$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$cases = @(
    @{ Name = 'success'; Script = 'child-success.ps1'; ExpectedExit = 0; ExpectedGuard = 'pass' },
    @{ Name = 'nonzero'; Script = 'child-exit.ps1'; ExpectedExit = 7; ExpectedGuard = 'throw' },
    @{ Name = 'exception'; Script = 'child-throw.ps1'; ExpectedExit = $null; ExpectedGuard = 'throw' },
    @{ Name = 'no-native-exit-after-residual-9'; Script = 'child-noexit.ps1'; ExpectedExit = 9; ExpectedGuard = 'throw' }
)
$results = foreach ($case in $cases) {
    $global:LASTEXITCODE = 9
    $observedException = $false
    $message = ''
    try {
        $null = & (Join-Path $root $case.Script)
        $observedExit = $LASTEXITCODE
        if ($observedExit -ne 0) { throw "Deployment failed with exit code $observedExit" }
    }
    catch {
        $observedException = $true
        $message = $_.Exception.Message
        $observedExit = $LASTEXITCODE
    }
    [pscustomobject]@{
        case = $case.Name
        observedExit = $observedExit
        exception = $observedException
        expectedExit = $case.ExpectedExit
        expectedGuard = $case.ExpectedGuard
        pass = if ($case.Name -eq 'exception') { $observedException } else { ($observedExit -eq $case.ExpectedExit -and $observedException -eq ($case.ExpectedGuard -eq 'throw')) }
        message = $message
    }
}
$results | ConvertTo-Json -Compress
if (($results | Where-Object { -not $_.pass }).Count -gt 0) { exit 1 }
