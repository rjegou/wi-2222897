# File: check-deployConfig-file.ps1
# Perform some deployConfig file validation
# Used by pipeline and for local deployment
#
# 2022-11-24 : file creation

#Requires -Version 7.6

using module "..\Scripts\Modules\deployCfg.psm1"
using module "..\Scripts\Modules\Roles.psm1"
using module "..\Scripts\Modules\DockerUtils.psm1"
using module "..\Scripts\Modules\logger.psm1"

param (
    [string]$deployConfig  = $(throw "deployConfig is a required parameter"),
    [switch]$dockerMode,
    [switch]$verbose
)

$global:verbose = $verbose # to be known by logger module

# include modules library ( $PSScriptRoot est le répertoire d'execution du script courant, donc celui qui charge la librairie )
. $PSScriptRoot\Lib\deploy-config-validation.ps1

# Use a dedicated function for all tests and add TUs on it
$IsValidFile = CheckHostsConfiguration -deployConfig "$deployConfig" -currentHost "$Env:ComputerName" -dockerMode $dockerMode
If ($TRUE -eq $IsValidFile)
{
    $IsValidFile = CheckCustomAppSettingsConfiguration -deployConfig "$deployConfig"
}

If ($FALSE -eq $IsValidFile)
{
    [Logger]::Fatal("The file {$deployConfig} contains error, process aborted")
    throw ("The file $deployConfig contains error, process aborted")
}