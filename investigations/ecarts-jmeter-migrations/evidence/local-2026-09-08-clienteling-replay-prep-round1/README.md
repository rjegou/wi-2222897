---
type: "Evidence"
title: "Clienteling master V26 — préparation live du rejeu Build + JMeter Cur/Fix"
description: "Lecture Azure DevOps datée des définitions, branches, YAML, templates et derniers runs utiles. Aucun run lancé."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-replay-prep-round1/README.md"
tags: ["Clienteling", "Azure DevOps", "JMeter", "replay-prep"]
timestamp: "2026-09-08"
source_system: "Azure DevOps REST API + dépôt documentaire local"
---

# Clienteling master V26 — préparation live du rejeu Build + JMeter Cur/Fix

## Provenance et portée

- Date de collecte : 2026-09-08, Europe/Paris.
- Système source : Azure DevOps `https://dev.azure.com/cegid/Retail`, API REST 7.1, lecture HTTPS avec le PAT fourni dans `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`.
- Le PAT a été lu en mémoire uniquement, jamais affiché, écrit dans cette preuve ou conservé dans une variable après les appels.
- Méthode : lecture des définitions Build, refs Git, builds/timelines/artefacts, puis lecture des blobs YAML et templates avec version de branche explicite. Aucun appel de queue, création, mise à jour, publication, promotion, tag ou commentaire n'a été exécuté.
- Fraîcheur : snapshot live au moment de la collecte ; les résultats Azure DevOps restent susceptibles de changer.
- Cette preuve ne remplace pas les artefacts bruts des builds historiques ; elle documente le prochain rejeu et ses préconditions.

## Verdict de préparation

**FACT** — le rejeu réel n'est pas lancé à ce tour.

**FACT** — la branche distante `Y2_Tools_AutoTest_Api:refs/heads/sandbox/clienteling/api-jmeter-fixes` existe, mais elle pointe sur le même commit que `master` : `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`. Le correctif local du générateur n'est donc pas injecté dans cette branche distante.

**FACT** — la définition Clienteling `2065 — Clienteling CI` utilise le dépôt `Y2_Plugins_Clienteling`, branche par défaut `master`, YAML `/azure-pipelines.yml`, révision de définition `5`. Le YAML live a le SHA-256 `AB9763A930312B3873CA544200AFB59B64AD59FDF6E8DBAE0BA78CFCC140E50B` (14 973 octets).

**VERDICT** — le pipeline Clienteling actuel n'est pas un chemin isolé acceptable pour le rejeu corrigé : il importe ou vérifie une image ACR depuis JFrog, publie en staging Artifactory, télécharge des packages JFrog pendant le déploiement, et possède des stages `Promote` et `Tag_Sources`. Le prochain rejeu doit utiliser une définition/YAML explicitement isolé, avec transfert par artefacts de pipeline et sans feed NuGet, promotion, tag ni publication partagée.

## Identifiants exacts à reprendre

| Objet | Identifiant live | Preuve / usage |
|---|---|---|
| Build définition Clienteling | `2065` — `Clienteling CI` | Build + déploiement + JMeter du plugin |
| Dépôt plugin | `Y2_Plugins_Clienteling` (`7776ac72-1788-4bea-9422-e5f0dacadc74`) | source des `Tests` et JMX consommés |
| Branche historique master migrée | `Clienteling_Migration_AutoTest_Jmeter_On_master` | commit `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a`, build `4432554` |
| Branche canonique plugin actuelle | `master` | commit live `0c0fd26533e46b13e029276f90b5c085c1804012` |
| API définition | `2637` — `AutoTest_Api CI` | YAML `/azure-pipelines.yml` |
| API branche d'essai | `sandbox/clienteling/api-jmeter-fixes` | commit live `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` |
| API `master` | `refs/heads/master` | même commit `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` |
| Console définition | `2641` — `AutoTest_Console CI` | branche par défaut `master` |
| Workflow JMeter définition | `5224` — `Y2 Tools Jmeter Workflow` | YAML `/azure-pipeline.yml`, branche `master` |

## Paramètres Cur/Fix et stages attendus

Le YAML Clienteling live déclare :

- `versionsToTest`: `['26']` par défaut ;
- `typesToTest`: `['Cur', 'Fix']` par défaut ;
- `campaignsToTest`: `['WebServices']` par défaut ;
- image déclarée : `$(acrImage.Repository)/$(acrImage.Name):$(acrImage.Tag)`, avec tag `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025` et conteneur `acr_y2jmeter_test` ;
- pour chaque variante, `download: current` de l'artefact `$(componentVersion)_nuget`, déploiement en conteneur, installation des outils, appel du template `PipelineTemplates/task-run-campaign.v1.yml@jmeterTemplates`, puis publication des résultats JUnit/artefacts.

