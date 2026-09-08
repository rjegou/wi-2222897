# Round 7 — vérification différentielle PlatformDeploy et réconciliation InventoryTracking

Date : 2026-09-07 Europe/Paris. Lecture seule Azure DevOps; aucune mutation distante, aucune queue et aucun document canonique modifié.

## PlatformDeploy : résultat du nouveau test

Le script `../2026-09-07-brain-reprise-consolidated-round6/test-platformdeploy-differential-round6.ps1` a été exécuté avec PowerShell 5.1. Résultat brut : `allPassed=true`, `TF_BUILD=true` dans les six processus.

| variante | enfant | Process.ExitCode observé | verdict |
|---|---:|---:|---|
| original | 0 | 0 | pass |
| original | 7 | 0 | absorption historique reproduite |
| original | exception | 1 | exception non masquée |
| corrigée | 0 | 0 | pass |
| corrigée | 7 | 1 | propagation reproduite |
| corrigée | exception | 1 | exception non masquée |

**FACT** — Le script copie le vrai `docker-pipeline-deploy.ps1` depuis `worktrees/Y2_Tools_PlatformDeploy`, puis substitue `docker-pipeline-deploy-ps7.ps1` par une fixture qui appelle `deploy-child.ps1`. `deploy-child.ps1` ne fait que `exit 0`, `exit 7` ou `throw`.

**FACT** — Il n'appelle pas `init-container.ps1`, ni la version originale, ni la version corrigée. Le texte de `init-container.ps1` n'est pas chargé par le processus; le script exerce donc réellement le wrapper externe, mais seulement une simulation de la frontière interne d'init-container.

**VERDICT** — Les 6/6 cas ferment la réserve de propagation au niveau du wrapper et distinguent bien code enfant nul, code enfant 7 et exception. Ils ne ferment pas la réserve round6 sur l'appel réel d'`init-container.ps1` avec les mêmes paramètres et dépendances substituées uniquement aux frontières externes.

Défaut exact à transmettre à Worker 3 : créer deux copies isolées ou deux invocations du vrai `init-container.ps1` (original/corrigé), injecter le même `deploy.ps1` factice via la frontière de commande attendue, puis capturer séparément l'exception PowerShell du script, `$LASTEXITCODE` juste après `deploy.ps1` et `Process.ExitCode`. Le test actuel ne doit pas être présenté comme un test before/after d'init-container.

## InventoryTracking : nombre exact de fichiers et diagnostics uniques

**FACT** — L'API Git Azure DevOps sur commit `ef3d87034d38b88aca04c824061b140e2a29252c`, parent `4de185bb132cfbfb50643b6b53d6feb85508f4e2`, renvoie `changeCounts: Edit=3` :

1. dossier `Cegid.Retail.InventoryTracking.Services.Tests` (entrée d'arbre) ;
2. `Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj` ;
3. `Cegid.Retail.InventoryTracking.Services.Tests/packages.config`.

Le premier rapport « deux fichiers » comptait les deux fichiers réellement édités; l'entrée dossier est la troisième entrée API, pas un troisième fichier de contenu. Le diff de contenu reste donc bien limité au `.csproj` et à `packages.config`.

**FACT** — `packages.config` contient `Cegid.Retail.XmlDiff` `1.0.0` et `XMLDiffPatch` `1.0.8.28`; le `.csproj` contient les deux références avec HintPath sous `Sln\packages`.

**FACT** — Build 4434070, log compilation 51 : le diagnostic unique MSB3245 est « Could not resolve ... Cegid.Retail.XmlDiff », répété dans deux formes de log; les erreurs CS0103 uniques sont quatre emplacements de `GlobalSettingsDtoConvertersUnitTest.cs` (lignes 88, 159, 219, 293, colonne 33), chacune répétée dans la sortie.

**FACT** — Builds 4440774 (log compilation 43) et 4440884 (log compilation 51), tous deux sur le commit exact `ef3d8703…`, comptent `MSB3245=0` et `CS0103=0`. Les logs montrent la copie de `Cegid.Retail.XmlDiff.dll` et `XmlDiffPatch.dll` depuis les dossiers NuGet attendus.

**INFERENCE bornée** — La correction est consommée et supprime les deux familles d'erreurs XmlDiff au stade compilation. Elle ne constitue pas une validation JMeter; le build 4440884 a d'ailleurs exécuté JMeter et s'est terminé `partiallySucceeded`.
