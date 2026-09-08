
# File: check-prerequisites.ps1
# Check prerequisite
#
# 2022-02-02 : file creation

#Requires -Version 7.4

param(
    [int]     $DotnetMajorVersion = 0,    # 0 = auto-detect from installed runtimes
    [Version] $PwshMinVersion     = "7.4"
)

# Auto-detect DotnetMajorVersion when not explicitly provided
if ($DotnetMajorVersion -eq 0) {
    $detected = (& dotnet --list-runtimes 2>$null) |
        Where-Object { $_ -match "Microsoft\.NETCore\.App (\d+)\.\d+\.\d+" } |
        ForEach-Object { [int]$Matches[1] } |
        Sort-Object -Descending |
        Select-Object -First 1
    $DotnetMajorVersion = if ($detected) { [int]$detected } else { 8 }
}

function WriteResult([string] $message, [Boolean] $result)
{
    # Préfixe [error] pour coloriser la ligne en rouge dans les logs Azure DevOps
    $prefix = if (($Env:TF_BUILD -eq $TRUE) -and ($result -eq $FALSE)) { "[error] " } else { "" }
    if ($result)
    {
        Write-Output "$prefix${message}$($PSStyle.Foreground.BrightGreen)Success$($PSStyle.Reset)"
    }
    else
    {
        Write-Output "$prefix${message}$($PSStyle.Foreground.BrightRed)Error$($PSStyle.Reset)"
    }
}

$nberr = 0
Write-Output ""
Write-Output "Checking the prerequisites according to the desired y2 components"
Write-Output ""
# Check Net Fwk 4.8
# Value of property Release in HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\
# must be greater than 528040 ( cf https://docs.microsoft.com/fr-fr/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#minimum-version )
$result = $FALSE
$message = "Net Fwk 4.8 Runtime ( needed for Y2 server and smartClients ) - "
try
{
    $value = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name "Release" -ErrorAction 'SilentlyContinue'
    $result = ([Boolean]( [Long] $value.release -gt 528040))
    if ([Long] $value.release -gt 528040)
    {
        $result = $TRUE
    }
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)Available here : https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48$($PSStyle.Reset)"
        ++$nberr
    }
}

# Net runtime
# Exécute la commande pour lister les runtimes .NET installés
$result = $FALSE
$message = "Net $DotnetMajorVersion Runtime ( needed for installation process ) - "
try {
    $runtimes = & dotnet --list-runtimes
    if ($runtimes -match "Microsoft\.NETCore\.App $DotnetMajorVersion\.\d+\.\d+")
    {
        $result = $TRUE
    }
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)Available here : https://dotnet.microsoft.com/en-us/download/dotnet/$DotnetMajorVersion.0$($PSStyle.Reset)"
        ++$nberr
    }
}

# Powershell Core
$result = $FALSE
$message = "Powershell Core >= $PwshMinVersion ( needed for installation process ) - "
try
{
    $test = Get-Command -Name pwsh -ErrorAction SilentlyContinue
    if ($NULL -ne $test)
    {
        if ($test.Version -ge $PwshMinVersion)
        {
            $result = $TRUE
        }
    }
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)Available here : https://github.com/PowerShell/PowerShell/releases$($PSStyle.Reset)"
        ++$nberr
    }
}

# IIS
$result = $FALSE
$message = "IIS Version 10 ( needed for Y2 server, AuthenticationServer and WebApps ) - "
try
{
    $value = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\InetStp\" -Name "MajorVersion" -ErrorAction 'SilentlyContinue'
    if ([int]$value.MajorVersion -ge 10)
    {
        $result = $TRUE
    }
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)On Windows Server  : Launch .\Scripts\System\Install-IIS.ps1 in a powershell console with Administrator privileges$($PSStyle.Reset)"
        Write-Output "$($PSStyle.Foreground.BrightBlack)On Windows Desktop : Launch .\Scripts\System\install-iis-desktop.cmd in a terminal console with Administrator privileges$($PSStyle.Reset)"
        ++$nberr
    }
}

