# Préparation locale — rejeu FrenchTaxesRules V22 isolé

Date : 2026-09-07. Statut : préparation reviewable uniquement, aucun lancement.

## Périmètre

- plugin constant : `FrenchTaxesRules 22.0.6.478` ;
- variante `FixHistorical` : Core `22.0.0.1011`, Common `22.0.2.300`, Identity `22.0.5.182` ;
- variante `Candidate` : Core `22.0.0.2068`, Common `22.0.3.311`, Identity `22.0.6.117` ;
- AuthenticationServer constant : `2.0.0.368` ;
- image historique épinglée par digest : `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb` ;
- campagne attendue : `232 LegacyServices + 144 WebServices = 376` tests ;
- cas discriminants : `Tests/LegacyServices/012-FrenchTaxesRules_Run.jmx`, `Tests/WebServices/006-Validation_SetDocumentErrorReason.jmx`, `Tests/WebServices/020-Purge_Execute.jmx` ; les manifests historiques contiennent 12 JMX Legacy et 20 Web.

Le nom du backup n’est pas imposé. Le préflight exige le SHA-256 attendu et une restauration distincte par variante ; la preuve SQL/IIS est apportée par le contrôle runtime local dans le job container, pas par une attestation JSON déclarative. Un simple booléen `V22_DEDICATED_TARGET_CONFIRMED` n'est pas accepté.

