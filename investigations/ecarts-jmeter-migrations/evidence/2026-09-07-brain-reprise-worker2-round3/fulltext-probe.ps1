$ErrorActionPreference = 'Stop'
$server = "localhost\$env:sqlinstance"
function Invoke-Sql([string] $Query) {
  & sqlcmd -S $server -U sa -P "$env:sa_password" -C -b -Q $Query
  if ($LASTEXITCODE -ne 0) { throw 'sqlcmd failed' }
}
$value = (& sqlcmd -S $server -U sa -P "$env:sa_password" -C -b -h -1 -W -Q "SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')" | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $value -ne '1') { throw "Full-Text service property is not 1: [$value]" }
$db = 'FullTextSmoke'
Invoke-Sql "IF DB_ID(N'$db') IS NOT NULL BEGIN ALTER DATABASE [$db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$db]; END; CREATE DATABASE [$db];"
Invoke-Sql "USE [$db]; CREATE TABLE dbo.Documents (Id int NOT NULL CONSTRAINT PK_Documents PRIMARY KEY, Body nvarchar(4000) NOT NULL); INSERT dbo.Documents VALUES (1,N'alpha searchable text'),(2,N'other text'); CREATE FULLTEXT CATALOG FullTextSmokeCatalog AS DEFAULT; CREATE FULLTEXT INDEX ON dbo.Documents(Body LANGUAGE 1033) KEY INDEX PK_Documents;"
$deadline = (Get-Date).AddSeconds(90)
do {
  Start-Sleep -Seconds 5
  $status = (& sqlcmd -S $server -U sa -P "$env:sa_password" -C -b -h -1 -W -Q "USE [$db]; SELECT FULLTEXTCATALOGPROPERTY(N'FullTextSmokeCatalog',N'PopulateStatus')" | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw 'Full-Text catalog status query failed' }
} while ($status -ne '0' -and (Get-Date) -lt $deadline)
if ($status -ne '0') { throw "Full-Text population did not finish: [$status]" }
$hits = (& sqlcmd -S $server -U sa -P "$env:sa_password" -C -b -h -1 -W -Q "USE [$db]; SELECT COUNT(*) FROM CONTAINSTABLE(dbo.Documents,Body,N'alpha')" | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or [int]$hits -lt 1) { throw "CONTAINSTABLE smoke returned [$hits]" }
Invoke-Sql "ALTER DATABASE [$db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$db];"
Write-Host "FULLTEXTSERVICEPROPERTY(IsFullTextInstalled)=$value; CONTAINSTABLE hits=$hits"
