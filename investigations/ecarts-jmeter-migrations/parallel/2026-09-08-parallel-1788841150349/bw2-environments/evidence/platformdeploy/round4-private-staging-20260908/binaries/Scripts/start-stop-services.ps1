# File: start-stop-services.ps1
# Maange sart or stop y2 services
#
# 2022-02-02 : file creation

#Requires -Version 7.6
#Requires -RunAsAdministrator

using module ".\Modules\logger.psm1"
using module ".\Modules\Utils.psm1"
using module ".\Modules\DeployCfg.psm1"
using module ".\Modules\Roles.psm1"

param (
    [string]$deployConfig       = $(throw "deployConfig is a required parameter"),
    [string]$action             = $(throw "action is a required parameter"),
    [version]$coreVersion       = $(throw "coreVersion is a required parameter"),
    [switch]$verbose
)

# include modules library ( $PSScriptRoot est le répertoire d'execution du script courant, donc celui qui charge la librairie )
# . $PSScriptRoot\Lib\utils.ps1
# --------------------------------------------------------------------------------

$global:verbose = $verbose # to be known by logger module

function iis_Service([string] $action )
{
    if ([DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2) -or [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::AuthServer) -or [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::WebApps))
    {
        [Logger]::Info("$action {IIS}")
        try
        {
            [Utils]::LaunchProcess( "iisreset", "/$action" )
        }
        catch
        {
            # Some time the first attempt to stop IIS failed for unknow reason
            if ($action.ToUpper() -eq "STOP")
            {
                [Logger]::Info("Retry to stop {IIS}")
                [Utils]::LaunchProcessHideCmdLine( "iisreset", "/$action" )
            }
            else {
                throw
            }
        }
    }
}

function wp_Service([string] $action, [version] $coreversion )
{
    if ([DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Wp))
    {
        [Logger]::Info("$action {WorkerProcess}")
        $processLauncherPath = "C:\Program Files (x86)\Cegid\Cegid Retail\Cegid Retail Y2 {0}.{1}\ProcessLauncher" -f "$($coreVersion.Major)", "$($coreVersion.Minor)"
        $svc = get-service "CegidRetailProcessLauncher $($coreVersion.Major).$($coreVersion.Minor) Multi-tenant" -ErrorAction SilentlyContinue
        if ( ($null -eq $svc) -and ($action.ToUpper() -eq "START" ) )
        {
            if ($action.ToUpper() -eq "START" )
            {
                [Logger]::Verbose("Install ProcessLauncher service")
                [Utils]::LaunchProcess( "$processLauncherPath\Cegid.Retail.ProcessLauncherServiceCommand_MultiTenant.cmd", "install" )
                $svc = get-service "CegidRetailProcessLauncher $($coreVersion.Major).$($coreVersion.Minor) Multi-tenant" -ErrorAction SilentlyContinue
            }
        }
        if ($NULL -ne $svc)
        {
            [Utils]::LaunchProcess( "$processLauncherPath\Cegid.Retail.ProcessLauncherServiceCommand_MultiTenant.cmd", "$action" )
            Set-Service -Name $($svc.Name) -StartupType Automatic
        }
    }
}

function report_Service([string] $action, [version] $coreversion )
{
    if ([DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Report))
    {
        [Logger]::Info("$action {ReportService}")
        $reportLauncherPath = "$([RoleUtils]::BaseDirectory([RoleTypes]::Report, $coreVersion))\Launcher" -f "$($coreVersion.Major)", "$($coreVersion.Minor)"
        $svc = get-service "CegidRetailReportServiceLauncher $($coreVersion.Major).$($coreVersion.Minor)" -ErrorAction SilentlyContinue
        if ( ($NULL -eq $svc) -and ($action.ToUpper() -eq "START" ) )
        {
            if ($action.ToUpper() -eq "START" )
            {
                [Logger]::Verbose("Install Report service launcher")
                [Utils]::LaunchProcess( "$reportLauncherPath\Cegid.Retail.ReportServiceCommand.cmd", "install" )
                $svc = get-service "CegidRetailReportServiceLauncher $($coreVersion.Major).$($coreVersion.Minor)" -ErrorAction SilentlyContinue
            }
        }
        if ($NULL -ne $svc)
        {
            [Utils]::LaunchProcess( "$reportLauncherPath\Cegid.Retail.ReportServiceCommand.cmd",  "$action" )
            Set-Service -Name $($svc.Name) -StartupType Automatic
        }
    }
}

function task_service([string] $action, [version] $coreversion )
{
    if ([DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Task))
    {
        [Logger]::Info("$action {TaskScheduler}")
        $taskName = "Cegid Retail Y2 $($coreVersion.Major).$($coreVersion.Minor) (Task Scheduler)"
        [Logger]::Verbose("$action task {$taskName}")
        if ($action.ToUpper() -eq "STOP")
        {
            # Test if task exists only on stop ( for a first install of taskscheduler)
            if( $NULL -ne (Get-ScheduledTask -TaskPath "\Cegid\" -TaskName "$taskName" -ErrorAction SilentlyContinue) )
            {
                Stop-ScheduledTask -TaskPath "\Cegid\" -TaskName "$taskName"
            }
        }
        else
        {
            Start-ScheduledTask -TaskPath "\Cegid\" -TaskName "$taskName"
        }
    }
}

function StopAllServices([version] $coreversion)
{
    [Logger]::Verbose("Stopping Y2 services")
    iis_Service     -action "Stop"
    wp_Service      -action "Stop" -coreVersion $coreVersion
    report_Service  -action "Stop" -coreVersion $coreVersion
    task_Service    -action "Stop" -coreVersion $coreVersion
}

function StartAllServices([version] $coreversion)
{
    [Logger]::Verbose("Starting Y2services")
    iis_Service     -action "Start"
    wp_Service      -action "Start" -coreVersion $coreVersion
    report_Service  -action "Start" -coreVersion $coreVersion
    task_Service    -action "Start" -coreVersion $coreVersion
}

# --------------------------------------------------------------------------------

if ($action.ToUpper() -eq "STOP")
{
    StopAllServices -coreVersion "$coreVersion"
}
else
{
    StartAllServices -coreVersion "$coreVersion"
}