# Round 5 read-only CI closure — 2026-09-07

## Dedicated-resource inventory

- **FACT** — In `Pipelines_Docker_BaseImages`, no matching branch (`2222897`, `FullText`, `InventoryTracking`, `sql-fulltext`) and no matching Full-Text definition were returned by REST readback. Master remains `cd5a72235e5f71373acb8994cb3f60f2f6975b93`. The prior round4 push to create `validation/WI-2222897-sql-fulltext-round4` was refused with TF401027; no retry was made.
- **FACT** — An existing dedicated InventoryTracking branch does exist in repository `Y2_Plugins_InventoryTracking` (`90f886fd-8a68-483f-b798-126928e6297f`): `refs/heads/validation/WI-2222897-inventorytracking-xmldiff` at `ef3d87034d38b88aca04c824061b140e2a29252c`.
- **FACT** — Its definition is 2072 `InventoryTracking CI`, not a dedicated definition: default branch is `master`, YAML is `/azure-pipelines.yml`, CI trigger is enabled, and the YAML has scheduled master/releases runs. The YAML contains ACR/JFrog image handling, private-agent build/MSI/package publication, deployment, JMeter stages, and Artifactory staging. It is therefore not safe for another isolated queue.

## Existing InventoryTracking runs (read-only)

- **FACT** — Build 4440774, definition 2072, source branch above and source commit `ef3d8703…`, manual, completed `succeeded` at `2026-09-07T12:29:19.752Z`. Timeline shows `dotNet-build: Build solution` succeeded and `Stage TI JMeter V26` skipped; this is evidence of compilation/build flow, not a JMeter validation.
- **FACT** — Build 4440884, same branch/definition/commit, completed `partiallySucceeded` at `2026-09-07T13:56:07.878Z`. Timeline directly shows JMeter campaign execution, Y2 deployment, Artifactory staging/upload and JFrog tasks; published test results reported failures. This confirms why definition 2072 must not be queued for this isolated mission.
- **INFERENCE** — The existing branch is useful evidence for the XmlDiff compilation candidate, but not a bounded Full-Text or build-only CI vehicle.

## Full-Text candidate review

- **FACT** — `sql-fulltext-hosted-build.yml` uses `windows-2022` for SQL 2019 (`BASETAG=ltsc2022`) and `windows-2025` for SQL 2025 (`BASETAG=ltsc2025`), with no registry/feed/JFrog/promotion/tag/deployment operation. `trigger`, `pr`, and `schedules` are disabled.
- **FACT** — The Dockerfile corrections from round12 are present in the preserved local worktree: SQL 2019 uses Advanced media and `/FEATURES=SQLENGINE,FullText`; SQL 2025 uses `/FEATURES=SQLENGINE,FullText`. No code/package correction was made in this round.
- **FACT** — The hosted build references `fulltext-probe.ps1`; the probe from round3 must be carried into the dedicated branch alongside the YAML. It is blocking: `$ErrorActionPreference='Stop'`; every `sqlcmd` failure throws; `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` must equal `1`; catalog population must reach `0`; `CONTAINSTABLE` must return at least one hit; otherwise the step throws and the job fails.
- **UNKNOWN** — No hosted runtime proof exists because the dedicated branch could not be created. No claim is made about Docker daemon availability, SQL installation, or Full-Text runtime state.

## External prerequisite

An operator with Git `CreateBranch` permission must create the dedicated Full-Text branch in `Pipelines_Docker_BaseImages`, add the two round4 YAML candidates plus the round3 probe and the round12-corrected Dockerfiles, then create a dedicated YAML definition with no triggers. Only then is a manual diagnostic queue appropriate. Do not queue definitions 2072 or 8090.
