param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$ContractRoot,
  [Parameter(Mandatory=$true)][string]$IsolationMarker,
  [Parameter(Mandatory=$true)][string]$ExpectedAppServerHost,
  [string]$ExpectedSha256 = 'C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C'
)
$ErrorActionPreference='Stop'
if ([string]::IsNullOrWhiteSpace($ExpectedAppServerHost) -or $ExpectedAppServerHost -match '^\$\(') { throw 'REFUSE: approved application-server host is unresolved' }
if (-not (Test-Path -LiteralPath $IsolationMarker -PathType Leaf)) { throw 'REFUSE: explicit dedicated-target marker is absent' }
if ((Get-Content -LiteralPath $IsolationMarker -Raw).Trim() -ne 'WI-2222897-V26-Fix-DEDICATED') { throw 'REFUSE: target is not explicitly dedicated to WI-2222897 V26 Fix' }
$cfg = Join-Path $SourceRoot 'Tests\Config\v26-Fix.cy2px'
if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) { throw "REFUSE: deployment config absent: $cfg" }
$cfgText = Get-Content -LiteralPath $cfg -Raw
if ($cfgText -match '__CONTAINER_HOST__|APPSERVER_HOST') { throw 'REFUSE: unresolved or externally supplied target host in deployment config' }
$src = Join-Path $ContractRoot 'payload\Tests\Export_Run\001-Export_Run.jmx'
$dstDir = Join-Path $SourceRoot 'Tests\Export_Run'; $dst = Join-Path $dstDir '001-Export_Run.jmx'
if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { throw 'REFUSE: corrected JMX source absent' }
if ((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash -ne $ExpectedSha256) { throw 'REFUSE: corrected JMX source hash mismatch' }
New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
Copy-Item -LiteralPath $src -Destination $dst -Force
Copy-Item -LiteralPath (Join-Path $ContractRoot 'campaigns\ExportRunOnly.xml') -Destination (Join-Path $SourceRoot 'Tests\ExportRunOnly.xml') -Force
if ((Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash -ne $ExpectedSha256) { throw 'REFUSE: destination JMX hash mismatch' }
Write-Host 'PASS isolated marker and JMX hash verified; destination path withheld'
