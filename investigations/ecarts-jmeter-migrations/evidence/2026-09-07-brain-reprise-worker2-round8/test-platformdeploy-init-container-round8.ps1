$ErrorActionPreference = 'Stop'

$sourceWorktree = Join-Path $PSScriptRoot '..\..\..\..\worktrees\Y2_Tools_PlatformDeploy'
$correctedWorktree = Join-Path $PSScriptRoot '..\..\..\..\worktrees\Y2_Tools_PlatformDeploy_worker3_r5b'
$sourceInit = Join-Path $sourceWorktree 'Src\Powershell\Code\Scripts\init-container.ps1'
$correctedInit = Join-Path $correctedWorktree 'Src\Powershell\Code\Scripts\init-container.ps1'
$sourceModules = Join-Path $sourceWorktree 'Src\Powershell\Code\Scripts\Modules'
$correctedModules = Join-Path $correctedWorktree 'Src\Powershell\Code\Scripts\Modules'

foreach ($path in @($sourceInit, $correctedInit, $sourceModules, $correctedModules)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing required path: $path" }
}

$sourceHash = (Get-FileHash -LiteralPath $sourceInit -Algorithm SHA256).Hash
$correctedHash = (Get-FileHash -LiteralPath $correctedInit -Algorithm SHA256).Hash
$tempRoot = Join-Path $env:TEMP ('wi2222897-init-container-round8-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    $results = @()
    foreach ($variant in @(
        [pscustomobject]@{ Name = 'original'; Init = $sourceInit; Modules = $sourceModules; Hash = $sourceHash },
        [pscustomobject]@{ Name = 'corrected'; Init = $correctedInit; Modules = $correctedModules; Hash = $correctedHash }
    )) {
        foreach ($mode in @('0', '7', 'throw')) {
            $caseRoot = Join-Path $tempRoot ($variant.Name + '-' + $mode)
            $caseScripts = Join-Path $caseRoot 'Scripts'
            $caseModules = Join-Path $caseScripts 'Modules'
            New-Item -ItemType Directory -Path $caseModules -Force | Out-Null
            Copy-Item -LiteralPath $variant.Init -Destination (Join-Path $caseScripts 'init-container.ps1')
            Get-ChildItem -LiteralPath $variant.Modules | Copy-Item -Destination $caseModules -Recurse -Force

            # External preflight boundary only; init-container.ps1 itself is unchanged.
            @'
Write-Output 'round8 inert check-prerequisites boundary'
exit 0
'@ | Set-Content -LiteralPath (Join-Path $caseScripts 'check-prerequisites.ps1') -Encoding utf8

            # External deployment boundary only; record exact child outcome then return/throw.
            @'
$resultPath = $env:WI2222897_CHILD_RESULT
$mode = $env:WI2222897_CHILD_MODE
if ($mode -eq '0') {
    [pscustomobject]@{ mode = $mode; childExitCode = 0; childException = $false } | ConvertTo-Json -Compress | Set-Content -LiteralPath $resultPath
    exit 0
}
if ($mode -eq '7') {
    [pscustomobject]@{ mode = $mode; childExitCode = 7; childException = $false } | ConvertTo-Json -Compress | Set-Content -LiteralPath $resultPath
    exit 7
}
[pscustomobject]@{ mode = $mode; childExitCode = $null; childException = $true } | ConvertTo-Json -Compress | Set-Content -LiteralPath $resultPath
throw 'round8 synthetic deploy child exception'
'@ | Set-Content -LiteralPath (Join-Path $caseRoot 'deploy.ps1') -Encoding utf8

            @'
<configuration><hosts><host name="__CONTAINER_HOST__" /></hosts><databases /></configuration>
'@ | Set-Content -LiteralPath (Join-Path $caseRoot 'config.cy2px') -Encoding utf8
            $childResult = Join-Path $caseRoot 'child-result.json'

            $psi = [Diagnostics.ProcessStartInfo]::new()
            $psi.FileName = (Get-Command pwsh.exe).Source
            $psi.Arguments = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + (Join-Path $caseScripts 'init-container.ps1') + '" -coreVersion 26.0.0 -dockerCy2px "' + (Join-Path $caseRoot 'config.cy2px') + '" -localDBMode None -verbose'
            $psi.WorkingDirectory = $caseRoot
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.Environment['TF_BUILD'] = 'true'
            $psi.Environment['WI2222897_CHILD_MODE'] = $mode
            $psi.Environment['WI2222897_CHILD_RESULT'] = $childResult
            $p = [Diagnostics.Process]::new()
            $p.StartInfo = $psi
            [void]$p.Start()
            $stdout = $p.StandardOutput.ReadToEnd()
            $stderr = $p.StandardError.ReadToEnd()
            $p.WaitForExit()
            $child = if (Test-Path -LiteralPath $childResult) { Get-Content -LiteralPath $childResult -Raw | ConvertFrom-Json } else { $null }
            $results += [pscustomobject]@{
                variant = $variant.Name
                initHash = $variant.Hash
                mode = $mode
                tfBuild = 'true'
                childExitCode = if ($null -eq $child) { $null } else { $child.childExitCode }
                childException = if ($null -eq $child) { $null } else { [bool]$child.childException }
                exceptionObserved = (($stdout + $stderr) -match 'round8 synthetic deploy child exception|Deployment failed with exit code')
                processExitCode = $p.ExitCode
                stderrTail = (($stderr -split "`r?`n" | Where-Object { $_ } | Select-Object -Last 2) -join ' | ')
            }
            $p.Dispose()
        }
    }
    [pscustomobject]@{
        sourceInit = $sourceInit
        correctedInit = $correctedInit
        sourceHash = $sourceHash
        correctedHash = $correctedHash
        sameInputs = $true
        realInitContainerInvoked = $true
        externalSubstitutions = @('check-prerequisites.ps1', 'deploy.ps1')
        dockerMsiSqlIisUsed = $false
        cases = $results
    } | ConvertTo-Json -Depth 8 -Compress
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
