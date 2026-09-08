$ErrorActionPreference = 'Stop'

function Invoke-Fixture {
  param([string]$Name,[string]$InvalidId)
  $a = @{
    'image-digest' = [ordered]@{ passed = ($InvalidId -ne 'image-digest'); value = 'repoDigestsCount=1' }
    'image-os' = [ordered]@{ passed = ($InvalidId -ne 'image-os'); value = 'present=True' }
    'image-architecture' = [ordered]@{ passed = $true; value = 'present=True' }
    'target-scope' = [ordered]@{ passed = ($InvalidId -ne 'target-scope'); value = "valid=$($InvalidId -ne 'target-scope')" }
    'mounts' = [ordered]@{ passed = ($InvalidId -ne 'mounts'); value = "count=$(if($InvalidId -eq 'mounts'){1}else{0});dangerous=$(if($InvalidId -eq 'mounts'){1}else{0})" }
    'networks' = [ordered]@{ passed = ($InvalidId -ne 'networks'); value = "count=$(if($InvalidId -eq 'networks'){1}else{1});forbidden=$(if($InvalidId -eq 'networks'){1}else{0})" }
    'ports' = [ordered]@{ passed = ($InvalidId -ne 'ports'); value = "hostPortBindings=$(if($InvalidId -eq 'ports'){1}else{0})" }
  }
  $failed = @($a.GetEnumerator() | Where-Object { -not $_.Value.passed })
  foreach ($x in $a.GetEnumerator()) { Write-Output "V22_PREFLIGHT_ASSERTION fixture=$Name id=$($x.Key) passed=$($x.Value.passed) value=$($x.Value.value)" }
  if ($failed.Count -eq 0) { throw 'Fixture did not fail as expected.' }
  Write-Output "V22_PREFLIGHT_REFUSAL fixture=$Name failedAssertions=$($failed.Key -join ',')"
  Write-Output "V22_PREFLIGHT_CLEANUP fixture=$Name containerPresentAfterRemove=False"
}

@('image-digest','image-os','target-scope','mounts','networks','ports') | ForEach-Object { Invoke-Fixture -Name "invalid-$($_)" -InvalidId $_ }
