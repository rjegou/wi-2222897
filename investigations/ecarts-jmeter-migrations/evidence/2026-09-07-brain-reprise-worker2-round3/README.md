# SQL Full-Text validation — Worker 2 round 3

Date : 2026-09-07 (Europe/Paris). No shared canonical document was modified.

## Existing correction reviewed

The prior evidence `local-2026-09-07-sql-fulltext-round12/README.md` was read and not reimplemented. It documents the minimal Dockerfile correction: SQL 2025 setup changes to `/FEATURES=SQLENGINE,FullText`; SQL 2019 uses SQLEXPRADV / Advanced media and the same feature selection. Its `tests.yml` smoke gate checks `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')=1` but no SQL installation or container was run.

## Dedicated candidate

`azure-pipelines.sql-fulltext-build-only.yml` is a standalone candidate with:

- `trigger: none`, `pr: none`, `schedules: []`;
- two independent Build/test stages for SQL Server 2019 (`ltsc2022`) and SQL Server 2025 (`ltsc2025`);
- an explicit future pool `SQL-FULLTEXT-ISOLATED` with custom demands `Docker=true` and `FullTextValidation=true`;
- local Docker build only, no registry login, image push, Artifactory/JFrog, feed, promotion, tag, downstream trigger, or shared environment;
- runtime assertion `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')=1`;
- discriminating smoke: create a database, full-text catalog/index, wait for population, query `CONTAINSTABLE`, require at least one hit, then drop the temporary database;
- pipeline artifacts limited to container logs.

The candidate does not claim to validate the 224 Clienteling cases or the Clienteling catalog/function. It proves only the image installation/runtime gate and a minimal Full-Text operation.

FACT — local PyYAML parsing succeeds (`trigger=none`, `pr=none`, empty schedules, stages `SQL2019` and `SQL2025`). The external `fulltext-probe.ps1` also passes Windows PowerShell parser validation. SHA-256 values are in `SHA256SUMS.txt`.

## Agent prerequisite and queue decision

FACT — live Azure DevOps pool inspection through Python requests/TLS verified found `Private VS2019` agents online on `Windows_NT 10.0.17763`, with no Docker capability reported; this is not proof of a compatible Windows Server Core 2022/2025 container host. The hosted `Azure Pipelines` pool exposes online agents, but their OS/container capabilities were not available in the read-only response and isolation was not proven.

INFERENCE — no existing pool is sufficiently proven for this candidate. SQL Server 2025 `windowsservercore-ltsc2025` especially requires a compatible Windows container host; selecting `Private VS2019` or an unqualified hosted agent would risk an invalid or shared run.

Therefore no pipeline, branch, definition, pool, or queue was created. This is a concrete executable candidate once an isolated compatible pool is attested. Docker Desktop local was not invoked.

## Provenance and limits

- Source worktree: `worktrees/Pipelines_Docker_BaseImages`.
- Existing local changes were preserved: `Images/SqlExpress/2019/dockerfile`, `Images/SqlExpress/2025/dockerfile`, `Images/SqlExpress/tests.yml`.
- The YAML candidate is evidence-only and is not committed to a repository or registered remotely.
- Exact live Azure DevOps reads used Python 3.12 `requests` with `verify=True`; PAT was read in memory and cleared in `finally`.
- Remaining UNKNOWN: compatible isolated agent availability, Docker Windows-container mode, media acquisition/build success, runtime Full-Text property on both versions, catalog population, and all 224 Clienteling cases.
