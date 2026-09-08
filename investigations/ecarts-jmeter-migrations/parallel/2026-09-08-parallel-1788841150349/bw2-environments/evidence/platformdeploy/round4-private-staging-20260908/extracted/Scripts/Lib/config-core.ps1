# File: config-core.ps1
# Module to manage Y2 core configuration
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module "..\Modules\logger.psm1"
using module "..\Modules\deployCfg.psm1"
using module "..\Modules\Roles.psm1"
using module "..\Modules\Utils.psm1"
using module "..\Modules\SiteIIS.psm1"

function CreateCegidFrameworkData([string] $deployConfig, [string] $folder)
{
    [Logger]::Verbose("Create {$folder\Cegid.Framework.Data.CegidConfig}")
    New-Y2Databases -ConfigFileFolder "$folder" > $null
    $tenants = [DeployCfg]::TenantList($deployConfig)
    foreach ($db in $tenants)
    {
        [Logger]::Verbose("Add database {$($db.Id)} from dbserver {$($db.Server)}")
        Add-Y2Databases -DatabaseServer        "$($db.Server)"       -DatabaseDriver "$($db.Driver)" `
                        -dbuser                "$($db.User)"         -DbPassword     "$($db.Pwd)" `
                        -DatabaseId            "$($db.Id)"           -DatabaseName   "$($db.Name)" `
                        -DataLanguageReference "$($db.DataLanguage)" -ConfigFileFolder "$folder" > $null
    }
}

function SetHealthPageFullAccess([string] $deployConfig, [version] $coreVersion)
{
    $opt      = [DeployCfg]::HealthPageFullAccess( $deployConfig )
    $waFolder = [Utils]::IIsWebAppFilePath("Cegid Retail Site", "Retail_$($coreVersion.Major).$($coreVersion.Minor)")
    [Logger]::Verbose("Set {HealthPageFullAccess} option to {$opt}")
    if ($opt)
    {
        Enable-Y2SiteHealthPageFullAccess -WebAppFolder "$waFolder"
    }
    else
    {
        Disable-Y2SiteHealthPageFullAccess -WebAppFolder "$waFolder"
    }
}

function SetIncludeExceptionDetailInFaults([string] $deployConfig, [version] $coreVersion)
{
    $opt      = [DeployCfg]::IncludeExceptionDetailInFaults( $deployConfig )
    $waFolder = [Utils]::IIsWebAppFilePath("Cegid Retail Site", "Retail_$($coreVersion.Major).$($coreVersion.Minor)")
    [Logger]::Verbose("Set {IncludeExceptionDetailInFaults} option to {$opt}")
    if ($opt)
    {
        Enable-Y2SiteIncludeExceptionDetailInFaults -WebAppFolder "$waFolder"
    }
    else
    {
        Disable-Y2SiteIncludeExceptionDetailInFaults -WebAppFolder "$waFolder"
    }
}

function SetIgnoreMissingOrInvalidSignature([string] $deployConfig, [version] $coreVersion)
{
    $opt      = [DeployCfg]::IgnoreMissingOrInvalidSignature( $deployConfig )
    $waFolder = [Utils]::IIsWebAppFilePath("Cegid Retail Site", "Retail_$($coreVersion.Major).$($coreVersion.Minor)")
    [Logger]::Verbose("Set {IgnoreMissingOrInvalidSignature} option to {$opt}")
    if ($opt)
    {
        Enable-Y2SiteIgnoreMissingOrInvalidSignature -WebAppFolder "$waFolder"
    }
    else
    {
        Disable-Y2SiteIgnoreMissingOrInvalidSignature -WebAppFolder "$waFolder"
    }
}

function SetUseCompressionWcf([string] $deployConfig, [version] $coreVersion)
{
    $opt      = [DeployCfg]::UseCompressionWcf( $deployConfig )
    $waFolder = [Utils]::IIsWebAppFilePath("Cegid Retail Site", "Retail_$($coreVersion.Major).$($coreVersion.Minor)")
    [Logger]::Verbose("Set {UseCompressionWcf} option to {$opt}")
    if ($opt)
    {
        Enable-Y2SiteWcfCompression -WebAppFolder "$waFolder"
    }
    else
    {
        Disable-Y2SiteWcfCompression -WebAppFolder "$waFolder"
    }
}

function SetUseIntegratedAuthentication([string] $deployConfig, [version] $coreVersion)
{
    $opt      = [DeployCfg]::UseIntegratedAuthentication( $deployConfig )
    $waFolder = [Utils]::IIsWebAppFilePath("Cegid Retail Site", "Retail_$($coreVersion.Major).$($coreVersion.Minor)")
    [Logger]::Verbose("Set {UseIntegratedAuthentication} option to {$opt}")
    if ($opt)
    {
        Enable-Y2SiteIntegratedAuthentication -WebAppFolder "$waFolder"
        # Windows Authentication is explicitly disabled when integrated auth is active:
        # the two modes are mutually exclusive in a Y2 deployment.
        Disable-Y2SiteWindowsAuthentication -Site "Cegid Retail Site" -Y2App "Retail_$($coreVersion.Major).$($coreVersion.Minor)"
    }
    else
    {
        Disable-Y2SiteIntegratedAuthentication -WebAppFolder "$waFolder"
        # Windows Authentication is intentionally NOT re-enabled here: its state is managed
        # independently by the deployment configuration and must not be assumed from this toggle.
    }
}

function SetStrictPgiSqlEnabled([string] $deployConfig, [version] $coreVersion)
{
    $opt = [DeployCfg]::StrictPgiSqlEnabled( $deployConfig )
    $waFilePath = [Utils]::IIsWebAppFilePath( "Cegid Retail Site", "Retail_$($coreVersion.Major).$($coreVersion.Minor)" )
    [Logger]::Verbose("Set {StrictPgiSqlEnabled} option to {$opt}")
    if ($opt)
    {
        Enable-Y2StrictPgiSql -ConfigFileFolder "$waFilePath\Config"
    }
    else
    {
        Disable-Y2StrictPgiSql -ConfigFileFolder "$waFilePath\Config"
    }
}

function ConfigureWorkerProcessQueues([version]$coreVersion)
{
    [Logger]::Verbose("Configure {WorkerProcess} Queues")
    $everyone = [Utils]::LocalizedEveryoneBuildInAccount()
    [Logger]::Verbose("Add full control for build in account {$everyone}")
    $queueName="workerprocess_cegid retail y2 {0}.{1}" -f "$($coreVersion.Major)", "$($coreVersion.Minor)"
    $queueExists = Get-Y2MsmqExists -QueueName ("{0}_request"-f $queueName)
    # Just to secure, WP queues are set on msi installation
    if ($queueExists -eq $false)
    {
        Add-Y2NewMsmq -QueueName ("{0}_request"-f $queueName) >$null
    }
    Set-Y2MsmqSetACL -QueueName ("{0}_request"-f $queueName) >$null
    $queueExists = Get-Y2MsmqExists -QueueName ("{0}_reply"-f $queueName)
    if ($queueExists -eq $false)
    {
        Add-Y2NewMsmq -QueueName ("{0}_reply"-f $queueName)
    }
    Set-Y2MsmqSetACL -QueueName ("{0}_reply"-f $queueName) >$null
}

function ConfigureReportServiceQueues([version]$coreVersion)
{
    [Logger]::Verbose("Configure {Reportservice} Queues")
    # Get host managing report queue, if not set as opton use current host
    $msmqHost = [DeployCfg]::MsmqPrintingHostManager($deployConfig)
    $queueName="cegid retail y2 {0}.{1}report" -f "$($coreVersion.Major)", "$($coreVersion.Minor)"
    #the msmq Host his host having role report
    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Report) )
    {
        $everyone = [Utils]::LocalizedEveryoneBuildInAccount()
        [Logger]::Verbose("Add full control for build in account {$everyone}")

        $queueExist = Get-Y2MsmqExists -QueueName  "$queueName"

        [Logger]::Verbose("Host managing reporting msmq is {$msmqHost}" )
        # Create queue only if host managing report queue is the current host
        if (($queueExist -eq $false) -and ( $msmqHost.ToUpper() -eq $Env:ComputerName.ToUpper()))
        {
            Add-Y2NewMsmq -QueueName "$queueName" >$null
        }
        Set-Y2MsmqSetACL -QueueName "$queueName" >$null
        $queueExists = Get-Y2MsmqExists -QueueName ("{0}response"-f $queueName)
        if (($queueExists -eq $false) -and ( $msmqHost.ToUpper() -eq $Env:ComputerName.ToUpper()))
        {
            Add-Y2NewMsmq -QueueName ("{0}response"-f $queueName) >$null
        }
        Set-Y2MsmqSetACL -QueueName ("{0}response"-f $queueName) >$null

        $configMsmq = "$([RoleUtils]::BaseDirectory([RoleTypes]::Report, $coreVersion))\Config"
        [Logger]::Verbose("Configure report service queue for report in {$configMsmq}" )
        Set-Y2ReportServiceMsmqConfig -ConfigFileFolder "$configMsmq" -MsmqHost "$msmqHost" -QueueType "Private" -QueueName "$queueName" >$null
    }
    # configure msmq report into IIS only if we have found a computer that  manage Report service
    # cf [DeployCfg]::MsmqPrintingHostManager($deployConfig)
    if ($msmqHost -ne "")
    {
        if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2) )
        {
            $configMsmq = [Utils]::IIsWebAppFilePath( "Cegid Retail Site", "$("Retail_{0}.{1}" -f "$($coreVersion.Major)", "$($coreversion.Minor)" )")
            [Logger]::Verbose("Configure report service queue for IIS in {$configMsmq}\Config" )
            Set-Y2ReportServiceMsmqConfig -ConfigFileFolder "$configMsmq\Config" -MsmqHost "$msmqHost" -QueueType "Private" -QueueName "$queueName" >$null
        }
    }
    else
    {
        [Logger]::Verbose("{Skip} Configure report service queue for IIS" )
    }
}

function configureWorkerProcessServiceLauncher([string] $deployConfig, [version]$coreVersion)
{
    $configFile = "C:\Program Files (x86)\Cegid\Cegid Retail\Cegid Retail Y2 $($coreVersion.Major).$($coreversion.Minor)\ProcessLauncher\Cegid.Retail.ProcessLauncher.exe.config"
    $maxSlot = [DeployCfg]::WorkerProcessMaxSlot($deployConfig);

    [Logger]::Verbose("Set MaxSlotCount=$maxslot into $configFile")
    # Set-Y2AppSettings -ConfigFile "$configFile" -Key "MaxSlotCount" -Value "$maxSlot"
    if ($maxSlot -eq 0)
    {
        Remove-Y2AppSettings -ConfigFile "$configFile" -Key "MaxSlotCount"
    }
    else
    {
        Set-Y2AppSettings -ConfigFile "$configFile" -Key "MaxSlotCount" -Value "$maxSlot"
    }
}

function configureReportServiceLauncher([string] $deployConfig, [version]$coreVersion)
{
    $configFile = "$([RoleUtils]::BaseDirectory([RoleTypes]::Report, $coreVersion))\Launcher\Cegid.Retail.ReportServiceLauncher.exe.config"
    $maxSlot = [DeployCfg]::ReportServiceMaxSlot($deployConfig);

    [Logger]::Verbose("Set MaxSlotCount=$maxslot into $configFile")
    if ($maxSlot -eq 0)
    {
        Remove-Y2AppSettings -ConfigFile "$configFile" -Key "MaxSlotCount"
    }
    else
    {
        Set-Y2AppSettings -ConfigFile "$configFile" -Key "MaxSlotCount" -Value "$maxSlot"
    }
}

# Manage specifique configuration into y2 components ( IIS and task for example)
# if $authserverUri is null or empty, remove relative configuration
function SetAuthserverConfigOnY2Role([string] $y2ConfigFolder, [string] $authServerUri)
{
    [Logger]::Verbose("Manage AuthServer configuration into folder {$y2ConfigFolder}")
    if ($authServerUri.Trim().Length -gt 0)
    {
        [Logger]::Verbose("Create {CegidPasseport} configuration")
        Set-Y2PasseportAuthServerUri -ConfigFileFolder "$y2ConfigFolder" -AuthServerUri "$authServerUri" >$Null
        # Add RetailAdminClient and enable self signed certificates only if protocol is https
        if ("https" -eq [DeployCfg]::GetWebbAppsProtocol($deployConfig) )
        {
            [Logger]::Verbose("Enable RetailAdminClient when authserver under {https}")
            Set-Y2AuthServerRetailAdminClient -ConfigFileFolder "$y2ConfigFolder"
            [Logger]::Verbose("Enable locally self-signed certificates when authserver under {https}")
            Enable-Y2AuthServerAcceptLocalCertificate -ConfigFileFolder "$y2ConfigFolder"
        }
        else {
            # With authserver under http didn't need cegid.retail.authserver.cegidconfig
            [Logger]::Verbose("Remove Y2 authserver configuration when authserver under {http}")
            Remove-Y2AuthServerConfig -ConfigFileFolder "$y2ConfigFolder"
        }
    }
    else
    {
        [Logger]::Verbose("Delete {CegidPasseport} configuration ( no authenticationServer used )")
        Remove-Y2PasseportConfig -ConfigFileFolder "$y2ConfigFolder"
        [Logger]::Verbose("Delete {Y2 authserver} configuration ( no authenticationServer used )")
        Remove-Y2AuthServerConfig -ConfigFileFolder "$y2ConfigFolder"
    }
}

function configureCore ([string] $deployConfig, [version]$coreVersion, [string] $authServerUri)
{
    [Logger]::Info("Configuring Y2 Core")
    $tempFolder=".\temp"
    [Logger]::Verbose("Initialize local temp folder {$tempFolder}")
    if ((Test-Path -Path "$tempFolder"))
    {
        remove-item -Path "$tempFolder" -Recurse
    }
    New-Item -Path "$tempFolder" -ItemType Directory >> $NULL
    # transforme relative path to absolute
    $tempFolder = (Resolve-Path -Path $tempFolder )

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2))
    {
        CreateCegidFrameworkData -deployConfig "$deployConfig" -folder ([Utils]::IIsWebAppFilePath( "Cegid Retail Site", "$("Retail_{0}.{1}" -f "$($coreVersion.Major)", "$($coreversion.Minor)" )")+"\Config")
        SetHealthPageFullAccess            -deployConfig "$deployConfig" -coreVersion $coreVersion
        SetIncludeExceptionDetailInFaults  -deployConfig "$deployConfig" -coreVersion $coreVersion
        SetIgnoreMissingOrInvalidSignature -deployConfig "$deployConfig" -coreVersion $coreVersion
        SetUseCompressionWcf               -deployConfig "$deployConfig" -coreVersion $coreVersion
        SetUseIntegratedAuthentication     -deployConfig "$deployConfig" -coreVersion $coreVersion
        SetStrictPgiSqlEnabled             -deployConfig "$deployConfig" -coreVersion $coreVersion
        ConfigureReportServiceQueues       -coreVersion $coreVersion
        # Manage configuration depending on Authserver usage
        $authServerConfigFolder = [Utils]::IIsWebAppFilePath( "Cegid Retail Site", "$("Retail_{0}.{1}" -f "$($coreVersion.Major)", "$($coreversion.Minor)" )")
        SetAuthserverConfigOnY2Role -y2ConfigFolder "$authServerConfigFolder\Config" -authServerUri "$authServerUri"
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Wp))
    {
        [Logger]::Info("Configuring WorkerProcess")
        CreateCegidFrameworkData -deployConfig "$deployConfig" -folder "$([RoleUtils]::BaseDirectory([RoleTypes]::Wp, $coreVersion))\Config"
        ConfigureWorkerProcessQueues -coreVersion $coreVersion
        configureWorkerProcessServiceLauncher -deployConfig "$deployConfig" -coreVersion $coreVersion
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Report))
    {
        [Logger]::Info("Configuring ReportService")
        CreateCegidFrameworkData -deployConfig "$deployConfig" -folder "$([RoleUtils]::BaseDirectory([RoleTypes]::Report, $coreVersion))\Config"
        ConfigureReportServiceQueues -coreVersion $coreVersion
        configureReportServiceLauncher -deployConfig "$deployConfig" -coreVersion $coreVersion
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Task))
    {
        [Logger]::Info("Configuring Task Scheduler")
        CreateCegidFrameworkData -deployConfig "$deployConfig" -folder "$([RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion))\Config"
        CreateCegidFrameworkData -deployConfig "$deployConfig" -folder "$([RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion))\Retail\Config"
        CreateCegidFrameworkData -deployConfig "$deployConfig" -folder "$([RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion))\Framework\Config"
        # Manage configuration depending on Authserver usage
        $authServerConfigFolder = "$([RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion))\Retail\Config"
        SetAuthserverConfigOnY2Role -y2ConfigFolder "$authServerConfigFolder" -authServerUri "$authServerUri"
    }
}