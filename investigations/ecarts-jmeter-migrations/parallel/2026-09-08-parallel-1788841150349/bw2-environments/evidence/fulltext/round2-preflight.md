# Round 2 Full-Text preflight and runner candidate

Date : 2026-09-08 (Europe/Paris).

## FACT

- The prior read-only pool evidence reports Microsoft-hosted agents online but without Docker capability/isolation proof; the private Windows pool is shared and lacks proven Docker/container compatibility. Source: `evidence/2026-09-07-brain-reprise-worker2-round4/README.md`, lines 7-10.
- The prior candidate required a future `SQL-FULLTEXT-ISOLATED` pool and demands `Docker=true`, `FullTextValidation=true`; it was not registered or queued. Source: `evidence/2026-09-07-brain-reprise-worker2-round3/README.md`, lines 11-31.
- No current proof in the inspected evidence establishes a producer-owned attestation for the exact Full-Text job scope, OS, image digest, zero mounts, zero networks/ports/endpoints and cleanup owner.

## Graphe d'effets

`checkout` → local Docker build (`--pull=false`) → local image identity check → no-mount/no-published-port container → Full-Text probe/diagnostics → PipelineArtifact only → targeted `docker rm -f` cleanup.

No registry login, image push, JFrog/feed operation, promotion, tag, downstream trigger, database/IIS/shared VM or business test is present in the candidate. The SQL probe remains after the attestation and runtime container checks. The current 90-second population window is retained; it is not increased.

## Verrou

**UNKNOWN/BLOCKED for runtime** — the dedicated pool and exact-scope attestation are not proven. Therefore no branch/definition was created, no queue was made, and no SQL/Docker execution occurred in this round.

## Candidate and local validation

- Candidate runner: `worktrees/fulltext/fulltext-runner-candidate.yml`.
- Attestation gate: `worktrees/fulltext/fulltext-attestation-gate.ps1`.
- The SQL2019 path is complete through cleanup; SQL2025 intentionally fails closed until the reviewed diagnostic stage is bound after producer attestation readback. This prevents an unreviewed or unattested SQL run.
- The gate requires exact scope, `exclusive=true`, `sha256:` image digest, empty mounts/networks/ports/endpoints, and non-empty cleanup owner. No fixture or runtime result is claimed yet.
