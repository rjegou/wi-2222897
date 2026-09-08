param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][string]$OutputRoot,
    [Parameter(Mandatory=$true)][string]$CampaignFilesText
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) { throw "Missing source root: $SourceRoot" }
$campaigns = @($CampaignFilesText -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($campaigns.Count -eq 0) { throw 'At least one campaign is required.' }
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$entries = @()
foreach ($jmx in $campaigns) {
    if ([IO.Path]::GetExtension($jmx) -ne '.jmx') { throw "Campaign is not a JMX path: $jmx" }
    $xml = [IO.Path]::ChangeExtension($jmx, '.xml')
    $source = Join-Path $SourceRoot $xml
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Source XML missing: $source" }
    $dest = Join-Path $OutputRoot $xml
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
    Copy-Item -LiteralPath $source -Destination $dest -Force
    $entries += [ordered]@{ path=$xml; jmxPath=$jmx; sourceXml=$xml; sha256=(Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToUpperInvariant() }
}
[ordered]@{ scope='WI-2222897'; kind='migration'; buildId="source-$(git -C $SourceRoot rev-parse HEAD)"; commit="$(git -C $SourceRoot rev-parse HEAD)"; version='repo-source'; files=$entries } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $OutputRoot 'manifest.json') -Encoding UTF8
Write-Host "PASS: migrationFiles=$($entries.Count); sourceRoot=$SourceRoot"
