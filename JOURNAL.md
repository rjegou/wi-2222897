# JOURNAL — WI-2222897

## 2026-09-08 — Mise en dépôt Git et réorganisation

Le workspace OneDrive (~8,6 Go, non versionné) est rapatrié dans un dépôt Git dédié
`C:/clones/wi-2222897`. **Le dossier d'origine n'a pas été modifié** : l'opération est une copie
sélective, pas un déplacement.

**Périmètre importé** — 1 869 fichiers, 59,3 Mo : la couche documentaire (Markdown, index, manifestes,
empreintes, CSV, JSON, scripts, PDF sources). Exclus : clones Git (1,7 Go), snapshots `sources/`
(1,9 Go), artefacts bruts de preuve (2,9 Go), sorties des sessions parallèles (2,1 Go),
distributions tierces, profils Azure CLI jetables, traces d'orchestration.

**Sécurité au passage** — écartés du dépôt : `git-askpass-worker2-r3.cmd`/`.ps1` (helpers
d'identifiants), `.v22-isolated-publish/` (clone égaré de 152 Mo), deux profils Azure CLI déposés dans
les preuves, les copies de `Generate_CSharp_Tablet.cmd` (mot de passe en dur préexistant dans
`Y2_Plugins_InventoryTracking`, à signaler au propriétaire du dépôt), et un PDF personnel hors
périmètre présent dans `archive/out-of-scope/`. Aucun secret n'a été ouvert ni copié.

**Travail sauvé avant tout nettoyage** — le contrôle Git des 13 clones a révélé **six worktrees sales
dont le contenu n'existait nulle part ailleurs** : les 4 corrections du générateur JMX et leurs 3
fichiers de tests, le correctif Full-Text des Dockerfiles SQL, le patch de diagnostic Full-Text, les 5
métadonnées Clienteling, la propagation d'erreur PlatformDeploy, et la modification utilisateur de
`azure-pipeline.yml`. Tout est extrait dans [patches/](patches/README.md), 76 Ko, avec branche, `HEAD`
et mode de réapplication. Sans cette extraction, supprimer les clones détruisait les corrections
couvrant 342 cas de test.

Le worktree `Y2_Plugins_FrenchTaxesRules` (621 fichiers modifiés, 237 non suivis) a été identifié
comme résidu d'un checkout interrompu et non versionné, sauf `azure-pipelines.wi2222897-v22-preflight.yml`
conservé sous `replay-prep/2026-09-07-v22-preflight-yaml-retrouve/`. Son SHA-256
`d1b53e1f2a6e7ed5c2b0450a957ac9693d4295064190fe035a69a977523646f4` correspond exactement au hash que
`STATUS.md` signalait comme non reliable à un commit : le fichier est désormais retrouvable.

**Défauts d'organisation corrigés**

1. `STATUS.md` : les 27 sections datées, non ordonnées et partiellement supersédées, sont sorties vers
   `archive/status-history-2026-09.md` sans perte. `STATUS.md` ne contient plus que l'état courant,
   dont une table « Synthèse » réécrite et une table « Où lire quoi ».
2. Index des preuves régénéré : il couvre les **178 dossiers** au lieu d'en omettre 74, avec le sujet
   tiré du README de chaque dossier et le volume resté hors dépôt. Il signale aussi les 43 dossiers
   dont le README n'a pas de titre exploitable.
3. `decisions/README.md` créé : registre des 6 arbitrages bloquants, jusque-là dispersés dans un plan
   de 28 Ko, une matrice et ce journal.
4. `EXTERNAL-ARTIFACTS.md` créé : emplacement, poids, commits de reconstitution et verdict de
   conservation de tout ce qui reste dehors.
5. `reporting/` créé ; la synthèse OneNote y est déplacée depuis `documentation/context/`.
6. `.gitignore`, `README.md`, `AGENTS.md` et `CLAUDE.md` réécrits pour la nouvelle réalité.
7. Liens vérifiés : 609 liens relatifs, **0 cassé dans la documentation**. Les 19 restants sont des
   liens déjà cassés à l'intérieur de fichiers `resources/Readme.md` livrés par l'outillage Cegid.

**Non fait** — aucun push : le remote est un dépôt GitHub privé **personnel**, ce qui est une question
de gouvernance des données internes à trancher avant publication. Le nettoyage du dossier OneNote
d'origine est traité séparément.

## 2026-09-08 — Point d'avancement et synthèse pour la page OneNote de suivi

Lecture transverse du dossier WI (README, AGENTS, STATUS, TASKS, RESOURCES, JOURNAL, matrices, CORRECTION_PLAN, findings 006/013, tracking et sorties BW du 2026-09-08) pour produire un point d'avancement consolidé, puis une synthèse destinée à la page OneNote de suivi de la PBI, lisible par le PO et le lead dev.

**Produit** — [reporting/2026-09-08-synthese-onenote-pbi.md](reporting/2026-09-08-synthese-onenote-pbi.md), indexée dans `reporting/README.md`. Le document est rédigé en complément du contenu OneNote existant (outil modifié v26/v22-25/<=v21, consigne LBAU mail + PR + déprovisionnement après merge, tableau rempli, builds InventoryTracking en échec, comparatif Clienteling déclaré impossible, remarques de Ludo sur Cur/Fix) et ne le répète pas.

**Corrections de lecture portées à la page** — les 485 échecs Clienteling V26 sont reclassés par première cause (224 Full-Text, 105 imputables au générateur JMX, le reste réparti scénario/packaging/fixtures) ; FrenchTaxesRules V22 Fix compte 174 refus et non 138 ; les libellés Cur/Fix de V7/V25 sont inversés dans la capture initiale ; V23 Fix et Clienteling V22/V23 Fix n'ont exécuté aucun test ; le comparatif legacy est devenu possible par les TRX de `Y2-TSTAUTOXXPG2` et non par les branches non migrées ; le Full-Text n'est pas absent mais sa population n'aboutit pas dans la fenêtre de 90 s du probe.

**Décisions listées comme attendues du PO/lead dev** — ligne de release Clienteling parmi quatre branches à plages chevauchantes, support de la pile FrenchTaxesRules V22 Fix, support de `ClientelingProductsService.svc`, propriétaire du transport des fixtures d'images, autorisation de republication de la chaîne API/Console/package migration, arbitrage du bug de précédence de `BeforeMigration.ps1` (thread PR 3573422).

Aucune action distante, aucun pipeline, aucune modification de code ou de preuve dans cette session. Seuls la synthèse, l'index `documentation/context/README.md` et cette entrée ont été écrits.

## 2026-09-07 — Worker 2 round3 — patch diagnostic Full-Text local

**FACT** — build `4442685` est terminal `failed` au commit `e3b674b...`; SQL2019 et SQL2025 restent à `PopulateStatus=1` jusqu’au timeout de 90 secondes et n’atteignent pas `CONTAINSTABLE`.

**FACT** — patch local reviewable du YAML `worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml` : diagnostics console bornés pour propriété Full-Text, FD Launcher/fdhost, DMV de population/catalogue/batches/ranges, crawl logs/ERRORLOG ciblés et espace disque ; collecte tolérante aux erreurs ; suppression et absence du conteneur vérifiées. Dockerfiles et probe inchangés.

**Validation** — worktree propre avant édition ; `git diff --check` passe, les deux scripts inline extraits passent le parseur PowerShell, et aucun push/JFrog/Artifactory/promotion/tag n’est ajouté. Aucun run, publication distante ou rejeu métier effectué. Cause moteur et propagation aux 224 cas Clienteling restent UNKNOWN.

## 2026-09-07 — Worker 2 round7 — clôture du préflight borné 4442696

Lecture directe de la collecte round25 : le run `4442696` est `completed/succeeded` au commit `68f1f7a8...`. Image digestée acquise, checkout skipped, assertions image/OS/architecture/target-scope/mounts/réseaux/ports PASS, `mounts=0;dangerous=0`, attestation PASS, conteneur créé puis cleanup `containerPresentAfterRemove=False`. Aucun métier/publication. Round24 `inProgress/timeout` est supersédé. `Config.Volumes`, ID complet, provenance du mount historique `4442225` et couverture des futurs jobs restent UNKNOWN. La reproduction locale d’un faux comptage null n’est pas convertie en fait runtime historique.

## 2026-09-07 — Worker 2 round6 — suivi final partiel du run 4442696

Lecture directe de `evidence/azure-devops-french-taxes-rules-v22-worker1-round24/README.md` et `timeline-expurgated.txt`. Le run unique `4442696` a exécuté le commit `68f1f7a8...` avec le YAML `659DE89E...`. Initialize/login ont réussi, checkout est skipped, l’inspection reste inProgress à 0 %, le hash final est pending et le run dépasse le timeout de 10 minutes au snapshot 20:08 UTC. Aucun métier/publication n’est prouvé. `Config.Volumes`, mounts, sous-verdicts, identité et cleanup restent UNKNOWN. Le timeout statique et le `finally` conditionné à `$created` ne prouvent pas le nettoyage effectif. Aucune action distante ou métier effectuée.

## 2026-09-07 — Worker 2 round4 — réconciliation `0D2D...` / `659DE...`

Reconstruction locale du résultat Worker 1 round23 : l’application du seul filtre null au YAML exact `DB8ED1...` produit exactement `0D2D781CF054CD4644C46552AB610544282D4CDD805EDCE9D197F66C151A0D5B`, en LF comme dans la forme source. Le candidat `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2` contient en plus la projection scrubbed `Config.Volumes`/mounts ; il est le seul candidat réellement testé et approuvé. Tests de réconciliation et candidat PASS. Python/OpenSSL Worker 1 a rétabli une lecture Azure DevOps HTTP 200 ; Schannel n’est plus considéré comme blocage global. Aucun accès distant ou métier effectué par Worker 2.

## 2026-09-07 — Worker 2 round3 — matérialisation du candidat V22 null-safe

Relecture locale du YAML exact du commit `44070560...` avec SHA-256 `DB8ED1DD...`. Le candidat round21 initial a été rejeté après reproduction du cas `inspection.Mounts=$null`, qui produisait un pseudo-mount. Matérialisation du candidat null-safe dans `replay-prep/2026-09-07-v22-round21-review/`, hash `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`, avec diff complet et test reproductible indexés dans la preuve Worker 2 round3. Tests PASS : syntaxe 0, null mounts 0, deux mounts, RW conservé, masquage, whitelist et cleanup inchangés. Aucun accès distant, Docker, queue ou métier. Schannel/TLS reste un échec observé de lecture Worker 1, non une impossibilité définitive.

## 2026-09-07 — Consolidation Worker 3 — InventoryTracking XmlDiff

Lecture de la collecte primaire Worker 2 round2 et mise à jour des documents canoniques, sans modification de preuve brute, dépôt, pipeline, branche, PR ou système distant. Le build `4434070` est distingué de `refs/heads/master` : il consomme la branche `InventoryTracking_Migration_AutoTest_On_master` au commit `4de185bb...`. La cause immédiate VSBuild est établie (`Cegid.Retail.XmlDiff` non résolu, `MSB3245`, quatre `CS0103`); les stages JMeter sont skipped. Le mécanisme exact package/restore/template, le correctif, les PR, le WI live et les campagnes JMeter restent UNKNOWN. Le master `4435986` réussi n'est pas une validation JMeter car son YAML ne déclare pas `TI_Jmeter_V26`.

Création de [finding 013](investigations/ecarts-jmeter-migrations/findings/013-inventorytracking-xmlDiff-migration-build-4434070.md), indexation de la collecte round2 et du suivi daté, ajout de la ligne InventoryTracking dans la matrice. L'ancien blocage global d'accès Azure DevOps est supersédé seulement pour les faits couverts par Worker 2; les échecs TLS/profil/navigateur des autres processus restent historiques. Les deux profils temporaires non nettoyés sont consignés dans `RESOURCES.md`. Aucun pipeline lancé.

## 2026-09-07 — Vérification réelle JMeter 5.6.3 de XPathAssertion

Relecture bornée de `evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/` et de ses artefacts, sans réexécuter les validations acquises et sans modifier code ou preuve brute. FACT : ZIP officiel présent, checksum SHA-512 `MATCH`, runtime JMeter 5.6.3 code `0`, harnesses réels code `0`. Avec `namespace=false`, `//Fault` ne matche pas un Fault SOAP préfixé mais matche un Fault non préfixé ; les variantes de préfixe SOAP sont également non matchées. Avec `namespace=true`, mapping SOAP et `//soap:Fault`, les préfixes `soap` et `env` du même URI matchent, l'absence de Fault ne matche pas et le mauvais namespace testé est rejeté. `local-name()` est trop permissif.

Conséquence documentaire : `CleanXpath` corrige l'expression invalide `//`, mais `//Fault` reste insuffisant pour la sémantique SOAP des JMX actuels. Le générateur doit être étudié pour une configuration namespace-aware ciblée, sans conclure à une modification globale avant inventaire SOAP 1.1/1.2 et autres XPath. Mise à jour de `evidence/.../README.md`, `evidence/README.md`, `findings/README.md`, création de [finding 012](investigations/ecarts-jmeter-migrations/findings/012-jmeter-5-6-3-xpath-namespace.md), puis mise à jour de `CORRECTION_PLAN.md`, `HANDOFF.md` et `STATUS.md`. UNKNOWN conservés : propagation API/Console/package/migration, régénération complète, SOAP 1.2 et rejeu métier.

## 2026-09-07 — Conseil de Ludo : packaging V22 supérieur

Investigation en lecture seule : cas exact FrenchTaxesRules releases/V5 V22, build 4429167, 0 échec Cur / 174 refus Fix. Packaging 22.0.23 retrouvé via Git/Azure DevOps puis confirmé dans JFrog production avec le token fourni par l'utilisateur, sans exposition du secret. Manifeste lu ; métadonnées des ZIP et présence du trio candidat vérifiées. Aucun ZIP téléchargé, test métier, déploiement ou changement de dépôt réalisé.

Mise à jour documentaire demandée : complément canonique dans [finding 004](investigations/ecarts-jmeter-migrations/findings/004-french-taxes-rules-v21-v23-build-4429167.md), nouvelle synthèse de collecte datée et routage evidence/HANDOFF/STATUS. Recommandation : comparer le trio à la pile Fix historique à contrat constant ; la compatibilité avec le plugin 22.0.6.478 et la réussite métier restent UNKNOWN. Prompt opérateur transmis ; aucune validation prétendue. Aucune ressource temporaire créée ou à dépolluer.

Staging temporaire court autorisé créé sous `C:\Users\jegour\AppData\Local\Temp\wi2222897-r7-b0e05dd2`. Console officielle originale/corrigée a généré les JMX depuis `ItemSearch_Keywords.xml`, code 0; SQL TC02 avant/après et XPath parsés. RemoveSpecialCharsForXQuery corrigée (`&` avant les autres entités), compilée et validée par 4 tests publics, avec non-régression CleanXpath/Unicode. Les quatre plans source→JMX XML restent à régénérer.

Round 8 : nouveau staging court `C:\Users\jegour\AppData\Local\Temp\wi2222897-r8-40d79ec7`. Console originale/corrigée a généré 4/4 plans legacy Mobility/ItemSearch (code 0); 682 SQL et 185 XPath parsés. Les JMX corrigés échappent l'XML interne et émettent `//Fault/...`; aucune exécution JMeter, SQL, HTTP ou migration.

Round 9 : contrôle des options XPath effectives (`namespace=false`, `tolerant=false`, `validate=false`, `whitespace=false`) et réponse SOAP synthétique. XML local : `//Fault` sélectionne 0 nœud namespace-aware, `//soap:Fault` sélectionne 1. Le moteur JMeter complet n'est pas disponible; stub uniquement, Java 23.0.1 vs cible 21. Aucun changement supplémentaire CleanXpath.

Round 10 : acquisition officielle Apache JMeter 5.6.3 tentée dans un staging temporaire; Invoke-WebRequest et curl échouent TLS (`SEC_E_NO_CREDENTIALS`). Aucun fichier acquis, installation système ou changement Java/PATH.

## 2026-09-07 — Intégration du bilan intermédiaire de la semaine précédente

Le bilan fourni par l'utilisateur a été intégré dans `documentation/tracking/2026-09-07-bilan-intermediaire-semaine-precedente.md` et routé depuis l'index du suivi et `STATUS.md`. Il recense 18 couples dépôt/branche/version déclarés `InProgress` pour FrenchTaxesRules, InventoryTracking et Clienteling, avec les builds, PR et échecs rapportés. La date exacte des observations n'étant pas fournie, elle est conservée comme inconnue ; aucun lien Azure DevOps n'a été revalidé en live et aucun dépôt, système distant ou artefact brut n'a été modifié.

## 2026-09-07 — CleanXpath validé hors ligne

`CleanXpath` remplace le préfixe `soap:Fault` par `Fault`, en conservant `EscapeJdbcDate` et `FixSqlUnicodeValue`; `RemoveSpecialCharsForXQuery` n'a pas été touchée. Compilation isolée code 0, DLL SHA-256 `5D7974252D1F7856A23DBBC6FACE10C751822434F7EB9CFFFE69E842EDAB4B15`. Tests production : Fault nu, prédicat, descendants, témoins non-Fault et sélections XML SOAP namespace-aware PASS; Unicode 9 vecteurs PASS. Source legacy retrouvée, mais l'ancien harness Unicode consommait un JMX déjà transformé : génération intégrée complète depuis XML encore UNKNOWN. Round4 draft indexé : préflight seulement, runner substitué, aucune isolation SQL/IIS attestée, Java23 vs Java21 inconnue.

Tentative génération intégrée Console depuis `ItemSearch_Keywords.xml` : bootstrap réussi puis `PathTooLongException` dans `JmeterGenerator.CloneDirectory`, avant JMX. Staging neuf confiné au workspace; aucun contournement `C:\temp`/`subst`, aucune exécution métier. RemoveSpecialCharsForXQuery reste non traitée tant que la génération source n'est pas acquise.

## 2026-09-05 — Limite de preuve sur l’embarquement du NuGet dans l’image

### Constat

La vérification ne permet pas d’affirmer directement que le `.nupkg` est présent dans l’image Docker finale. Elle établit seulement la chaîne prévue :

1. `DownloadPipelineArtifact@2` télécharge l’artefact NuGet ;
2. le job copie `Y2.Tools.Jmeter.Workflow.<BuildNumber>.nupkg` vers `Docker/Y2-JMeter/Y2.Tools.Jmeter.Workflow.zip` ;
3. le `Dockerfile` fait `COPY` de ce `.zip`, puis `Expand-Archive` vers `C:/`.

Le run historique 4373772 montre les tâches `Download nuget`, `Copy Y2-Tools-JMeter-Workflow`, `Docker build image` et `Test Docker Image` en succès. Cela prouve l’exécution des étapes, pas la présence vérifiée d’un fichier ou d’un hash dans l’image finale. **Preuve directe : UNKNOWN.**

La branche `sandbox/tests_rje` désactive actuellement les stages Docker pour éviter tout push d’image. Pour obtenir la preuve manquante sans publication, il faudra construire l’image localement dans le même job que la vérification, lancer un contrôle dans le conteneur (présence du contenu sous `C:\Tools`, idéalement hash/version), puis ne pas exécuter `JFrogDocker@1`.

## 2026-09-05 — Préparation d’une branche d’essai sans publication

### État

**PRÊT À EXÉCUTER —** la branche `sandbox/tests_rje` a été créée dans l’UI depuis `master` au commit `4db2dcdab647249de3cdc27eadaf15a158b3a26a`, puis le YAML sécurisé a été poussé avec le commit `b962f77b00b8908e236d1fdc0156a8b4628bf08d`.

### Configuration isolée

La copie locale de `azure-pipeline.yml` a été préparée pour :

- conserver la fabrication `Y2.Tools.Jmeter.Workflow.nupkg` ;
- conserver sa publication comme artefact du run Azure DevOps, limitée à ce run ;
- désactiver le push NuGet Artifactory et la publication du BuildInfo ;
- désactiver les quatre stages de build/push Docker ;
- désactiver la promotion NuGet/Docker et le tag source.

Le pipeline **5224** peut être lancé explicitement sur `sandbox/tests_rje`. Contrôle post-push effectué sur le YAML distant : `NuGet pack` est conservé et les sept conditions de publication/build externe sont désactivées.

## 2026-09-05 — Pipeline AzDO de fabrication du NuGet JMeter

### Verdict

**FAIT — pipeline responsable identifié :** `Y2 Tools Jmeter Workflow`, définition Azure DevOps **5224** :
https://dev.azure.com/cegid/Retail/_build?definitionId=5224

### Preuves vérifiées en lecture seule

- La définition 5224 est nommée `Y2 Tools Jmeter Workflow`, utilise le dépôt Git `Y2_Tools_Jmeter_Workflow` (ID `44f5e1ff-0205-49f5-8e9e-5dfbf183df2a`) et la branche par défaut `refs/heads/master`.
- YAML source : https://dev.azure.com/cegid/Retail/_git/Y2_Tools_Jmeter_Workflow?path=/azure-pipeline.yml, commit master vérifié `4db2dcdab647249de3cdc27eadaf15a158b3a26a`.
- Dans le YAML, `NuGetCommand@2` / `NuGet pack` empaquette `Y2.Tools.Jmeter.Workflow.nuspec` avec `versioningScheme: byEnvVar` et `versionEnvVar: Build.BuildNumber`.
- Le package est publié dans l’artefact de pipeline `$(Build.Repository.Name).$(Build.BuildNumber)`, puis `JFrogNuGet@1` le pousse vers `retail-nuget-staging/$(Build.Repository.Name)/`.
- Run de référence réussi : build **4373772**, numéro **3.0.211**, branche `master`, terminé le 2026-08-19, résultat `succeeded` : https://dev.azure.com/cegid/Retail/_build/results?buildId=4373772
- Artefact constaté sur ce run : `Y2_Tools_Jmeter_Workflow.3.0.211`.

### Distinction importante

Le pipeline 5224 fabrique le NuGet **`Y2.Tools.Jmeter.Workflow`**, c’est-à-dire l’outillage/workflow JMeter consommé par les pipelines de tests migrés. Il ne prouve pas la fabrication du NuGet convertisseur **`Cegid.Retail.AutoTest.Console`**, qui est un package distinct utilisé localement par l’outil de migration ; son pipeline source reste **UNKNOWN** dans le périmètre de cette recherche.

Fichiers de preuve locaux réorganisés sous `evidence/azure-devops/pipeline-5224/` : `definition-5224.json` et `master-yaml-live.json`.

## 2026-09-03 — Génération d'un CSV mis à jour à partir de `repos_to_migrate.xlsx`

### Demande

Régénérer `documentation/tracking/repos_to_migrate.xlsx` en investiguant directement dans les 3 repos concernés (`Y2_Plugins_FrenchTaxesRules`, `Y2_Plugins_InventoryTracking`, `Y2_Plugins_Clienteling`) pour corriger les noms de branche et les versions associées, le fichier original étant potentiellement obsolète.

### Méthode

- Auth AzDO via `az` (token `az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798`), appels REST directs (Git Items / Commits API) — pas de clone local, pas de browser automation.
- Liste des branches réelles par repo : `az repos ref list --filter heads`.
- Pour chaque branche candidate (ligne de release : `master`, `releases/*`, `old-releases/*`), lecture des fichiers `ExternalsToRestore_V<n>.xml` à la racine (source de vérité citée dans `documentation/guides/FONCTIONNEMENT_TECHNIQUE.md` §2) pour déterminer la ou les versions Y2 majeures supportées.
- Détection des branches déjà migrées via la présence de branches `<Plugin>_Migration_AutoTest_Jmeter_On_<branche-source>` (convention documentée en §3.2), avec vérification de la date du dernier commit et recherche de PR associée (`az repos pr list`, aucune trouvée pour ces branches).
- Exclusion des branches bruit : `sandbox/*`, `batch/*`, `bugfix/*`, `features/*`, branches à nom malformé (ex. `Y2_Plugins_InventoryTracking:releases/V2features/2185648-Remove_blackduck-scan-OnV2`, `Y2_Plugins_FrenchTaxesRules:9355ff57-on-releases-V6`).

### Résultat

Nouveau fichier : `documentation/tracking/repos_to_migrate_updated.csv` — mêmes colonnes que le xlsx source (`Nom, Branches, Versions`), sur demande explicite de l'utilisateur (2026-09-03 : "le csv doit reprendre la syntaxe et colonnes du xls source"). Les infos `DejaMigre` / `Commentaire` d'une première version enrichie ont été retirées du CSV et sont conservées uniquement ici, dans ce JOURNAL, pour ne pas perdre l'info.

Écarts principaux vs fichier original :
- Branches manquantes découvertes : `FrenchTaxesRules` releases/V1, V6, V7 ; `InventoryTracking` releases/V6 ; `Clienteling` releases/V7, V7_PI17_Y2V24, V8, PI14.
- `Clienteling` : les anciennes branches `releases/V2..V5` ont été renommées `old-releases/V2..V5` (inactives depuis 2024-06-21) — toujours dans le périmètre (versions ≤21 → abandonnées) mais renommées.
- Branches avec une tentative de migration déjà poussée mais **sans PR** : `FrenchTaxesRules/master` (2026-09-03, en cours), `InventoryTracking` V3/V4/V5, `Clienteling` master/old-releases-V5/V6 (toutes datées 2025-05-09, message générique "Mise a jour automatique" — probablement un run d'outillage antérieur, à ne pas considérer comme "fait").

### Point bloquant / à faire trancher par Ludo & Lydie

`Y2_Plugins_Clienteling` a 4 branches dont les plages de versions Y2 (via `ExternalsToRestore_V*.xml`) se chevauchent : `releases/PI14` (24-26), `releases/V7` (24), `releases/V7_PI17_Y2V24` (24-25), `releases/V8` (25). Toutes ont un commit récent (2026-08-11, même PR de sécurité appliquée en série sur toutes). Le pipeline de `releases/PI14` déclare `VersionMajor: 7` (version du plugin, pas version Y2) — donc le nom "PI14" ne correspond plus au contenu réel de la branche. Je n'ai pas tranché laquelle de ces branches est la "vraie" ligne de release à migrer : c'est documenté tel quel dans le CSV (colonne Commentaire) plutôt que résolu arbitrairement, à faire trancher par Ludo/Lydie comme prévu par le PBI (notification après collecte).

### Non fait

- Pas de mise à jour de l'outil de migration lui-même (images Docker par version, commentaire ACR/JMeter pour ≤21) — hors périmètre de cette tâche, reste à faire pour la suite du PBI.
- Pas d'exécution de pipeline, pas de PR créée.

## 2026-09-04 — Vérification de la PR 505832 (Y2_Plugins_FrenchTaxesRules) vs description/AC du PBI

### Contexte

PR : https://dev.azure.com/cegid/Retail/_git/Y2_Plugins_FrenchTaxesRules/pullrequest/505832 — `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V6` → `releases/V6`, créée le 2026-09-04 par Ronan JEGOU, reviewer Ludovic BAUDEAU (vote 0), `mergeStatus: succeeded`.

Description et AC du PBI rafraîchies depuis AzDO (`az boards work-item show --id 2222897`) : AC inchangés dans le fond (mêmes 3 blocs : images Docker, gestion ≤21/>21, Excel + notification). Description enrichie d'une finalité supplémentaire ("faire un état des lieux des erreurs restantes"), reportée dans `README.md`.

### Vérification point par point

- Branche `releases/V6` du repo `Y2_Plugins_FrenchTaxesRules` correspond à la version Y2 **V24** (confirmé via `/ExternalsToRestore_V24.xml` à la racine et `matrix.V24` dans le pipeline) → s'applique la branche AC "versions > 21".
- Image Docker : `azure-pipelines.yml` cible `acrImage.Tag = sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022` (≡ win2022sql2019dotnet10) — cohérent car ce n'est pas la branche V26/master (qui doit utiliser win2025sql2025dotnet10). ✅
- Versions > 21 : pipeline exécuté (build + tests JMeter), run https://dev.azure.com/cegid/Retail/_build/results?buildId=4429563, 100% tests passés, PR créée après succès. ✅
- Ancien job `TestAutos` (legacy, `launch-testsAutos.v2.yml`) supprimé du pipeline, cohérent avec "Suppression/déréférencement des tests AutoTest legacy" de la description de PR. ✅
- Ajout des fichiers JMeter (`Tests/LegacyServices/*.jmx`, `Tests/WebServices/*.jmx`), backup DB via Git LFS (`Tests/Backups/AUTO_V24_00.bak`), scripts (`Testautos2Jmeter.bat`, `BeforeMigration.ps1`). Cohérent avec la description de PR.
- Point AC "≤21 : job ACR + stage JMeter commentés" **non applicable à cette PR** (branche V24 > 21) et non vérifiable ici : le pipeline généré est paramétré (`versionsToTest`, condition `if le(version, 21) → condition: false`) plutôt que littéralement "commenté" — à surveiller quand l'outil traitera une branche réellement ≤21 (le job `Ensure_Docker_Image_Up_To_Date` n'a lui-même aucune condition liée à la version).
- Mise à jour de l'Excel "Migration AutoTests Legacy To Jmeter" et notification Ludo/Lydie : **pas couverts par cette PR**, restent dus au niveau du PBI (portée globale, pas par PR unitaire) — cf. section "Non fait" ci-dessus, toujours vrai à ce jour.

### Conclusion

La PR 505832 répond aux AC applicables à son périmètre (branche V24, > 21) : image Docker correcte, pipeline exécuté avec succès, PR créée. Les critères concernant les versions ≤21 et les livrables globaux du PBI (Excel, notification) restent hors périmètre de cette PR unitaire et ne sont pas encore traités.

## 2026-09-04 — Prise en charge des commentaires de la PR 505832

### Contexte

11 threads sur la PR, dont 3 système et **8 commentaires actifs, tous émis par le bot SonarCloud** (« Platform Engineering »). Aucun commentaire humain : les deux reviewers (`[Retail]\CRM`, Ludovic BAUDEAU) n'avaient pas encore voté.

Répartition :
- 6 × `powershelldre:S8642` (casse d'opérateurs / cmdlets) — `BeforeMigration.ps1` lignes 17 (`-And`), 61 (`-Or`), 72 (`-And`), 352 et 357 (`write-host`) ; `checkPackage.ps1` ligne 10 (`-Not`).
- 2 × `powershelldre:S3776` (complexité cognitive) — `BeforeMigration.ps1` : `RenameTestCases` (49 → 15 demandé) et `UpdateTestCaseControl` (39 → 15 demandé).

### Analyse préalable (a conditionné la réponse)

- `BeforeMigration.ps1` et `checkPackage.ps1` sont **ajoutés** par cette PR (`changeType: add`), et ne sont appelés **que** par `Testautos2Jmeter.bat` — jamais par `azure-pipelines.yml` (vérifié par grep sur le contenu des 3 fichiers au commit source). Ce sont donc des outils *one-shot* de migration, hors chemin d'exécution CI.
- Les `.jmx` livrés dans la PR ont été produits par cette version exacte du script et validés à 100 % (build 4429563). Toucher la *logique* du script sans régénérer la migration désynchronise le script commité des tests commités.
- Corollaire retenu : les corrections de **casse** sont sûres (opérateurs et cmdlets PowerShell insensibles à la casse → zéro impact runtime) ; les **refactos de logique** ne le sont pas dans le cadre de cette PR.

### Bug trouvé, non détecté par Sonar

`BeforeMigration.ps1:16-21`, fonction `RemoveTestCases` :

```powershell
$_.Label -like "EC*" -And (A) -or (B) -or (C)
```

`-and` étant prioritaire sur `-or`, l'expression vaut `(Label -like "EC*" -and A) -or B -or C`, alors que le commentaire juste au-dessus annonce « celles commençant par "EC" **et** ayant une des trois Query ». Il manque les parenthèses autour de `(A -or B -or C)`.

Conséquence : des TestCases ne commençant pas par `EC` mais matchant la Query B ou C ont pu être supprimés pendant la migration. **Le risque est une perte de couverture silencieuse** — un TC supprimé ne peut pas échouer — donc le 100 % vert du build 4429563 ne l'invalide pas.

Point secondaire, lignes 343 et 364 : `$controlId` n'est pas défini (attendu `$preDataQueriesControlId` / `$finalQueriesControlId`). Impact limité au message de log.

### Actions faites

1. Commit `8af9183` — « style: align PowerShell operator/cmdlet casing (SonarCloud S8642) » — poussé sur `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V6` **via l'API REST AzDO** (`POST /_apis/git/.../pushes`, contenu en base64), sans clone : le repo embarque des fichiers Git LFS (`Tests/Backups/AUTO_V24_00.bak`). 2 fichiers, 6 lignes, taille en octets identique avant/après → diff purement cosmétique, vérifié en re-téléchargeant les blobs du commit poussé.
2. Les 6 threads S8642 : réponse « Corrigé : `X` → `y` (commit 8af9183) » + statut `fixed`.
3. Les 2 threads S3776 : réponse **Won't fix assumé** + statut `wontFix`, justifiée par l'analyse ci-dessus (outillage one-shot hors CI, reproductibilité des `.jmx`, script conservé pour traçabilité et non pour maintenance). Pour `UpdateTestCaseControl`, mention que la complexité vient de 3 blocs quasi identiques (`PreDataQueries` / `FinalDataQueries` / `XmlQueries`), factorisables si le script est un jour réutilisé.
4. Nouveau thread `3573422` ancré sur `BeforeMigration.ps1:16-21`, statut `active` : signalement du bug de précédence + `$controlId`, avec la raison explicite de ne pas le corriger dans cette PR.

### Décisions prises

- Ne pas corriger le bug de précédence dans cette PR : le corriger sans rejouer la migration ni la campagne de tests créerait une incohérence script/tests plus coûteuse que le bug lui-même à ce stade. Arbitrage laissé ouvert dans le thread : WI dédié pour mesurer le delta de couverture legacy → JMeter, ou acceptation explicite du périmètre migré.
- Ne pas refactorer pour satisfaire S3776 : effort réel sur du code jetable, aucun gain produit.

### Leçons apprises

- **Sonar sur une PR de migration signale surtout le bruit du fichier ajouté, pas les vrais risques.** Les 8 commentaires portaient sur 2 fichiers d'outillage, dont aucun n'est exécuté par la CI, et aucun ne pointait le bug de logique réellement présent dans le même bloc de code. Il faut lire le fichier, pas seulement la règle.
- **Réflexe utile avant de répondre à un commentaire de qualité de code : vérifier si le fichier concerné est dans le chemin d'exécution** (grep du nom du script dans `azure-pipelines.yml` et les `.bat`/`.cmd`). Cela change radicalement l'arbitrage fix / won't fix.
- **Pousser un commit via l'API REST `pushes` d'AzDO fonctionne bien et évite un clone** quand le repo est lourd (Git LFS). Il faut : le `oldObjectId` de la ref (via `/refs?filter=heads/<branche>`), les contenus en `base64encoded`, et une vérification post-push en re-téléchargeant les blobs (`/items?versionDescriptor.version=<sha>&download=true`). Attention : l'API `/items` exige le **SHA complet**, un SHA court renvoie 404.
- L'auto-complete était déjà armé sur la PR : le push a relancé la validation sans déclencher de merge (les reviewers n'ont pas approuvé). À garder en tête avant de pousser sur une PR en auto-complete approuvée.

### État après action

PR 505832 : `active`, `mergeStatus: succeeded`, dernier commit source `8af9183`, auto-complete armé. 8 threads Sonar traités (6 `fixed`, 2 `wontFix`), 1 thread ouvert volontairement (`3573422`) pour arbitrage par le reviewer. Reste en attente : vote des reviewers.
## 2026-09-06 — Points de récupération des logs legacy communiqués par un collègue

Deux messages du collègue ont été intégrés au handoff à partir de la page 13 de `procédureMigration.pdf` et du document technique de nettoyage post-migration.

- **Premier point à inspecter** : `D:\CegidUtils\CegidIntegrationTests\override` sur `Y2-TSTAUTOXXPG2`, car les dossiers sont organisés par plugin/version et FrenchTaxesRules est associé à cette VM dans le document de suivi.
- Rapports : `C:\inetpub\wwwroot\integrationTestsReports` ; archives TRX : `\\cbr-tstauto-sql\Archives\TRX\CBR_AUTO_TT_XX.XX` ; configuration dashboard : `\\cbr-tstauto-sql\Outils\PublishTRX\Dashboard.SourceItems.xml`.
- La procédure mentionne les VM `Y2-TSTAUTOXXPG1` à `Y2-TSTAUTOXXPG4`, le compte `cegidgroup\SvcTestAutoRetail` et des raccourcis présents sur le bureau (`Integration...`, `List integration...`, `override - Shortcut`, etc.). Aucun mot de passe n'a été communiqué ni enregistré.
- **UNKNOWN / à confirmer** : présence effective des logs recherchés, méthode exacte de connexion et pertinence d'une connexion RDP via `mstsc` (inférence fondée sur la capture d'un bureau Windows, non explicitement confirmée par la doc).
- Aucun accès, nettoyage ou modification de VM n'a été effectué dans cette mise à jour.

