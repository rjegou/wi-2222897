[CmdletBinding()]
param([Parameter(Mandatory)] [string] $ReplayRoot)

$ErrorActionPreference = 'Stop'
$validator = Join-Path $ReplayRoot 'scripts\Assert-V22IsolationAttestation.ps1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('v22-isolation-' + [guid]::NewGuid().ToString('N'))
$image = 'acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb'
$run = '4442120-FixHistorical-prewrite'
$job = 'FixHistorical'
$jobId = 'job-0001'
$attempt = '1'
$containerId = '0123456789abcdef'
$hostName = 'V22-JOB-HOST'
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $policy = [ordered]@{
        schema = 'v22-isolation-policy-1'; scopeId = "$run/$job"
        allowedMounts = @([ordered]@{ source = 'C:\agent\temp'; destination = 'C:\agent\temp'; readOnly = $false })
        allowedNetworks = @([ordered]@{ name = 'job-net'; id = 'net-001' })
        allowedPorts = @([ordered]@{ host = 18080; container = 80; protocol = 'tcp' }, [ordered]@{ host = 11433; container = 1433; protocol = 'tcp' })
    }
    $attestation = [ordered]@{
        schema = 'v22-isolation-attestation-1'; producer = 'host'; runId = $run; jobName = $job; jobId = $jobId; attemptId = $attempt; collectedUtc = [DateTimeOffset]::UtcNow.ToString('o'); scopeId = "$run/$job"
        containerId = $containerId; image = $image; destinationHost = $hostName; sqlHost = $hostName; iisHost = $hostName
        mounts = $policy.allowedMounts; networks = $policy.allowedNetworks; ports = $policy.allowedPorts
    }
    $policyPath = Join-Path $fixture 'policy.json'; $attestationPath = Join-Path $fixture 'attestation.json'
    $policy | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $policyPath -Encoding UTF8
    $attestation | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $attestationPath -Encoding UTF8
    & $validator -AttestationPath $attestationPath -PolicyPath $policyPath -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedContainerId $containerId -ExpectedImage $image -ExpectedDestinationHost $hostName
    $bad = $attestation | ConvertTo-Json -Depth 8 | ConvertFrom-Json
    $bad.mounts[0].destination = 'C:\shared'
    $badPath = Join-Path $fixture 'bad-mount.json'; $bad | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $badPath -Encoding UTF8
    try { & $validator -AttestationPath $badPath -PolicyPath $policyPath -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedContainerId $containerId -ExpectedImage $image -ExpectedDestinationHost $hostName; throw 'Unauthorized mount unexpectedly passed.' } catch { if ($_.Exception.Message -notmatch 'Mount is not explicitly allowed') { throw } }
    $badArray = Join-Path $fixture 'bad-array.json'; '[]' | Set-Content -LiteralPath $badArray -Encoding UTF8
    try { & $validator -AttestationPath $badArray -PolicyPath $policyPath -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedContainerId $containerId -ExpectedImage $image -ExpectedDestinationHost $hostName; throw 'Array attestation unexpectedly passed.' } catch { if ($_.Exception.Message -notmatch 'must be a JSON object') { throw } }
    foreach($case in @(
        @{ name='stale'; mutate={param($x) $x.collectedUtc = [DateTimeOffset]::UtcNow.AddMinutes(-20).ToString('o')}; expected='outside freshness window' },
        @{ name='future'; mutate={param($x) $x.collectedUtc = [DateTimeOffset]::UtcNow.AddMinutes(3).ToString('o')}; expected='outside freshness window' },
        @{ name='other-attempt'; mutate={param($x) $x.attemptId = '2'}; expected='different run, job or attempt' },
        @{ name='other-container'; mutate={param($x) $x.containerId = 'abcdef0123456789'}; expected='different container' },
        @{ name='other-run'; mutate={param($x) $x.runId = '4442121-FixHistorical-prewrite'}; expected='different run, job or attempt' },
        @{ name='other-job'; mutate={param($x) $x.jobName = 'FixCandidate'}; expected='different run, job or attempt' }
    )) {
        $variant = $attestation | ConvertTo-Json -Depth 8 | ConvertFrom-Json
        & $case.mutate $variant
        $variantPath = Join-Path $fixture "$($case.name).json"; $variant | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $variantPath -Encoding UTF8
        try { & $validator -AttestationPath $variantPath -PolicyPath $policyPath -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedContainerId $containerId -ExpectedImage $image -ExpectedDestinationHost $hostName; throw "$($case.name) unexpectedly passed." } catch { if($_.Exception.Message -notmatch $case.expected){throw} }
    }
    $missingPath = Join-Path $fixture 'missing.json'
    try { & $validator -AttestationPath $missingPath -PolicyPath $policyPath -ExpectedRunId $run -ExpectedJobName $job -ExpectedJobId $jobId -ExpectedAttempt $attempt -ExpectedContainerId $containerId -ExpectedImage $image -ExpectedDestinationHost $hostName; throw 'Missing attestation unexpectedly passed.' } catch { if($_.Exception.Message -notmatch 'missing or unresolved'){throw} }
    Write-Host 'ISOLATION-ATTESTATION PASS: valid, stale, future, attempt, container and missing-file cases checked.'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
