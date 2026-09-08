# File: check-for-update.ps1
# Check if a new version of the package is available and ask for install it if any
# Used only on local use

#Requires -Version 7.6

using module "..\Scripts\Modules\logger.psm1"
using module "..\Scripts\Modules\utils.psm1"

param (
    [version]$currentVersion    = $(throw "coreVersion is a required parameter"),
    [string]$folderToUpgrade    = $(throw "folderToUpgrade is a required parameter"),
    [string]$restartCmdLine     = $(throw "restartCmdLine is a required parameter"),
    [switch]$verbose,
    [int]$targetMajorVersion    = 0,   # 0 = comportement historique (pattern *), >0 = famille cible précise
    [string]$bootstrapScript    = ""   # script de redémarrage après upgrade (défaut : deploy.ps1)
)

[logger]::Info("Looking for update...")
$packageName   = "PlatformDeploy"
$retailJFrogCli = "$PSScriptRoot\..\Tools\Cegid.Retail.JFrogCli\Cegid.Retail.JFrog.Cli.exe"

# Construire la commande de téléchargement selon le mode demandé
if ($targetMajorVersion -gt 0) {
    $versionPattern = "$targetMajorVersion.*"
    if ($targetMajorVersion -eq $currentVersion.Major) {
        # Même famille : uniquement les versions plus récentes dans la famille
        [logger]::Info("Recherche de mise à jour dans la famille V$targetMajorVersion (> $currentVersion)...")
        $params = "download", "package", "$packageName", $versionPattern, "-gt", "$currentVersion", "-k", "-f", "./Upgrade"
    } else {
        # Inter-famille : télécharger la dernière version disponible dans la famille cible
        [logger]::Info("Recherche du dernier package PlatformDeploy V$targetMajorVersion (inter-famille)...")
        $params = "download", "package", "$packageName", $versionPattern, "-k", "-f", "./Upgrade"
    }
} else {
    # Comportement historique : toute version plus récente
    $params = "download", "package", "$packageName", "*", "-gt", "$currentVersion", "-k", "-f", "./Upgrade"
}
& $retailJFrogCli @params
if ( ! $? ) {
    [Logger]::Fatal("The download of one or more packages has failed")
    throw "Process aborted"
}
# Looking for a new version uploaded in upgrade folder  ( We get list in descending order to have the latest at first position )
$downloadedPackages = Get-ChildItem ".\Upgrade\$packageName.*.zip" -ErrorAction silentlycontinue | Sort-Object -Descending
if (($NULL -ne $downloadedPackages) -and ($downloadedPackages.Count -gt 1))
{
    # delete older versions downloaded and not installed to keep only the more recent ( indice 0 is the more recent due to sort method )
    For ($i = 1; $i -lt $downloadedPackages.Length; $i++)
    {
        Remove-Item  "$($downloadedPackages[$i])" -ErrorAction silentlycontinue
    }
}

if ($NULL -ne $downloadedPackages) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")>$NULL
    $message = "A new version of Y2 Platform Deploy is available.`n`nDo you want to install it now ?"
    $choice = [System.Windows.Forms.MessageBox]::Show("$message", "Y2 Platform Deploy $scriptsVersion", [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($choice -eq "YES")
    {
        $upgradeScript = "$PSScriptRoot\..\upgrade\do-upgrade.ps1"
        # Copy do-upgrade.ps1 scripts under folder upgrade
        Copy-Item "$PSScriptRoot\do-upgrade.ps1" "$upgradeScript" -force
        $zipArg        = "-zipPackage ""$($downloadedPackages[0])"""
        $cmdLineArg    = "-cmdLineToLaunch ""$restartCmdLine"""
        $destFolderArg = "-folderToUpgrade ""$folderToUpgrade"""
        # Passer le script de redémarrage si spécifié (ex : bootstrap.ps1)
        $upgradeArgs = "-File ""$upgradeScript""", $zipArg, $destFolderArg, $cmdLineArg
        if ($bootstrapScript) {
            $upgradeArgs += "-bootstrapScript ""$folderToUpgrade\$bootstrapScript"""
        }
        # Launch upgrade scripts under folder upgrade
        Start-Process -FilePath "pwsh" -ArgumentList $upgradeArgs
        # Exit current script and also calling script
        [System.Environment]::Exit(0)
    }
}
exit 0