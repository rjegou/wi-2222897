# SQL Full-Text — terminal build 4442156 (2026-09-07)

## Provenance and method

- Date: 2026-09-07, Europe/Paris.
- Azure DevOps project: `Retail`; definition `14251`; build `4442156`.
- Repository: `Pipelines_Docker_BaseImages`; source branch `refs/heads/sandbox/WI-2222897-sql-fulltext`; source commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`.
- Read-only method: Azure CLI extension `azure-devops` version `1.0.8`, with `AZURE_CONFIG_DIR` in a temporary workspace folder and `AZURE_DEVOPS_EXT_PAT` loaded only in the process from the authorized PAT file. Both environment variables were removed after each command; the temporary CLI profile was then removed.
- No pipeline was queued, cancelled, retried, published, promoted, tagged, or otherwise modified.

## Terminal result

FACT — `az pipelines build show --id 4442156 --org https://dev.azure.com/cegid --project Retail --output json` returned exit code `0` and:

```text
status=completed
result=failed
queueTime=2026-09-07T16:42:52.325537Z
startTime=2026-09-07T16:42:59.634622Z
finishTime=2026-09-07T16:58:11.425745Z
```

The definition is `WI-2222897 SQL FullText Hosted Build Round11`; the repository is `Pipelines_Docker_BaseImages` and the build reason is `manual`.

## Timeline and logs

FACT — timeline read through `az devops invoke --area build --resource timeline --route-parameters project=Retail buildId=4442156 --api-version 7.1` shows both stages failed:

| stage | interval UTC | result | failing task/log |
|---|---|---|---|
| SQL Server 2019 Full-Text build and smoke | 16:43:01–16:50:56 | failed | `Build and smoke-test SQL Server 2019 Full-Text`, log 9 |
| SQL Server 2025 Full-Text build and smoke | 16:43:01–16:58:11 | failed | `Build and smoke-test SQL Server 2025 Full-Text`, log 14 |

FACT — log 9 proves the SQL 2019 Docker image was successfully tagged `sql-fulltext-smoke:2019`, then the probe failed at `2026-09-07T16:50:46Z` with `Full-Text population did not finish: [1]`; the task ended with `SQL 2019 Full-Text smoke failed` and PowerShell exit code `1`.

FACT — log 14 proves the SQL 2025 Docker image was successfully tagged `sql-fulltext-smoke:2025`, the SQL service configuration returned `ChangeServiceConfig SUCCESS`, then the probe failed at `2026-09-07T16:57:51Z` with `Full-Text population did not finish: [1]`; the task ended with `SQL 2025 Full-Text smoke failed` and PowerShell exit code `1`.

FACT — both task logs show `Changed database context to 'FullTextSmoke'.` before the population failure. No `CONTAINSTABLE` success is present in the retrieved task logs.

## Installation, population, query, cleanup

| boundary | SQL 2019 | SQL 2025 |
|---|---|---|
| Docker image build | FACT — succeeded/tagged | FACT — succeeded/tagged |
| setup command | FACT — `/MediaType=Advanced`, `/FEATURES=SQLENGINE,FullText` visible in log | FACT — `/FEATURES=SQLENGINE,FullText` visible in log |
| `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` | UNKNOWN in this terminal task log; prior build 4442121 proved `1` | UNKNOWN in this terminal task log; prior build 4442121 proved `1` |
| catalog population | FACT — probe returned status `[1]` after timeout | FACT — probe returned status `[1]` after timeout |
| `CONTAINSTABLE` | UNKNOWN/not reached | UNKNOWN/not reached |
| cleanup | UNKNOWN — container name was printed, but no direct `docker rm` postcondition appears in logs 9/14 | UNKNOWN — same |

FACT — `az pipelines runs artifact list --run-id 4442156` returned `[]`. The diagnostic artifacts expected by the prior handoff were not published because the artifact publish tasks are shown as skipped after the smoke task failure.

## Limits and next useful action

INFERENCE — the common failure on both versions after successful image construction localizes the current issue to Full-Text population/probe completion, not the 2019 Advanced media selection alone. This does not identify whether the service, catalog, table, crawl, or timeout is causal.

UNKNOWN — the current build does not prove the final service property, `CONTAINSTABLE`, or cleanup state because those values are absent from the available task logs and no artifacts were published.

Next authorized useful action: a new dedicated diagnostic run only if explicitly coordinated, with diagnostics executed in a `finally` path that publishes evidence even when the smoke assertion fails, and with an explicit cleanup assertion. Do not alter shared pipelines or the existing worktree changes based on this result alone.

Postcondition: this is a new evidence-only collection; no shared document, worktree file, branch, definition, registry, feed, or deployment was modified.
