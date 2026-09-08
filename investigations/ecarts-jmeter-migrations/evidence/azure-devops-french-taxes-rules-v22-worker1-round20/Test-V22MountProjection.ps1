$ErrorActionPreference = 'Stop'
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
$image = [pscustomobject]@{ Config = [pscustomobject]@{ Volumes = [pscustomobject]@{ 'C:\ProgramData\agent' = $null; 'C:\Users\Alice\secret-cache' = $null } } }
$inspection = [pscustomobject]@{ Mounts = @(
    [pscustomobject]@{ Type='bind'; Source='C:\Users\Alice\agent\_work\1'; Destination='C:\agent\_work'; RW=$false },
    [pscustomobject]@{ Type='bind'; Source='D:\shared\token=hidden'; Destination='C:\shared'; RW=$true }
) }
$configVolumes = @($image.Config.Volumes.PSObject.Properties | ForEach-Object { [ordered]@{name=(ConvertTo-ScrubbedPath $_.Name)} })
$name = 'wi2222897-v22-preflight-4442225'
$scrubbedMounts = @($inspection.Mounts | ForEach-Object { [ordered]@{name=$name;type=$_.Type;source=(ConvertTo-ScrubbedPath $_.Source);destination=(ConvertTo-ScrubbedPath $_.Destination);rw=[bool]$_.RW} })
$dangerous = @($inspection.Mounts | Where-Object { $_.Destination -notmatch '(?i)(agent|work|programdata|windows)' -or $_.RW -eq $true })
$json = [ordered]@{ image=[ordered]@{configVolumes=$configVolumes}; container=[ordered]@{name=$name;mounts=$scrubbedMounts;dangerousMountCount=@($dangerous).Count} } | ConvertTo-Json -Depth 8
if ($json -match 'Alice|hidden|secret-cache') { throw 'Path identity or secret-shaped value leaked.' }
if ($json -notmatch 'dangerousMountCount\"\s*:\s*1') { throw 'Dangerous mount classification changed.' }
if ($json -notmatch 'configVolumes|<user-root>|<drive>') { throw 'Scrubbed projection missing.' }
Write-Output 'PASS: inert Config.Volumes and mount projection is scrubbed and preserves dangerous classification.'
