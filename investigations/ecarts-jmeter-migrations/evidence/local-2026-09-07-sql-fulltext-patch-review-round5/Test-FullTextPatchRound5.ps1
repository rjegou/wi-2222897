param(
  [string]$YamlPath = (Join-Path $PSScriptRoot '..\..\..\..\worktrees\Pipelines_Docker_BaseImages_worker2_round9\validation\WI-2222897\sql-fulltext-hosted-build.yml')
)

$ErrorActionPreference = 'Stop'
$lines = Get-Content -LiteralPath $YamlPath
$starts = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s+- powershell: \|$') { $starts += $i }
}
if ($starts.Count -ne 2) { throw "Expected two PowerShell stage scripts, found $($starts.Count)" }

$scripts = @()
foreach ($start in $starts) {
  $end = $start + 1
  while ($end -lt $lines.Count -and $lines[$end] -notmatch '^\s+displayName: Build and smoke-test') { $end++ }
  if ($end -ge $lines.Count) { throw 'Stage displayName not found' }
  $script = ($lines[($start + 1)..($end - 1)] | ForEach-Object {
    if ($_.Length -ge 8) { $_.Substring(8) } else { $_ }
  }) -join "`n"
  $tokens = $null
  $parseErrors = $null
  [System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$tokens, [ref]$parseErrors) | Out-Null
  if ($parseErrors.Count -ne 0) { throw "PowerShell parse failed at YAML line $($start + 1): $($parseErrors.Message -join '; ')" }
  $scripts += $script
}
Write-Output "SCRIPT_PARSE=PASS count=$($scripts.Count)"

$script:MockRemove = 0
$script:MockInspect = 0
$script:MockNames = ''
function docker {
  if ($args[0] -eq 'rm') { $global:LASTEXITCODE = $script:MockRemove; return }
  if ($args[0] -eq 'ps') {
    $global:LASTEXITCODE = $script:MockInspect
    if ($script:MockNames) { Write-Output $script:MockNames }
    return
  }
  $global:LASTEXITCODE = 0
}

function Get-CleanupBlock([string]$ScriptText, [string]$StageName) {
  $stageLines = $ScriptText -split "`n"
  $rmLine = ($stageLines | Select-String 'docker rm -f \$container').LineNumber[0] - 1
  $start = $rmLine - 1
  while ($start -ge 0 -and $stageLines[$start].Trim() -ne 'try {') { $start-- }
  $end = $rmLine
  while ($end -lt $stageLines.Count -and $stageLines[$end] -notmatch '\} catch \{ Write-Warning \("' + [regex]::Escape($StageName) + ' cleanup verification failed:') { $end++ }
  if ($start -lt 0 -or $end -ge $stageLines.Count) { throw "Cleanup block not found for $StageName" }
  return ($stageLines[$start..$end] -join "`n")
}

$cases = @(
  @{ Name = 'absence-confirmed'; Remove = 0; Inspect = 0; Names = '' },
  @{ Name = 'container-remains'; Remove = 0; Inspect = 0; Names = 'sql-fulltext-smoke-test' },
  @{ Name = 'remove-failed'; Remove = 1; Inspect = 0; Names = 'sql-fulltext-smoke-test' },
  @{ Name = 'docker-ps-failed'; Remove = 0; Inspect = 1; Names = '' }
)
$results = @()
foreach ($stageIndex in 0..1) {
  $stageName = if ($stageIndex -eq 0) { 'SQL 2019' } else { 'SQL 2025' }
  $scriptText = $scripts[$stageIndex]
  $controlFlowPresent = ($scriptText -match '\$smokeError = \$null') -and
    ($scriptText -match 'finally \{') -and
    ($scriptText -match '\$null -ne \$smokeError\) \{ throw \$smokeError \}') -and
    ($scriptText -match 'diagnostic collection failed') -and
    ($scriptText -match 'docker rm -f \$container')
  if (-not $controlFlowPresent) { throw "Expected diagnostic/cleanup control flow missing for $stageName" }
  $cleanup = Get-CleanupBlock $scripts[$stageIndex] $stageName
  foreach ($case in $cases) {
    $script:MockRemove = $case.Remove
    $script:MockInspect = $case.Inspect
    $script:MockNames = $case.Names
    $output = (& {
      $container = 'sql-fulltext-smoke-test'
      Invoke-Expression $cleanup
    } *>&1 | Out-String).Trim() -replace '\s+', ' '
    $results += [pscustomobject]@{
      stage = $stageName
      case = $case.Name
      warning = ($output -match 'could not be verified')
      unknown = ($output -match 'remaining=UNKNOWN')
      output = $output
    }
  }
  $results += [pscustomobject]@{
    stage = $stageName
    case = 'source-control-flow-present'
    diagnosticCatch = ($scriptText -match 'diagnostic collection failed')
    cleanupFinally = ($scriptText -match 'finally \{')
    smokeRethrow = ($scriptText -match '\$null -ne \$smokeError\) \{ throw \$smokeError \}')
  }
}

Remove-Item Function:docker -ErrorAction SilentlyContinue
$smokeError = $null
$cleanupRan = $false
$rethrow = $false
try { throw 'smoke failed' } catch { $smokeError = $_.Exception } finally { $cleanupRan = $true }
try { if ($null -ne $smokeError) { throw $smokeError } } catch { $rethrow = $true }
$results += [pscustomobject]@{ stage = 'control-flow'; case = 'smoke-failed-preserved'; cleanupRan = $cleanupRan; rethrow = $rethrow }

$diagnosticCaught = $false
$cleanupRan = $false
try { throw 'diagnostic failed' } catch { $diagnosticCaught = $true } finally { $cleanupRan = $true }
$results += [pscustomobject]@{ stage = 'control-flow'; case = 'collection-failed-cleanup'; diagnosticCaught = $diagnosticCaught; cleanupRan = $cleanupRan }

$results | ConvertTo-Json -Depth 4
