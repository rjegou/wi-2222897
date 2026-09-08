# Récupération logs Full-Text — 4442685 et 4442156

Date de collecte : 2026-09-07 (Europe/Paris). Système source : Azure DevOps `cegid/Retail`, API REST sur `dev.azure.com`, Python `requests` avec vérification TLS/certificats. Aucun PAT n’a été envoyé aux hôtes d’artefacts ou de redirection. Aucun pipeline, définition, branche ou dépôt n’a été modifié.

## Résultat de récupération

- **FACT** — l’API Azure DevOps répond en HTTPS vérifié pour les métadonnées, builds, timelines et logs.
- **FACT** — les URLs d’artefact retournées par Azure DevOps ont l’hôte `artprodsu6weu.artifacts.visualstudio.com`, puis redirigent vers `spsprodweu3.vssps.visualstudio.com`. La redirection a été suivie sans en-tête `Authorization`; la réponse finale est `203 text/html`, 16 595 octets, pas une archive ZIP.
- **FACT** — les artefacts restent donc non récupérés, sans transmission du PAT hors `dev.azure.com`.

## Builds et concurrence

- **FACT** — build `4442685`, définition `14251`, branche `refs/heads/sandbox/WI-2222897-sql-fulltext`, SHA `e3b674b007071259fd74b024f6b4b48baf0a7f5d`, terminal `failed`, fin `2026-09-07T20:02:23.5877387Z`.
- **FACT** — build `4442156`, même définition/branche, SHA `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`, terminal `failed`, fin `2026-09-07T16:58:11.4257452Z`.
- **FACT** — contrôle live de la définition Full-Text `14251` : zéro run `inProgress` au moment de cette collecte. Aucun run n’a été lancé dans cette round.

## Assertions et runtime démontrés

### Build 4442685 — SHA e3b674b

- **FACT — SQL2019** — l’image `sql-fulltext-smoke:2019` est taguée (`log 9`). Le probe atteint la création de `FullTextSmoke`, émet des observations `FULLTEXT_OBSERVATION_EXIT=0`, puis lève `Full-Text population did not finish: [1]` à `2026-09-07T19:55:14.294Z`. La tâche échoue et l’artefact `sql-fulltext-2019-evidence` est publié.
- **FACT — SQL2025** — l’image `sql-fulltext-smoke:2025` est taguée (`log 14`). Le probe émet des observations `FULLTEXT_OBSERVATION_EXIT=0`, puis lève `Full-Text population did not finish: [1]` à `2026-09-07T20:02:00.959Z`. La tâche échoue et l’artefact `sql-fulltext-2025-evidence` est publié.
- **FACT** — le script exécuté contient les assertions `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')`, `FULLTEXTCATALOGPROPERTY(...,'PopulateStatus')`, `OBJECTPROPERTYEX(...,'TableFullTextPopulateStatus')`, `sys.fulltext_index_fragments` et `sys.dm_fts_index_population`; il n’appelle `CONTAINSTABLE` qu’après `PopulateStatus=0`.
- **INFERENCE bornée** — `IsFullTextInstalled=1` est compatible avec la poursuite du probe jusqu’à la création de la base et de l’index; sa valeur numérique n’est pas imprimée dans les logs. Elle n’est donc pas une observation directe conservée.
- **FACT** — `CONTAINSTABLE` n’est pas atteint dans les deux variantes, car le probe lève avant cette requête.
- **UNKNOWN** — valeurs numériques détaillées des DMV/propriétés, erreurs ERRORLOG/service, et cleanup effectif (`docker rm -f`, suppression de base). Le YAML ordonne le cleanup, mais les artefacts de diagnostic ne sont pas récupérables par cette pile TLS.

### Build 4442156 — SHA 0baf69c

- **FACT** — SQL2019 et SQL2025 taguent leurs images puis échouent également sur `Full-Text population did not finish: [1]`; les deux tâches `Build and smoke-test` sont failed et les publications d’artefacts sont skipped.
- **FACT** — aucune preuve `CONTAINSTABLE` n’est présente dans les logs de ce build.
- **UNKNOWN** — valeurs détaillées des propriétés/DMV, ERRORLOG et cleanup pour 4442156.

## Conclusion discriminante

**FACT** — sur deux runs indépendants, les deux versions SQL atteignent le runtime Full-Text et restent à `PopulateStatus=1` jusqu’à l’échec du probe; la postcondition fonctionnelle `CONTAINSTABLE >= 1` n’est satisfaite dans aucun run. **INFERENCE** — le défaut démontré est une population Full-Text non terminale dans cette fenêtre, pas une absence prouvée du composant Full-Text. **UNKNOWN** — cause moteur précise et état final après cleanup. Aucun rejeu métier ou FrenchTaxesRules V22 n’a été touché.

