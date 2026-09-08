[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ResultRoot,
    [Parameter(Mandatory)] [ValidateSet('FixHistorical','FixCandidate')] [string] $Variant,
    [Parameter(Mandatory)] [string] $ExpectedImage,
    [Parameter(Mandatory)] [string] $ExpectedPluginVersion,
    [Parameter(Mandatory)] [string] $ExpectedAuthenticationServerVersion,
    [Parameter(Mandatory)] [string] $ExpectedBackupSha256,
    [Parameter(Mandatory)] [string] $CoreVersion,
    [Parameter(Mandatory)] [string] $CommonVersion,
    [Parameter(Mandatory)] [string] $IdentityVersion,
    [string] $BaselineSummaryJson,
    [string] $ExpectedBaselineCoreVersion,
    [string] $ExpectedBaselineCommonVersion,
    [string] $ExpectedBaselineIdentityVersion
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ResultRoot -PathType Container)) { throw "Result root is missing: $ResultRoot" }
if ($ExpectedImage -notmatch '@sha256:[0-9a-fA-F]{64}$') { throw 'Authorization comparison image is not digest-pinned.' }
if ($ExpectedBackupSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Authorization comparison backup hash is invalid.' }
if ([string]::IsNullOrWhiteSpace($ExpectedPluginVersion) -or [string]::IsNullOrWhiteSpace($ExpectedAuthenticationServerVersion)) { throw 'Authorization comparison shared package provenance is incomplete.' }
function Get-Rows([string] $folder) {
    if (-not (Test-Path -LiteralPath $folder -PathType Container)) { throw "Campaign folder is missing: $folder" }
    foreach ($file in Get-ChildItem -LiteralPath $folder -Recurse -File | Where-Object { $_.Extension -in '.jtl','.csv' }) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        if ($raw.TrimStart().StartsWith('<')) {
            foreach ($m in [regex]::Matches($raw, '(?s)<sample\b.*?</sample>')) {
                $scenario = $file.Name
                if ($m.Value -match '(?i)\b(?:lb|label)="([^"]+)"') { $scenario = $Matches[1] }
                [pscustomobject]@{ scenario=$scenario; text=$m.Value }
            }
        } else {
            $records = @(Import-Csv -LiteralPath $file.FullName)
            foreach ($record in $records) {
                $scenario = $file.Name
                $label = @($record.PSObject.Properties | Where-Object { $_.Name -match '^(?i:label|lb|sampler_label)$' } | Select-Object -First 1)
                if ($label.Count -eq 1 -and -not [string]::IsNullOrWhiteSpace([string]$label[0].Value)) { $scenario = [string]$label[0].Value }
                $text = (($record.PSObject.Properties | ForEach-Object { [string]$_.Value }) -join '|')
                [pscustomobject]@{ scenario=$scenario; text=$text }
            }
        }
    }
}
function Get-Summary([string] $folder, [string] $kind) {
    $rows = @(Get-Rows $folder)
    $items = @{}
    foreach ($row in $rows) {
        $category = $null
        if ($kind -eq 'Legacy' -and $row.text -match '(?i)CBP50101|ID4266|ClaimsPrincipalPermission') { $category = 'LegacyAuthorization' }
        if ($kind -eq 'Web' -and $row.text -match '(?i)FailedAuthentication|Access is denied') { $category = 'WebAuthorization' }
        if ($category) {
            $key = "$($row.scenario)|$category"
            if (-not $items.ContainsKey($key)) { $items[$key] = 0 }
            $items[$key]++
        }
    }
    [pscustomobject]@{ counts=$items; total=($items.Values | Measure-Object -Sum).Sum }
}
$summary = [ordered]@{
    variant = $Variant
    provenance = [ordered]@{
        image = $ExpectedImage
        pluginVersion = $ExpectedPluginVersion
        authenticationServerVersion = $ExpectedAuthenticationServerVersion
        backupSha256 = $ExpectedBackupSha256.ToUpperInvariant()
        coreVersion = $CoreVersion
        commonVersion = $CommonVersion
        identityVersion = $IdentityVersion
    }
    legacy = Get-Summary (Join-Path $ResultRoot 'LegacyServices') 'Legacy'
    web = Get-Summary (Join-Path $ResultRoot 'WebServices') 'Web'
}
$legacyTotal = [int]$summary.legacy.total
$webTotal = [int]$summary.web.total
if ($Variant -eq 'FixHistorical') {
    if ($legacyTotal -ne 138 -or $webTotal -ne 36) { throw "Baseline authorization signature mismatch: legacy=$legacyTotal expected=138, web=$webTotal expected=36." }
    $json = $summary | ConvertTo-Json -Compress -Depth 8
    Write-Output $json
    Write-Host "Baseline authorization signatures verified by scenario: legacy=$legacyTotal web=$webTotal total=$($legacyTotal+$webTotal)."
    exit 0
}
if ([string]::IsNullOrWhiteSpace($BaselineSummaryJson)) { throw 'Candidate comparison requires the baseline summary.' }
$baseline = $BaselineSummaryJson | ConvertFrom-Json
if ([int]$baseline.legacy.total -ne 138 -or [int]$baseline.web.total -ne 36) { throw 'Baseline summary is not the required 138+36 authorization signature baseline.' }
if (-not $baseline.provenance -or $baseline.provenance.image -ne $ExpectedImage -or $baseline.provenance.pluginVersion -ne $ExpectedPluginVersion -or $baseline.provenance.authenticationServerVersion -ne $ExpectedAuthenticationServerVersion -or $baseline.provenance.backupSha256 -ne $ExpectedBackupSha256.ToUpperInvariant()) { throw 'Baseline summary provenance does not match the candidate shared inputs.' }
if ($baseline.provenance.coreVersion -ne $ExpectedBaselineCoreVersion -or $baseline.provenance.commonVersion -ne $ExpectedBaselineCommonVersion -or $baseline.provenance.identityVersion -ne $ExpectedBaselineIdentityVersion) { throw 'Baseline summary provenance does not match the expected historical package versions.' }
if ($legacyTotal -ne 0 -or $webTotal -ne 0) { throw "Candidate authorization signatures remain: legacy=$legacyTotal web=$webTotal." }
foreach ($branch in @('legacy','web')) {
    foreach ($property in $baseline.$branch.counts.PSObject.Properties) {
        if ($summary.$branch.counts.ContainsKey($property.Name)) { throw "Candidate still contains baseline authorization signature: $($property.Name)." }
    }
}
Write-Host "Candidate authorization comparison verified: baseline=174 signatures, candidate=0 matching authorization signatures; unrelated failures remain separately countable."
