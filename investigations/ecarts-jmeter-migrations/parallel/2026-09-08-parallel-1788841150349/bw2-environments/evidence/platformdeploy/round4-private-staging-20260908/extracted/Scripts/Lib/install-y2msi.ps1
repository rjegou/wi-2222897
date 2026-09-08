# File: install-y2msi.ps1
# Module to manage MSI deployment
#
# 2022-02-02 : file creation

#Requires -Version 7.6

using module "..\Modules\logger.psm1"
using module "..\Modules\Roles.psm1"

# Install all msi present in a specified folder
# Use a prefix to filter msi to install ( Example : "E_IIS" will install files matching "E_IIS*.MSI" )
# retrun number of msi in errors
function installAllMSIs( [string]$msifolder, [string]$msiPrefixe,  [string]$logsFolder, [version] $coreVersion, [bool] $uninstallNonY2Kits = $FALSE )
{
  $nbErr=0
  Get-ChildItem -Path "$msiFolder\$msiPrefixe*.MSI" |
    ForEach-Object {
        if ($uninstallNonY2Kits -and ( $packageFolder.ToUpper() -ne "Y2.CORE"))
        {
          # uninstall kits before installing nw one ( only non Y2 core kits to manage plugins for version x.99)
          $nbErr = $nbErr + (uninstallMsi -msiName "$($_.FullName)" -logsFolder "$logsFolder" -coreVersion "$coreVersion")
        }
        # ignore E_IIS_SERVER_RETAIL.MSI already installed
        if ( $_.Name.ToUpper() -ne "E_IIS_SERVER_RETAIL.MSI" )
        {
          # Write-Host " - $($_.FullName)"
          $nbErr = $nbErr + (installMsi -msiName "$($_.FullName)" -logsFolder "$logsFolder" -coreVersion "$coreVersion")
        }
    }
  return $nbErr
}

function ForceDestinationFolder( [string] $msiFilename, [version] $coreVersion )
{
    if ( $msiFilename.StartsWith("E_IIS_SERVER_RETAIL" ))
    {
      return [RoleUtils]::BaseDirectory([RoleTypes]::Y2, $coreVersion)
    }
    elseif ( $msiFilename.StartsWith("WORKER_PROCESS_RETAIL" ))
    {
        return [RoleUtils]::BaseDirectory([RoleTypes]::Wp, $coreVersion)
    }
    elseif ( $msiFilename.StartsWith("TASKSCHEDULER_RETAIL" ))
    {
        if (( $msiFilename.ToUpper() -eq "TASKSCHEDULER_RETAIL_COMMON.MSI") -or
            ( $msiFilename.ToUpper() -eq "TASKSCHEDULER_RETAIL_TASKSCHEDULER.MSI" ))
        {
          # Plugin common and plugin taskscheduler must be forced at root of taskscheduler
          return [RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion)
        }
        else
        {
          # Other plugins must be forced into Retail subfolder
          return "$([RoleUtils]::BaseDirectory([RoleTypes]::Task, $coreVersion))\Retail"
        }
    }
    elseif ( $msiFilename.StartsWith("REPORT_RETAIL" ))
    {
      return [RoleUtils]::BaseDirectory([RoleTypes]::Report, $coreVersion)
    }
}

# return 0 if ok, 1 otherwise
function installMsi( [string]$msiName, [string]$logsFolder, [version] $coreVersion)
{
  $msiExecArgs = "/i `"$msiName`" "
  # Manage destination folder for plugins if coreVersion is V xx.99
  $forceDestLog = ""
  if ($coreVersion.Minor -eq 99)
  {
    # Get MSI folder to see if it is a plugin or not
    $msiFolder= Split-Path -Path "$msiName"
    # need to force if msi folder isn't Y2.Core
    if (!($msiFolder.ToUpper().EndsWith("\Y2.CORE") ))
    {
      $dest = ForceDestinationFolder -msiFile (Split-Path $msiName -leaf ) -coreVersion $coreVersion
      $msiExecArgs = $msiExecArgs + "FORCEINSTALL=TRUE INSTALLDIR=`"$dest`" "
      $forceDestLog = "- with FORCEINSTALL in $dest "
    }
  }

  # Extract MSI name to make associated log file
  $msiLogFile = (join-path "$logsFolder" (Get-ChildItem -Path "$msiName").BaseName)
  $msiExecArgs = $msiExecArgs  + "/quiet /lv* `"$msiLogFile.log`" "
  $exitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "$msiExecArgs" -Wait -PassThru).ExitCode
  $msiFileName=(Get-ChildItem -Path "$msiName").Name
  # 0 = Success ; 3010 = A restart is required to complete the install.
  If (@(0,3010) -contains $exitCode)
  {
    [Logger]::Verbose("Install $msiFileName $forceDestLog- {Success}")
    return (0)
  }
  else
  {
    [Logger]::Error("Install $msiFileName - Fail exit code {$exitCode}")
    return (1)
  }
}

# return 0 if ok, 1 otherwise
function uninstallMsi( [string]$msiName, [string]$logsFolder, [version] $coreVersion)
{
  # Get package productCode
  $msiFolder = ((Get-ChildItem -Path "$msiName").FullName | Split-Path )
  $msiXml = (join-path "$msiFolder" (((Get-ChildItem -Path "$msiName").BaseName)+".xml"))
  $config = [xml](Get-Content "$msiXml")
  $productNode = $config.SelectSingleNode("//DOCUMENT/PRODUCT")
  $productCode = $productNode.Attributes["productcode"].Value
  $msiExecArgs = "/x $productCode "

  # Extract MSI name to make associated log file
  $msiLogFile = (join-path "$logsFolder" (Get-ChildItem -Path "$msiName").BaseName)
  $msiExecArgs = $msiExecArgs  + "/quiet /lv* `"$($msiLogFile)_uninstall.log`" "
  $exitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "$msiExecArgs" -Wait -PassThru).ExitCode
  $msiFileName=(Get-ChildItem -Path "$msiName").Name
  # 0 = Success ; 1605 = Product not found => not previously installed.
  If (@(0,1605) -contains $exitCode)
  {
    [Logger]::Verbose("Uninstall $msiFileName - ProductCode $productCode - {Success}")
    return (0)
  }
  else
  {
    [Logger]::Error("Uninstall $msiFileName - ProductCode $productCode - Fail exit code {$exitCode}")
    return (1)
  }
}