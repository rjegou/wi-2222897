[CmdletBinding()]
param([Parameter(Mandatory)] [string] $ContractPath, [Parameter(Mandatory)] [string] $EvidenceRoot)
$ErrorActionPreference='Stop'
. $ContractPath
New-Item -ItemType Directory -Path $EvidenceRoot -Force | Out-Null
$root=Join-Path $EvidenceRoot 'fixture'; New-Item -ItemType Directory -Path $root -Force | Out-Null
$ctx=@{RunId='run-1';JobName='job-1';JobId='job-id';Attempt='1';Host='host-1';Os='windows-2025';ExclusiveEndpoint='endpoint-1'}
$image='registry.example/y2-jmeter@sha256:' + ('a'*64)
$inspect=[pscustomobject]@{Id='0123456789abcdef';Running=$true;Image=$image;Mounts=@('C:\job-temp');Networks=@('job-net-1');Ports=@()}
$mapping=[pscustomobject]@{jmeter=[pscustomobject]@{id=$inspect.Id}}
$path=Join-Path $root 'attestation.json'; New-HostAttestation $mapping 'jmeter' $inspect $ctx $image $path
$expected=@{runId='run-1';jobName='job-1';jobId='job-id';attempt='1';containerId=$inspect.Id;os='windows-2025';imageDigest=$image;host='host-1';exclusiveEndpoint='endpoint-1'}
Assert-HostAttestation $path $expected
$cases=@('stale','different-container','absent')
$a=Get-Content $path -Raw | ConvertFrom-Json; $a.collectedUtc=[DateTimeOffset]::UtcNow.AddMinutes(-30).ToString('o'); $a | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $root 'stale.json')
try { Assert-HostAttestation (Join-Path $root 'stale.json') $expected; throw 'stale accepted' } catch { if ($_.Exception.Message -notmatch 'stale') { throw } }
$a=Get-Content $path -Raw | ConvertFrom-Json; $a.containerId='abcdef0123456789'; $a | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $root 'different-container.json')
try { Assert-HostAttestation (Join-Path $root 'different-container.json') $expected; throw 'different container accepted' } catch { if ($_.Exception.Message -notmatch 'containerId') { throw } }
try { Assert-HostAttestation (Join-Path $root 'absent.json') $expected; throw 'absent accepted' } catch { if ($_.Exception.Message -notmatch 'absent') { throw } }
$owned=Join-Path $root 'owned'; New-Item -ItemType Directory -Path $owned -Force | Out-Null; 'owner-1' | Set-Content (Join-Path $owned '.owner'); 'owned' | Set-Content (Join-Path $owned 'artifact.txt')
$unowned=Join-Path $root 'unowned.txt'; 'keep' | Set-Content $unowned
Remove-OwnedReplayObjects $owned 'owner-1'
if (Test-Path (Join-Path $owned 'artifact.txt')) { throw 'owned artifact survived cleanup' }; if (-not (Test-Path $unowned)) { throw 'unowned artifact was removed' }
'PASS: valid producer/consumer; absent, stale and different-container refusals; cleanup only owned objects.' | Set-Content (Join-Path $EvidenceRoot 'test-result.txt')
