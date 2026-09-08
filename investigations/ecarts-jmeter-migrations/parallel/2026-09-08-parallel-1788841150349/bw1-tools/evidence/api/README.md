# API evidence — 2026-09-08

## Provenance

System: local Windows PowerShell / Visual Studio BuildTools MSBuild. Source snapshot: `worktrees/Y2_Tools_AutoTest_Api`, HEAD `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`, clean at inspection. Independent baseline: `worktrees/api`, commit `8461c8db6ec532834f1b047013716fbc2dd3c718`. No secret was read or copied.

## Commands and results

1. `git status --short --branch` before edit: `## master`.
2. MSBuild net452 Debug/Rebuild with the pre-existing local reference staging, output redirected under this evidence directory: `EXIT_CODE=0`; DLL produced.
3. Reflection checks against the produced DLL: dates (3), Unicode doubled apostrophe, XQuery escaping, SOAP 1.1 CleanXpath, non-SOAP preservation, and `ExpectedValue=0` XPath generation: all PASS.
4. Offline `System.Xml.XmlDocument.SelectNodes` checks: response prefixes `soap` and `env` match; wrong URI and no Fault do not match: all PASS.
5. JMeter discovery: `JMETER_NOT_FOUND`; no JMeter execution.

## Hash manifest

| Path | SHA-256 |
|---|---|
| `worktrees/api/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` | `37594BDD95DEDB71EC15584F71E21B4E61749534B57605B69B739B365E4AF4FA` |
| `runtime/Cegid.Retail.AutoTest.Api.dll` | `FB497E2B86B50398952842D573AEB79488C6FA610007295D38EFA07248DA9A89` |
| `rebuild.log` | `679C58811AEFD6201CE3DB8E0AAC5AB6D8BC9826ABD6C3C889F3ED2769D002F0` |

These are local, dated evidence only; they do not prove package/migration propagation or business success.

## Round 2 consolidation evidence — 2026-09-08

Historical provenance reviewed: `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`. Its literal scanner was adopted for `FixSqlUnicodeValue`; its `PrepareXPathAssertion`/SOAP 1.1 constants were adopted for XPath generation; its `EscapeJdbcDate` quoted-date replacement establishes `yyyyMMdd`. The historical worktree was not modified.

New discriminating checks:

- Ten direct DLL vectors PASS: Unicode literal, doubled apostrophes, ASCII doubled apostrophes, existing `N` prefix, multiple literals, line/block comments, bracketed identifiers, quoted identifiers, and date `2026-04-28 -> 20260428`.
- `ApiSourceXmlHarness.exe` parsed the local `source-fixture.xml` and called public `GenerateJmeter`; `SOURCE_XML_TO_JMX=PASS`. Generated JMX hash: `07A46BE426D8AF7CB344767B7B99EBDEF3862C8219B04D97B33537BD181324F1`.
- Generated API expression is `//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode`; XML-encoded expression is retained in `generated-soap-expression.txt` and runtime-decoded form in `generated-soap-expression-runtime.txt`.
- Official Apache JMeter 5.6.3 ZIP SHA-512: `387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B016307`. Real CLI run used only local inert JMX/fixtures: exit `0`, JTL `generated-soap-inert-round2.jtl`, 4 samples and `Err: 0`.
- JMeter real results: SOAP prefixes `soap` and `env` positive PASS; wrong URI and missing Fault negative assertions PASS. Descendant `detail/faultcode` is included. No HTTP/SQL sampler or remote endpoint exists in the inert plan.

Round 1's `JMETER_NOT_FOUND` is superseded by this local indexed acquisition and execution. Console/package/cache propagation remains UNKNOWN.
