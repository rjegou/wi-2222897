[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ContainerId,
    [Parameter(Mandatory)] [string] $RunId,
    [Parameter(Mandatory)] [string] $ExpectedImageDigest,
    [Parameter(Mandatory)] [string] $SqlHost,
    [Parameter(Mandatory)] [string] $IisHost
)

$ErrorActionPreference = 'Stop'
if ($ContainerId -notmatch '^[0-9a-f]{12,64}$') { throw 'ContainerId must be a Docker ID.' }
if ($ExpectedImageDigest -notmatch '@sha256:[0-9a-f]{64}$') { throw 'Expected image must be digest-pinned.' }
if ([string]::IsNullOrWhiteSpace($RunId)) { throw 'RunId is required.' }

function DockerInspect([string] $format) {
    $value = & docker inspect --format $format $ContainerId 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($value -join ''))) { throw "docker inspect failed for the current container." }
    ($value -join '').Trim()
}

$actualId = DockerInspect '{{.Id}}'
$state = DockerInspect '{{.State.Status}}'
$image = DockerInspect '{{.Config.Image}}'
$scope = DockerInspect '{{index .Config.Labels "wi.scope"}}'
$ephemeral = DockerInspect '{{index .Config.Labels "wi.ephemeral"}}'
$labelRun = DockerInspect '{{index .Config.Labels "wi.runId"}}'
$hostname = DockerInspect '{{.Config.Hostname}}'
$ip = DockerInspect '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

if (-not $actualId.StartsWith($ContainerId)) { throw 'Inspected container ID differs from the asserted current container.' }
if ($state -ne 'running') { throw "Current container is not running: $state" }
if ($image -ne $ExpectedImageDigest) { throw 'Running image does not match the pinned digest.' }
if ($scope -ne 'WI-2222897/FrenchTaxesRules/V22' -or $ephemeral -ne 'true' -or $labelRun -ne $RunId) { throw 'Container labels do not prove ephemeral WI/run ownership.' }
if ($SqlHost -notin @($hostname, $ip, $ContainerId, $actualId.Substring(0,12)) -or $IisHost -notin @($hostname, $ip, $ContainerId, $actualId.Substring(0,12))) {
    throw 'SQL/IIS endpoints do not resolve to the current ephemeral container.'
}

$top = (& docker top $ContainerId 2>$null | Out-String)
if ($LASTEXITCODE -ne 0 -or $top -notmatch '(?i)sqlservr') { throw 'sqlservr is not observable in the current container.' }
if ($top -notmatch '(?i)(w3wp|iisexpress|inetinfo)') { throw 'IIS worker is not observable in the current container.' }
Write-Host "Runtime isolation OK: container=$($actualId.Substring(0,12)) state=$state scope=$scope run=$labelRun sql=$SqlHost iis=$IisHost; no writes performed."
