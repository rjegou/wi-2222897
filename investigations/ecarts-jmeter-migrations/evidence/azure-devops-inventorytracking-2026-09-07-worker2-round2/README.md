# InventoryTracking XmlDiff — collecte worker 2, round 2

Date : 2026-09-07 (Europe/Paris). Collecte Azure DevOps `cegid/Retail`, lecture seule.

## Méthode CLI partageable

La méthode qui fonctionne dans cet environnement est :

```powershell
$cfg = Join-Path (Get-Location) '.azconfig-worker2-r2'
New-Item -ItemType Directory -Force $cfg | Out-Null
$env:AZURE_CONFIG_DIR = $cfg
$env:AZURE_DEVOPS_EXT_PAT = [IO.File]::ReadAllText('C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt').Trim()
try {
  az pipelines build show --id 4434070 --org https://dev.azure.com/cegid --project Retail --output json
  az devops invoke --area build --resource timeline --route-parameters project=Retail buildId=4434070 --org https://dev.azure.com/cegid --api-version 5.1 --output json
  az devops invoke --area build --resource logs --route-parameters project=Retail buildId=4434070 logId=51 --org https://dev.azure.com/cegid --api-version 5.1 --output json
} finally {
  Remove-Item Env:AZURE_DEVOPS_EXT_PAT,Env:AZURE_CONFIG_DIR -ErrorAction SilentlyContinue
  # supprimer le dossier de configuration temporaire exact après la collecte
}
```

Ne jamais afficher le PAT. `AZURE_CONFIG_DIR` évite l'erreur de permission sur le profil Azure global. Pour les réponses Unicode de `az devops invoke`, ajouter `PYTHONIOENCODING=utf-8`. `az devops invoke` avec `--area build --resource timeline --api-version 5.1` fonctionne; `resource timelines` ou `api-version 7.1-preview.2` échoue avec cette version de CLI.

## Résultat

**FACT** — La ref actuelle `InventoryTracking_Migration_AutoTest_Jmeter_On_master` pointe toujours vers `4de185bb132cfbfb50643b6b53d6feb85508f4e2`. Les derniers builds de cette branche sont `4434070` (`7.73`) et `4432064` (`7.71`), tous deux terminés `failed` au même commit.

**FACT** — Le fichier `Cegid.Retail.InventoryTracking.Services.Tests.csproj` est identique aux deux commits (`objectId=6d9c51077b37cc501e3dae9bb5224ae77f4f93e4`). Il référence explicitement `Cegid.Retail.XmlDiff` avec `HintPath=..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`.

**FACT** — `ExternalsToRestore_V26.xml` est également identique (`objectId=08eed7dc917da2670e62f9386d4e9916968be123`) et restaure `Cegid.Retail.Y2.Core.Net.Full` `26.0.0.1030`, `Cegid.Retail.Common.Library` `26.0.4.233`, `FWK-CEGID-NET-FULL` `12.9.181` et `Cegid.Retail.Identity.Services` `26.0.5.650`. Le log 4434070 prouve que ces quatre packages sont restaurés avec succès; il ne prouve pas que le DLL XmlDiff est contenu dans le package Core.

**FACT** — Le commit de migration `4de185b…` porte le commentaire `dereferencement`, parent `33bcac946d82dbb655c45b10693896286a98043f`, et supprime le répertoire `Cegid.Retail.InventoryTracking.WebServices.Tests` et son `packages.config`. Le master `20aa528…` conserve ce projet.

**FACT** — Le `packages.config` supprimé du projet WebServices.Tests contenait `Cegid.Retail.XmlDiff` `1.0.0` et `XMLDiffPatch` `1.0.8.28`. Le `packages.config` conservé de Services.Tests ne contient aucun de ces deux packages.

**FACT** — Dans le build master réussi `4435986`, le log VSBuild montre la compilation WebServices.Tests avec `Sln\packages\Cegid.Retail.XmlDiff.1.0.0\lib\net452\Cegid.Retail.XmlDiff.dll`, puis la compilation Services.Tests avec `Assemblies\Bin\Cegid.Retail.XmlDiff.dll`. Dans 4434070, MSBuild cherche `Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`, le déclare absent (`MSB3245`), puis produit quatre `CS0103`.

## Conclusion et correctif minimal candidat

Cause la mieux établie : le désenregistrement de l'ancien projet WebServices.Tests a supprimé l'unique restauration NuGet de `Cegid.Retail.XmlDiff`/`XMLDiffPatch`, alors que Services.Tests conserve une référence historique vers un DLL dans le répertoire Y2Core. La suppression du projet n'est pas en elle-même fautive; c'est l'absence prouvée de l'acquisition de la dépendance encore requise qui l'est.

Le plus petit correctif candidat est de restaurer explicitement le package `Cegid.Retail.XmlDiff` `1.0.0` dans le projet qui conserve la référence, ou de modifier la référence vers l'emplacement/package réellement supporté. Le choix entre ces deux formes reste à valider par le propriétaire du dépôt et par la compatibilité de `XMLDiffPatch`; aucun code, package, pipeline, branche ou dépôt n'a été modifié.

Test discriminant minimal : dans un checkout isolé du commit 4de185b…, restaurer uniquement la déclaration de package/référence prouvée, exécuter `dotNet-build: Build solution **\*.sln`, puis vérifier que la référence est résolue et que les quatre erreurs `XmlDiff` disparaissent. Un run Azure DevOps aurait des effets partagés : agent privé, restauration JFrog, publication Artifactory staging si Build réussit, puis potentiellement TestAutos/JMeter selon paramètres; il ne doit pas être recommandé avant validation locale et autorisation explicite.

## Templates

Les timelines prouvent les versions des tasks Azure (`JFrogNuGet 1.14.2`, `VSBuild 1.276.0`) et les noms de templates exécutés, mais aucun commit résolu des dépôts `Pipelines_Templates`, `Y2_Tools_Jmeter_Workflow` ou `Y2_Tools_PlatformDeploy` n'est exposé par les métadonnées lues. Leur contenu exact au run reste **UNKNOWN**, sans conclure à une impossibilité de résolution.
