# File: config-authserver.ps1
# Module to manage authenticationserver configuration
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module "..\Modules\logger.psm1"
using module "..\Modules\DeployCfg.psm1"
using module "..\Modules\Utils.psm1"
using module "..\Modules\SiteIIS.psm1"

function configureAuthServerTenantsInMongoDB([string] $y2Uri, [string] $deployConfig, [version]$coreVersion, [string] $configFolder)
{
    # Ref: https://github.com/nightroman/Mdbc
    # Tenants managed in a Cosmos DB for MongoDB
    # By default, The connect-mdbc command create varialbe $Client, $Collection and $database
    # but we can provide your own. We use this functionnality to avoid mistakes or undesired replacement
    # So we use vars : $mongoCli, $mongoCollection and $mongoDatabase
    $cfg = [DeployCfg]::GetMongoDbTenantsConfig($deployConfig)
    connect-mdbc -ClientVariable "mongoCli" -CollectionVariable "mongoCollection" -DatabaseVariable "mongoDatabase" `
                 -ConnectionString "$($cfg.connectionString)" -DatabaseName "$($cfg.database)" -CollectionName "$($cfg.collection)"

    # Create file tenants.json only if deployment use managed AuthenticationServer
    # CosmosTenants can also be used wen deployment use an unmanaged instance of authentication server
    if ([DeployCfg]::UseManagedAuthenticationServer($deployConfig))
    {
        New-AuthServerCosmosTenantsConfig -ConfigFileFolder $configFolder -ConnectionString "$($cfg.connectionString)" `
                                        -DatabaseName "$($cfg.database)" -Collection "$($cfg.collection)" -Environment "$($cfg.environment)"

        # Get tenants into cosmo to remove them from AuthServerPartnerDomain
        $tenantList=get-MdbcData -Collection $mongoCollection -Filter @{y2url="$y2uri"}
        foreach($item in $tenantList)
        {
            try {
                Remove-AuthServerPartnerDomain -ConfigFileFolder "$configFolder" -PartnerDomain "$($item.folderid)"
            }
            catch {
                [Logger]::Warning($_)
            }
        }
    }

    # Remove all tenant using the current y2 uri in cosmoDb
    Remove-MdbcData -Collection $mongoCollection -Filter @{y2url="$y2uri"} -Many
    $tenants = [DeployCfg]::TenantList($deployConfig)
    foreach ($db in $tenants)
    {
        $tenant = [RemoteTenant]::new()

        $tenant.id                     = (new-Guid) # This is a technical internal id that should be unique
        $tenant.sic                    = "$($db.Sic)"
        $tenant.offer                  = "$($cfg.offer)"
        $tenant.environment            = "$($cfg.environment)"
        $tenant.folderid               = "$($db.Id)"
        $tenant.y2url                  = "$y2Uri"
        $tenant.gdprurl                = ""
        $tenant.y2version              = "$($coreVersion.Major).$($coreVersion.Minor)"
        $tenant.y2region               = "$($cfg.region)"
        $tenant.y2federationdomainhint = ""

        [Logger]::Verbose("Adding Tenants {$($tenant.folderid)} in MongoDB")
        $tenant | Add-MdbcData -Collection $mongoCollection
        # Manage partner domin only if deployment use managed AuthenticationServer
        # CosmosTeant can also be used wen deployment use an unmanaged instance of authentication server
        if ([DeployCfg]::UseManagedAuthenticationServer($deployConfig))
        {
            [Logger]::Verbose("Adding Partner Domain {$($db.Id)}")
            Add-AuthServerPartnerDomain -ConfigFileFolder "$configFolder" -PartnerDomain "$($db.Id)"
        }
    }
}

