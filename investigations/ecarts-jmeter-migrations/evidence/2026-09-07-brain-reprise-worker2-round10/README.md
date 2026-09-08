# Round 10 — couverture effective des triggers Full-Text

Date : 2026-09-07 Europe/Paris. Lecture Azure DevOps REST/TLS uniquement; aucune définition partagée modifiée, aucun push, aucune queue.

## Méthode et version

Pour chaque définition, la configuration complète a été lue par REST (`_apis/build/definitions/{id}?api-version=7.1`) puis le chemin `process.yamlFilename` a été lu via Git Items avec `versionDescriptor.version=sandbox/WI-2222897-sql-fulltext` et `versionDescriptor.versionType=branch`. La branche a été résolue au commit `cd5a72235e5f71373acb8994cb3f60f2f6975b93`.

## Matrice

| ID | définition / YAML | dépôt et branche par défaut | métadonnées REST | YAML au commit sandbox | verdict sandbox |
|---:|---|---|---|---|---|
| 6823 | SqlExpress2019 / `Images/SqlExpress/2019/sqlexpress2019-pipeline.yml` | `Pipelines_Docker_BaseImages` / `refs/heads/master` | CI, `branchFilters: []`, `settingsSourceType: 2` | `trigger: none`; pas de `schedules`, pas de `resources.pipelines` trigger | **EXCLUDE** — aucune CI push dans ce YAML |
| 6874 | IIS_Msmq / `Images/IIS-Msmq/Iis-Msmq-pipeline.yml` | même dépôt / master | CI, `branchFilters: []`, `settingsSourceType: 2` | `trigger: none`; pas de `schedules`, pas de `resources.pipelines` trigger | **EXCLUDE** |
| 8090 | Pipelines_Docker_BaseImages / `Images/y2-jmeter/JMeter-pipeline.yml` | même dépôt / master | CI, `branchFilters: []`, `settingsSourceType: 2` | Git Items HTTP 404 : item absent au commit sandbox, résolu explicitement à `cd5a7223…` | **UNKNOWN / STOP** — YAML et override non lisibles |
| 10260 | Y2_Aspnet / `Images/Y2-aspnet/Y2-aspnet-pipeline.yml` | même dépôt / master | CI, `branchFilters: []`, `settingsSourceType: 2` | `trigger: none`; pas de `schedules`, pas de `resources.pipelines` trigger | **EXCLUDE** |
| 14079 | Win2025-stack-pipeline / `win2025-stack-pipeline.yml` | même dépôt / master | CI, `branchFilters: []`, `settingsSourceType: 2` | `trigger: none`; pas de `schedules`, pas de `resources.pipelines` trigger | **EXCLUDE** |
| 14084 | SqlExpress2025 / `Images/SqlExpress/2025/sqlexpress2025-pipeline.yml` | même dépôt / master | CI, `branchFilters: []`, `settingsSourceType: 2` | `trigger: none`; pas de `schedules`, pas de `resources.pipelines` trigger | **EXCLUDE** |

## Sémantique officielle appliquée

Microsoft documente que `trigger: none` désactive les CI triggers dans le schéma YAML : [YAML trigger](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/trigger?view=azure-pipelines). Microsoft documente aussi que, sans configuration de push trigger, une pipeline YAML peut être configurée par défaut sur toutes les branches selon le réglage organisation/projet, et que les paramètres UI peuvent remplacer `trigger`/`pr` YAML : [Azure Repos Git pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops), [Troubleshoot pipeline triggers](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/troubleshoot-triggers?view=azure-devops).

La matrice sépare donc la preuve YAML explicite des métadonnées REST. `settingsSourceType: 2` indique que la définition s'appuie sur les réglages du YAML, mais la documentation précise qu'un override UI peut modifier le comportement; aucun endpoint de cette collecte ne rend un override distinct lisible. Les cinq YAML effectivement lus excluent le push. Pour 8090, l'absence du fichier au commit sandbox est une preuve d'indisponibilité du pipeline à cette version, mais pas une preuve suffisante d'absence d'override ou de comportement déclenché par la configuration partagée.

## Décision

**VERDICT : arrêt avant push.** Cinq définitions sont exclues par leur YAML explicite, mais 8090 reste indéterminable : CI metadata active, filtres vides, YAML référencé absent au commit exact. Modifier ou désactiver 8090 est hors périmètre. Les candidats Full-Text restent dans le worktree isolé round9; aucun runtime, définition dédiée ou build n'a été créé.
