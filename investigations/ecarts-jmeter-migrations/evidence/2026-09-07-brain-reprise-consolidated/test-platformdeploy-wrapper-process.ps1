$ErrorActionPreference = 'Stop'

$sourceWorktree = Join-Path $PSScriptRoot '..\..\..\..\worktrees\Y2_Tools_PlatformDeploy'
$isolatedWorktree = Join-Path $PSScriptRoot '..\..\..\..\worktrees\Y2_Tools_PlatformDeploy_worker3_r5b'
$sourceInit = Join-Path $sourceWorktree 'Src\Powershell\Code\Scripts\init-container.ps1'
$isolatedInit = Join-Path $isolatedWorktree 'Src\Powershell\Code\Scripts\init-container.ps1'
$sourceWrapper = Join-Path $sourceWorktree 'Src\Powershell\Code\docker-pipeline-deploy.ps1'

$tempRoot = Join-Path $env:TEMP ('wi2222897-platformdeploy-wrapper-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
try {
    Copy-Item -LiteralPath $sourceWrapper -Destination (Join-Path $tempRoot 'docker-pipeline-deploy.ps1')
    @'
param([string]$deployConfig, [string]$RetailJfrogApiKey, [string]$LocalDBInContainer, [switch]$verbose)
switch ($env:WI2222897_FAKE_CHILD_MODE) {
  '0' { exit 0 }
  '7' { exit 7 }
  'throw' { throw 'synthetic child exception' }
  default { throw 'missing test mode' }
}
'@ | Set-Content -LiteralPath (Join-Path $tempRoot 'docker-pipeline-deploy-ps7.ps1') -Encoding utf8

    $powershell = (Get-Command powershell.exe).Source
    $cases = @()
    foreach ($mode in @('0','7','throw')) {
        $psi = [Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $powershell
        $psi.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $tempRoot 'docker-pipeline-deploy.ps1') + '" -RetailJfrogApiKey inert -verbose'
        $psi.WorkingDirectory = $tempRoot
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $p = [Diagnostics.Process]::new()
        $p.StartInfo = $psi
        $p.StartInfo.Environment['WI2222897_FAKE_CHILD_MODE'] = $mode
        [void]$p.Start()
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        $cases += [pscustomobject]@{ mode = $mode; exitCode = $p.ExitCode; outputContainsSynthetic = (($stdout + $stderr) -match 'synthetic child exception') }
        $p.Dispose()
    }

    [pscustomobject]@{
        beforeGuardPresent = ((Get-Content -LiteralPath $sourceInit -Raw) -match '\$deploymentExitCode')
        afterGuardPresent = ((Get-Content -LiteralPath $isolatedInit -Raw) -match '\$deploymentExitCode')
        realWrapperProcessCases = $cases
    } | ConvertTo-Json -Depth 5 -Compress
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
