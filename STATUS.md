# État consolidé — WI-2222897

**Snapshot du 2026-09-11.** Ce fichier ne contient que l'**état courant**. Les 27 sections datées
qui retraçaient l'historique jour par jour ont été déplacées sans perte dans
[archive/status-history-2026-09.md](archive/status-history-2026-09.md).

Motif de la séparation : l'ancien fichier mêlait l'état courant et son historique sans ordre
chronologique, et conservait des sections explicitement mentionnées comme supersédées à côté
de l'état en vigueur. Il fallait le lire intégralement pour connaître l'état.

Règle pour la suite : une modification d'état met à jour **la section concernée ci-dessous**.
Une nouvelle section datée va dans le fichier d'historique, pas ici.

## Où lire quoi

| Question | Fichier |
|---|---|
| Qu'est-ce qui bloque, et qui doit trancher ? | [decisions/README.md](decisions/README.md) |
| Quel est l'état de chaque domaine ? | la section « Synthèse » ci-dessous |
| Quelle est la cause d'un échec précis ? | [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) puis `findings/` |
| Que faut-il implémenter, et où ? | [CORRECTION_PLAN.md](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) |
| Que dire au PO / lead dev ? | [reporting/2026-09-08-synthese-onenote-pbi.md](reporting/2026-09-08-synthese-onenote-pbi.md) |
| Qu'est-ce qui s'est passé tel jour ? | [JOURNAL.md](JOURNAL.md) et l'historique d'état |
| Où sont les artefacts lourds ? | [EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md) |

## Reprise Clienteling 14264 — agent résolu, rejeu bloqué par le backup

La clôture documentaire du 2026-09-08 (« aucun nouveau run, push, provisionnement ») a été **dépassée
par une reprise ultérieure**, rapportée dans les [synthèses techniques de pause](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/README.md)
et non revérifiée ici : le stage `TargetDiagnostic` a été basculé sur `vmImage: windows-2025`
(commit `c20755d802d1fb56a93289dd19b92622eb7f2c54`, postérieur à `f8858ad7…`) et le run `4446303`
est `succeeded` avec Docker `29.7.2`. Les agents privés A/B ne sont plus une piste. Le fait est
consigné sans attribution à une session identifiée.

Deux acquis rapportés changent la suite : les valeurs runtime PlatformDeploy V26 sont résolues depuis
les logs du build historique `4432554` (`PlatformDeploy 5.0.86`, `docker-pipeline-deploy.ps1`,
`Docker\data\v26-Cur.cy2px` / `v26-Fix.cy2px`, `-LocalDBInContainer "Backup"`), et le backup
`Tests/Backups/AUTO_V26_00.bak` que ce build consommait est **absent de l'arbre Git actuel** de
`master` comme de la branche isolée. Le rejeu est donc bloqué en amont du provisionnement : premier
sujet à reprendre, vérifier que l'objet LFS `8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`
(`156 663 808` o) est encore téléchargeable, puis choisir le changement minimal qui le matérialise sur
l'agent `windows-2025`. Détail dans
[finding 016](investigations/ecarts-jmeter-migrations/findings/016-clienteling-v26-backup-lfs-absent.md).

Ce hash ne doit pas être confondu avec le `AUTO_V26_00.bak` de `Y2_Plugins_FrenchTaxesRules`
(`23bfb0b6…`, `150 765 568` o) : deux fichiers homonymes dans deux dépôts.

### Faits établis

- `FACT` — API corrigée : commit `4c22cb2850a150161f44080815375527c4daad48`, build `4444962`,
  PipelineArtifact `5037204`.
- `FACT` — Console accepté : build `4445025`, artifact `5037277`, version `2.0.43`, package
  SHA-256 `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`; tests
  discriminants de la DLL embarquée passés. Provenance distincte du candidat local `803D...`.
- `FACT` — définition `14264`, branche `sandbox/clienteling/wi2222897-isolated-replay`, dernier
  commit distant **vérifié** `f8858ad73df9c9eca7e438e609b6effebb677a9b` ; le commit `c20755d8…`
  signalé plus haut est postérieur mais seulement rapporté, non revérifié.
- `FACT` — `4440884` utilisait le pool privé pour Build V26, mais Cur/Fix utilisaient Azure
  Pipelines Windows 2025 avec Docker. Les diagnostics privés `4445464` et `4445516` ne
  réfutent donc pas cette voie hébergée.
