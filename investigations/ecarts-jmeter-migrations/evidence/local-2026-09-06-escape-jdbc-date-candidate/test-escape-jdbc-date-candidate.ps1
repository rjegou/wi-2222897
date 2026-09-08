$ErrorActionPreference = 'Stop'

$typeDefinition = @'
using System;
using System.Text.RegularExpressions;

public static class EscapeJdbcDateCandidateHarness
{
    public static string Original(string query)
    {
        // fix date 
        query = Regex.Replace(query, @"'(\d{4})-(\d{2})-(\d{2})'", "'${1}${3}${2}'");

        // fix date  (yyyy-mm-ddThh:mm:ss(.sss))  time with simple quote
        query = Regex.Replace(query, @"(?<![\w'])\b(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?)\b(?![\w'])", "'$1'");

        // fix date without '
        query = Regex.Replace(query, @"(?<![\w'])\b(\d{4})-(\d{2})-(\d{2})\b(?![\w'])", "'${1}${2}${3}'");

        return query;
    }

    public static string Candidate(string query)
    {
        // fix date 
        query = Regex.Replace(query, @"'(\d{4})-(\d{2})-(\d{2})'", "'${1}${2}${3}'");

        // fix date  (yyyy-mm-ddThh:mm:ss(.sss))  time with simple quote
        query = Regex.Replace(query, @"(?<![\w'])\b(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?)\b(?![\w'])", "'$1'");

        // fix date without '
        query = Regex.Replace(query, @"(?<![\w'])\b(\d{4})-(\d{2})-(\d{2})\b(?![\w'])", "'${1}${2}${3}'");

        return query;
    }
}
'@

Add-Type -TypeDefinition $typeDefinition -Language CSharp

$cases = @(
    [pscustomobject]@{ Name = 'ISO apostrophée'; Input = "'2026-04-28'"; ExpectedCandidate = "'20260428'"; MustPreserveOriginal = $false },
    [pscustomobject]@{ Name = 'Date ambiguë'; Input = "'2026-04-05'"; ExpectedCandidate = "'20260405'"; MustPreserveOriginal = $false },
    [pscustomobject]@{ Name = 'Date compacte'; Input = "'20260428'"; ExpectedCandidate = "'20260428'"; MustPreserveOriginal = $true },
    [pscustomobject]@{ Name = 'Motif hors date'; Input = "'2026/04/28'"; ExpectedCandidate = "'2026/04/28'"; MustPreserveOriginal = $true },
    [pscustomobject]@{ Name = 'Date bissextile'; Input = "'2024-02-29'"; ExpectedCandidate = "'20240229'"; MustPreserveOriginal = $false },
    [pscustomobject]@{ Name = 'Deux dates SQL'; Input = "SELECT '2026-04-28', '2026-04-05'"; ExpectedCandidate = "SELECT '20260428', '20260405'"; MustPreserveOriginal = $false },
    [pscustomobject]@{ Name = 'Texte sans date'; Input = "SELECT 'no date here'"; ExpectedCandidate = "SELECT 'no date here'"; MustPreserveOriginal = $true },
    [pscustomobject]@{ Name = 'ISO sans apostrophes'; Input = '2026-04-28'; ExpectedCandidate = $null; MustPreserveOriginal = $true },
    [pscustomobject]@{ Name = 'Date-heure'; Input = '2026-04-28T12:34:56'; ExpectedCandidate = $null; MustPreserveOriginal = $true }
)

$results = foreach ($case in $cases) {
    $original = [EscapeJdbcDateCandidateHarness]::Original($case.Input)
    $candidate = [EscapeJdbcDateCandidateHarness]::Candidate($case.Input)
    $expected = if ($case.MustPreserveOriginal) { $original } else { $case.ExpectedCandidate }
    $passed = if ($case.MustPreserveOriginal) { $candidate -ceq $original } else { $candidate -ceq $expected }
    [pscustomobject]@{
        Name = $case.Name
        Input = $case.Input
        ExpectedCandidate = $expected
        Original = $original
        Candidate = $candidate
        Behavior = if ($case.MustPreserveOriginal) { 'Candidate must equal original' } else { 'Candidate corrected only' }
        Verdict = if ($passed) { 'PASS' } else { 'FAIL' }
    }
}

$failures = @($results | Where-Object Verdict -eq 'FAIL')
$exitCode = if ($failures.Count -eq 0) { 0 } else { 1 }
$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.json') -Encoding UTF8
$results | Format-Table -AutoSize | Out-String | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.txt') -Encoding UTF8
$exitCode | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'exit-code.txt') -Encoding ASCII
$results | Format-Table -AutoSize
Write-Output ("ExitCode={0}" -f $exitCode)
exit $exitCode
