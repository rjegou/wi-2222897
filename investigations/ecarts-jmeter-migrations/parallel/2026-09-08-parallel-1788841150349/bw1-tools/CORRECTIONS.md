# API correction matrix

| Area | File/method | Cause addressed | Test before/after | Status |
|---|---|---|---|---|
| JDBC dates | `JmeterCodeGen.cs` / `EscapeJdbcDate` | JDBC date literals require generator-compatible forms | quoted, unquoted and datetime reflection cases | FACT — PASS |
| SQL Unicode | `JmeterCodeGen.cs` / `FixSqlUnicodeValue` | non-ASCII SQL literals need `N` prefix; doubled apostrophe must remain part of literal | `SELECT 'NN''é'` -> `SELECT N'NN''é'` | FACT — PASS |
| XML/XQuery escaping | `JmeterCodeGen.cs` / `RemoveSpecialCharsForXQuery` | `<`, `>`, apostrophes must survive XML embedding | `<x a='é'>` encoded and verified | FACT — PASS |
| SOAP 1.1 XPath | `JmeterCodeGen.cs` / `CleanXpath`, `XPathJmeter` | prefix stripping loses namespace identity | descendant path, variable response prefix, wrong URI and absent Fault offline XML cases | FACT — PASS offline; JMeter UNKNOWN |
| ExpectedValue negation | `JmeterCodeGen.cs` / `XPathJmeter` | zero means negative XPath assertion | `ExpectedValue=0` emitted `XPath.negate=true` | FACT — PASS |
| Package propagation | Console/package/cache/regeneration | binary identity may diverge across stages | not executed in this scope | UNKNOWN |

## Console / migration synthesis — 2026-09-08

| Composant | Preuve | Statut |
|---|---|---|
| API `JmeterCodeGen.cs` | FB497E... compilée et tests locaux documentés dans `evidence/api/README.md` | FACT local, pas bundle final |
| Console clone | HEAD fa8a5fb..., csproj/packages.config/nuspec relus | FACT |
| Package Console 2.0.41 | SHA 7C5C6D... ; API 334155E6... ; dépendances csproj manquantes dans tools | FACT, défaut candidat |
| API→Console→nupkg | script avec contrôle d'identité et dépendances fourni | CANDIDATE, non exécuté |
| Cache/version migration | aucun changement ni preuve de rafraîchissement | UNKNOWN |
| XML legacy→JMX | JMX historiques présents mais exclus comme sources | UNKNOWN pour XML quatre-plans exacts |
