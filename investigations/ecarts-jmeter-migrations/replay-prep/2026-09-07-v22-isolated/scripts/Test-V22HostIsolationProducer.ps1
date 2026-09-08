[CmdletBinding()]
param([Parameter(Mandatory)] [string] $ReplayRoot)

$ErrorActionPreference = 'Stop'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('v22-host-producer-' + [guid]::NewGuid().ToString('N'))
$oldPath = $env:Path
$image = 'acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb'
$id = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
$run = '4442120-FixHistorical-prewrite'; $job = 'FixHistorical'; $jobId = 'job-0001'; $hostName = 'V22-JOB-HOST'
$attempt = '1'
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $inspect = [ordered]@{
        Id = $id; State = [ordered]@{ Running = $true }; RepoDigests = @($image); Config = [ordered]@{ Hostname = $hostName }
        Mounts = @(
            [ordered]@{ Source = 'C:\agent\_work\1'; Destination = 'C:\__w\1'; RW = $true },
            [ordered]@{ Source = 'C:\agent\_work\_tool'; Destination = 'C:\__t'; RW = $true },
            [ordered]@{ Source = 'C:\agent\externals'; Destination = 'C:\__a\externals'; RW = $false }
        )
        NetworkSettings = [ordered]@{ Networks = [ordered]@{ 'vsts_network_abcdef' = [ordered]@{ NetworkID = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' } }; Ports = [ordered]@{} }
    }
    $dockerJson = ($inspect | ConvertTo-Json -Depth 10 -Compress)
    "@echo $dockerJson" | Set-Content -LiteralPath (Join-Path $fixture 'docker.cmd') -Encoding ASCII
    $hostPath = (($oldPath -split ';') | Where-Object { $_ -notmatch '(?i)Docker' }) -join ';'
    $env:Path = "$fixture;$hostPath"
    $policyPath = Join-Path $ReplayRoot 'V22-ISOLATION-POLICY.json'
    $mapping = '{"v22Jmeter":{"id":"' + $id + '"}}'
    $output = Join-Path $fixture 'attestation.json'
    & (Join-Path $ReplayRoot 'scripts\Write-V22HostIsolationAttestation.ps1') -ContainerMappingJson $mapping -ContainerResourceName v22Jmeter -ExpectedContainerId $id -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedImage $image -PolicyPath $policyPath -OutputPath $output -ValidatorPath (Join-Path $ReplayRoot 'scripts\Assert-V22IsolationAttestation.ps1')
    if (-not (Test-Path -LiteralPath $output -PathType Leaf)) { throw 'Host producer did not write the attestation.' }
    $inspect.Mounts = @($inspect.Mounts) + [ordered]@{ Source = '\\.\pipe\docker_engine'; Destination = '\\.\pipe\docker_engine'; RW = $true }
    ($inspect | ConvertTo-Json -Depth 10 -Compress) | ForEach-Object { "@echo $_" | Set-Content -LiteralPath (Join-Path $fixture 'docker.cmd') -Encoding ASCII }
    try { & (Join-Path $ReplayRoot 'scripts\Write-V22HostIsolationAttestation.ps1') -ContainerMappingJson $mapping -ContainerResourceName v22Jmeter -ExpectedContainerId $id -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedImage $image -PolicyPath $policyPath -OutputPath (Join-Path $fixture 'forbidden.json') -ValidatorPath (Join-Path $ReplayRoot 'scripts\Assert-V22IsolationAttestation.ps1'); throw 'Forbidden Docker mount unexpectedly passed.' } catch { if ($_.Exception.Message -notmatch 'Host mount does not match policy|Forbidden shared mount') { throw } }
    $badMapping = '{"v22Jmeter":{"id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}}'
    try { & (Join-Path $ReplayRoot 'scripts\Write-V22HostIsolationAttestation.ps1') -ContainerMappingJson $badMapping -ContainerResourceName v22Jmeter -ExpectedContainerId $id -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedImage $image -PolicyPath $policyPath -OutputPath (Join-Path $fixture 'bad.json') -ValidatorPath (Join-Path $ReplayRoot 'scripts\Assert-V22IsolationAttestation.ps1'); throw 'Mismatched mapping unexpectedly passed.' } catch { if ($_.Exception.Message -notmatch 'Mapping and Agent.ContainerId disagree') { throw } }
    Write-Host 'HOST-PRODUCER PASS: exact mapped container extracted; mismatched mapping refused.'
} finally {
    $env:Path = $oldPath
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
