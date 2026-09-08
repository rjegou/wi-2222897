# Agent comparability — builds 4440884 and 4444389

Date: 2026-09-08 (Europe/Paris). Source: Azure DevOps REST build metadata, timelines and selected logs, collected read-only. Earlier evidence was not modified.

## Job matrix

| Build | Exact job / purpose | Timeline record (type/result) | Agent / OS image | Container and Docker evidence |
|---|---|---|---|---|
| 4440884 | Build V26 | `2a130c04-1486-5a73-a382-fad121cfea2b` (Job/succeeded), log 84 | `vm-alm-agent-02-A`; self-hosted identity; OS image not reported in this job log | Build job is not the JMeter container job; no container conclusion |
| 4440884 | Ensure Docker image / preparation | `1e64d301-36f8-58d2-83c9-7957632a52c9` (Job/succeeded), log 19 | Azure Pipelines 43; Ubuntu 24.04, `20260831.293.1` | Checks ACR `AcrRetailDocker`; `y2-jmeter` digest `ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2` |
| 4440884 | JMeter Cur | `695043ab-e776-5178-ee76-76a301c1de11` (Job/succeededWithIssues), log 190; prepare `7086f859-3c5d-5db2-bbc5-e52cfa67d264`, run `f12bcdc5-108e-588e-2264-de889c09953c` | Azure Pipelines 2; Windows 2025, `20260830.247.1` | Pulls `y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`; digest `ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`; Docker pull/inspect/create succeed |
| 4440884 | JMeter Fix | `cfe27557-def1-507a-d355-2a5f2652ce65` (Job/succeededWithIssues), log 196; prepare `f67f8319-52a2-5949-e433-17ced0e6d551`, run `06a827d8-1b13-50c6-a4da-14fef2429110` | Azure Pipelines 3; Windows 2025, `20260830.247.1` | Same Windows container tag and digest; Docker pull/inspect/create succeed |
| 4444389 | Build V26 | `2a130c04-1486-5a73-a382-fad121cfea2b` (Job/succeeded), log 76 | `vm-alm-agent-04-A-A`; self-hosted identity; OS image not reported in this job log | Build job is separate from JMeter container jobs |
| 4444389 | Ensure Docker image / preparation | `5c908e62-6276-52ff-e3c1-a5071d7d33f3` (Phase/skipped) | No agent ran this phase | No ACR check or import ran; this is not evidence that the JMeter daemon is optional |
| 4444389 | JMeter Cur | `695043ab-e776-5178-ee76-76a301c1de11` (Job/canceled), log 178; prepare `7086f859-3c5d-5db2-bbc5-e52cfa67d264`, run `f12bcdc5-108e-588e-2264-de889c09953c` | Azure Pipelines 17; Windows 2025, `20260830.247.1` | Container initialization started and was canceled; the job log shows the same Windows container tag and digest before cancellation |
| 4444389 | JMeter Fix | `cfe27557-def1-507a-d355-2a5f2652ce65` (Job/failed), log 129; prepare `f67f8319-52a2-5949-e433-17ced0e6d551`, run `06a827d8-1b13-50c6-a4da-14fef2429110` | Azure Pipelines 9; Windows 2025, `20260830.247.1` | `docker version` cannot open `npipe:////./pipe/docker_engine`; no container was created and the task ends with `ContainerId` null |

The repeated record IDs are the identifiers returned by the timeline API for the corresponding job names; the build-specific log IDs and timestamps distinguish the two runs.

## Corrected comparison

FACT: Ubuntu 24.04 belongs only to 4440884's Ensure Docker job. It is not the OS of either JMeter Cur or Fix job. Both builds' JMeter jobs target Windows 2025 and the same Windows Server Core LTSC 2025 JMeter image tag.

FACT: 4440884 JMeter Cur and Fix reached container creation; 4444389 Fix failed at Docker daemon discovery before container creation, and Cur was canceled before completion. Therefore excluding Ensure ACR did not cause an OS mismatch, and there is no evidence that Ensure ACR was a prerequisite for the daemon itself.

INFERENCE: differing hosted-agent numbers indicate non-stable allocation; Build V26 is a separate self-hosted job from the JMeter jobs. No evidence permits a shared-agent restart or pool-wide change.

The YAML at both source commits declares `container: acr_y2jmeter_test` and the same pool/container structure. The external repositories `azoTemplates`, `jmeterTemplates` and `leoTemplates` have no explicit `ref`; their exact resolved revisions remain UNKNOWN. The isolation diff changes only branch-scoped conditions for Ensure and Publish, leaving Build and JMeter container declarations intact.

## Safe preflight for worker 1

Use a branch-scoped preflight in the JMeter stage before preparation, without installing/restarting Docker or changing a pool:

```powershell
$dockerVersion = & docker version --format '{{.Server.APIVersion}}' 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Docker daemon unavailable on this agent; JMeter container precondition failed."
  exit 1
}
Write-Host "Docker daemon reachable; API version collected without credentials."
```

Keep Ensure ACR, Artifactory staging, promotion, tags and shared publication disabled on the isolated branch. Require a Windows 2025 agent with a reachable Docker daemon and preserve the exact container tag/digest, Build, NuGet artifact, Cur/Fix setup and assertions. The preflight is diagnostic and fail-fast; it does not repair shared infrastructure.

No remote mutation, launch, restart or cleanup was performed.
