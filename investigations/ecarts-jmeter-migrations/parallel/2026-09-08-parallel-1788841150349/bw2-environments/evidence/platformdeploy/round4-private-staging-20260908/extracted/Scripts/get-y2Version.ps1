# File: get-y2Version.ps1
# Get Y2 version deployed from config
# Used by pipeline and for local deployment
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module ".\Modules\deployCfg.psm1"
using module ".\Modules\logger.psm1"
using module ".\Modules\DevUtils.psm1"

param (
    [string]$deployConfig             = $(throw "deployConfig is a required parameter"),
    [switch]$verbose
)

# In pipeline a powershell script can not use "using module" command because of there is some echo
# and statement can not appear before any other statements in a script.
# So we use a small script instead

$global:verbose = $verbose # to be known by logger module

$selectedVersion = $NULL
$y2CorePackage = [DeployCfg]::GetY2CorePackageInfo($deployConfig)
if ($NULL -ne $y2CorePackage)
{
    $selectedVersion = $y2CorePackage.SelectVersion
    if ($y2CorePackage.SelectVersion.ToLower().StartsWith("packaging:"))
    {
        Write-Host
        # Split the string and use -1 to get last element
        $y2DistribVersion = ($y2CorePackage.SelectVersion.Split(":")[-1]).Trim()
        [Logger]::Verbose("Search version of {Y2.Core} used by Packaging {$y2DistribVersion} in {$($y2CorePackage.RepoKind)}")
        $retailJFrogCli="$PSScriptRoot\..\Tools\Cegid.Retail.JFrogCli\Cegid.Retail.JFrog.Cli.exe"

        $folder = $env:TEMP
        try
        {
            # use jfrogCli to get y2distrib informations to extract y2.Core version paskage used
            $params = "y2distrib", "packages", "$y2DistribVersion", "-r", $y2CorePackage.RepoKind, "-f", $folder
            if ($verbose)
            {
                $params += "-v"
            }
            if ($Env:TF_BUILD -eq $TRUE) {
                $params += "--azologs"
            }
            & $retailJFrogCli @params > $NULL
            if( ! $? )
            {
                [Logger]::Fatal("Fail to get {Y2.Core} version used by packaging {$y2DistribVersion} in {$($y2CorePackage.RepoKind)}")
                throw "Process aborted"
            }
            $json = Get-Content -Path "$folder\artifactsToDownload.json" -Raw | ConvertFrom-Json
            $selectedVersion = ($($json.artifacts) | Where-Object {$_.name.ToLower() -eq "y2.core"}).version
            [Logger]::Info("Packaging {$y2DistribVersion} in {$($y2CorePackage.RepoKind)} use {Y2.Core} version {$selectedVersion}")
        }
        finally {
            Remove-Item "$folder\artifactsToDownload.json"
        }
    }
}
$selectedVersion = $selectedVersion.Replace(".*", ".0")
return [version]$selectedVersion
