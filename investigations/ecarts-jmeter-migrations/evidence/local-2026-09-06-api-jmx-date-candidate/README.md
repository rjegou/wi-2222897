# Génération JMX — fixtures EscapeJdbcDate

Date : 2026-09-06. Le harnais appelle directement `Cegid.Retail.AutoTest.Api.JmeterCodeGen.GenerateJmeter(TestPlan, string, string)` ; il ne contient ni réflexion ni copie de la transformation. La fixture réelle est `DtoLegacyServiceTestPlan` + un `TestCase` + une `Control` dans `PreDataQueries`, avec `input.xml` minimal `<Root />`.

API chargée : `runtime/Cegid.Retail.AutoTest.Api.dll`, chemin absolu affiché par le programme, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`. Runtime : .NET Framework `v4.0.30319`. Les DLL d'exécution viennent du `bin` compilé ; les façades net452 n'ont servi qu'à compiler le harnais et ne sont pas chargées comme runtime.

Le programme génère six JMX sans JMeter, SQL, HTTP ou déploiement, puis exige exactement un `JDBCSampler` et une propriété `stringProp name="query"` par fichier. Il retourne un code non nul en cas d'exception, d'absence/ambiguïté du sampler ou d'attendu incorrect.

Résultats :

| fixture | attendu | obtenu | état |
|---|---|---|---|
| `SELECT '2026-04-28'` | `SELECT '20260428'` | `SELECT '20260428'` | PASS |
| `SELECT '2026-04-05'` | `SELECT '20260405'` | `SELECT '20260405'` | PASS |
| `SELECT '2024-02-29'` | `SELECT '20240229'` | `SELECT '20240229'` | PASS |
| deux dates | `SELECT '20260428','20240229'` | identique | PASS |
| témoin compact | `SELECT '20260428'` | identique | PASS |
| témoin slash | `SELECT '2026/04/28'` | identique | PASS |

Compilation du harnais : code `0`. Exécution : code `0`. Commandes, source, fixtures, JMX et `results.tsv` sont conservés dans ce dossier. Aucun worktree n'a été modifié. Verdict maximal : génération JMX corrigée validée sur ces fixtures ; comparaison originale, propagation Console et rejeu métier restent à faire.