## 2026-09-06 — Réorganisation des PDF du dossier `doc`

Les 10 PDF du dossier ont été inventoriés et leurs 29 pages contrôlées visuellement. Neuf documents contiennent des informations de migration AutoTest/JMeter ; `EDT Classe 5A - Jeudi 3 et vendredi 4-09.pdf` est un emploi du temps scolaire hors périmètre. Les PDF sont conservés inchangés comme sources brutes.

Documentation créée :

- `documentation/README.md` : point d'entrée, hiérarchie des sources, inventaire et fraîcheur ;
- `documentation/guides/PROCEDURE_MIGRATION_JMETER.md` : procédure de bout en bout, validation, PR et communication ;
- `documentation/guides/ENVIRONNEMENT_ET_EXECUTION_LOCALE.md` : SQL/JDBC, backups, Git LFS, Fix/Cur, `cy2px`, QualityTools, WCF et exécution locale ;
- `documentation/guides/DEPANNAGE_JMETER.md` : contrôles XML/SQL, comparaison local/pipeline/legacy et boucle de correction.

Le `README.md` du WI route désormais vers ces documents. Les valeurs datées des PDF sont signalées comme historiques ou à revalider ; la synthèse du WI et le fonctionnement établi par lecture du code restent prioritaires. Aucun secret visible dans les captures n'a été recopié.

