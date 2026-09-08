[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ContainerMappingJson,
    [Parameter(Mandatory)] [string] $ContainerResourceName,
    [Parameter(Mandatory)] [string] $ExpectedContainerId,
    [Parameter(Mandatory)] [string] $ExpectedRunId,
    [Parameter(Mandatory)] [string] $ExpectedJobName,
    [Parameter(Mandatory)] [string] $ExpectedJobId,
    [Parameter(Mandatory)] [string] $ExpectedAttempt,
    [Parameter(Mandatory)] [string] $ExpectedImage,
    [Parameter(Mandatory)] [string] $PolicyPath,
    [Parameter(Mandatory)] [string] $OutputPath,
    [Parameter(Mandatory)] [string] $ValidatorPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ContainerMappingJson) -or $ContainerMappingJson -match '^\$\(') { throw 'Agent.ContainerMapping is missing or unresolved.' }
if ([string]::IsNullOrWhiteSpace($ExpectedContainerId) -or $ExpectedContainerId -match '^\$\(') { throw 'Agent.ContainerId is missing or unresolved.' }
if ($ExpectedContainerId -notmatch '^[0-9a-fA-F]{12,64}$') { throw 'Expected container identity is malformed.' }
if ([string]::IsNullOrWhiteSpace($ExpectedAttempt) -or $ExpectedAttempt -match '^\$\(') { throw 'System.JobAttempt is missing or unresolved.' }
if (-not (Test-Path -LiteralPath $PolicyPath -PathType Leaf)) { throw "Isolation policy is missing: $PolicyPath" }
if (-not (Test-Path -LiteralPath $ValidatorPath -PathType Leaf)) { throw "Isolation validator is missing: $ValidatorPath" }
try { $mapping = $ContainerMappingJson | ConvertFrom-Json } catch { throw 'Agent.ContainerMapping is not valid JSON.' }
$mapped = $mapping.$ContainerResourceName
if ($null -eq $mapped -or [string]::IsNullOrWhiteSpace([string]$mapped.id)) { throw "Container resource mapping is missing: $ContainerResourceName" }
if ($mapped.id -ne $ExpectedContainerId) { throw 'Agent.ContainerMapping and Agent.ContainerId disagree.' }
try { $policyObject = Get-Content -LiteralPath $PolicyPath -Raw | ConvertFrom-Json } catch { throw 'Isolation policy is not valid JSON.' }
if ($null -eq $policyObject.containerResourceName -or $policyObject.containerResourceName -ne $ContainerResourceName) { throw 'Isolation policy is for a different container resource.' }

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker CLI is unavailable on the host step.' }
$agentWorkFolder = $env:AGENT_WORKFOLDER
$agentToolsDirectory = $env:AGENT_TOOLSDIRECTORY
$agentHomeDirectory = $env:AGENT_HOMEDIRECTORY
if ([string]::IsNullOrWhiteSpace($agentWorkFolder) -or [string]::IsNullOrWhiteSpace($agentToolsDirectory) -or [string]::IsNullOrWhiteSpace($agentHomeDirectory)) { throw 'Host agent roots are missing; refusing to classify mounts.' }
function Get-NormalizedPath([string] $path) { return [IO.Path]::GetFullPath($path).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) }
function Test-UnderRoot([string] $path, [string] $root) { $p = Get-NormalizedPath $path; $r = Get-NormalizedPath $root; return $p.Equals($r, [StringComparison]::OrdinalIgnoreCase) -or $p.StartsWith($r + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) }
$agentWorkFolder = Get-NormalizedPath $agentWorkFolder
$agentToolsDirectory = Get-NormalizedPath $agentToolsDirectory
$agentExternalsDirectory = Get-NormalizedPath (Join-Path $agentHomeDirectory 'externals')
$raw = (& docker inspect --format '{{json .}}' $ExpectedContainerId 2>$null) -join "`n"
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) { throw 'Docker inspect failed for the exact mapped job container.' }
try { $inspect = $raw | ConvertFrom-Json } catch { throw 'Docker inspect output is not valid JSON.' }
if ($inspect.Id -ne $ExpectedContainerId) { throw 'Docker inspect returned a different container identity.' }
if (-not [bool]$inspect.State.Running) { throw 'Mapped job container is not running.' }
if ($inspect.RepoDigests -notcontains $ExpectedImage) { throw 'Mapped job container repository digest does not match the candidate image.' }
if ([string]::IsNullOrWhiteSpace([string]$inspect.Config.Hostname)) { throw 'Mapped job container hostname is missing.' }

