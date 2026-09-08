[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $AttestationPath,
    [Parameter(Mandatory)] [string] $PolicyPath,
    [Parameter(Mandatory)] [string] $ExpectedRunId,
    [Parameter(Mandatory)] [string] $ExpectedJobName,
    [Parameter(Mandatory)] [string] $ExpectedJobId,
    [Parameter(Mandatory)] [string] $ExpectedAttempt,
    [Parameter(Mandatory)] [string] $ExpectedContainerId,
    [Parameter(Mandatory)] [string] $ExpectedImage,
    [Parameter(Mandatory)] [string] $ExpectedDestinationHost,
    [int] $MaxAgeSeconds = 900,
    [int] $MaxFutureSkewSeconds = 60
)

$ErrorActionPreference = 'Stop'
foreach ($path in @($AttestationPath, $PolicyPath)) {
    if ([string]::IsNullOrWhiteSpace($path) -or $path -match '^\$\(' -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Isolation attestation input is missing or unresolved: $path"
    }
}
if ($ExpectedImage -notmatch '@sha256:[0-9a-f]{64}$') { throw 'Expected image is not digest-pinned.' }

function Read-JsonObject([string] $path, [string] $name) {
    try { $value = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json } catch { throw "$name is not valid JSON." }
    if ($null -eq $value -or $value -is [array]) { throw "$name must be a JSON object." }
    return $value
}

$attestation = Read-JsonObject $AttestationPath 'Isolation attestation'
$policy = Read-JsonObject $PolicyPath 'Isolation policy'
if ($attestation.schema -ne 'v22-isolation-attestation-1' -or $attestation.producer -ne 'host') { throw 'Isolation attestation provenance is not the required host contract.' }
if ($attestation.runId -ne $ExpectedRunId -or $attestation.jobName -ne $ExpectedJobName -or $attestation.jobId -ne $ExpectedJobId -or [string]$attestation.attemptId -ne $ExpectedAttempt) { throw 'Isolation attestation is for a different run, job or attempt.' }
if ([string]::IsNullOrWhiteSpace([string]$attestation.collectedUtc)) { throw 'Isolation attestation freshness timestamp is missing.' }
try { $collected = [DateTimeOffset]::Parse([string]$attestation.collectedUtc, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind) } catch { throw 'Isolation attestation freshness timestamp is invalid.' }
$age = ([DateTimeOffset]::UtcNow - $collected).TotalSeconds
if ($age -lt (-1 * $MaxFutureSkewSeconds) -or $age -gt $MaxAgeSeconds) { throw "Isolation attestation is outside freshness window: ageSeconds=$([math]::Round($age, 1))." }
if ($attestation.image -ne $ExpectedImage) { throw 'Isolation attestation image digest does not match the candidate.' }
if ($attestation.scopeId -ne "$ExpectedRunId/$ExpectedJobName") { throw 'Isolation scope is missing or does not identify this run/job.' }
if ($null -ne $policy.scopeId -and $attestation.scopeId -ne $policy.scopeId) { throw 'Isolation scope differs from the explicit policy.' }
if ($null -ne $policy.scopePattern -and $attestation.scopeId -notmatch [string]$policy.scopePattern) { throw 'Isolation scope does not match the explicit policy.' }
if ($attestation.destinationHost -ne $ExpectedDestinationHost -or $attestation.sqlHost -ne $ExpectedDestinationHost -or $attestation.iisHost -ne $ExpectedDestinationHost) { throw 'Isolation destinations are not bound to the current job host.' }
if ($attestation.containerId -notmatch '^[0-9a-fA-F]{12,64}$' -or $attestation.containerId -ne $ExpectedContainerId) { throw 'Isolation attestation is for a different container or has malformed identity.' }

$actualMounts = @($attestation.mounts)
$allowedMounts = @($policy.allowedMounts)
$matchedMounts = @{}
foreach ($mount in $actualMounts) {
    if ($null -eq $mount.source -or $null -eq $mount.destination -or $null -eq $mount.readOnly) { throw 'Mount entry is incomplete.' }
    $forbiddenMountPatterns = @($policy.forbiddenMountPatterns | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    if ($forbiddenMountPatterns.Count -gt 0 -and @($forbiddenMountPatterns | Where-Object { [string]$mount.source -match $_ -or [string]$mount.destination -match $_ }).Count -gt 0) { throw "Forbidden shared mount: $($mount.destination)" }
    $match = @($allowedMounts | ForEach-Object -Begin { $index = 0 } -Process { $current = $_; $currentIndex = $index; $index++; $sourceOk = if ($null -ne $current.sourcePattern) { [string]$mount.source -match [string]$current.sourcePattern } else { $current.source -eq $mount.source }; $destinationOk = if ($null -ne $current.destinationPattern) { [string]$mount.destination -match [string]$current.destinationPattern } else { $current.destination -eq $mount.destination }; if ($sourceOk -and $destinationOk -and [bool]$current.readOnly -eq [bool]$mount.readOnly) { [pscustomobject]@{ Index = $currentIndex; Entry = $current } } })
    if ($match.Count -ne 1) { throw "Mount is not explicitly allowed: $($mount.destination)" }
    if ($matchedMounts.ContainsKey($match[0].Index)) { throw "Duplicate policy match for mount: $($mount.destination)" }
    $matchedMounts[$match[0].Index] = $true
}
foreach ($index in 0..($allowedMounts.Count - 1)) { if (-not $matchedMounts.ContainsKey($index) -and -not [bool]$allowedMounts[$index].optional) { throw "Required policy mount is absent: $($allowedMounts[$index].logical)" } }

$actualNetworks = @($attestation.networks)
$allowedNetworks = @($policy.allowedNetworks)
foreach ($network in $actualNetworks) {
    if ($null -eq $network.name -or $null -eq $network.id) { throw 'Network entry is incomplete.' }
    if (@($allowedNetworks | Where-Object { $nameOk = if ($null -ne $_.namePattern) { [string]$network.name -match [string]$_.namePattern } else { $_.name -eq $network.name }; $idOk = if ($null -ne $_.idPattern) { [string]$network.id -match [string]$_.idPattern } else { $_.id -eq $network.id }; $nameOk -and $idOk }).Count -ne 1) { throw "Network is not explicitly allowed: $($network.name)" }
}
if ($actualNetworks.Count -lt @($allowedNetworks | Where-Object { -not [bool]$_.optional }).Count) { throw 'A required policy network is absent.' }

$actualPorts = @($attestation.ports)
$allowedPorts = @($policy.allowedPorts)
foreach ($port in $actualPorts) {
    if (@($allowedPorts | Where-Object { $_.host -eq $port.host -and $_.container -eq $port.container -and $_.protocol -eq $port.protocol }).Count -ne 1) { throw 'Port mapping is not explicitly allowed.' }
}
if ($actualPorts.Count -gt $allowedPorts.Count) { throw 'Unexpected published port exists.' }

Write-Host "Isolation attestation accepted for run=$ExpectedRunId job=$ExpectedJobName container=$($attestation.containerId) image=$ExpectedImage; SQL/IIS destinations and mounts/networks/ports match policy."
