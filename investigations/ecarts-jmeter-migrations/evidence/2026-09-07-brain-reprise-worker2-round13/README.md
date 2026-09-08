# Worker 2 — Full-Text population diagnosis

Date: 2026-09-07. Source: Azure DevOps REST over verified TLS and Microsoft Learn. No canonical shared document modified.

## Terminal evidence before diagnostics

Build `4442121`, source `62a286c48326c6eeae355e44a430e8d8b6ac63bf`, completed `failed` at `2026-09-07T16:37:15Z`. SQL 2019 task log 9 completed `failed` at `16:30:13Z`; SQL 2025 task log 14 completed `failed` at `16:36:58Z`. Both Docker images built and both installation probes passed `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')=1`. Both then failed after the probe's 90-second wait with `Full-Text population did not finish: [1]`; neither reached `CONTAINSTABLE`.

Microsoft Learn defines catalog `PopulateStatus` value `1` as **Full population in progress**; it is not idle, paused, throttled, shutdown, or disk-full. The official page also cautions against tight polling and recommends the table-level population property for more granular status: [FULLTEXTCATALOGPROPERTY](https://learn.microsoft.com/en-us/sql/t-sql/functions/fulltextcatalogproperty-transact-sql?view=sql-server-ver17).

This establishes a real runtime population stall or slow population, not the earlier parser defects. It does not yet identify whether the Full-Text service, SQL process, table population, fragments, DMV state, or crawl log is causal because the prior YAML had no runtime diagnostics.

## Diagnostic rerun

The dedicated YAML was extended only in `finally` blocks to collect, before container removal: `Get-Service MSSQL$DOCKERSQLEXPR`, `Get-Process sqlservr`, `sc.exe query`, `FULLTEXTSERVICEPROPERTY`, catalog `PopulateStatus`, `OBJECTPROPERTYEX(...TableFullTextPopulateStatus)`, `sys.fulltext_index_fragments`, `sys.dm_fts_index_population`, and SQL ERRORLOG tails. No image, external registry, feed, promotion, tag, deployment, or shared target was changed.

- Diagnostic YAML commit: `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`, neutral `[skip ci] WI-2222897 indent runtime diagnostics`.
- Definition 14251 remained dedicated with `triggers: null`; no `codex` text was found in its metadata.
- Build `4442156`, source `0baf69c1...`, was manually queued at `16:42:52Z`; both stages started at `16:43:01Z` and remained `inProgress` at the latest read. Its runtime diagnostic artifacts and terminal result are therefore still pending.

No claim is made for SQL 2019/2025 `CONTAINSTABLE` success or the 224 business cases. The dirty master clone and its three round12 modifications remain preserved; all work was isolated.

