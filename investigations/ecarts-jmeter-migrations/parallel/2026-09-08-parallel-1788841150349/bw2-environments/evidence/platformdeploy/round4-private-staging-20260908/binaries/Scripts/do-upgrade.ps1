# File: do-upgrade.ps1
# Script to upgrade y2platform.
# This script is copied into the upgrade folder and launched in a separate process
# to release files before upgrading.
# Used only on local use.

#Requires -Version 7.6

param (
    [string]$zipPackage      = $(throw "zipPackage is a required parameter"),
    [string]$folderToUpgrade = $(throw "folderToUpgrade is a required parameter"),
    [string]$cmdLineToLaunch = $(throw "cmdLineToLaunch is a required parameter"),
    [string]$bootstrapScript = ""   # Full path to the restart script after upgrade (default: deploy.ps1)
)

function BackupActualVersion([string]$upgradeTempDir, [string]$backupSource, [string] $backupDest)
{
    Get-ChildItem -Filter "*.*"-Path "$upgradeTempDir" | ForEach-Object {
        if($_.PSIsContainer)
        {
            # Backup folder only if exists in current version
            if (Test-Path "$backupSource\$($_.Name)" )
            {
                Write-Output "Backup folder $($_.Name) in $backupDest"
                Move-Item "$backupSource\$($_.Name)" "$backupDir\$($_.Name)"
            }
        }
        else
        {
            # Backup file only if exists in current version
            if (Test-Path "$backupSource\$($_.Name)" -PathType leaf)
            {
                Write-Output "Backup file $($_.Name) in $backupDest"
                Move-Item "$backupSource\$($_.Name)" "$backupDest\$($_.Name)"
            }
        }
    }
}

function UpgradeVersion([string]$upgradeTempDir, [string]$folderToUpgrade)
{
    Get-ChildItem -Filter "*.*"-Path "$upgradeTempDir" | ForEach-Object {
            Write-Output "Upgrade $folderToUpgrade\$($_.Name)"
            Move-Item "$upgradeTempDir\$($_.Name)" "$folderToUpgrade\$($_.Name)"
    }
}

### Main ###
# This script is running under ./upgrade subfolder
$ErrorActionPreference = "Stop"
Write-Output "Upgrading Y2PlatformDeploy with package $(Split-Path $zipPackage -leaf) ..."
Write-Output ""
try
{
    $upgradeTempDir = "$PSScriptRoot\tmp"
    if (Test-Path $upgradeTempDir)
    {
        Write-Output "Clearing upgrade temporary folder $upgradeTempDir"
        Remove-Item $upgradeTempDir -Force -Recurse
    }
    $backupDir = "$PSScriptRoot\backup"
    if (Test-Path $backupDir)
    {
        Write-Output "Clearing backup folder $backupDir"
        Remove-Item $backupDir -Force -Recurse
    }
    New-Item -Path $backupDir -ItemType "directory" >$NULL
    Expand-Archive -Path "$zipPackage" -DestinationPath "$upgradeTempDir"

    # Make a backup of current version
    BackupActualVersion -upgradeTempDir $upgradeTempDir -backupSource "$folderToUpgrade" -backupDest "$backupDir"
    Write-Output ""
    # upgrade version
    UpgradeVersion -upgradeTempDir $upgradeTempDir -folderToUpgrade "$folderToUpgrade"

    # Remove zip used for upgrade
    Remove-Item -Path "$zipPackage" -Force
    # And this script
    Remove-Item -Path "$PSScriptRoot\*.ps1" -Force

    # Do not check for upgrade After installing a new version
    $cmdLineToLaunch = $cmdLineToLaunch + " -ignoreUpgrade"
    # Utiliser le script de redémarrage fourni (bootstrap.ps1 pour upgrade inter-famille)
    # ou deploy.ps1 par défaut pour la compatibilité ascendante.
    $launchScript = if ($bootstrapScript -and (Test-Path $bootstrapScript)) { $bootstrapScript } else { "$folderToUpgrade\deploy.ps1" }
    Start-Process -FilePath "pwsh" -ArgumentList "$('-Command ""')$launchScript $cmdLineToLaunch$('""')"
    [System.Environment]::Exit(0)
}
catch {
    Write-Host "$_" -ForegroundColor Red
    Write-Host "$($PSItem.Exception)" -ForegroundColor Red
    Write-Output ""

    Write-Output "Upgrade fail : Press Enter"
    Read-Host
}
finally
{
    # We keeep backup folder locally, it will be replaced during next upgrade
    Write-Output "Clearing upgrade temporary folder $upgradeTempDir"
    Remove-Item -Path "$upgradeTempDir" -Force -Recurse
}

exit 1
