[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $SummaryBase64,
    [Parameter(Mandatory)] [string] $ExpectedImage,
    [Parameter(Mandatory)] [string] $ExpectedPluginVersion,
    [Parameter(Mandatory)] [string] $ExpectedAuthenticationServerVersion,
    [Parameter(Mandatory)] [string] $ExpectedBackupSha256,
    [Parameter(Mandatory)] [string] $ExpectedBaselineCoreVersion,
    [Parameter(Mandatory)] [string] $ExpectedBaselineCommonVersion,
    [Parameter(Mandatory)] [string] $ExpectedBaselineIdentityVersion
)

$ErrorActionPreference = 'Stop'
if ($ExpectedImage -notmatch '@sha256:[0-9a-fA-F]{64}$' -or $ExpectedBackupSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Baseline attestation shared provenance is invalid.' }
try { $json = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($SummaryBase64)); $summary = $json | ConvertFrom-Json } catch { throw 'Baseline attestation is not valid base64 JSON.' }
if ([int]$summary.legacy.total -ne 138 -or [int]$summary.web.total -ne 36) { throw 'Baseline attestation does not contain 138 Legacy + 36 Web signatures.' }
$p = $summary.provenance
if (-not $p -or $p.image -ne $ExpectedImage -or $p.pluginVersion -ne $ExpectedPluginVersion -or $p.authenticationServerVersion -ne $ExpectedAuthenticationServerVersion -or $p.backupSha256 -ne $ExpectedBackupSha256.ToUpperInvariant() -or $p.coreVersion -ne $ExpectedBaselineCoreVersion -or $p.commonVersion -ne $ExpectedBaselineCommonVersion -or $p.identityVersion -ne $ExpectedBaselineIdentityVersion) { throw 'Baseline attestation provenance mismatch; refusing candidate before deployment writes.' }
Write-Host 'Baseline attestation accepted: provenance and 174 targeted signatures verified before candidate deployment.'
