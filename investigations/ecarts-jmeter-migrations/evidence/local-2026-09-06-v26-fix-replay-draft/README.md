# Brouillon local de pipeline isolé — WI-2222897

Date : 2026-09-06. Brouillon non exécutable et non publié. Aucun worktree, système distant, image, package, backup, SQL ou pipeline n’a été modifié ou lancé.

## Périmètre exact

Un seul job V26 Fix, campagne `ExportRunOnly`, qui référence uniquement `TestPlans\Export_Run.xml`. Le plan `Export_Run.xml` reste complet, avec son ordre et toutes ses prérequêtes/assertions ; il ne s’agit pas d’une sélection exclusive TC08–TC10. TC08, TC09 et TC10 seront contrôlés dans les résultats du plan complet.

`campaigns/ExportRunOnly.xml` est le descripteur candidat. Pour un futur run, il devra être copié dans le checkout sous `Tests\ExportRunOnly.xml` avec le plan sous `Tests\TestPlans\Export_Run.xml`. Le template source confirme que `campaignName` résout ce fichier XML puis invoque tous ses `TestPlanItem`.

## Artefacts récupérables

`azure-pipelines.candidate.yml` conserve une unique tâche `PublishPipelineArtifact@1`, `condition: always()`, nommée `rje-wi2222897-$(Build.BuildId)-evidence`. `scripts/stage-evidence.ps1` utilise une liste explicite : JMX Export_Run, descripteur de campagne, JTL/log/XML bruts Export_Run, archive de déploiement, SHA-256 du backup, cibles résolues et références consommées. Aucun backup, secret, workspace complet ou dump d’environnement n’est copié.

Le SHA-256 du backup est calculé avant restauration dans `backup.sha256`; il ne prétend pas reproduire le hash historique inconnu. `PublishTestResults` est retiré du template candidat, mais les résultats bruts restent dans l’artefact du run.

## Changements par rapport aux templates

| Source | Copie candidate | Changement |
|---|---|---|
| `Y2_Tools_PlatformDeploy/Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml` | `templates/task-deploy-in-containerized-job.candidate.yml` | conserve téléchargement/déploiement/contrôles/restauration ; retire seulement sa publication PipelineArtifact interne, reprise par l’artefact unique |
| `Y2_Tools_Jmeter_Workflow/PipelineTemplates/task-run-campaign.v1.yml` | `templates/task-run-campaign.candidate.yml` | conserve préparation, JMeter, conversion et assertions ; retire seulement PublishTestResults |
| mêmes fichiers | `*.source.yml` | copies de référence intactes pour comparaison |

Le brouillon ne contient aucun stage Publish/Promote/Tag, TestAutos, push NuGet/Docker, BuildInfo ou déploiement externe. L’image est épinglée par digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`, avec plugin `26.0.10.75`, Core `26.0.0.1762`, JMeter 5.6.3 et Java 21.

## Blocages avant revue/exécution

- agent Windows compatible avec `windowsservercore-ltsc2025`, capacité et quota non confirmés ;
- connexion registre `AzureContainerRegistry-Docker-Retail` et variable secrète JFrog non validées pour une définition d’essai ; aucune valeur secrète n’est fournie ;
- provenance/présence du plugin de test, de `v26-Fix.cy2px`, du JMX corrigé et de `AUTO_V26_00.bak` dans le checkout d’essai à confirmer ;
- `platformDeployVersion` et `artifactoryPackageFolder` restent non résolus ;
- résolution effective `__CONTAINER_HOST__`, `APPSERVER_HOST`, SQL et IIS à vérifier dans le run ; toute cible hôte/partagée bloque ;
- triggers CI/PR/schedule/completion et nettoyage des conteneurs, réseau, volumes et staging à valider avec l’opérateur.

Le brouillon doit être revu avant toute création de définition ou action distante.
