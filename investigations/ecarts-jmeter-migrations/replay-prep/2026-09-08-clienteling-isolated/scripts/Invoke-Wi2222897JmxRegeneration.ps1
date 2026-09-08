param(
    [Parameter(Mandatory=$true)][string]$InputRoot,
    [Parameter(Mandatory=$true)][string]$ExpectedPackageSha256,
    [Parameter(Mandatory=$true)][string]$ExpectedApiDllSha256,
    [Parameter(Mandatory=$true)][string]$OutputRoot,
    [Parameter(Mandatory=$true)][string]$CampaignFilesText
)
$ErrorActionPreference = 'Stop'
if ($ExpectedPackageSha256 -notmatch '^[0-9A-Fa-f]{64}$' -or $ExpectedApiDllSha256 -notmatch '^[0-9A-Fa-f]{64}$') { throw 'Expected package/API hashes must be SHA-256.' }
$files = @($CampaignFilesText -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($files.Count -eq 0) { throw 'At least one JMX output is required.' }
$consoleNupkg = Get-ChildItem -LiteralPath (Join-Path $InputRoot 'console') -Filter '*.nupkg' -Recurse -File | Select-Object -First 1
if (-not $consoleNupkg) { throw 'Console nupkg missing from exact Console artifact.' }
$packageHash = (Get-FileHash -LiteralPath $consoleNupkg.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
if ($packageHash -ne $ExpectedPackageSha256.ToUpperInvariant()) { throw "Console package hash mismatch: $packageHash" }
$extract = Join-Path $OutputRoot 'console-extracted'
New-Item -ItemType Directory -Path $extract -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory($consoleNupkg.FullName,$extract)
$api = Get-ChildItem -LiteralPath $extract -Filter 'Cegid.Retail.AutoTest.Api.dll' -Recurse -File | Select-Object -First 1
$exe = Get-ChildItem -LiteralPath $extract -Filter 'Cegid.Retail.AutoTest.Console.exe' -Recurse -File | Select-Object -First 1
if (-not $api -or -not $exe) { throw 'Console artifact lacks expected API DLL or Console executable.' }
$apiHash = (Get-FileHash -LiteralPath $api.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
if ($apiHash -ne $ExpectedApiDllSha256.ToUpperInvariant()) { throw "Embedded API hash mismatch: $apiHash" }
$migrationManifest = Get-ChildItem -LiteralPath (Join-Path $InputRoot 'migration') -Filter 'manifest.json' -Recurse -File | Select-Object -First 1
if (-not $migrationManifest) { throw 'Migration manifest missing; source XML to JMX mapping is required.' }
$migration = Get-Content -LiteralPath $migrationManifest.FullName -Raw | ConvertFrom-Json
if ($migration.scope -ne 'WI-2222897' -or $migration.kind -ne 'migration') { throw 'Migration manifest scope/kind mismatch.' }
$jmxOut = Join-Path $OutputRoot 'generated'
New-Item -ItemType Directory -Path $jmxOut -Force | Out-Null
$entries = @()
foreach ($relative in $files) {
    $mapping = @($migration.files | Where-Object { $_.jmxPath -eq $relative }) | Select-Object -First 1
    if (-not $mapping -or [string]::IsNullOrWhiteSpace($mapping.sourceXml)) { throw "No source XML mapping for ${relative}" }
    $xml = Join-Path $migrationManifest.DirectoryName $mapping.sourceXml
    if (-not (Test-Path -LiteralPath $xml -PathType Leaf)) { throw "Source XML missing: $xml" }
    $leaf = Split-Path -Leaf $relative
    & $exe.FullName --tstj=$xml --dstFolder=$jmxOut
    if ($LASTEXITCODE -ne 0) { throw "Console generation failed for ${relative}: exit $LASTEXITCODE" }
    $generated = Get-ChildItem -LiteralPath $jmxOut -Filter $leaf -Recurse -File | Select-Object -First 1
    if (-not $generated) { throw "Console did not produce expected JMX: $leaf" }
    $outRelative = $generated.FullName.Substring($jmxOut.Length).TrimStart('\','/')
    $hash = (Get-FileHash -LiteralPath $generated.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    $entries += [ordered]@{ path=$outRelative; requestedPath=$relative; sourceXml=$mapping.sourceXml; sha256=$hash }
}
[ordered]@{ scope='WI-2222897'; kind='jmx'; consolePackageSha256=$packageHash; apiDllSha256=$apiHash; sourceMigrationBuildId=$migration.buildId; files=$entries } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $OutputRoot 'manifest.json') -Encoding UTF8
Remove-Item -LiteralPath $extract -Recurse -Force
Write-Host "PASS: package=$packageHash; api=$apiHash; jmx=$($entries.Count)"
