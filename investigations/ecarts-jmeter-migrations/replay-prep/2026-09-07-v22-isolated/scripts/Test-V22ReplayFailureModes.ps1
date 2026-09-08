[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ReplayRoot
)

$ErrorActionPreference = 'Stop'
$yaml = Get-Content -LiteralPath (Join-Path $ReplayRoot 'azure-pipelines.candidate.yml') -Raw
$steps = Get-Content -LiteralPath (Join-Path $ReplayRoot 'scripts\steps-replay-variant.yml') -Raw
if ($yaml -notmatch 'stage:\s*FixCandidate[\s\S]*?dependsOn:\s*FixHistorical[\s\S]*?condition:\s*succeeded\(\)') { throw 'Candidate is not blocked by a failed historical baseline.' }
if ($steps -notmatch 'condition:\s*always\(\)[\s\S]*?Cleanup job-scoped replay directory') { throw 'Cleanup is not unconditional after candidate failure.' }
$isolationIndex = $steps.IndexOf('Assert-V22IsolationAttestation.ps1')
$deployIndex = $steps.IndexOf('Invoke-V22PlatformDeploy.ps1')
if ($isolationIndex -lt 0 -or $deployIndex -lt 0 -or $isolationIndex -ge $deployIndex) { throw 'Host isolation attestation is not ordered before deployment.' }
if ($steps -notmatch 'target:\s*host' -or $steps -notmatch 'AGENT_CONTAINERMAPPING' -or $steps -notmatch 'V22IsolationContainerId') { throw 'Host isolation producer is not mapped to the exact job container.' }
if ($steps -notmatch 'Write-V22HostIsolationAttestation\.ps1' -or $steps.IndexOf('Write-V22HostIsolationAttestation.ps1') -ge $steps.IndexOf('Assert-V22IsolationAttestation.ps1')) { throw 'Host isolation producer is not ordered before consumer validation.' }
$pipeline = Get-Content -LiteralPath (Join-Path $ReplayRoot 'azure-pipelines.candidate.yml') -Raw
if ($pipeline -notmatch "stageDependencies\.FixHistorical\.FixHistorical\.outputs\['captureBaseline\.V22BaselineAuthSummary'\]" -or $steps -notmatch 'V22_BASELINE_AUTH_SUMMARY_B64:\s*\$\(V22_BASELINE_AUTH_SUMMARY_B64\)') { throw 'Baseline attestation is not transported through the declared job variable and environment mapping.' }
$deployHelper = Get-Content -LiteralPath (Join-Path $ReplayRoot 'scripts\Invoke-V22PlatformDeploy.ps1') -Raw
if ($deployHelper -notmatch '(?s)try\s*\{.*finally\s*\{' -or $deployHelper -notmatch 'Retail-JfrogCli\.json' -or $deployHelper -notmatch '(Remove-Item|File\]::Delete).*repoFile') { throw 'JFrog temporary configuration does not have a verified finally cleanup path.' }
if ($deployHelper -match '(?m)&\s*\$sanitizedPath[^\r\n]*RetailJfrogApiKey') { throw 'Deployment helper exposes the JFrog secret as a command argument.' }

# Exercise the real result counter with inert JTL substitutes.
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('v22-replay-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path (Join-Path $fixture 'LegacyServices') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fixture 'WebServices') -Force | Out-Null
    'timeStamp,success' | Set-Content (Join-Path $fixture 'LegacyServices\results.jtl')
    1..232 | ForEach-Object { '0,true' | Add-Content (Join-Path $fixture 'LegacyServices\results.jtl') }
    'timeStamp,success' | Set-Content (Join-Path $fixture 'WebServices\results.jtl')
    1..144 | ForEach-Object { '0,true' | Add-Content (Join-Path $fixture 'WebServices\results.jtl') }
    & (Join-Path $ReplayRoot 'scripts\Assert-V22CampaignCounts.ps1') -ResultRoot $fixture
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw 'Expected count fixture unexpectedly failed.' }
    Add-Content (Join-Path $fixture 'WebServices\results.jtl') '0,true'
    try { & (Join-Path $ReplayRoot 'scripts\Assert-V22CampaignCounts.ps1') -ResultRoot $fixture; throw 'Count mismatch unexpectedly passed.' } catch { if ($_.Exception.Message -notmatch 'Campaign count mismatch') { throw } }
    $baseline = Join-Path $fixture 'BaselineAuth'
    $candidate = Join-Path $fixture 'CandidateAuth'
    foreach ($root in @($baseline,$candidate)) {
        New-Item -ItemType Directory -Path (Join-Path $root 'LegacyServices'),(Join-Path $root 'WebServices') -Force | Out-Null
    }
    'label,responseData' | Set-Content (Join-Path $baseline 'LegacyServices\results.jtl')
    1..138 | ForEach-Object { "legacy-$_,CBP50101" | Add-Content (Join-Path $baseline 'LegacyServices\results.jtl') }
    'label,responseData' | Set-Content (Join-Path $baseline 'WebServices\results.jtl')
    1..36 | ForEach-Object { "web-$_,FailedAuthentication" | Add-Content (Join-Path $baseline 'WebServices\results.jtl') }
    'label,responseData' | Set-Content (Join-Path $candidate 'LegacyServices\results.jtl')
    'unrelated,Other application failure' | Add-Content (Join-Path $candidate 'LegacyServices\results.jtl')
    'label,responseData' | Set-Content (Join-Path $candidate 'WebServices\results.jtl')
    'unrelated,Other application failure' | Add-Content (Join-Path $candidate 'WebServices\results.jtl')
    $image = 'acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb'
    $summary = & (Join-Path $ReplayRoot 'scripts\Assert-V22AuthorizationComparison.ps1') -ResultRoot $baseline -Variant FixHistorical -ExpectedImage $image -ExpectedPluginVersion '22.0.6.478' -ExpectedAuthenticationServerVersion '2.0.0.368' -ExpectedBackupSha256 '3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2' -CoreVersion '22.0.0.1011' -CommonVersion '22.0.2.300' -IdentityVersion '22.0.5.182'
    $summaryB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($summary -join "`n")))
    & (Join-Path $ReplayRoot 'scripts\Assert-V22BaselineAttestation.ps1') -SummaryBase64 $summaryB64 -ExpectedImage $image -ExpectedPluginVersion '22.0.6.478' -ExpectedAuthenticationServerVersion '2.0.0.368' -ExpectedBackupSha256 '3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2' -ExpectedBaselineCoreVersion '22.0.0.1011' -ExpectedBaselineCommonVersion '22.0.2.300' -ExpectedBaselineIdentityVersion '22.0.5.182'
    & (Join-Path $ReplayRoot 'scripts\Assert-V22AuthorizationComparison.ps1') -ResultRoot $candidate -Variant FixCandidate -BaselineSummaryJson ($summary -join "`n") -ExpectedImage $image -ExpectedPluginVersion '22.0.6.478' -ExpectedAuthenticationServerVersion '2.0.0.368' -ExpectedBackupSha256 '3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2' -CoreVersion '22.0.0.2068' -CommonVersion '22.0.3.311' -IdentityVersion '22.0.6.117' -ExpectedBaselineCoreVersion '22.0.0.1011' -ExpectedBaselineCommonVersion '22.0.2.300' -ExpectedBaselineIdentityVersion '22.0.5.182'
    Write-Host 'FAILURE-MODES PASS: baseline failure blocks candidate; candidate failure preserves cleanup; wrong count is rejected; 138+36 authorization comparison allows unrelated failures.'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
