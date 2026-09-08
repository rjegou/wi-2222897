# Worker 2 round 4 — V22 hash reconciliation

Date: 2026-09-07 (Europe/Paris). Local-only reconciliation; no remote mutation, queue, Docker or business execution.

## Proven cause

The `0D2D781C...` result is reproducible by applying only the one-line null filter from `patch-null-safe.diff` to the exact source `DB8ED1...`. It contains no `Config.Volumes` or scrubbed mount projection. The approved `659DE89E...` candidate contains that projection plus the null filter and is 15 normalized lines longer. The discrepancy is functional, not an encoding or line-ending discrepancy: both reconstructed hashes are identical in LF and source-preserved form.

## Verified outputs

- Exact source: `../azure-devops-french-taxes-rules-v22-exact-yaml-44070560/azure-pipelines.wi2222897-v22-preflight.yml`, SHA-256 `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`.
- Worker 1 round23 one-line application reconstruction: `0D2D781CF054CD4644C46552AB610544282D4CDD805EDCE9D197F66C151A0D5B`.
- Candidate actually tested: `../../replay-prep/2026-09-07-v22-round21-review/azure-pipelines.wi2222897-v22-preflight.null-safe.yml`, SHA-256 `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.
- Reconciliation test: `Test-V22ReconcileRound4.ps1`.

The candidate test remains PASS for PowerShell syntax, null/multiple mounts, scrubbing, unchanged whitelist, timeout and cleanup. The source YAML contains no business or publication step. Python/OpenSSL HTTPS revalidation in Worker 1 round23 proves Schannel is not a global access blocker; no active run was found.