## 2026-09-06 — Réorganisation complète du workspace pour reprise LLM

Le dossier a été réorganisé autour de cinq zones explicites : `documentation/`, `worktrees/`, `evidence/`, `investigations/` et `archive/`. La racine ne contient plus que les routeurs et registres canoniques (`AGENTS.md`, `README.md`, `STATUS.md`, `TASKS.md`, `JOURNAL.md`, `RESOURCES.md`).

Actions réalisées :

- création d'un parcours de démarrage et d'une matrice « lire/produire » par type de tâche ;
- séparation des guides, du contexte PBI, des neuf PDF sources et des fichiers de suivi ;
- déplacement des deux dépôts Git sous `worktrees/`, sans modifier leur contenu ni leur état ;
- regroupement des quatre captures du pipeline 5224 sous `evidence/azure-devops/pipeline-5224/` ;
- conservation de l'ancien handoff FrenchTaxesRules sous `archive/handoffs/`, avec redirection vers le handoff canonique ;
- isolement du PDF scolaire hors périmètre sous `archive/out-of-scope/` ;
- regroupement des archives, extractions brutes et index LLM legacy sous `investigations/ecarts-jmeter-migrations/evidence/legacy/` ;
- ajout d'index pour `cases/`, `findings/`, `references/`, `sources/`, les archives et la quarantaine ;
- déplacement du clone Clienteling incomplet sous `sources/quarantine/` et des ZIP de snapshots sous `sources/archives/`.

