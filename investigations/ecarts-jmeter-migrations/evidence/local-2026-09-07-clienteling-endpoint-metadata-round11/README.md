# Clienteling endpoint JMX generation — 2026-09-07

## Provenance and staging

FACT — The five corrected plans were read from the clean-before-edit worktree `worktrees/Y2_Plugins_Clienteling` and run with the copied Console 2.0.42 runtime plus the available corrected API DLL. No API worktree, package, common document, remote Git, HTTP, or MSI state was changed.

FACT — All five plans' referenced input XMLs and their required expected-output XMLs were found in the same Clienteling worktree and parsed as XML before copying. The exact source hashes and roles are in `manifest.tsv`. The campaign's sixth control plan required the already-indexed synthetic `input.xml`; it was used only to complete the pre-existing six-plan campaign and is not part of the five endpoint result set.

## Result

FACT — Console exited `0` with both the available original API DLL and the corrected API DLL, generating the same six JMX files and hashes. The five corrected endpoint plans are represented by `001-plan01.jmx` through `005-plan05.jmx`. Static inspection of those JMX files found:

- `001-plan01.jmx`: `ClientelingDeploymentService.svc`
- `002-plan02.jmx`: `ClientelingDeploymentService.svc`
- `003-plan03.jmx`: `ClientelingDeploymentService.svc`
- `004-plan04.jmx`: `ClientelingMobilityService.svc`
- `005-plan05.jmx`: `ClientelingMobilityService.svc`

No old generic `DeploymentService.svc` or `MobilityService.svc` was found in those five generated JMX endpoint fields. This proves source→Console→JMX generation for the V26 worktree pair, with original/corrected API parity for this generation, not deployed HTTP behavior or MSI installation.

## Limits

UNKNOWN — This run validates the current V26 worktree only. V22–V25 are not generalized; their exact manifests were not used. The Console process was a generator-only invocation in a temporary staging directory and did not execute business HTTP or MSI operations.

Additional read-only check: the indexed exact snapshots for V22/V23 (`Y2_Plugins_Clienteling-v6-build-4432602`), V24 (`Y2_Plugins_Clienteling-v7-build-4432652`), V25 (`Y2_Plugins_Clienteling-v8-build-4432672`) and V26 (`Y2_Plugins_Clienteling-master-build-4432554-exact`) each expose the expected Deployment and Mobility service names in their MSI manifests. Their corresponding five `IntegratedTests/AutoTest/Data/WebServices/TestPlans` files are absent from those snapshots, so no historical plan-to-manifest correction is claimed.
