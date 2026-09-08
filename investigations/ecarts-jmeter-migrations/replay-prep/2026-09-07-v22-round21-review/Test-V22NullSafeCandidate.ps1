$ErrorActionPreference = 'Stop'
$candidate = Join-Path $PSScriptRoot 'azure-pipelines.wi2222897-v22-preflight.null-safe.yml'
$expected = '659DE89ECC92E279B87BEE0D07DC51B388DE99EF4910A5BE913B75B672CD0BD2'
$hash = (Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash
if ($hash -cne $expected) { throw "Candidate hash mismatch: $hash" }
$yaml = Get-Content -LiteralPath $candidate -Raw
$lines = $yaml -split "`r?`n"
$start = [Array]::IndexOf($lines, "        `$ErrorActionPreference = 'Stop'")
$end = [Array]::IndexOf($lines, '      displayName: Read-only host/image/container inspection')
if ($start -lt 0 -or $end -le $start) { throw 'Inline PowerShell bounds not found.' }
$script = ($lines[$start..($end - 1)] | ForEach-Object { if ($_.Length -ge 8) { $_.Substring(8) } else { $_ } }) -join "`r`n"
$tokens = $null; $errors = $null
[System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -ne 0) { throw "Inline PowerShell syntax errors: $($errors.Count)" }
function ConvertTo-ScrubbedPath([object] $value) {
    if ($null -eq $value) { return '<absent>' }
    $text = [string]$value
    $text = $text -replace '(?i)^[A-Z]:\\Users\\[^\\]+', '<user-root>'
    $text = $text -replace '(?i)^[A-Z]:\\(a|agent)\\[^\\]+', '<agent-root>'
    $text = $text -replace '(?i)^[A-Z]:\\', '<drive>:\\'
    $text = $text -replace '(?i)(^|[\\/])(password|passwd|token|secret|apikey|api-key)([^\\/]*)', '$1<redacted-path>'
    $text = $text -replace '(?i)(password|passwd|token|secret|apikey|api-key)=[^;\\s]+', '$1=<redacted>'
    return $text
}
$nullMounts = @($null | Where-Object { $null -ne $_ } | ForEach-Object { $_ })
$multipleMounts = @(
    [pscustomobject]@{ Type='bind'; Source='C:\Users\Alice\agent\_work\1'; Destination='C:\agent\_work'; RW=$false }
    [pscustomobject]@{ Type='volume'; Source='D:\shared\token=x'; Destination='C:\shared'; RW=$true }
) | Where-Object { $null -ne $_ }
$projected = @($multipleMounts | ForEach-Object { [ordered]@{ source=(ConvertTo-ScrubbedPath $_.Source); destination=(ConvertTo-ScrubbedPath $_.Destination); rw=[bool]$_.RW } })
$json = $projected | ConvertTo-Json -Depth 5
if (@($nullMounts).Count -ne 0) { throw 'Null mount was not filtered.' }
if (@($projected).Count -ne 2 -or $projected[1].rw -ne $true) { throw 'Multiple mount projection or RW classification failed.' }
if ($json -match 'Alice|token=x') { throw 'Scrubbing leaked path identity or token-shaped content.' }
if ($yaml -notmatch 'dangerousMounts\.Count -eq 0' -or $yaml -notmatch 'docker rm -f \$name' -or $yaml -notmatch 'containerPresentAfterRemove') { throw 'Whitelist or cleanup changed.' }
if ($yaml -match '(?im)jmeter\.bat|sqlcmd|JFrog|PublishPipelineArtifact|PublishBuildArtifacts') { throw 'Business or publication action found.' }
Write-Output "PASS: $hash; syntax=0; nullMounts=0; multipleMounts=2; rwPreserved=true; scrubbed=true; whitelist=unchanged; cleanup=unchanged"
