# V22 run 4442696 — final runtime preflight

## Provenance

- Source: Azure DevOps `cegid/Retail`, definition `14246`, build `4442696`.
- Branch: `refs/heads/investigation/wi-2222897-v22-preflight-20260907`.
- Commit: `68f1f7a8e575e79cf3098cafcd16e10b22237ada`.
- YAML SHA-256: `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.
- Collection: Python 3.12.4/OpenSSL HTTPS, certificate and hostname validation active; PAT only in process memory.

## Final result

- Build status/result: `completed` / `succeeded`.
- Start: `2026-09-07T19:54:51.3861431Z`; finish: `2026-09-07T20:04:15.7004975Z`.
- Image pull succeeded at digest `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.
- Checkout was skipped; no business stage or artifact publication exists.

## Runtime assertions from log 7

- image-digest: passed.
- image-os: passed; `windows`.
- image-architecture: passed; `amd64`.
- target-scope: passed.
- mounts: `count=0; dangerous=0`.
- networks: `count=1; forbidden=0`; observed network `nat`.
- ports: `hostPortBindings=0`.
- attestation: `passed=True`; container state `created`.
- cleanup: `V22_PREFLIGHT_CLEANUP containerPresentAfterRemove=False`.

## Evidence limits

- FACT: no runtime mount was detected and the unchanged whitelist passed.
- FACT: container identity was represented by an ephemeral run-local name, but the full container ID was not persisted in the non-artifact logs.
- UNKNOWN: image `Config.Volumes`; the YAML projects it but the output stayed in agent temp and no artifact was published.
- INFERENCE: this run proves the bounded preflight environment had no observed mounts/host ports and no surviving named container; it does not prove future business-job isolation or package consumption.

## Independent review handoff

Worker 2 review inputs: this README, `timeline-expurgated.txt`, and the prior local candidate/test at `replay-prep/2026-09-07-v22-round21-review/`.
