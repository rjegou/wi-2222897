[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)][ValidateSet('Cur','Fix')][string]$Variant,
    [Parameter(Mandatory)][string]$RunId,
    [Parameter(Mandatory)][string]$ImageRepository,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$ImageDigest,
    [Parameter(Mandatory)][string]$BackupSourcePath,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$ExpectedBackupSha256,
    [Parameter(Mandatory)][string]$OutputRoot,
    [string]$DatabaseName = 'AUTO_V26_00',
    [string]$BackupFileName = 'AUTO_V26_00.bak',
    [string]$DataRoot = 'C:\wi2222897\data',
    [switch]$Provision
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $Provision) { throw 'Refusing image pull, restore, and container writes: pass -Provision only from the authorized isolated job.' }
if ($RunId -notmatch '^[A-Za-z0-9._-]+$') { throw 'RunId contains unsafe characters.' }
if ($ImageRepository -notmatch '^[A-Za-z0-9./_-]+$') { throw 'ImageRepository contains unsafe characters.' }
if ($DatabaseName -notmatch '^[A-Za-z0-9_-]+$') { throw 'DatabaseName contains unsafe characters.' }
if ($BackupFileName -notmatch '^[A-Za-z0-9._-]+\.bak$') { throw 'BackupFileName must be a simple .bak filename.' }
if (-not (Test-Path -LiteralPath $BackupSourcePath -PathType Leaf)) { throw "Backup source is missing: $BackupSourcePath" }
if ([string]::IsNullOrWhiteSpace($env:WI2222897_SQL_SA_PASSWORD)) { throw 'WI2222897_SQL_SA_PASSWORD must be supplied only in the isolated process environment.' }

$imageRef = "$ImageRepository@sha256:$ImageDigest"
$scope = "WI-2222897/$Variant/$RunId"
$containerName = "wi2222897-$Variant-$RunId"
$networkName = "wi2222897-$Variant-$RunId"
$stageRoot = Join-Path $OutputRoot 'target-inputs'
$backupPath = Join-Path $stageRoot $BackupFileName
$restoreReceiptPath = Join-Path $OutputRoot 'restore-receipt.json'
New-Item -ItemType Directory -Path $OutputRoot,$stageRoot -Force | Out-Null

function Invoke-Docker([string[]]$Arguments) {
    $out = & docker @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "docker $($Arguments -join ' ') failed: $($out -join ' ')" }
    @($out)
}
function Invoke-Sql([string]$Query, [switch]$AllowFailure) {
    $args = @('exec','-e',"SQLCMDPASSWORD=$env:WI2222897_SQL_SA_PASSWORD",$containerName,'sqlcmd','-S','localhost','-U','sa','-b','-W','-h','-1','-s','|','-Q',$Query)
    $out = & docker @args 2>&1
    if (-not $AllowFailure -and $LASTEXITCODE -ne 0) { throw "sqlcmd failed: $($out -join ' ')" }
    [pscustomobject]@{ ExitCode=$LASTEXITCODE; Output=@($out) }
}

# Read-only daemon capability check before acquiring or writing anything.
Invoke-Docker @('info','--format','{{json .ServerVersion}}') | Out-Null
if ($PSCmdlet.ShouldProcess($imageRef, 'Pull digest-pinned image')) { Invoke-Docker @('pull',$imageRef) | Out-Null }
$repoDigests = @(Invoke-Docker @('image','inspect',$imageRef,'--format','{{json .RepoDigests}}') | ConvertFrom-Json)
if (-not ($repoDigests | Where-Object { $_ -eq $imageRef })) { throw "Pulled image does not prove requested digest: $imageRef" }

