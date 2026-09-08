[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ReplayRoot,
    [Parameter(Mandatory)] [string] $HistoricalSourceRoot,
    [Parameter(Mandatory)] [string] $BackupPath
)

$ErrorActionPreference = 'Stop'
$preflight = Join-Path $ReplayRoot 'scripts\Preflight-V22FrenchTaxesRules.ps1'
$steps = Join-Path $ReplayRoot 'scripts\steps-replay-variant.yml'
$pipeline = Join-Path $ReplayRoot 'azure-pipelines.candidate.yml'
$manifest = Join-Path $ReplayRoot 'JMX-SHA256SUMS.txt'
$image = 'acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb'

foreach ($path in @($preflight, $steps, $pipeline, $manifest, $BackupPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Dry-run input is missing: $path" }
}

$env:V22_BACKUP_PATH = $BackupPath
$env:V22_JMX_ROOT = Join-Path $HistoricalSourceRoot 'Tests'
& $preflight -RepositoryRoot $HistoricalSourceRoot -HistoricalSourceRoot $HistoricalSourceRoot -TemplatesCommit INLINE_LOCAL_STEPS -ExpectedImage $image -ExpectedPluginVersion '22.0.6.478' -ExpectedAuthenticationServerVersion '2.0.0.368' -ExpectedBackupSha256 '3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2' -JmxManifestPath $manifest
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "Preflight dry-run failed with exit code $LASTEXITCODE." }

$yaml = Get-Content -LiteralPath $pipeline -Raw
$variantSteps = Get-Content -LiteralPath $steps -Raw
$deployHelper = Get-Content -LiteralPath (Join-Path $ReplayRoot 'scripts\Invoke-V22PlatformDeploy.ps1') -Raw
if ($yaml -notmatch "image:\s*'.+@sha256:[0-9a-f]{64}'") { throw 'Pipeline image is not digest-pinned.' }
if ($yaml -notmatch 'trigger:\s*none' -or $yaml -notmatch 'pr:\s*none' -or $yaml -notmatch 'schedules:\s*\[\]') { throw 'Pipeline triggers are not fully disabled.' }
if ($variantSteps -match 'PublishPipelineArtifact|JFrogDocker|Promote|Tag_Sources') { throw 'Dry-run detected an external publication or promotion step.' }
if ($variantSteps -match 'Get-Content[^\r\n]*parameters\.properties|Write-(Host|Output)[^\r\n]*(PASSWORD|TOKEN|ApiKey)') { throw 'Dry-run detected secret-bearing output.' }
if ($variantSteps -notmatch 'Invoke-V22PlatformDeploy\.ps1' -or $deployHelper -notmatch 'LocalDBInContainer Backup') { throw 'Production deployment orchestration is missing from the candidate steps.' }
if ($variantSteps -notmatch 'Assert-V22IsolationAttestation\.ps1' -or $variantSteps -notmatch 'Write-V22HostIsolationAttestation\.ps1' -or $variantSteps -notmatch 'V22_ISOLATION_ATTESTATION_PATH' -or $variantSteps -notmatch 'V22_ISOLATION_POLICY_PATH' -or $variantSteps -notmatch 'target:\s*host' -or $variantSteps -notmatch 'AGENT_CONTAINERMAPPING' -or $variantSteps -notmatch 'V22IsolationContainerId') { throw 'Host isolation producer is not explicitly configured before deployment writes.' }
if ($variantSteps -notmatch 'RETAIL_JFROG_API_KEY' -or $deployHelper -notmatch 'Retail-JfrogCli\.json' -or $deployHelper -notmatch 'Aes') { throw 'Supported temporary JFrog CLI authentication setup is missing.' }
if ($variantSteps -notmatch 'jmeter.*-n -t' -or $variantSteps -notmatch 'jmeter-cli\.ps1.*invoke-campaign') { throw 'Production JMeter orchestration is incomplete.' }
if ($variantSteps -notmatch 'Assert-V22CampaignCounts\.ps1' -or $variantSteps -notmatch 'Collect-V22ScrubbedResults\.ps1') { throw 'Production result validation/collection is incomplete.' }
if ($variantSteps -notmatch 'Assert-V22ConsumedPackages\.ps1' -or $variantSteps -notmatch 'Assert-V22AuthorizationComparison\.ps1' -or $variantSteps -notmatch 'Assert-V22BaselineAttestation\.ps1') { throw 'Package-consumption or authorization attestation validation is incomplete.' }
if ($yaml -notmatch "stageDependencies\.FixHistorical\.FixHistorical\.outputs\['captureBaseline\.V22BaselineAuthSummary'\]" -or $variantSteps -notmatch 'V22_BASELINE_AUTH_SUMMARY_B64:\s*\$\(V22_BASELINE_AUTH_SUMMARY_B64\)') { throw 'Cross-job baseline attestation transport is not explicitly wired through a job variable and environment mapping.' }
if ($variantSteps -match 'PublishPipelineArtifact|PublishBuildArtifacts') { throw 'Baseline transport must not assume an unpublished artifact.' }
if ($yaml -notmatch 'stage:\s*Preflight' -or $yaml -notmatch 'stage:\s*FixHistorical' -or $yaml -notmatch 'stage:\s*FixCandidate') { throw 'Required stage order is incomplete.' }
if ($variantSteps -notmatch '012-FrenchTaxesRules_Run\.jmx' -or $variantSteps -notmatch '006-Validation_SetDocumentErrorReason\.jmx' -or $variantSteps -notmatch '020-Purge_Execute\.jmx') { throw 'Three discriminating operations are incomplete.' }
if ($variantSteps -notmatch 'invoke-campaign[^\r\n]*LegacyServices' -or $variantSteps -notmatch 'invoke-campaign[^\r\n]*WebServices') { throw 'Complete Legacy/Web campaign steps are incomplete.' }

Write-Host 'DRY-RUN PASS: immutable preflight -> historical baseline -> 3 discriminating operations -> 376-test campaign.'
Write-Host 'DRY-RUN EFFECTS: no SQL/IIS deployment, no JMeter process, no network publication, no branch/queue mutation.'
