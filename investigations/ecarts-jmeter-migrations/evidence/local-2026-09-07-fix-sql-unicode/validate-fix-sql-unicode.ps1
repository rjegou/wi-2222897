$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Text.RegularExpressions;
public static class UnicodeFixProbe {
  public static string Old(string query) { return Regex.Replace(query, @"'([^']*[^\x00-\x7F][^']*)'", "N'$1'"); }
  public static string Apply(string query) {
    if (String.IsNullOrEmpty(query)) return query;
    var result = new StringBuilder(query.Length + 16);
    for (int i=0; i<query.Length; i++) {
      if (query[i]=='-' && i+1<query.Length && query[i+1]=='-') { int e=query.IndexOf('\n',i+2); if(e<0)e=query.Length; result.Append(query,i,e-i); i=e-1; continue; }
      if (query[i]=='/' && i+1<query.Length && query[i+1]=='*') { int e=query.IndexOf("*/",i+2,StringComparison.Ordinal); e=e<0?query.Length:e+2; result.Append(query,i,e-i); i=e-1; continue; }
      if (query[i]=='[' || query[i]=='\"') { char close=query[i]=='['?']':'\"'; int e=i+1; while(e<query.Length){ if(query[e]==close){ if(e+1<query.Length && query[e+1]==close){e+=2;continue;} e++;break;} e++; } result.Append(query,i,e-i); i=e-1; continue; }
      if (query[i] != '\'') { result.Append(query[i]); continue; }
      bool alreadyUnicode = i > 0 && (query[i-1] == 'N' || query[i-1] == 'n');
      int end=i+1; bool hasNonAscii=false;
      while (end < query.Length) {
        if (query[end] > 0x7F) hasNonAscii=true;
        if (query[end] != '\'') { end++; continue; }
        if (end+1 < query.Length && query[end+1] == '\'') { end+=2; continue; }
        break;
      }
      if (hasNonAscii && !alreadyUnicode) result.Append('N');
      result.Append(query, i, Math.Min(end+1, query.Length)-i);
      i=Math.Min(end, query.Length-1);
    }
    return result.ToString();
  }
}
'@
$cases=@(
  @{Name='Unicode simple'; Input="select 'café'"; Expected="select N'café'"},
  @{Name='Unicode doubled apostrophe'; Input="select 'l''été'"; Expected="select N'l''été'"},
  @{Name='ASCII doubled apostrophe'; Input="select 'l''ete'"; Expected="select 'l''ete'"},
  @{Name='Outside literal'; Input='select cafe -- été'; Expected='select cafe -- été'},
  @{Name='Already prefixed'; Input="select N'l''été'"; Expected="select N'l''été'"}
  @{Name='Multiple literals'; Input="select 'café', 'été'"; Expected="select N'café', N'été'"}
  @{Name='Line comment'; Input="select 'ok' -- 'café'"; Expected="select 'ok' -- 'café'"}
  @{Name='Block comment'; Input="select 'ok' /* 'café' */"; Expected="select 'ok' /* 'café' */"}
  @{Name='Delimited identifiers'; Input='select [café''col], "café''col"'; Expected='select [café''col], "café''col"'}
)
foreach($case in $cases) {
  $before=[UnicodeFixProbe]::Old($case.Input); $after=[UnicodeFixProbe]::Apply($case.Input)
  if($after -cne $case.Expected){throw "$($case.Name): got [$after]"}
  "PASS`t$($case.Name)`tBEFORE=[$before]`tAFTER=[$after]"
}
$jmx=Join-Path $PSScriptRoot '..\..\sources\Y2_Plugins_Clienteling-master-build-4432554-exact\Tests\WebServices\073-ItemSearch_Keywords.jmx'
[xml]$doc=Get-Content -LiteralPath $jmx -Raw
$node=$doc.SelectNodes("//*[local-name()='JDBCSampler']") | Where-Object { $_.testname -like '*TC 02 - A-PreQuery1' }
if(-not $node){throw 'TC02 A-PreQuery1 not found'}
$queryNode=$node.SelectSingleNode("./stringProp[@name='query']")
if(-not $queryNode){throw 'TC02 SQL query node not found'}
$queryText=$queryNode.InnerText
$before=[UnicodeFixProbe]::Old($queryText); $after=[UnicodeFixProbe]::Apply($queryText)
if($after -notmatch "MAM_MOTCLE=N'" -or $after -notmatch "''"){throw 'TC02 generated SQL assertion failed'}
"PASS`tItemSearch:Keywords TC02 A-PreQuery1`tBEFORE_HASH=$((Get-FileHash $jmx -Algorithm SHA256).Hash)`tOLD_CHANGED=$($before -cne $node.query)`tNEW_PRESERVES_ESCAPED_APOSTROPHE=$($after -match "''")"
