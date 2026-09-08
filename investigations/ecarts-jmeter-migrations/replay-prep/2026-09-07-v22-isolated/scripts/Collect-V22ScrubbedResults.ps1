[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ResultRoot,
    [Parameter(Mandatory)] [string] $OutputPath,
    [Parameter(Mandatory)] [ValidateSet('FixHistorical','FixCandidate')] [string] $Variant
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ResultRoot -PathType Container)) { throw "Result root is missing: $ResultRoot" }
$rows = [System.Collections.Generic.List[object]]::new()
foreach ($file in Get-ChildItem -LiteralPath $ResultRoot -File -Recurse | Where-Object { $_.Extension -in '.jtl','.csv','.log' }) {
    $bytes = (Get-Item -LiteralPath $file.FullName).Length
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    $lines = @(Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue)
    $rows.Add([ordered]@{
        variant = $Variant
        file = $file.Name
        relative = $file.FullName.Substring($ResultRoot.TrimEnd('\').Length).TrimStart('\')
        extension = $file.Extension.ToLowerInvariant()
        bytes = $bytes
        sha256 = $hash
        lineCount = $lines.Count
        successTrueCount = @($lines | Where-Object { $_ -match '(?i)(^|[,;])true([,;]|$)' }).Count
        successFalseCount = @($lines | Where-Object { $_ -match '(?i)(^|[,;])false([,;]|$)' }).Count
        errorMarkerCount = @($lines | Where-Object { $_ -match '(?i)error|exception|failed|assertion' }).Count
    })
}
$parent = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $parent -Force | Out-Null
@{
    variant = $Variant
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    files = @($rows)
    secretPolicy = 'No URLs, credentials, tokens, claims, payloads or raw lines are retained.'
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Scrubbed result summary written: files=$($rows.Count), variant=$Variant"
