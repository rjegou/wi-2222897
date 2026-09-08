# File: download-packages.ps1
# Manage packages installation
# Used by pipeline and for local deployment
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\DevUtils.psm1"
using module "..\Scripts\Modules\Utils.psm1"
using module "..\Scripts\Modules\DeployCfg.psm1"
using module "..\Scripts\Modules\Roles.psm1"

param (
    [string]$deployConfig             = $(throw "deployConfig is a required parameter"),
    [string]$downloadedPackagesFolder = $(throw "downloadedPackagesFoler is a required parameter"),
    [switch]$verbose
)

# include modules library ( $PSScriptRoot est le répertoire d'execution du script courant, donc celui qui charge la librairie )
# . $PSScriptRoot\Lib\utils.ps1
# --------------------------------------------------------------------------------

$retailJFrogCli="$PSScriptRoot\..\Tools\Cegid.Retail.JFrogCli\Cegid.Retail.JFrog.Cli.exe"

$params = "download", "packagelist", "$deployConfig", "-f", "$downloadedPackagesFolder", "-di", "$downloadedPackagesFolder/downloadedPackages.json"
if ($verbose)
{
    $params += "-v"
}
if ($Env:TF_BUILD -eq $TRUE) {
    $params += "--azologs"
}
& $retailJFrogCli @params
# jfrog cli reste en exitCode 0 même si in kit est en erreur !!!!!!!!!!!!!!!!!!!!
# pas normal......................
if( ! $? )
{
    [Logger]::Fatal("The download of one or more packages has failed")
    throw "Process aborted"
}
# Check if CDM must be installed
if ( [DeployCfg]::CdmUsed($deployConfig) -and [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Cptx))
{
    $installCDM = $TRUE
    [Logger]::Verbose("Get CDM wanted version")
    $cdmWanted = [DeployCfg]::GetCDMSelectedVersion("$deployConfig")
    $cdmPackageFolder = "$downloadedPackagesFolder\\CDM"
    $cdmLocal = [Utils]::CdmLocalPackageVersion($cdmPackageFolder)
    # Ignore $cdmLocal revision because not used into cdmWanted ( semantic versionning)
    if ($NULL -ne $cdmLocal )
    {
        if ( ($cdmLocal.Major -eq $cdmWanted.Major ) -and
             ($cdmLocal.Minor -eq $cdmWanted.Minor ) -and
             ($cdmLocal.Build -eq $cdmWanted.Build ) )
        {
            [Logger]::Verbose( "CDM Version {$($cdmWanted.Major).$($cdmWanted.Minor).$($cdmWanted.Build)} already downloaded" )
            Write-Host
            $installCDM = $FALSE
        }
    }
    if ($TRUE -eq $installCDM)
    {
        $cdmRepo = [DeployCfg]::GetCdmJfrogRepositoryPath($deployConfig)
        $params = "download", "artifacts", "$cdmRepo", "$cdmPackageFolder", "cdm.*", "--failNoOp"
        if ($verbose)
        {
            $params += "-v"
        }
        if ($Env:TF_BUILD -eq $TRUE) {
            $params += "--azologs"
        }
        & $retailJFrogCli @params
        if( ! $? )
        {
            [Logger]::Fatal("The download of one or more packages has failed")
            throw "Process aborted"
        }
    }
}