Le snapshot contient `AUTO_V21_00.bak` (150515712 octets, SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2`). Cette valeur est une preuve historique, pas une exigence de nom pour le rejeu.

## Valeurs résolues et divergence Core

`ExternalsToRestore_V22.xml` est consommé par le job Build via `Nuget/restore-externals.v1.yml` ; il déclare Core `22.0.0.1012`, Common `22.0.2.300` et Identity `22.0.5.182`. Le job JMeter de déploiement consomme ensuite le fichier `v22-fix.cy2px` et les packages déployés. Les journaux MSI Fix enregistrent Core `22.0.0.1011` (dont CBRCPTX, Worker Process et composants IIS), statut d’installation `0`. Conclusion : `1012` est une entrée de restauration d’externals de compilation, `1011` une version d’installation runtime observée ; leur relation binaire exacte reste UNKNOWN.

## Agent/container

Le YAML historique associe `windows-latest` à `container: acr_y2jmeter_test`, puis transmet `APPSERVER_HOST`, `DB_HOST`, `AUTHORITY_HOST` et les ports au runner JMeter. Cela démontre le modèle d’un conteneur éphémère avec SQL/IIS dans le job, mais pas sa disponibilité actuelle : compatibilité Windows LTSC2025, accès ACR/service connection, restauration SQL et cible dédiée restent UNKNOWN. Une infrastructure supplémentaire n’est pas démontrée nécessaire, mais l’exécution actuelle n’est pas prouvée.

## Garde-fous

Le YAML désactive triggers, publications JFrog, import/promotion ACR, tags et déclenchement aval. Le script échoue avant toute écriture si le backup hashé, les descripteurs, les 32 JMX historiques et les 32 JMX de run ne sont pas prouvés. Les 32 JMX historiques peuvent être utilisés directement ; aucune régénération n'est exigée sans changement explicitement justifié. Il ne contient aucun secret.

Le runner local `worktrees/Y2_Tools_Jmeter_Workflow/Scripts/jmeter-cli.ps1` appelle réellement `jmeter.bat -n -t <plan> -p <properties> -j <log> -l <jtl>` aux lignes 161-169. Cette preuve est statique : aucune invocation métier ni résultat final n'est acquis. Le préflight vérifie maintenant l'identité SHA-256 des 32 JMX contre [`JMX-SHA256SUMS.txt`](JMX-SHA256SUMS.txt), en plus de la cardinalité et des trois cas discriminants.

Le contrôle runtime du candidat est `scripts/Assert-V22LocalContainerRuntime.ps1`. Il refuse avant écriture si l'image attendue n'est pas digestée, si les trois endpoints ne sont pas `COMPUTERNAME`, ou si SQL Server/IIS et les ports 1433/80 ne sont pas présents dans le job container. Le contrôle historique `Assert-V22RuntimeIsolation.ps1` reste documentaire et n'est pas utilisé par le candidat, car `docker inspect`/`docker top` n'est pas disponible depuis le job.

Les fichiers historiques `task-run-campaign.v1.yml` et `task-deploy-in-containerized-job.v2.yml` ont été vérifiés, mais ne sont pas consommés par le candidat : les étapes sont inline et le template secret-printing est exclu.

## Round 3 — candidat complet reviewable, non queued

## Round 5 — corrections Worker 2/Worker 1 et manifeste

## Round 7 — corrections locales Worker 2

La référence `image` utilise maintenant le loginServer exact `acrretaildocker-e2c3eugzbee2habm.azurecr.io` avec le repository, tag et digest historiques. Chaque variante exécute une readiness check avant téléchargement/restauration.

`Invoke-V22PlatformDeploy.ps1` vérifie la révision PlatformDeploy épinglée, rend optionnelle sa déclaration de clé inutilisée dans une copie temporaire et l'invoque sans argument secret. Pour éviter un échec systématique d'authentification, il initialise temporairement le dépôt chiffré `Retail-JfrogCli.json` au format exact du CLI depuis la variable d'environnement masquée, puis restaure/supprime ce fichier en `finally`; toute consommation supplémentaire de la clé par le script fait échouer le contrôle.

`Assert-V22ConsumedPackages.ps1` vérifie après déploiement les trois ZIP de la variante contre `PACKAGE-SHA256SUMS.txt` et les trois versions dans `downloadedPackages.json`. Cette preuve porte sur les entrées téléchargées par PlatformDeploy, pas sur chaque assembly finalement chargé par IIS.

`Assert-V22AuthorizationComparison.ps1` exige pour `FixHistorical` les 138 signatures Legacy et 36 signatures Web attendues, puis exige pour `FixCandidate` zéro signature correspondante par scénario. `Assert-V22BaselineAttestation.ps1` valide ce résumé, son image/plugin/backup/versions et le refuse avant le téléchargement/restauration du job candidat. Les autres erreurs restent séparées et autorisées.

Le manifeste [`MANIFEST.sha256`](MANIFEST.sha256) fige les fichiers du candidat. Le checkout sépare désormais `self` (branche dédiée portant `investigations/.../replay-prep`) de `pluginSource` épinglé au commit `2d826b8fd19ecb4d7200f574414efb7583de8ed2`; les chemins `pluginSource\Tests` sont donc explicites. PlatformDeploy `5.0.86` et son hash `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295` sont intégrés.

Précondition d'intégration : la définition dédiée doit référencer une branche de `Y2_Plugins_FrenchTaxesRules` contenant exactement le sous-arbre `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/` manifesté ici. Cette branche/définition n'a pas été créée; le checkout `pluginSource` garantit séparément que les JMX et le backup viennent du commit plugin épinglé.

La clé JFrog n'est plus passée au wrapper en argument. Le script historique déclarait `RetailJfrogApiKey` comme paramètre obligatoire mais ne le consommait pas ; la correction locale rend cette déclaration optionnelle dans une copie temporaire et refuse toute révision où la clé apparaît ailleurs. `parameters.properties` reste temporaire, ACL restreinte à l'identité du job et exclu de toute collecte. `Collect-V22ScrubbedResults.ps1` ne conserve que métadonnées, hashes et compteurs expurgés. `Assert-V22CampaignCounts.ps1` refuse tout total différent de 232 + 144.

Tests locaux : le préflight positif reste passant; `Invoke-V22RunnerDryRun.ps1` vérifie aussi la présence de l'orchestration de production (restore PlatformDeploy, trois appels JMeter, campagne CLI, comptage et collecte); `Test-V22ReplayFailureModes.ps1` passe sur substituts inertes et démontre blocage du candidat après échec baseline, cleanup après échec candidat et refus d'un comptage incorrect. Le contrôle SQL/IIS est seulement une readiness check : il ne prouve pas l'identité/cycle de vie du container, les mounts ou l'absence de cible partagée.

Le fichier [`azure-pipelines.candidate.yml`](azure-pipelines.candidate.yml) est désormais un candidat complet et séquentiel : `Preflight` dans l'image digestée, `FixHistorical`, puis `FixCandidate`. Les deux variantes réutilisent le même plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, backup hashé et 32 JMX hashés; elles changent uniquement Core/Common/Identity. Chaque variante exécute les trois JMX discriminants puis les campagnes LegacyServices/WebServices, sans publication d'artefact (pour exclure toute fuite via `parameters.properties`) et avec nettoyage limité à son dossier sous `Agent.TempDirectory`.

Les étapes sont inline via [`scripts/steps-replay-variant.yml`](scripts/steps-replay-variant.yml), sans `Pipelines_Templates` et sans le template qui affichait `parameters.properties`. Le contrôle [`Assert-V22LocalContainerRuntime.ps1`](scripts/Assert-V22LocalContainerRuntime.ps1) vérifie seulement la disponibilité locale de SQL/IIS sur 1433/80 et crée un marqueur sous `Agent.TempDirectory`; il ne constitue pas une preuve d'identité/cycle de vie du container, de mounts ou d'absence de cible partagée.

**FACT** — commits locaux figés dans le candidat : plugin `2d826b8fd19ecb4d7200f574414efb7583de8ed2`, JMeter Workflow `4db2dcdab647249de3cdc27eadaf15a158b3a26a`, PlatformDeploy `93f91487ee717185599555a42df3cb5d024ace89`; image fixée par digest; backup `AUTO_V21_00.bak` SHA-256 déjà prouvé.

**FACT Worker 1 round5** — image historique `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb` et hashes des trois packages baseline sont intégrés dans [`PACKAGE-SHA256SUMS.txt`](PACKAGE-SHA256SUMS.txt). Leur consommation runtime reste à vérifier.

**FACT (collecte Worker 1, 2026-09-07)** — les logs du build historique `4429167` identifient le téléchargement JFrog `retail-software-production/Y2.Tools.PlatformDeploy/PlatformDeploy.5.0.86.zip`; une lecture actuelle HTTP 200 du même chemin a fourni 7 566 674 octets et le SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, concordant avec le hash calculé sur le flux. Le commit code `93f91487ee717185599555a42df3cb5d024ace89` reste une provenance Git distincte de l'identité du ZIP. Les deux valeurs sont renseignées dans le YAML. Aucun lancement ni queue n'a été effectué.

Le parcours positif inerte est reproductible avec `scripts/Invoke-V22RunnerDryRun.ps1` : il consomme le snapshot V22, vérifie backup/JMX/digest, puis contrôle l'ordre baseline historique → trois opérations discriminantes → campagnes Legacy/Web (376). Il ne lance ni SQL/IIS, ni JMeter, ni publication. Les contrôles négatifs refusent un digest non épinglé et un hash backup invalide avant toute écriture.

Commande exacte (PowerShell, depuis la racine WI) :
`$p=(Join-Path (Get-Location) 'investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated'); $s=(Join-Path (Get-Location) 'investigations/ecarts-jmeter-migrations/sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167'); & "$p/scripts/Invoke-V22RunnerDryRun.ps1" -ReplayRoot $p -HistoricalSourceRoot $s -BackupPath (Join-Path $s 'Tests/Backups/AUTO_V21_00.bak')`

## Audit Round 2 — isolation réellement démontrée par les templates

Lecture locale datée du 2026-09-07 des snapshots suivants : pipeline FrenchTaxesRules build 4429167, `Y2_Tools_PlatformDeploy` HEAD `93f91487ee717185599555a42df3cb5d024ace89` et `Y2_Tools_Jmeter_Workflow` HEAD `4db2dcdab647249de3cdc27eadaf15a158b3a26a` (ce dernier conserve la modification utilisateur de `azure-pipeline.yml`).

**FACT** — le pipeline historique déclare `container: acr_y2jmeter_test` pour chaque job TI JMeter et utilise une image `y2-jmeter` construite depuis une base SQLExpress. Le template de déploiement appelle `docker-pipeline-deploy.ps1` avec `-LocalDBInContainer Backup`; le script restaure chaque base via `sqlcmd` dans le SQL local du conteneur, et dépose le backup sous `$(Agent.TempDirectory)\Deploy\docker\data`. La configuration `v22-cur.cy2px` et `v22-fix.cy2px` contient `__CONTAINER_HOST__`, une seule base `AUTO_V21_00`, et les rôles Y2/Cptx/AuthServer/WebApps/Wp sur ce même hôte.

**FACT** — après `task-extract-vars`, le pipeline injecte `hostname` dans `APPSERVER_HOST`, `DB_HOST` et `AUTHORITY_HOST`, avec DB sur 1433 et application sur 80. Aucun `volumes:` ni `docker run/create/rm` externe n'est déclaré dans le pipeline FrenchTaxesRules; les seules publications observées sont des `PipelineArtifact` de logs/tests. Le pipeline historique contient toutefois des stages Publish/Promote/Tag_Sources et des téléchargements JFrog, donc il ne doit pas être lancé pour le rejeu isolé.

**INFERENCE limitée** — le code démontre une topologie de services locaux au job container et aucune cible SQL/IIS externe explicitement configurée. Il ne démontre pas à lui seul le cycle de vie Azure du container, son absence de volume partagé implicite, ni son digest réel au moment du run.

**FACT bloquant** — `Assert-V22RuntimeIsolation.ps1` appelle `docker inspect`/`docker top` depuis une étape exécutée dans le job et exige les labels `wi.scope`, `wi.ephemeral`, `wi.runId`; ni ces labels ni l'accès au daemon Docker ne sont fournis par le pipeline historique. Le candidat Round1 ne déclare pas de `container:` pour ses stages et ne contient aucune étape de déploiement/rejeu réelle. Ce contrôle ne peut donc pas être considéré comme une preuve équivalente sans étape hôte/agent séparée ou mécanisme de métadonnées prouvé.

**FACT bloquant** — le template local `task-run-campaign.v1.yml` écrit le mot de passe dans `parameters.properties` puis l'affiche intégralement avec `Get-Content` (lignes 90-107). Il est impropre à un rejeu isolé tant que cette fuite n'est pas supprimée ou que la tâche n'est pas remplacée par une variante équivalente dont les logs sont expurgés.

**Configuration techniquement nécessaire avant lancement** : job container explicitement déclaré avec image digestée et checkout séparé du plugin à `pluginCommit`; étapes inline et chemins disponibles dans la branche dédiée; backup `AUTO_V21_00.bak` vérifié par SHA-256 avant restauration séparée Cur/Fix; paramètres temporaires protégés et exclus des collectes; extraction vérifiée de `hostname`, `sqlinstance`, `backupName`, `authServerPort`; préflight des 3 cas puis campagnes Legacy/Web; collecte uniquement de métadonnées expurgées. Les paramètres réellement non résolus restent l'identité/cycle de vie du container Azure, ses mounts, la compatibilité agent et l'absence de cibles partagées.

## Limites et mutation minimale

Le pipeline `2054` existant référence `Pipelines_Templates` sans ref immuable et contient des jobs de publication/promotion/tag. Mutation minimale future : commit sur branche d'essai dédiée, remplacement de `TEMPLATES_COMMIT_REQUIRED` par un commit approuvé, injection de l'attestation de cibles et queue explicite après revue. Cette mutation n'a pas été effectuée.
