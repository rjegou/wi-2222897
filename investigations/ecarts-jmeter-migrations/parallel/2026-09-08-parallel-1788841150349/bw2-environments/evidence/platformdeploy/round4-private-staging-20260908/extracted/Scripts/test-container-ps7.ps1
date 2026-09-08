# File: test-container.ps1
# Manage test of a containerized deployment
# Used by for local deployment into a docker image
# This script always run into a container. ( local or in a containerized job)

#Requires -Version 7.6

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\DeployCfg.psm1"
using module "..\Scripts\Modules\DevUtils.psm1"
using module "..\Scripts\Modules\Roles.psm1"

param (
    [version]$coreVersion = $(throw "coreVersion is a required parameter"),
    [string]$dockerCy2px = $(throw "dockerCy2px is a required parameter"),
    [switch]$verbose
)

function GetWebPageSafe([string] $info, [string] $uri, [bool] $retryOnce = $false)
{
    $success = $FALSE
    [Logger]::Info("$info at {$uri}")
    try {
        $result = Invoke-RestMethod -Method Get -Uri "$uri"
        $success = $TRUE
        [Logger]::Verbose($result)
    }
    catch
    {
        if ($retryOnce)
        {
            [Logger]::Verbose("Retry .... (we can have a time out !)")
            try
            {
                $result = Invoke-RestMethod -Method Get -Uri "$uri"
                $success = $TRUE
                [Logger]::Verbose($result)
            }
            catch {
                [Logger]::Error("Get web page failure:")
                [Logger]::Error($_)
            }
        }
        else
        {
            [Logger]::Error("Get web page failure:")
            [Logger]::Error($_)
        }
    }

    return $success
}

