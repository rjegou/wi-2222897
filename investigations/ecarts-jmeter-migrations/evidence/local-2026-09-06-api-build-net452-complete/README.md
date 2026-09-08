# Compilation API — façades net452 complètes

Date : 2026-09-06. Projet compilé seul : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/Cegid.Retail.AutoTest.Api/Cegid.Retail.AutoTest.Api.csproj`, configuration `Debug|AnyCPU`, signature inchangée.

Le targeting pack local `Microsoft.NETFramework.ReferenceAssemblies.net452 1.0.3` fournit 51 DLL sous `build/.NETFramework/v4.5.2/Facades`. Identités vérifiées : `System.Runtime 4.0.10.0`, token `b03f5f7f11d50a3a` ; `System.ObjectModel 4.0.0.0`, même token. Aucun conflit de nom avec les 13 DLL applicatives stagingées.

`RjeNet452CompleteFacades.targets` ajoute l’ensemble wildcard des façades comme références MSBuild, sans modifier le projet. Les 64 DLL sont regroupées dans `staging/allrefs` pour éviter un séparateur de chemin ambigu ; toutes proviennent des preuves locales, aucune assembly runtime/net48 n’est utilisée.

Commande exacte : `logs/command.txt`. MSBuild `17.14.14.31908`, `/t:Build`, sans restauration ; sorties et intermédiaires confinés à `bin/` et `obj/` de cette preuve. La trace MSBuild confirme l’import et la ligne Csc contient `System.Runtime.dll` et `System.ObjectModel.dll` depuis `staging/allrefs`.

Résultat réel : code `0`, zéro avertissement, zéro erreur. Les erreurs `System.Runtime`, `System.ObjectModel` et `DelegateCommand/ICommand` ont disparu. DLL produite : `bin/Cegid.Retail.AutoTest.Api.dll`, identité `Cegid.Retail.AutoTest.Api, Version=1.1.46.0, PublicKeyToken=fe0ce61bd76bef19`, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`.

Les deux worktrees API restent sans sorties générées ; le worktree corrigé conserve seulement sa modification antérieure de `JmeterCodeGen.cs`. Cette compilation ne valide pas la génération JMX.
