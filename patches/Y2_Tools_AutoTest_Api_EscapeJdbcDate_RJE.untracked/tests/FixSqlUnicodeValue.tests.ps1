param([Parameter(Mandatory=$true)][string]$AssemblyPath)
$ErrorActionPreference = 'Stop'
[Reflection.Assembly]::LoadFrom((Resolve-Path $AssemblyPath)) | Out-Null
$cases = @(
  @{ Name='Unicode simple'; Input="select N'café'"; Expected="select N'café'" },
  @{ Name='Unicode doubled apostrophe'; Input="select 'l''été'"; Expected="select N'l''été'" },
  @{ Name='ASCII doubled apostrophe'; Input="select 'l''ete'"; Expected="select 'l''ete'" },
  @{ Name='Outside literal'; Input='select cafe -- été'; Expected='select cafe -- été' },
  @{ Name='Already prefixed'; Input="select N'l''été'"; Expected="select N'l''été'" },
  @{ Name='Multiple literals'; Input="select 'café', 'été'"; Expected="select N'café', N'été'" },
  @{ Name='Line comment'; Input="select 'ok' -- 'café'"; Expected="select 'ok' -- 'café'" },
  @{ Name='Block comment'; Input="select 'ok' /* 'café' */"; Expected="select 'ok' /* 'café' */" },
  @{ Name='Delimited identifiers'; Input='select [café''col], "café''col"'; Expected='select [café''col], "café''col"' }
)
foreach($case in $cases) {
  $actual = [Cegid.Retail.AutoTest.Api.JmeterCodeGen]::FixSqlUnicodeValue($case.Input)
  if($actual -cne $case.Expected) { throw "$($case.Name): expected [$($case.Expected)] got [$actual]" }
  "PASS $($case.Name)"
}
