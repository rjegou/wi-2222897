# Result — BW1 API / Console / migration synthesis

## FACT — 2026-09-08

- `JmeterCodeGen.cs` now consolidates the existing `EscapeJdbcDate`, `FixSqlUnicodeValue`, and `RemoveSpecialCharsForXQuery` paths with SOAP 1.1 namespace-aware XPath generation.
- The Unicode SQL regex was strengthened to preserve doubled apostrophes, e.g. `SELECT 'NN''é'` -> `SELECT N'NN''é'`.
- SOAP 1.1 controls beginning with `/soap:Fault` or `//soap:Fault` emit a local-name/namespace-uri XPath for `http://schemas.xmlsoap.org/soap/envelope/` and set `XPath.namespace=true`; other XPath controls retain `XPath.namespace=false`.
- The API project rebuilt successfully for net452 Debug with the existing local reference staging. Output DLL identity is `Cegid.Retail.AutoTest.Api, Version=1.1.46.0, PublicKeyToken=fe0ce61bd76bef19`, SHA-256 `FB497E2B86B50398952842D573AEB79488C6FA610007295D38EFA07248DA9A89`.
- Reflection tests passed for dates, Unicode/doubled apostrophes, XML escaping, SOAP descendant `detail/faultcode`, non-SOAP preservation, and `ExpectedValue=0` (`XPath.negate=true`). XML offline tests passed for SOAP prefixes `soap` and `env`, wrong URI rejection, and absence-of-Fault rejection.

## INFERENCE

The generator patch is suitable for Console consumption only when the Console package actually embeds this DLL and the migration cache/version is refreshed. That propagation is not established by this local build.

## UNKNOWN / limits

- Apache JMeter 5.6.3 is not installed in this environment (`JMETER_NOT_FOUND`); no real JMeter execution was performed in this round.
- Package `2.0.42`, Console propagation, migration cache identity, source XML -> JMX generation through the production Console, and downstream package hashes remain unverified here.
- SOAP 1.2 is intentionally unsupported; no SOAP 1.2 contract was established.
- No remote queue, push, publication, feed/JFrog action, PR or Azure DevOps mutation occurred.

## FACT — Console round 2

- Clone Console indépendant propre à `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`.
- Nupkg local 2.0.41 vérifié : SHA-256 `7C5C6D5023037838EE15E7DA3C518660D1ACADB20447CA778D61AB62B15409DC`, API embarquée `334155E6...`.
- Le csproj référence `Microsoft.Practices.Unity.Configuration`, `Microsoft.Practices.Unity.RegistrationByConvention`, `XmlDiffPatch` et `XmlDiffPatch.View`, absents des 16 entrées `tools` du nupkg contrôlé.
- Le script `evidence/console/scripts/Invoke-LocalConsolePackage.ps1` contrôle API, Console, dépendances fournies et hashes après extraction.
- L'inventaire XML est livré. Les JMX persistants sont explicitement des références et ne sont pas utilisés comme sources de génération.

## INFERENCE — chaîne suivante

Injecter une DLL API finale hashée, fournir toutes les dépendances, fabriquer le nupkg uniquement dans B, extraire et contrôler toutes les identités, puis exécuter `checkPackage.ps1` avec cache temporaire sous B.

## UNKNOWN / limites ajoutées

- `FB497E...` est candidat non approuvé en attente de non-régression SQL et packaging.
- L'écart API package `51FB...` versus SOAP round13 `57BE...` n'est pas consolidé.
- Compilation Console source, package final, cache/version migration, génération XML legacy→JMX avec ce package et rejeu métier restent non prouvés.
- Les XML quatre-plans exacts restent introuvables dans les sources persistantes ; seul un ancien staging est indexé.
- Un fichier secret aurait été exporté transitoirement puis retiré selon le rapport migration. Aucune valeur n'a été lue, affichée ou copiée ; nettoyage non vérifié indépendamment.

## Round 2 — provenance package et faisabilité

**FACT** — le bundle API local est propre sur la branche `WI-2222897/clienteling/autotest-api-1.1.47`, commit `16a03a83c7e4d9a7c65237f556a4167604ed294b`, avec source `JmeterCodeGen.cs` SHA-256 `01489EDC1AB556C903E9D40EA94356B161048A2F0FD5ED64D3545CAC1BDA605D` et version proposée `1.1.47`.

**FACT** — le push de cette branche a été refusé par AzDO `VS403660` pour l'identité `rjegou@cegid.com`, scope `repository`, permission `CreateBranch`. Aucun contournement ni push vers `master` n'a été tenté.

**FACT borné** — le candidat WORKER 3 `2.0.42-soapnamespace.20260907` (`803DDBAA...`) / API `57BEACA2...` est seulement décrit par les preuves locales; aucun fichier correspondant n'est présent pour extraction indépendante.

**FACT borné** — les preuves existantes relient `57BE...` à la génération SOAP namespace-aware et, dans une collecte de réflexion distincte, à `EscapeJdbcDate` et `FixSqlUnicodeValue`. **UNKNOWN** — lien hashé de `57BE...` avec `RemoveSpecialCharsForXQuery`; les mentions « quatre transformations » n'identifient pas explicitement ce hash.

**FACT** — un package local distinct réellement disponible est conservé dans `evidence/local-2026-09-08-console-package-2.0.42-cleanxpath/`, SHA-256 `82F9C7EE19E635DB14F937078339ED5424A2EDE5BE13B2A10F75A790400D70C0`, API embarquée `51FB31...`; une preuve ciblée établit qu'il ne contient pas le correctif Unicode complet. Il est exploitable pour diagnostic uniquement, pas comme release candidate.

**BLOCAGE** — le build source ne peut pas être reproduit ici sans les reference assemblies officielles .NET Framework 4.5.2 utilisées précédemment; leur téléchargement NuGet a échoué sur `SEC_E_NO_CREDENTIALS`, et aucune installation globale/cible alternative n'a été effectuée.
