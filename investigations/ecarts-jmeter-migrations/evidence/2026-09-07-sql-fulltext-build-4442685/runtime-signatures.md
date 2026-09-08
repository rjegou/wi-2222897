# Signatures expurgées — build 4442685

Source : logs Azure DevOps lus par REST, sans secret ni payload.

```text
Checkout ... HEAD is now at e3b674b [skip ci] WI-2222897 fix Full-Text probe Docker preflight
FULLTEXT_OBSERVATION_EXIT=0  (répété jusqu’à 2026-09-07T19:55:14.139Z)
Full-Text population did not finish: [1]
SQL 2019 Full-Text smoke failed
```

Pour SQL2025, seule la timeline est directement lisible dans cette collecte : la tâche `Build and smoke-test SQL Server 2025 Full-Text` et la stage SQL2025 sont `failed`; l’artefact `sql-fulltext-2025-evidence` est `succeeded` côté publication.
