# Clienteling endpoint metadata correction — 2026-09-07

## Scope

FACT — The clean worktree `worktrees/Y2_Plugins_Clienteling` was inspected before editing. Its branch was `master`, based on the local remote-tracking branch, with no prior modifications. The five editable XML plans exist at `HEAD`; they are not under `sources/` or `evidence/`.

FACT — The V26 MSI manifest `Kits/V26/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml` declares `ClientelingDeploymentService.svc` and `ClientelingMobilityService.svc`. The five plans previously declared the generic `DeploymentService.svc` or `MobilityService.svc`.

## Change

Only these five `WebService` attributes were changed:

- `Deployment_ResetFTSCustomer.xml`: `DeploymentService.svc` → `ClientelingDeploymentService.svc`
- `Deployment_UpdateFTSCatalog.xml`: `DeploymentService.svc` → `ClientelingDeploymentService.svc`
- `Deployment_UpdateFTSCustomer.xml`: `DeploymentService.svc` → `ClientelingDeploymentService.svc`
- `Mobility_GetClientelingParameters.xml`: `MobilityService.svc` → `ClientelingMobilityService.svc`
- `Mobility_UpdateClientelingParameters.xml`: `MobilityService.svc` → `ClientelingMobilityService.svc`

Products was not changed. Its support and manifest coverage remain a separate decision.

## Validation

The five files parse as XML. Each resulting service name matches an installed service name in the V26 manifest. `git diff --check` passed. No HTTP request, MSI execution, package publication, or remote Git action was performed.

A local Console-only staging attempt used the copied 2.0.42 runtime and the available corrected API DLL. It loaded the corrected `plan01` and emitted a partial `001-plan01.jmx`, then stopped with exit `-1` because the plan's referenced `InputFiles\Deployment\FullTextSearchResetCustomer_01.xml` was deliberately not copied into the minimal staging. This is retained as a bounded generation check, not as a successful JMX validation. The partial output and log are included here; no input fixture was invented or taken from an unreviewed source.

## Provenance and limits

The three Deployment plans share local Git provenance through commit `23176daf130403b47e270767a54325244c7870fc` (`Merged PR 75416: Rework SEARCHCUSTFTS`, 2021-06-22); the V26 manifest is present in the current worktree history at `2b6f7f22085b554c1fcdbda0476d0ef47e9ffdf1`. This is local repository provenance, not proof that every historical version has the same manifest.

INFERENCE — The correction is justified for the current V26 source/manifest pair. UNKNOWN — V22–V25 editable source/manifest pairs are not present in this worktree, so no cross-version correction is claimed. Complete JMX regeneration remains pending the indexed input fixtures; HTTP smoke tests remain pending because no deployed endpoint was exercised.
