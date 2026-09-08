$ErrorActionPreference = 'Stop'

$worktree = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..\worktrees\Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE')
$sourcePath = Join-Path $worktree 'Cegid.Retail.AutoTest.Api\JmeterCodeGen.cs'
$source = Get-Content -LiteralPath $sourcePath -Raw

function Find-MatchingBrace([string] $text, [int] $openIndex) {
    $depth = 0
    $state = 'code'
    for ($i = $openIndex; $i -lt $text.Length; $i++) {
        $ch = $text[$i]
        $next = if ($i + 1 -lt $text.Length) { $text[$i + 1] } else { [char]0 }
        if ($state -eq 'lineComment') {
            if ($ch -eq "`n") { $state = 'code' }
            continue
        }
        if ($state -eq 'blockComment') {
            if ($ch -eq '*' -and $next -eq '/') { $state = 'code'; $i++ }
            continue
        }
        if ($state -eq 'string') {
            if ($ch -eq '\') { $i++ } elseif ($ch -eq '"') { $state = 'code' }
            continue
        }
        if ($state -eq 'verbatimString') {
            if ($ch -eq '"' -and $next -eq '"') { $i++ } elseif ($ch -eq '"') { $state = 'code' }
            continue
        }
        if ($state -eq 'char') {
            if ($ch -eq '\') { $i++ } elseif ($ch -eq "'") { $state = 'code' }
            continue
        }
        if ($ch -eq '/' -and $next -eq '/') { $state = 'lineComment'; $i++; continue }
        if ($ch -eq '/' -and $next -eq '*') { $state = 'blockComment'; $i++; continue }
        if ($ch -eq '@' -and $next -eq '"') { $state = 'verbatimString'; $i++; continue }
        if ($ch -eq '"') { $state = 'string'; continue }
        if ($ch -eq "'") { $state = 'char'; continue }
        if ($ch -eq '{') { $depth++ }
        if ($ch -eq '}') {
            $depth--
            if ($depth -eq 0) { return $i }
            if ($depth -lt 0) { throw 'Brace balance became negative.' }
        }
    }
    throw 'No matching closing brace found.'
}

$signature = '(?m)^\s*private\s+static\s+string\s+EscapeJdbcDate\s*\(\s*string\s+query\s*\)\s*\{'
$matches = [regex]::Matches($source, $signature)
if ($matches.Count -ne 1) { throw "Expected exactly one EscapeJdbcDate signature; found $($matches.Count)." }
$match = $matches[0]
$openIndex = $source.IndexOf('{', $match.Index)
$closeIndex = Find-MatchingBrace $source $openIndex
$methodText = $source.Substring($match.Index, $closeIndex - $match.Index + 1)
$publicMethod = [regex]::Replace($methodText, '\bprivate\s+static\s+string\s+EscapeJdbcDate\b', 'public static string EscapeJdbcDate', 1)
if ($publicMethod -eq $methodText) { throw 'The private access modifier was not found exactly once.' }

$typeDefinition = "using System;`nusing System.Text.RegularExpressions;`n`npublic static class ExtractedEscapeJdbcDateHarness`n{`n$publicMethod`n}`n"
Add-Type -TypeDefinition $typeDefinition -Language CSharp

$cases = @(
    [pscustomobject]@{ Name = 'ISO apostrophée'; Input = "'2026-04-28'"; Expected = "'20260428'" },
    [pscustomobject]@{ Name = 'Date ambiguë'; Input = "'2026-04-05'"; Expected = "'20260405'" },
    [pscustomobject]@{ Name = 'Date compacte'; Input = "'20260428'"; Expected = "'20260428'" },
    [pscustomobject]@{ Name = 'Motif hors date'; Input = "'2026/04/28'"; Expected = "'2026/04/28'" },
    [pscustomobject]@{ Name = 'Date bissextile'; Input = "'2024-02-29'"; Expected = "'20240229'" },
    [pscustomobject]@{ Name = 'Deux dates SQL'; Input = "SELECT '2026-04-28', '2026-04-05'"; Expected = "SELECT '20260428', '20260405'" },
    [pscustomobject]@{ Name = 'Texte sans date'; Input = "SELECT 'no date here'"; Expected = "SELECT 'no date here'" },
    [pscustomobject]@{ Name = 'ISO sans apostrophes'; Input = '2026-04-28'; Expected = "'20260428'" },
    [pscustomobject]@{ Name = 'Date-heure'; Input = '2026-04-28T12:34:56'; Expected = "'2026-04-28T12:34:56'" }
)

$results = foreach ($case in $cases) {
    $actual = [ExtractedEscapeJdbcDateHarness]::EscapeJdbcDate($case.Input)
    [pscustomobject]@{
        Name = $case.Name
        Input = $case.Input
        Expected = $case.Expected
        Obtained = $actual
        Verdict = if ($actual -ceq $case.Expected) { 'PASS' } else { 'FAIL' }
    }
}

$failures = @($results | Where-Object Verdict -eq 'FAIL')
$exitCode = if ($failures.Count -eq 0) { 0 } else { 1 }
(Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'source-sha256.txt') -Encoding ASCII
$results | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.json') -Encoding UTF8
$results | Format-Table -AutoSize | Out-String | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.txt') -Encoding UTF8
$exitCode | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'exit-code.txt') -Encoding ASCII
$results | Format-Table -AutoSize
Write-Output ("ExitCode={0}" -f $exitCode)
exit $exitCode
