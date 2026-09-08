#region Suppression de dossiers de tests
# Chemin du script
$basePath = $PSScriptRoot
Write-Host "Chemin du script : $basePath"

# Recherche du dossier Y2_Plugins_*
Write-Host "Recherche du dossier 'Y2_Plugins_*' dans $basePath..."
$repoFolder = Get-ChildItem -Path $basePath -Directory -Filter "Y2_Plugins_*" | Select-Object -First 1
if (-not $repoFolder) {
    Write-Host "Aucun dossier 'Y2_Plugins_*' trouve dans $basePath"
    exit
}
Write-Host "Dossier trouve : $($repoFolder.FullName)"

# Deduire le pluginName (ex: Y2_Plugins_Employee -> Employee)
$pluginName = $repoFolder.Name -replace "^Y2_Plugins_", ""
Write-Host "PluginName deduit : $pluginName"

# Chemin du dossier IntegratedTests
$integratedTestsPath = Join-Path -Path $repoFolder.FullName -ChildPath "IntegratedTests"
Write-Host "Chemin du dossier IntegratedTests : $integratedTestsPath"

# Verifier si le dossier IntegratedTests existe
if (Test-Path $integratedTestsPath -PathType Container) {
    # Recuperer les sous-dossiers de IntegratedTests
    $subfolders = Get-ChildItem -Path $integratedTestsPath -Directory | Select-Object -ExpandProperty Name

    # Verifier si IntegratedTests contient uniquement AutoTest et Workflow
    $allowedFolders = @("AutoTest", "Workflow")
    $extraFolders = $subfolders | Where-Object { $_ -notin $allowedFolders }

    if ($extraFolders.Count -gt 0) {
        # Il y a d'autres dossiers que AutoTest et Workflow
        Read-Host "IntegratedTests contient des dossiers autres que AutoTest et Workflow : $($extraFolders -join ', ')"

        # Supprimer le dossier AutoTest s'il existe
        $autoTestPath = Join-Path -Path $integratedTestsPath -ChildPath "AutoTest"
        if (Test-Path $autoTestPath -PathType Container) {
            Write-Host "Suppression du dossier AutoTest..."
            Remove-Item -Path $autoTestPath -Recurse -Force
        } else {
            Write-Host "Le dossier AutoTest n'existe pas dans IntegratedTests."
        }
    } else {
        # IntegratedTests contient uniquement AutoTest et Workflow (ou est vide)
        Write-Host "IntegratedTests contient uniquement AutoTest et Workflow (ou est vide).  Suppression de IntegratedTests..."
        Remove-Item -Path $integratedTestsPath -Recurse -Force
    }
} else {
    Write-Host "Le dossier IntegratedTests n'existe pas (deja supprime ou absent)."
}

# Supprimer les projets de tests legacy des deux campagnes conservées par la migration.
foreach ($testProjectSuffix in @("WebServices.Tests", "LegacyServices.Tests")) {
    $testProjectPath = Join-Path -Path $repoFolder.FullName -ChildPath "Cegid.Retail.$pluginName.$testProjectSuffix"
    Write-Host "Chemin du dossier $testProjectSuffix : $testProjectPath"
    if (Test-Path $testProjectPath -PathType Container) {
        Write-Host "Suppression du dossier $testProjectSuffix..."
        Remove-Item -Path $testProjectPath -Recurse -Force
    } else {
        Write-Host "Le dossier $testProjectSuffix n'existe pas."
    }
}
#endregion

#region Modification du fichier .sln

# Chemin du fichier solution : .\Y2_Plugins_{pluginName}\Sln\*.sln
$slnFolder = Join-Path -Path $repoFolder.FullName -ChildPath "Sln"
$slnFile = Get-ChildItem -Path $slnFolder -Filter "*.sln" -File | Select-Object -First 1
if (-not $slnFile) {
    Write-Host "Aucun fichier .sln trouve dans $slnFolder"
    exit
}
$slnPath = $slnFile.FullName
Write-Host "Chemin du fichier solution : $slnPath"

# Lecture du fichier solution
Write-Host "Lecture du fichier solution..."
$lines = Get-Content $slnPath

