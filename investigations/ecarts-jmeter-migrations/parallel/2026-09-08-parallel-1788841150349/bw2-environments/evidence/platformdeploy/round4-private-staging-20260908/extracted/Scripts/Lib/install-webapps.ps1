
# File: install-webapps.ps1
# Module to manage WA  deployment
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module "..\Modules\logger.psm1"
using module "..\Modules\deployCfg.psm1"
using module "..\Modules\Utils.psm1"
using module "..\Modules\DevUtils.psm1"
using module "..\Modules\DockerUtils.psm1"

# Microsoft.Web.Administration.dll lives in %windir%\System32\inetsrv, which PS7 (.NET 7+)
# does not search by default. Loading it explicitly makes the ServerManager type available
# without going through the IISAdministration module (which has its own native-loading issues).
Add-Type -Path (Join-Path $env:SystemRoot "System32\inetsrv\Microsoft.Web.Administration.dll")

# Create a website and add a self-signed certificate if binding is https
function CreateWebAppsSite([string] $webSite, [string] $protocol, [string] $certHostName)
{
    [Logger]::Info("Create new WebSite {$webSite} with protocol {$protocol}")
    $path = "$Env:systemdrive\inetpub\wwwroot"
    [Logger]::Verbose("Physical path is {$path}")

    if ("https" -eq $protocol)
    {
        $hostName = $certHostName.ToLower()
        # Lowercase: all URLs in configuration are always lowercase
        [Logger]::Verbose("Creating a self-signed certificate on {$hostName}")
        # ref: https://learn.microsoft.com/en-us/powershell/module/iisadministration/new-iissitebinding?view=windowsserver2022-ps#example-4
        # This password protects only a temporary self-signed dev certificate — it is NOT a production secret.
        $password     = "dev-certificate"
        $friendlyName = "Cegid Retail Y2 ($($Env:Computername)) IIS SSL Certificate"
        $certificate  = New-SelfSignedCertificate -DnsName $hostName `
                            -CertStoreLocation "Cert:\LocalMachine\My" `
                            -FriendlyName $friendlyName
        $securedString = ConvertTo-SecureString -String $password -Force -AsPlainText
        $pfxPath = "$Env:systemdrive\inetpub\wwwroot\test-certificate.pfx"
        Export-PfxCertificate -FilePath $pfxPath `
                              -Cert "cert:\localmachine\my\$($certificate.Thumbprint)" `
                              -Password $securedString
        Import-PfxCertificate -FilePath $pfxPath `
                              -CertStoreLocation "Cert:\LocalMachine\Root" `
                              -Password $securedString

        # Create the site directly with the HTTPS binding — no interim HTTP binding needed.
        # Using $sm.Sites.Add() (ServerManager API) avoids the Remove-IISSiteBinding call that was
        # used in the previous temp-port approach: in Windows Server Core containers some versions of
        # the IISAdministration module delete the site when Remove-IISSiteBinding removes the binding
        # that was used to create it, leaving $sm.Sites[$webSite] null afterwards.
        #
        # We use New-Object Microsoft.Web.Administration.ServerManager (not Get-IISServerManager).
        # Get-IISServerManager returns a MODULE-CACHED shared instance: calling Dispose() on it
        # poisons the cache — every subsequent Get-IISServerManager call in this process returns
        # the same disposed object, causing either ObjectDisposedException or "Cannot index into a
        # null array" ($sm.Sites returns null on a disposed SM). Creating our own instance via
        # New-Object gives us an independent object whose lifecycle we control safely.
        #
        # IMPORTANT: all modifications (site binding AND security/access section) are batched into
        # a SINGLE CommitChanges() call. Two sequential CommitChanges() calls trigger two separate
        # IIS config-reload cycles. In Windows Server Core containers the second reload can cause
        # IIS to stop/restart the HTTPS site, making it lose its HTTP.SYS SSL cert registration;
        # the TLS handshake then fails with "connection forcibly closed by remote host".
        [Logger]::Verbose("Creating site {$webSite} with HTTPS binding on port 443")
        $sm = New-Object Microsoft.Web.Administration.ServerManager
        try
        {
            # --- binding ---
            # Empty host header ("*:443:") + sslFlags 0 = non-SNI, port-wide default certificate.
            # A host-header binding with sslFlags 1 (SNI required) makes HTTP.SYS reset any
            # ClientHello that carries no SNI extension, at the TLS layer, before the request ever
            # reaches the application (so nothing is logged anywhere). Java's TLS stack — used by
            # JMeter's HTTP sampler — does not send SNI for dotless/single-label hostnames, which is
            # exactly what Docker auto-generates as container hostname (e.g. "e27a7cd82729").
            # This container only ever hosts one HTTPS site on port 443, so a default certificate
            # serves every client (SNI-aware or not) without ambiguity.
            $site    = $sm.Sites.Add($webSite, "https", "*:443:", $path)
            $binding = $site.Bindings[0]
            $binding.CertificateHash      = $certificate.GetCertHash()
            $binding.CertificateStoreName = "My"
            $binding.SetAttributeValue("sslFlags", 0)   # 0 = no SNI requirement

            # --- SSL-required access flag (set in memory before committing) ---
            # GetApplicationHostConfiguration() works with the SM's in-memory model, so the site
            # added above is already visible here even before CommitChanges().
            [Logger]::Verbose("Enforce SSL required on site {$webSite}")
            $config  = $sm.GetApplicationHostConfiguration()
            $section = $config.GetSection("system.webServer/security/access", $webSite)
            $section["sslFlags"] = "Ssl"

            # --- single atomic commit — one IIS config-reload, one HTTP.SYS registration ---
            $sm.CommitChanges()
        }
        finally
        {
            $sm.Dispose()
        }

        # Belt-and-suspenders: explicitly register the SSL cert with HTTP.SYS as the port-wide
        # default certificate (ipport, NOT hostnameport — hostnameport is the SNI-only form and
        # would reject SNI-less clients such as JMeter, see the binding comment above).
        # IIS normally does this during site start, but in some Windows Server Core container builds
        # the automatic registration is skipped or delayed when the site is created via the
        # ServerManager API.  Calling netsh here ensures the binding is present immediately.
        # "Already registered" (error 183 in output text) is silently tolerated — it means IIS
        # beat us to it, which is fine.  netsh exit codes are unreliable; we parse the output text.
        [Logger]::Verbose("Registering SSL certificate with HTTP.SYS as default certificate for ipport 0.0.0.0:443")
        $certHashHex = [BitConverter]::ToString($certificate.GetCertHash()).Replace("-", "").ToLower()
        $appId       = "{" + [System.Guid]::NewGuid().ToString() + "}"
        $netshOut    = (& netsh http add sslcert ipport="0.0.0.0:443" `
                            certhash="$certHashHex" certstorename="My" appid="$appId" 2>&1) -join " "
        if ($netshOut -match "(?i)successfully|183")
        {
            [Logger]::Verbose("HTTP.SYS SSL cert binding: {$netshOut}")
        }
        else
        {
            [Logger]::Warning("netsh http add sslcert: {$netshOut}")
        }
    }
    else
    {
        # HTTP site — use ServerManager API directly, consistent with the HTTPS path above.
        [Logger]::Verbose("Creating site {$webSite} with HTTP binding on port 80")
        $smHttp = New-Object Microsoft.Web.Administration.ServerManager
        try
        {
            $smHttp.Sites.Add($webSite, "http", "*:80:", $path) | Out-Null
            $smHttp.CommitChanges()
        }
        finally
        {
            $smHttp.Dispose()
        }
    }
}

function SetFullControlForIisUsers( [string] $folder, [bool] $force = $FALSE)
{
    if (([DockerUtils]::IsRunningInDockerContainer() -eq $FALSE) -or ($force -eq $TRUE))
    {
        [Logger]::Verbose("Set Acl for folder {$folder} ( BUILTIN\IIS_IUSRS Allow FullControl )")
        $Acl = Get-ACL $folder
        $AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\IIS_IUSRS","FullControl","ContainerInherit,Objectinherit","none","Allow")
        $Acl.AddAccessRule($AccessRule)
        Set-Acl $folder $Acl
    }
    else
    {
        # In a docker container, updating acl on subfolder raise error "This access control list is not in canonical form and therefore cannot be modified."
        # We will set it lately with $Force option on c:\inetpub\wwwroot folder and let subfolder inherit it
        [Logger]::Verbose("Set Acl for folder {$folder} skipped in a docker context")
    }
}

# WebApps need to have a local folder named "temp"
# USER_IIS, need to work with it so set fullControl
function ConfigureWebAppSpecialFolders([string] $waSiteName)
{
    # Authentication server need to have a logs, temp and keys subfolders
    # Other WebApps need a logs and a temp subfolders
    # User BUILTIN\IIS_IUSRS must have full control on it

    $waFileFolder = [Utils]::IIsWebAppFilePath( ([DeployCfg]::GetWebbAppsIisSite( $deployConfig )), $waSiteName)
    # configure logs sub folder used by all WebApp
    $logsFolder="$waFileFolder\logs"
    if (!(Test-Path -Path "$logsFolder"))
    {
        [Logger]::Verbose("Create folder $logsFolder")
        New-Item -Path "$logsFolder" -ItemType Directory >> $NULL
    }
    SetFullControlForIisUsers -folder $logsFolder

    # configure temp sub folder used by all WebApp
    $tempFolder="$waFileFolder\temp"
    if (!(Test-Path -Path "$tempFolder"))
    {
        [Logger]::Verbose("Create folder {$tempFolder}")
        New-Item -Path "$tempFolder" -ItemType Directory >> $NULL
    }
    SetFullControlForIisUsers -folder $tempFolder

    # configure keys subfolders only used by authenticationserver
    if ( $waSiteName -eq "AuthenticationServer")
    {
        $tempFolder="$waFileFolder\keys"
        if (!(Test-Path -Path "$tempFolder"))
        {
            [Logger]::Verbose("Create folder {$tempFolder}")
            New-Item -Path "$tempFolder" -ItemType Directory >> $NULL
        }
        SetFullControlForIisUsers -folder $tempFolder
    }

    if (([DockerUtils]::IsRunningInDockerContainer() -eq $TRUE))
    {
        # In a docker container we fix acl on c:\inetpub\wwwroot folder and let subfolder inherit it
        SetFullControlForIisUsers -folder "c:\inetpub\wwwroot" -force $TRUE
    }
}

function SetWebAppApplicationPool([string] $waSiteName)
{
    $appPoolName       = "CegidRetailPool$($waSiteName)WA"
    $netCoreWASiteName = [DeployCfg]::GetWebbAppsIisSite($deployConfig)

    # New-IISAppPool does not exist in IISAdministration — use ServerManager API directly.
    # New-Object creates an independent instance (not the module-cached one returned by
    # Get-IISServerManager), so Dispose() here does not poison the shared module cache.
    $sm = New-Object Microsoft.Web.Administration.ServerManager
    try
    {
        if ($null -eq $sm.ApplicationPools[$appPoolName])
        {
            [Logger]::Verbose("Create new Application Pool {$appPoolName}")
            $sm.ApplicationPools.Add($appPoolName) | Out-Null
        }
        else
        {
            [Logger]::Verbose("Application Pool {$appPoolName} already exists")
        }
        [Logger]::Verbose("Set Application pool {$appPoolName} to WebApp {$waSiteName}")
        $sm.ApplicationPools[$appPoolName].ManagedRuntimeVersion = "v4.0"
        # Two-step null guard: if the site is not found the subsequent indexer on null throws
        # "Cannot index into a null array" with no useful context — fail explicitly instead.
        $iisWebAppsSite = $sm.Sites[$netCoreWASiteName]
        if ($null -eq $iisWebAppsSite)
        {
            $availableSites = ($sm.Sites | ForEach-Object { $_.Name }) -join ", "
            throw "IIS site '$netCoreWASiteName' not found. Available sites: [$availableSites]"
        }
        $iisApp = $iisWebAppsSite.Applications["/$waSiteName"]
        if ($null -eq $iisApp)
        {
            throw "IIS application '/$waSiteName' not found in site '$netCoreWASiteName'"
        }
        $iisApp.ApplicationPoolName = $appPoolName
        $sm.CommitChanges()
    }
    finally
    {
        $sm.Dispose()
    }
}

function installWebApps([string] $waDownloadFolder, [string] $waSiteName)
{
    # Execute WebDeploy
    # MsDeploy ne marche pas bien via power shell cf : https://stackoverflow.com/questions/59826215/msdeploy-powershell-script-parameters-does-not-work
    # Repertoire d'install via registry
    try{
        $msDeployPath = (Get-ItemProperty -Path "HKLM:Software\Microsoft\IIS Extensions\MSDeploy\3\" -Name "InstallPath").InstallPath
    }
    catch
    {
        [Logger]::Fatal("MSDeploy V3 installation path not found !" )
        throw "MSDeploy V3 installation path not found !"
    }
    $netCoreWASiteName = [DeployCfg]::GetWebbAppsIisSite( $deployConfig )
    # Check if site used by webapps exists — use ServerManager directly (no IIS cmdlets)
    $smCheck = New-Object Microsoft.Web.Administration.ServerManager
    $siteExists = $null -ne $smCheck.Sites[$netCoreWASiteName]
    $smCheck.Dispose()
    if (-not $siteExists)
    {
        $protocol = [DeployCfg]::GetWebbAppsProtocol( $deployConfig )
        # computername for certificats must by the dns name used by iis
        # this is computername for local machine or private vm
        # must be public dns for public vm see parameters "SpecificAuthServerHostBaseUri" and "SpecificWebAppsHostBaseUri"
        if ( $waSiteName -eq "AuthenticationServer")
        {
            $certhostName = [DeployCfg]::GetAuthServerHostBaseUri($deployConfig)
        }
        else {
            $certhostName = [DeployCfg]::GetWebAppsHostBaseUri($deployConfig)
        }
        CreateWebAppsSite -webSite "$netCoreWASiteName" -protocol $protocol -certHostName $certhostName
    }

    $msdeploy = "$msDeployPath\msdeploy.exe"
    $params = "--%", "-verb:sync", "-source:iisapp='$waDownloadFolder'", "-dest:iisapp='$netCoreWASiteName/$waSiteName'", "-disableLink:AppPoolExtension", "-disableLink:ContentExtension", "-disableLink:CertificateExtension", "-enableRule:DoNotDeleteRule", "-retryAttempts:3", "-retryInterval:3000"
    $result = & "$msdeploy" @params
    if( $? )
    {
        [Logger]::Verbose(($result | Where-Object { $_ } | out-string ))
    }
    else
    {
        [Logger]::Fatal(($result | Where-Object { $_ } | out-string ))
        throw ($result | out-string )
    }

    ConfigureWebAppSpecialFolders -waSiteName $waSiteName
    SetWebAppApplicationPool -waSiteName $waSiteName
}
