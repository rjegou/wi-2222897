# V22 preflight patch — scrubbed mount projection

## Provenance and scope

- Prepared: 2026-09-07 (Europe/Paris).
- Target definition/run: `14246` / `4442225`.
- Reported source commit: `44070560cc855b461f5a307c9438a203e67cebe4`.
- Exact local YAML inspected: `worktrees/Y2_Plugins_FrenchTaxesRules/azure-pipelines.wi2222897-v22-preflight.yml`.
- Local YAML SHA-256: `D1B53E1F2A6E7ED5C2B0450A957AC9693D4295064190FE035A69A977523646F4`.
- The local file is not cryptographically linked to the reported commit; the patch is therefore reviewable but not applied to that worktree.

## Patch result

`patch.diff` adds only diagnostic projection after the existing image/container inspection. It records, after scrubbing, image `Config.Volumes` and container mounts with `name`, `type`, `source`, `destination`, and `rw`. It does not change acquisition, labels, assertions, cleanup, image digest, or business behavior.

Scrubbing removes user/agent/build-root identity from paths and does not serialize environment variables, image environment, command output, credentials, or the raw Docker inspection object. The existing `dangerousMounts` predicate remains unchanged and still fails closed.

## Local verification

`Test-V22MountProjection.ps1` uses inert PowerShell objects only. It verifies:

- `Config.Volumes` and mount fields are projected;
- path identity is scrubbed;
- a read-write mount remains classified as dangerous;
- a forbidden secret-shaped path is not present in output;
- no Docker daemon, image, container, pipeline, or remote service is touched.

## Dockerfile review

The indexed Dockerfile sources under `worktrees/Pipelines_Docker_BaseImages/Images` and the indexed FrenchTaxesRules snapshots contain no `VOLUME` declaration. This is only a local-source fact; it does not prove the pinned historical image has empty `Config.Volumes`, because the exact image manifest/config was not retained or linked to these sources.

## Next action

Apply the diff only on a dedicated review branch/worktree after confirming the source commit. A future authorized read-only preflight can then retain the scrubbed projection before the unchanged whitelist assertion. Do not relax the whitelist based on the projection.
