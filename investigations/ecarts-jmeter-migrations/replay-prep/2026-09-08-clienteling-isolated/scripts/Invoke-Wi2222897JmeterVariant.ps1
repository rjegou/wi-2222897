param(
    [Parameter(Mandatory=$true)][ValidateSet('Cur','Fix')][string]$Variant,
    [Parameter(Mandatory=$true)][string]$InputRoot,
    [Parameter(Mandatory=$true)][string]$JmxManifest,
    [Parameter(Mandatory=$true)][string]$TargetAttestation,
    [Parameter(Mandatory=$true)][string]$OutputRoot,
    [Parameter(Mandatory=$true)][string]$CampaignFilesText
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $JmxManifest -PathType Leaf)) { throw "Missing JMX manifest: $JmxManifest" }
if (-not (Test-Path -LiteralPath $TargetAttestation -PathType Leaf)) { throw "Missing target attestation: $TargetAttestation" }
$target = Get-Content -LiteralPath $TargetAttestation -Raw | ConvertFrom-Json
if ($target.scope -ne 'WI-2222897' -or $target.variant -ne $Variant) { throw 'Target attestation scope/variant mismatch.' }
if ($target.cleanupScope -notmatch '^wi2222897-[A-Za-z0-9._-]+$') { throw 'Unsafe cleanup scope.' }
$jmeter = Get-ChildItem -LiteralPath $InputRoot -Filter jmeter.bat -Recurse -File | Select-Object -First 1
if (-not $jmeter) { throw 'JMeter executable was not supplied as an input artifact.' }
$manifest = Get-Content -LiteralPath $JmxManifest -Raw | ConvertFrom-Json
if ($manifest.scope -ne 'WI-2222897' -or $manifest.kind -ne 'jmx') { throw 'JMX manifest scope/kind mismatch.' }
$CampaignFiles = @($CampaignFilesText -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($CampaignFiles.Count -eq 0) { throw 'At least one explicit JMX is required.' }
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
$results = @()
foreach ($relative in $CampaignFiles) {
    $entry = @($manifest.files | Where-Object { $_.requestedPath -eq $relative -or $_.path -eq $relative }) | Select-Object -First 1
    if (-not $entry) { throw "JMX not present in manifest: $relative" }
    $jmxRelative = [string]$entry.path
    $jmx = Join-Path (Split-Path -Parent $JmxManifest) $jmxRelative
    if (-not (Test-Path -LiteralPath $jmx -PathType Leaf)) { throw "JMX missing: $jmx" }
    $actual = (Get-FileHash -LiteralPath $jmx -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne ([string]$entry.sha256).ToUpperInvariant()) { throw "JMX hash mismatch: $relative" }
    $safe = ($relative -replace '[\\/:]','_')
    $jtl = Join-Path $OutputRoot "$safe.$Variant.jtl"
    $log = Join-Path $OutputRoot "$safe.$Variant.log"
    $props = Join-Path $OutputRoot "$safe.$Variant.properties"
    @("# WI-2222897 isolated run", "VARIANT=$Variant", "APPSERVER_HOST=$($target.appHost)", "DB_HOST=$($target.dbHost)") | Set-Content -LiteralPath $props -Encoding ASCII
    & $jmeter.FullName -n -t $jmx -q $props -l $jtl -j $log
    $exit = $LASTEXITCODE
    Remove-Item -LiteralPath $props -Force
    if ($exit -ne 0) { throw "JMeter failed for $relative with exit code $exit" }
    $results += [ordered]@{ variant=$Variant; jmx=$relative; jmxSha256=$actual; jtl=(Split-Path -Leaf $jtl); log=(Split-Path -Leaf $log) }
}
$results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputRoot 'results-manifest.json') -Encoding UTF8
Write-Host "PASS: variant=$Variant; campaigns=$($results.Count); target=$($target.cleanupScope)"
