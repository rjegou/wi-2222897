$ErrorActionPreference = 'Stop'
$fixture = Get-Content (Join-Path $PSScriptRoot 'artifact-item-fixtures.json') -Raw | ConvertFrom-Json
function Assert([bool]$ok,[string]$message) { if (-not $ok) { throw $message } }
function Validate([object]$manifest,[bool]$localMode) {
  if (-not $localMode) { return 'normal-path' }
  Assert ($manifest.artifactId -eq '5037140') 'wrong artifact id'
  Assert ($manifest.pluginName -eq 'Y2.Plugin.InventoryTracking' -and $manifest.version -eq '26.0.7.83') 'wrong plugin identity/version'
  Assert (@($manifest.items).Count -eq 4) 'expected four items'
  $names=@($manifest.items | % name); Assert (@($names | Select-Object -Unique).Count -eq 4) 'ambiguous item selection'
  foreach($i in $fixture.items) { $got=@($manifest.items | ? name -eq $i.name); Assert ($got.Count -eq 1 -and $got[0].length -eq $i.length -and $got[0].sha256 -eq $i.sha256) "missing or altered $($i.name)" }
  return 'local-substitution'
}
$cases=@()
function Case([string]$name,[scriptblock]$action,[bool]$expected) { $ok=$true; try { & $action | Out-Null } catch { $ok=$false }; $script:cases += [pscustomobject]@{name=$name;pass=($ok -eq $expected)} }
Case 'positive identity-version-hashes' { Validate $fixture $true } $true
Case 'missing-file' { $x=$fixture | ConvertTo-Json -Depth 8 | ConvertFrom-Json; $x.items=@($x.items | Select-Object -First 3); Validate $x $true } $false
Case 'wrong-version' { $x=$fixture | ConvertTo-Json -Depth 8 | ConvertFrom-Json; $x.version='26.0.7.82'; Validate $x $true } $false
Case 'altered-hash' { $x=$fixture | ConvertTo-Json -Depth 8 | ConvertFrom-Json; $x.items[0].sha256=('0'*64); Validate $x $true } $false
Case 'ambiguous-selection' { $x=$fixture | ConvertTo-Json -Depth 8 | ConvertFrom-Json; $x.items=@($x.items)+$x.items[0]; Validate $x $true } $false
Case 'dependencies-preserved' { Assert (@($fixture.dependencies).Count -eq 4) 'dependencies lost' } $true
Case 'option-absent-keeps-normal-path' { Assert ((Validate $fixture $false) -eq 'normal-path') 'normal path changed' } $true
$cases | ConvertTo-Json -Compress
if (@($cases | ? { -not $_.pass }).Count) { exit 1 }
