# CleanXpath — validation locale

Date : 2026-09-07. Source modifiée : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`, branche `sandbox/rje-wi2222897-escape-jdbc-date`. La modification conserve `EscapeJdbcDate` et `FixSqlUnicodeValue`; `RemoveSpecialCharsForXQuery` n'est pas modifiée.

## FACT

- Le défaut est reproduit dans le snapshot API : `path.Replace("soap:Fault", string.Empty)` transforme `/soap:Fault` en `/`, puis la normalisation en `//`.
- Le snapshot legacy indexé `evidence/legacy/raw/primary-package-extracted/.../IntegratedTests/AutoTest/Data/WebServices/TestPlans/` contient l'entrée réelle `ItemSearch_Keywords.xml` et des contrôles `/soap:Fault`; elle n'est pas un JMX déjà transformé.
- Correction : remplacement du préfixe `soap:Fault` par `Fault`, méthode publique testable par comportement.
- Compilation isolée réelle : MSBuild BuildTools 17.14.14, targeting pack net452 1.0.3 et façades stagingées; code 0, DLL SHA-256 `5D7974252D1F7856A23DBBC6FACE10C751822434F7EB9CFFFE69E842EDAB4B15`.
- `tests/CleanXpath.tests.ps1` charge cette DLL de production et valide `/soap:Fault`, prédicat, descendants, témoins non-Fault et sélection dans un XML SOAP synthétique namespace-aware. Le test Unicode durable existant charge aussi cette DLL et ses neuf vecteurs passent.

## INFERENCE / UNKNOWN

La correction est directement reliée à la source legacy et à la génération API, mais une génération intégrée complète de `ItemSearch_Keywords.xml` vers JMX n'a pas été exécutée dans ce lot : l'ancien harness Unicode lisait un JMX déjà transformé. La réussite métier et la consommation par Console/migration restent UNKNOWN.

Round 4 `worktrees/WI-2222897-v26-fix-replay-draft-round4/` reste un brouillon de préflight : runner testé avec `jmeter.bat` substitué, aucune attestation réelle SQL/IIS; Java détecté 23, cible 21 non validée; acquisitions et Azure CLI restent non vérifiées/accessibles.

Provenance : workspace local, chemin et commit ci-dessus, collecte 2026-09-07; voir `logs/build.log` et `tests/CleanXpath.tests.ps1`. Aucun SQL/HTTP métier, JMeter métier, package, publication ou système partagé n'a été utilisé.

Tentative intégrée 2026-09-07 : le launcher Console officiel a été exécuté avec la source legacy `ItemSearch_Keywords.xml` et la DLL corrigée dans un staging neuf. Bootstrap réussi, puis `System.IO.PathTooLongException` dans `JmeterGenerator.CloneDirectory` avant création du JMX. Le staging workspace est trop profond pour .NET Framework; aucun chemin système court ni `subst` n'a été utilisé. Cette tentative ne prouve donc pas la génération intégrée.

Empreinte du journal de tentative : `cleanxpath-integrated/console.log` SHA-256 `F4599515D333BB2289626D0D3D4B70754BB52B7F030BD66420A8096771FAF0C3`; le dossier output ne contient aucun fichier produit.