$networkEntries = @($inspect.NetworkSettings.Networks.psobject.Properties | ForEach-Object { [ordered]@{ name = $_.Name; id = $_.Value.NetworkID } })
$portEntries = @()
if ($null -ne $inspect.NetworkSettings.Ports) {
    $portEntries = @($inspect.NetworkSettings.Ports.psobject.Properties | ForEach-Object { foreach ($binding in @($_.Value)) { [ordered]@{ host = [int]$binding.HostPort; container = [int](($_.Name -split '/')[0]); protocol = (($_.Name -split '/')[1]).ToLowerInvariant() } } })
}
$attestation = [ordered]@{
    schema = 'v22-isolation-attestation-1'; producer = 'host'; runId = $ExpectedRunId; jobName = $ExpectedJobName; jobId = $ExpectedJobId
    scopeId = "$ExpectedRunId/$ExpectedJobName"; containerId = $inspect.Id; image = $ExpectedImage; attemptId = $ExpectedAttempt
    collectedUtc = [DateTimeOffset]::UtcNow.ToString('o')
    destinationHost = $inspect.Config.Hostname; sqlHost = $inspect.Config.Hostname; iisHost = $inspect.Config.Hostname
    mounts = @($inspect.Mounts | ForEach-Object { [ordered]@{ source = $_.Source; destination = $_.Destination; readOnly = (-not [bool]$_.RW) } })
    networks = $networkEntries
    ports = $portEntries
}
$policyMounts = @($policyObject.allowedMounts)
foreach ($mount in @($attestation.mounts)) {
    $match = @($policyMounts | Where-Object {
        $sourceOk = if ($null -ne $_.sourcePattern) { [string]$mount.source -match [string]$_.sourcePattern } else { $_.source -eq $mount.source }
        $destinationOk = if ($null -ne $_.destinationPattern) { [string]$mount.destination -match [string]$_.destinationPattern } else { $_.destination -eq $mount.destination }
        $sourceOk -and $destinationOk -and [bool]$_.readOnly -eq [bool]$mount.readOnly
    })
    if ($match.Count -ne 1) { throw "Host mount does not match policy: $($mount.destination)" }
    $logical = [string]$match[0].logical
    switch -Regex ($logical) {
        '^job-work$' { if (-not (Test-UnderRoot $mount.source $agentWorkFolder)) { throw 'Job-work source is outside Agent.WorkFolder.' } }
        '^agent-tools$' { if (-not (Test-UnderRoot $mount.source $agentToolsDirectory)) { throw 'Tools source is outside Agent.ToolsDirectory.' } }
        '^agent-externals$' { if (-not (Test-UnderRoot $mount.source $agentExternalsDirectory) -or [bool]$mount.readOnly -ne $true) { throw 'Externals source or mode is not the agent externals root/read-only contract.' } }
        '^agent-tasks-optional$' { if (-not (Test-UnderRoot $mount.source (Join-Path $agentWorkFolder '_tasks')) -or [bool]$mount.readOnly -ne $true) { throw 'Tasks source or mode is outside the optional read-only agent contract.' } }
        default { throw "Unknown policy mount logical name: $logical" }
    }
}
$tempPath = "$OutputPath.tmp"
$attestation | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $tempPath -Encoding UTF8
try {
    & $ValidatorPath -AttestationPath $tempPath -PolicyPath $PolicyPath -ExpectedRunId $ExpectedRunId -ExpectedJobName $ExpectedJobName -ExpectedJobId $ExpectedJobId -ExpectedAttempt $ExpectedAttempt -ExpectedContainerId $ExpectedContainerId -ExpectedImage $ExpectedImage -ExpectedDestinationHost $inspect.Config.Hostname
    $parent = Split-Path -Parent $OutputPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Move-Item -LiteralPath $tempPath -Destination $OutputPath -Force
    Write-Host "Host isolation attestation written for mapped container $($inspect.Id.Substring(0,12)) without exposing inspection payload."
} finally {
    if (Test-Path -LiteralPath $tempPath -PathType Leaf) { Remove-Item -LiteralPath $tempPath -Force }
}