function SqlConnectionTests
{
    $success = $TRUE
    # Select only the two columns displayed in the verbose log (SELECT * produces unusable output with sqlcmd.exe -h -1)
    $query = "SELECT TOP(1) SO_SOCIETE, SO_VERSIONBASE FROM societe"
    [Logger]::Info("Test sql connections to tenants with {$query}")
    # Get databases instance to launch query
    $tenants = [DeployCfg]::TenantList($dockerCy2px)
    foreach ($db in $tenants)
    {
        try {
            # sqlcmd.exe is used instead of Invoke-Sqlcmd: the SqlServer PS module is not installed in the container.
            # -h -1  suppresses column headers
            # -W     removes trailing whitespace
            # -C     trusts the container's self-signed certificate (SQL Server 2025 defaults to Encrypt=Mandatory)
            # 2>&1   captures stderr into the output stream so errors appear in the throw message
            $output = & sqlcmd -S "$($db.server)" -U sa -P "$env:sa_password" -d "$($db.name)" -Q "$query" -h -1 -W -C 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "sqlcmd exited with code $LASTEXITCODE`n$($output -join "`n")"
            }
            # Filter out sqlcmd informational lines (e.g. "Changed database context to ...") to get the first data row.
            $firstRow = $output | Where-Object { $_ -and $_ -notmatch '^Changed database context' } | Select-Object -First 1
            [Logger]::Verbose("Server {$($db.server)} - db {$($db.name)} => $firstRow")
        }
        catch {
            $success = $FALSE
            [Logger]::Error("SQL query failed on Server {$($db.server)} - db {$($db.name)}")
            [Logger]::Error($_)
        }
    }
    return $success
}

function AuthenticationTests([string] $authUri)
{
    $success = $TRUE
    [Logger]::Info("Test authentication on all tenants (with cegid/cegid) at {$authUri}")
    # Get databases instance to laucnh query
    $tenants = [DeployCfg]::TenantList($dockerCy2px)
    foreach ($db in $tenants)
    {
        try {
            $data = "client_id=CegidRetailResourceFlowClient&username=cegid%40$($db.id)&password=cegid&grant_type=password&scope=RetailBackendApi+offline_access"
            $headers = @{ 'Content-Type' = 'application/x-www-form-urlencoded; charset=UTF-8' }
            $response = Invoke-RestMethod -Method POST -Uri "$authUri" -Headers $headers -Body $data
            [Logger]::Verbose("token for $($db.id) : {$($response.access_token)}")
        }
        catch {
            $success = $FALSE
            [Logger]::Error("Fail to get token bearer for tenant {$($db.id)}")
            [Logger]::Error($_)
        }
    }
    return $success
}

function WorkerProcessPingTests([string] $uri)
{
    $success = $TRUE
    [Logger]::Info("Test WorkerProcess ping on all tenants (with cegid/cegid) at {$uri}")
    # Get databases instance to laucnh query
    $tenants = [DeployCfg]::TenantList($dockerCy2px)
    foreach ($db in $tenants)
    {
        $loop = $TRUE
        $maxRetry = 20;
        $totalRetry = $maxRetry;
        While (($loop -eq $TRUE) -and ($totalRetry -ge 0))
        {
            try {
                $login="$($db.id)\cegid:cegid"
                $basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($login))
                $headers = @{ 'Content-Type'  = "text/xml; charset=UTF-8";
                                'SOAPAction'    = "http://www.cegid.fr/Retail/1.0/IWorkerProcessService/Ping";
                                'Authorization' = "Basic $basicAuth"
                            }
                $soap="<Envelope xmlns='http://schemas.xmlsoap.org/soap/envelope/'>
                        <Body>
                            <Ping xmlns='http://www.cegid.fr/Retail/1.0'>
                                <input>Hello</input>
                                <clientContext>
                                    <DatabaseId>$($db.id)</DatabaseId>
                                </clientContext>
                            </Ping>
                        </Body>
                    </Envelope>"

                $response = Invoke-RestMethod -Method POST -Uri "$Uri" -Headers $headers -Body $soap
                Write-Host $response.Content
                [Logger]::Verbose("Ping reply for $($db.id) : {$($response.OuterXml)} after $($maxRetry - $totalRetry) retries")
                $loop = $FALSE
                $success = $TRUE
            }
            catch {
                $success = $FALSE
                if ($totalRetry -eq 0)
                {
                    $loop = $FALSE
                    [Logger]::Error("Fail ping workprocess for tenant {$($db.id)}")
                    [Logger]::Error($_)

                }
            }
            if ($loop -eq $TRUE)
            {
                $totalRetry--
                [Logger]::Verbose("Retry .... (we can have a time out !) $totalRetry left")
                Start-Sleep -Seconds 30
            }
        }
    }
    return $success
}

###### main ####

$global:verbose = $verbose # to be known by logger module
$ErrorActionPreference = "Stop"

$hostname = $env:computername.ToLower()
$cy2pxConfig = [xml](Get-Content "$dockerCy2px")
$dbServers = $cy2pxConfig.SelectNodes("//configuration/databases/server")
$useTenants = ($dbServers.Count -gt 0)

$nbErrors = 0
try {
    $uri = "http://$hostname/retail_$($coreVersion.Major).$($coreVersion.Minor)"
    $nbErrors += [DevUtils]::IIF( (GetWebPageSafe -info "Test Y2 home page" -uri "$($uri)"), 0, 1)

    if ($useTenants)
    {
        Write-Host
        # Perform sql connection tests
        $nbErrors += [DevUtils]::IIF((SqlConnectionTests), 0, 1)
    }
    else
    {
        [Logger]::Info("Skip database connection tests because deployement didn't use tenants definition")
    }
    Write-Host
    # Test health page : first test can failed with a time out error
    $uri = "http://$hostname/retail_$($coreVersion.Major).$($coreVersion.Minor)/health/"
    $nbErrors += [DevUtils]::IIF((GetWebPageSafe -info "Test Y2 health page" -uri $uri -retryOnce $true), 0, 1)

    $uri = "http://$hostname/retail_$($coreVersion.Major).$($coreVersion.Minor)/WorkerProcessService.svc"
    if ([DeployCfg]::HostHaveRole($dockerCy2px, $hostname, [RoleTypes]::Wp))
    {
        if ($useTenants)
        {
            Write-Host
            $nbErrors += [DevUtils]::IIF((WorkerProcessPingTests -uri "$uri"), 0, 1)
        }
        else
        {
            [Logger]::Info("Skip test to get workerprocess ping because deployement didn't use tenants definition")
        }
    }
    Write-Host
    $protocol = [DeployCfg]::GetWebbAppsProtocol($dockerCy2px)
    $uri = "$($protocol)://$hostname/authenticationserver"
    if ([DeployCfg]::HostHaveRole($dockerCy2px, $hostname, [RoleTypes]::AuthServer) -and [DeployCfg]::PackageUsed($dockerCy2px, "y2.core.authenticationserver"))
    {
        $nbErrors += [DevUtils]::IIF( (GetWebPageSafe -info "Test Authentication Server home page" -uri $uri), 0, 1)
        if ($useTenants)
        {
            Write-Host
            $nbErrors += [DevUtils]::IIF((AuthenticationTests -authUri "$($protocol)://$hostname/authenticationserver/connect/token"), 0, 1)
        }
        else
        {
            [Logger]::Info("Skip test to get authentication token bearer because deployement didn't use tenants definition")
        }
    }
    else {
        [Logger]::Info("Skip authentication server tests because deployement didn't use it")
    }
}
finally
{
    if ($nbErrors -gt 0)
    {
        throw "One or tests failed"
    }
}