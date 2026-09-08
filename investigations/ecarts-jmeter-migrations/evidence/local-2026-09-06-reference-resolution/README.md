# Résolution des références — preuve isolée

Date : 2026-09-06. Worktree inspecté : `Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE`, commit `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` avec la modification antérieure conservée.

## Références du projet

`System.Windows.Interactivity` est demandé directement dans `Cegid.Retail.AutoTest.Api.csproj`, sans `HintPath`, sans `SpecificVersion` et sans condition : `Version=4.5.0.0`, `PublicKeyToken=31bf3856ad364e35`. Aucun usage C# direct de ce nom n'a été trouvé ; les usages `InteractionRequest` viennent de `Prism.Interactivity`.

`Prism.Unity` apparaît dans `packages.config` en version `6.1.0`, mais aucune référence `<Reference Include="Prism.Unity...">` n'existe dans le `.csproj`. Le projet demande `Prism.Wpf, Version=6.1.0.0, PublicKeyToken=91a96d2a154366d8`, via son HintPath net45. `Prism.Unity 6.1.0` expose `Prism.Unity.Wpf.dll`, avec l'identité `Prism.Unity.Wpf, Version=6.1.0.0, PublicKeyToken=91a96d2a154366d8`; son nuspec net45 dépend de Unity 4.0.1, CommonServiceLocator 1.3 et Prism.Wpf 6.1.0. Il n'y a donc pas d'incompatibilité de référence Prism à résoudre.

## Candidats inspectés

| package/version | DLL / cible | identité lue | SHA-256 nupkg | verdict |
|---|---|---|---|---|
| Expression.Blend.Sdk.WPF/1.0.1 | `lib/net45/System.Windows.Interactivity.dll` | `System.Windows.Interactivity, 4.5.0.0, 31bf3856ad364e35` | `252A7CB60704030D651744D1595B7E5C0010B9791B0FFC11BF7B3475B122F3DF` | compatible |
| System.Windows.Interactivity.WPF/2.0.20525 | `lib/net40/System.Windows.Interactivity.dll` | `4.0.0.0, 31bf3856ad364e35` | `C957C78DA19E55B3A4EFF69C2D4713BF2057701790D967A2F8771705794E4DAD` | incompatible avec la version demandée |
| Trans.System.Windows.Interactivity/3.0.40218.1 | `lib/netcoreapp3.1` et `lib/netstandard2.0` | `4.5.0.0, 31bf3856ad364e35` | `95C8121554ACD9C448885C921219914DE8A3DFBCFAE8AAFE8D34A4E61B856B47` | identité exacte, cible non net452 |
| Blend.Interactivity.Wpf/1.0.1340 | `lib/net/System.Windows.Interactivity.dll` | `3.5.0.0, 31bf3856ad364e35` | `495593E35C36FAF90CC2E0D797073F45D2690EF99753034F284E3E1941B476CF` | version incompatible |
| Unofficial.System.Windows.Interactivity/1.0.0.2 | `lib/sl50/System.Windows.Interactivity.dll` | `5.0.5.0, 31bf3856ad364e35` | `2AF96DE1CA1FF5EFFEB9544A5E271B9C2A33C6AD811691DD52694E3930AE5A49` | cible/version incompatibles |
| RoyWpf.System.Windows.Interactivity/0.1.2 | `lib/netcoreapp3.1/System.Windows.Interactivity.dll` | `0.1.2.0`, token vide | `5A225FF245BF169380C34BABE8A062DFCA8EECDD8B04B38831E280C69A5FA30F` | incompatible |

## Résolution proposée

Pour une compilation isolée, fournir `System.Windows.Interactivity.dll` depuis `packages/Expression.Blend.Sdk.WPF.1.0.1/lib/net45/System.Windows.Interactivity.dll` à la référence sans HintPath, dans le répertoire de staging MSBuild (sans modifier le `.csproj`). Les références Prism restent celles du projet : `packages/Prism.Core.6.1.0/lib/net45/Prism.dll` et `packages/Prism.Wpf.6.1.0/lib/net45/Prism.Wpf.dll`; `Prism.Unity.Wpf.dll` est disponible sous `local-2026-09-06-api-build-dependencies/packages/Prism.Unity.6.1.0/lib/net45/` si une résolution transitive le demande.

Les recherches NuGet publiques et Artifactory `all-nuget` ont été faites en lecture seule. Les commandes et logs sont dans `logs/`; aucun secret n'y figure. Aucun projet, cache partagé, SDK système, build ou test n'a été exécuté.
