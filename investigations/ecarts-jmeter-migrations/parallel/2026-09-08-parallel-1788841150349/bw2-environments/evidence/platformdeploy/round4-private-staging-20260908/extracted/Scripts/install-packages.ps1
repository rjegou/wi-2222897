# File: install-packages.ps1
# Manage packages installation
# Used by pipeline and for local deployment
#
# 2022-02-02 : file creation

#Requires -Version 7.6
#Requires -RunAsAdministrator

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\DeployCfg.psm1"
using module "..\Scripts\Modules\DevUtils.psm1"
using module "..\Scripts\Modules\Roles.psm1"
using module "..\Scripts\Modules\Utils.psm1"

param (
    [string]$deployConfig             = $(throw "deployConfig is a required parameter"),
    [string]$downloadedPackagesFolder = $(throw "downloadedPackagesFoler is a required parameter"),
    [version]$coreVersion             = $(throw "coreVersion is a required parameter"),
    [string]$logsFolder               = $(throw "Logs folders is a required parameter"),
    [switch]$verbose
)

# include modules library ( $PSScriptRoot est le répertoire d'execution du script courant, donc celui qui charge la librairie )
. $PSScriptRoot\Lib\install-y2msi.ps1
. $PSScriptRoot\Lib\install-webapps.ps1
# . $PSScriptRoot\Lib\utils.ps1
# --------------------------------------------------------------------------------

$global:verbose = $verbose # to be known by logger module

# Check il deployment tools manage on a same host version x.0 and x.99
# true if kits folder for version x.99 exists when installing version x.0
#   or if kits folder for version x.0 exists when installing version x.99
$alternateMinorVersion = [DevUtils]::IIF( $($coreVersion.Minor) -eq 0, 99, 0)
# Get parent folder of $msiFolder
$kitsFolder = (get-item $downloadedPackagesFolder ).parent
$uninstallNonY2Kits = $FALSE
if ( Test-Path -Path ("$kitsFolder\{0}.{1}" -f "$($coreVersion.Major)", "$alternateMinorVersion"))
{
    $messge = "Installing Y2 core {$($coreVersion.Major).$($coreVersion.Minor)} beside version {$($coreVersion.Major).$alternateMinorVersion}"
    $messge = $messge + "`nKits for plugins will be automatically uninstalled before they are updated"
    $messge = $messge + "`nand processlauncher for version {$($coreVersion.Major).$alternateMinorVersion} will be stopped and StartupType set to manual"
    [Logger]::HighLight($messge )
    $uninstallNonY2Kits = $TRUE
    # Stop and disable automatic startup of same Y2 majour version used on this computer
    # because plugins are uninstalled so service could not start launcher will loop trying to start process
    $svc = get-service "CegidRetailProcessLauncher $($coreVersion.Major).$alternateMinorVersion Multi-tenant" -ErrorAction SilentlyContinue
    if ( ($null -ne $svc) )
    {
        [Logger]::Verbose("Stopping service {$($svc.Name)} and set Startup Type to {manual}")
        Stop-Service -Name $($svc.Name)
        Set-Service -Name $($svc.Name) -StartupType Manual
    }
    $svc = get-service "CegidRetailReportServiceLauncher $($coreVersion.Major).$alternateMinorVersion" -ErrorAction SilentlyContinue
    if ( ($null -ne $svc) )
    {
        [Logger]::Verbose("Stopping service {$($svc.Name)} and set Startup Type to {manual}")
        Stop-Service -Name $($svc.Name)
        Set-Service -Name $($svc.Name) -StartupType Manual
    }
}

# Delete logs folder if exists
[Logger]::Info("Initialize log folder {$logsFolder}")
if ((Test-Path -Path "$logsFolder"))
{
  remove-item -Path "$logsFolder" -Recurse
}
New-Item -Path "$logsFolder" -ItemType Directory > $NULL

$downloadedPackagesFolder = (Resolve-Path -Path $downloadedPackagesFolder )

