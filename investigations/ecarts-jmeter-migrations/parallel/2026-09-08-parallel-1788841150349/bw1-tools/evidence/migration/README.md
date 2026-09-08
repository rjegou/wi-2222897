# BW1 migration evidence — 2026-09-08

Périmètre : mécanisme local `Migration_Jmeter_RJE_Sandbox` de sélection Console/cache/package et appel de génération. Collecte hors réseau métier, sans publication ni queue.

Sources auditées : snapshot source HEAD `13144a2fb5ef7c822fff3c0a64fed88e72339981`; clone indépendant par export Git des fichiers suivis puis dépôt local; le clone direct a échoué avec `fatal: '$GIT_DIR' too big`. Le secret `jfrogToken.txt` a été détecté dans l’export sans ouverture, retiré immédiatement, puis l’historique local a été purgé; aucune valeur n’est conservée.

Fichiers clés et empreintes du clone :

| fichier | SHA-256 |
|---|---|
| `migration-tools/checkPackage.ps1` | `A7F4520294523291B54320DC980A0163BE2504A230329B312691B2BC5462C18D` |
| `Testautos2Jmeter.bat` | `479EC7F3C0319AEECC275AFF0BAAFB4CD0C979A4F003CD2DCA7FCEA2B4B2B2C5` |
| `migration-tools/consoleWorkflowVersions.json` | `8D04FD78390A56DD6C74C70F4BDC519FB12BB1B66A9A328A46EC5FECEE863B52` |

Le package de fixture est le cache existant, version nuspec `2.0.41`, SHA-256 `7C5C6D5023037838EE15E7DA3C518660D1ACADB20447CA778D61AB62B15409DC`.

Le test avant/après déréférencement est archivé sous `mstest-deref-run.txt` et `mstest-deref-final-postcondition.txt`. L’avant laissait `LegacyServices.Tests`; le patch local retire les deux dossiers et projets `.sln`, sans retirer `Y2.Core.Common` dans la fixture multi-ligne.
