# InventoryTracking — contrat de transport du package Build — round 5

## Provenance

- Date : 2026-09-08 (Europe/Paris).
- Source : Azure DevOps `cegid/Retail`, run `4444887` (`7.83`), définition `2072`.
- Commit testé : `efba57ea5a96d346170f4407e37050985244dcee`.
- Méthode : lecture AzDO CLI/REST des artefacts et lecture des templates/scripts archivés localement ; aucun secret, push, publication ou queue supplémentaire.
- Fraîcheur : collecte live et revue locale le 2026-09-08.

## Faits établis

**FACT** — le Build du run a publié un PipelineArtifact isolé `26.0.7.83_Software`, ID `5037140`, taille déclarée `1 705 531` octets. Les artefacts `26.0.7.83_Nuget`, `26.0.7.83_HtmlDocs` et les logs Cur/Fix sont distincts. Le package de Build existe donc dans le service PipelineArtifact ; cela ne prouve pas qu'il est consommable par PlatformDeploy.

**FACT** — le template consommé `Y2_Tools_PlatformDeploy/Src/PipelineTemplates/task-deploy-in-containerized-job.v2.yml` (copie source : `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-v26-fix-replay-draft-hardened/templates/task-deploy-in-containerized-job.source.yml`) télécharge l'archive PlatformDeploy via `JFrogGenericArtifacts@1`, extrait `PlatformDeploy.$(foundPlatformDeployVersion).zip`, puis lance `docker-pipeline-deploy.ps1`.

**FACT** — le script PlatformDeploy `Scripts/download-packages.ps1` (copie extraite et hashée dans `parallel/.../bw2-environments/evidence/platformdeploy/round4-private-staging-20260908/extracted/Scripts/download-packages.ps1`) appelle obligatoirement `Cegid.Retail.JFrog.Cli.exe download packagelist <cy2px> -f <kits> -di <downloadedPackages.json>`. Il n'accepte aucun répertoire local de packages, PipelineArtifact, URL d'artefact ou cache comme entrée déclarée.

**FACT** — le `.cy2px` décrit des packages/version et des hôtes ; il ne décrit pas un chemin local de remplacement. Dans `4444887`, les jobs ont donc cherché `Y2.Plugin.InventoryTracking.26.0.7.83` dans `retail-software-staging` et ont échoué avant JMeter.

## Décision de transport

**INFERENCE** — ajouter seulement `DownloadPipelineArtifact@2` dans Cur/Fix ne résoudrait pas le défaut : le script PlatformDeploy relancerait ensuite le téléchargement JFrog du packagelist et rejetterait l'absence du package staging.

**UNKNOWN** — structure interne exacte de l'archive `26.0.7.83_Software` et correspondance octet/hash avec le package JFrog attendu ; le téléchargement direct de l'archive a été refusé par l'authentification locale avant transfert. Aucun hash de contenu n'est inventé.

**DÉCISION BORNÉE** — aucun diff exécutable n'est préparé à ce stade. Un diff qui introduirait `localPackageRoot` ou un équivalent serait un nouveau contrat non prouvé et devrait modifier au minimum le template PlatformDeploy, `download-packages.ps1` et la génération/validation de `downloadedPackages.json`. Il doit être revu techniquement par le worker 2 avant toute branche ou queue.

## Options à faire arbitrer

1. **Contrat local explicite à développer** : paramètre et manifeste de packages local, vérification SHA-256 dans chaque job, conservation du téléchargement JFrog pour les dépendances non fournies, et test inerte avant queue métier. C'est une modification substantielle, pas un simple YAML.
2. **Destination JFrog dédiée** : publier uniquement le package `26.0.7.83` dans un chemin/repository de test isolé puis fournir service connection, droits, routage, rétention et cleanup prouvés. Cette option est interdite sans décision et n'est pas exécutée.

Aucune publication dans `retail-software-staging`, aucun feed partagé, aucune promotion, aucun tag et aucun changement de service/agent n'a été réalisé.
