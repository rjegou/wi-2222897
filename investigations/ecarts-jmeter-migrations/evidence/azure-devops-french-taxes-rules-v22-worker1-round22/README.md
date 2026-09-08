# V22 Azure DevOps TLS diagnostic

## Provenance

- Date: 2026-09-07 (Europe/Paris).
- Scope: read-only diagnostics after authenticated REST retrieval failed at TLS setup.
- Clients: Windows PowerShell/.NET, `curl.exe` 8.13.0 with Schannel, Git HTTPS with Schannel, Azure CLI.
- No PAT value, certificate content, or proxy credential was displayed or persisted.

## Results

- Local clock read: `2026-09-07T21:36:36+02:00`.
- `w32tm /query /status`: access denied (`0x80070005`); authoritative time status is therefore UNKNOWN.
- No proxy environment variables were present.
- Root stores were readable: 80 certificates in both CurrentUser and LocalMachine stores.
- `curl.exe` failed before HTTP/TLS handshake with `schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS (0x8009030E)`.
- The same failure reproduced against `https://dev.azure.com` and `https://www.microsoft.com`.
- Git HTTPS with Schannel reproduced the same error.
- Azure CLI additionally remains blocked by `PermissionError` reading `.azure\azureProfile.json`.

## Verdict

- FACT: failure occurs before Azure DevOps HTTP authentication and is not evidence of an invalid PAT.
- FACT: TLS validation was not disabled.
- UNKNOWN: authoritative clock status and the underlying Windows Schannel policy/provider cause.
- Minimal intervention: repair or permit the Windows Schannel credential provider/TLS policy for this worker, then repeat a non-mutating curl/Git test.
