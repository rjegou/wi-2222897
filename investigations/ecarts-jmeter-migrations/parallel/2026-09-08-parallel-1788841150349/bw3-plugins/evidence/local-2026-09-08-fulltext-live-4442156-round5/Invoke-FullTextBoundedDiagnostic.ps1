[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Image,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $SetupQuery,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ContainstableQuery,

    [string] $OutputPath = (Join-Path (Get-Location) 'fulltext-diagnostic.jsonl'),

    [ValidateRange(30, 600)]
    [int] $ObserveSeconds = 120,

    [ValidateRange(1, 60)]
    [int] $PollSeconds = 5,

    [ValidateNotNullOrEmpty()]
    [string] $SqlInstance = 'DOCKERSQLEXPR'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $env:MSSQL_SA_PASSWORD) {
    throw 'MSSQL_SA_PASSWORD must be supplied by the caller process; it is never accepted as a script argument.'
}

$docker = Get-Command docker -ErrorAction Stop
$runId = [guid]::NewGuid().ToString('N')
$containerName = "wi2222897-ftdiag-$runId"
$labelKey = 'wi-2222897.fulltext-diagnostic'
$labelValue = $runId
$created = $false
$outputDirectory = Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))
if ($outputDirectory) {
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

# SQLCMDPASSWORD is inherited by docker exec without putting the value in an argument.
$previousSqlcmdPassword = $env:SQLCMDPASSWORD
$env:SQLCMDPASSWORD = $env:MSSQL_SA_PASSWORD

function Invoke-DockerText {
    param([Parameter(Mandatory = $true)][string[]] $Arguments)

    $lines = @(& $docker.Source @Arguments 2>&1 | ForEach-Object { [string]$_ })
    [pscustomobject]@{
        ExitCode = [int]$LASTEXITCODE
        Text     = ($lines -join "`n")
    }
}

function Redact-Secret {
    param([AllowEmptyString()][string] $Text)

    if ($null -eq $Text) { return '' }
    if ($env:MSSQL_SA_PASSWORD) {
        return $Text.Replace($env:MSSQL_SA_PASSWORD, '<redacted>')
    }
    return $Text
}

function Write-Event {
    param(
        [Parameter(Mandatory = $true)][string] $Event,
        [hashtable] $Data = @{}
    )

    $record = [ordered]@{
        event       = $Event
        utc         = [DateTime]::UtcNow.ToString('o')
        runId       = $runId
        container   = $containerName
        image       = $Image
    }
    foreach ($key in $Data.Keys) { $record[$key] = $Data[$key] }
    ($record | ConvertTo-Json -Compress -Depth 8) | Add-Content -LiteralPath $OutputPath -Encoding UTF8
}

function Invoke-SqlQuery {
    param([Parameter(Mandatory = $true)][string] $Query)

    Invoke-DockerText @(
        'exec', '--env', 'SQLCMDPASSWORD', $containerName, 'sqlcmd',
        '-S', "localhost\$SqlInstance", '-U', 'sa', '-C', '-b', '-W', '-s', '|', '-Q', $Query
    )
}

try {
    Write-Event 'diagnostic-start' @{ observeSeconds = $ObserveSeconds; pollSeconds = $PollSeconds }

    $run = Invoke-DockerText @(
        'run', '--detach', '--name', $containerName,
        '--label', "$labelKey=$labelValue",
        '--env', 'ACCEPT_EULA=Y', '--env', 'MSSQL_PID=Developer', '--env', 'MSSQL_SA_PASSWORD',
        $Image
    )
    if ($run.ExitCode -ne 0) { throw "docker run failed: $(Redact-Secret $run.Text)" }
    $created = $true
    Write-Event 'container-created' @{ dockerId = (Redact-Secret $run.Text).Trim() }

    $deadline = [DateTime]::UtcNow.AddSeconds([Math]::Min(90, $ObserveSeconds))
    do {
        $ready = Invoke-SqlQuery 'SELECT 1 AS Ready'
        if ($ready.ExitCode -eq 0) { break }
        Start-Sleep -Seconds $PollSeconds
    } while ([DateTime]::UtcNow -lt $deadline)
    if ($ready.ExitCode -ne 0) { throw "SQL readiness failed: $(Redact-Secret $ready.Text)" }
    Write-Event 'sql-ready'

    $setup = Invoke-SqlQuery $SetupQuery
    Write-Event 'setup' @{ exitCode = $setup.ExitCode; output = (Redact-Secret $setup.Text) }
    if ($setup.ExitCode -ne 0) { throw 'SetupQuery failed; diagnostic stopped before polling.' }

    $statusQuery = @"
SET NOCOUNT ON;
USE [FullTextSmoke];
SELECT CONCAT(
  'CATALOG=', COALESCE(CONVERT(varchar(20), FULLTEXTCATALOGPROPERTY(N'FullTextSmokeCatalog', N'PopulateStatus')), 'NULL'),
  ';TABLE=', COALESCE(CONVERT(varchar(20), OBJECTPROPERTYEX(OBJECT_ID(N'dbo.Documents'), N'TableFullTextPopulateStatus')), 'NULL'),
  ';DMV=', COALESCE(CONVERT(varchar(20), (SELECT TOP 1 status FROM sys.dm_fts_index_population WHERE database_id = DB_ID())), 'NONE'),
  ';DMV_DESC=', COALESCE((SELECT TOP 1 status_description FROM sys.dm_fts_index_population WHERE database_id = DB_ID()), 'NONE'),
  ';RANGE=', COALESCE(CONVERT(varchar(20), (SELECT TOP 1 range_count FROM sys.dm_fts_index_population WHERE database_id = DB_ID())), 'NONE'),
  ';DONE=', COALESCE(CONVERT(varchar(20), (SELECT TOP 1 completed_range_count FROM sys.dm_fts_index_population WHERE database_id = DB_ID())), 'NONE'),
  ';OUTSTANDING=', COALESCE(CONVERT(varchar(20), (SELECT TOP 1 outstanding_batch_count FROM sys.dm_fts_index_population WHERE database_id = DB_ID())), 'NONE')
);
"@
    $runtimeQuery = 'Get-Service -Name ''MSSQL$' + $SqlInstance + ''',''MSSQLFDLauncher'' -ErrorAction SilentlyContinue | Select-Object Name,Status; Get-Process -Name fdhost,fdlauncher -ErrorAction SilentlyContinue | Select-Object ProcessName,Id,StartTime'
    $end = [DateTime]::UtcNow.AddSeconds($ObserveSeconds)
    $lastStatus = $null
    while ($true) {
        $status = Invoke-SqlQuery $statusQuery
        $runtime = Invoke-DockerText @('exec', $containerName, 'powershell', '-NoLogo', '-NoProfile', '-Command', $runtimeQuery)
        $lastStatus = $status
        Write-Event 'observation' @{
            sqlExitCode = $status.ExitCode
            sql         = (Redact-Secret $status.Text)
            runtimeExitCode = $runtime.ExitCode
            runtime     = (Redact-Secret $runtime.Text)
        }
        if ($status.ExitCode -eq 0 -and $status.Text -match 'CATALOG=0;TABLE=0;DMV=0') { break }
        if ([DateTime]::UtcNow -ge $end) { break }
        Start-Sleep -Seconds $PollSeconds
    }

    $hits = Invoke-SqlQuery $ContainstableQuery
    $hitCount = $null
    if ($hits.ExitCode -eq 0) {
        $candidate = (($hits.Text -split "`r?`n") | Where-Object { $_.Trim() } | Select-Object -Last 1).Trim()
        [Int64]::TryParse($candidate, [Globalization.NumberStyles]::Integer, [Globalization.CultureInfo]::InvariantCulture, [ref]$hitCount) | Out-Null
    }
    Write-Event 'containstable' @{ exitCode = $hits.ExitCode; hitCount = $hitCount; output = (Redact-Secret $hits.Text) }
    if ($hits.ExitCode -ne 0 -or $null -eq $hitCount -or $hitCount -lt 1) {
        throw 'CONTAINSTABLE assertion failed.'
    }
    if ($null -eq $lastStatus -or $lastStatus.Text -notmatch 'CATALOG=0;TABLE=0;DMV=0') {
        throw 'Full-Text population did not reach the terminal status.'
    }
    Write-Event 'assertion-pass'
}
catch {
    Write-Event 'assertion-fail' @{ error = (Redact-Secret $_.Exception.Message) }
    throw
}
finally {
    if ($created) {
        $inspect = Invoke-DockerText @('inspect', $containerName)
        $owned = $false
        if ($inspect.ExitCode -eq 0) {
            try {
                $json = $inspect.Text | ConvertFrom-Json
                $owned = ($json[0].Config.Labels.$labelKey -eq $labelValue)
            } catch { $owned = $false }
        }
        if ($owned) {
            $removed = Invoke-DockerText @('rm', '--force', $containerName)
            Write-Event 'cleanup' @{ exitCode = $removed.ExitCode; output = (Redact-Secret $removed.Text) }
        } else {
            Write-Event 'cleanup-unknown' @{ inspectExitCode = $inspect.ExitCode }
        }
    }
    if ($null -eq $previousSqlcmdPassword) {
        Remove-Item Env:SQLCMDPASSWORD -ErrorAction SilentlyContinue
    } else {
        $env:SQLCMDPASSWORD = $previousSqlcmdPassword
    }
}
