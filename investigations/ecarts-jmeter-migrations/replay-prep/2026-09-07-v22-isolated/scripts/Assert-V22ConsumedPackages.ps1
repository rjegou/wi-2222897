[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $DeployRoot,
    [Parameter(Mandatory)] [ValidateSet('FixHistorical','FixCandidate')] [string] $Variant,
    [Parameter(Mandatory)] [string] $PackageManifestPath,
    [Parameter(Mandatory)] [string] $CoreVersion,
    [Parameter(Mandatory)] [string] $CommonVersion,
    [Parameter(Mandatory)] [string] $IdentityVersion
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $DeployRoot -PathType Container)) { throw "Deploy root is missing: $DeployRoot" }
if (-not (Test-Path -LiteralPath $PackageManifestPath -PathType Leaf)) { throw "Package manifest is missing: $PackageManifestPath" }
$prefix = if ($Variant -eq 'FixHistorical') { 'baseline/' } else { 'candidate/' }
$wanted = @(Get-Content -LiteralPath $PackageManifestPath | Where-Object { $_ -match "^\s*[0-9a-fA-F]{64}\s+$prefix" })
if ($wanted.Count -ne 3) { throw "Expected three $Variant package hashes, found $($wanted.Count)." }
$expected = @{}
foreach ($line in $wanted) {
    if ($line -notmatch '^\s*([0-9a-fA-F]{64})\s+.+/([^/]+\.zip)\s*$') { throw "Invalid package manifest line: $line" }
    $expected[$Matches[2]] = $Matches[1].ToUpperInvariant()
}
foreach ($name in $expected.Keys) {
    $hits = @(Get-ChildItem -LiteralPath $DeployRoot -Recurse -File -Filter $name -ErrorAction Stop)
    if ($hits.Count -ne 1) { throw "Expected one downloaded package $name under DeployRoot, found $($hits.Count)." }
    $actual = (Get-FileHash -LiteralPath $hits[0].FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne $expected[$name]) { throw "Consumed package hash mismatch for ${name}: expected $($expected[$name]), got $actual." }
}
$config = @(Get-ChildItem -LiteralPath $DeployRoot -Recurse -File -Filter 'downloadedPackages.json' -ErrorAction SilentlyContinue)
if ($config.Count -ne 1) { throw "Expected one PlatformDeploy downloadedPackages.json, found $($config.Count)." }
$json = Get-Content -LiteralPath $config[0].FullName -Raw
foreach ($version in @($CoreVersion,$CommonVersion,$IdentityVersion)) {
    if ($json -notmatch [regex]::Escape($version)) { throw "downloadedPackages.json does not contain expected version $version." }
}
Write-Host "Consumed package inputs verified: variant=$Variant packages=$($expected.Count) versions=$CoreVersion,$CommonVersion,$IdentityVersion manifest=$([IO.Path]::GetFileName($PackageManifestPath))."
