# Worker 2 — Full-Text Round 11

Date: 2026-09-07 (Europe/Paris). Source: Azure DevOps REST API over verified TLS, project Retail, repository `Pipelines_Docker_BaseImages`. PAT was used in process memory only and is not present here.

## Scope and trigger safety

The dedicated branch is `refs/heads/sandbox/WI-2222897-sql-fulltext`. Read-only checks found no PR for this branch, no tag at the branch head, and no enabled build policy filtered to this branch; the observed build policies were scoped to `refs/heads/master`. The six existing definitions were inspected at an explicit branch version. Definitions 6823, 6874, 10260, 14079 and 14084 had YAML `trigger: none` at that version; definition 8090's requested YAML item was absent at the branch commit. The dedicated definitions below have no trigger configuration and were queued manually.

Official Azure Pipelines documentation confirms that `[skip ci]` suppresses a push CI run that would otherwise trigger, but does not universally suppress tag-triggered builds or PR validation policies. Therefore the marker was used only together with the branch/policy/tag checks above, not as the sole safety control. Sources: [Azure Repos Git pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/repos/azure-repos-git?view=azure-devops), [trigger schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/trigger?view=azure-pipelines), [trigger troubleshooting](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/troubleshoot-triggers?view=azure-devops).

## Dedicated resources and provenance

- Push `[skip ci] WI-2222897 dedicated SQL Full-Text candidates`: commit `412602e55b0e16130f3de7567e6f8979c63bf9cf`.
- Diagnostic interpolation correction push `[skip ci] WI-2222897 fix hosted diagnostic variable interpolation`: commit `5fdc6150b5af9c41ec6a6684a7da62bd2825ac3a`.
- Definition 14250, `WI-2222897 SQL FullText Hosted Round11`, YAML `/validation/WI-2222897/sql-fulltext-hosted-diagnostic.yml`.
- Definition 14251, `WI-2222897 SQL FullText Hosted Build Round11`, YAML `/validation/WI-2222897/sql-fulltext-hosted-build.yml`.
- No shared definition, image registry, feed, promotion, tag, downstream pipeline or deployment was modified or invoked. The created definitions/builds remain for review/cleanup by the supervising worker.

The dirty local clone was not switched: its three round12 modifications remained the only tracked changes. Candidate work was inspected in isolated worktree `worktrees/Pipelines_Docker_BaseImages_worker2_round9`.

## Hosted diagnostic

Build `4442007` (commit `412602e...`) succeeded but exposed a diagnostic-only PowerShell interpolation defect (`$(Agent.OSVersion)` was treated as command substitution). It was corrected narrowly to `$env:AGENT_OSVERSION` and re-run.

Build `4442013` (commit `5fdc6150...`) succeeded on a fresh Microsoft-hosted `windows-2025` agent. Direct log evidence: Windows Server 2025 Datacenter, build 26100; Docker client/server 29.7.2, `windows/amd64`; `docker version exit=0`, `docker info exit=0`, `windowsfilter`, process isolation, zero containers/images. The artifact was `hosted-diagnostic`.

## Full-Text smoke

Build `4442019` is a manual run of definition 14251 at commit `5fdc6150...`, with independent SQL 2019/windows-2022 and SQL 2025/windows-2025 stages. Both stages are build/test only and use the round12 Dockerfiles and `fulltext-probe.ps1`; they do not push images or publish to external registries.

The terminal readback completed the run as `failed` at `2026-09-07T16:07:17.575Z`. SQL 2019 stage was completed `failed` at `2026-09-07T16:00:17.826Z`; SQL 2025 stage was completed `failed` at `2026-09-07T16:07:17.246Z`. Both images built successfully and both containers started. The first causal probe failure for each version was:

    Full-Text service property is not 1: [1
    (1 rows affected)]

This is a probe-output parsing defect: the captured value contains the valid value `1` plus sqlcmd's row-count message. Both probes failed closed before reaching `CONTAINSTABLE`; this is not proof that either SQL version lacks Full-Text. The logs also show successful SQL 2025 service configuration before the probe failure.

The run does not validate the 224 business cases or the Clienteling catalog; it is only an isolated installation/property/CONTAINSTABLE smoke path. No claim of Full-Text support is closed by the SQL 2019 result.
