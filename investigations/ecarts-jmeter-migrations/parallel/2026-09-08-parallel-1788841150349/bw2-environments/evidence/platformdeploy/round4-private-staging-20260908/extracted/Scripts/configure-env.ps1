# File: configure-env.ps1
# Manage configuration
# Used by pipeline and for local deployment
#
# 2022-02-02 : template creation

#Requires -Version 7.6
#Requires -RunAsAdministrator

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\DeployCfg.psm1"
using module "..\Scripts\Modules\Roles.psm1"

param (
    [string]$toolsPath           = $(throw "Path to tools is a required parameter"),
    [string]$deployConfig        = $(throw "deployConfig is a required parameter"),
    [version]$coreVersion        = $(throw "coreVersion is a required parameter"),
    [switch]$verbose
)

# include modules library ( $PSScriptRoot est le répertoire d'execution du script courant, donc celui qui charge la librairie )
. $PSScriptRoot\Lib\config-core.ps1
. $PSScriptRoot\Lib\config-authserver.ps1
. $PSScriptRoot\Lib\config-webapps.ps1
# . $PSScriptRoot\Lib\utils.ps1
# --------------------------------------------------------------------------------

$global:verbose = $verbose # to be known by logger module
Write-Host
[Logger]::Verbose("Import module Cegid.Retail.Y2Platform.CmdLet from {$toolsPath\PlatformCmdlet}")
import-module $toolsPath\PlatformCmdlet\Cegid.Retail.Y2Platform.CmdLet.dll
if ([DeployCfg]::UseMongoDbTenants($deployConfig))
{
    [Logger]::Verbose("Import module Mdbc from {$toolsPath\Mdbc\Tools\Mdbc}")
    import-module $toolsPath\Mdbc\Tools\Mdbc\Mdbc.dll
}
[Logger]::Info("Configure environment")

$authServerUri =""
if ([DeployCfg]::UseManagedAuthenticationServer($deployConfig))
{
    $authServerHost = [DeployCfg]::GetAuthServerHostBaseUri($deployConfig)
    $waProtocol = [DeployCfg]::GetWebbAppsProtocol($deployConfig)
    $authServerUri = ("${waProtocol}://$authServerHost/AuthenticationServer").ToLower()
    if ([DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::AuthServer))
    {
        configureAuthenticationServer -deployConfig $deployConfig -coreVersion $coreVersion
    }
}
else
{
    # try to get AuthserHostName from option ( if empty we do not use authenticationServer )
    # in this cas do not set CegidPasseport AND DO not config installed WebApps
    $authServerUri=[DeployCfg]::SpecificAuthenticationServerUri( $deployConfig )
    # Configure CosmosTenant for Non managed authentication server, only when we configure hot with Y2
    if ([DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2))
    {
        if ($authServerUri.Length -gt 0 -and [DeployCfg]::UseMongoDbTenants($deployConfig))
        {
            [Logger]::Info("Configuring remote tenants for {Unmamaged AuthenticationServer} {$authServerUri}")
            $y2Host = [DeployCfg]::GetY2HostBaseUri($deployConfig)
            $y2Uri  = ("http://$y2Host/Retail_$($coreVersion.Major).$($coreVersion.Minor)").ToLower()
            configureAuthServerTenantsInMongoDB -y2Uri $y2Uri -deployConfig $deployConfig -coreVersion $coreVersion -configFolder ""
        }
    }
}

configureCore -deployConfig "$deployConfig" -coreVersion $coreVersion -authServerUri $authServerUri

# Configure installed WA
if ($authServerUri.Length -gt 0 -and [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::WebApps))
{
    configureWebApps -deployConfig $deployConfig -coreVersion $coreVersion -authServerUri $authServerUri
}

Write-Host
# Apply CustomAppSettings
if ( $TRUE -eq [DeployCfg]::HaveCustomAppSettings($deployConfig))
{
    [Logger]::Info("Apply Custom AppSettings")
    $customAppSettings = [DeployCfg]::GetCustomAppSettings($deployConfig)
    foreach ($setting in $customAppSettings.appSetting)
    {
        $baseDir = [RoleUtils]::BaseDirectory($setting.role, $coreVersion)
        $configFile = Join-Path "$baseDir" "$($setting.file)"
        $legacyMode = ($($setting.legacy).ToUpper()  -eq "TRUE" )
        $enabled    = ($($setting.enabled).ToUpper() -eq "TRUE" )
        if ($enabled)
        {
            [Logger]::Verbose("Set appSetting {$($setting.key)} = {$($setting.value)} in {$configFile} (legacyMode = {$legacyMode})" )
            if ($FALSE -eq $legacyMode)
            {
                Set-Y2AppSettings -ConfigFile "$configFile" -Key "$($setting.key)" -Value "$($setting.value)"
            }
            else
            {
                Set-Y2AppSettings -ConfigFile "$configFile" -Key "$($setting.key)" -Value "$($setting.value)" -LegacyMode
            }
        }
        else
        {
            [Logger]::Verbose("Remove appSetting {$($setting.key)} in {$configFile} (legacyMode = {$legacyMode})" )
            if ($FALSE -eq $legacyMode)
            {
                Remove-Y2AppSettings -ConfigFile "$configFile" -Key "$($setting.key)"
            }
            else
            {
                Remove-Y2AppSettings -ConfigFile "$configFile" -Key "$($setting.key)" -LegacyMode
            }
        }
    }
}
else
{
    [Logger]::Verbose("No Custom AppSettings used")
}
Write-Host