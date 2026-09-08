# File: docker-pipeline-deploy-ps7.ps1
# Manage containerized deployment in a job pipeline
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module ".\Scripts\Modules\logger.psm1"
using module ".\Scripts\Modules\DevUtils.psm1"
using module ".\Scripts\Modules\DeployCfg.psm1"
using module ".\Scripts\Modules\DockerUtils.psm1"
using module ".\Scripts\Modules\Utils.psm1"

param (
    [string]$deployConfig = "",
    [string]$RetailJfrogApiKey = $(throw "RetailJfrogApiKey is mandatory."),
    [string]$LocalDBInContainer = "None",
    [switch]$verbose
)

# include modules library ( $PSScriptRoot est le répertoire d'execution du script courant, donc celui qui charge la librairie )
. $PSScriptRoot\Scripts\Lib\dockerize-cy2px.ps1

# Set Location to relocate in case restart in admin mode
Set-Location $PSScriptRoot
$ErrorActionPreference = "Stop"
$global:verbose = $verbose # to be known by logger module
# Get scripts version
$scriptsVersion = ( Test-ScriptFileInfo -Path ".\Scripts\FileInfo.ps1").version

[logger]::Info("Y2 Platform Deploy Version {$scriptsVersion}")

if ($deployconfig.Trim() -eq "")
{
    [Logger]::Warning("Deployment config file {-deployConfig} not set, use default value equals to {.\y2deploy.cy2px}")
    $deployConfig = '.\y2Deploy.cy2px'
}

# Set y2 core version deployed
try {
    if (-not(Test-Path -Path $deployConfig -PathType Leaf))
    {
        [Logger]::Fatal("File {$deployConfig} not found !")
        throw
    }

    # Validate local Db Mode
    If (($LocalDBInContainer.ToUpper() -ne "NONE") -and  ($LocalDBInContainer.ToUpper() -ne "BACKUP") -and ($LocalDBInContainer.ToUpper() -ne "ATTACH"))
    {
        [Logger]::Fatal("Parameter {LocalDBInContainer} must be {None}, {Backup} or {Attach}")
        throw
    }

    # Validate deployment configuration file with option dockerMode
    & $PSScriptRoot\Scripts\check-deployConfig-file.ps1 -deployConfig "$deployConfig" -DockerMode -verbose:$verbose

    $coreVersion = & $PSScriptRoot\Scripts\get-y2Version.ps1 -deployConfig "$deployConfig" -verbose:$verbose
    $downloadKitsFolder = "$PSScriptRoot\Kits\{0}.{1}" -f "$($coreVersion.Major)", "$($coreVersion.Minor)"
    $dockerDataFolder = "$PSScriptRoot\Docker\Data"

    # When in local host make o copy of cy2pxfile
    # in Pipeline the file is already in the working folder
    if ($Env:TF_BUILD -ne $TRUE)
    {
        # Create a copy of the deployment file in deloyment folder
        $dockerCy2px = "$dockerDataFolder\dockerdeploy.cy2px"
        [Logger]::Info("Copy {$deployconfig} into {$dockerCy2px}")
        Copy-Item "$deployconfig" "$dockerCy2px"
    }
    else
    {
        $dockerCy2px = $deployconfig
    }

    # dockerize deployment file
    DockerizeDeployConfigFile -dockerCy2px "$dockerCy2px" -LocalDBMode $LocalDBInContainer -dockerDataFolder "$dockerDataFolder"

    & $PSScriptRoot\Scripts\download-packages.ps1 -deployConfig "$dockerCy2px" -downloadedPackagesFolder $downloadKitsFolder -verbose:$verbose

    # $dockerargs = "run --rm -it -p 5000:80 -v $PSScriptRootWithSlash/Docker/Data:c:/data -v $($PSScriptRootWithSlash):c:/Deploy leobase powershell `"c:/data/init-container.ps1 -coreVersion $coreVersion -dbname $deployDb $verbosity $doTesting`""
    & $PSScriptRoot\Scripts\init-container.ps1 -coreVersion $coreVersion -dockerCy2px "$dockerCy2px" -verbose:$verbose -doTests:$withTests -localDBMode $localDBInContainer
}
catch {
    [Logger]::Error($_)
    [Logger]::Error($PSItem)
    Write-Host

    [Logger]::Error("Fail !")
    Exit 1
}
