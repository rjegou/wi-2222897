# Handoff Worker 2 — concrete Cur/Fix target preparation

Date: 2026-09-08. This is a read-only preparation; no Docker command was run.

## Provenance from real Clienteling sources

- Live Clienteling YAML declares V26, Cur and Fix, WebServices, image tag
  `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, and container label
  `acr_y2jmeter_test` (evidence `local-2026-09-08-clienteling-replay-prep-round1`).
- Historical deployment mechanism uses PlatformDeploy with
  `-LocalDBInContainer Backup`; the documented backup name is
  `Tests/Backups/AUTO_V26_00.bak`, database `AUTO_V26_00`, tenant
  `TESTS_AUTO_JMETER`.
- The digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`
  is recorded for a historical V26 Fix image in HANDOFF.md, not yet proved as
  the Clienteling image consumed by the target run. The backup content hash is
  explicitly UNKNOWN; do not reuse the historical digest or invent a backup hash.

## Executable preparation

`Invoke-Wi2222897EphemeralTarget.ps1` is fail-closed and intended to run only
inside an authorized isolated job with `-Provision`. It requires a digest-pinned
image, an acquired backup plus expected SHA-256, a successful restore receipt,
and an output directory. It creates only a network/container bearing
`WI-2222897` ownership labels, exposes no host ports, mounts the backup read-only,
and writes `target-docker-inspect.json` plus an attestation derived from the
actual Docker inspection. Without a restore receipt it refuses to attest.

The script deliberately publishes no host ports and creates an internal network.
The authorized job must therefore run JMeter in the same network/target context
or prove an explicitly allowed private route before the assertions; adding a
shared port or host mount is not an acceptable fallback.

`Remove-Wi2222897EphemeralTarget.ps1` validates ownership labels and run ID before
removing only that container and its empty dedicated network, then verifies both
are absent. Worker 2 remains the Docker/SQL/IIS operator and should integrate or
adapt these scripts in its own isolated job; no files in `bw2-environments` were
modified here.

## Required fresh values before 14264

The worker must produce, from the actual job: image ref plus digest, backup path
and SHA-256, restore receipt, application/SQL start evidence, target endpoints,
network/mount/port inspection, and cleanup readback for both Cur and Fix. Round7
already removes the former JMeter artifact transport dependency by downloading
and hashing JMeter 5.6.3 in each job; that does not create a target attestation.
The Full-Text diagnostic remains separate from these business target assertions.