function configureRetailClient([string] $y2Uri, [string] $deployConfig, [version]$coreVersion, [string] $configFolder)
{
    [Logger]::Verbose("Configuring Y2 client and tenants")
    # New-AuthServerRetailClient -ConfigFileFolder "$configFolder"
    [Logger]::Verbose("Adding SmartCLient {$y2Uri}")
    Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -ClientUri "$y2Uri" -Type "SmartClient"
    $thisHost = [DeployCfg]::GetY2HostBaseUri($deployConfig)
    # Manage localhost and ip for self client if computer have role AUthServer and Y2
    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::AuthServer) -and
         [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2))
    {
        # Y2 always use http protocol
        $localhostUri = $y2Uri.Replace(("http://$thishost/").ToLower(), "http://localhost/")
        [Logger]::Verbose("Adding SmartClient {$localhostUri}")
        Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -ClientUri "$localhostUri" -Type "SmartClient"
    }
    # Manage host with IP ( if only one ip available )
    # For vm only because computer have more than one network interface ( each having a specific IP)
    $ip = Resolve-DNSName $thisHost -Type A
    if (($NULL -ne $ip ) -and ($ip.Length -eq 1 ))
    {
        $ipUri = $y2Uri.Replace(("http://$thishost/").ToLower(), "http://$($ip.IPAddress)/").ToLower()
        [Logger]::Verbose("Adding SmartClient {$ipUri}")
        Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -ClientUri "$ipUri" -Type "SmartClient"
    }

    # Initialize all tenants info ( do not car about if we used comso or not )
    # Remove all domains and partners domain for this y2 uri
    # Always remove config into user respository to manage upgrading environement to cosmos
    try {
        Remove-AuthServerPartnerDomain -ConfigFileFolder "$configFolder" -AuthorityUri "$y2Uri" >$Null
    }
    catch {
        [Logger]::Warning($_)
    }
    try {
        Remove-AuthServerAuthorityDomains -ConfigFileFolder "$configFolder" -AuthorityUri "$y2Uri" >$Null
    }
    catch {
        [Logger]::Warning($_)
    }
    # Remove tenants.json file used by cosmo
    try {
        Remove-AuthServerCosmosTenantsConfig -ConfigFileFolder "$configFolder"
    }
    catch {
        [Logger]::Warning($_)
    }
    if ([DeployCfg]::UseMongoDbTenants($deployConfig))
    {
        configureAuthServerTenantsInMongoDB -y2Uri $y2Uri -deployConfig $deployConfig -coreVersion $coreVersion -configFolder $configFolder
    }
    else
    {
        $tenants = [DeployCfg]::TenantList($deployConfig)
        foreach ($db in $tenants)
        {
            [Logger]::Verbose("Adding Tenants {$($db.Id)}")
            Add-AuthServerAuthorityDomains -ConfigFileFolder "$configFolder" -AuthorityUri "$y2Uri" -Domain "$($db.Id)"
            [Logger]::Verbose("Adding Partner Domain {$($db.Id)}")
            Add-AuthServerPartnerDomain -ConfigFileFolder "$configFolder" -PartnerDomain "$($db.Id)"
        }
    }
}

function ConfigureAspnetClient([string] $deployConfig, [string] $configFolder)
{
    [Logger]::Verbose("Configuring {aspnet} client(s)")
    [DeployCfg]::PackageList($deployConfig) | Foreach-Object {
        $packageName = $($_.Name.Trim())
        if ($packageName.ToUpper().StartsWith("Y2.WEBAPPS.") )
        {
            $waName = [Utils]::WebAppNameFromPackage($packageName)
            $waClientId = [DeployCfg]::GetWebAppAuthServerClientID( $deployConfig, $packageName)
            $thisHost = [DeployCfg]::GetWebAppsHostBaseUri($deployConfig)
            $waProtocol = [DeployCfg]::GetWebbAppsProtocol($deployConfig)
            $waUri = ("${waProtocol}://$thisHost/$waName").ToLower()
            [Logger]::Verbose("Adding AspNetClient {$waUri} with clientId {$waClientId}")
            Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -ClientUri "$waUri" -Type "AspNetClient" -WebApp "$waClientId">$NULL
            # Manage localhost and ip for webapps client if computer have role AUthServer and WebApps
            if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::AuthServer) -and
                 [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::WebApps))
            {
                $localhostUri = ("${waProtocol}://localhost/$waName").ToLower()
                [Logger]::Verbose("Adding AspNetClient {$localhostUri} with clientId {$waClientId}")
                Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -ClientUri "$localhostUri" -Type "AspNetClient" -WebApp "$waClientId">$NULL
            }
            # Manage host with IP ( if only one ip available )
            # For vm only because computer have more than one network interface ( each having a specific IP)
            $ip = Resolve-DNSName $thisHost -Type A
            if (($NULL -ne $ip ) -and ($ip.Length -eq 1 ))
            {
                $ipUri = ("${waProtocol}://$($ip.IPAddress)/$waName").ToLower()
                [Logger]::Verbose("Adding AspNetClient {$ipUri} with clientId {$waClientId}")
                Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -ClientUri "$ipUri" -Type "AspNetClient" -WebApp "$waClientId">$NULL
            }
        }
    }
}

