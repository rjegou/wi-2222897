# InventoryTracking transport round 10 — push permission stop

Date: 2026-09-08 Europe/Paris. Candidate `.work/transport-round7` was re-read directly. No source clone lock was touched and no remote branch, commit, pipeline or run was created by this round.

## FACT — direct verification

The manifest producer in `inventorytracking.azure-pipelines.yml` uses `sourceBuildId = '$(Build.BuildId)'` and `artifactName = '$(componentVersion)_Software'` exactly once. Each Cur/Fix job downloads `$(componentVersion)_Software`, computes hashes over the files actually present, and passes both values to the PlatformDeploy helper. The helper rejects sourceBuildId or artifactName mismatches and emits a standard camelCase ArtifactItem with `pipeline-artifact://<sourceBuildId>/<artifactName>`.

The real helper tests passed: `normal-path-static PASS`, `positive PASS`, `wrong-version PASS`, `wrong-source-build PASS`, `wrong-artifact-name PASS`, `wrong-hash PASS`, `duplicate-file PASS`, `unexpected-root-file PASS`, `missing-manifest PASS`, `ALL CASES PASS`. All candidate PowerShell files parsed successfully.

## FACT — remote mutation attempt and blocker

The operator prepared REST Git Pushes with `oldObjectId` and first attempted to create the dedicated PlatformDeploy branch from master `93f91487ee717185599555a42df3cb5d024ace89`. Azure DevOps rejected branch creation before any push:

`VS403660: You do not have permission to create ref 'refs/heads/validation/WI-2222897-inventorytracking-local-transport-20260908' ... scope 'repository'.`

No plugin branch creation, commit push, blob readback, pipeline queue, or JMeter run was attempted after this failure. No permission bypass was used.

## Hashes relus

| file | SHA-256 |
|---|---|
| `prepare-local-inventorytracking-package.ps1` | `90B397FC00CFFD7E9876E7F1097E2A3E9E15E524BF0E31E23F4EAF47C74C7333` |
| `download-packages.ps1` | `5415C82BC8C0E02AB650172B38DE840C1208B67DECD4139C4046B20E23097B0F` |
| `docker-pipeline-deploy.ps1` | `E972F9A7125613F3F531F21F742CF766C88194129B207E87D7E0303D47F33F90` |
| `docker-pipeline-deploy-ps7.ps1` | `209D9DE9211CC556714C8C3DA35769C1B6C39159228C79B5E4AD44BAD07E7065` |
| `task-deploy-in-containerized-job.v2.yml` | `5C15CE4841FEB5B9ADAD23BADFD31A84891C5371BA02070990610D09325C9C73` |
| `inventorytracking.azure-pipelines.yml` | `8387EA8A883AD9A4004D34638AE3866645483FAA72DA7B215DEAD472A0ABB6C9` |
| `test-local-transport.ps1` | `218CDB444772FD8A5D562B7FBE176D2DFEA81F303F864A4BC3FD8EA2B8566EA7` |

## UNKNOWN

No terminal Build + Cur/Fix result exists for this candidate because AzDO rejected the required branch creation. The permission issue requires an authorized branch or repository permission decision; changing services, shared agents, feeds, or staging is out of scope.
