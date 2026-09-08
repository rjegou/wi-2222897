# Console — préparation isolée round 1

Date : 2026-09-08 (Europe/Paris). Périmètre : `Y2_Tools_AutoTest_Console`, packaging local uniquement. Aucun build lourd, test métier, appel réseau, publication, feed, cache partagé ou dépôt commun n'a été utilisé.

## FACT

- Clone indépendant : `worktrees/console`, obtenu avec `git clone --no-hardlinks --local`.
- Source et clone : branche `master`, HEAD `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`, propres.
- Le nuspec source est `worktrees/console/Cegid.Retail.AutoTest.Console/Cegid.Retail.AutoTest.Console.nuspec`; il prend les binaires depuis `Assemblies/Bin`, dont l'API et l'exécutable Console.
- `scripts/Invoke-LocalConsolePackage.ps1` prépare API→Console→nupkg, compare SHA-256 à chaque étape et écrit uniquement sous `evidence/console` par défaut.
- Le clone cible .NET Framework `v4.5.2`; `packages.config` déclare 12 packages. Le csproj référence notamment API 1.1.46, Model, ColorConsoleTraceListener, CompareFileStream, IndentText, Svn 1.0.4, XmlDiff 1.0.5, CommandLineParser, CommonServiceLocator, Unity 4.0.1 et Prism 6.1.x.
- Le nupkg local 2.0.41 vérifié contient 16 entrées `tools`, mais ne contient pas les références csproj `Microsoft.Practices.Unity.Configuration`, `Microsoft.Practices.Unity.RegistrationByConvention`, `XmlDiffPatch` et `XmlDiffPatch.View`. Cette divergence est un défaut de packaging candidat, pas une preuve de cause unique de migration.

## Écart DLL / package

La preuve package précédente rapporte API `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`. La preuve SOAP round13 rapporte une DLL différente, `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`. La présence de `57BE...` dans un package Console n'est donc pas prouvée par le package précédent. L'addendum `soap-xpath-negative-validation-handoff` reste non revérifié.

## Sources XML à consommer, sans copie brute

Les quatre plans source→JMX prouvés sont `Mobility_UpdateMobileParameters.xml`, `Mobility_GetMobileParameters.xml`, `ItemSearch_GetItemsFacets.xml` et `ItemSearch_GetItems.xml`, issus du snapshot Clienteling master exact. Le scénario `ItemSearch:Keywords` est indexé séparément pour le vecteur Unicode. Les plans FrenchTaxesRules dates sont dans les snapshots V21–V26 sous `Tests/WebServices`, avec entrées/sorties `Validation`/`OutputFiles` ; chemins et hashes doivent être repris depuis les manifestes avant toute régénération. Aucun XML, réponse, paramètre ou secret n'est copié ici.

L'inventaire détaillé, y compris les hash des JMX de référence (explicitement non utilisés comme sources), est `legacy-source-inventory.tsv`. Les XML originaux des quatre plans intégrés ont seulement un ancien chemin de staging dans la preuve 2026-09-07 ; leur disponibilité persistante est `UNKNOWN`.

## Limites

Le script prépare la propagation mais son exécution et la consommation de la future DLL sont réservées au round suivant. Une identité correcte ne prouve ni génération JMX complète, ni orchestration migration, ni réussite métier.