Vérifications effectuées : 56 fichiers Markdown curatés contrôlés, zéro cible de lien local manquante ; aucun ancien chemin canonique ni marqueur de conflit dans le corpus curaté ; empreintes SHA-256 des deux archives legacy inchangées. Les comptages des quatre lots legacy après déplacement correspondent à l'inventaire préalable.

État Git préservé :

- `worktrees/Migration_Jmeter_RJE_Sandbox` reste propre sur `current-state-2026-09-05`, HEAD `13144a2fb5ef7c822fff3c0a64fed88e72339981` ;
- `worktrees/Y2_Tools_Jmeter_Workflow` reste sur `master`, HEAD `4db2dcdab647249de3cdc27eadaf15a158b3a26a`, avec la modification utilisateur préexistante de `azure-pipeline.yml` (14 ajouts, 3 suppressions).

Aucune action Azure DevOps, VM, JFrog, publication, relance, branche, PR, code produit ou pipeline n'a été réalisée pendant cette réorganisation.
## 2026-09-06 — Clonage des dépôts utiles aux investigations

**FAIT — clones locaux ajoutés sous `worktrees/`**, sur la branche distante par défaut `master`, sans modification distante :

- `Y2_Tools_AutoTest_Api` — `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`
- `Y2_Tools_AutoTest_Console` — `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`
- `Y2_Plugins_FrenchTaxesRules` — `07a42172bebc65d17093e166ac08de22e4fe7248`
- `Y2_Plugins_Clienteling` — `0c0fd26533e46b13e029276f90b5c085c1804012`
- `Pipelines_Docker_BaseImages` — `cd5a72235e5f71373acb8994cb3f60f2f6975b93`
- `Y2_Tools_PlatformDeploy` — `93f91487ee717185599555a42df3cb5d024ace89`

Les deux clones déjà présents ont été conservés. Vérification post-clonage : les six nouveaux dépôts sont propres ; `Y2_Tools_Jmeter_Workflow` conserve uniquement sa modification locale préexistante dans `azure-pipeline.yml`. Les remotes et chemins sont documentés dans `worktrees/README.md`.

## 2026-09-06 — Protocole de poursuite des écarts legacy/JMeter

Rédaction de [PROTOCOLE_INVESTIGATION_ECARTS_LEGACY_JMETER.md](documentation/guides/PROTOCOLE_INVESTIGATION_ECARTS_LEGACY_JMETER.md), indexé dans les guides et relié depuis le handoff et STATUS. Le protocole distingue validation des défauts techniques prouvés et comparaison fonctionnelle à contrat constant ; il intègre les deux échecs déjà observés en legacy et les limites de comparabilité des 489 autres différences V26.

Contrôle effectué : tous les liens relatifs du protocole se résolvent. Travail documentaire uniquement ; aucun code, package, pipeline, branche ou système distant modifié, aucun rejeu exécuté. Aucun nouveau résultat causal ni aucune ressource temporaire. Les UNKNOWN existants restent ouverts.

## 2026-09-06 — Isolation des investigations vis-à-vis des collègues

À la demande utilisateur, renforcement du protocole legacy/JMeter : nouvelle section 0 sur les worktrees et triggers, NuGet exclusivement en artefacts de runs identifiés sans push JFrog/feed partagé, Docker local ou transféré en artefact par défaut, publication Docker éventuelle dans un espace dédié avec préfixe WI/personnel, tag unique et consommation par digest. Ajout des précautions sur les agents, bases, services externes et nettoyage ciblé. La chaîne de propagation de l'étape 4 et STATUS sont alignés sur ces règles.

Vérification documentaire : liens du protocole résolus, absence de marqueurs de conflit. Aucun pipeline, code, package ou système distant modifié ; aucune publication ni ressource d'essai créée. Le registre RESOURCES reste inchangé. L'isolation effective devra être vérifiée pour chaque futur essai ; aucun résultat de contrôle distant n'est revendiqué ici.

## 2026-09-06 — Reproduction locale ciblée de EscapeJdbcDate

Dans `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-escape-jdbc-date/`, reproduction en lecture du code source au commit `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` avec un harnais C# compilé en mémoire par PowerShell `Add-Type`. Aucun worktree, snapshot, package, configuration globale ou système distant n'a été modifié ; aucune installation/restauration n'a été effectuée.

Résultat : `'2026-04-28'` devient `'20262804'` et `'2026-04-05'` devient `'20260504'` ; `'20260428'` et `'2026/04/28'` restent inchangées. Défaut reproduit, correction non validée.

## 2026-09-06 — Candidat local de correction EscapeJdbcDate

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-escape-jdbc-date-candidate/`. Le harnais conserve l’original et teste un candidat limité au remplacement `${1}${3}${2}` par `${1}${2}${3}`. Neuf cas ont passé, dont deux dates ISO apostrophées corrigées, une date bissextile, deux dates SQL, et trois comportements hors correction conservés. Code de sortie réel : `0`.

Le patch est conservé sans application dans `candidate.patch`. Aucun worktree, snapshot, package, système distant ou configuration globale n’a été modifié. Compilation API et génération JMX restent `UNKNOWN`.

## 2026-09-06 — Correctif EscapeJdbcDate appliqué dans un worktree dédié

Création du worktree local `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/` sur `sandbox/rje-wi2222897-escape-jdbc-date`, basé sur `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`. Application exclusive de `${1}${3}${2}` → `${1}${2}${3}` dans `JmeterCodeGen.cs`, sans commit ni publication.

Le harnais extrait automatiquement la méthode réelle et passe les neuf contrôles avec code `0`. `git diff --check` retourne `0`; le worktree initial reste propre et le nouveau ne modifie que `JmeterCodeGen.cs`. Compilation API et génération JMX restent `UNKNOWN`.

## 2026-09-06 — Collecte isolée des dépendances de compilation API

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-dependencies/`. NuGet `6.12.2.1` a récupéré les paquets publics, dont `Microsoft.NETFramework.ReferenceAssemblies.net452 1.0.3`, et les paquets Cegid exacts depuis Artifactory `all-nuget`, sans modification de configuration, cache partagé, worktree ou système. Les nupkg, SHA-256, journaux sans secret et DLL attendues sont indexés dans le manifeste.

Le package exact `System.Windows.Interactivity, Version=4.5.0.0` n'est pas disponible via la recherche nuget.org et n'a pas été trouvé aux emplacements locaux ciblés ; aucune substitution n'a été faite. `Prism.Unity 6.1.0` est présent mais expose `Prism.Unity.Wpf.dll`, alors que le projet référence un autre nom à confirmer. Aucun build, test, restauration de solution, installation, publication ou connexion distante n'a été exécuté. Compilation API : `UNKNOWN`.

## 2026-09-06 — Résolution metadata-only des références restantes

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-reference-resolution/`. Les références du `.csproj` et leurs usages ont été relus sans modification. `Expression.Blend.Sdk.WPF 1.0.1` fournit sous `lib/net45` `System.Windows.Interactivity.dll`, version d'assembly `4.5.0.0`, PublicKeyToken `31bf3856ad364e35` : correspondance exacte. Les autres candidats ont été écartés selon leur cible, version ou token.

`Prism.Unity` n'est pas une référence `<Reference>` du projet ; il est déclaré dans `packages.config`, et son assembly WPF `Prism.Unity.Wpf 6.1.0.0` possède le token Prism attendu. Les dépendances net45 de son nuspec sont déjà présentes. Aucun `.csproj`, `packages.config`, worktree, cache partagé, SDK système, build ou test n'a été modifié/exécuté.

## 2026-09-06 — Tentative de compilation isolée de l'API corrigée

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-candidate/`. MSBuild `17.14.14.31908` a ciblé uniquement le `.csproj`, en Debug/AnyCPU, avec staging `ReferencePath`, références net452 via `FrameworkPathOverride` et toutes les sorties dans la preuve. Code de sortie réel : `1`.

La première erreur causale est `CS0012` dans `JmeterGenerator.cs(98,45)` : `System.Runtime, Version=4.0.0.0, PublicKeyToken=b03f5f7f11d50a3a` manque à la résolution ; 36 erreurs de compilation, zéro avertissement. Aucun code, projet, signature, worktree ou cache partagé n'a été modifié. Aucune DLL API n'a été produite ; génération JMX UNKNOWN.

## 2026-09-06 — Retentative avec façade net452 explicitement importée

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-candidate-facades/`. Le diagnostic de l'étape précédente est confirmé : `FrameworkPathOverride` seul ne transmettait pas les façades au compilateur. Un import MSBuild externe local a ajouté la façade exacte `System.Runtime.dll` et sa trace apparaît dans le journal et la ligne Csc.

Compilation unique : code `1`, zéro avertissement, deux erreurs. `System.Runtime` n'est plus en erreur ; le nouveau premier blocage est `System.ObjectModel, Version=4.0.0.0, PublicKeyToken=b03f5f7f11d50a3a` manquant, avec l'erreur `ICommand` associée. Aucun worktree, projet, signature, cache partagé ou système n'a été modifié. DLL API et génération JMX restent UNKNOWN.

## 2026-09-06 — Compilation avec toutes les façades net452

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-build-net452-complete/`. Les 51 DLL du dossier `Facades` du targeting pack net452 ont été ajoutées par import MSBuild wildcard ; aucune collision avec les 13 références applicatives n'a été détectée. La ligne Csc contient effectivement `System.Runtime.dll` et `System.ObjectModel.dll` depuis le staging local.

La compilation unique réelle du `.csproj` réussit en `Debug|AnyCPU`, code `0`, zéro avertissement et zéro erreur. `Cegid.Retail.AutoTest.Api.dll` version `1.1.46.0`, token `fe0ce61bd76bef19`, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`. Aucun worktree, projet ou système distant n'a été modifié ; génération JMX toujours UNKNOWN.

## 2026-09-06 — Génération JMX avec l'API compilée

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-jmx-date-candidate/`. Le harnais appelle directement `JmeterCodeGen.GenerateJmeter` avec une fixture `DtoLegacyServiceTestPlan` validée par les signatures du modèle. Il charge `runtime/Cegid.Retail.AutoTest.Api.dll`, SHA-256 vérifiée `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`, sur .NET Framework `v4.0.30319`.

Six JMX ont été générés et parsés structurellement : dates 2026-04-28, 2026-04-05, 2024-02-29, deux dates, valeur compacte et valeur slash. Un unique `JDBCSampler/query` par fichier ; 6/6 PASS, code d'exécution `0`. Aucun JMeter, SQL, HTTP, déploiement ou worktree n'a été utilisé. Comparaison avec l'originale, propagation Console et rejeu métier restent à faire.

