# File: dockerize-cy2px.ps1
# Module to convert input deploy configfile into a dockerfile that can be used in a dockerized deployment

#Requires -Version 7.6

using module "..\Modules\logger.psm1"
using module "..\Modules\DeployCfg.psm1"
using module "..\Modules\DockerUtils.psm1"

function CanUseLocalDBWithBackupMode([System.Xml.XmlNode] $dbServer, [string] $dockerDataFolder)
{
    $haveLocalDbError = $FALSE
    foreach($db in $server.SelectNodes("tenants/*"))
    {
        if ( (Test-Path "$dockerDataFolder\$($db.databaseName).bak" -PathType Leaf) -eq $FALSE)
        {
            [Logger]::Error("Database backup {$($db.databaseName).bak} not found in folder {$dockerDataFolder}. Can not use local Database mode {Backup}")
            $haveLocalDbError = $TRUE
        }
    }
    return $haveLocalDbError
}

function CanUseLocalDBWithAttachMode([System.Xml.XmlNode] $dbServer, [string] $dockerDataFolder)
{
    $haveLocalDbError = $FALSE
    foreach($db in $server.SelectNodes("tenants/*"))
    {
        if ( (Test-Path "$dockerDataFolder\$($db.databaseName).MDF" -PathType Leaf) -eq $FALSE)
        {
            [Logger]::Error("Database file {$($db.databaseName).MDF} not found in folder {$dockerDataFolder}. Can not use local Database mode {Attach}")
            $haveLocalDbError = $TRUE
        }
        if ( (Test-Path "$dockerDataFolder\$($db.databaseName).MDF" -PathType Leaf) -eq $FALSE)
        {
            [Logger]::Error("Database file {$($db.databaseName)_0.ldf} not found in folder {$dockerDataFolder}. Can not use parameter {Attach}")
            $haveLocalDbError = $TRUE
        }
    }
    return $haveLocalDbError
}

# Dockerize databases configuration
function DockerizeDatabasesConfiguration ([string] $dockerCy2px, [string] $LocalDBMode, [string] $dockerDataFolder)
{
    $cy2pxConfig = [xml](Get-Content "$dockerCy2px")
    $dbServers = $cy2pxConfig.SelectNodes("//configuration/databases/server")
    if ($dbServers.Count -eq 0)
    {
        [Logger]::Warning("Using a deployment configuration file {without} tenants definition")
    }
    else
    {
        # Replace all database server host name with their appropriate IP address (to avoid DNS problem when running in a docker container)
        [Logger]::Verbose("Replace database server hostname by IP address if needed")
        [DockerUtils]::SetIPAddressForDatabaseServerHost($dockerCy2px)

        if ($LocalDBMode.ToUpper() -ne "NONE")
        {
            # Searh database server of this docker host ( depend if running on pipeline or on local computer)
            if ($Env:TF_BUILD -ne $TRUE)
            {
                $dbHost = $Env:COMPUTERNAME
            }
            else
            {
                $dbHost = [DockerUtils]::ContainerHostToken()
            }

            $server = $cy2pxConfig.SelectSingleNode("//configuration/databases/server") | Where-Object { $_.instance.ToUpper().StartsWith($dbHost.ToUpper())}
            if ($NULL -eq $server)
            {
                [Logger]::Fatal("There is no database used by the docker host {$dbHost} in you deployment. Can not use parameter {LocalDBInContainer}")
                throw
            }
            $haveLocalDbError = $FALSE
            if ($LocalDBMode.ToUpper() -eq "BACKUP")
            {
                $haveLocalDbError = CanUseLocalDBWithBackupMode -dbServer $server -dockerDataFolder $dockerDataFolder
            }
            else
            {
                if ($LocalDBMode.ToUpper() -eq "ATTACH")
                {
                    $haveLocalDbError = CanUseLocalDBWithAttachMode -dbServer $server -dockerDataFolder $dockerDataFolder
                }
            }
            If ($haveLocalDbError)
            {
                [Logger]::Fatal("One or more file are missing. Can not use parameter {LocalDBInContainer}")
                throw
            }
            else
            {
                # Set databases server as ContainerHostToken()
                $server.instance = [DockerUtils]::ContainerHostToken()
                $cy2pxConfig.Save($dockerCy2px)
            }
        }
    }
}

# Dockerize a deploy config file
function DockerizeDeployConfigFile([string] $dockerCy2px, [string] $LocalDBMode, [string] $dockerDataFolder)
{
    [Logger]::Info("Prepare file {$dockerCy2px} to be used into a containerized deployment")
    # if current host is used into roles définition change it to container host token that will be replaced into the running image
    if ($Env:TF_BUILD -ne $TRUE)
    {
        [Logger]::Verbose("Replace docker host in role definition list with container host token")
        [DockerUtils]::DockerHostToContainerHostToken($dockerCy2px)
    }
    else
    {
        [Logger]::Verbose("Replace container host token by hostname in role definition list")
        [DockerUtils]::ContainerHostTokenToHostName($dockerCy2px)
    }

    DockerizeDatabasesConfiguration -dockerCy2px $dockerCy2px -LocalDBMode $LocalDBMode -dockerDataFolder $dockerDataFolder
}