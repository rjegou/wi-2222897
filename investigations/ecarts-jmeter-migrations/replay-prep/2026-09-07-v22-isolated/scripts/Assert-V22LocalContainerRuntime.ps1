[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $RunId,
    [Parameter(Mandatory)] [string] $ExpectedImage,
    [Parameter(Mandatory)] [string] $AppHost,
    [Parameter(Mandatory)] [string] $DbHost,
    [Parameter(Mandatory)] [string] $AuthorityHost
)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:TF_BUILD)) { throw 'TF_BUILD runtime marker is missing.' }
if ([string]::IsNullOrWhiteSpace($env:COMPUTERNAME)) { throw 'Container hostname is missing.' }
if ($RunId -match '[\\/:]' -or $RunId -match '(^|[.])\\.($|[\\/])') { throw 'RunId contains path syntax; refusing to create a marker outside the job scope.' }
if ($ExpectedImage -notmatch '@sha256:[0-9a-f]{64}$') { throw 'Expected image is not digest-pinned.' }
if ($AppHost -ne $env:COMPUTERNAME -or $DbHost -ne $env:COMPUTERNAME -or $AuthorityHost -ne $env:COMPUTERNAME) {
    throw 'Application, SQL and AuthenticationServer endpoints are not the current job container.'
}
$processes = @(Get-Process -ErrorAction Stop)
if (-not ($processes.ProcessName -match '(?i)^sqlservr$')) { throw 'sqlservr is not running in the current job container.' }
if (-not ($processes.ProcessName -match '(?i)^(w3wp|iisexpress|inetinfo)$')) { throw 'IIS worker is not running in the current job container.' }
$listeners = @(Get-NetTCPConnection -State Listen -ErrorAction Stop)
foreach ($port in 80,1433) {
    if (-not ($listeners | Where-Object LocalPort -eq $port)) { throw "Expected local listener $port is absent." }
}
$root = [IO.Path]::GetFullPath($env:AGENT_TEMPDIRECTORY)
$marker = Join-Path $root ("V22-FrenchTaxesRules-" + $RunId)
$markerFull = [IO.Path]::GetFullPath($marker)
$rootPrefix = $root.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $markerFull.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Readiness marker escaped Agent.TempDirectory; refusing to write.' }
New-Item -ItemType Directory -Path $marker -Force | Out-Null
Write-Host "Local service readiness OK: host=$env:COMPUTERNAME run=$RunId ports=80,1433 marker=$marker. This check does not attest container identity, mounts, lifecycle or absence of shared targets."
