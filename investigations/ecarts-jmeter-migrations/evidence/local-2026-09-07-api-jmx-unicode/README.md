# Génération intégrée JMX — FixSqlUnicodeValue

Date : 2026-09-07. Source canonique lue : `sources/Y2_Plugins_Clienteling-master-build-4432554-exact/Tests/WebServices/073-ItemSearch_Keywords.jmx`, cas `ItemSearch:Keywords` TC02 A-PreQuery1. Le harnais appelle directement `JmeterCodeGen.GenerateJmeter`; aucune réflexion, SQL, HTTP, JMeter métier ou publication.

Compilation API : MSBuild BuildTools 17.14.14 avec le targeting pack net452 1.0.3, les 51 façades et les dépendances stagingées dans la preuve du 2026-09-06. Code retour `0`, DLL produite sous `local-2026-09-07-api-build-fix-sql-unicode/bin/`, SHA-256 `22D85CAA8CA61F30EFADBD611BB584042575A64EB2D78ED3A3637EF1D02D81CC`.

Génération avant/après : assembly originale SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81` produit un JMX TC02 où `MAM_MOTCLE=NN'`; assembly corrigée produit `MAM_MOTCLE=N'` et conserve l'apostrophe SQL doublée. JMX originel hash `2BE4F66F35195CDFEE6C60D4EA5168A7D19AE98E9E5585DC67EA7348063873F1`; corrigé hash `D2535F92B17043E9AA4AD4D21036558193D998545B4981048FD78F4DCAAC7EBE`.

Les neuf vecteurs durables de `tests/FixSqlUnicodeValue.tests.ps1` passent contre la DLL corrigée : Unicode simple, Unicode avec `''`, ASCII avec `''`, hors littéral, préfixe N, littéraux multiples, commentaire ligne, commentaire bloc et identifiants délimités. La compilation et la génération intégrées sont donc `FACT` pour cette DLL et ce scénario. La propagation Console/migration, le package publié et la réussite métier restent `UNKNOWN`.
