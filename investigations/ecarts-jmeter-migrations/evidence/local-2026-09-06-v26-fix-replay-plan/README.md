# Plan de rejeu isolé — FrenchTaxesRules V26 Fix

Date : 2026-09-06. Document de préparation uniquement : aucune branche, définition, exécution, restauration SQL, téléchargement ou publication créée.

## Voie retenue

Une définition d’essai séparée est nécessaire. Un simple lancement de la définition 2054 depuis une branche ne garantit pas l’exclusion des stages Publish/Promote/Tag, des triggers aval ni des tâches de publication intégrées aux templates. Le YAML d’essai doit être dérivé du YAML au commit `f80bc731571b2b5ed8a67da171b288873de428a6`, avec uniquement le job `TI_Jmeter_V26_Fix`, déclenchement manuel et branche d’essai ; aucune modification de la définition collective.

Fichiers à adapter dans la branche d’essai, sans toucher aux dépôts partagés : copie du YAML pipeline, copie locale épinglée de `task-deploy-in-containerized-job.v2.yml` et copie locale épinglée de `task-run-campaign.v1.yml`. Supprimer de ces copies les publications PipelineArtifact/PublishTestResults ; conserver les sorties dans le workspace et les logs standard du run. Les templates partagés `azoTemplates`, `leoTemplates` et `jmeterTemplates` restent en lecture seule.

## Chaîne et effets

1. Checkout isolé : plan/JMX corrigé, `LegacyServices.xml`, `TestPlans`, `Tests\Config\v26-Fix.cy2px`, `Tests\Backups\AUTO_V26_00.bak` et packages de test exacts. Écrit le workspace de l’agent.
2. Pull en lecture seule de l’image historique `y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`.
3. Déploiement dans le conteneur uniquement : `-LocalDBInContainer Backup`, staging du `.bak`, restauration de `AUTO_V26_00`, tenant `TESTS_AUTO_JMETER`. Vérifier que `__CONTAINER_HOST__` et `APPSERVER_HOST` résolvent le conteneur ; toute résolution vers l’hôte partagé bloque le run.
4. Campagne : le template reçoit `campaignsFolderPath` et `campaignName`, puis `jmeter-cli.ps1 invoke-campaign`. Le JMX est lu depuis le checkout, pas depuis l’image.
5. Sorties : JTL/logs/JUnit conservés dans le workspace du run ; aucune publication, push NuGet/Docker, BuildInfo, promotion, tag, TestAutos on-premise ou déploiement externe.

## TC08–TC10 et dépendances

Le `LegacyServices.xml` complet référence dix plans, dont `Export_Run.xml`. Le template ne possède pas de filtre de TestCase : une campagne réduite à `Export_Run.xml` exécuterait encore tous les cas de ce plan. Pour ne pas supprimer arbitrairement les cas, conserver le plan complet et vérifier séparément TC08, TC09 et TC10 dans les résultats, dans l’ordre source. Une exécution TC08–TC10 uniquement nécessiterait un sélecteur JMeter/support de campagne non démontré ou une fixture JMX dérivée ; UNKNOWN, donc hors premier rejeu.

Prérequis métier à préserver : prérequêtes et assertions du plan complet, état initial du backup, `v26-Fix.cy2px`, plugin `26.0.10.75`, Core `26.0.0.1762`, JMeter 5.6.3/Java 21. Le hash historique du backup reste UNKNOWN ; le futur run doit calculer le SHA-256 du fichier acquis avant restauration et l’enregistrer.

## Contrôles avant autorisation

- vérifier CI/PR, schedules, resource/completion triggers et consommateurs automatiques de la définition d’essai ; manuel uniquement ;
- vérifier capacité d’un agent Windows compatible avec l’image Windows Server Core 2025, quota disque et concurrence ;
- vérifier noms de conteneur/réseau/volume/temp et base interne uniques au run ; aucun partage hôte en écriture ;
- vérifier que les tâches de publication, promotion, tag, TestAutos et déploiement externe sont absentes du graphe ;
- définir le nettoyage ciblé des conteneurs, réseau, staging et workspace du run, sans purge globale.

Verdict : préparation possible, reproduction métier historique encore UNKNOWN. Aucun lancement ne doit intervenir avant revue de cette définition d’essai et de ses destinations.
