# FixSqlUnicodeValue — validation offline

Date : 2026-09-07. Source code modifié : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`, branche `sandbox/rje-wi2222897-escape-jdbc-date`, HEAD observé avant édition avec modification préexistante uniquement sur `EscapeJdbcDate`. Aucun SQL/HTTP métier, package, version, publication ou dépôt partagé touché.

La méthode `FixSqlUnicodeValue` est maintenant publique afin d'être testable par comportement sans réflexion. Elle parcourt les littéraux SQL, reconnaît `''` comme apostrophe échappée et n'ajoute `N` qu'au début d'un littéral contenant un caractère non ASCII, en préservant un préfixe `N` existant.

`validate-fix-sql-unicode.ps1` contient les vecteurs avant/après et extrait le SQL du JMX source `Y2_Plugins_Clienteling-master-build-4432554-exact/Tests/WebServices/073-ItemSearch_Keywords.jmx`, TC02 A-PreQuery1. Le script est une validation de l'algorithme exact, en attendant une DLL API compilée.

Résultats attendus/observés : Unicode simple corrigé, Unicode avec `''` corrigé, ASCII avec `''` inchangé, texte hors littéral inchangé, préfixe N déjà présent inchangé, et SQL TC02 extrait du JMX vérifiant `MAM_MOTCLE=N'` et la conservation d'une apostrophe doublée. Le JMX source contient déjà la sortie historiquement mal formée (`'N'` au milieu); la validation de correction porte donc sur les vecteurs d'entrée et sur la préservation structurelle du JMX, sans prétendre réparer rétroactivement ce snapshot. La compilation du projet net452 reste bloquée par l'absence des assemblies de référence .NET Framework 4.5.2 (`MSB3644`); aucune DLL n'a été produite.

Empreintes : `validate-fix-sql-unicode.ps1` = `047E251D271AD3071823DD73DBF5CE4AE2E4F487A833E5DF0A96A3F4388634C8`; `results.txt` = `DE5C6599A55682BB01832784F024324BF94A9F8D741572B41129806ED47DE558`; JMX source TC02 = `28B4223A6228E062A1EF2D9548DF9A6586FEAD366A0B0EFC98BCD18ABE69D2EE`.
