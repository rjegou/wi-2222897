# FrenchTaxesRules V26 runtime preflight — round 8

## Provenance and resolved references

- Source YAML: `Y2_Plugins_FrenchTaxesRules/azure-pipelines.yml` at commit `f80bc731571b2b5ed8a67da171b288873de428a6`, the source of build 4432510.
- Effective source values: pool `Azure Pipelines` / `windows-latest` (lines 96-97); container image tag `cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025` (lines 31-36, 93-95); registry endpoint `AzureContainerRegistry-Docker-Retail` (line 95).
- Registry mechanism: `Docker@2` is not used by 4432510 to log in directly; its transitive `job-ensure-docker-image-in-acr.v1.yml@azoTemplates` imports/checks the image through ACR and JFrog. The historical runtime image digest used here is the independently recorded V26 digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`.
- Transitive template commits read through REST on 2026-09-08: `Pipelines_Templates` `acf748eb49b901f9e54b69565e371d6d9ca4dc21`, `Y2_Tools_Jmeter_Workflow` `4db2dcdab647249de3cdc27eadaf15a158b3a26a`, `Y2_Tools_PlatformDeploy` `93f91487ee717185599555a42df3cb5d024ace89`.

## Static effect review

- **FACT**: build 4432510's YAML enables master/releases triggers and Saturday schedule; it includes Artifactory staging, PlatformDeploy, TestAutos/JMeter, log publication, Promote, source tagging and release notes. Its `task-deploy-in-containerized-job.v2.yml` downloads PlatformDeploy via `JFrogGenericArtifacts@1`; `task-run-campaign.v1.yml` publishes test results.
- **FACT**: definition 14246 / run 4442696 is only a mechanism reference. Its exact YAML is `azure-pipelines.wi2222897-v22-preflight.yml` at commit `68f1f7a8e575e79cf3098cafcd16e10b22237ada`; it uses `trigger: none`, `pr: none`, `schedules: []`, `Azure Pipelines`/`windows-latest`, `Docker@2` login, `docker image inspect`, ephemeral `docker create`, scrubbed JSON, no artifact publication, and exact-name cleanup.
- **INFERENCE**: the attached YAML is the minimal V26 adaptation of that mechanism. It does not checkout, restore a backup, deploy PlatformDeploy, consume Console/JMX, call business endpoints, publish a PipelineArtifact, or touch shared cleanup. Its only external resource is a uniquely named labeled container and its agent-temp output.

## Status

## Run 4445476 result

- **FACT**: the YAML was published at commit `408091c6e65c774876541ae979eac3d4877a2a1b` on `sandbox/frenchtaxesrules/v26-preflight-20260908`, definition `14265`, and queued once. It completed `failed` at `2026-09-08T11:47:52.5203411Z` after the ten-minute job timeout.
- **FACT**: Docker@2 registry login succeeded. The agent pulled the pinned image and logged digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`, matching the requested digest. No backup, PlatformDeploy, Console, JMX, business call, artifact publication or shared cleanup was executed.
- **FACT**: the inspection task was canceled while the image/container operation was still running; no OS/mount/network attestation was emitted. The post-step hashed one expurgated temporary output (`92A41510A395FA404ABE346DFEFB2F3377D8D59AA3A97964E6589029CAD44022`) and reported no artifact publication.
- **UNKNOWN / required intervention**: because cancellation interrupted the `finally` cleanup assertion, current existence of `wi2222897-frenchtaxesrules-v26-preflight-4445476` on agent `Azure Pipelines 29` is not proven. Do not relaunch this preflight or proceed to JMeter until Azure DevOps/agent operations verifies and, if present, removes only that exact labeled resource.
