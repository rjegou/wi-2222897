# Worker 2 round 3 — V22 null-safe candidate

Date: 2026-09-07 (Europe/Paris). Local-only review; no Azure DevOps, Docker, business job, queue, push or remote mutation.

## Sources and outputs

- Exact source: `../azure-devops-french-taxes-rules-v22-exact-yaml-44070560/azure-pipelines.wi2222897-v22-preflight.yml`.
- Source commit: `44070560cc855b461f5a307c9438a203e67cebe4`.
- Source SHA-256: `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`.
- Candidate: `../../replay-prep/2026-09-07-v22-round21-review/azure-pipelines.wi2222897-v22-preflight.null-safe.yml`.
- Candidate SHA-256: `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.
- Reproducible test: `../../replay-prep/2026-09-07-v22-round21-review/Test-V22NullSafeCandidate.ps1`.
- Full source diff: `patch-against-exact-yaml-null-safe.diff`.

## Verdict

**FACT** — the first round21 candidate was rejected because a null `inspection.Mounts` value produced one pseudo-mount. The null-safe candidate filters null entries before projection.

**FACT** — the test passes with inline PowerShell syntax errors `0`, null mounts `0`, two mounts preserved, read-write classification preserved, scrubbed path output, unchanged whitelist predicate, unchanged timeout/cleanup, and no business/publication command.

**UNKNOWN** — live runtime values, Azure variable propagation, and actual branch/definition state were not tested. Schannel/TLS is recorded only as an observed Worker 1 access failure, not as a permanent impossibility.
