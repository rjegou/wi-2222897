# Round 2 local validation record

Date : 2026-09-08 (Europe/Paris).

## Commands and results

- `pwsh -NoLogo -NoProfile -File worktrees/fulltext/fulltext-attestation-gate.ps1 -AttestationPath fixture-attestation-valid.json -ExpectedJobScope 14251/round2/SQL2019` → `EXIT=0`, `FULLTEXT_ATTESTATION=PASS`, digest format exact, mounts/networks/ports/endpoints zero.
- Same gate with `fixture-attestation-shared.json` → `EXIT=1`, `FULLTEXT_ATTESTATION_BLOCKED host is not exclusive`.
- PowerShell parser on `fulltext-attestation-gate.ps1` → `PARSE=PASS`.
- PyYAML parse on `fulltext-runner-candidate.yml` → `YAML=PASS trigger=none pr=none schedules=[] stages=SQL2019,SQL2025`, exit `0`.
- Static candidate checks confirm `--network none`, `docker image inspect`, and mount/port assertions. No Docker, SQL, IIS, Azure DevOps queue, registry, JFrog or feed operation was executed.

## Hashes

| File | SHA-256 |
|---|---|
| `worktrees/fulltext/fulltext-runner-candidate.yml` | `36BC8D1A0901ED62B1A4D0387954605C75C660D5D59182EF14A644847EEB4E92` |
| `worktrees/fulltext/fulltext-attestation-gate.ps1` | `5CA9A5F1753A62F9B0880ABA1C79C3D851495D51F70B829F6E6E1D188A5A5AC7` |
| `fixture-attestation-valid.json` | `1933FFBDA4D40520EB54DE0ED242B90D9EF42E7B33019EBCFF28BC7787AABC51` |
| `fixture-attestation-shared.json` | `05E92F845A1BE55DCE3A8CB69080DFF93CA30D034D1889F0E71AA7AF6B9ECC64` |

The fixture digest is synthetic and is used only to test format validation; it is not an image identity claim.
