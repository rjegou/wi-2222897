# Compilation API avec façades net452

Date : 2026-09-06. Le journal précédent montre `FrameworkPathOverride` sur `build/.NETFramework/v4.5.2`, mais la ligne Csc ne contenait aucune référence `Facades/System.Runtime.dll`; la première erreur était donc une résolution incomplète, et non une absence de DLL.

Le package `Microsoft.NETFramework.ReferenceAssemblies.net452 1.0.3` contient `build/.NETFramework/v4.5.2/Facades/System.Runtime.dll`, identité lue sans exécution : `System.Runtime, Version=4.0.10.0, PublicKeyToken=b03f5f7f11d50a3a`. Son `.targets` désactive `FrameworkPathOverride`, active `NoStdLib` et ajoute `mscorlib`, mais n'ajoute pas automatiquement les façades.

Configuration locale : `RjeNet452Facades.targets`, passée via `CustomAfterMicrosoftCommonTargets`. Elle ajoute uniquement cette façade exacte par `Reference/HintPath` et émet une trace `RJE net452 facade import active`. La ligne Csc du nouveau journal contient effectivement `...staging/facades/System.Runtime.dll`.

MSBuild `17.14.14.31908` a compilé une seule fois le `.csproj`, en `Debug|AnyCPU`, avec signature inchangée et sorties `bin/obj` dans ce dossier. Code de sortie : `1`, zéro avertissement, deux erreurs.

Première erreur causale après correction : `UnitTest.cs(507,29) CS0012`, `System.ObjectModel, Version=4.0.0.0, PublicKeyToken=b03f5f7f11d50a3a` non référencé. L'erreur `CS0266` sur `Prism.Commands.DelegateCommand`/`ICommand` est associée à cette façade manquante. Aucun nouvel essai n'a été lancé.

Le worktree initial reste propre ; le worktree corrigé conserve uniquement `JmeterCodeGen.cs`. Aucun `bin`, `obj`, `Assemblies/Bin` ou `Assemblies/XML` n'a été créé dans les worktrees. Aucune DLL API n'a été produite ; génération JMX UNKNOWN.
