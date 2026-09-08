[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $DeployScript,
    [Parameter(Mandatory)] [string] $DeployConfig,
    [Parameter(Mandatory)] [string] $DeployRoot,
    [switch] $ValidateOnly
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $DeployScript -PathType Leaf)) { throw "PlatformDeploy script is missing: $DeployScript" }
$apiKey = $env:RETAIL_JFROG_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) { throw 'Masked RETAIL_JFROG_API_KEY environment variable is required.' }
$source = Get-Content -LiteralPath $DeployScript -Raw
$matches = [regex]::Matches($source, 'RetailJfrogApiKey')
if ($matches.Count -ne 2) {
    throw "Refusing PlatformDeploy revision: RetailJfrogApiKey occurs $($matches.Count) times; secret transport is not proven safe."
}
$mandatory = '[string]$RetailJfrogApiKey = $(throw "RetailJfrogApiKey is mandatory."),'
if (-not $source.Contains($mandatory)) {
    throw 'Refusing PlatformDeploy revision: expected unused mandatory API-key parameter declaration was not found.'
}

# The pinned PS7 script declares this parameter but never consumes it. Remove only
# that unused mandatory declaration in a temporary copy, so no secret reaches a
# process argument. Any future consumption causes the fail-closed occurrence check.
$sanitized = $source.Replace($mandatory, '[string]$RetailJfrogApiKey = "",')
$sanitizedPath = Join-Path $DeployRoot 'docker-pipeline-deploy-ps7-sanitized.ps1'
Set-Content -LiteralPath $sanitizedPath -Value $sanitized -Encoding UTF8
$appData = [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData)
if ([string]::IsNullOrWhiteSpace($appData)) { throw 'ApplicationData path is unavailable; cannot configure the pinned JFrog CLI.' }
$repoDir = Join-Path $appData 'Cegid.Retail'
$repoFile = Join-Path $repoDir 'Retail-JfrogCli.json'
$backupFile = Join-Path $DeployRoot '.Retail-JfrogCli.previous.json'
$hadPrevious = Test-Path -LiteralPath $repoFile -PathType Leaf
if ($hadPrevious) { Copy-Item -LiteralPath $repoFile -Destination $backupFile -Force }
try {
    if (-not (Test-Path -LiteralPath $repoDir -PathType Container)) { New-Item -ItemType Directory -Path $repoDir -Force | Out-Null }
    $productId = (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductID -ErrorAction Stop).ProductID
    $seed = "$productId-$env:COMPUTERNAME-$env:USERNAME-$env:USERDOMAIN"
    if ($seed.Length -lt 32) { throw 'PlatformDeploy JFrog encryption seed is shorter than 32 characters.' }
    $aesKey = [Text.Encoding]::ASCII.GetBytes($seed.Substring(0,32))
    $aesIv = [Text.Encoding]::ASCII.GetBytes('XJFrogArtApi-PAT')
    $aes = [Security.Cryptography.Aes]::Create()
    $aes.Key = $aesKey
    $aes.IV = $aesIv
    $stream = [IO.MemoryStream]::new()
    $crypto = [Security.Cryptography.CryptoStream]::new($stream, $aes.CreateEncryptor(), [Security.Cryptography.CryptoStreamMode]::Write)
    $writer = [IO.StreamWriter]::new($crypto)
    $writer.Write($apiKey)
    $writer.Close()
    $payload = [Convert]::ToBase64String($stream.ToArray())
    $json = [ordered]@{ Data = @([ordered]@{ Key = 'JFROG'; Base64 = $payload }) } | ConvertTo-Json -Depth 4 -Compress
    Set-Content -LiteralPath $repoFile -Value $json -Encoding UTF8
    if ($ValidateOnly) {
        Write-Host 'PlatformDeploy JFrog authentication contract validated from masked environment; invocation skipped.'
        exit 0
    }
    & $sanitizedPath -deployConfig $DeployConfig -LocalDBInContainer Backup
    if ($LASTEXITCODE -ne 0) { throw "PlatformDeploy failed with exit code $LASTEXITCODE." }
    Write-Host 'PlatformDeploy invoked without API-key process argument; JFrog CLI config was temporary and restored after invocation.'
}
finally {
    $env:RETAIL_JFROG_API_KEY = $null
    if ($hadPrevious) { Copy-Item -LiteralPath $backupFile -Destination $repoFile -Force }
    elseif (Test-Path -LiteralPath $repoFile -PathType Leaf) { [IO.File]::Delete($repoFile) }
    if (Test-Path -LiteralPath $backupFile -PathType Leaf) { [IO.File]::Delete($backupFile) }
    Remove-Variable apiKey,aesKey,aesIv,seed,payload,json -ErrorAction SilentlyContinue
}
