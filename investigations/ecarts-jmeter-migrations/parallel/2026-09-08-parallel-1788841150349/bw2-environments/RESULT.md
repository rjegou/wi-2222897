# Résultat — Full-Text et propagation des images

## Verdict au 2026-09-08

## PlatformDeploy — Round 2

**FACT** — la source PlatformDeploy `93f91487ee717185599555a42df3cb5d024ace89` contient déjà le garde `$nbErr -gt 0` dans `Src/Powershell/Code/Scripts/install-packages.ps1:247-250`; aucun doublon n'est requis.

**FACT** — patch local `e20c50acf33d11d8bba1cd10facb89dfd4bd4902` dans le clone exclusif `worktrees/platformdeploy` : `init-container.ps1` capture le retour de `deploy.ps1` et lève une erreur si non nul.

**FACT** — le harness local couvre succès, retour non nul, exception et `$LASTEXITCODE` résiduel : 4/4 cas PASS, `PROCESS_EXIT=0`. Le cas résiduel documente une limite volontaire : le garde suppose que le wrapper appelé termine explicitement; cette précondition est satisfaite dans la source actuelle (`deploy.ps1` termine par `exit $LASTEXITCODE`, `deploy-core.ps1` par `Exit $exitCode`).

**UNKNOWN** — validation sur package PlatformDeploy réellement consommé par les runners V22/V26; aucun run distant n'a été lancé.

**FACT** — le seul runner historique figé avec résolution détaillée est Clienteling `4432602`: `lastV5` a résolu `5.0.86`, tag `V5.0.86`, commit source `93f91487...`; l'égalité binaire archive historique/source reste UNKNOWN. Pour `4432554` et `4432510`, la version PlatformDeploy réellement consommée reste UNKNOWN.

**FACT** — le patch `e20c50a...` ne peut pas être consommé par les runs historiques: il existe seulement dans le clone local exclusif et n'a été ni publié ni poussé. Vérification sans registry possible par staging/archivage privé selon le job de build PlatformDeploy, puis extraction et hash du script.

**FACT** — les health checks du template couvrent page Y2, SQL tenants, `/health/`, WorkerProcess et AuthenticationServer/token selon configuration, mais `continueOnTestFailure=true` peut tolérer leurs échecs. Cela ne constitue pas une preuve de migration réussie.

**INFERENCE** — le correctif de propagation est pertinent pour les chemins pipeline qui consomment cette famille de scripts, mais son intégration doit être vérifiée dans l'archive exacte du runner; aucun contenu d'image ou succès migration n'est démontré.

**UNKNOWN** — transport effectif des fixtures vers l'image/montage et attestation runtime `Agent.ContainerMapping`; aucun correctif BW1/BW3 n'est importé.

### Round 4 — packaging privé et lecture AzDO

**FACT** — le packaging local reproduisant `CopyFiles` puis `ArchiveFiles` conserve le `init-container.ps1` corrigé : source et extraction SHA-256 `2D713EE2149D20F5137BBAF5E459B4CAB4307883F4B93791C61D54C74D65CF1F`; archive privée `52B0125A7E00256D4138E591CC2F97B2FA9372A9E84D69C25B3D1B48E4681318` (59 437 octets). Parse extrait : 0 erreur. Preuve : [round4-packaging-azdo.md](evidence/platformdeploy/round4-packaging-azdo.md).

**UNKNOWN** — les lectures REST HTTPS ciblées des builds `4432602`, `4432554` et `4432510` n'ont pas obtenu de réponse (`The SSL connection could not be established`); aucun artefact n'a été téléchargé. `4432602` reste documenté comme `5.0.86`/`V5.0.86`/`93f91487...`, sans égalité binaire prouvée; `4432554` et `4432510` restent sans version PlatformDeploy prouvée.

Le worker 1 entreprend un nouveau preflight autorisé; ce round ne dispose pas de son résultat et n'en déduit aucune conclusion.

**FACT** — les builds `4442685` (commit `e3b674b007071259fd74b024f6b4b48baf0a7f5d`) et `4442156` (commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`) échouent dans le probe Full-Text. Les deux versions SQL atteignent `PopulateStatus=1`, puis le probe expire dans sa fenêtre de 90 secondes avant `CONTAINSTABLE`. Les preuves sont les README des collectes datées dans `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-sql-fulltext-build-4442685-recovery-round2/` et `.../evidence/2026-09-07-brain-reprise-worker2-round13/`.

**INFERENCE bornée** — le défaut démontré est une population Full-Text non terminale dans la fenêtre du probe; ce n'est pas une preuve d'absence de Full-Text. `PopulateStatus=1` est compatible avec une population en cours, lente ou bloquée.

**UNKNOWN** — cause parmi `MSSQLFDLauncher`/`fdhost`, crawl ou word breaker, configuration/catalogue, espace disque, démarrage SQL ou interaction image. Les valeurs DMV détaillées, ERRORLOG/SQLFT logs et cleanup runtime ne sont pas disponibles dans les artefacts récupérés.

## Patch diagnostic

**FACT** — le YAML local `worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml` a le SHA-256 `6C6FD9EC35AD02DA4B71DB8562888BB479441BCC44BED78D4B169E7DB66E21B3`. Le `git status --short --branch` du clone indique uniquement ce fichier modifié, sur HEAD détaché; aucune publication ni queue n'a été faite.

**FACT** — le test local de revue extrait les deux scripts, parse sans erreur, vérifie les quatre cas de cleanup et les contrôles de flux. Résultat archivé : [patch-review-rerun.txt](evidence/fulltext/patch-review-rerun.txt), `EXIT=0`, `SCRIPT_PARSE=PASS count=2`. Une inspection `docker ps` en échec reste `remaining=UNKNOWN`; l'échec smoke est relancé après cleanup.

**UNKNOWN** — le comportement Docker/SQL réel du patch tant qu'une queue dédiée n'est pas autorisée et exécutée.

## Propagation image SQL → workflow

**FACT** — les Dockerfiles SQL 2019/2025 activent `FEATURES=SQLENGINE,FullText`; `Images/SqlExpress/tests.yml` vérifie `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` dans l'image construite. Hashes des fichiers relus : [file-hashes.tsv](evidence/fulltext/file-hashes.tsv).

**FACT** — `Y2_Tools_Jmeter_Workflow/azure-pipeline.yml` définit les tags de base `2019-y2-aspnet-10-windowsservercore-ltsc2022` et `2025-y2-aspnet-10-windowsservercore-ltsc2025`, puis inclut le dépôt `Pipelines_Docker_BaseImages`. `Docker/Y2-JMeter/job-build.yml` passe `baseImageTag` au `docker build`, puis publie l'image Y2-JMeter en staging et la teste via une référence tag.

**UNKNOWN** — aucune preuve locale de digest reliant un build précis de `Pipelines_Docker_BaseImages` à l'image effectivement consommée par un build JMeter. La chaîne YAML prouve le routage des tags, pas l'identité de contenu finale. Aucun push ou publication n'a été effectué dans ce round.

## Prochaine expérience exacte

Après coordination explicite : une queue unique de la définition dédiée Full-Text, sans Dockerfile modifié, sans promotion/push, avec la fenêtre actuelle de 90 secondes. Avant suppression du conteneur, collecter services/processus `MSSQLFDLauncher`/`fdhost`, DMV Full-Text, catalogues/index, ERRORLOG/SQLFT ciblés et espace disque. La décision est : `PopulateStatus=0` puis au moins un résultat `CONTAINSTABLE` et cleanup confirmé; sinon conserver le sous-verdict causal en `UNKNOWN`. Ne pas augmenter arbitrairement le timeout.
