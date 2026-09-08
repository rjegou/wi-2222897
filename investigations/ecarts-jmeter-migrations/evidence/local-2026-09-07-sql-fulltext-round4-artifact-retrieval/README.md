# SQL Full-Text — artefact retrieval round4 (2026-09-07)

## Provenance and scope

- Scope: only diagnostic artefacts from Azure DevOps build `4442254`; no new run, commit, definition change, or repository edit.
- Definition `14251`, repository `Pipelines_Docker_BaseImages`, branch `sandbox/WI-2222897-sql-fulltext`, executed commit `4bb5830236585369f74645d88e1505eeccc183d7`.
- Metadata source: official Azure DevOps Build Artifacts API, read with Azure CLI/PAT in an isolated profile.
- Retrieval transport requested for this round: Python `requests`, TLS verification enabled, no browser-policy bypass.
- No PAT was sent to an artifact redirect host. Redirects were followed only without authentication.

## Duplicate check and concurrent state

FACT — a read-only search of the evidence README/index material found no other local collection containing the contents of the two 4442254 diagnostic ZIPs. Existing round3 metadata was reused; it was not modified.

FACT — the local worktree remains unchanged with the three pre-existing modifications in the SQL 2019/2025 Dockerfiles and `tests.yml`. The remote dedicated branch had already advanced to `4bb58302...` by another instance; no concurrent branch change was made here.

## Official metadata

FACT — the official Build Artifacts API returned HTTP 200 with two artefacts:

| artefact | id | reported size |
|---|---:|---:|
| `sql-fulltext-2019-evidence` | `5034439` | `47679` |
| `sql-fulltext-2025-evidence` | `5034449` | `51811` |

No signed URL, token, or redirect URL is recorded in this evidence.

FACT — metadata inspection of `resource.type` and `resource.data` identifies both artefacts as `PipelineArtifact`, not `Container`. Their `resource.data` fields are opaque 66-character references; the metadata also reports `HashType=DEDUPNODEORCHUNK` and the two RootIds. The File Containers API is therefore not the applicable retrieval path. The supported path is the Pipeline Artifact SDK/ArtifactTool flow, already attempted in round3.

## Python requests attempt

FACT — the Python transport read metadata successfully with TLS verification enabled: `METADATA status=200 redirects=0`.

For each artifact, the reported download URL returned HTTP `302` on the initial request. The redirect was followed without any Authorization header; the redirect target returned HTTP `203`. No ZIP was saved and no content hash exists.

```text
ARTIFACT sql-fulltext-2019-evidence initial_status=302
ARTIFACT sql-fulltext-2019-evidence redirect_status=203 hop=1
ARTIFACT sql-fulltext-2019-evidence NOT_SAVED final_status=203
ARTIFACT sql-fulltext-2025-evidence initial_status=302
ARTIFACT sql-fulltext-2025-evidence redirect_status=203 hop=1
ARTIFACT sql-fulltext-2025-evidence NOT_SAVED final_status=203
```

The earlier CLI ArtifactTool/.NET path failed with the same TLS/SSPI authentication error; it was not retried in this round. No TLS verification was disabled and no alternate host was contacted with the PAT.

## Findings

FACT — artifact publication is proven by metadata and the prior timeline; artifact payload retrieval is not proven. Therefore services/processes, `FULLTEXTSERVICEPROPERTY`, catalog/table state, population DMV, ERRORLOG, `CONTAINSTABLE`, and cleanup cannot be classified from these ZIPs.

INFERENCE — the direct prerequisite for closing item 5 is access to the published ZIP payload through an approved artifact transport that can authenticate the redirect flow without exposing the PAT to the redirect host. No further useful local transport attempt is justified after the bounded Python result.

UNKNOWN — Full-Text population’s direct cause remains unresolved; the common status `[1]` timeout is the latest available runtime fact.

## Item 6 boundary

FACT — the Clienteling Products support audit is referenced, not repeated: `2026-09-07-clienteling-products-support-worker2-round3`.

UNKNOWN — support and delivery by version remain UNKNOWN per that delegated collection; this round makes no Products claim.

## Resources and postconditions

- No shared document, worktree, branch, pipeline, definition, registry, feed, promotion, tag, or deployment was modified.
- The temporary Azure CLI profile `.tmp-az-fulltext-round2` remains in the workspace. It is a resource created by the prior collection, not by this round; removal was not attempted again after the earlier native cleanup rejection.
- New output is this evidence-only README. No raw secret, signed URL, or diagnostic payload was persisted.
