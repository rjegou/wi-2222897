
# File: init-container.ps1
# Manage a containerized deployment
# Used by for local deployment into a docker image
# This script always run into a container.

#Requires -Version 7.6
# In a local container:
#   - deployment sources are mapped into c:\deploys
#   - docker data are mapped into c:\data
#   - Deployment configuration file is c:\data\dockerdeploy.cy2px
#
# In a containerized job:
#   - deployment are extracted $(Agent.TempDirectory)/Deploy
#   - docker data are available into $(Agent.TempDirectory)/Deploy/DOcker/data
#   - Deployment configuration file isprovided as parameter

# 2022-02-02 : file creation

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\DeployCfg.psm1"
using module "..\Scripts\Modules\DockerUtils.psm1"
using module "..\Scripts\Modules\DevUtils.psm1"
using module "..\Scripts\Modules\Roles.psm1"
using module "..\Scripts\Modules\Utils.psm1"

param (
    [version]$coreVersion = $(throw "coreVersion is a required parameter"),
    [string]$dockerCy2px = $(throw "dockerCy2px is a required parameter"),
    [switch]$doTests,
    [string]$localDBMode,
    [switch]$verbose
)

$global:verbose = $verbose # to be known by logger module
$ErrorActionPreference = "Stop"

function AttachLocalDatabases([string] $deployConfig)
{
    [Logger]::Info("Attach databases into container")
    $sqlInstance = "$($env:computername)\$($env:sqlinstance)"
    $userDb      = "sa"
    $pwdDb       = $env:sa_password

    $config = [xml](Get-Content "$deployConfig")
    $server = $config.SelectSingleNode("//configuration/databases/server") | Where-Object { $_.instance.ToUpper().StartsWith([DockerUtils]::ContainerHostToken())}
    if($NULL -eq $server)
    {
        [Logger]::Warning("No local database server to use found into {$deployConfig} file")
        Exit
    }
    # Change server instance
    $old = $server.instance
    $server.instance = $sqlInstance
    $databasesFolder = [DockerUtils]::ContainerDataFolder()
    [Logger]::Verbose("Change instance {$old} to {$($server.instance)}")
    foreach($db in $server.SelectNodes("tenants/*"))
    {
        # Example : [{'dbName': 'AUTO_2300','dbFiles': ['C:\\tmpsql\\AUTO_2300.MDF','C:\\tmpsql\\AUTO_2300_0.ldf']}]"
        $files = @("(FILENAME = N'$databasesFolder\$($db.databaseName).MDF')", "(FILENAME = N'$databasesFolder\$($db.databaseName)_0.ldf')");
        $files = $files -join ","
        $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '" + $($db.databaseName) + "') BEGIN EXEC sp_detach_db [$($db.databaseName)] END;CREATE DATABASE [$($db.databaseName)] ON $($files) FOR ATTACH;"
        # Use sqlcmd with LaunchProcess instead of Invoke-Sqlcmd to manage console output
        [Logger]::Verbose("{Attach database} : Invoke-Sqlcmd -ServerInstance {'$sqlInstance'} -Username {$userDb} -Password {$pwdDb} -Database master --Query {$sqlcmd} -QueryTimeout 0 -Verbose")
        [Utils]::LaunchProcessHideCmdLine( "sqlcmd", "-S `"$sqlInstance`" -U $userDb -P $pwdDb -C -Q `"$sqlcmd`"" )
        # Manage broker
        $sqlcmd = "ALTER DATABASE [$($db.databaseName)] SET DISABLE_BROKER; ALTER DATABASE [$($db.databaseName)] SET NEW_BROKER; ALTER DATABASE [$($db.databaseName)] SET ENABLE_BROKER"
        # & sqlcmd -S localhost\SQLEXPRESS -U sa -P Cegid.2019 -Q $sqlcmd
        [Logger]::Verbose("{Set broker} : Invoke-Sqlcmd -ServerInstance {'$sqlInstance'} -Username {$userDb} -Password {$pwdDb} -Database master --Query $sqlcmd -QueryTimeout 0 -Verbose")
        [Utils]::LaunchProcessHideCmdLine( "sqlcmd", "-S `"$sqlInstance`" -U $userDb -P $pwdDb -C -Q `"$sqlcmd`"" )

        $old = $db.password
        $db.userId  ="sa"
        $db.password = $env:sa_password
        [Logger]::Verbose("Database {$($db.id)} : Set dbuser = {$($db.userId)} dbpwd = {$($db.password)}")
    }

    [Logger]::Verbose("Save new {$deployConfig} file")

    $config.Save($deployConfig)
    Write-Host
}

function RestoreLocalDatabases( [string] $deployConfig)
{
    [Logger]::Info("Restore databases into container")
    $sqlInstance = "$($env:computername)\$($env:sqlinstance)"
    $userDb      = "sa"
    $pwdDb       = $env:sa_password

    $config = [xml](Get-Content "$deployConfig")
    $server = $config.SelectSingleNode("//configuration/databases/server") | Where-Object { $_.instance.ToUpper().StartsWith([DockerUtils]::ContainerHostToken())}
    if ($NULL -eq $server)
    {
        [Logger]::Warning("No local database server to use found into {$deployConfig} file")
        Exit
    }
    # Change server instance
    $old = $server.instance
    $server.instance = $sqlInstance
    $dbFolder = [DockerUtils]::ContainerDataFolder()
    [Logger]::Verbose("Change instance {$old} to {$($server.instance)}")
    foreach($db in $server.SelectNodes("tenants/*"))
    {
        # Update restauration script
        $restoreDb   = Get-Content "$dbFolder\restore-databases.sql.template" -raw
        $restoreDb   = $restoreDb.Replace("__databaseName__", "$($db.databaseName)")
        $restoreDb   = $restoreDb.Replace("__backupFile__", "$dbFolder\$($db.databaseName).bak")
        $restoreDb   = $restoreDb.Replace("__localDataPath__", $env:databasesFolder)

        [Logger]::Verbose("{Restore database} : Invoke-Sqlcmd -ServerInstance {'$sqlInstance'} -Username {$userDb} -Password {$pwdDb} -Database master --Query $qryRestoreDb -QueryTimeout 0 -Verbose")
        # Use sqlcmd with LaunchProcess instead of Invoke-Sqlcmd to manage console output
        [Utils]::LaunchProcessHideCmdLine( "sqlcmd", "-S `"$sqlInstance`" -U $userDb -P $pwdDb -C -Q `"$restoreDb`"" )
        # Manage broker
        $sqlcmd = "ALTER DATABASE [$($db.databaseName)] SET DISABLE_BROKER; ALTER DATABASE [$($db.databaseName)] SET NEW_BROKER; ALTER DATABASE [$($db.databaseName)] SET ENABLE_BROKER"
        # & sqlcmd -S localhost\SQLEXPRESS -U sa -P Cegid.2019 -Q $sqlcmd
        [Logger]::Verbose("{Set broker} : Invoke-Sqlcmd -ServerInstance {'$sqlInstance'} -Username {$userDb} -Password {$pwdDb} -Database master --Query {$sqlcmd} -QueryTimeout 0 -Verbose")
        [Utils]::LaunchProcessHideCmdLine( "sqlcmd", "-S `"$sqlInstance`" -U $userDb -P $pwdDb -C -Q `"$sqlcmd`"" )

        # Update database to use integrated authentication (only when using backup)
        $sqlcmd = "Update paramsoc set soc_data='-' where soc_nom='SO_MAUTHENTIFICATIONNTOBLIG'; UPDATE UTILISAT SET US_DOMAINEAUTHENT='$($db.id)'"
        [Logger]::Verbose("{Integrated Authent} : Invoke-Sqlcmd -ServerInstance {'$sqlInstance'} -Username {$userDb} -Password {$pwdDb} -Database {'$($db.databaseName)'} --Query {$sqlcmd} -QueryTimeout 0 -Verbose")
        [Utils]::LaunchProcessHideCmdLine( "sqlcmd", "-S `"$sqlInstance`" -U $userDb -P $pwdDb -d $($db.databaseName) -C -Q `"$sqlcmd`"" )

        # Change database connection string
        $old = $db.password
        $db.userId  ="sa"
        $db.password = $env:sa_password
        [Logger]::Verbose("Database {$($db.id)} : Set dbuser = {$($db.userId)} dbpwd = {$($db.password)}")
    }

    [Logger]::Verbose("Save new {$deployConfig} file")

    $config.Save($deployConfig)
    Write-Host
}

###### main ####

$cy2px="$dockerCy2px"
$y2CoreHostMappedUriInfo = ""
try {
    [Logger]::Info("Validate prerequisites in selected images")
    & $PSScriptRoot\check-prerequisites.ps1

    [Logger]::Info("Start containerized deployment")
    # Check if deployment use tenants
    $cy2pxConfig = [xml](Get-Content "$cy2px")
    $dbServers = $cy2pxConfig.SelectNodes("//configuration/databases/server")
    $useTenants = ($dbServers.Count -gt 0)
    [Logger]::Verbose("Check if deployment use tenants : Result = {$useTenants}")

    # Configure and restaure database if we use db in container
    if ($localDBMode.ToUpper() -ne "NONE")
    {
        if ($useTenants)
        {
            if ($localDBMode.ToUpper() -eq "BACKUP")
            {
                RestoreLocalDatabases -deployConfig $cy2px
            }
            if ($localDBMode.ToUpper() -eq "ATTACH")
            {
                AttachLocalDatabases -deployConfig $cy2px
            }
        }
        else
        {
            [Logger]::Warning("Skip database configuration because deployement didn't use tenants definition")
        }
    }

    # When deployment is made into a local container,
    # we must change current location to use mounted path

    if ($Env:TF_BUILD -ne $TRUE)
    {
        Set-Location "c:\deploy"
    }

    [Logger]::Info("Launch deployment of file {$cy2px}")

    # if a host is used into roles contains container host token, change it to container host name
    [Logger]::Verbose("Replace container host token by hostname in role definition list")
    [DockerUtils]::ContainerHostTokenToHostName($cy2px)

    Write-Host
    # Create environment variable env:coreVersion used in deploy process
    $env:coreVersion = $coreVersion
    # Launch deployment
    & .\deploy.ps1 "$cy2px" -verbose:$verbose -noDownload -ignoreUpgrade
    $deploymentExitCode = $LASTEXITCODE
    if ($deploymentExitCode -ne 0)
    {
        [Logger]::Error("Deployment failed with exit code {$deploymentExitCode}")
        throw "Deployment failed with exit code $deploymentExitCode"
    }

    # Perfom simple test if wanted and if deployment end with success
    # and if we are not in a build context ( in this cas tests are running with a speicfic task)
    if ($Env:TF_BUILD -ne $TRUE)
    {
      if ($LASTEXITCODE -eq 0)
      {
        # On deployment success save uri that can be used from host to display them at the end
        $y2CoreHostMappedUriInfo = "http://localhost:5000/retail_$($coreVersion.Major).$($coreVersion.Minor)"
        $hostname = $env:computername.ToLower()
        $y2CoreHostUriInfo = "http://$hostname/retail_$($coreVersion.Major).$($coreVersion.Minor)"
        $waProtocol = [DeployCfg]::GetWebbAppsProtocol($cy2px)
        $WebAppHostUriInfo = "$($waProtocol)://$hostname"
        Write-Host
        if ($doTests)
        {
            try {
                & .\Scripts\test-container.ps1 -coreVersion $coreVersion -dockerCy2px "$cy2px" -verbose:$verbose
            }
            catch {
                [Logger]::Error("One or more tests failed")
            }
        }

        Write-Host
        Write-Host "--------------------------------------------------------"
        Write-Host "| Deployment ended : This current powershell session   |"
        Write-Host "| is running into your containerized deployment.       |"
        Write-Host "| Type Exit to quit and delete this container          |"
        Write-Host "--------------------------------------------------------"
        # Display hostUri info if deployment successfull
        if ( $y2CoreHostMappedUriInfo -ne "")
        {
            [Logger]::Highlight("Access URIs with container name")
            [Logger]::Info(" - Y2 Server Uri  : {$y2CoreHostUriInfo}")
            [Logger]::Info(" - Y2 WebApps Uri : {$WebAppHostUriInfo}  - Example: {$WebAppHostUriInfo/authenticationserver/}")
        }
      }

      Set-Location "c:\"
      Write-Host
      # Start a new powershell session with a custom prompt to keep container alive ( )
      powershell.exe { function Global:prompt { Write-Host -NoNewLine " CNTR $Env:ComputerName " -BackgroundColor White -ForegroundColor Black;
                                              Write-Host " $PWD " -BackgroundColor Cyan  -ForegroundColor Black;
                                              Write-Host -NoNewLine "$(Get-Date -f `"HH:mm:ss`")" -ForegroundColor Yellow;
                                              Write-Host -NoNewLine " >" -ForegroundColor Green;
                                              Write-Host -NoNewLine "" -ForegroundColor White;
                                              Return " ";
                                              } } -noexit
    }
}
catch {
    if ($Env:TF_BUILD -ne $TRUE)
    {
        Write-Host $_ -ForegroundColor Red
        Write-Host $PSItem.Exception -ForegroundColor Red
        Write-Host

        Write-Host "Fail ! (Press enter to end)" -ForegroundColor Red
        Read-Host
    }
    else
    {
        # Must fail when running into pipeline
        [Logger]::Error($_)
        [Logger]::Error($PSItem)
        Write-Host
        [Logger]::Error("Fail !")
        Exit 1
    }
}
