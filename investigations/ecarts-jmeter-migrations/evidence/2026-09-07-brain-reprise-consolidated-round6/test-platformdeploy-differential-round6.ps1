$ErrorActionPreference = 'Stop'

$sourceWorktree = Join-Path $PSScriptRoot '..\..\..\..\worktrees\Y2_Tools_PlatformDeploy'
$sourceWrapper = Join-Path $sourceWorktree 'Src\Powershell\Code\docker-pipeline-deploy.ps1'

$tempRoot = Join-Path $env:TEMP ('wi2222897-platformdeploy-diff-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
try {
    # This is the real outer wrapper. The inner script is an inert fixture for
    # the exact init-container boundary: original absorbs a non-zero child
    # status under TF_BUILD, corrected throws; exceptions remain non-zero.
    Copy-Item -LiteralPath $sourceWrapper -Destination (Join-Path $tempRoot 'docker-pipeline-deploy.ps1')
    @'
param([string]$deployConfig, [string]$RetailJfrogApiKey, [string]$LocalDBInContainer, [switch]$verbose)
& .\deploy-child.ps1
if ($env:WI2222897_VARIANT -eq 'corrected') {
  $deploymentExitCode = $LASTEXITCODE
  if ($deploymentExitCode -ne 0) { throw "Deployment failed with exit code $deploymentExitCode" }
}
'@ | Set-Content -LiteralPath (Join-Path $tempRoot 'docker-pipeline-deploy-ps7.ps1') -Encoding utf8
    @'
switch ($env:WI2222897_CHILD_MODE) {
  '0' { exit 0 }
  '7' { exit 7 }
  'throw' { throw 'synthetic child exception' }
  default { throw 'missing test mode' }
}
'@ | Set-Content -LiteralPath (Join-Path $tempRoot 'deploy-child.ps1') -Encoding utf8

    $powershell = (Get-Command powershell.exe).Source
    $cases = @()
    foreach ($variant in @('original','corrected')) {
        foreach ($mode in @('0','7','throw')) {
            $psi = [Diagnostics.ProcessStartInfo]::new()
            $psi.FileName = $powershell
            $psi.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $tempRoot 'docker-pipeline-deploy.ps1') + '" -RetailJfrogApiKey inert -verbose'
            $psi.WorkingDirectory = $tempRoot
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.Environment['TF_BUILD'] = 'true'
            $psi.Environment['WI2222897_VARIANT'] = $variant
            $psi.Environment['WI2222897_CHILD_MODE'] = $mode
            $p = [Diagnostics.Process]::new()
            $p.StartInfo = $psi
            [void]$p.Start()
            $stdout = $p.StandardOutput.ReadToEnd()
            $stderr = $p.StandardError.ReadToEnd()
            $p.WaitForExit()
            $expected = if ($mode -eq '0') { 0 } elseif ($mode -eq 'throw') { 1 } elseif ($variant -eq 'original') { 0 } else { 1 }
            $cases += [pscustomobject]@{
                variant = $variant
                mode = $mode
                tfBuild = $psi.Environment['TF_BUILD']
                exitCode = $p.ExitCode
                expectedExitCode = $expected
                pass = ($p.ExitCode -eq $expected)
                exceptionObserved = (($stdout + $stderr) -match 'synthetic child exception')
            }
            $p.Dispose()
        }
    }
    $result = [pscustomobject]@{
        wrapper = 'docker-pipeline-deploy.ps1 from source worktree'
        tfBuild = 'true'
        cases = $cases
        allPassed = (@($cases | Where-Object { -not $_.pass }).Count -eq 0)
    }
    $result | ConvertTo-Json -Depth 6 -Compress
    if (-not $result.allPassed) { exit 2 }
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