$nbErr = 0;
[DeployCfg]::PackageList($deployConfig) | Foreach-Object {
  $packageFolder = $($_.Name.Trim())
  $containsExe = Get-ChildItem "$downloadedPackagesFolder\$packageFolder\Cegid.Retail.*.exe"
  if ($containsExe -eq $null)
  {
    [Logger]::Info("Installing MSI for {$packageFolder}")
    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2))
    {
        # Pour Core le kits E_IIS_SERVER_RETAIL.msi doit être passé en premier ...
        if ($packageFolder.ToUpper() -eq "Y2.CORE")
        {
          $nbErr=$nbErr + (installMsi -msiName "$downloadedPackagesFolder\$packageFolder\E_IIS_SERVER_RETAIL.MSI" -logsFolder "$logsFolder" -coreVersion "$coreVersion")
        }
        $nbErr=$nbErr + (installAllMSIs -msiFolder "$downloadedPackagesFolder\$packageFolder" -msiPrefixe "E_IIS" -logsFolder "$logsFolder" -coreVersion "$coreVersion" -uninstallNonY2Kits $uninstallNonY2Kits)
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Wp))
    {
        $nbErr=$nbErr + (installAllMSIs -msiFolder "$downloadedPackagesFolder\$packageFolder" -msiPrefixe "WORKER_PROCESS" -logsFolder "$logsFolder" -coreVersion "$coreVersion" -uninstallNonY2Kits $uninstallNonY2Kits)
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Report))
    {
        $nbErr=$nbErr + (installAllMSIs -msiFolder "$downloadedPackagesFolder\$packageFolder" -msiPrefixe "REPORT" -logsFolder "$logsFolder" -coreVersion "$coreVersion" -uninstallNonY2Kits $uninstallNonY2Kits)
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Task))
    {
        $nbErr=$nbErr + (installAllMSIs -msiFolder "$downloadedPackagesFolder\$packageFolder" -msiPrefixe "TASKSCHEDULER"  -logsFolder "$logsFolder" -coreVersion "$coreVersion" -uninstallNonY2Kits $uninstallNonY2Kits)
    }

    if ( [DeployCfg]::CdmUsed($deployConfig) -and [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Cptx) )
    {
      # install cptx
      if ($packageFolder.ToUpper() -eq "Y2.CORE")
      {
        # Cptx for Core ( nom non normalisé)
        $nbErr=$nbErr + (installMsi -msiName "$downloadedPackagesFolder\$packageFolder\CBRCPTX.MSI" -logsFolder "$logsFolder" -coreVersion "$coreVersion")
      }
      else {
        # Cptx for plugins
        $nbErr=$nbErr + (installAllMSIs -msiFolder "$downloadedPackagesFolder\$packageFolder" -msiPrefixe "CPTX"  -logsFolder "$logsFolder" -coreVersion "$coreVersion" -uninstallNonY2Kits $uninstallNonY2Kits)
      }
    }

    if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Saft))
    {
        $nbErr=$nbErr + (installAllMSIs -msiFolder "$downloadedPackagesFolder\$packageFolder" -msiPrefixe "SAFT!"  -logsFolder "$logsFolder" -coreVersion "$coreVersion" -uninstallNonY2Kits $uninstallNonY2Kits)
    }
  }
  else
  {
    [Logger]::Info("Deploying packages for {$packageFolder}")
    # Set WebApp name from package folder name
    if ($packageFolder.ToUpper() -eq "Y2.CORE.AUTHENTICATIONSERVER")
    {
      $waName="AuthenticationServer"
      if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::AuthServer))
      {
        installWebApps -waDownloadFolder "$downloadedPackagesFolder\$packageFolder" -waSiteName "$waName"
      }
    }
    else
    {
      if ($packageFolder.ToUpper().StartsWith("Y2.WEBAPPS.") )
      {
        $waName = [Utils]::WebAppNameFromPackage($packageFolder)
        if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::WebApps))
        {
          installWebApps -waDownloadFolder "$downloadedPackagesFolder\$packageFolder" -waSiteName "$waName"
        }
      }
      else
      {
        [Logger]::Fatal("Unknow how to deploy {$packageFolder} content")
        throw "Process aborted"
      }
    }
  }
}

# ── Force-rebuild binding redirects ──────────────────────────────────────────
# BindingRedirectGenerator runs as a MSI commit custom-action; it can fail on
# some machines (exit 1 → MSI 1603) without this being caught at the script level.
# Running it unconditionally here ensures binding redirects are always up to date.

function Invoke-BindingRedirectGenerator([string]$baseDir, [string]$inputDir, [string]$outputFile, [string]$label)
{
    $brg = Join-Path $baseDir "Setup\BindingRedirectGenerator.exe"
    if (-not (Test-Path $brg))       { [Logger]::Warning("BindingRedirectGenerator not found for {$label} at {$brg}");  return }
    if (-not (Test-Path $inputDir))  { [Logger]::Warning("BindingRedirectGenerator input dir absent for {$label}: {$inputDir}"); return }
    [Logger]::Info("Rebuilding binding redirects for {$label}")
    $ec = (Start-Process -FilePath $brg `
        -ArgumentList "/InputDirFilter:`"*.dll`" /InputDir:`"$inputDir`" /OutputFile:`"$outputFile`" /Override /Mode:2" `
        -Wait -PassThru).ExitCode
    if ($ec -eq 0) { [Logger]::Verbose("BindingRedirectGenerator {$label} - {Success}") }
    else           { [Logger]::Warning("BindingRedirectGenerator {$label} - exit code {$ec}") }
}