## 2026-09-06 — Comparaison API originale/corrigée

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-jmx-date-before-after/`. Le worktree original était propre à `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` et n'a pas été modifié. Deux processus .NET Framework `v4.0.30319` ont appelé directement `JmeterCodeGen.GenerateJmeter` avec les mêmes six fixtures et des DLL chargées dont les SHA-256 sont consignées.

Original : code `1`, quatre dates ISO dans l'ordre erroné (`20262804`, `20260504`, `20242902`, et les deux dates), deux témoins PASS. Corrigé : code `0`, six PASS. La comparaison XML montre uniquement les différences attendues dans `JDBCSampler/query` pour les quatre cas ISO ; les deux témoins sont identiques. Console, Docker et rejeu métier restent non validés.

## 2026-09-06 — Préparation de la propagation Console

Mise à jour documentaire de la fiche `findings/001-french-taxes-rules-v26.md`, de `CORRECTION_PLAN.md` et de `STATUS.md` avec le lien vers la preuve avant/après. Formulation conservée : correctif local compilé et génération JMX validée sur six fixtures ; Console, Docker et rejeu métier restent `UNKNOWN`.

Le worktree Console est `master@fa8a5fb411bbadcef16204f149bae3a65b0f7abb`, `master...origin/master`, état propre, vérifié sans fetch. `Cegid.Retail.AutoTest.Console.csproj` cible net452, référence `Cegid.Retail.AutoTest.Api` 1.1.46 via `..\packages\Cegid.Retail.AutoTest.Api.1.1.46\lib\net452\Cegid.Retail.AutoTest.Api.dll`; `packages.config` porte la même version. `Program.GenerateTestsMethods` choisit `--tstj`, instancie `JmeterGenerator`, puis l'API charge chaque plan et appelle `JmeterCodeGen.GenerateJmeter`.

Commande locale identifiée, à exécuter seulement dans une future expérience isolée : `Cegid.Retail.AutoTest.Console.exe --tstj=<testCampaign> --dstFolder=<dossier-essai>`. Elle exige une campagne XML, les TestPlans associés et les ressources `OutputFiles`; aucun build ni exécution n'a été lancé ici. Le nuspec embarque les DLL `Cegid.Retail.AutoTest.*` dans `tools`, mais cela ne prouve pas la fabrication d'un package.

Proposition : worktree Console dédié depuis ce commit, staging local de l'API corrigée et de ses dépendances déjà identifiées, compilation net452 vers un dossier d'essai, puis génération avec une campagne minimale et comparaison des `JDBCSampler/query` aux six fixtures. UNKNOWN : artefact Console corrigé identifiable, mode exact de fourniture sans modification du projet, dépendances complètes disponibles et équivalence de campagne réelle.

## 2026-09-06 — Compilation Console avec API corrigée

Création du worktree `Y2_Tools_AutoTest_Console_Date_RJE` sur `sandbox/rje-wi2222897-console-date`, depuis `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`. Le worktree Console source reste propre. Staging privé créé dans `evidence/local-2026-09-06-console-build-date-candidate/` avec l'API corrigée SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`, les dépendances locales et les 51 façades net452.

Compilation unique du `.csproj` Console par MSBuild 17.14.14, sans restauration, sortie `1`. Première erreur : `Cegid.Retail.Svn 1.0.4.0` demandé mais staging initial `1.0.2.0`; le contrôle a aussi établi l'absence locale de `Cegid.Retail.XmlDiff 1.0.5.0` et de l'identité exacte `XmlDiffPatch.View` demandée. Aucun contournement, aucun exe/API Console final, aucune exécution Console. Génération JMX via Console reste `UNKNOWN`.

## 2026-09-06 — Alignement des dépendances Console

Création de `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-console-dependencies-aligned/`. La matrice des 17 références du `.csproj` distingue les versions NuGet, `HintPath`, `SpecificVersion` et identités réelles. Le staging privé contient l'API corrigée SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`, `Cegid.Retail.Svn 1.0.4.0`, `Cegid.Retail.XmlDiff 1.0.5.0` et les dépendances compatibles, sans homonymes concurrents.

La recherche Artifactory all-nuget a récupéré `Cegid.Retail.XmlDiff 1.0.5`; nuget.org n'en fournit pas. Le package 1.0.5 produit `XmlDiffPatch.View` version `1.0.1493.40755` mais token `8d9c769b09370619`, alors que le `.csproj` demande `59dd5855c27c6c17`. Le package local 1.0.3 porte encore un autre token. Verdict : pas prêt à compiler ; aucune compilation exécutée à cette étape.

## 2026-09-06 — Identité XmlDiffPatch.View dans l’artefact Console officiel

Inspection locale de `Cegid.Retail.AutoTest.Console.2.0.42.nupkg` du run 4311240, SHA-256 `4ACE80675261D7D5DAD2DB3F0E8C7983790E1983D32C12661FF980C54B16E5DE`. L’artefact extrait ne contient ni `XmlDiffPatch.View.dll`, ni `XmlDiffPatch.dll`, ni `Cegid.Retail.XmlDiff.dll`; son nuspec/manifeste ne les désignent pas. Console officiel et API officielle ont été lus metadata-only : aucune référence XmlDiffPatch.View relevée. La référence projet reste `XmlDiffPatch.View 1.0.1493.40755`, token `59dd5855c27c6c17`; les candidates locales 1.0.5 (`8d9c769b09370619`), 1.0.4 (`1a0de8f0f7caa6ed`) et 1.0.3 (`3675d7d1b79eb039`) ne correspondent pas. Aucun staging ajouté, aucune compilation/exécution effectuée ; résolution exacte `UNKNOWN`.

## 2026-09-06 — Console officielle avec API originale/corrigée

Deux copies isolées du runtime Console 2.0.42/run 4311240 ont été préparées. Console est identique dans les deux (`2.0.42.0`, SHA-256 `82A1134B...ED75A9F`). Les APIs originale et corrigée ont la même identité `1.1.46.0`, token `fe0ce61bd76bef19`; seule leur DLL diffère. La campagne locale six fixtures respecte le format observé dans les campagnes du workspace. Sous Windows PowerShell 5.1, les deux commandes `--tstj` retournent `-1` après l'initialisation Unity, sans JMX ni assertion ; stderr est vide. Cause précise `UNKNOWN`, propagation Console non validée.

## 2026-09-06 — Déblocage rapide de la génération Console

Diagnostic local : PathTooLongException puis input.xml attendu sous TestPlans. Copies sous C:\temp\rje-wi2222897-20260906-console ; deux exécutions officielles code 0, six JMX chacune, corrected 6/6 contre quatre écarts ISO original. Preuves indexées dans local-2026-09-06-console-quick-diagnosis. Aucun worktree modifié, aucun système distant utilisé ; ressource locale enregistrée. Pipeline non examiné davantage car le blocage est résolu localement.

## 2026-09-06 — Préparation Export_Run FrenchTaxesRules TC08–TC10

Depuis `Y2_Plugins_FrenchTaxesRules` master au commit `07a42172bebc65d17093e166ac08de22e4fe7248`, copie sans modification du plan complet `Export_Run.xml`, des entrées `Run_08.xml` à `Run_10.xml` et des graines `OutputFiles` dans `C:\temp\rje-wi2222897-export-20260906-173737`. Un descripteur de campagne d'essai ne référence que ce plan. Aucun JMX, génération, Console, JMeter, SQL, HTTP ou réseau n'a été exécuté. Manifeste et dates des prérequêtes : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-export-run-tc08-tc10-prep/`.

## 2026-09-06 — Blocage complétude Export_Run avant/après

Le contrôle du plan complet a trouvé les références `InputFiles\Export\Run_01.xml` à `Run_07.xml` absentes de la préparation. Conformément à la consigne, aucun runtime n'a été lancé, aucun espace original/corrected créé et aucune entrée n'a été supprimée ou modifiée. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-export-run-tc08-tc10-before-after-blocked/`.

## 2026-09-06 — Blocage sorties Export_Run complètes

Les dix entrées sont présentes dans la source legacy au commit `07a42172bebc65d17093e166ac08de22e4fe7248`, mais les graines `TestPlans\OutputFiles\Export\Run_01.xml` à `Run_04.xml` manquent. Arrêt avant copie complète et génération Console ; aucun contenu inventé ou substitué. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-export-complete-blocked/`.

## 2026-09-06 — Export_Run complet avant/après

Le contrôle a été corrigé pour utiliser les références XML réellement présentes : dix `Input` et cinq sorties `XmlQueries/OutputFiles` (`Run_05.xml` à `Run_09.xml`). Deux copies courtes et indépendantes ont été générées depuis l'artefact Console officiel local : original et corrected ont retourné `0`. Les JMX contiennent chacun 86 samplers ; les différences normalisées sont limitées aux dates de TC08/TC09 et aux racines de chemin, sans différence hors dates. Aucun JMeter, SQL ou HTTP. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-export-complete-before-after/`.

## 2026-09-06 — Préparation du rejeu métier Export_Run

La preuve de génération Console est intégrée aux findings, au plan de correction et au statut : génération validée sur le plan complet, réussite métier toujours `UNKNOWN`. Les guides établissent les prérequis SQL Server 2019, backup correspondant, packages/versions, `cy2px`, tenant dédié, services Y2/Auth, pilote JDBC et JMeter. Le worktree FrenchTaxesRules ne fournit ni `Tests/Config` ni backup ; aucune exécution métier n'a été tentée. La définition locale prouvée `2054 — FrenchTaxesRules CI` comporte des effets Publish/Promote/Tag et cible TestAutos partagé ; une voie sandbox doit être identifiée avant toute relance. Preuve documentaire : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-export-run-business-replay-prep/`.

## 2026-09-06 — Identification build 4432510

Pour le seul build 4432510 au commit `f80bc731571b2b5ed8a67da171b288873de428a6`, la timeline et le YAML exact établissent le job JMeter conteneurisé `acr_y2jmeter_test`, l’image logique `cegid-retail-docker-production/y2-jmeter:$(acrImage.Tag)`, le checkout du dépôt et l’exécution de `Tests\LegacyServices\010-Export_Run.jmx` par `task-run-campaign.v1.yml`. Les logs prouvent SQL Server 2025 Express 17.0.1000.7, pas SQL Server 2019. Le mécanisme de backup est référencé via `Tests\Backups`, mais son identité exacte et le tag/digest d’image restent UNKNOWN. TestAutos on-premise est distingué du runner JMeter. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-4432510-identification/`. Aucun pipeline ni artefact distant téléchargé.

## 2026-09-06 — Prérequis exacts V26 Fix avant choix d'environnement

Inspection locale ciblée des preuves des builds 4432510 et 4426342 : `cy2px` V26 Fix retrouvé pour 4426342, Core 26.0.0.1762, plugin 26.0.10.67, tenant TESTS_AUTO_JMETER, et JMeter 5.6.3/Java 21.0.5 observés dans les logs. Le service SQL Express et le driver `Sql2012` sont prouvés, mais ni SQL Server 2019, ni un backup identifié, ni la consommation d'un JMX fourni hors checkout ne le sont. Correction du compte rendu précédent : SQL Server 2019 passe de prérequis affirmé à UNKNOWN pour ce périmètre. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-replay-prereqs/`. Aucun pipeline, service, SQL, réseau ou restauration lancé.

## 2026-09-06 — Image et données historiques du job JMeter 4432510

Les logs Azure DevOps du job Fix établissent le pull de l’image `y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`. Le registre reste masqué par Azure. Le job copie `Tests\Backups\AUTO_V26_00.bak` vers son staging Docker, puis lance `docker-pipeline-deploy.ps1 -LocalDBInContainer Backup`; la restauration de `AUTO_V26_00` est observée avant JMeter. Le hash du backup reste UNKNOWN. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-4432510-image-data/`. Aucun téléchargement ni lancement depuis ce poste.

## 2026-09-06 — Plan concret de rejeu pipeline isolé

La définition 2054 ne peut pas être considérée isolée par une simple branche : le graphe historique contient des stages aval et les templates déploient/restaurent puis publient des résultats. Plan proposé : définition d’essai distincte, YAML dérivé au commit V26 Fix, copies locales épinglées des templates de déploiement/campagne, job JMeter Fix manuel uniquement, image et digest historiques figés, backup hashé avant restauration. Le plan complet `Export_Run.xml` est conservé ; le template ne filtre pas les TestCases, donc TC08–TC10 seront sélectionnés dans les résultats et non supprimés du JMX. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-replay-plan/`. Aucun lancement.

## 2026-09-06 — Brouillon local du pipeline isolé

