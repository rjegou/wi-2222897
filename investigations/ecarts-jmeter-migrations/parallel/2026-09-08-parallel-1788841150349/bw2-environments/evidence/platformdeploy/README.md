# PlatformDeploy — revue locale Round 1 — 2026-09-08

## Périmètre et provenance

- Source inspectée : `worktrees/Y2_Tools_PlatformDeploy`, HEAD `93f91487ee717185599555a42df3cb5d024ace89`.
- Clone indépendant de travail : `worktrees/platformdeploy`, baseline locale `ead4504982dc34fc1eed1476624a9f828e460e7f`.
- Correction locale : commit `e20c50acf33d11d8bba1cd10facb89dfd4bd4902`, sans publication distante.
- Date de collecte : 2026-09-08 ; méthode : lecture locale, parse PowerShell et harness inerte sans Docker/SQL/IIS.

## Constats

### FACT — garde MSI déjà présente

`Src/Powershell/Code/Scripts/install-packages.ps1:74-124` cumule les retours de `installMsi`/`installAllMSIs` dans `$nbErr`. Les lignes `247-250` lèvent une exception lorsque `$nbErr -gt 0`. Aucun ajout de garde identique n’est proposé.

### FACT — écart de propagation du déploiement corrigé localement

Dans la baseline, `Src/Powershell/Code/Scripts/init-container.ps1:191` invoquait `deploy.ps1`, puis ne testait `$LASTEXITCODE` qu’à l’intérieur du chemin local `TF_BUILD -ne $TRUE` pour décider d’exécuter les tests. Le chemin pipeline ne transformait pas explicitement un code de sortie non nul en erreur de déploiement.

Le patch ajoute immédiatement après l’invocation : capture de `$LASTEXITCODE`, journalisation expurgée et `throw` si le code est différent de zéro. Il ne modifie ni l’attendu métier, ni le health check, ni la configuration distante.

### FACT — health checks et limite de leur portée

`Src/Powershell/Code/Scripts/test-container-ps7.ps1:178-235` contrôle page d’accueil, SQL si des tenants existent, page `/health/`, ping WorkerProcess si applicable et AuthenticationServer/token si applicable. Le template `Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml:270-283` ne lance ce test que lorsque le déploiement précédent est `succeeded()` et peut rendre les tests tolérants via `continueOnTestFailure`.

`continueOnTestFailure: true` dans `Src/PipelineTemplates/task-deployment-tests.yml:42-43` est donc un contrat de collecte de santé, pas une preuve de déploiement réussi ni de migration métier réussie.

### FACT — contrat de version et artefact

`task-deploy-in-containerized-job.v2.yml:21-60,80-140` accepte une version PlatformDeploy fixe ou `lastV*`, la résout via Artifactory, valide la plage SemVer (sauf identifiant de build numérique), puis extrait l’archive. L’identifiant réellement consommé doit être conservé dans la preuve de chaque run ; la lecture YAML seule ne prouve pas la version effectivement installée.

## Consommation historique figée

