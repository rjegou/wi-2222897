# InventoryTracking transport correction — sourceBuildId / artifactName

Date: 2026-09-08 Europe/Paris. Candidate: `.work/transport-round7`, based on PlatformDeploy commit `93f91487ee717185599555a42df3cb5d024ace89`. No Azure DevOps mutation was performed in this correction.

## Correction

The local manifest now carries two distinct fields:

- `sourceBuildId`: `$(Build.BuildId)` of the current pipeline run;
- `artifactName`: `$(componentVersion)_Software`, the exact name passed to `download: current`.

Each Cur/Fix job downloads that exact artifact name, generates the manifest from the files actually present, and passes both expected values to PlatformDeploy. The helper rejects a manifest with the wrong source build or artifact name before copying any file. The produced `downloadedPackages.json` entry uses `pipeline-artifact://<sourceBuildId>/<artifactName>` and the standard camelCase fields `uri`, `filename`, `name`, `version`. No AzDO resource artifact ID is assumed or required.

## Independent tests

Executed `test-local-transport.ps1` against the real helper and fixture files from artifact 5037140:

`normal-path-static PASS`; `positive PASS`; `wrong-version PASS`; `wrong-source-build PASS`; `wrong-artifact-name PASS`; `wrong-hash PASS`; `duplicate-file PASS`; `unexpected-root-file PASS`; `missing-manifest PASS`; `ALL CASES PASS`.

PowerShell parse and YAML/isolation guards also passed. The candidate contains no `retail-software-staging`, and the candidate branch remains excluded from ACR ensure and staging publication. Existing container jobs and pull timeouts were not rewritten.

## Candidate hashes

| file | SHA-256 |
|---|---|
| `prepare-local-inventorytracking-package.ps1` | `90B397FC00CFFD7E9876E7F1097E2A3E9E15E524BF0E31E23F4EAF47C74C7333` |
| `download-packages.ps1` | `5415C82BC8C0E02AB650172B38DE840C1208B67DECD4139C4046B20E23097B0F` |
| `docker-pipeline-deploy.ps1` | `E972F9A7125613F3F531F21F742CF766C88194129B207E87D7E0303D47F33F90` |
| `docker-pipeline-deploy-ps7.ps1` | `209D9DE9211CC556714C8C3DA35769C1B6C39159228C79B5E4AD44BAD07E7065` |
| `task-deploy-in-containerized-job.v2.yml` | `5C15CE4841FEB5B9ADAD23BADFD31A84891C5371BA02070990610D09325C9C73` |
| `inventorytracking.azure-pipelines.yml` | `8387EA8A883AD9A4004D34638AE3866645483FAA72DA7B215DEAD472A0ABB6C9` |
| `test-local-transport.ps1` | `218CDB444772FD8A5D562B7FBE176D2DFEA81F303F864A4BC3FD8EA2B8566EA7` |

## Review request

Worker 2 should review this correction specifically. After favorable review, the operator may push isolated branches using REST Git Pushes with `oldObjectId`, reread branch/blob refs, verify effective parameters/isolation, and queue exactly one Build + Cur/Fix. No remote action is authorized by this evidence alone.
