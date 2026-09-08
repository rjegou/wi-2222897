$ErrorActionPreference = 'Stop'

$typeDefinition = @'
using System;
using System.Text.RegularExpressions;

public static class EscapeJdbcDateHarness
{
    public static string EscapeJdbcDate(string query)
    {
        // fix date 
        query = Regex.Replace(query, @"'(\d{4})-(\d{2})-(\d{2})'", "'${1}${3}${2}'");

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
    [pscustomobject]@{ Input = "'2026-04-28'"; Expected = "'20260428'" },
    [pscustomobject]@{ Input = "'2026-04-05'"; Expected = "'20260405'" },
    [pscustomobject]@{ Input = "'20260428'"; Expected = "'20260428'" },
    [pscustomobject]@{ Input = "'2026/04/28'"; Expected = "'2026/04/28'" }
)

$results = foreach ($case in $cases) {
    $actual = [EscapeJdbcDateHarness]::EscapeJdbcDate($case.Input)
    [pscustomobject]@{
        Input = $case.Input
        Expected = $case.Expected
        Obtained = $actual
        Verdict = if ($actual -ceq $case.Expected) { 'PASS' } else { 'FAIL' }
    }
}

$results | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.json') -Encoding UTF8
$results | Format-Table -AutoSize | Out-String | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'results.txt') -Encoding UTF8
$results | Format-Table -AutoSize