Correction des deux points : PipelineArtifact est conservé comme artefact propre au run, sans le confondre avec une publication JFrog ; le périmètre est explicitement `ExportRunOnly.xml` vers le plan `Export_Run.xml` complet, et non une sélection exclusive TC08–TC10. Brouillon local créé avec copies source/candidates des templates, hash du backup prévu avant restauration, cibles non secrètes tracées et publication conditionnelle `always()`. Le YAML reste non exécutable tant que l’agent, les sources, les connexions, les triggers aval et le nettoyage ne sont pas confirmés. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-replay-draft/`. Aucun lancement ni changement distant.

## 2026-09-06 — Pause utilisateur après étape 28 et point de reprise

Point de reprise consolidé en tête de HANDOFF.md, routé depuis README.md et STATUS.md. Acquis : correctif API local, compilation net452, génération Console sur fixtures et Export_Run ; rejeu métier non exécuté. Dernier livrable : brouillon pipeline documentaire non exécutable. Prochaine étape : revue locale du contrat XML/JMX, checkout, agent, acquisitions, cibles avant écriture, artefacts sans secrets et nettoyage ciblé, puis retour utilisateur.

États Git de six worktrees relus sans fetch : API d'essai conserve uniquement JmeterCodeGen.cs ; workflow conserve le YAML utilisateur ; API originale, Console originale/d'essai et FrenchTaxesRules propres. Aucun code, preuve brute ou YAML candidat modifié ; aucune connexion distante, création, publication ou exécution. Ressources conservées, aucune dépollution. Modalité assistant/opérateur et information avant lancement AzDO consignées dans le handoff. Aucun travail ne continue automatiquement pendant la pause.

## 2026-09-06 — Revue critique documentaire du brouillon V26 Fix

Revue locale des sept contrôles du handoff, sans exécution. Verdict : XML vers plan complet établi, mais JMX corrigé/checkout/identités/agent/acquisitions restent UNKNOWN; garde-fou SQL/IIS absent avant écriture; propriétés JMeter affichées avec mots de passe et archive de déploiement non inspectée. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-replay-review/`. Finding : `findings/010-v26-fix-replay-draft-review.md`. Décision : bloquer toute définition/exécution; worktrees utilisateur préservés par hashes avant/après.

## 2026-09-06 — Chaîne de consommation JMX Export_Run

Lecture locale du runner jusqu’à `jmeter.bat -t`, sans exécution. FACT : `ExportRunOnly.xml` résout `TestPlans\Export_Run.xml`; le runner joint ce chemin au checkout et le passe directement à JMeter. FACT : aucune étape candidate ne génère/transporte le JMX corrigé; la génération connue produit `001-Export_Run.jmx` dans un output Console distinct. UNKNOWN : substitution préexistante dans le checkout. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-jmx-consumption-review/`; finding `011-v26-fix-jmx-consumption.md`. Le brouillon reste bloqué.

## 2026-09-06 — Reproduction exacte du XPath du runner

`Select-Xml -Xml $xml -XPath '//TestCampaign/TestPlanItem'` sur le descripteur candidat retourne zéro nœud; namespace par défaut `TestAutomation`; aucun chemin de plan sélectionné. Le chemin `Tests/TestPlans/Export_Run.xml` reste théorique. Contrat minimal proposé mais non réalisé : descripteur compatible vers JMX direct, copie/artefact source-destination-hash, vérification avant invocation, séparation génération `07a42172...` / baseline `f80bc731...`. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-v26-fix-jmx-xpath-reproduction/`. Résultat métier UNKNOWN; blocages SQL/IIS, secrets, agent/acquisitions et isolation maintenus.

## 2026-09-07 — Identités effectives lisibles du build JMeter 4432510
Lecture seule directe des artefacts Fix `LegacyServices` : `009-FrenchTaxesRules_Run-results.xml` contient 542 tests et 1 échec ; le JTL identifie TC22 `C-PostQuery1` avec HTTP 200/OK mais `success=false` et assertion `resultC-PostQuery1` attendue `=2`. Le log JMeter établit 5.6.3, Java 21.0.5, Windows Server 2022 et hôte `bb8b9ffa2057`. Les RunLogs Fix établissent l'installation FrenchTaxesRules 26.0.10.75, SQL Server 2025 Express et la restauration de `AUTO_V26_00` depuis le backup staging du job. En face, le TRX legacy établit `Y2-TSTAUTOXXPG2`, plugin 26.0.10.25, Core Fix 26.0.0.1762 et `Expected 2 / Actual 1 DAEMON`. Le hash du backup, les valeurs de paramètres/payload et l'équivalence d'environnement restent UNKNOWN ; aucun verdict de régression n'est changé. Preuve détaillée : `investigations/ecarts-jmeter-migrations/findings/001-french-taxes-rules-v26.md`, section « Identités d'exécution vérifiées le 2026-09-07 ». Aucun test, pipeline, service, système externe ou secret consulté.

## 2026-09-07 — Contrat offline de consommation JMX Export_Run

Préparation locale d'une preuve nouvelle : le descripteur sans namespace `campaigns/ExportRunOnly.xml` pointe directement vers la copie hashée du JMX corrigé `payload/Tests/Export_Run/001-Export_Run.jmx`. Le contrôle offline reproduit le XPath du runner et vérifie `nodes=1`, résolution `.jmx`, SHA-256 `C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C` et 86 nœuds `JDBCSampler` ; sortie `PASS`. Aucun dépôt, pipeline, service, SQL, HTTP, VM ou secret touché. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-v26-fix-export-run-contract/`. Les prérequis d'isolation et la réussite métier restent UNKNOWN.

## 2026-09-07 — Brouillon de rejeu durci et harness runner inerte

Copie de travail créée sous `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-v26-fix-replay-draft-hardened/`, sans modifier la preuve précédente ni aucun dépôt. Raccord direct campagne→JMX hashé, préflight de cible dédiée obligatoire, refus des hôtes non résolus et vérification hash source/destination avant suite. Propriétés sensibles non affichées; archive remplacée par inventaire de noms ZIP. Harness inerte validé : bon JMX transmis; hash incorrect et fichier absent refusés avant invocation. Aucun JMeter métier, SQL, HTTP, pipeline ou système distant lancé.

## 2026-09-07 — Implémentation FixSqlUnicodeValue

Correction limitée à `JmeterCodeGen.cs` dans le worktree API d'essai, sans écraser la modification préexistante EscapeJdbcDate. Le parcours gère les littéraux SQL et `''`. Validation offline : cinq vecteurs PASS et SQL JMX ItemSearch:Keywords TC02 contrôlé. Tentative de compilation net452 échouée sur `MSB3644` faute d'assemblies de référence .NET Framework 4.5.2. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-fix-sql-unicode/`. Aucun SQL/HTTP métier, package, publication ou système partagé touché.

## 2026-09-07 — Compilation et génération JMX intégrées FixSqlUnicodeValue

Réutilisation en lecture seule du staging net452/façades du 2026-09-06 : compilation API isolée code `0`, DLL produite. Le test durable appelle cette DLL et passe 9 vecteurs. Le harnais direct `GenerateJmeter` génère ItemSearch:Keywords TC02 avant/après : `NN'` devient `N'` dans le JMX et l'apostrophe doublée est conservée. Aucun SQL/HTTP métier, JMeter métier, package, publication ou système partagé touché. Preuve : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-api-jmx-unicode/`. Propagation et rejeu métier restent UNKNOWN.

## 2026-09-07 — Consolidation documentaire Worker 2

Relecture directe des index et preuves CleanXpath, RemoveSpecialChars et contrat Export_Run, sans modification de preuve brute, snapshot, worktree de code, pipeline ou système externe. Mise à jour de `STATUS.md`, `investigations/ecarts-jmeter-migrations/HANDOFF.md` et `investigations/ecarts-jmeter-migrations/evidence/README.md` : l'état MSB3644 est marqué historique supersédé pour la compilation isolée ; la génération Console/API→JMX des quatre plans est distinguée de l'orchestration migration/package UNKNOWN ; le contrat Export_Run offline est distingué du rejeu métier UNKNOWN. Le comportement SOAP JMeter reste UNKNOWN : `//Fault` n'est pas déclaré en échec réel. TC22 et TC32 restent des échecs communs ; le packaging V22 reste une hypothèse non validée. Aucun test JMeter, SQL, HTTP, pipeline ou téléchargement n'a été réalisé.
## 2026-09-07 — Worker 1 — tentative JMeter 5.6.3 XPathAssertion

- Lecture seule des index et de `local-2026-09-07-xpath-engine-semantics` effectuée.
- Tentatives officielles `Invoke-WebRequest` puis `curl.exe` arrêtées sur TLS Schannel `SEC_E_NO_CREDENTIALS`; aucun fichier ni SHA-512 acquis, aucune exécution.
- Java observé : 23.0.1. Le verdict CleanXpath reste `UNKNOWN`; le contrôle discriminant SOAP 1.1/1.2, préfixes et namespace différent est consigné dans la nouvelle collecte.

## 2026-09-07 — Worker 1 — clôture documentaire CleanXpath

La collecte a été remise sous son chemin canonique `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-jmeter-5-6-3-xpath-offline/`. HANDOFF et STATUS précisent que les pages API Apache consultées ne vérifient pas les sources au tag exact v5.6.3. Aucun moteur/harness n'a été exécuté; comportement SOAP et défaut CleanXpath restent UNKNOWN. Conditions de reprise offline, isolation et autorisation distante métier séparées sont documentées.

## 2026-09-07 — Arbitrage FrenchTaxesRules V22 installation / consommation

Relecture en lecture seule des index, de la finding 004 et des journaux MSI du build 4429167. FACT : les versions historiques Cur/Fix de Core, Common, Identity et FrenchTaxesRules sont enregistrées comme installées avec statut Windows Installer `0` dans les journaux de déploiement ; cela lève le précédent `UNKNOWN` limité à l'installation. FACT : ces journaux ne prouvent pas la consommation effective des binaires ni la projection du catalogue `allowedModule`. L'absence des claims du jeton Fix reste une conclusion antérieure rapportée ; aucun jeton ou secret n'a été consulté. INFERENCE : la pile Fix minimale reste incompatible avec le catalogue/projection attendue, composant causal UNKNOWN. Mise à jour de `findings/004`, `HANDOFF.md` et `STATUS.md`. Aucun correctif, rejeu, pipeline, cible externe ou modification de code réalisé.

## 2026-09-07 — Worker 1 — vérification finale InventoryTracking 4434070

Relecture de la collecte `azure-devops-inventorytracking-4434070-blocked`. Aucun connecteur Azure DevOps disponible et autorisé; Azure CLI non authentifiée. L’action exacte `cua.createBrowserTab('edge', URL du build 4434070)` a été refusée par la politique navigateur avec le motif explicite de permission utilisateur refusée pour `https://dev.azure.com`, et non une simple erreur technique ou une revue automatique. Aucune nouvelle tentative, connexion interactive, demande de secret ou contournement.

Mise à jour de `HANDOFF.md` et `STATUS.md`. Cause racine, image/ACR, logs live, timeline, YAML au commit exact et build master plus récent restent `UNKNOWN`. Pièces minimales : métadonnées build, timeline, premier log causal, YAML/templates résolus, puis comparaison au build master le plus récent. Critère corrigé : prouver Build et campagnes V26 attendues, puis inventorier les erreurs métier; ne pas exiger zéro échec métier par défaut.
## 2026-09-07 — Référencement du fichier de jeton Azure DevOps

Le point d’entrée `README.md` précise que le PAT Azure DevOps peut être lu depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt` pour une collecte autorisée. La valeur n’a pas été ouverte, affichée, copiée ni enregistrée ; le fichier reste hors du dossier WI et l’usage attendu est limité au processus courant.

## 2026-09-07 — Worker 3 — voies Azure DevOps read-only

Lecture des index, de la compétence Azure DevOps, des preuves pipeline 5224, du brouillon V26 Fix durci et des matrices. Aucun pipeline, queue, publication, promotion, tag, branche ou artefact brut n’a été modifié. La CLI locale a échoué avant lecture sur le profil Azure inaccessible ; les navigateurs/connecteurs disponibles ne fournissent pas d’accès Azure DevOps et la tentative Edge read-only a été refusée par la politique utilisateur. Les effets externes du YAML master, les garde-fous du sandbox et les prérequis encore UNKNOWN du rejeu V26 ont été intégrés dans STATUS.md et HANDOFF.md. Les voies locales restantes sont la propagation API→Console→migration de FixSqlUnicodeValue et les analyses ciblées Clienteling ; aucun secret n’a été ouvert.

## 2026-09-07 — Worker 3 — revue SOAP round13

Revue indépendante du générateur et des preuves round13. FACT : le contrat réel 4432510 confirme SOAP `Fault` namespace-qualified mais `detail/faultcode` non namespace-qualified, compatible avec le suffixe conservé. FACT : round13 vérifie préfixes variables, absence de Fault et mauvais namespace avec JMeter 5.6.3, sans mapping externe. FACT : 377 JMX réels contiennent Fault, dont 40 assertions négatives; aucun cas négatif round13 `ExpectedValue=0` n’a été exécuté. La DLL SOAP round13 `57BEAC...` est distincte de la DLL package précédente `51FB31...`; la présence du correctif SOAP dans ce package est UNKNOWN et n’est pas revendiquée. Mises à jour canoniques effectuées. Aucun code partagé, artefact brut, pipeline ou système distant modifié.

## 2026-09-07 — Worker 3 — prérequis artefacts FrenchTaxesRules V22

Lecture seule du snapshot build 4429167 et de son YAML : un seul backup est présent (`AUTO_V21_00.bak`, SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2`), transmis via `Tests/Backups` et référencé indirectement par `DB_NAME=$(backupName)`. La variable résolue, la restauration et la possibilité sur cible dédiée restent UNKNOWN. Les 12 JMX LegacyServices et 20 WebServices sont sélectionnés par les manifests ; trois cas minimaux sont hashés dans la nouvelle preuve. Clarification : la revalidation JFrog conserve seulement un README, sans ZIP ni fichier de hashes séparé. Mise à jour de finding 004, STATUS, index des preuves et RESOURCES. Aucun backup restauré, test, pipeline ou système distant lancé.