Pour un rejeu master/V26 explicite, la matrice attendue est donc :

1. `Build` : génération, compilation V26, tests applicatifs et fabrication de l'artefact plugin ;
2. `TI_Jmeter_V26` / `TI_Jmeter_V26_Cur` : déploiement, JMeter `WebServices`, résultats JUnit et logs ;
3. `TI_Jmeter_V26_Fix` : même chaîne, avec configuration Fix ;
4. aucun `Publish`, `Promote`, `Tag_Sources` ou import ACR dans l'essai isolé.

**UNKNOWN** — le YAML live ne fournit pas, à lui seul, la preuve du contenu final de l'image, des JMX effectivement transmis au runner, du backup restauré, ni de la version de l'API/Console réellement chargée par le job.

## Mécanisme d'injection du candidat Console/API

**FACT** — le YAML API de la branche sandbox fabrique un NuGet, publie un artefact de pipeline nommé `Nuget`, et contient aussi des tâches `ArtifactoryGenericUpload` / `ArtifactoryPublishBuildInfo` conditionnées aux branches `master` ou `releases/*`. Il n'existe pas dans ce YAML de paramètre permettant au build Clienteling de consommer directement cet artefact inter-définition.

**FACT** — le YAML Console live construit son propre package et publie un artefact `Nuget`; sa restauration dépend du feed Artifactory dans le YAML actuel. Le candidat local Console vérifié précédemment est le package `2.0.42-soapnamespace.20260907`, SHA-256 `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`, mais aucune publication distante ni consommation par Clienteling n'est prouvée.

**INFERENCE** — une exécution corrigée exige une chaîne d'essai supplémentaire ou un YAML de mission qui transmet explicitement les artefacts API/Console par `DownloadPipelineArtifact` depuis des builds et IDs exacts, puis vérifie les hashes avant génération/consommation des JMX. Une simple queue de `2065` ne peut pas injecter le candidat local.

## Contrôle live des templates et effets partagés

| Élément lu | Révision / SHA-256 | Observation factuelle |
|---|---|---|
| `Y2_Tools_Jmeter_Workflow/PipelineTemplates/task-run-campaign.v1.yml` | `master`, `1630C6A105983FBF85994581E6B9A754639FFF28A3107B9C11E2A3ACA7D2AB80` | écrit `parameters.properties`, appelle `C:\Tools\jmeter-cli.ps1`, convertit JTL en JUnit et publie les résultats de test ; les logs doivent être contrôlés pour éviter toute fuite de paramètre |
| `Y2_Tools_Jmeter_Workflow/PipelineTemplates/task-install-y2-test-tools.v1.yml` | `master`, `0D7401305247C020D1824F702DF876D729B89EDA39603567D51043907241EFC5` | télécharge le package de test de l'artefact `$(componentVersion)_nuget` et le copie dans le contexte Y2 |
| `Y2_Tools_PlatformDeploy/Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml` | `master`, `187F9910CDAD16DA7C7029180D3E6926DCF9F97039986DA2F82137B38BEB42D5` | cherche/télécharge PlatformDeploy via JFrog, copie backup/config, déploie avec `-LocalDBInContainer Backup`, publie les logs ; ce chemin n'est pas isolé par défaut |
| `Pipelines_Templates/AzureContainerRegistry/job-ensure-docker-image-in-acr.v1.yml` | `master`, `AAF8E1671119929FDA5837646696C9DA8F8101CCF65880F07139DED5930D169A` | compare digest JFrog/ACR et peut exécuter `az acr import` |
| `Pipelines_Templates/JFrog/promote-artifacts.v1.yml` | `master`, `9877C75D23B325F0FA40ECC9DE3D769231667CBC6E2D1D7659ED62B767F0F751` | promotion d'artefacts staging vers production |
| `Pipelines_Templates/Git/tag-sources.v1.yml` | `master`, `7017463CDFA7E7B318F23FBAA264783C9C129F41C6315EB1AFDD9B7C797CD1F6` | exécute `git tag` puis `git push origin` |

**FACT** — le contrôle des destinations partagées n'est pas optionnel : le pipeline Clienteling live déclare un trigger CI sur `master`/`releases/*`, un schedule hebdomadaire, une vérification/import ACR, `Publish` staging, `Promote` et `Tag_Sources`. Le YAML API sandbox n'inclut que `master` dans son trigger ; sa branche sandbox n'est donc pas déclenchée automatiquement par ce YAML, mais les conditions de publication doivent néanmoins être contrôlées dans tout essai manuel.

