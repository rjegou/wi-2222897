[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $RepositoryRoot,
    [Parameter(Mandatory)] [string] $TemplatesCommit,
    [Parameter(Mandatory)] [string] $ExpectedImage,
    [Parameter(Mandatory)] [string] $ExpectedPluginVersion,
    [Parameter(Mandatory)] [string] $ExpectedAuthenticationServerVersion,
    [Parameter(Mandatory)] [string] $ExpectedBackupSha256,
    [string] $HistoricalSourceRoot = $RepositoryRoot,
    [string] $JmxManifestPath = (Join-Path $PSScriptRoot '..\JMX-SHA256SUMS.txt'),
    [string] $PackageManifestPath = (Join-Path $PSScriptRoot '..\PACKAGE-SHA256SUMS.txt'),
    [int] $ExpectedTotal = 376
)

$ErrorActionPreference = 'Stop'

if ($TemplatesCommit -ne 'INLINE_LOCAL_STEPS' -and $TemplatesCommit -notmatch '^[0-9a-f]{40}$') {
    throw 'No approved immutable template commit or INLINE_LOCAL_STEPS mode was supplied.'
}
if ($ExpectedPluginVersion -ne '22.0.6.478') { throw 'Plugin version drift.' }
if ($ExpectedAuthenticationServerVersion -ne '2.0.0.368') { throw 'AuthenticationServer drift.' }
if ($ExpectedImage -notmatch '@sha256:[0-9a-f]{64}$') { throw 'Image digest is not pinned.' }
if ($ExpectedTotal -ne 376) { throw 'Expected V22 campaign total must remain 376.' }
$expectedLegacyCount = 232
$expectedWebCount = 144
if (($expectedLegacyCount + $expectedWebCount) -ne $ExpectedTotal) { throw 'Legacy/Web campaign totals are inconsistent.' }
if ($ExpectedBackupSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Backup SHA-256 must be a 64-hex digest.' }
if (-not (Test-Path -LiteralPath $PackageManifestPath -PathType Leaf)) { throw "Package SHA-256 manifest is missing: $PackageManifestPath" }
$packageLines = @(Get-Content -LiteralPath $PackageManifestPath | Where-Object { $_ -and $_ -notmatch '^\s*#' })
if ($packageLines.Count -ne 6) { throw "Expected six baseline/candidate package hashes, found $($packageLines.Count)." }
foreach ($line in $packageLines) {
    if ($line -notmatch '^\s*[0-9a-fA-F]{64}\s{2,}(baseline|candidate)/.+\.zip\s*$') { throw "Invalid package SHA-256 manifest line: $line" }
}

$source = if (Test-Path (Join-Path $RepositoryRoot 'Tests')) { Join-Path $RepositoryRoot 'Tests' } else { Join-Path $RepositoryRoot 'IntegratedTests\AutoTest\Data' }
$required = @(
    (Join-Path $source 'LegacyServices.xml'),
    (Join-Path $source 'WebServices.xml')
)
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing indexed test descriptor: $path" }
}

$expectedJmx = @(
    'LegacyServices\012-FrenchTaxesRules_Run.jmx',
    'WebServices\006-Validation_SetDocumentErrorReason.jmx',
    'WebServices\020-Purge_Execute.jmx'
)

# Do not assume a V22-specific backup filename. Require an operator-provided path and content hash.
if ([string]::IsNullOrWhiteSpace($env:V22_BACKUP_PATH) -or -not (Test-Path -LiteralPath $env:V22_BACKUP_PATH -PathType Leaf)) {
    throw 'V22_BACKUP_PATH must identify an acquired backup before any deployment write.'
}
$backupHash = (Get-FileHash -LiteralPath $env:V22_BACKUP_PATH -Algorithm SHA256).Hash
if ($backupHash -ine $ExpectedBackupSha256) {
    throw "Backup SHA-256 mismatch: expected $ExpectedBackupSha256, got $backupHash."
}

# Isolation is proven by the local-container runtime check in the candidate job.
# Do not accept a declarative target JSON as a substitute for process/endpoint proof.

# Verify the exact historical source set before accepting generated output.
$historicalTests = Join-Path $HistoricalSourceRoot 'Tests'
if (-not (Test-Path -LiteralPath $historicalTests -PathType Container)) { throw 'Historical Tests root is missing.' }
$legacyManifest = Join-Path $historicalTests 'LegacyServices.xml'
$webManifest = Join-Path $historicalTests 'WebServices.xml'
$legacyItems = @(([xml](Get-Content -LiteralPath $legacyManifest -Raw)).SelectNodes('//TestPlanItem') | ForEach-Object { $_.GetAttribute('item') })
$webItems = @(([xml](Get-Content -LiteralPath $webManifest -Raw)).SelectNodes('//TestPlanItem') | ForEach-Object { $_.GetAttribute('item') })
if (@($legacyItems).Count -ne 12 -or @($webItems).Count -ne 20) { throw "Historical JMX manifest count mismatch: legacy=$(@($legacyItems).Count), web=$(@($webItems).Count)." }
foreach ($item in @($legacyItems) + @($webItems)) {
    $jmxPath = Join-Path $historicalTests $item
    if (-not (Test-Path -LiteralPath $jmxPath -PathType Leaf)) { throw "Missing historical JMX: $jmxPath" }
}

# Historical JMX may be used directly; regeneration is optional and must be explicit.
if ([string]::IsNullOrWhiteSpace($env:V22_JMX_ROOT) -or -not (Test-Path -LiteralPath $env:V22_JMX_ROOT -PathType Container)) {
    throw 'V22_JMX_ROOT must identify the JMX run-input directory.'
}
$jmx = @(Get-ChildItem -LiteralPath $env:V22_JMX_ROOT -Filter '*.jmx' -File -Recurse)
if ($jmx.Count -ne 32) { throw "Expected exactly 32 JMX run inputs, found $($jmx.Count); refusing to deploy or replay." }
foreach ($relative in $expectedJmx) {
    $path = Join-Path $env:V22_JMX_ROOT $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing discriminant JMX: $path" }
}

# Presence/count is not identity. Require the exact historical 32-file manifest,
# then hash every run input before any deployment or replay write.
if (-not (Test-Path -LiteralPath $JmxManifestPath -PathType Leaf)) { throw "JMX SHA-256 manifest is missing: $JmxManifestPath" }
$manifest = @{}
foreach ($line in Get-Content -LiteralPath $JmxManifestPath) {
    if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith('#')) { continue }
    if ($line -notmatch '^\s*([0-9a-fA-F]{64})\s{2,}(.+?)\s*$') { throw "Invalid JMX SHA-256 manifest line: $line" }
    $relative = $Matches[2].Trim() -replace '/', '\\'
    if ($manifest.ContainsKey($relative)) { throw "Duplicate JMX manifest path: $relative" }
    $manifest[$relative] = $Matches[1].ToUpperInvariant()
}
if ($manifest.Count -ne 32) { throw "Expected 32 JMX hashes in manifest, found $($manifest.Count)." }
foreach ($entry in $manifest.GetEnumerator()) {
    $path = Join-Path $env:V22_JMX_ROOT $entry.Key
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Manifest JMX is missing: $path" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne $entry.Value) { throw "JMX SHA-256 mismatch for $($entry.Key): expected $($entry.Value), got $actual." }
}

Write-Host "Preflight OK: descriptors=$($required.Count), discriminants=$($expectedJmx.Count), jmx=$($jmx.Count), hashes=$($manifest.Count), legacy=$expectedLegacyCount, web=$expectedWebCount, total=$ExpectedTotal, no writes performed."