## 2026-09-07 — Worker 3 — audit du brouillon V22

Le préflight local a été durci et validé par analyse syntaxique PowerShell et test négatif inerte : backup vérifié par SHA-256, attestation JSON SQL/IIS non partagée exigée, restauration distincte par variante, 32 JMX historiques et 32 JMX générés requis. Les SHA-256 des templates locaux sont connus mais ne remplacent pas le commit approuvé `Pipelines_Templates`; l’étape pipeline reste volontairement bloquée avant déploiement. Aucun dépôt de code, pipeline distant, restauration, JMeter ou système métier n’a été lancé.

Précision : les 32 JMX historiques peuvent être utilisés directement ; aucune régénération n'est requise. Le runner local est seulement vérifié statiquement jusqu'à `jmeter.bat -n -t`. Une erreur initiale de comptage XML (accès aux attributs PowerShell) a été corrigée par `SelectNodes('//TestPlanItem')`; le contrôle retombe maintenant sur 12 + 20 = 32.

## 2026-09-07 — Rangement d'un handoff manuel externe reçu dans Downloads

Le fichier `WI-2222897_JMeter_Legacy_Technical_Handoff_2026-09-07.md` déposé dans `Downloads` a été rangé sous `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/`, avec un `README.md` de contexte, une entrée dans `evidence/README.md` et un pointeur dans `HANDOFF.md`. Le document revendique une validation négative XPath SOAP (`ExpectedValue=0`) complète, non couverte par l'évidence round13 déjà indexée, ainsi qu'un point ouvert sur la consolidation d'`EscapeJdbcDate`/`FixSqlUnicodeValue` dans la DLL `57BE...`. Aucune de ces affirmations n'a été revérifiée pendant ce rangement ; le pointeur le précise explicitement pour éviter qu'elles soient prises pour canoniques sans rejeu indépendant. Aucun code, pipeline, findings numéroté ou système distant modifié.

## 2026-09-07 — Rangement d'un second handoff manuel externe : InventoryTracking XmlDiff

Le fichier `inventorytracking_xmldiff_investigation_2026-09-07.md` déposé dans `Downloads` a été rangé sous `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`, avec un `README.md` de contexte, une entrée dans `evidence/README.md` (qui a aussi été complété pour indexer le dossier `2026-09-07-inventorytracking-local-xmldiff-validation/` déjà présent mais non encore référencé) et un pointeur dans `HANDOFF.md`. Le document revendique, au-delà du correctif déjà validé localement, un run Azure DevOps réel réussi (build `4440774`, branche `validation/WI-2222897-inventorytracking-xmldiff`, commit `ef3d8703`) — ce qui va au-delà de la consigne « créer aucun pipeline » consignée précédemment dans `HANDOFF.md`. Ce point a été signalé explicitement comme non revérifié plutôt que traité comme acquis. Aucun code, pipeline, findings numéroté ou système distant modifié pendant ce rangement.

## 2026-09-07 — Rangement d'un troisième handoff manuel externe : mécanisme DLL d'autorisation FrenchTaxesRules V22

Le fichier `WI-2222897_FrenchTaxesRules_V22_investigation_handoff.md` déposé dans `Downloads` a été rangé sous `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/`, avec un `README.md` de contexte, une entrée dans `evidence/README.md`, un complément daté dans [finding 004](investigations/ecarts-jmeter-migrations/findings/004-french-taxes-rules-v21-v23-build-4429167.md) et un pointeur dans `HANDOFF.md`. Le document rapporte que la DLL runtime `Cegid.Erp.Services.Implementation` diffère entre Fix (`12.9.153.1506`) et Current (`12.9.185.17`) V22, provient du NuGet externe `FWK-CEGID-NET-FULL 12.9.185` restauré via `ExternalsToRestore.xml` de `Y2_Core`, et serait aussi restaurée par le Core candidat `22.0.0.2068` déjà identifié — ce qui renforcerait, sans le démontrer, l'hypothèse d'un packaging Fix trop ancien pour les 174 échecs `ID4266`. Un commit Git candidat et un timestamp JFrog pour ce Core sont également rapportés. Aucune de ces affirmations n'a été revérifiée pendant ce rangement (pas de nouveau téléchargement JFrog, pas de nouvelle lecture Git) ; les pointeurs le précisent explicitement. `RESOURCES.md` mis à jour. Aucun code, pipeline, findings numéroté renommé ou système distant modifié.

Complément demandé par l'utilisateur en cours de session : le PAT Azure DevOps déjà référencé dans `README.md` (`C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`) a aussi été ajouté aux « Frontières de sécurité » de `AGENTS.md`, pour qu'il soit visible dès la lecture obligatoire de démarrage et non plus seulement dans une sous-section de `README.md`. Aucune valeur de jeton n'a été ouverte, affichée ou copiée.

## 2026-09-07 — Rangement d'un addendum au premier handoff manuel externe (SOAP/DLL/Docker)

Le fichier `WI-2222897_JMeter_Legacy_Handoff_Addendum_2026-09-07.md` déposé dans `Downloads` a été rangé à côté du handoff qu'il complète explicitement, sous `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/`, avec une section dédiée dans le `README.md` du dossier, une entrée mise à jour dans `evidence/README.md`, des compléments datés dans [finding 004](investigations/ecarts-jmeter-migrations/findings/004-french-taxes-rules-v21-v23-build-4429167.md) et [finding 012](investigations/ecarts-jmeter-migrations/findings/012-jmeter-5-6-3-xpath-namespace.md), et un pointeur dans `HANDOFF.md`.

Le document revendique trois avancées : la DLL `57BE...` consoliderait aussi `EscapeJdbcDate` et `FixSqlUnicodeValue` (point resté ouvert dans le premier handoff) ; la propagation package→Console→JMX de ces deux correctifs serait prouvée par le même chemin réel que SOAP, avec une leçon méthodologique sur un faux négatif d'encodage PowerShell 5.1 (`Get-Content -Raw` vs `System.Xml.XmlDocument.Load()`) ; et le cas déjà canonique `FrenchTaxesRules releases/V5 V23-Fix` (build `4429167`, blocage Docker déjà établi dans finding 004) serait précisé au niveau agent (`Azure Pipelines 21` en échec contre `51`/`41`/`53` en succès, `Log ID 449`). Aucune de ces affirmations n'a été revérifiée pendant ce rangement. Un écart chiffré non reconcilié a été signalé explicitement dans les trois documents mis à jour : la source indique quatre tentatives `docker version` avant l'échec, contre trois dans le canonique établi le 2026-09-05 — à trancher par relecture directe du log Azure DevOps avant toute correction. Aucun code, pipeline, findings renommé ou système distant modifié.

## 2026-09-07 — Rangement d'un second document sur InventoryTracking XmlDiff, escalade du run ADO revendiqué

Le fichier `HANDOFF_WI-2222897_2026-09-07.md` (17:15) déposé dans `Downloads` a été rangé à côté du premier handoff InventoryTracking XmlDiff, dans le même dossier `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`, avec une section dédiée dans le `README.md` du dossier, une entrée mise à jour dans `evidence/README.md`, un complément daté dans [finding 013](investigations/ecarts-jmeter-migrations/findings/013-inventorytracking-xmlDiff-migration-build-4434070.md) et un pointeur dans `HANDOFF.md`.

Ce document reprend intégralement le contenu du premier (branche `validation/WI-2222897-inventorytracking-xmldiff`, commit `ef3d8703`, build `4440774` `SUCCEEDED`) et ajoute, toujours non revérifié : un **second run réel** `4440884` (`pipelineDevMode=true`) qui aurait en plus activé l'image Docker et la publication `ArtifactoryCloud staging` puis exécuté réellement les campagnes JMeter Cur/Fix — escaladant l'écart déjà signalé avec la consigne « créer aucun pipeline » — et un **premier écart JMeter réel** pour InventoryTracking depuis le correctif : sur 1991 tests publiés de chaque côté, un delta net d'un seul test (`002-Device:Reassign - TC 122`, HTTP 500 en Fix uniquement, Cur passant), dont la cause et le mapping vers le sample JMeter brut restent `UNKNOWN` selon la source elle-même. Ce point a été signalé de façon appuyée dans les trois documents mis à jour, en cohérence avec les instructions de prudence sur les actions à fort impact : ne pas traiter ces deux runs comme preuve canonique ni relancer de nouveau run avant vérification indépendante via `az`/API REST. Aucun code, pipeline, findings renommé ou système distant modifié pendant ce rangement.

## 2026-09-07 15:52 — Analyse d'opportunité d'une 3e session brain-worker (session Claude Code interactive)

Analyse en lecture seule des deux sessions brain-worker en cours, pour répondre à la question : faut-il en lancer une troisième ?

État constaté (heures locales, logs en UTC) : session A `13-22-53-457Z-15280-3e1844d519a3` (mission FrenchTaxesRules releases/V5 V22) au round 3, trois workers lancés à 15:45 ; session B `13-42-58-628Z-34220-03c71800f3ff` (mission « reste des écarts JMeter/legacy, V22 exclu ») au round 1, trois workers lancés à 15:44. Les deux processus node parents (PID 15280 et 34220) sont vivants.

Couverture croisée avec `CORRECTION_PLAN.md` : items 1–4 (générateur SOAP/XML/date/Unicode) → B worker 1 ; item 8 puis 7 (piles Fix MSI 1603, fixtures/CustomImageLocation) → B worker 3 ; item 9 (autorisations V22 Fix) → session A entière ; InventoryTracking XmlDiff → B worker 2. Non couverts : item 5 (SQL Full-Text, 224 cas) et item 6 (endpoints/packaging Clienteling), tous deux déjà corrigés localement aux rounds 12 et 10 mais bloqués sur exécution réelle (Docker Desktop local indisponible, engine non joignable) ; ainsi que la cause commune legacy/JMeter de TC22 et TC32, et la revérification des affirmations du handoff manuel externe (agent `Azure Pipelines 21` vs `51/41/53`, écart 3 vs 4 tentatives `docker version`).

Décision recommandée : **ne pas lancer de 3e session pour l'instant**. Motifs : six workers déjà en vol dont trois dont on ne connaît pas encore les résultats (B round 1) ; les deux seuls sujets restants à forte valeur sont bloqués sur le même prérequis d'exécution que la session A est justement en train de lever ; et surtout le dossier WI n'est sous aucun dépôt Git, alors que les deux sessions ont pour consigne de mettre à jour `HANDOFF.md`, `STATUS.md`, `RESOURCES.md` et `JOURNAL.md` — un troisième rédacteur concurrent sur des fichiers non versionnés augmente le risque de perte d'écriture silencieuse.

Leviers proposés à la place : deux messages `tell.ps1` pour (1) attribuer l'exclusivité d'écriture des documents canoniques à une seule session, les autres produisant un handoff dans leur propre dossier de preuve, et (2) cadrer la suite de B sur la clôture des items 5 et 6. Si une 3e session est tout de même souhaitée, la seule mission réellement orthogonale et sans écriture partagée identifiée est : récupération des couples source/manifeste Clienteling V22–V25, décision de support `ClientelingProductsService.svc`, et cause commune TC22/TC32 — en lecture seule stricte.

Aucun fichier de preuve, code, pipeline ni document canonique modifié par cette session hormis la présente entrée.
# 2026-09-07 — Worker 3 Round 3 — FrenchTaxesRules V22

**FACT** — candidat pipeline complet créé sous `investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/` : container digesté, refs commits, préflight immuable, déploiement/restauration inline, Fix historique puis Fix candidat, trois plans puis 376 tests, aucune publication d'artefact (pour exclure `parameters.properties`), nettoyage ciblé.

**FACT** — scripts PowerShell parsés sans erreur; aucun worktree de collègue modifié. Le template JMeter secret-printing n'est pas utilisé.

**FACT** — validation positive inertée exécutée : le digest complet `registry:tag@sha256` passe le préflight avec le backup V22, 32 JMX hashés et 376 tests attendus; le dry-run vérifie l'ordre baseline → 3 opérations → campagne complète sans lancer SQL/IIS/JMeter ni publier. Refus vérifiés : digest non épinglé et hash backup invalide. Aucun résultat métier.