## Derniers runs pertinents relus

| Build | État live | Branche / commit | Résumé de timeline | Artefacts pertinents |
|---|---|---|---|---|
| `4432554` | `completed / partiallySucceeded`, `2026-09-04` | `Clienteling_Migration_AutoTest_Jmeter_On_master` / `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a` | `Build`, `TI Jmeter V26-Cur`, `TI Jmeter V26-Fix` exécutés ; `Promote` skipped | NuGet/Software/Docs et logs/de résultats Cur/Fix |
| `4442017` | `completed / succeeded`, `2026-09-07` | `refs/pull/506336/merge` / `3b86e33706fc38390b9daecc8e821b90de96e040` | Build applicatif seulement ; aucun stage TI JMeter ; `Promote` skipped | `26.0.10.32_Nuget`, Software, HtmlDocs |
| `4336599` | `completed / succeeded`, dernier master trouvé dans la liste relue | `refs/heads/master` / `0c0fd26533e46b13e029276f90b5c085c1804012` | Build et `TestAutos (on Premise)` ; pas de campagne JMeter Clienteling équivalente | `26.0.10.19_Nuget`, Software, HtmlDocs |

Le build historique `4432554` reste la référence directement comparable pour les compteurs Cur/Fix déjà documentés : les runs JMeter historiques associés sont `6180736` (Cur) et `6180750` (Fix), avec 2 118 tests publiés et 485 non passés chacun selon [finding 006](../../findings/006-clienteling-v26-build-4432554.md). Cette mention réutilise la preuve locale existante ; elle ne constitue pas une nouvelle lecture des résultats bruts.

## Proposition concrète, sous conditions de sécurité

1. Créer ou sélectionner une définition Azure DevOps d'essai explicitement dédiée au WI, sans modifier `2065`, `2637`, `2641`, `5224`, les templates partagés ou les branches `master`/release.
2. Construire l'API depuis `sandbox/clienteling/api-jmeter-fixes` après que le correctif local soit réellement committé sur cette branche, puis conserver le `.nupkg`, son manifeste et son SHA-256 dans l'artefact du build API exact.
3. Construire Console depuis une branche d'essai épinglée au candidat validé, en consommant uniquement l'artefact API exact par ID de build ; conserver le `.nupkg` Console et son hash. Ne pas pousser ces packages vers Artifactory/NuGet partagé.
4. Générer ou récupérer les JMX dans un worktree/artefact d'essai, calculer leurs SHA-256, et transmettre explicitement le lot au build Clienteling. La branche plugin à figer pour la première expérience est `Clienteling_Migration_AutoTest_Jmeter_On_master` au commit `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a`, sauf décision de reprendre `master` au commit live.
5. Utiliser les paramètres `version=26`, `types=Cur,Fix`, et d'abord un lot minimal avec un cas par défaut prouvé ; ensuite seulement le périmètre complet `WebServices` puis les campagnes prévues. Restaurer un backup dédié hashé, vérifier l'image SQL 2025 réellement consommée, les fixtures/images Clienteling et les endpoints avant tout JMeter.
6. Attendre et collecter : timeline prouvant `Build`, `TI_Jmeter_V26_Cur`, `TI_Jmeter_V26_Fix` ; artefacts exacts et hashes API/Console/JMX/image ; logs de déploiement ; JTL/JUnit/CSV Cur et Fix ; preuve d'absence de `Publish`, promotion, tag, import ACR et déclenchement aval.

**Condition d'arrêt** — tant que la définition isolée, le mécanisme de transfert des packages/JMX et les destinations d'écriture ne sont pas identifiés et vérifiables, ne pas lancer le build Clienteling actuel. Cette condition est un risque démontré par la lecture des YAML/templates, pas une absence d'autorisation métier.

## Limites et UNKNOWN conservés

- `UNKNOWN` : contenu final du digest ACR utilisé par le prochain run et présence de Full-Text dans cette image ; le tag YAML ne suffit pas.
- `UNKNOWN` : package API/Console réellement chargé par le générateur et le runner ; aucun artefact distant corrigé n'est lié à Clienteling.
- `UNKNOWN` : JMX exacts transmis au prochain job et mécanisme officiel de transport des fixtures images.
- `UNKNOWN` : absence de déclenchement aval d'une définition isolée tant que ses abonnements/resources Azure DevOps n'ont pas été relus.
- `UNKNOWN` : baseline métier comparable après correction ; le build historique `4432554` reste une référence de comparaison, pas une validation de migration.