# Rechercher les lignes contenant les deux projets legacy.
$searchString = "Cegid\.Retail\.$pluginName\.(WebServices|LegacyServices)\.Tests"  # Escaped dots!
Write-Host "Recherche de la ligne contenant '$searchString'..."

# Remove each matching Project block and its following EndProject line.
$newLines = [System.Collections.Generic.List[string]]::new()
$insideRemovedProject = $false
foreach ($line in $lines) {
    if ($line -match $searchString) {
        $insideRemovedProject = $true
        continue
    }
    if ($insideRemovedProject) {
        if ($line.Trim() -eq "EndProject") { $insideRemovedProject = $false }
        continue
    }
    [void]$newLines.Add($line)
}

if ($newLines.Count -eq $lines.Count) {
    Write-Host "Aucune ligne correspondant au projet '$searchString' trouvee dans le .sln (deja supprime ou absent)."
} else {
    [System.IO.File]::WriteAllLines($slnPath, [string[]]$newLines)
    Write-Host "Projets legacy supprimes du fichier solution."
}

#region Suppression des lignes de packages.config

# Chemin du fichier packages.config (a l'interieur de $repoFolder)
$packagesConfigFile = Join-Path -Path $repoFolder.FullName -ChildPath "PublishedSharedTools\packages.config"

if (Test-Path -Path $packagesConfigFile -PathType Leaf) {
    Write-Host "Modification de packages.config..."

    # Lire le contenu du fichier
    $content = Get-Content -Path $packagesConfigFile

    # Filtrer les lignes a supprimer (uniquement "Cegid.Retail.AutoTest.Console")
    $filteredContent = $content | Where-Object {
        $_ -notmatch "Cegid\.Retail\.AutoTest\.Console"
    }

    # ecrire le contenu filtre dans le fichier
    $filteredContent | Set-Content -Path $packagesConfigFile -Force

    Write-Host "packages.config modifie."
} else {
    Write-Host "Le fichier $packagesConfigFile n'existe pas (chemin : $packagesConfigFile)."
}
#endregion

#region Nettoyage du fichier .nuspec

# Chercher le fichier .nuspec se terminant par ".Tests.nuspec" dans le meme dossier que le .sln
$nuspecFile = Get-ChildItem -Path $slnFolder -Filter "*.Tests.nuspec" -File | Select-Object -First 1

if (-not $nuspecFile) {
    Write-Host "Aucun fichier '.Tests.nuspec' trouve dans $slnFolder (deja supprime ou absent)."
} else {
    Write-Host "Fichier .nuspec trouve : $($nuspecFile.FullName)"

    $lines = Get-Content $nuspecFile.FullName
    $patterns = @(
        "Cegid\.Retail\.XmlDiff\.dll",
        "Cegid\.Retail\.XmlDiff\.xml",
        "xmldiffpatch\.dll"
    )

    $linesToRemove = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($pattern in $patterns) {
            if ($lines[$i] -match $pattern) {
                # Ajouter la ligne courante
                $linesToRemove += $i
                # Verifier si la ligne precedente est un commentaire
                if ($i -gt 0 -and $lines[$i - 1].Trim().StartsWith("<!--")) {
                    $linesToRemove += ($i - 1)
                }
            }
        }
    }

    # Supprimer les lignes en les excluant
    $linesCleaned = for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($linesToRemove -notcontains $i) {
            $lines[$i]
        } else {
            Write-Host "Suppression de la ligne $i : $($lines[$i])"
        }
    }

    # Sauvegarder le fichier modifie
    $linesCleaned | Set-Content -Path $nuspecFile.FullName -Force
    Write-Host "Fichier .nuspec nettoye avec succes."
}
#endregion


# Suppression des fichiers cibles
$filesToDelete = @("Gen_All_TestCases.cmd", "Testautos2Jmeter.bat", "BeforeMigration.ps1", "checkPackage.ps1")

foreach ($file in $filesToDelete) {
    $filePath = Join-Path -Path $repoFolder.FullName -ChildPath $file
    Write-Host "Chemin du fichier $file : $filePath"

    if (Test-Path $filePath -PathType Leaf) {
        Write-Host "Suppression du fichier $file..."
        Remove-Item -Path $filePath -Force
    } else {
        Write-Host "Le fichier $file n'existe pas."
    }
}

Write-Host "Operation terminee."