**FACT** — pour le build Clienteling V22/V23 `4432602`, les logs historiques `215/243/244` relus dans `evidence/2026-09-07-brain-reprise-consolidated/README.md` établissent `lastV5` → `foundPlatformDeployVersion=5.0.86`, téléchargement/extraction de `PlatformDeploy.5.0.86.zip`, et tag source `V5.0.86` → commit `93f91487ee717185599555a42df3cb5d024ace89`. Le SHA-256 rapporté de l’archive est `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, mais l’égalité binaire avec l’archive effectivement consommée reste `UNKNOWN`.

**UNKNOWN** — aucun élément figé ne donne une résolution PlatformDeploy équivalente pour le build Clienteling V26 `4432554` ou FrenchTaxesRules V26 `4432510`. Il est donc interdit d’affirmer que le patch local `e20c50a...` a été consommé par ces runs.

**FACT** — le workflow JMeter au commit local `4db2dcdab647249de3cdc27eadaf15a158b3a26a` construit les images avec `Docker/Y2-JMeter/job-build.yml`, transmet `baseImageTag` au `docker build` et référence `Pipelines_Templates`/`Pipelines_Docker_BaseImages` sans ref immuable dans le YAML inspecté. Cela relie le routage déclaratif, pas le contenu final ni PlatformDeploy réellement exécuté.

## Vérification locale sans registry

Le job PlatformDeploy construit son archive par `CopyFiles` vers `$(Build.BinariesDirectory)`, puis `ArchiveFiles` vers `PlatformDeploy.$(Build.BuildNumber).zip` (`Src/PipelineTemplates/job-build.platformDeploy.yml:60-157`). Une vérification locale reproductible peut donc staging-er les mêmes chemins depuis le clone patché, produire une archive privée sous `evidence/platformdeploy/`, l’extraire avec le même layout `Deploy/`, puis comparer le SHA-256 de `Scripts/init-container.ps1` et exécuter le harness `TF_BUILD=true`. Cette méthode prouve uniquement que l’archive privée contient le patch; elle ne prouve ni acquisition JFrog, ni agent Windows, ni MSI/SQL/IIS.

## Tests exécutés

1. Harness avant (`harness-before.ps1` + `child-exit.ps1`) : le sous-script retourne 7 ; sortie `LASTEXITCODE=7`, processus du harness 0. Cela montre qu’une simple invocation ne constitue pas à elle seule une propagation d’échec.
2. Harness après (`harness-after.ps1`) : même retour 7 ; exception `Deployment failed with exit code 7`, processus 1.
3. Harness discriminant (`harness-semantics.ps1`) : 4/4 PASS pour succès (`0`), retour non nul (`7`), exception et code résiduel (`9`). Le cas résiduel échoue volontairement sous le garde afin de rendre explicite la précondition du patch.
4. Parse PowerShell sans erreur pour `init-container.ps1`, `install-packages.ps1` et `test-container-ps7.ps1`.
5. `git diff --check` après correction : succès.

## Portée réelle de `$LASTEXITCODE`

Le harness ne remplace pas un run complet. Il vérifie la sémantique d’appel `& script.ps1` utilisée par `init-container.ps1`. La source réelle rend le garde déterministe dans le chemin nominal : `deploy.ps1` termine par `exit $LASTEXITCODE` (`deploy.ps1:46-51`) et `deploy-core.ps1` termine par `Exit $exitCode` (`deploy-core.ps1:169-188`). Le cas résiduel reste un contrat à préserver si ce wrapper est refactoré.

Ces tests sont inertes et ne prouvent ni installation MSI, ni image, ni SQL/IIS, ni réussite de campagne JMeter.

## Matrice locale

| Repo/fichier | Cause ou contrat | Avant | Après | Statut |
|---|---|---|---|---|
| Y2_Tools_PlatformDeploy / `Src/Powershell/Code/Scripts/init-container.ps1` | Code retour `deploy.ps1` non propagé explicitement dans tous les contextes | Retour 7 non transformé en exception par le harness | Exception explicite et sortie non nulle | CORRECTION LOCALE PROUVÉE sous contrat des wrappers `exit`; revue distante requise |
| Y2_Tools_PlatformDeploy / `Src/Powershell/Code/Scripts/install-packages.ps1` | Erreurs MSI agrégées dans `$nbErr` | Garde déjà présente | Inchangé | CLOS — ne pas dupliquer |
| Y2_Tools_PlatformDeploy / `Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml` | Version installée, déploiement, logs, health check | Contrats statiques seulement | Inchangé | PRÉREQUIS à prouver par run exact |
| Y2_Tools_PlatformDeploy / `Src/PipelineTemplates/task-deployment-tests.yml` | `continueOnTestFailure=true` | Santé collectée sans bloquer le job | Inchangé | UNKNOWN pour l’effet aval exact |

## Contrats proposés aux autres voies

- Producteur de runner : publier l’identifiant exact de l’image/OS/digest, la cible, les mounts/réseaux/ports et l’état cleanup avant toute étape métier.
- Consommateur PlatformDeploy : fournir la version exacte du package, le code de sortie du déploiement et les logs MSI avant d’autoriser les health checks.
- Consommateur health/JMeter : traiter `continueOnTestFailure` comme observation tolérée uniquement ; ne pas convertir un job vert en succès migration.
- Fixtures : transmettre un chemin/artefact explicite et son hash ; aucun nom `CustomImage`/`ImageFolder` n’est ajouté ici car le propriétaire du transport n’est pas prouvé.

## Limites / UNKNOWN

- UNKNOWN : version PlatformDeploy réellement consommée par les runs historiques V22/V26 ; aucun run distant n’a été lancé.
- UNKNOWN : le patch local n’est consommé par aucun package historique tant qu’une archive privée ou une publication explicitement autorisée n’est pas reliée au runner.
- UNKNOWN : comportement exact de `deploy.ps1` dans chaque version publiée et sur un agent pipeline réel.
- UNKNOWN : propagation effective de l’attestation `Agent.ContainerMapping` jusqu’à PlatformDeploy ; cette revue ne modifie pas Pipelines_Templates ni les définitions historiques.
- UNKNOWN : health checks réellement exécutés dans un run donné ; le YAML ne suffit pas à prouver l’exécution.
