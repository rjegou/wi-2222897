param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$Args -join "`n" | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'invocation.args') -Encoding UTF8
exit 0
