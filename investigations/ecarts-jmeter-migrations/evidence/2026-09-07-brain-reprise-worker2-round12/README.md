# Worker 2 — Full-Text probe correction and rerun

Date: 2026-09-07. Scope: only the dedicated `Pipelines_Docker_BaseImages` branch `sandbox/WI-2222897-sql-fulltext`; no FrenchTaxesRules work.

## Correction and local tests

The prior smoke `4442019` proved the first probe defect: `sqlcmd` returned `1` plus `(1 rows affected)`. The probe now prefixes SQL with `SET NOCOUNT ON`, validates `$LASTEXITCODE`, requires exactly one non-empty integer line, and rejects arbitrary leading digits. Local PowerShell tests passed for: valid `1`; row-count noise; context noise; empty output; unexpected text. PowerShell syntax parsing passed.

The next run exposed a second, precise noise source: `USE FullTextSmoke` emitted `Changed database context to 'FullTextSmoke'.` before the scalar. The minimal follow-up replaces those scalar queries with `sqlcmd -d FullTextSmoke` and removes `USE` only from the status/count probes. This preserves the SQL operation and fail-closed parsing.

## Remote provenance

- Probe hardening commit: `f2bc2d25d1eb9c984ca58801ddccf6f620473c86`, message `[skip ci] WI-2222897 harden Full-Text smoke probe`.
- Context-noise correction commit: `62a286c48326c6eeae355e44a430e8d8b6ac63bf`, message `[skip ci] WI-2222897 remove sqlcmd context noise`.
- Definitions 14250 and 14251 were read back before queue; both remain dedicated, branch-defaulted to `sandbox/WI-2222897-sql-fulltext`, with `triggers: null`. No `codex` string was found in their metadata.
- The dirty master clone's three round12 files were not switched or overwritten. Work occurred in isolated `worktrees/Pipelines_Docker_BaseImages_worker2_round9`.

## Builds

- `4442095`, source `f2bc2d25...`: SQL 2019 built its image and reached catalog status; it failed because the status output still contained the database-context message. SQL 2025 was followed to terminal `failed` with the same old probe generation. No external publication occurred.
- `4442121`, source `62a286c4...`: manually queued definition 14251 after the second correction. SQL 2019 built its image and reached the actual population check; it failed closed after 90 seconds with `Full-Text population did not finish: [1]`. This is a real runtime population failure/timeout, not a parser failure, and `CONTAINSTABLE` was not reached. SQL 2025 remained `inProgress` at the latest collection point and must be followed to result before claiming its runtime outcome.

This smoke is not the 224-case business validation and cannot close the Clienteling catalog question. Pipeline effects remain limited to hosted-agent Docker build, local container smoke, and minimal pipeline artifacts on the dedicated definition; no image/feed/JFrog publication, promotion, tag, deployment, or downstream trigger is used.
