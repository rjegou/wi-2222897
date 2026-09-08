# V22 Python HTTPS and Azure DevOps revalidation

## Provenance

- Date: 2026-09-07 (Europe/Paris).
- Client: local Python 3.12.4 using OpenSSL 3.0.13.
- TLS context: `CERT_REQUIRED` (`verify_mode=2`), `check_hostname=True`, 75 loaded CA certificates.
- PAT was read from the authorized local file and used only in process memory; its value was not logged or persisted.

## Results

- Public Azure DevOps endpoint: HTTP 200 with standard Python certificate and hostname validation.
- Branch read: `refs/heads/investigation/wi-2222897-v22-preflight-20260907` points to `44070560cc855b461f5a307c9438a203e67cebe4`.
- Definition read: `14246`, `WI-2222897 V22 Runtime Preflight 20260907`, revision 2, YAML `/azure-pipelines.wi2222897-v22-preflight.yml`, default branch is the neutral investigation branch.
- Queue/pool read: queue `591`, hosted pool `Azure Pipelines`, pool id `79`, queue status enabled.
- Active runs query for definition 14246: none.

## Content control

- Exact collected YAML SHA-256: `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`.
- Applying the one-line null-safe mount filter from `replay-prep/2026-09-07-v22-round21-review/patch-null-safe.diff` to that exact YAML produces SHA-256 `0D2D781CF054CD4644C46552AB610544282D4CDD805EDCE9D197F66C151A0D5B` (UTF-8, original LF form).
- This does not equal the mandated approved target SHA-256 `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.

## Verdict

- FACT: independent HTTPS is functional and the branch/definition state was revalidated read-only.
- FACT: no active run was found.
- UNKNOWN: the concrete YAML content corresponding to the mandated `659DE89E...` hash.
- STOP: do not publish or queue until that exact approved content is located and checked against remote head.
