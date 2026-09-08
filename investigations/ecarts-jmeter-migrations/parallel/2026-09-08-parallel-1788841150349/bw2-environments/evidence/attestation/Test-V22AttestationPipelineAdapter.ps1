[CmdletBinding()]
param([Parameter(Mandatory)] [string] $AdapterPath, [Parameter(Mandatory)] [string] $ContractPath, [Parameter(Mandatory)] [string] $EvidenceRoot)
$ErrorActionPreference='Stop'
$fixture=Join-Path $EvidenceRoot 'adapter-fixture'; New-Item -ItemType Directory -Path $fixture -Force | Out-Null
$oldPath=$env:Path; $oldMapping=$env:AGENT_CONTAINERMAPPING
$id='0123456789abcdef'; $image='registry.example/y2-jmeter@sha256:' + ('b'*64)
$dockerJson=([ordered]@{Id=$id;State=[ordered]@{Running=$true};Config=[ordered]@{Image=$image};Mounts=@([ordered]@{Source='C:\job-temp';Destination='C:\job-temp';RW=$true});NetworkSettings=[ordered]@{Networks=[ordered]@{'job-net'=[ordered]@{}};Ports=[ordered]@{}}}|ConvertTo-Json -Depth 10 -Compress)
"@echo $dockerJson" | Set-Content (Join-Path $fixture 'docker.cmd') -Encoding ASCII
$dockerScript=Join-Path $fixture 'docker.ps1'; "Write-Output '$dockerJson'" | Set-Content $dockerScript -Encoding UTF8
$env:Path="$fixture;$oldPath"
$ctx=@{RunId='run-3';JobName='job-3';JobId='job-id-3';Attempt='1';Host='host-3';Os='windows-2025';ExclusiveEndpoint='endpoint-3'}
$attestation=Join-Path $fixture 'attestation.json'; $ownerRoot=Join-Path $fixture 'owned'; New-Item $ownerRoot -ItemType Directory -Force | Out-Null; 'owner-3' | Set-Content (Join-Path $ownerRoot '.owner'); 'owned' | Set-Content (Join-Path $ownerRoot 'result.txt'); $foreign=Join-Path $fixture 'foreign.txt'; 'keep' | Set-Content $foreign
try {
    . $AdapterPath -ContractPath $ContractPath -AttestationPath $attestation -Context $ctx -ImageDigest $image -DockerCommandPath $dockerScript
    $env:AGENT_CONTAINERMAPPING='{"v22Jmeter":{"id":"bad"}}'; try { Invoke-HostAttestationProducer; throw 'substitution accepted' } catch { if ($_.Exception.Message -notmatch 'malformed|Mapping') { throw } }
    $env:AGENT_CONTAINERMAPPING='not-json'; try { Invoke-HostAttestationProducer; throw 'invalid mapping accepted' } catch { if ($_.Exception.Message -notmatch 'invalid JSON') { throw } }
    $env:AGENT_CONTAINERMAPPING='{"v22Jmeter":[{"id":"'+$id+'"}]}'; try { Invoke-HostAttestationProducer; throw 'multiple mapping accepted' } catch { if ($_.Exception.Message -notmatch 'malformed') { throw } }
    Remove-Item Env:AGENT_CONTAINERMAPPING; try { Invoke-HostAttestationProducer; throw 'absent mapping accepted' } catch { if ($_.Exception.Message -notmatch 'absent') { throw } }
    $env:AGENT_CONTAINERMAPPING='{"v22Jmeter":{"id":"'+$id+'"}}'; Invoke-HostAttestationProducer
    $missingOwner=Join-Path $fixture 'missing-owner'; New-Item $missingOwner -ItemType Directory -Force | Out-Null; 'owner-missing' | Set-Content (Join-Path $missingOwner '.owner'); $savedAttestation=$AttestationPath; $AttestationPath=Join-Path $fixture 'missing-attestation.json'
    try { Invoke-GuardedReplay { throw 'transport unexpectedly accepted' } $missingOwner 'owner-missing'; throw 'transport absent accepted' } catch { if ($_.Exception.Message -notmatch 'absent') { throw } }; $AttestationPath=$savedAttestation
    $ctx.JobName='other-job'; try { Invoke-GuardedReplay { throw 'job substitution unexpectedly accepted' } $ownerRoot 'owner-3'; throw 'job substitution accepted' } catch { if ($_.Exception.Message -notmatch 'jobName') { throw } }; $ctx.JobName='job-3'
    $a=Get-Content $attestation -Raw|ConvertFrom-Json; $a.imageDigest=$image -replace 'b','c'; $a|ConvertTo-Json -Depth 10|Set-Content (Join-Path $fixture 'wrong-digest.json'); try { Assert-HostAttestation (Join-Path $fixture 'wrong-digest.json') @{runId='run-3';jobName='job-3';jobId='job-id-3';attempt='1';containerId=$id;os='windows-2025';imageDigest=$image;host='host-3';exclusiveEndpoint='endpoint-3'}; throw 'digest substitution accepted' } catch { if ($_.Exception.Message -notmatch 'imageDigest') { throw } }
    $a=Get-Content $attestation -Raw|ConvertFrom-Json; $a.os='windows-2022'; $a|ConvertTo-Json -Depth 10|Set-Content (Join-Path $fixture 'wrong-os.json'); try { Assert-HostAttestation (Join-Path $fixture 'wrong-os.json') @{runId='run-3';jobName='job-3';jobId='job-id-3';attempt='1';containerId=$id;os='windows-2025';imageDigest=$image;host='host-3';exclusiveEndpoint='endpoint-3'}; throw 'OS substitution accepted' } catch { if ($_.Exception.Message -notmatch 'os') { throw } }
    try { Invoke-GuardedReplay { throw 'synthetic business failure' } $ownerRoot 'owner-3'; throw 'business failure was swallowed' } catch { if ($_.Exception.Message -notmatch 'synthetic business failure') { throw } }
    if (Test-Path (Join-Path $ownerRoot 'result.txt')) { throw 'owned cleanup did not run' }; if (-not (Test-Path $foreign)) { throw 'foreign object was removed' }
    $manual=Join-Path $fixture 'manual.json'; $ctx.ContainerId=$id; Invoke-HostAttestationProducer -ContainerMode manual; if (-not (Test-Path $attestation)) { throw 'manual producer did not write attestation' }
    'PASS: adapter invoked with inert inspection; mapping absent/invalid/substituted, digest/OS divergence, business failure cleanup and manual mode covered.' | Set-Content (Join-Path $EvidenceRoot 'adapter-test-result.txt')
} finally { $env:Path=$oldPath; if($null -eq $oldMapping){Remove-Item Env:AGENT_CONTAINERMAPPING -ErrorAction SilentlyContinue}else{$env:AGENT_CONTAINERMAPPING=$oldMapping} }