# Manage authserver configuration depending on used protocol
function ConfigurationDependingOnProtocol([string] $deployConfig, [string]$configFolder)
{
    # Add RetailAdminClient and enable self signed certificates only if protocol is https
    if ("https" -eq [DeployCfg]::GetWebbAppsProtocol($deployConfig) )
    {
        [Logger]::Verbose("Enable RetailAdminClient when authserver under {https}")
        Add-AuthServerRetailClient -ConfigFileFolder "$configFolder" -Type "RetailAdminClient" >$NULL
        [Logger]::Verbose("Enable locally self-signed certificates when authserver under {https}")
        Enable-AuthServerAcceptLocalCertificate -ConfigFileFolder "$configFolder"
    }
    else {
        [Logger]::Verbose("Remove RetailAdminClient when authserver under {http}")
        try {
            Remove-AuthServerRetailClient -ConfigFileFolder "$configFolder" -Type "RetailAdminClient" >$NULL
        }
        catch {
            [Logger]::Warning($_)
        }
        [Logger]::Verbose("Disable locally self-signed certificates when authserver under {http}")
        Disable-AuthServerAcceptLocalCertificate -ConfigFileFolder "$configFolder"
    }
}

function configureLoginUI([string] $deployConfig, [string] $configFolder)
{
    $federatedLogin = [DeployCfg]::FederatedLoginUI($deployConfig)
    [Logger]::Verbose("Use Federated login UI set to {$federatedLogin}")
    if ($federatedLogin)
    {
        Add-AuthServerCegidPassportRepository -ConfigFileFolder "$configFolder" >$Null
    }
    else {
        Remove-AuthServerCegidPassportRepository -ConfigFileFolder "$configFolder" >$Null
    }
}

function configureAuthenticationServer ([string] $deployConfig, [version]$coreVersion)
{
    $thisHost = [DeployCfg]::GetY2HostBaseUri($deployConfig)
    $y2Uri = ("http://$thisHost/Retail_$($coreVersion.Major).$($coreVersion.Minor)").ToLower()
    $netCoreWASiteName = [DeployCfg]::GetWebbAppsIisSite( $deployConfig )
    $authServerFilePath = [Utils]::IIsWebAppFilePath( $netCoreWASiteName, "AuthenticationServer")
    [Logger]::Info("Configuring {AuthenticationServer} in {$authServerFilePath}")
    configureRetailClient -y2Uri $y2Uri -deployConfig $deployConfig -coreVersion $coreVersion -configFolder "$authServerFilePath" >$Null
    ConfigureAspnetClient -deployConfig $deployConfig -configFolder $authServerFilePath >$Null
    ConfigurationDependingOnProtocol -deployConfig $deployConfig -configFolder $authServerFilePath
    configureLoginUI -deployConfig $deployConfig -configFolder $authServerFilePath
    [Logger]::Verbose("Enable Duende license")
    $duendeKey = [DeployCfg]::GetDuendeLicenceKey($deployConfig)
    Set-AuthServerDuendeLicense -ConfigFileFolder "$authServerFilePath" -key "$duendeKey"
    [Logger]::Verbose("Disable Windows authentication on {$waName}")
    Disable-Y2SiteWindowsAuthentication -Site "$netCoreWASiteName" -Y2App "AuthenticationServer"
}