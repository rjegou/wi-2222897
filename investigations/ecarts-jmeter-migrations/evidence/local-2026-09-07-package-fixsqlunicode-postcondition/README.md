# Postcondition FixSqlUnicodeValue dans l'API package — 2026-09-07

## Objectif

Vérifier le comportement de `FixSqlUnicodeValue` dans la DLL réellement embarquée par le nupkg isolé précédent, puis le comparer à la DLL dédiée du correctif Unicode. Aucun générateur partagé, package feed, SQL, HTTP ou service distant n'a été utilisé.

## FACT

- Le package isolé `Cegid.Retail.AutoTest.Console.2.0.42-cleanxpath.20260907.nupkg` contient l'API SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`.
- L'invocation de sa méthode statique `Cegid.Retail.AutoTest.Api.JmeterCodeGen.FixSqlUnicodeValue(string)` sur `SELECT ... 'NN''é' ...` retourne `SELECT ... 'NN'N'é' ...`. Le littéral SQL reste donc corrompu : cette DLL packagée n'embarque pas le correctif FixSqlUnicodeValue.
- La DLL dédiée du build FixSqlUnicode, SHA-256 `22D85CAA8CA61F30EFADBD611BB584042575A64EB2D78ED3A3637EF1D02D81CC`, retourne `SELECT ... N'NN''é' ...` sur le même vecteur. Ce comportement est la postcondition attendue.
- Les deux invocations ont été faites dans des processus PowerShell séparés pour éviter une collision de chargement d'assembly portant la même identité `1.1.46.0`.

Sorties brutes : `package-api-vector.log` et `fix-unicode-api-vector.log`.

## INFERENCE

La chaîne package/migration validée au round précédent prouve seulement la propagation de la DLL `51FB...` et des corrections qu'elle contient (notamment CleanXpath du lot concerné). Elle ne prouve pas la propagation de FixSqlUnicodeValue. Un package Console/API destiné à ce correctif doit être reconstruit avec la DLL `22D85...` ou une DLL finale équivalente, puis repassé par le contrôle de contenu et `checkPackage.ps1`.

## UNKNOWN

- La DLL `22D85...` n'a pas été injectée dans un nouveau nupkg Console pendant ce lot.
- Aucun package officiel, Console recompilée depuis source, migration complète, JMX Unicode généré via package ou rejeu métier n'est établi ici.
- La compatibilité de la DLL `22D85...` avec le runtime Console 2.0.42 n'est pas démontrée par cette invocation seule.

## Action suivante bornée

Reprendre le staging package isolé avec la DLL `22D85...`, conserver une version locale distincte, inspecter le hash API dans le nupkg, exécuter `checkPackage.ps1`, puis générer uniquement le fixture `ItemSearch:Keywords` sans SQL/HTTP/JMeter métier. Ne pas modifier `consoleWorkflowVersions.json`, le cache partagé ou un dépôt.
