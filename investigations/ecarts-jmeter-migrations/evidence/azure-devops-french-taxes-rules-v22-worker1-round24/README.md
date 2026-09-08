# V22 run 4442696 — timeout-bound follow-up

## Provenance

- Source: Azure DevOps `cegid/Retail`, build `4442696`, definition `14246`.
- Commit: `68f1f7a8e575e79cf3098cafcd16e10b22237ada`.
- Branch: `refs/heads/investigation/wi-2222897-v22-preflight-20260907`.
- YAML SHA-256: `659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2`.
- Collection method: Python 3.12.4/OpenSSL HTTPS with certificate and hostname validation; PAT only in process memory.

## State at 2026-09-07 20:08 UTC

- Build status: `inProgress`; result and finish time absent.
- Queue time: `19:54:42Z`; start time: `19:54:51Z`.
- Timeline last changed: `19:55:14Z`; current inspection task remains `inProgress`, percent `0`.
- Definition YAML timeout is 10 minutes and cancel timeout is 1 minute; the run is beyond the configured execution bound.

## Timeline and logs

- `Initialize job`: succeeded.
- `Authenticate to read the existing registry image`: succeeded; Docker task version `2.276.0`.
- `Checkout`: skipped.
- `Read-only host/image/container inspection`: in progress at 0%; no task log is attached yet.
- `Hash local expurgated inspection output`: pending.
- Logs 4, 5 and 6 were read and expurgated locally; they contain no mount, Config.Volumes, container identity or cleanup result.

## Verdict

- FACT: the run is still active beyond its configured timeout and timeline updates stopped at 19:55:14Z.
- FACT: no business stage, artifact publication, or second run was created.
- UNKNOWN: image/container inspection, Config.Volumes, mounts, sub-verdicts and `containerPresentAfterRemove`.
- STOP: no cancellation or resource cleanup action was taken automatically; preserve this run for supervised Azure DevOps handling.
