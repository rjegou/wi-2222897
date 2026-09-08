# Docker review — builds 4444389 and 4440884

Date: 2026-09-08 (Europe/Paris). Collection method: Azure DevOps REST API, read-only, build metadata, timelines and selected log bodies. Secrets and raw credentials were not collected.

## Direct facts

Build `4444389` (7.77) is running on `refs/heads/validation/WI-2222897-inventorytracking-isolated-20260908`, source `13d0db910153952f1827f05f6532fa0f06741124`, queue/pool `Azure Pipelines`. Its JMeter Fix job is `failed`; its Cur job was still pending at collection time. The Docker Ensure phase and Artifactory staging phase are skipped.

The failed Fix job ran on agent `Azure Pipelines 9`. Its container initialization log reports agent version `5.278.0`, Windows image `windows-2025`, image version `20260830.247.1`, then four failed attempts to execute `docker version --format '{{.Server.APIVersion}}'`. The Docker API endpoint was `npipe:////./pipe/docker_engine`; the Windows system reported that the file did not exist. The task then failed with `ContainerId` null. The later missing deployment-log ZIPs and stop-network failure are consequences of this initialization failure.

Build `4440884` (7.76) completed `partiallySucceeded` from `ef3d87034d38b88aca04c824061b140e2a29252c`. Its Docker Ensure job succeeded on agent `Azure Pipelines 43`, using Ubuntu image `ubuntu-24.04`, image version `20260831.293.1`, and found ACR `AcrRetailDocker` and the JMeter image up to date. The ACR and JFrog digest matched: `ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`. Its Cur and Fix preparation/run tasks completed and the JMeter jobs reached `succeededWithIssues`.

Both builds restored `Y2.Tools.Jmeter.Workflow` version `3.0.175`. The exact consumed revisions of the external YAML template repositories remain UNKNOWN because the pipeline resources have no explicit `ref` in the recorded YAML. The 4440884 PlatformDeploy checkout was previously observed at `93f91487ee717185599555a42df3cb5d024ace89`; this does not establish revisions for the other templates.

## Causal conclusion

FACT: excluding Ensure ACR did not remove the JMeter container requirement. The JMeter job still declares/initializes a container, and 4444389 fails before the JMeter run because the local Docker daemon/API is unavailable.

INFERENCE: the agents are hosted/ephemeral or at least non-stable between runs: 4444389 uses Windows/agent 9 while 4440884 uses Ubuntu and several different agent identities. There is no evidence here of a persistent shared agent that can safely be repaired. Do not restart a pool or clean Docker globally.

FACT: re-enabling shared ACR publication cannot fix a missing local Docker named pipe. No evidence supports changing Ensure ACR, image promotion, or global pool configuration.

## Minimal safe next step

Keep Ensure ACR and shared publication disabled on the isolated validation branch. Add a branch-scoped preflight before the JMeter stage that records only OS/image/agent identity and a redacted `docker version` result, and fails fast with an actionable message if the Docker API is unavailable. The preflight must not install, restart, remove containers, alter pools, publish images, promote artifacts, or tag sources.

Queue the validation branch only on an agent/image contract that demonstrably provides the required Docker daemon (the successful 4440884 Ubuntu path is a candidate, not a guarantee for a future run). Preserve Build, the pipeline NuGet artifact and Cur/Fix preparation/run tasks. Apply the exact TC122 instrumentation in `../TC122-INSTRUMENTATION.patch`: response/path/correlation values are hashed, with no raw secret-bearing fields.

UNKNOWN: whether the Azure Pipelines queue can constrain this branch to a compatible image without a global pool change; whether the next run will receive a Linux-capable agent; and whether the selected image contains the expected JMeter container runtime. These require a controlled worker-1 run and artifact/log verification.

No remote mutation, restart, cleanup or pipeline launch was performed by this collection.
