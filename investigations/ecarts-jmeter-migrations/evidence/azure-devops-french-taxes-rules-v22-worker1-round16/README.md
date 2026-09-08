# V22 preflight diagnostic — run 4442225

## Provenance

- Collected: 2026-09-07 (Europe/Paris), after final run state was available.
- System: Azure DevOps organization `https://dev.azure.com/cegid`, project `Retail`.
- Definition: `14246`.
- Run: `4442225`.
- Source branch: `refs/heads/investigation/wi-2222897-v22-preflight-20260907`.
- Source commit: `44070560cc855b461f5a307c9438a203e67cebe4`.
- Collection method: Azure DevOps CLI and Build timeline/log REST endpoint; only whitelist log lines were retained here.
- Freshness: final run status read after `finishTime=2026-09-07T17:24:33.947815+00:00`.

## FACT — final result and persisted diagnostics

Run `4442225` ended `completed` / `failed`. The inspection task ended `failed`; the finalization and hash-output tasks succeeded.

Whitelisted log evidence from inspection log 7:

```text
Digest: sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb
V22_PREFLIGHT_ASSERTION id=image-digest passed=True value=repoDigestsCount=1
V22_PREFLIGHT_ASSERTION id=image-os passed=True value=present=True
V22_PREFLIGHT_ASSERTION id=image-architecture passed=True value=present=True
V22_PREFLIGHT_ASSERTION id=target-scope passed=True value=valid=True
V22_PREFLIGHT_ASSERTION id=mounts passed=False value=count=1;dangerous=1
V22_PREFLIGHT_ASSERTION id=networks passed=True value=count=1;forbidden=0
V22_PREFLIGHT_ASSERTION id=ports passed=True value=hostPortBindings=0
V22_PREFLIGHT_ATTESTATION passed=False digest=***/cegid-retail-docker-production/y2-jmeter@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb imageOs=windows imageArchitecture=amd64 imageLayers=31 containerState=created mounts=1 dangerousMounts=1 networks=nat forbiddenNetworks=0 hostPortBindings=0 targetScopeValid=True failedAssertions=mounts
V22_PREFLIGHT_CLEANUP containerPresentAfterRemove=False
```

The log also identifies the refusal as `Runtime isolation whitelist assertion failed: mounts.` and PowerShell exit code `1`.

## Qualification

- FACT: image digest acquisition and digest assertion passed for the expected digest.
- FACT: OS and architecture fields were present; the attestation reported `windows` and `amd64`.
- FACT: target scope assertion passed.
- FACT: networks passed with `nat` and zero forbidden networks.
- FACT: ports passed with zero host bindings.
- FACT: mounts failed with one observed mount and one dangerous mount according to the whitelist predicate.
- FACT: cleanup ran and reported no container remaining after removal.
- UNKNOWN: the retained whitelist values do not identify the mount source/destination; no raw inspection was retained. The exact dangerous mount target therefore cannot be inferred from this evidence alone.
- UNKNOWN: this preflight does not prove the two future business jobs, their execution identity, or their runtime isolation.

No SQL, deployment, business replay, permission, service connection, network, or mount mutation was performed, and no new run was queued.
