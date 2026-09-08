param(
    [Parameter(Mandatory=$true)][string]$InputRoot,
    [Parameter(Mandatory=$true)][string]$ExpectedApiCommit,
    [Parameter(Mandatory=$true)][string]$ExpectedApiPackageSha256,
    [Parameter(Mandatory=$true)][string]$ExpectedApiDllSha256,
    [Parameter(Mandatory=$true)][string]$ExpectedConsolePackageSha256,
    [Parameter(Mandatory=$true)][string]$ExpectedConsoleApiDllSha256,
    [Parameter(Mandatory=$true)][string]$ExpectedScope,
    [Parameter(Mandatory=$true)][string]$TargetAttestation,
    [Parameter(Mandatory=$true)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ExpectedApiCommit) -or $ExpectedApiCommit.Length -ne 40) { throw 'API commit must be an exact 40-character SHA.' }
if (-not (Test-Path -LiteralPath $InputRoot -PathType Container)) { throw "Missing input root: $InputRoot" }
foreach ($hash in @($ExpectedApiPackageSha256,$ExpectedApiDllSha256,$ExpectedConsolePackageSha256,$ExpectedConsoleApiDllSha256)) {
    if ($hash -notmatch '^[0-9A-Fa-f]{64}$') { throw 'Expected package/DLL hashes must be SHA-256.' }
}
function Get-OnlyNupkg([string]$directory, [string]$label) {
    $files = @(Get-ChildItem -LiteralPath $directory -Filter '*.nupkg' -Recurse -File)
    if ($files.Count -ne 1) { throw "Expected exactly one $label nupkg; found $($files.Count)." }
    return $files[0]
}
function Get-EmbeddedDllHash([string]$packagePath) {
    $extract = Join-Path ([IO.Path]::GetTempPath()) ('wi2222897-preflight-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extract | Out-Null
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($packagePath, $extract)
        $dll = Get-ChildItem -LiteralPath $extract -Filter 'Cegid.Retail.AutoTest.Api.dll' -Recurse -File | Select-Object -First 1
        if (-not $dll) { throw "Missing Cegid.Retail.AutoTest.Api.dll in $packagePath" }
        return (Get-FileHash -LiteralPath $dll.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    } finally { if (Test-Path -LiteralPath $extract) { Remove-Item -LiteralPath $extract -Recurse -Force } }
}
$apiPackage = Get-OnlyNupkg (Join-Path $InputRoot 'api') 'API'
$consolePackage = Get-OnlyNupkg (Join-Path $InputRoot 'console') 'Console'
$apiPackageHash = (Get-FileHash -LiteralPath $apiPackage.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
$consolePackageHash = (Get-FileHash -LiteralPath $consolePackage.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
if ($apiPackageHash -ne $ExpectedApiPackageSha256.ToUpperInvariant()) { throw "API package hash mismatch: $apiPackageHash" }
if ($consolePackageHash -ne $ExpectedConsolePackageSha256.ToUpperInvariant()) { throw "Console package hash mismatch: $consolePackageHash" }
$apiDllHash = Get-EmbeddedDllHash $apiPackage.FullName
$consoleApiDllHash = Get-EmbeddedDllHash $consolePackage.FullName
if ($apiDllHash -ne $ExpectedApiDllSha256.ToUpperInvariant()) { throw "API DLL hash mismatch: $apiDllHash" }
if ($consoleApiDllHash -ne $ExpectedConsoleApiDllSha256.ToUpperInvariant()) { throw "Console embedded API hash mismatch: $consoleApiDllHash" }
$migrationManifests = @(Get-ChildItem -LiteralPath (Join-Path $InputRoot 'migration') -Filter manifest.json -Recurse -File)
if ($migrationManifests.Count -ne 1) { throw "Expected exactly one migration manifest; found $($migrationManifests.Count)." }
$migrationFile = $migrationManifests[0]
$migration = Get-Content -LiteralPath $migrationFile.FullName -Raw | ConvertFrom-Json
if ($migration.scope -ne $ExpectedScope -or $migration.kind -ne 'migration' -or -not $migration.buildId -or -not $migration.files) { throw "Incomplete migration manifest: $($migrationFile.FullName)" }
foreach ($entry in @($migration.files)) {
    $path = Join-Path $migrationFile.DirectoryName $entry.path
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Migration manifest file missing: $path" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne ([string]$entry.sha256).ToUpperInvariant()) { throw "Migration hash mismatch: $path" }
}
if ([string]::IsNullOrWhiteSpace($TargetAttestation) -or -not (Test-Path -LiteralPath $TargetAttestation -PathType Leaf)) { throw 'Dedicated target attestation is required.' }
$target = Get-Content -LiteralPath $TargetAttestation -Raw | ConvertFrom-Json
if ($target.scope -ne $ExpectedScope -or $target.cleanupScope -notmatch '^wi2222897-[A-Za-z0-9._-]+$') { throw 'Target scope or cleanup scope is not isolated.' }
foreach ($host in @($target.appHost,$target.dbHost)) { if ([string]::IsNullOrWhiteSpace($host) -or $host -notmatch '^wi2222897-[A-Za-z0-9._-]+$') { throw 'Target host is not a dedicated WI-2222897 host.' } }
[ordered]@{ scope=$ExpectedScope; apiCommit=$ExpectedApiCommit; apiPackageSha256=$apiPackageHash; apiDllSha256=$apiDllHash; consolePackageSha256=$consolePackageHash; consoleApiDllSha256=$consoleApiDllHash; migration=[ordered]@{ buildId=[string]$migration.buildId; manifest=$migrationFile.Name; files=@($migration.files | ForEach-Object { [ordered]@{ path=$_.path; sha256=$_.sha256 } }) }; target=[ordered]@{ appHost=$target.appHost; dbHost=$target.dbHost; variant=$target.variant; cleanupScope=$target.cleanupScope } } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "PASS: api=$apiPackageHash; console=$consolePackageHash; migration=$($migration.buildId); target=$($target.cleanupScope)"