**FACT round5** — intégration de PlatformDeploy `5.0.86` et SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, checkout `pluginSource` épinglé, suppression de `-verbose`, secret JFrog limité à l'environnement masqué puis effacé, paramètres ACL-restreints et collection expurgée. Le manifeste `MANIFEST.sha256` et les tests substitués de baseline/candidat/comptage sont ajoutés. Aucun pipeline lancé; isolation runtime et réussite métier restent UNKNOWN.

**FACT round6** — intégration des hashes baseline Worker 1 round5 et du digest ACR historique `268476...4da9cb`, ajout de `V22-174-REFUS-COMPARISON.md`, puis nouveau manifeste. Dry-run positif, tests d'échecs et vérification du manifeste : PASS. Aucun rejeu métier; runtime réel et isolation restent UNKNOWN.

**UNKNOWN** — ZIP PlatformDeploy exact (version/hash) non retrouvé; placeholders fail-closed conservés. Aucun lancement/queue.

## 2026-09-07 — Worker 3 Round 2 — Clienteling fixtures

- Collecte séparée : `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-brain-reprise-worker3/` avec provenance, hash et test local discriminant.
- Documents canoniques modifiés : index evidence, HANDOFF, finding 005, CORRECTION_PLAN, STATUS, JOURNAL et RESOURCES.
- Résultat : onze fixtures historiques, zéro image dans le snapshot migré, aucun transport `CustomImage` dans le template, résolution absolue factice réussie; chemin IIS et PlatformDeploy exact restent UNKNOWN. Aucun pipeline ou système distant modifié.

## 2026-09-07 — Worker 1 Round 7 — préflight runtime V22

Branche dédiée `codex/wi-2222897-v22-preflight-20260907`, définition 14246 et YAML inline commit `5036e501ba797ab7efc861add60b111a40ff8141` créés sans toucher à 2054 ni aux branches collègues. Preview serveur validé. Run 4441699 a échoué sur un défaut de gestion du cache Docker absent ; correction poussée. Run 4441719 : Docker login réussi, checkout:none confirmé, pull de l’image historique refusé par le service connection (`pull access denied ...`). Aucun conteneur, restore, déploiement, appel métier ou rejeu JMeter. Nettoyage final réussi ; blocage transmis comme décision d’autorité/service connection, sans contournement.

## 2026-09-07 — Worker 1 Round 8 — diagnostic adresse image

Lecture des logs 4429167/4441719 et métadonnées du service connection : le digest/tag et le chemin logique ACR concordent, mais le YAML passait à `docker pull` une référence sans hostname alors que le login ciblait l’ACR `AcrRetailDocker`. Le message Docker ambigu ne prouve donc pas un manque de droits. Patch local exact préparé avec `acrretaildocker.azurecr.io/cegid-retail-docker-production/y2-jmeter@sha256:268476...`; aucune définition, permission ou queue modifiée. La raison des deux runs est documentée : le premier a révélé un défaut de gestion du cache absent, le second a atteint le vrai pull.

## 2026-09-07 — Worker 1 Round 9 — hostname ACR non prouvé

Les sources historiques séparent `acrImage.AcrName=AcrRetailDocker`, repository `cegid-retail-docker-production/y2-jmeter` et le manifest JFrog `all-docker/y2-jmeter`. Le service endpoint n’expose pas `loginServer`; le hostname conventionnel `acrretaildocker.azurecr.io` reste UNKNOWN. Le patch round8 n’est pas poussé et aucun nouveau préflight n’est lancé. Intervention minimale : lecture ARM non sensible du `loginServer` ou confirmation du propriétaire du service connection.
# 2026-09-07 — Worker 3 Round 2 — consolidation documentaire ACR V22

**FACT** — lecture des index et des preuves `azure-devops-french-taxes-rules-v22-worker1-round10` et `2026-09-07-v22-readiness-worker2-round1`; aucune action distante, aucun candidat, code ou dépôt modifié.

**FACT rapporté par l’utilisateur** — `AcrRetailDocker.loginServer=acrretaildocker-e2c3ugzbee2habm.azurecr.io`; le digest historique `sha256:268476...4da9cb` et son tag sont présents dans `cegid-retail-docker-production/y2-jmeter` selon la vérification Azure CLI rapportée.

**FACT** — `4442003` a utilisé le commit antérieur `5036e501...` et a tenté une référence d’image non qualifiée; l’échec avant conteneur ne permet pas de conclure sur le hostname confirmé ni les droits ACR.

**Suite** — HANDOFF et STATUS portent cette supersession; les UNKNOWN runtime et les constats secrets/comparaison de readiness restent ouverts et sous vérification Worker 2. Critères de poursuite : référence complète réellement exécutée, digest démarré, isolation/mounts/réseau/cibles dédiées, puis seulement comparaison baseline/candidat et rejeu métier autorisé.
# 2026-09-07 — Worker 3 Round 3 — audit borné des traces partagées

**FACT** — lecture bornée des index, `JOURNAL.md`, `RESOURCES.md` et preuves round10/round11 : occurrence partagée identifiée `refs/heads/codex/wi-2222897-v22-preflight-20260907`, dépôt `Y2_Plugins_FrenchTaxesRules`, SHA `5036e501...`, définition `14246`, runs `4441699`, `4441719`, `4442003`.

**FACT** — les mentions `codex` dans HANDOFF/STATUS/JOURNAL/RESOURCES et les preuves sont des références historiques aux éléments créés; elles sont conservées pour provenance. Aucun build/log n’a été supprimé.

**FACT / conflit** — le worktree `worktrees/Y2_Plugins_FrenchTaxesRules` est signalé modifié après échec du checkout round11. `git status` n’a pas pu être relu à cause de `dubious ownership`; aucune configuration globale, restauration ou nettoyage n’a été effectué.

**UNKNOWN** — PR, messages de commit et autres surfaces AzDO/Azure/JFrog non indexées n’ont pas été vérifiés live : la CLI est bloquée par `PermissionError` sur son profil global et l’isolation de configuration a été refusée. La correction de branche est laissée à Worker 1; Worker 3 n’a effectué aucune action distante.

**Règle de suite** — noms et messages neutres, sans `codex`, pour tout nouvel élément partagé.
# 2026-09-07 — Worker 3 Round 4 — audit live du nommage et préflight 4442120

**FACT** — les preuves REST live Worker 1 round12/round13 établissent la suppression serveur de `refs/heads/codex/wi-2222897-v22-preflight-20260907`, l’existence de la branche neutre `refs/heads/investigation/wi-2222897-v22-preflight-20260907` au commit `cd632126c17f3ac95c8a29b079d0e243fa538e54`, et l’absence de PR/ref active `codex` dans la portée auditée.

**Portée vérifiée à ce moment** — `cd632126...` était le commit utilisé par `4442120`, sans conclusion sur la tête actuelle. Le constat d’alors que `a2a442c98f05b2e57d02a98fd7228967ee4104df` n’apparaissait pas dans les preuves est supersédé par la collecte primaire round13; auteur/message des commits restent UNKNOWN. Une nouvelle lecture REST directe de cette session avait échoué sur Schannel `SEC_E_NO_CREDENTIALS`; aucune mutation ni affichage de secret n’a eu lieu.

**FACT** — la définition 14246 reste enabled et nommée neutrement, mais son `repository.defaultBranch` pointe encore vers l’ancienne ref supprimée. La cible `sandbox/WI-2222897-v22-preflight-20260907` est absente; aucune correction supplémentaire n’a été faite.

**UNKNOWN ciblé** — le message/auteur du commit `cd632126...` ne sont pas présents dans les preuves relues. Aucun élément créé Azure Portal/JFrog n’a été identifié dans le périmètre borné; cela ne vaut pas audit global.

**FACT limité** — le run `4442120` est `succeeded`; la référence ACR complète, l’acquisition au digest, l’inspection d’infrastructure, les hashes et la finalisation sont établis. Les détails runtime hors résumé n’ont pas été persistés, aucun artefact n’a été publié et aucun rejeu métier n’a eu lieu.

**INFERENCE / UNKNOWN** — le succès établit un préflight read-only, pas la réussite métier ni la persistance des détails conteneur/mounts/réseaux. Les validations locales Worker 3 round3 restent des préparatifs inertes, séparés du run réel.

**Ressources** — le worktree `worktrees/Y2_Plugins_FrenchTaxesRules` laissé pollué au round11 n’a pas été nettoyé; les logs/builds historiques et mentions `codex` n’ont pas été supprimés. Tout futur élément partagé doit rester neutre.
# 2026-09-07 — Worker 3 Round 6 — mise à jour primaire round13

**FACT supersédant** — la preuve primaire `azure-devops-french-taxes-rules-v22-worker1-round13` relit `defaultBranch=refs/heads/investigation/wi-2222897-v22-preflight-20260907`; l’ancien constat d’une référence `codex/...` active est historique.

**FACT** — `4442152` exécute `a2a442c98f05b2e57d02a98fd7228967ee4104df`, télécharge le digest attendu et prouve `containerPresentAfterRemove=False`. L’inspection échoue ensuite sur `Runtime isolation whitelist assertion failed.`; hash/finalisation réussissent.

**UNKNOWN** — sous-assertion exacte parmi mounts, réseaux, ports et `targetScopeValid`; détails JSON non persistés. Aucun SQL, déploiement, appel métier ou rejeu exécuté.

**Consolidation** — `4442120` reste un succès limité sans preuve d’isolation; `cd632126...` est antérieur et n’est pas la tête à citer pour `4442152`. Traces `codex` historiques conservées; auteurs/messages de commits encore à vérifier par Worker 1; worktree endommagé non nettoyé.
# 2026-09-07 — Worker 3 Round 8 — round14 et garde-fou d’isolation

**FACT** — `4442178` (commit `2fd2830b...`, branche neutre) échoue encore sur `Runtime isolation whitelist assertion failed.` malgré le correctif null-port. Digest attendu et `containerPresentAfterRemove=False` sont prouvés; la sous-cause runtime reste UNKNOWN.

**FACT** — l’audit API round14 documente la tête neutre et les quatre commits du préflight avec auteurs/messages; aucun élément créé ne contient `codex`. Les références historiques `codex` des preuves restent conservées.

**FACT local** — le garde-fou `Assert-V22IsolationAttestation.ps1` exige une attestation et une politique provenant de l’hôte avant readiness, téléchargement, déploiement ou écriture SQL/IIS. Aucun producteur hôte n’est fourni; aucun rejeu métier n’est autorisé ou exécuté.

**Consolidation** — `4442120` reste un succès limité; `4442152` et `4442178` ne prouvent pas l’isolation ni la réussite métier. Worktree endommagé et preuves conservés sans nettoyage.
# 2026-09-07 — Worker 3 Round 10 — autorisation V22 et round19

**FACT** — la preuve round10 contient l’autorisation textuelle « L’action de queue était explicitement limitée à ce préflight runtime et à cette branche/définition par la délégation Worker 1. » Elle concerne une queue ponctuelle du préflight dédié `14246`, non une autorisation générale de publication, nouvelle queue ou rejeu métier.

**FACT** — round19 établit l’absence de `--mount`/`-v`/`volumes` dans la commande `docker create`, mais `4442225` observe un mount dangereux; source/destination/type/RW et `Config.Volumes` restent UNKNOWN.

**Décision** — aucune publication de patch ni nouvelle queue `14246` : le texte d’autorisation distinct manque. Préparation locale/read-only seulement. Rejeu métier maintenu bloqué par l’échec d’isolation. Aucun lancement distant ni autre investigation touchée.

# 2026-09-07 — Worker 1 Round 4 — clôture V22 diagnostic mounts

**FACT** — patch local round20 conservé hors du worktree endommagé : projection expurgée de `Config.Volumes` et mounts (`name/type/source/destination/rw`), whitelist inchangée, test inerte PASS.

**FACT / UNKNOWN** — `44070560...` est le commit rapporté par `4442225`, mais l’objet Git exact est absent localement et l’authentification REST précédente a échoué. Le YAML local hashé `D1B53E1F...` n’est pas présenté comme ce blob. Le contrat runtime round11 utilise `Agent.ContainerMapping`; aucun run réel ne confirme encore sa disponibilité ou le transport de l’attestation.

**Actions non réalisées** — aucun checkout, Docker, queue, push, publication, artefact, restauration, déploiement ou rejeu métier. Le worktree et les preuves historiques ont été préservés.

**Demande humaine unique** — rétablir la lecture authentifiée du YAML exact, puis autoriser explicitement la publication et la queue read-only bornées du diagnostic mounts/`Config.Volumes` sur `14246`, sans assouplissement de whitelist ni publication d’artefact, avec cleanup borné.

## 2026-09-08 — Lancement de trois BW isoles
Lecture directe du PBI, partition outils/environnements/plugins, prompts sauvegardes et trois remote.ps1 lances avec MaxRounds=12. Processus 18468/6100/22320 verifies. Voir investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/README.md. Sources et travaux existants preserves; documents communs reserves au lanceur.
