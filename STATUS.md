# État consolidé — WI-2222897

**Snapshot du 2026-09-08.** Ce fichier ne contient que l'**état courant**. Les 27 sections datées
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

## Synthèse

État par domaine au **2026-09-08**. Chaque ligne renvoie à la preuve qui la soutient.

| Domaine | État | Preuve canonique | Suite sûre |
|---|---|---|---|
| Périmètre et critères du WI | documentés | [README.md](README.md), [synthèse du PBI](documentation/context/PBI_2222897_synthese_visio_Ludo.md) | relire le work item live si une décision dépend de son état actuel |
| Procédure de migration | documentée, valeurs historiques signalées | [documentation/README.md](documentation/README.md) | revalider versions, chemins et prérequis avant exécution |
| Inventaire plugins/branches | 19 couples recalculés depuis les dépôts le 2026-09-03 ; bilan intermédiaire intégré le 2026-09-07 ; FACT : utilisateur fixe Clienteling à master, releases/V6, releases/V7, releases/V8 le 2026-09-08 | [documentation/tracking/](documentation/tracking/README.md), [décision 1](decisions/README.md) | appliquer ce périmètre au prochain suivi ; la décision ne prouve pas la migration |
| Diagnostic des échecs | 9 des 9 couples suivis classés `TERMINE` ; chaque cas non passé est rattaché à une cause prouvée. InventoryTracking est validé avec couverture complète restaurée | [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) | implémenter les causes prouvées ; ne pas rouvrir un verdict sans preuve contraire |
| Comparaison legacy/JMeter | baseline V26 obtenue pour FrenchTaxesRules (253 scénarios) et Clienteling (2 131) ; **aucune baseline comparable pour V21–V25** | [matrice legacy](investigations/ecarts-jmeter-migrations/cases/LEGACY_COMPARISON_MATRIX.md) | ne reclasser qu'à scénario, contrat, versions, données et environnement identiques |
| Générateur JMX (4 défauts) | FACT : Console candidate 2.0.43 du build 4445025/5037277 embarque la DLL API attendue et génère réellement les 19 plans source au code 0 ; l’inventaire nominatif 10 LegacyServices + 9 WebServices correspond à 19 sorties ; le compteur fixe 32 provient du commit de validateur c5aebe9 sans inventaire source ; aucun moteur JMeter lancé | [preuve génération 4445025](investigations/ecarts-jmeter-migrations/evidence/build-4445025-jmx-generation/README.md) et [inventaire round7](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-frenchtaxesrules-round7/README.md) | vérifier seulement un éventuel périmètre externe nominatif avant de corriger le validateur ; le jeu des 19 JMX est figé et rapporté identique au jeu local `.work\jfull\Tests`, et 18 d'entre eux sont rapportés poussés sur la branche de validation FrenchTaxesRules — aucune réduction JMeter Cur/Fix n'est pour autant mesurée |
| SQL Full-Text (224 cas historiquement associés) | **FACT** : `4442156`, `4442254` et `4442685` sont terminés en échec ; SQL2019/SQL2025 n'achèvent pas la population dans la fenêtre observée. Full-Text installé et service SQL démarré sont prouvés, mais la cause racine reste **UNKNOWN**. Le lien avec 224 cas d'une nouvelle campagne Clienteling reste **UNKNOWN**. | [finding 014](investigations/ecarts-jmeter-migrations/findings/014-sql-fulltext-runtime-4442685.md), [collecte live round5](investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-fulltext-live-4442156-round5/README.md) | diagnostic borné sur image isolée : DMV/services/FDHOST horodatés, attente explicite, `CONTAINSTABLE`, cleanup ; aucune modification d'image partagée |
| InventoryTracking | **TERMINE / VALIDE.** Commit `be3c9ac3` corrige `002-Device_Reassign.jmx` (tag `<hashTree/>` manquant sous TC122). Run réel `4447425` terminé (`partiallySucceeded`) : **1991 tests exécutés** sur Cur et Fix (86/86 de `Device_Reassign` restaurés). Fix (run `6189957`) : 1651 passés, 340 échoués ; Cur (run `6189960`) : 1652 passés, 339 échoués. `TC122` est l'unique écart (Passed en Cur, Failed en Fix). Conformité 100% à la baseline `4440884`. Conteneurs arrêtés et nettoyés | [finding 017](investigations/ecarts-jmeter-migrations/findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md) | mission InventoryTracking pleinement remplie ; résultats et artefacts archivés |
| InventoryTracking — historique | cause du build initial prouvée ; migration `4de185bb` et correctif `ef3d8703` accessibles ; `4440884` a exécuté Cur/Fix, mais `4444389`, `4444720` et `4444887` n'ont produit aucun résultat JMeter ; `4444700/4444703` ont été annulés volontairement avant JMeter ; `4444887` initialise Cur/Fix puis échoue dans PlatformDeploy faute de package staging ; le candidat transport round7 est revu favorablement sur le mécanisme et ses tests locaux passent ; correction de provenance requise avant queue : distinguer `sourceBuildId=Build.BuildId` et `artifactName=$(componentVersion)_Software`, puis attester les hashes des quatre fichiers réellement transportés ; aucun test PlatformDeploy réel en conteneur n'est encore prouvé | [finding 013](investigations/ecarts-jmeter-migrations/findings/013-inventorytracking-xmlDiff-migration-build-4434070.md), [revue transport round8](investigations/ecarts-jmeter-migrations/evidence/build-5037140-inventorytracking-transport-review-round8/README.md), [revue patch round8](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-inventorytracking-transport-review-round8/README.md) | corriger/revoir la provenance BuildId/artifactName, conserver les hashes MSI/XML effectivement transportés sans exiger un hash d'archive, puis seulement préparer le run isolé |
| Pipeline NuGet JMeter 5224 | chaîne historique statique; Round7 de 14264 télécharge directement Apache JMeter 5.6.3 par job Cur/Fix et vérifie la SHA-512; contenu final de l'image Clienteling et cible runtime restent non prouvés | [preuves pipeline](evidence/azure-devops/pipeline-5224/README.md), [préconditions round5](investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw3-plugins/evidence/local-2026-09-08-jmeter-preconditions-round5/README.md), [contrat Round7](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-isolated-pipeline-round7/README.md) | obtenir l'attestation produite après provisionnement Cur/Fix et vérifier image/digest/backup/cleanup |
| Rejeu métier Clienteling | **DIAGNOSTIC AVANCE, rapporté.** Le backup `AUTO_V26_00.bak` (156 663 808 o, SHA-256 `8B95C2BA…`) est matérialisé avec succès dans CI sur agent Windows 2025 (run `4447427`). Suite rapportée le 2026-09-09 : `Product.Version`/`BuildPlatform` rétablis, `GenerateJmx` atteint puis débloqué de deux fautes successives (`OutputFiles` manquants du manifeste, `TestPlan` fourni à la place d'un `TestCampaign`) ; HEAD isolée `28f71268…`. Aucun JMeter Cur/Fix encore atteint | [finding 016](investigations/ecarts-jmeter-migrations/findings/016-clienteling-v26-backup-lfs-absent.md), [finding 017](investigations/ecarts-jmeter-migrations/findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md), [finding 019](investigations/ecarts-jmeter-migrations/findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md) | relancer 14264 sur `28f71268…` (apiBuildId 4444962, consoleBuildId 4445025, consoleDefinitionId 2641) et vérifier GenerateJmx puis JMeter Cur/Fix |
| Rejeu métier FrenchTaxesRules V26 | **JMETER EXECUTE (rapporté, non revérifié).** Blocage `Checkpoint.Authorization` résolu sur déf. `2054` (commit `b82c5452`). Run `4447508` avait échoué à `Launch Y2 deployment` (package non présent sur staging). Un document reçu le 2026-09-09 rapporte que le transport local a été raffiné (sous-dossier `localPackageRoot` limité aux 4 fichiers du manifest) et que le build `4448787` (`partiallySucceeded`) a exécuté JMeter Cur **et** Fix réellement : 253 tests chacun, **51 échecs communs strictement identiques** Cur/Fix ; `Export_Run` TC08-10 et `DocumentSignature_SignOne` TC02 absents de ces 51 échecs. Aucune lecture Azure DevOps indépendante n'a revérifié `4448787` dans ce processus | [finding 017](investigations/ecarts-jmeter-migrations/findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md), [finding 018](investigations/ecarts-jmeter-migrations/findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md) | revérifier `4448787` par lecture directe AzDO, puis regrouper les 51 échecs communs par cause réelle via les détails REST des résultats (pas test par test) |
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
- vérification indépendante des push `5138407`/`5138712` et des builds `4449477`/`4449640` rapportés
  le 2026-09-09 pour Clienteling V26 (`Product.Version`/`BuildPlatform`, correctifs `OutputFiles` et
  `TestCampaign` de `GenerateJmx`) : soutenus uniquement par le document rangé dans
  [finding 019](investigations/ecarts-jmeter-migrations/findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md) ;
  résultat du rejeu sur HEAD `28f71268…` (GenerateJmx, JMeter Cur/Fix) non encore obtenu.

Ne pas convertir ces points en actions de correction sans preuve nouvelle ou décision explicite.
