# V22 mount count comparison — 44070560 vs 68f1f7a8

## Provenance

- Date: 2026-09-07 (Europe/Paris).
- Source YAML 44070560: exact collection, SHA-256 `DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A`.
- Source YAML 68f1f7a8: published diagnostic, SHA-256 `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.
- Historical run evidence: 4442225 / prior collection round19.
- Final run evidence: 4442696 / collection round25.
- Local reproduction: PowerShell 5.1 and PowerShell 7, inert objects only; no Docker, agent or remote access.

## Exact logic difference

- 44070560: `$mounts | ForEach-Object` projects a null input into one object with null fields.
- 68f1f7a8: `$mounts | Where-Object { $null -ne $_ } | ForEach-Object` filters null before projection.
- The `dangerousMounts` predicate is unchanged in both versions.

## Reproduction

The same fixtures were run under both PowerShell versions; detailed output is in `reproduction.txt`.

| Fixture | 44070560 projected/dangerous | 68f1f7a8 projected/dangerous |
|---|---:|---:|
| null Mounts | 1 / 1 | 0 / 0 |
| empty array | 0 / 0 | 0 / 0 |
| one real RW mount | 1 / 1 | 1 / 1 |

## Evidence boundary

- FACT: the null-input artifact is reproducible in both PowerShell 5.1 and 7.
- FACT: 4442225 retained the text `count=1;dangerous=1`, but did not retain raw Mounts or Config.Volumes; this cannot prove the historical input was null.
- FACT: 4442696 retained `mounts=count=0;dangerous=0`, network/ports assertions, and cleanup false-after-remove.
- FACT: the final YAML writes `Config.Volumes`, scrubbed mounts, and container name into `preflight-inspection.json` under `Agent.TempDirectory`, but the pipeline publishes no artifact and the console attestation omits those fields and the full container ID. Therefore they are absent from final retained logs.
- INFERENCE: the round19 `count=1;dangerous=1` could have been caused by null Mounts, but a real dangerous RW mount would produce the same counts; historical cause remains UNKNOWN.
- INFERENCE: 4442696 proves no observed runtime mounts, not that the image Config.Volumes value was empty.

## Terminal timing

4442696 queue `19:54:42.686Z`, start `19:54:51.386Z`, inspection task start `19:55:12.093Z`, inspection finish `20:04:00.366Z`, build finish `20:04:15.700Z`. Effective build duration from start to finish was about 9m24s; the earlier stale timeline view was a visibility lag, not evidence of an over-timeout execution.