# Complements BRG: adds binding redirects for strongly-named assemblies found
# recursively under $binDir that BRG missed (e.g. DLLs in subdirectories).
function Add-MissingBindingRedirects([string]$binDir, [string]$configPath, [string]$label)
{
    if (-not (Test-Path $configPath)) { [Logger]::Warning("Config not found for {$label}: {$configPath}"); return }
    if (-not (Test-Path $binDir))     { [Logger]::Warning("Bin dir not found for {$label}: {$binDir}");    return }

    [System.Xml.XmlDocument]$doc = [System.Xml.XmlDocument]::new()
    $doc.Load($configPath)
    $nsmgr = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
    $nsmgr.AddNamespace("asm", "urn:schemas-microsoft-com:asm.v1")
    $asmBinding = $doc.SelectSingleNode("//asm:assemblyBinding", $nsmgr)
    if ($null -eq $asmBinding) { [Logger]::Warning("No assemblyBinding section in {$configPath}"); return }

    $ns      = "urn:schemas-microsoft-com:asm.v1"
    $changed = $false

    Get-ChildItem -Path $binDir -Recurse -Filter "*.dll" | ForEach-Object {
        $file = $_
        try {
            $asmName    = [System.Reflection.AssemblyName]::GetAssemblyName($file.FullName)
            $tokenBytes = $asmName.GetPublicKeyToken()
            if ($null -eq $tokenBytes -or $tokenBytes.Length -eq 0) { return }
            $token   = ($tokenBytes | ForEach-Object { $_.ToString("x2") }) -join ''
            $name    = $asmName.Name
            $version = $asmName.Version.ToString()
            $culture = if ([string]::IsNullOrEmpty($asmName.CultureName)) { "neutral" } else { $asmName.CultureName }

            $xpath = "//asm:assemblyBinding/asm:dependentAssembly/asm:assemblyIdentity[@name='$name' and @publicKeyToken='$token']"
            if ($null -ne $doc.SelectSingleNode($xpath, $nsmgr)) { return }

            [Logger]::Info("Adding missing binding redirect for {$name} {$version} ($label)")
            $depAsm = $doc.CreateElement("dependentAssembly", $ns)
            $id     = $doc.CreateElement("assemblyIdentity",  $ns)
            $id.SetAttribute("name", $name)
            $id.SetAttribute("publicKeyToken", $token)
            $id.SetAttribute("culture", $culture)
            $redir  = $doc.CreateElement("bindingRedirect", $ns)
            $redir.SetAttribute("oldVersion", "0.0.0.0-$version")
            $redir.SetAttribute("newVersion", $version)
            $depAsm.AppendChild($id)    | Out-Null
            $depAsm.AppendChild($redir) | Out-Null
            $asmBinding.AppendChild($depAsm) | Out-Null
            $changed = $true
        }
        catch { [Logger]::Warning("Cannot read assembly info for {$($file.Name)}: {$($_.Exception.Message)}") }
    }

    if ($changed) { $doc.Save($configPath); [Logger]::Info("Missing binding redirects saved for {$label}") }
}

if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Y2))
{
    $d = [RoleUtils]::BaseDirectory([RoleTypes]::Y2, $coreVersion)
    Invoke-BindingRedirectGenerator $d "$d\Bin\" "$d\Web.config" "Y2"
    Add-MissingBindingRedirects "$d\Bin\" "$d\Web.config" "Y2"
}
if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Wp))
{
    $d = [RoleUtils]::BaseDirectory([RoleTypes]::Wp, $coreVersion)
    Invoke-BindingRedirectGenerator $d "$d\" "$d\*.exe.config" "WorkerProcess"
}
if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Task))
{
    $d = [RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion)
    Invoke-BindingRedirectGenerator $d "$d\" "$d\*.exe.config" "TaskScheduler"
}
if ( [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Report))
{
    $d = [RoleUtils]::BaseDirectory([RoleTypes]::Report, $coreVersion)
    Invoke-BindingRedirectGenerator $d "$d\" "$d\*.exe.config" "Report"
}

if ($nbErr -gt 0)
{
  [Logger]::Fatal("One or more MSI installation failed")
  throw "Errors found during package installation - see output"
}
