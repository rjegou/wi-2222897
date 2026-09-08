# File: config-webapps.ps1
# Module to manage authenticationserver configuration
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module "..\Modules\logger.psm1"
using module "..\Modules\DeployCfg.psm1"
using module "..\Modules\Utils.psm1"
using module "..\Modules\SiteIIS.psm1"

function SetWebAppTenants([string] $deployConfig, [Version] $coreVersion, [string] $configFolder)
{
    [Logger]::Verbose("Configuring Y2 client and tenants")
    # New-WebAppTenants -ConfigFileFolder "$configFolder"
    $thisHost = [DeployCfg]::GetY2HostBaseUri($deployConfig)
    $y2Uri = ("http://$thisHost/Retail_$($coreVersion.Major).$($coreVersion.Minor)").ToLower()
    # Remove all tenants for this y2 uri
    try {
        Remove-WebAppTenants -ConfigFileFolder "$configFolder" -Y2Url "$y2Uri" >$Null
    }
    catch {
        [Logger]::Warning($_)
    }
    
    $tenants = [DeployCfg]::TenantList($deployConfig)
    foreach ($db in $tenants)
    {
        [Logger]::Verbose("Adding tenant {$($db.Id)}")
        Add-WebAppTenants -ConfigFileFolder "$configFolder" -FolderId "$($db.Id)" -Y2Url "$y2Uri" >$Null
    }
}

function configureWebApps ([string] $deployConfig, [version]$coreVersion, [string] $authServerUri)
{
    [DeployCfg]::PackageList($deployConfig) | Foreach-Object {
        $packageName = $($_.Name.Trim())
        if ($packageName.ToUpper().StartsWith("Y2.WEBAPPS.") )
        {
            $waName = [Utils]::WebAppNameFromPackage( $packageName )
            $waClientId = [DeployCfg]::GetWebAppAuthServerClientID( $deployConfig, $packageName)
            #Net Core WebApps can be deployed under specific site to use https ( Y2 Core MUST be in http )
            $waFilePath = [Utils]::IIsWebAppFilePath( ([DeployCfg]::GetWebbAppsIisSite( $deployConfig )), "$waName" )
            $acceptLocalCert = ("https" -eq [DeployCfg]::GetWebbAppsProtocol($deployConfig) )
            [Logger]::Info("Configuring WebApp {$waName} in {$waFilePath} with authserver clientId {$waClientId}")
            [Logger]::Verbose("Adding authority {$authServerUri} and set acceptLocalCert to {$acceptLocalCert}")
            Set-WebAppOAuthConfig -ConfigFileFolder "$waFilePath" -AuthServerHostUri "$authServerUri" -WebApp "$waClientId" -AcceptLocalCert $acceptLocalCert >$Null
            SetWebAppTenants -deployConfig $deployConfig -coreVersion $coreVersion -configFolder $waFilePath
            [Logger]::Verbose("Set base Href to {$($waName.ToLower())}")
            Set-WebAppIndexBaseHref -ConfigFileFolder "$waFilePath\ClientApp\dist" -href "$($waName.ToLower())" >$Null
            # desactive windows Authentication in WA
            [Logger]::Verbose("Disable Windows authentication on {$waName}")
            $netCoreWASiteName = [DeployCfg]::GetWebbAppsIisSite( $deployConfig )
            Disable-Y2SiteWindowsAuthentication -Site "$netCoreWASiteName" -Y2App "$waName"
        }
    }
}