# Build 4432510 — image, backup et entrée JMX

Date : 2026-09-06. Périmètre strict : build 4432510, commit source `f80bc731571b2b5ed8a67da171b288873de428a6`, définition 2054. Lectures distantes Azure DevOps bornées aux métadonnées, timeline, YAML du commit et logs des tâches JMeter ; aucun téléchargement, lancement ou secret conservé.

## Conclusions

### Image — FACT partiel / UNKNOWN

Le YAML exact déclare le conteneur `acr_y2jmeter_test` avec l’image `cegid-retail-docker-production/y2-jmeter:$(acrImage.Tag)`, et le job `TI_Jmeter_V${version}_${typeTest}` l’utilise. Le tag évalué et un digest ne sont pas enregistrés dans les preuves/logs consultés : UNKNOWN. Les logs du run observent SQL Server 2025 Express `17.0.1000.7`, Windows Server 2025 ; cela ne fournit pas un digest d’image. Preuve locale : `build-4432510/_extracted/v26-Fix_RunLogs-Attempt#1/ApplicationEventLog.txt:5748-5752`.

### Backup — FACT mécanisme / UNKNOWN identité

Le YAML passe `Tests\Backups` à `task-deploy-in-containerized-job.v2.yml` et le `cy2px`/déploiement est préparé avant l’installation des outils et l’exécution JMeter. Le log de préparation confirme `DB_INSTANCE=\\DOCKERSQLEXPR` et `FOLDER_ID=TESTS_AUTO_JMETER`. Le nom exact, la source, le hash et la restauration du backup ne sont pas exposés dans les logs sûrs consultés ; `parameters.properties` n’a pas été ouvert. Aucun backup n’a été téléchargé.

### JMX — FACT

Le checkout du dépôt se fait dans `s\Y2_Plugins_FrenchTaxesRules`. Le YAML exact appelle `task-run-campaign.v1.yml@jmeterTemplates` avec `campaignsFolderPath=$(Build.SourcesDirectory)\Y2_Plugins_$(plugin.Name)\Tests` et `campaignName=LegacyServices`. Le log de tâche 172 exécute ensuite `C:\__w\1\s\Y2_Plugins_FrenchTaxesRules\Tests\LegacyServices\010-Export_Run.jmx` avec `C:\Tools\jmeter\bin\jmeter.bat`. Propriétaire : `task-run-campaign.v1.yml`; JMeter 5.6.3 est observé dans le log produit.

## Injection sans image

FACT : le JMX est consommé depuis le checkout, non depuis le contenu démontré de l’image. Il est donc techniquement possible de fournir un JMX corrigé par un checkout isolé en conservant l’image ; le point d’entrée à adapter serait `campaignsFolderPath`/le fichier `Tests\LegacyServices\010-Export_Run.jmx`. UNKNOWN : aucun contrat local ne prouve qu’un artefact de JMX peut être monté ou substitué par le template sans modification du pipeline. TestAutos on-premise n’est pas ce runner : il s’agit d’une autre voie et n’est pas utilisée par le job JMeter 4432510.

## Références

- Métadonnées build 4432510 : définition 2054, branche `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_master`, commit ci-dessus, résultat `partiallySucceeded`.
- Timeline : stage `TI JMeter V26`; tâches `Prepare Jmeter Campaign Run...LegacyServices-v26-Fix` et `Run Jmeter Tests Campaign...LegacyServices-v26-Fix`, toutes deux réussies.
- YAML distant : `azure-pipelines.yml` au commit source ci-dessus ; templates référencés `task-deploy-in-containerized-job.v2.yml` et `task-run-campaign.v1.yml`.

Action suivante unique : obtenir, dans les métadonnées d’exécution ou un manifeste déjà produit du même build, la valeur résolue de `acrImage.Tag` et `backupName`, puis vérifier le point d’injection JMX avant toute exécution.
