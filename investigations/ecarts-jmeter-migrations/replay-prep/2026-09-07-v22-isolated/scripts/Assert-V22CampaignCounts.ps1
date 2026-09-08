[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ResultRoot
)

$ErrorActionPreference = 'Stop'
function Get-ResultCount([string] $folder) {
    $count = 0
    if (-not (Test-Path -LiteralPath $folder -PathType Container)) { throw "Campaign result folder is missing: $folder" }
    foreach ($file in Get-ChildItem -LiteralPath $folder -File -Recurse | Where-Object { $_.Extension -in '.jtl','.csv' }) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        if ($raw.TrimStart().StartsWith('<')) { $count += ([regex]::Matches($raw, '<sample\b')).Count }
        else {
            $lines = @($raw -split "`r?`n" | Where-Object { $_.Trim() })
            if ($lines.Count -gt 0 -and $lines[0] -match '(?i)timeStamp|timestamp') { $count += [Math]::Max(0, $lines.Count - 1) } else { $count += $lines.Count }
        }
    }
    return $count
}
$legacy = Get-ResultCount (Join-Path $ResultRoot 'LegacyServices')
$web = Get-ResultCount (Join-Path $ResultRoot 'WebServices')
if ($legacy -ne 232 -or $web -ne 144) { throw "Campaign count mismatch: LegacyServices=$legacy (expected 232), WebServices=$web (expected 144)." }
Write-Host "Campaign counts OK: legacy=$legacy web=$web total=$($legacy + $web)."
