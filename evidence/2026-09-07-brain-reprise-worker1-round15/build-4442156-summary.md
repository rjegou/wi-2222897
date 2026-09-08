# Build 4442156 — Full-Text terminal analysis

Date de collecte : 2026-09-07 (Europe/Paris). Source : Azure DevOps REST, projet Retail, build `4442156`. Collecte read-only, projection non sensible uniquement.

## FACT

- Build `WI-2222897-SQLFullText-HostedBuild-20260907.4`, définition `14251`, branche `refs/heads/sandbox/WI-2222897-sql-fulltext`, commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`.
- État terminal : `completed`, résultat `failed`, fin `2026-09-07T16:58:11.4257452Z`.
- SQL2019 : checkout réussi; image `sql-fulltext-smoke:2019` construite et taguée; contexte `FullTextSmoke` atteint; le probe échoue à `2026-09-07T16:50:46.6021401Z` avec `Full-Text population did not finish: [1]`; la tâche se termine failed à `16:50:50.8466667Z`.
- SQL2025 : checkout réussi; image `sql-fulltext-smoke:2025` construite et taguée; configuration du service observée (`MSSQL$DOCKERSQLEXPR`, sqlservr.exe); contexte `FullTextSmoke` atteint; le probe échoue à `2026-09-07T16:57:51.3348876Z` avec `Full-Text population did not finish: [1]`; la tâche se termine failed à `16:57:59.5233333Z`.
- Les deux tâches `PublishPipelineArtifact` sont terminales `skipped` : log 10 pour SQL2019 et log 15 pour SQL2025. L'endpoint build artifacts retourne une liste vide.
- Le YAML utilisé a le hash SHA-256 `4A41B67E5D0DE8CD6085DB6B3298D830887F176AACE80C9F6F16A87C4C4EFFBC`. Dans chaque stage, le bloc `finally` prépare les fichiers `*-runtime-diagnostic.ps1`, `*-runtime-diagnostic.log` et `*-container.log`, puis le publish suit sans `condition: always()` aux lignes 45-46 et 86-87.

## Diagnostic discriminant

`finally` est bien exécuté dans le même job (les tâches de nettoyage post-checkout sont succeeded), mais le publish conditionné par défaut au succès du job est skipped après l'échec du probe. Il est donc impossible de récupérer depuis ce run les observations demandées (service/processus, `TableFullTextPopulateStatus`, `sys.fulltext_index_fragments`, `sys.dm_fts_index_population`, ERRORLOG). Ce n'est pas une preuve que ces requêtes n'ont pas été exécutées; c'est une preuve qu'elles n'ont pas été publiées et restent UNKNOWN.

## Séparation des conclusions

- FACT : les deux variantes atteignent la population puis échouent avec le même statut non terminal `[1]`.
- INFERENCE : le défaut commun actuellement actionnable est la non-publication des diagnostics sur échec; il empêche d'identifier la cause moteur de la population bloquée.
- UNKNOWN : cause SQL/Full-Text (service arrêté, population active, fragments, ERRORLOG ou autre); aucun résultat DMV/runtime retenu comme preuve.
- UNKNOWN : `CONTAINSTABLE` n'est pas une postcondition atteinte; le probe lève avant cette vérification.

## Action minimale suivante

Corriger dans le YAML dédié les deux étapes de publication pour qu'elles s'exécutent avec `condition: always()` (en conservant le `finally` et sans modifier l'image ni le scénario), puis effectuer un seul rejeu borné autorisé. La postcondition attendue est l'artefact diagnostic présent et, seulement après lecture de ses projections non sensibles, la décision sur une correction moteur. Aucun rejeu n'a été lancé dans ce lot.