# MSMQ
$result = $FALSE
$message = "MSMQ ( needed for Y2 server, workerprocess and Report service ) - "
try
{
    $value = Get-MsmqQueue -ErrorAction 'SilentlyContinue' > $NULL
    $result = $TRUE
}
catch {
    # Need to catch if msmq not installed
    # Option -ErrorAction 'SilentlyContinue' in case of out of domain
    Write-Output "$($PSStyle.Foreground.BrightYellow)Error while trying to get MSMQ queues, this is expected when MSMQ is not installed. Continuing checking other prerequisites...$($PSStyle.Reset)"
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)On Windows Server  : Launch .\Scripts\System\Install-MSMQ.ps1 in a powershell console with Administrator privileges$($PSStyle.Reset)"
        Write-Output "$($PSStyle.Foreground.BrightBlack)On Windows Desktop : Launch .\Scripts\System\Install-MSMQ-desktop.cmd in a terminal console with Administrator privileges$($PSStyle.Reset)"
        ++$nberr
    }
}

# Check printer Cegid only if not running in a container
$result = $FALSE
$message = "Cegid Report Service Printer ( needed for Report service ) - "
if ($env:UserName -ne "ContainerAdministrator" )
{
    try
    {
        $prn = Get-Printer -Name "Cegid Report Service Printer" -ErrorAction 'SilentlyContinue'
        if ($NULL -ne $prn)
        {
            $result = $TRUE
        }
    }
    finally
    {
        WriteResult -message $message -result $result
        if ($result -eq $FALSE)
        {
            Write-Output "$($PSStyle.Foreground.BrightBlack)Available here : https://cegid.jfrog.io/artifactory/retail-software-production/Cegid%20Report%20Service%20Printer/Cegid%20Report%20Service%20Printer%20(pcl6).zip$($PSStyle.Reset)"
            ++$nberr
        }
    }
}
else
{
    $result = $TRUE # If running in a container we don't need to check the printer
    Write-Output "${message}not applicable in a container"
}

# DotnetHosting
$result = $FALSE
$message = "DotNet Hosting Bundle $DotnetMajorVersion.* module for IIS ( needed for AuthenticationServer and WebApps ) - "
try
{
    $DotNETCoreUpdatesPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Updates\.NET"
    $DotNetCoreItems = Get-Item -ErrorAction Stop -Path $DotNETCoreUpdatesPath
    $DotNetCoreItems.GetSubKeyNames() | Where-Object { $_ -match "Microsoft .NET.*Windows Server Hosting" } | ForEach-Object {
        # Stop testing other keys if one is found
        if ( $FALSE -eq $result)
        {
            $value = Get-ItemProperty -Path "$DotNETCoreUpdatesPath\$_" -Name "PackageVersion" -ErrorAction 'SilentlyContinue'
            if ($value.PackageVersion.StartsWith("$DotnetMajorVersion."))
            {
                $result = $TRUE
            }
        }
    }
}
catch {
    # Need to catch if dotnet hosting not installed and continue checking
    # Option -ErrorAction 'SilentlyContinue' in case of out of domain
    Write-Output "$($PSStyle.Foreground.BrightYellow)Error while trying to get DotNet Hosting Bundle information, this is expected when it's not installed. Continuing checking other prerequisites...$($PSStyle.Reset)"
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)See link 'Hosting Bundle' under 'ASP.NET Core Runtime' at https://dotnet.microsoft.com/en-us/download/dotnet/$DotnetMajorVersion.0$($PSStyle.Reset)"
        ++$nberr
    }
}

# WebDeploy 3
$result = $FALSE
$message = "Web Deploy V3 ( needed for AuthenticationServer and WebApps ) - "
try
{
    $value = Get-ItemProperty -Path "HKLM:Software\Microsoft\IIS Extensions\MSDeploy\3\" -Name "InstallPath" -ErrorAction 'SilentlyContinue'
    if ($value.InstallPath -and ($value.InstallPath.length -gt 0 ))
    {
        $result = $TRUE
    }
}
finally
{
    WriteResult -message $message -result $result
    if ($result -eq $FALSE)
    {
        Write-Output "$($PSStyle.Foreground.BrightBlack)See https://www.microsoft.com/fr-fr/download/details.aspx?id=43717$($PSStyle.Reset)"
        ++$nberr
    }
}

# throw exception if any error and running in a pipeline or in a container
if ($nberr -gt 0)
{
    if (($Env:TF_BUILD -eq $TRUE) -or ($env:UserName -eq "ContainerAdministrator"))
    {
        throw "One or more prerequisites are missing !"
    }
}
Write-Output ""
