# SQL Full-Text — diagnostic terminal round3 (2026-09-07)

## Provenance

- Source system: Azure DevOps `Retail`.
- Definition: `14251`, `WI-2222897 SQL FullText Hosted Build Round11`.
- Build: `4442254`, `WI-2222897-SQLFullText-HostedBuild-20260907.6`.
- Repository/branch: `Pipelines_Docker_BaseImages`, `refs/heads/sandbox/WI-2222897-sql-fulltext`.
- Executed commit: `4bb5830236585369f74645d88e1505eeccc183d7`.
- Read-only collection: Azure CLI `azure-devops` 1.0.8, isolated `AZURE_CONFIG_DIR`, PAT loaded only in process from the authorized local file. No secret was displayed or persisted.
- No run was queued by this collection. Active-run query for definition 14251 returned `[]`.

## Concurrent branch state

FACT — before any possible repository edit, the required status check on `worktrees/Pipelines_Docker_BaseImages` returned:

```text
## master...origin/master
 M Images/SqlExpress/2019/dockerfile
 M Images/SqlExpress/2025/dockerfile
 M Images/SqlExpress/tests.yml
```

FACT — the dedicated remote branch had advanced from the previous run’s commit `0baf69c1...` to `4bb58302...` before this collection. This is a concurrent change by another instance; it was not edited here.

## Why 4442156 had no diagnostics

FACT — the exact YAML at commit `0baf69c1...` has publish steps without an explicit condition:

```yaml
- publish: $(Build.ArtifactStagingDirectory)
  artifact: sql-fulltext-2019-evidence
```

and equivalently for SQL 2025. Since the smoke task failed, both `PublishPipelineArtifact` tasks were `skipped`. The diagnostic commands wrote files under `$(Build.ArtifactStagingDirectory)` and redirected their output; they therefore did not appear in the task log and were not recoverable from build 4442156.

## Corrected run already executed

FACT — commit `4bb58302...` adds `condition: always()` to both publish steps and adds a Docker preflight. Build `4442254` used that commit; no duplicate run was launched.

FACT — timeline for 4442254 shows both smoke tasks failed, but both `PublishPipelineArtifact` tasks succeeded:

| variant | smoke result | publish result |
|---|---|---|
| SQL 2019 | failed, 17:34:16–17:41:02 UTC | succeeded, 17:41:02–17:41:05 UTC |
| SQL 2025 | failed, 17:34:17–17:47:16 UTC | succeeded, 17:47:16–17:47:20 UTC |

FACT — `az pipelines runs artifact list --run-id 4442254` returned:

- `sql-fulltext-2019-evidence`, artifact id `5034439`, reported size `47679`;
- `sql-fulltext-2025-evidence`, artifact id `5034449`, reported size `51811`.

## Diagnostic retrieval attempt

The two artifact downloads were attempted using the CLI artifact command and then once via each artifact’s reported download URL, with the PAT kept in process memory. Both methods failed with the same TLS/SSPI error:

```text
System.Net.Http.HttpRequestException: The SSL connection could not be established
System.Security.Authentication.AuthenticationException
Win32Exception: Aucune information d’identification n’est disponible dans le package de sécurité
```

No TLS verification was disabled and no browser-policy refusal was bypassed. The destination evidence subdirectories contain no downloaded files.

## Results and limits

FACT — 4442254 proves the corrected publication path works and that both variants reached their smoke tasks, which failed. It does not by itself expose the diagnostic file contents.

FACT — from the prior build logs, both variants reached image construction and failed after `Full-Text population did not finish: [1]`; `CONTAINSTABLE` was not reached.

UNKNOWN — service state, `FULLTEXTSERVICEPROPERTY`, catalog/table population details, DMV rows, ERRORLOG, and cleanup postcondition remain unreadable because the published ZIPs cannot be downloaded in this environment.

INFERENCE — the missing-diagnostics cause is closed: it was the implicit `succeeded()` condition on publication, not absence of diagnostic code. The Full-Text population cause remains open.

## Resources and postconditions

- No shared document was modified.
- No local worktree file was modified.
- No pipeline, branch, definition, registry, feed, promotion, tag, or deployment was created or changed by this collection.
- Temporary Azure CLI profile `.tmp-az-fulltext-round2` remains in the workspace because native removal was rejected by policy; it is a bounded resource containing only CLI cache/extension files and must be removed later by an approved native cleanup method.