- `FACT` — aucun Build Clienteling corrigé complet, GenerateJmx, Cur ou Fix prouvé dans 14264.
  Scripts préparés et tests locaux ne valent pas exécution distante.

### Limites et reprise

- `UNKNOWN` — acquisition/restauration du backup, réseau privé, contenu final de l’image, endpoints
  réels et cleanup attesté. Le hash du backup et les chemins PlatformDeploy/config sont désormais
  **rapportés** (finding 016) et non plus totalement inconnus ; l'agent hébergé Docker-compatible est
  identifié.
- `INFERENCE` — reprendre dans le contexte hébergé Windows 2025/Docker des jobs Cur/Fix
  historiques, sans généraliser depuis le job privé direct.
- Ordre : relire [HANDOFF.md](investigations/ecarts-jmeter-migrations/HANDOFF.md), puis la
  [comparaison round11](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-14264-initialization-comparison-round11/README.md),
  intégrer les producteurs PlatformDeploy/DataRoot/IIS/JMeter, attester image/backup/réseau/
  endpoints/cleanup, puis seulement Build → GenerateJmx → Cur/Fix avec les candidats hashés.

Ressources à conserver : preuves sous `investigations/ecarts-jmeter-migrations/evidence/`, scripts
sous `investigations/ecarts-jmeter-migrations/replay-prep/` et staging `.work` jusqu’à dépollution
ciblée. Ne pas réimporter les binaires.

### Suite rapportée le 2026-09-09 — GenerateJmx débloqué, JMeter Cur/Fix pas encore atteint

**Rapporté, non revérifié.** Un document reçu le 2026-09-09 rapporte une reprise postérieure à ce qui
précède : deux variables de pipeline manquantes (`Product.Version: '26.0.10.23'`,
`BuildPlatform: 'any cpu'`) ont été rétablies, permettant d'atteindre `GenerateJmx` ; deux fautes
causales y ont ensuite été identifiées et corrigées — le manifeste de migration
(`New-Wi2222897MigrationManifest.ps1`) ne copiait que le XML racine des plans sans leurs
`InputFiles`/`ExpectedOutput` (push `5138407`, HEAD `8cc14f2f8b83ea642a021e0e2ba8b872ab95c664`), puis
la Console recevait un `TestPlan` au lieu du `TestCampaign` attendu par `--tstj`
(`Invoke-Wi2222897JmxRegeneration.ps1` corrigé, push `5138712`, HEAD
`28f71268426de6f196c2f4672b526489819c6393`). Aucun JMeter Cur/Fix n'est revendiqué par ce document :
le prochain test doit relancer la définition `14264` sur `28f71268…` avec `apiBuildId=4444962`,
`consoleBuildId=4445025`, `consoleDefinitionId=2641`. Détail dans
[finding 019](investigations/ecarts-jmeter-migrations/findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md).

## FrenchTaxesRules V22/V23 — validation rapportée du 2026-09-10

**Rapporté, non revérifié.** Une synthèse technique reçue le 2026-09-10 rapporte que le trio
`Y2.Core 22.0.0.2068` / `Y2.Core.Common 22.0.3.311` / `Y2.Plugin.Identity 22.0.6.117`, issu du
packaging `22.0.23`, a été appliqué à V22 Fix avec AuthenticationServer `2.0.0.368` inchangé. Le
run `4453591` est rapporté vert en V22 Cur et Fix, avec toutes les campagnes V22 jouées. Cela
confirme la combinaison dans le compte rendu, mais pas la version minimale individuelle ni la
cause exacte parmi Core/Common/Identity.

