# V22 mount provenance diagnosis — run 4442225

## Provenance

- Collected: 2026-09-07 (Europe/Paris).
- System: local workspace snapshot, with prior Azure DevOps run evidence.
- Run: `4442225`; definition `14246`.
- Reported source branch: `refs/heads/investigation/wi-2222897-v22-preflight-20260907`.
- Reported source commit: `44070560cc855b461f5a307c9438a203e67cebe4`.
- Primary prior evidence: `../azure-devops-french-taxes-rules-v22-worker1-round16/README.md`.
- Local YAML examined: `worktrees/Y2_Plugins_FrenchTaxesRules/azure-pipelines.wi2222897-v22-preflight.yml`.
- Local YAML SHA-256: `D1B53E1F2A6E7ED5C2B0450A957AC9693D4295064190FE035A69A977523646F4`.
- Freshness: local YAML is not cryptographically proven to be the reported commit; it is used only to identify the creation command and declared inputs.

## FACT — exact creation path visible in the YAML snapshot

The pipeline performs no `--mount`, `-v`, `volumes`, or external `docker run` for this container. It creates the container with this command shape (YAML line 49):

```text
docker create --name <build-specific-name> --label wi.scope=WI-2222897/FrenchTaxesRules/V22 --label wi.ephemeral=true --label wi.runId=<Build.BuildId> <image> powershell -NoLogo -NoProfile -Command <OS inspection command>
```

The same step then runs `docker container inspect`, serializes `Mounts` as `type/source/destination/rw`, and derives:

```text
dangerousMounts = destination not matching agent|work|programdata|windows OR rw == true
```

Cleanup is `docker rm -f <build-specific-name>` in `finally`.

## FACT — what the run proves

Round16 records one observed mount and one dangerous mount (`count=1;dangerous=1`), while digest, OS, architecture, target scope, network and host port bindings passed. The retained evidence does not include `type`, `source`, `destination`, or `rw` for that mount.

## INFERENCE — provenance candidates, not causes

Because the visible `docker create` has no explicit mount option, the mount was not requested by this command line. Plausible origins are:

1. a `VOLUME` declared in the pinned image configuration (`Config.Volumes`), or
2. Docker/agent runtime behavior outside this YAML, including host-agent/container-job plumbing if the run used such plumbing.

The local repository snapshot contains no `VOLUME` declaration proving the pinned historical image configuration. Therefore neither candidate is established as the cause.

## UNKNOWN / stop condition

The exact mount source, destination, type and read/write mode remain UNKNOWN. The image `Config.Volumes` and raw `docker inspect` payload from run `4442225` were not retained. No whitelist relaxation, queue, remote mutation, container launch, or business replay was performed.

## Minimal next action

For one explicitly authorized read-only preflight, retain only a scrubbed mount projection from the exact container inspect result before applying the whitelist:

```powershell
$inspection = docker container inspect $containerId | ConvertFrom-Json
@($inspection.Mounts | ForEach-Object { [ordered]@{ type=$_.Type; source=$_.Source; destination=$_.Destination; rw=$_.RW } }) |
  ConvertTo-Json -Depth 5
```

Also retain the image projection `Config.Volumes` from the exact pinned image inspect. This is diagnostic only; do not alter the whitelist until the source is classified.