Copy-Item -LiteralPath $BackupSourcePath -Destination $backupPath -Force
$actualBackup = (Get-FileHash -LiteralPath $backupPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($actualBackup -ne $ExpectedBackupSha256.ToUpperInvariant()) { throw "Backup SHA-256 mismatch: expected $ExpectedBackupSha256, got $actualBackup." }

$labels = @('--label',"wi.scope=$scope",'--label','wi.ephemeral=true', '--label',"wi.runId=$RunId",'--label',"wi.cleanup=$containerName")
$existing = & docker ps -a --filter "name=^/$containerName$" --format '{{.ID}}' 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($existing -join ''))) { throw "Target container already exists: $containerName" }
if ($PSCmdlet.ShouldProcess($networkName, 'Create private internal network')) { Invoke-Docker (@('network','create','--internal') + $labels + @($networkName)) | Out-Null }
$mount = "type=bind,source=$backupPath,target=C:\wi2222897\backup\$BackupFileName,readonly"
if ($PSCmdlet.ShouldProcess($containerName, 'Create and start ephemeral target')) {
    Invoke-Docker (@('create','--name',$containerName,'--network',$networkName) + $labels + @('--mount',$mount,$imageRef)) | Out-Null
    try {
        Invoke-Docker @('start',$containerName) | Out-Null
        $ready = $false
        for ($i=0; $i -lt 30; $i++) {
            $probe = Invoke-Sql 'SELECT 1' -AllowFailure
            if ($probe.ExitCode -eq 0) { $ready = $true; break }
            Start-Sleep -Seconds 2
        }
        if (-not $ready) { throw 'SQL did not become ready within 60 seconds.' }
        $fileList = Invoke-Sql "RESTORE FILELISTONLY FROM DISK = N'C:\wi2222897\backup\$BackupFileName';"
        if ($fileList.ExitCode -ne 0) { throw "RESTORE FILELISTONLY failed: $($fileList.Output -join ' ')" }
        $logical = @($fileList.Output | ForEach-Object { ($_ -split '\|').Trim() } | Where-Object { $_.Count -ge 3 -and $_[0] -and $_[2] -in @('D','L') } | ForEach-Object { [pscustomobject]@{ Name=$_[0]; Type=$_[2] } })
        if ($logical.Count -lt 1) { throw 'RESTORE FILELISTONLY returned no logical database files.' }
        $moves = @(); $n = 0
        foreach ($file in $logical) {
            $n++; $ext = if ($file.Type -eq 'L') { 'ldf' } else { 'mdf' }
            $moves += "MOVE N'$($file.Name.Replace("'","''"))' TO N'$DataRoot\$DatabaseName-$n.$ext'"
        }
        $restoreQuery = "IF DB_ID(N'$DatabaseName') IS NOT NULL BEGIN ALTER DATABASE [$DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END; RESTORE DATABASE [$DatabaseName] FROM DISK = N'C:\wi2222897\backup\$BackupFileName' WITH REPLACE, $($moves -join ', '); ALTER DATABASE [$DatabaseName] SET MULTI_USER;"
        $restored = Invoke-Sql $restoreQuery
        if ($restored.ExitCode -ne 0) { throw "RESTORE DATABASE failed: $($restored.Output -join ' ')" }
        $verify = Invoke-Sql "IF DB_ID(N'$DatabaseName') IS NULL THROW 51000, 'Database restore not visible', 1; SELECT name FROM sys.databases WHERE name = N'$DatabaseName';"
        if ($verify.ExitCode -ne 0 -or -not ($verify.Output -contains $DatabaseName)) { throw 'Restored database could not be verified.' }
        [ordered]@{ schema='wi2222897-restore-receipt-1'; scope='WI-2222897'; variant=$Variant; runId=$RunId; status='PASS'; image=$imageRef; backupPath=$BackupFileName; backupSha256=$actualBackup; database=$DatabaseName; container=$containerName; network=$networkName; restoredUtc=[DateTimeOffset]::UtcNow.ToString('o') } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $restoreReceiptPath -Encoding UTF8
        [ordered]@{ schema='wi2222897-target-attestation-2'; scope='WI-2222897'; variant=$Variant; runId=$RunId; status='PASS'; image=$imageRef; backupPath=$BackupFileName; backupSha256=$actualBackup; database=$DatabaseName; appHost=$containerName; dbHost=$containerName; network=$networkName; publishedPorts=@(); restoreReceipt='restore-receipt.json'; cleanupScope=$containerName; inspectedUtc=[DateTimeOffset]::UtcNow.ToString('o') } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputRoot 'target-attestation.json') -Encoding UTF8
    } catch { & docker rm -f $containerName 2>$null | Out-Null; & docker network rm $networkName 2>$null | Out-Null; throw }
}