La même source rapporte V23 Cur vert, tandis que V23 Fix s'arrête avant JMeter dans `Test Y2
deployment` sur `sectionGroupName` dans `IdentityServerConfiguration.ExtractAdditionalConfig`.
Le test discriminant annoncé remplace uniquement Identity `23.0.5.243` par `23.0.6.171` sur la
branche `sandbox/WI-2222897-frenchtaxesrules-v23-identity-validation-20260910`, commit
`07397fd…`; son résultat reste `UNKNOWN` tant que la ref et la timeline ne sont pas relues.
Voir [finding 023](investigations/ecarts-jmeter-migrations/findings/023-frenchtaxesrules-v22-v23-packaging-validation-20260910.md)
et la [preuve source](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-10-frenchtaxesrules-v22-v23-validation/README.md).

## Legacy PG2/PG3 — arrêt rapporté avant le démarrage des tests

**Rapporté, non revérifié.** Une fiche reçue le 2026-09-11 rapporte que le workflow `Y2_Plugins_FrenchTaxesRules_master`
sur `Y2-TSTAUTOXXPG2` s'arrête dans `executeWorkflowPlugin`, avant `executeWF_PluginOneCore` et
`executeIntegrationTest`, sans TRX ni `.mstest.log` dans le workspace. Elle propose comme hypothèse
principale un blocage PowerShell 5.1 lors d'un `Invoke-WebRequest` JFrog sans `-UseBasicParsing`.
Le run `4459782` ne constitue donc pas une baseline Legacy et ne permet pas de conclure sur une
régression JMeter. Un complément rapporte le même arrêt sur `Y2-TSTAUTOXXPG3` avec
`Y2_Plugins_InventoryTracking_V5`, le même XML NAnt à `0` octet et le même
`Artifactory_fct.ps1` (SHA-256 rapporté identique entre PG2 et PG3). **INFERENCE rapportée** : le
problème semble transversal aux VM Legacy et au code commun d'accès JFrog, avec
`Invoke-WebRequest` PowerShell 5.1 sans `-UseBasicParsing` ni timeout explicite comme suspect
principal. Ces éléments restent non revérifiés. Voir [finding 025](investigations/ecarts-jmeter-migrations/findings/025-frenchtaxesrules-legacy-log-recovery-4459782.md),
la [collecte PG2](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-11-frenchtaxesrules-legacy-log-recovery/README.md)
et le [complément PG2/PG3](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-11-legacy-jfrog-cross-vm-symptom/README.md).

## Baseline Legacy FrenchTaxesRules master — 10.95 / build 4462232

**FACT — preuve locale vérifiée.** La baseline de référence est désormais archivée dans
[le dossier dédié](evidence/legacy/Y2_Plugins_FrenchTaxesRules/master/10.95-build-4462232/README.md).
Le workflow Fix → Current trace Identity `26.0.7.221`, MSTest et la génération des TRX.
Chaque campagne compte 274 tests exécutés selon le compteur TRX ; après exclusion des
conteneurs, Fix compte 1 échec élémentaire et Current 44. La comparabilité détaillée avec
JMeter reste **UNKNOWN** tant que les contrats, versions, données, paramètres et environnement
ne sont pas alignés. Voir [finding 026](investigations/ecarts-jmeter-migrations/findings/026-frenchtaxesrules-legacy-baseline-4462232.md).

## Synthèse

État par domaine au **2026-09-11**. Chaque ligne renvoie à la preuve qui la soutient.

| Domaine | État | Preuve canonique | Suite sûre |
|---|---|---|---|
| Périmètre et critères du WI | documentés | [README.md](README.md), [synthèse du PBI](documentation/context/PBI_2222897_synthese_visio_Ludo.md) | relire le work item live si une décision dépend de son état actuel |
| Procédure de migration | documentée, valeurs historiques signalées | [documentation/README.md](documentation/README.md) | revalider versions, chemins et prérequis avant exécution |
| Inventaire plugins/branches | 19 couples recalculés depuis les dépôts le 2026-09-03 ; bilan intermédiaire intégré le 2026-09-07 ; FACT : utilisateur fixe Clienteling à master, releases/V6, releases/V7, releases/V8 le 2026-09-08 ; collecte AzDO du 2026-09-10 : 48 refs `heads` actuelles créées par `rjegou@cegid.com` sur 10 des 12 dépôts du périmètre | [documentation/tracking/](documentation/tracking/README.md), [décision 1](decisions/README.md), [inventaire AzDO 2026-09-10](documentation/tracking/2026-09-10-azdo-branches-created-by-rjegou.md) | utiliser l’inventaire daté pour les branches de travail ; les branches supprimées restent UNKNOWN |
| Diagnostic des échecs | 9 des 9 couples suivis classés `TERMINE` ; chaque cas non passé est rattaché à une cause prouvée. InventoryTracking est validé avec couverture complète restaurée | [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) | implémenter les causes prouvées ; ne pas rouvrir un verdict sans preuve contraire |
| Comparaison legacy/JMeter | baseline V26 obtenue pour FrenchTaxesRules (253 scénarios) et Clienteling (2 131) ; **aucune baseline comparable pour V21–V25** | [matrice legacy](investigations/ecarts-jmeter-migrations/cases/LEGACY_COMPARISON_MATRIX.md) | ne reclasser qu'à scénario, contrat, versions, données et environnement identiques |
| Générateur JMX (4 défauts) | FACT : Console candidate 2.0.43 du build 4445025/5037277 embarque la DLL API attendue et génère réellement les 19 plans source au code 0 ; l’inventaire nominatif 10 LegacyServices + 9 WebServices correspond à 19 sorties ; le compteur fixe 32 provient du commit de validateur c5aebe9 sans inventaire source ; aucun moteur JMeter lancé | [preuve génération 4445025](investigations/ecarts-jmeter-migrations/evidence/build-4445025-jmx-generation/README.md) et [inventaire round7](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-frenchtaxesrules-round7/README.md) | vérifier seulement un éventuel périmètre externe nominatif avant de corriger le validateur ; le jeu des 19 JMX est figé et rapporté identique au jeu local `.work\jfull\Tests`, et 18 d'entre eux sont rapportés poussés sur la branche de validation FrenchTaxesRules — aucune réduction JMeter Cur/Fix n'est pour autant mesurée |
| SQL Full-Text (224 cas historiquement associés) | **FACT** : `4442156`, `4442254` et `4442685` sont terminés en échec ; SQL2019/SQL2025 n'achèvent pas la population dans la fenêtre observée. Full-Text installé et service SQL démarré sont prouvés, mais la cause racine reste **UNKNOWN**. Le lien avec 224 cas d'une nouvelle campagne Clienteling reste **UNKNOWN**. | [finding 014](investigations/ecarts-jmeter-migrations/findings/014-sql-fulltext-runtime-4442685.md), [collecte live round5](investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-fulltext-live-4442156-round5/README.md) | diagnostic borné sur image isolée : DMV/services/FDHOST horodatés, attente explicite, `CONTAINSTABLE`, cleanup ; aucune modification d'image partagée |
| InventoryTracking | **TERMINE / VALIDE.** Commit `be3c9ac3` corrige `002-Device_Reassign.jmx` (tag `<hashTree/>` manquant sous TC122). Run réel `4447425` terminé (`partiallySucceeded`) : **1991 tests exécutés** sur Cur et Fix (86/86 de `Device_Reassign` restaurés). Fix (run `6189957`) : 1651 passés, 340 échoués ; Cur (run `6189960`) : 1652 passés, 339 échoués. `TC122` est l'unique écart (Passed en Cur, Failed en Fix). Conformité 100% à la baseline `4440884`. Pour `4447425` spécifiquement, la tâche `Stop Containers` est `succeeded` (lecture directe de la timeline, 2026-09-08) ; une re-collecte round 4 rapportée le 2026-09-09 recoupe les comptes Cur/Fix des builds `4447425`/`4440884`/`4445575` (1991/1991/1905) et l'inventaire JMX Git (32 blobs au `sourceVersion`), mais requalifie le cleanup en `UNKNOWN` de façon générale (grep de log, pas résultat de tâche) — sans contredire le fait spécifique établi pour `4447425` | [finding 017](investigations/ecarts-jmeter-migrations/findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md), [finding 020](investigations/ecarts-jmeter-migrations/findings/020-attestation-campagne-round4-transport-local-candidat.md) | mission InventoryTracking pleinement remplie ; résultats et artefacts archivés ; ne pas présenter le cleanup comme prouvé pour `4440884`/`4445575`/`4432554` |
| InventoryTracking — historique | cause du build initial prouvée ; migration `4de185bb` et correctif `ef3d8703` accessibles ; `4440884` a exécuté Cur/Fix, mais `4444389`, `4444720` et `4444887` n'ont produit aucun résultat JMeter ; `4444700/4444703` ont été annulés volontairement avant JMeter ; `4444887` initialise Cur/Fix puis échoue dans PlatformDeploy faute de package staging ; le candidat transport round7 est revu favorablement sur le mécanisme et ses tests locaux passent ; correction de provenance requise avant queue : distinguer `sourceBuildId=Build.BuildId` et `artifactName=$(componentVersion)_Software`, puis attester les hashes des quatre fichiers réellement transportés ; aucun test PlatformDeploy réel en conteneur n'est encore prouvé | [finding 013](investigations/ecarts-jmeter-migrations/findings/013-inventorytracking-xmlDiff-migration-build-4434070.md), [revue transport round8](investigations/ecarts-jmeter-migrations/evidence/build-5037140-inventorytracking-transport-review-round8/README.md), [revue patch round8](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-inventorytracking-transport-review-round8/README.md) | corriger/revoir la provenance BuildId/artifactName, conserver les hashes MSI/XML effectivement transportés sans exiger un hash d'archive, puis seulement préparer le run isolé |
| InventoryTracking — routage Testing Manager | **FACT :** le job legacy `TestAutos` n'existe que dans le YAML historique et dépend de `Publish`, limité à `master`/`releases/*`. Les YAML de migration `ef3d8703`/`be3c9ac3` l'ont remplacé par une chaîne JMeter conditionnelle ; `4440774` a donc Build vert mais JMeter/TestAutos skipped, tandis que `4440884`/`4447425` ont JMeter sans TestAutos. | [finding 024](investigations/ecarts-jmeter-migrations/findings/024-inventorytracking-legacy-tests-branch-routing.md) | si Testing Manager est requis sur les branches de migration, définir explicitement le contrat de pipeline et prouver un TRX/XML final ; ne pas déduire le verdict legacy du job de soumission |
| Pipeline NuGet JMeter 5224 | chaîne historique statique; Round7 de 14264 télécharge directement Apache JMeter 5.6.3 par job Cur/Fix et vérifie la SHA-512; contenu final de l'image Clienteling et cible runtime restent non prouvés | [preuves pipeline](evidence/azure-devops/pipeline-5224/README.md), [préconditions round5](investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-jmeter-preconditions-round5/README.md), [contrat Round7](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-isolated-pipeline-round7/README.md) | obtenir l'attestation produite après provisionnement Cur/Fix et vérifier image/digest/backup/cleanup |
| Rejeu métier Clienteling | **DIAGNOSTIC AVANCE, rapporté.** Le backup `AUTO_V26_00.bak` (156 663 808 o, SHA-256 `8B95C2BA…`) est matérialisé avec succès dans CI sur agent Windows 2025 (run `4447427`). Une synthèse ultérieure rapporte que le replay a franchi host/SQL/backup/CLI JFrog et atteint `download-packages.ps1` ; le dernier run cité `4452826` échoue sur le téléchargement de packages, avec diagnostic whitelisté vide. Aucun JMeter Cur/Fix n'est prouvé. | [finding 016](investigations/ecarts-jmeter-migrations/findings/016-clienteling-v26-backup-lfs-absent.md), [finding 019](investigations/ecarts-jmeter-migrations/findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md), [finding 022](investigations/ecarts-jmeter-migrations/findings/022-clienteling-v26-replay-jfrog-download-4452826.md) | relire directement `4452826`/`4452739` et identifier le premier message non sensible du CLI avant toute correction ou relance |
| Rejeu métier FrenchTaxesRules V26 | **JMeter rapporté, état contradictoire à revérifier.** `4448787` est rapporté avec Cur/Fix exécutés (253 tests chacun, 51 échecs communs) ; une autre synthèse rapporte `4452567` bloqué avant JMeter sur l'image Docker puis `4452790` bloqué avant JMeter sur l'absence de `*.cy2px`. Ces sources restent non revérifiées et ne permettent pas de conclure sur le résultat final V26 | [finding 018](investigations/ecarts-jmeter-migrations/findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md), [finding 021](investigations/ecarts-jmeter-migrations/findings/021-frenchtaxesrules-v26-run-4452790-cy2px.md) | relire directement les timelines/logs `4448787`, `4452567` et `4452790`, puis vérifier le producteur des `*.cy2px` avant tout nouveau rejeu |
| FrenchTaxesRules V22/V23 | **Rapporté, non revérifié.** V22 Cur/Fix et les campagnes V22 seraient verts dans `4453591` après relèvement Core/Common/Identity ; V23 Cur serait vert, mais V23 Fix s'arrêterait avant JMeter sur `sectionGroupName` | [finding 023](investigations/ecarts-jmeter-migrations/findings/023-frenchtaxesrules-v22-v23-packaging-validation-20260910.md) | relire les runs/paramètres et la ref V23 Identity seule ; ne pas retenir de minima individuels ni compter V23 comme échec JMeter avant preuve |
| Livrables globaux PBI | tableau de suivi rempli ; synthèse de reporting produite le 2026-09-08 ; notification Ludo/Lydie à confirmer | [reporting/](reporting/2026-09-08-synthese-onenote-pbi.md) | confirmer la notification et le processus PR/mail cadré par LBAU |
| Décisions et suites | FACT : décisions 1, 2 et 6 rendues ; 4 à investiguer ; 5 fixe validation isolée avant décision de publication avec versions/destination ; Products reste ouvert | [decisions/README.md](decisions/README.md) | relever les minima V22 Fix ; mesurer le delta BeforeMigration, corriger et régénérer ; valider les packages en isolation. Aucune publication partagée autorisée |

## Dépôts de travail

Les clones Git et worktrees ne sont **pas** dans ce dépôt : ils restent à leur emplacement d'origine,
avec leur état Git propre. Emplacements exacts et états relevés dans
[EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md).

Deux points à connaître avant d'y toucher :

- `Y2_Tools_Jmeter_Workflow` porte une **modification locale de l'utilisateur** dans `azure-pipeline.yml`
  (14 ajouts, 3 suppressions au snapshot du 2026-09-06). À préserver.
- `Y2_Plugins_FrenchTaxesRules` est signalé **pollué** depuis le 2026-09-07 après un checkout interrompu,
  et sa lecture Git échouait sur `dubious ownership`. Le reclonage propre tenté le 2026-09-08 a échoué
  avec Git exit 128 sans créer de worktree ; à reprendre après rétablissement de l'accès.

Toujours exécuter `git status --short --branch` dans le dépôt concerné avant de travailler :
les états consignés sont des snapshots, pas des verrous.

## Faits établis à ne pas rouvrir sans preuve contraire

- Le défaut `EscapeJdbcDate` inverse mois et jour pour certaines dates ISO apostrophées ; la correction durable passe par AutoTest.Api, Console, l'outil de migration, la régénération puis le rejeu.
- Mise à jour locale 2026-09-06 : correctif local compilé et génération JMX validée sur six fixtures ; comparaison avant/après conservée dans `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-jmx-date-before-after/`. La validation Console a ensuite été acquise, voir les compléments ci-dessous. Docker et rejeu métier restent non validés.
- Dépendances Console vérifiées localement : `Svn 1.0.4` et `XmlDiff 1.0.5` trouvés, mais `XmlDiffPatch.View` garde un PublicKeyToken différent de la référence du projet ; compilation Console `UNKNOWN` et non relancée.
- `ExpectedValue=-1` désactive le contrôle du nombre de lignes, pas l'exécution SQL ni les erreurs techniques.
- Les codes Console `-1` initiaux ont été résolus : chemins trop longs et input.xml mal placé. Console officielle avec substitution de l'API validée sur six fixtures puis Export_Run ; recompilation Console et packaging non validés.
- Les soumissions `TestAutos` acceptées ne prouvent pas le résultat aval.
- SQL Full-Text appartient aux images SQL de base consommées par le workflow JMeter ; son absence ne doit pas être corrigée au hasard dans le dépôt consommateur.
- Les snapshots sous `investigations/ecarts-jmeter-migrations/sources/` sont des preuves, pas des branches de correction.
- Rapporté le 2026-09-09, non revérifié : sur FrenchTaxesRules V26, l'incident `Move-Item Access denied` du build `4447926` s'est révélé transitoire après rejeu identique réussi ; ne pas le corriger en dur (`Copy-Item`) sans preuve de cause. Le transport local vers un déploiement piloté par manifest doit contenir exactement les fichiers du manifest, dans un sous-dossier dédié, provenance conservée. Détail dans [finding 018](investigations/ecarts-jmeter-migrations/findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md) et la [section 6 du guide de dépannage](documentation/guides/DEPANNAGE_JMETER.md#6-leçons-opérationnelles-rapportées-audit-bw3-et-frenchtaxesrules-v26-2026-09-09).

La formulation complète et les preuves sont dans le [handoff canonique](investigations/ecarts-jmeter-migrations/HANDOFF.md) et le [plan de correction](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md).

## Principaux `UNKNOWN` ou décisions manquantes

Prochaine démarche : revue du brouillon selon le point de pause du handoff et le [protocole legacy/JMeter](documentation/guides/PROTOCOLE_INVESTIGATION_ECARTS_LEGACY_JMETER.md), déjà appliqué jusqu'aux validations locales et à la préparation du rejeu. Ne pas recommencer ces validations sans nouveau motif.

Précautions ajoutées le 2026-09-06 à la demande utilisateur : NuGet d'essai exclusivement en artefacts de pipeline, aucun push vers un feed partagé ; Docker local ou en artefact de préférence, publication éventuelle sous une identité dédiée après validation de sa destination. La section 0 du protocole couvre aussi triggers aval, ressources partagées, données et nettoyage ciblé. Ces règles sont documentées, leur application sur un run n'a pas encore été vérifiée.

- package/version/hash effectivement publiés et consommés par Console, migration et image JMeter ;
- contenu exact du NuGet dans l'image Docker finale, faute d'inspection directe ;
- comparabilité complète de plusieurs résultats legacy et JMeter ;
- mécanisme propriétaire de transport/montage des fixtures d'images Clienteling ;
- versions minimales exactes à retenir pour FrenchTaxesRules V22 Fix (relèvement décidé), périmètre du service Clienteling Products et propriétaire exact de certains correctifs d'autorisation ;
- état courant des ressources Azure DevOps depuis les dernières vérifications datées ; l'authentification
  CLI/profil local et la lecture navigateur ont échoué dans la reprise du 2026-09-08 ;
- vérification indépendante des runs, pushs et refs rapportés par les
  [synthèses de pause du 2026-09-08](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/README.md) :
  ils ne sont soutenus que par ces documents. Note : le bug de `002-Device_Reassign.jmx` est résolu
  (balise `<hashTree/>` manquante restaurée au commit `be3c9ac3`, validé sur run `4447425`) et la
  disponibilité de l'objet LFS Clienteling V26 est prouvée (run `4447427`, 156 Mo).
- vérification indépendante du build `4448787` rapporté le 2026-09-09 (FrenchTaxesRules V26 : JMeter
  Cur/Fix exécutés, 253 tests chacun, 51 échecs communs) : ce chiffre n'est soutenu que par le document
  rapporté dans [finding 018](investigations/ecarts-jmeter-migrations/findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md) ;
  regroupement causal des 51 échecs communs, non encore fait.
- vérification indépendante des builds `4452567` et `4452790` rapportés le 2026-09-09 pour FrenchTaxesRules
  V26 : image Docker/manifest, tags consommés, commit `bd3688e4…`, push annoncé et absence des `*.cy2px`
  restent à confirmer par lecture directe ; voir [finding 021](investigations/ecarts-jmeter-migrations/findings/021-frenchtaxesrules-v26-run-4452790-cy2px.md).
- vérification indépendante des push `5138407`/`5138712` et des builds `4449477`/`4449640` rapportés
  le 2026-09-09 pour Clienteling V26 (`Product.Version`/`BuildPlatform`, correctifs `OutputFiles` et
  `TestCampaign` de `GenerateJmx`) : soutenus uniquement par le document rangé dans
  [finding 019](investigations/ecarts-jmeter-migrations/findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md) ;
  résultat du rejeu sur HEAD `28f71268…` (GenerateJmx, JMeter Cur/Fix) non encore obtenu.
- vérification indépendante de la séquence Clienteling rapportée dans les runs `4451986` à `4452826`
  (tokenisation host/SQL, staging backup, CLI JFrog et blocage `download-packages.ps1`) : aucun
  identifiant, package fautif ou JMeter Cur/Fix n'a été relu directement ; voir [finding 022](investigations/ecarts-jmeter-migrations/findings/022-clienteling-v26-replay-jfrog-download-4452826.md).
- vérification indépendante de la re-collecte round 4 (4 builds `4447425`/`4440884`/`4445575`/`4432554`,
  collecteur `scripts/invoke_bw3_collector.py`) rapportée le 2026-09-09 : les comptes Cur/Fix et
  l'inventaire JMX Git convergent avec ce qui était déjà versionné, mais aucune lecture Azure DevOps
  n'a été refaite par ce processus. Voir [finding 020](investigations/ecarts-jmeter-migrations/findings/020-attestation-campagne-round4-transport-local-candidat.md).
- le gabarit candidat de transport local de package (même finding 020) reste sans couple cible : tous
  ses paramètres (`sourceBuildId`, `artifactName`, `packageVersion`, `manifestPath`,
  `localPackageRoot`, `deploymentTarget`, `sourceCommit`) sont `UNKNOWN` tant qu'un prochain couple
  n'est pas sélectionné ; pertinent pour la [décision 4](decisions/README.md#4-qui-transporte-les-fixtures-dimages-clienteling-et-vers-quel-chemin) sans la trancher.

Ne pas convertir ces points en actions de correction sans preuve nouvelle ou décision explicite.
