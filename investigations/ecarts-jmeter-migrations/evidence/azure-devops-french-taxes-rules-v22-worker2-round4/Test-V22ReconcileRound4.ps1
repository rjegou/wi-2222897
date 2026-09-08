$ErrorActionPreference = 'Stop'
$sourcePath = Join-Path $PSScriptRoot '..\azure-devops-french-taxes-rules-v22-exact-yaml-44070560\azure-pipelines.wi2222897-v22-preflight.yml'
$candidatePath = Join-Path $PSScriptRoot '..\..\replay-prep\2026-09-07-v22-round21-review\azure-pipelines.wi2222897-v22-preflight.null-safe.yml'
$source = Get-Content -LiteralPath $sourcePath -Raw
$candidate = Get-Content -LiteralPath $candidatePath -Raw
$old = '          $mounts = @($inspection.Mounts | ForEach-Object { [ordered]@{type=$_.Type;source=$_.Source;destination=$_.Destination;rw=$_.RW} })'
$new = '          $mounts = @($inspection.Mounts | Where-Object { $null -ne $_ } | ForEach-Object { [ordered]@{type=$_.Type;source=$_.Source;destination=$_.Destination;rw=$_.RW} })'
if (([regex]::Matches($source, [regex]::Escape($old))).Count -ne 1) { throw 'Source hunk is not unique.' }
$worker1 = $source.Replace($old, $new)
function Get-Sha([string] $text) { return (([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($text)) | ForEach-Object ToString x2) -join '').ToUpperInvariant() }
$sourceHash = Get-Sha $source
$worker1Hash = Get-Sha $worker1
$candidateHash = Get-Sha $candidate
if ($sourceHash -cne 'DB8ED1DD519CB021E6A90C2504E956C7DDCBBB26D9BBE47AEBF499C9093E4E7A') { throw "Source hash mismatch: $sourceHash" }
if ($worker1Hash -cne '0D2D781CF054CD4644C46552AB610544282D4CDD805EDCE9D197F66C151A0D5B') { throw "Worker 1 reconstruction mismatch: $worker1Hash" }
if ($candidateHash -cne '659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2') { throw "Candidate hash mismatch: $candidateHash" }
if ($worker1 -match 'configVolumes|ConvertTo-ScrubbedPath') { throw 'Worker 1 result unexpectedly contains diagnostic projection.' }
if ($candidate -notmatch 'configVolumes|ConvertTo-ScrubbedPath' -or $candidate -notmatch 'Where-Object \{ \$null -ne \$_ \}') { throw 'Candidate projection or null-safe filter is absent.' }
if ($candidate -notmatch 'dangerousMounts\.Count -eq 0' -or $candidate -notmatch 'timeoutInMinutes: 10' -or $candidate -notmatch 'cancelTimeoutInMinutes: 1' -or $candidate -notmatch 'docker rm -f \$name' -or $candidate -notmatch 'containerPresentAfterRemove') { throw 'Whitelist, timeout or cleanup changed.' }
if ($candidate -match '(?im)jmeter\.bat|sqlcmd|JFrog|PublishPipelineArtifact|PublishBuildArtifacts') { throw 'Business or publication action found.' }
Write-Output "PASS: source=$sourceHash; worker1AppliedOnlyFilter=$worker1Hash; candidate=$candidateHash; functionalDifference=projectionMissingInWorker1; syntaxAndProjectionCheckedByCandidateTest"
