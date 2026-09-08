# Build 4442156 — timeline/artifacts projection

Collecte REST read-only le 2026-09-07. Secrets, URLs d'artefacts et payloads exclus.

| élément | état | résultat | log |
|---|---|---|---:|
| BuildAndTest2019 | completed | failed | 13 |
| Build and smoke-test SQL Server 2019 Full-Text | completed | failed | 9 |
| PublishPipelineArtifact (SQL2019) | completed | skipped | 10 |
| BuildAndTest2025 | completed | failed | 18 |
| Build and smoke-test SQL Server 2025 Full-Text | completed | failed | 14 |
| PublishPipelineArtifact (SQL2025) | completed | skipped | 15 |
| Post-job checkout 2019 | completed | succeeded | 11 |
| Post-job checkout 2025 | completed | succeeded | 16 |

FACT : `GET .../builds/4442156/artifacts` a retourné zéro artefact. Les logs 9, 14 et 18 ont été projetés par filtrage des signatures (`FULLTEXT`, population, service/processus, échec); aucun secret ni payload brut n'a été conservé.
