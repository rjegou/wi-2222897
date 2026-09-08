# InventoryTracking — reprise Worker 2 round 2

Date : 2026-09-07 (Europe/Paris). Collecte Azure DevOps en lecture seule.

## Méthode Azure DevOps fonctionnelle

La CLI Azure DevOps reste inutilisable dans le profil global et l’API via Schannel/curl échoue. La méthode fonctionnelle est Python 3.12 `requests` avec `Session.auth=('', pat)`, `Session.verify=True`, et le PAT lu en mémoire avec `Path(...).read_text(encoding='utf-8-sig').strip()`. Aucun token n’est affiché, écrit ou persisté ; la session et la variable sont vidées dans `finally`.

## État live collecté

FACT — WI `2222897` : HTTP 200, rev `17`, titre `Migration Testauto Legacy => Migrer toutes les plugins et branches pour inventaire erreur restantes`, état `Committed`, 7 relations.

FACT — dépôt `Y2_Plugins_InventoryTracking` : id `90f886fd-8a68-483f-b798-126928e6297f`, branche par défaut `refs/heads/master`.

FACT — la branche de migration existe toujours et doit être recherchée avec `filter=heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master` : objet `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.

FACT — aucun PR n’est retourné pour cette branche source vers `master` par la requête read-only.

FACT — build `4434070` : `7.73`, `completed/failed`, branche de migration, commit `4de185bb132cfbfb50643b6b53d6feb85508f4e2`, fin `2026-09-04T14:25:10.0849986Z`. Les deux derniers builds de cette branche sont `4434070` et `4432064`, tous deux en échec au même commit.

FACT — définition `2072` `InventoryTracking CI`, dépôt ci-dessus, YAML `/azure-pipelines.yml`, queue enabled, pool/règles résolues depuis le YAML ; triggers CI master/releases et schedule samedi 06:15 UTC.

## YAML et templates examinés

Le YAML exact au commit `4de185bb` déclare `pipelineDevMode=false` mais `true` rend simultanément actives les étapes de build, publication, JMeter et promotion. Il ne possède pas de paramètre Build-only.

FACT — le YAML référence trois dépôts externes sans `ref` immuable : `Pipelines_Templates`, `Y2_Tools_Jmeter_Workflow`, `Y2_Tools_PlatformDeploy`. Les hashes ci-dessous sont ceux du contenu lu sur leurs branches `master` au 2026-09-07, pas la preuve des commits réellement consommés par le build 4434070.

| dépôt / fichier | SHA-256 du contenu lu | effet observé |
|---|---|---|
| Pipelines_Templates `/Y2Tools/restore-y2Tools.v1.yml` | `aa81f7211e510ab6063bbbcf523ad83b378d11fe558946139e5333fb94d1a5ed` | `JFrogNuGet@1` |
| Pipelines_Templates `/Nuget/restore-externals.v1.yml` | `6b1749d616bc3989f19dbccabde8bc501cdc6e81bb239d9967b9072139620a4b` | `JFrogNuGet@1` |
| Pipelines_Templates `/Build/dotNet-build.v1.yml` | `ecc4fc0902ef503d9215b1217945e180592393af7adcc37fe31411dca839fa21` | restore JFrog ; publication quality gate |
| Pipelines_Templates `/Nuget/nuget-build-publish.v1.yml` | `47999edcf1bd634e94b03d9a0d7c55759bd0bae775dc5c2afcab6a36df9c2fc6` | `PublishPipelineArtifact` |
| Pipelines_Templates `/JFrog/upload-staging.v1.yml` | `bb46fc3dd7fe992575d39e39946e27f9adc49404f883bf54aecb4974aa9eadb4` | upload Artifactory staging |
| Pipelines_Templates `/JFrog/promote-artifacts.v2.yml` | `1dcc70de5a7132745144574fb86e04c72b3f6675d9adb907e2d993bcdca1b8e4` | promotion JFrog |
| Pipelines_Templates `/Git/tag-sources.v1.yml` | `7017463cdfa7e7b318f23fbaa264783c9c129f41c6315eb1afdd9b7c797cd1f6` | `git push` tag |
| Pipelines_Templates `/Jmeter/TestsAuto/archive-and-publish-test-campaign-logs.v1.yml` | `89f88d68ed79c7ff990701e5c3095350ed9f06689317650197c8b24726515d95` | pipeline log publication |
| Y2_Tools_Jmeter_Workflow `/PipelineTemplates/task-run-campaign.v1.yml` | `1630c6a105983fbf85994581e6b9a754639fff28a3107b9c11e2a3aca7d2ab80` | invokes JMeter and publishes test results |
| Y2_Tools_PlatformDeploy `/Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml` | `187f9910cdad16da7c7029180d3e6926dcf9f97039986da2f82137b38beb42d5` | JFrog download, Docker/container deployment, pipeline artifact |

FACT — le YAML lui-même confirme aussi `Ensure_Docker_Image_Up_To_Date` (JFrog → ACR), `Publish`, `TI_Jmeter_V26`, `Promote` et `Tag_Sources`. Ces effets excluent une queue Build-only de la définition partagée 2072.

## Correctif et avant/après local

Base : `4de185bb132cfbfb50643b6b53d6feb85508f4e2`. Correctif isolé : `ef3d87034d38b88aca04c824061b140e2a29252c`.

FACT — avant, `Services.Tests/packages.config` ne contenait ni `Cegid.Retail.XmlDiff` ni `XMLDiffPatch`, et le csproj pointait `Cegid.Retail.XmlDiff` vers `..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`.

FACT — après, `packages.config` contient `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28`; le csproj pointe vers `..\Sln\packages\...` pour les deux DLL.

FACT — `nuget restore Sln\InventoryTracking.sln -NonInteractive` retourne `0` et restitue les deux DLL. FACT — MSBuild `ResolveAssemblyReferences` avec `BuildProjectReferences=false` retourne `0` et résout les deux références. UNKNOWN — build complet CI ; le build local complet retourne `1` sur assemblies Cegid manquantes dans `ServiceContracts`, blocage distinct de XmlDiff.

## Décision CI

Pas de création de pipeline, branche, PR ou queue dans ce lot : le YAML partagé et ses templates ne prouvent pas les limites demandées. Candidat exact à soumettre à BRAIN : une définition/branche dédiée avec YAML copié et épinglé, `trigger: none`, `pr: none`, `schedules: []`, stage unique Build, restore contrôlé, aucune tâche JFrog/ACR/Docker/TestAutos/JMeter/Publish-Promote-Tag, et un agent dédié explicitement identifié. La validation doit ensuite vérifier l’absence de `MSB3245` XmlDiff et des quatre `CS0103`, sans assimiler ce résultat à la réussite métier JMeter.

