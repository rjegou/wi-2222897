# Consolidated handoff — Worker 2, round 14

Date: 2026-09-07 (Europe/Paris). This is a fusion-ready evidence-only deliverable. No `HANDOFF.md`, `STATUS.md`, `RESOURCES.md`, `JOURNAL.md`, or other canonical shared document was modified. FrenchTaxesRules V22 release analysis is not repeated.

## Executive matrix

| Area | Current verdict | Direct evidence | Remaining boundary / next action |
|---|---|---|---|
| Clienteling V22–V25 generation/endpoints | FACT — 20/20 generated with code 0, XML parsed, endpoints conform to manifests | [worker1 round4](../2026-09-07-brain-reprise-worker1-round4/README.md) | HTTP/MSI/SQL/IIS execution and Products support decision remain UNKNOWN |
| Clienteling orchestration | FACT — corrected package consumed descriptor and produced 151 JMX; all 151 parsed | [worker1 round5](../2026-09-07-brain-reprise-worker1-round5/README.md) | Runtime HTTP/MSI/SQL/IIS and `ClientelingProductsService.svc` support remain UNKNOWN |
| SOAP negative, SQL/date generation | FACT — local harness/package evidence validates the targeted negative SOAP and SQL/date generation paths | [soap package round14](../local-2026-09-07-soap-package-round14/) and [round2 harness](../2026-09-07-brain-reprise-worker1-round2/) | No end-to-end business replay; keep runtime outcome UNKNOWN |
| PlatformDeploy init-container | FACT — real original/corrected init-container executed with identical inputs, TF_BUILD=true; original absorbs child 7, corrected refuses it; success and exception behavior preserved | [worker2 round8](../2026-09-07-brain-reprise-worker2-round8/README.md) | External MSI/Docker/SQL/IIS compatibility not tested |
| InventoryTracking XmlDiff | FACT — CI builds 4440774/4440884 show MSB3245=0 and CS0103=0; 4440884 ran 48/48 assembly tests and JMeter stages | [consolidated round7](../2026-09-07-brain-reprise-consolidated-round7/README.md) | TC105 SQL root cause remains UNKNOWN; use reconciled counters, not physical-line fallback |
| InventoryTracking counters | FACT — logical CSV count 13,501; 141 exact phrase occurrences and 183 classified error records are different scopes; Cur/Fix error rows 339/340 are reconciled | [worker1 round11](../2026-09-07-brain-reprise-worker1-round11/README.md) | TC105 payload/runtime SQL evidence is still missing |
| Full-Text SQL2019/2025 | EN COURS — diagnostic build 4442156 is in progress; no verdict anticipated | [worker2 round13](../2026-09-07-brain-reprise-worker2-round13/README.md) | Must read terminal result and runtime artifacts before changing image or claiming CONTAINSTABLE |
| Shared naming audit | FACT — old server ref `codex/wi-2222897-v22-preflight-20260907` and proposed neutral ref are absent; definition 14246 still has obsolete defaultBranch | [worker1 round13](../2026-09-07-brain-reprise-worker1-round13/README.md) | Correcting defaultBranch requires an existing approved neutral ref or explicit instruction to create one; audit is not a universal absence claim |

## Full-Text status, bounded

Build `4442121` completed failed on both variants after image construction and `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')=1`; both catalog probes stayed at status `1` for 90 seconds. Microsoft Learn defines status 1 as full population in progress. This is a runtime population problem, not the earlier sqlcmd parsing defect. The dedicated diagnostic YAML collects service/process state, catalog and table population status, fragments, `sys.dm_fts_index_population`, and ERRORLOG before container removal.

Build `4442156` was manually queued from commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a` on `sandbox/WI-2222897-sql-fulltext`; definition 14251 remains triggerless and dedicated. At the latest observation both stages were still `inProgress`. Do not infer Full-Text or `CONTAINSTABLE` success from this run until artifacts and terminal status are read.

## Resources: created versus observed

Created by this workstream: dedicated branch `sandbox/WI-2222897-sql-fulltext`; definitions 14250 (diagnostic) and 14251 (build); builds 4442007, 4442013, 4442019, 4442095, 4442121 and 4442156; neutral commits `412602e`, `5fdc615`, `f2bc2d2`, `62a286c`, `cc2ecfb`, `0baf69c`. These resources were confined to the dedicated branch/definitions; no shared definition, image registry, feed, promotion, tag, deployment, or downstream pipeline was modified.

Observed but not created by this workstream: InventoryTracking builds 4440774/4440884, Clienteling evidence, PlatformDeploy source/candidate worktrees, and definition 14246. The dirty master clone with its three round12 modifications was preserved. No cleanup was performed.

## Remaining actions requiring external state

1. Read 4442156 terminal result and both diagnostic artifacts. If service is running and table/DMV status remains 1, capture crawl/error evidence before any image change.
2. Keep TC105 as UNKNOWN until the payload, SQL execution context, and comparable legacy/JMeter runtime evidence exist.
3. Decide whether `ClientelingProductsService.svc` is supported before enabling or judging Products cases.
4. For definition 14246, obtain an approved existing neutral ref or explicit authorization to create one; do not point the obsolete defaultBranch to master by inference.

