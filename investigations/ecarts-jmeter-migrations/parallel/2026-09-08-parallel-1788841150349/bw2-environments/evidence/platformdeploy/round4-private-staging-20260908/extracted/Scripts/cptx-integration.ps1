# File: cptx-integration.ps1
# Manage cptx integration
# Used by pipeline and for local deployment
#
# 2022-04-22 : template creation

#Requires -Version 7.6

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\DeployCfg.psm1"
using module "..\Scripts\Modules\Roles.psm1"
using module "..\Scripts\Modules\Utils.psm1"
using module "..\Scripts\Modules\CdmHelper.psm1"

param (
    [string]$toolsPath                = $(throw "Path to tools is a required parameter"),
    [string]$downloadedPackagesFolder = $(throw "downloadedPackagesFoler is a required parameter"),
    [string]$deployConfig             = $(throw "deployConfig is a required parameter"),
    [version]$coreVersion             = $(throw "coreVersion is a required parameter"),
    [string]$logsFolder               = $(throw "Logs folders is a required parameter"),
    [switch]$verbose
)

# A Cptx installed is never removed, so if we install a plugin cptx it will be always integrated
# even if plugin no more installed

$global:verbose = $verbose # to be known by logger module
Write-Host
if ($FALSE -eq [DeployCfg]::CurrentHostHaveRole($deployConfig, [RoleTypes]::Cptx))
{
    Write-Host
    exit 0
}

if ( $FALSE -eq [DeployCfg]::CdmUsed($deployConfig) )
{
    [Logger]::Verbose("Configuration options doesn't contain a CDM version to use, cptx integration ignored")
    Write-Host
    exit 0
}

[Logger]::Verbose("Import module Cegid.Retail.Y2Platform.CmdLet from {$toolsPath\PlatformCmdLet}")
import-module $toolsPath\PlatformCmdLet\Cegid.Retail.Y2Platform.CmdLet.dll
[Logger]::Info("Integrate all CPTX on databases")

$cdmWantedVersion = [DeployCfg]::GetCDMSelectedVersion($deployConfig)
$cdmInstallationFolder = [CdmHelper]::GetCdmInstallationFolder( $cdmWantedVersion )

# Install the right of version cdm if needed
if ( $FALSE -eq ( [CdmHelper]::CdmInstalled( $cdmInstallationFolder, $cdmWantedVersion)) )
{
    $msiName = "$downloadedPackagesFolder\CDM\Cdm.msi"
    [Logger]::Info("Install CDM")
    $msiExecArgs = "/i `"$msiName`" "
    $msiLogFile = (join-path "$logsFolder" (Get-ChildItem -Path "$msiName").BaseName)
    $msiExecArgs = $msiExecArgs  + "/quiet /lv* `"$msiLogFile.log`" "
    $exitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "$msiExecArgs" -Wait -PassThru).ExitCode
    # 0 = Success ; 3010 = A restart is required to complete the install.
    If (@(0,3010) -contains $exitCode)
    {
      [Logger]::Verbose("$msiName - {Success}")
    }
    else
    {
      [Logger]::Fatal("$msiName $forceDestLog- Fail exit code {$exitCode}")
      throw "$msiName installation failed"
    }
}

try {
    # Move Cptx install folder into temp directory before updateing cptxorder file and process cptx
    $cptxTempDir = [Utils]::CreateTemporaryDirectory()
    $cptxInstallPath = [RoleUtils]::BaseDirectory( [RoleTypes]::Cptx, $coreVersion )
    [Logger]::Verbose("Copying {$cptxInstallPath} to {$cptxTempDir}")
    Copy-Item -Path "$cptxInstallPath\*" -Destination "$cptxTempDir"

    $cdmFile  = "{0}\cdm.Exe" -f $cdmInstallationFolder
    $cptxFile = "{0}\Cptx_Order.cptxseq" -f "$cptxTempDir"

    [Logger]::Verbose("Manage cptx_order.cptxseq file to add specific plugin's cptx.")
    Get-ChildItem -Filter "*.Cptx"-Path "$cptxTempDir" | ForEach-Object {
        Add-CdmCptxOrderFile -ConfigFileFolder "$cptxTempDir" -CptxFilename "$_"
    }

    [Logger]::Info("Launch Cptx integration with {$cptxFile}")
    $tenants = [DeployCfg]::TenantList($deployConfig)
    foreach ($db in $tenants)
    {
        $traceId  =  "_{0}" -f "$($db.Name)"
        $cdmLocalLogFile = (join-path "$logsFolder" "CPTX$traceID.log")
        # Si on passe par laucnh process ca lance Cegid.CDMWebService et ca freeze ... encore un mystere CBP
        # $args = "/DB=`"$($db.Name)`" /SERVER=`"$($db.Server)`" /DRIVER=MSSQL2012 /USER=`"$($db.User)`" /PWD=`"$($db.Pwd)`" /UNICODE=1 /FILE=`"$cptxFile`" /TRACEID=`"$traceId`""
        # [Utils]::LaunchProcess($cdmFile, $args)
        [Logger]::Verbose("logfile : $cdmLocalLogFile")

        $params = "/DB=$($db.Name)", "/SERVER=$($db.Server)", "/DRIVER=MSSQL2012", "/USER=$($db.User)", "/PWD=$($db.Pwd)", "/UNICODE=1", "/FILE=$cptxFile", "/TRACEID=$traceId"
        [Logger]::Verbose("Start cptx integration for database {$($db.Name)} on server {$($db.Server)} with args`n$(($params -join "`n"))")
        & $cdmFile @params > "$cdmLocalLogFile"
        if( ! $? )
        {
            [Logger]::Fatal("CDM.exe processus for database {$($db.Name) on $($db.Server)} has failed")
            throw "Process aborted"
        }
        # Check logs for DbScriptGenerator error code 2 ( Need to convert inot UTF8 to check erros in )
        $logFile = Get-Content -raw -Path  $cdmLocalLogFile
        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        [System.IO.File]::WriteAllLines($cdmLocalLogFile, $logFile, $Utf8NoBomEncoding)
        $logFile = Get-Content -Path  $cdmLocalLogFile

        if ( ($null -ne ($logFile | Select-String -pattern "(`"Cegid.DbScriptGenerator.exe`" process terminated with return code 2.)")) -or `
            ($null -ne ($logFile | Select-String -pattern "(fin d'exécution de `"Cegid.DbScriptGenerator.exe`" avec un code de retour 2.)")) )
        {
            [Logger]::Fatal("DbScriptGenerator error code {2} found on cptx integration for database {$($db.Name) on $($db.Server)}")
            throw "CPTX integration failed"
        }
    }
}
finally {
    [Logger]::Verbose("Clearing ctpx temporary folder {$cptxTempDir}")
    Remove-Item -LiteralPath "$cptxTempDir" -Force -Recurse
}

Write-Host
