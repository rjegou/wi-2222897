# Revue documentaire du brouillon V26 Fix — WI-2222897

Date : 2026-09-06. Revue locale uniquement, sans pipeline, JMeter, déploiement, SQL/IIS, téléchargement ni mutation distante. Baseline : build `4432510`, commit `f80bc731571b2b5ed8a67da171b288873de428a6`, plugin Fix `26.0.10.75`, Core `26.0.0.1762`.

## Verdicts par contrôle

| Contrôle | Verdict | Preuve directe et limite |
|---|---|---|
| Contrat XML/JMX corrigé | UNKNOWN — non démontré | `azure-pipelines.candidate.yml:79-92` appelle `ExportRunOnly`; `campaigns/ExportRunOnly.xml:2-3` pointe vers `TestPlans\Export_Run.xml`; le template consomme ce descripteur (`task-run-campaign.candidate.yml:121-144`). Rien ne rattache ce plan au JMX corrigé; l’archive prévue référence `Tests\LegacyServices\010-Export_Run.jmx` (`scripts/stage-evidence.ps1:10`). Préparer un manifeste de chemin/hash du JMX effectivement consommé. |
| Checkout et provenance baseline | UNKNOWN — bloquant | `azure-pipelines.candidate.yml:30-31,47-49,81` suppose `self\Y2_Plugins_FrenchTaxesRules` et `Tests\Config`, backup et `v26-Fix.cy2px`; `clean:false` ne garantit ni contenu ni commit. |
| Agent LTSC2025 et acquisitions | UNKNOWN — bloquant | `azure-pipelines.candidate.yml:14-21` utilise `windows-latest`; `:43-50` laisse `platformDeployVersion`, `artifactoryPackageFolder` et la variable secrète non définis. Le template télécharge PlatformDeploy par JFrog (`task-deploy-in-containerized-job.candidate.yml:120-142`) et la source exige PS7.6 (`docker-pipeline-deploy-ps7.source.ps1:6`). |
| Identités réellement consommées | UNKNOWN — non démontré | Les variables et `references-consumed.txt` (`azure-pipelines.candidate.yml:5-18,94-108`) recopient des déclarations, pas l’identité observée du package/DLL/plugin/Core/JMX effectivement chargé. Le template choisit `foundPlatformDeployVersion` puis télécharge un ZIP (`task-deploy-in-containerized-job.candidate.yml:80-140`). |
| Garde-fous SQL/IIS avant écriture | FAIL — garde-fou absent | Le brouillon déploie/restaure avant la lecture de cibles (`azure-pipelines.candidate.yml:43-77`); `resolved-targets.txt` est postérieur et textuel (`:66-76`). Le template copie/restaure le backup et lance le déploiement (`task-deploy-in-containerized-job.candidate.yml:173-202`) sans arrêt préalable si SQL/IIS/`__CONTAINER_HOST__`/`APPSERVER_HOST` sont ambigus. |
| Triggers, effets aval, isolation | PARTIAL — non démontré | `azure-pipelines.candidate.yml:1-3` désactive CI/PR/schedule et le YAML ne contient ni stage aval, TestAutos, push, promotion ou tag. En revanche endpoint ACR/JFrog, volumes/réseaux/staging et consommateurs aval ne sont pas contrôlés (`:14-21`; template `:120-135`). Nettoyage ciblé non défini. |
| Collecte always() et secrets | FAIL — archive non sûre par preuve | Les traces/publication sont `always()` (`azure-pipelines.candidate.yml:59-61,94-122`) et la liste d’artefacts est explicite (`scripts/stage-evidence.ps1:9-31`). Mais `task-run-campaign.candidate.yml:90-107` écrit et affiche `PASSWORD`/`DB_PASSWORD`; `stage-evidence.ps1:16` archive le ZIP de déploiement sans inspection. |

## Décision

**BLOQUER toute définition ou exécution.** Préparatifs : épingler checkout/commit et prouver le JMX corrigé consommé; résoudre agent LTSC2025, registre, PlatformDeploy, packages et backup par identifiants/empreintes; ajouter des contrôles d’arrêt avant toute écriture SQL/IIS; prouver l’isolation et l’absence de consommateurs aval; supprimer les impressions de propriétés secrètes et inspecter/redacter l’archive avant publication `always()`.

## Préservation worktrees

Hash SHA-256 avant/après revue documentaire, inchangés : `Y2_Tools_Jmeter_Workflow/azure-pipeline.yml` = `1F41A6000D8CE6162B6112B98A32E28DFF3C9C55955206B6FA86615765A47EDC`; `Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` = `AEEF6AA332A416A5AC8F1987E732095BE4C39AD619D157B5DBCA23525B0B8EF2`.
