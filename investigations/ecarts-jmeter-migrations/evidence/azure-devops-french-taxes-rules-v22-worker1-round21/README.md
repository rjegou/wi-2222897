# V22 diagnostic patch against exact YAML

## Provenance

- Date: 2026-09-07 (Europe/Paris).
- Source collection: `../azure-devops-french-taxes-rules-v22-exact-yaml-44070560/azure-pipelines.wi2222897-v22-preflight.yml`.
- Declared source commit: `44070560cc855b461f5a307c9438a203e67cebe4`.
- Declared source SHA-256: `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`.
- This folder is a new reviewable derivation; the prior round20 evidence remains unchanged.

## Scope

The corrected diff only projects scrubbed `Config.Volumes` and container mount fields (`name`, `type`, `source`, `destination`, `rw`). Existing image acquisition, labels, whitelist predicates, business policy, and bounded cleanup are unchanged. No artifact publication is added.

## Verification

`round20/patch.diff` was tested and rejected against the exact YAML because its first hunk had an indentation mismatch. `patch-against-exact-yaml.diff` was prepared with the exact source indentation and must be checked with `git apply --check` before any publication. The existing inert projection test passed independently: `PASS`.

## Evaluation

- FACT: the diagnostic preserves the existing dangerous-mount classification logic.
- FACT: path values are scrubbed before serialization in the diagnostic projection.
- INFERENCE: the corrected diff is source-compatible once `git apply --check` passes.
- UNKNOWN: live branch head and definition `14246` could not be revalidated because authenticated REST failed at TLS setup.
