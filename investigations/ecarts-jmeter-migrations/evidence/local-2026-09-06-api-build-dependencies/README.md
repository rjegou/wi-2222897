# Dépendances API — collecte isolée

Date : 2026-09-06. Source : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE`, commit `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.

Client : `C:\Program Files\NuGet\nuget.exe`, version fichier `6.12.2.1`. Les commandes fixaient `-OutputDirectory` ici, `-NoHttpCache`, `-DirectDownload`, `-NonInteractive`, `-DisableParallelProcessing` et `-PackageSaveMode nupkg`; aucune configuration ni cache partagé n'a été écrit.

Sources : `https://api.nuget.org/v3/index.json` et `https://cegid.jfrog.io/cegid/api/nuget/all-nuget`. Le probe Artifactory et les trois récupérations privées ont abouti sans prompt; aucun secret n'est consigné. Les journaux ont été contrôlés : zéro ligne contenant password/apikey/token/credential/Authorization.

## Manifeste SHA-256 des nupkg

| package/version | source | nupkg local | SHA-256 | état de la référence projet |
|---|---|---|---|---|
| CommonServiceLocator/1.3 | nuget.org | `packages/CommonServiceLocator.1.3/CommonServiceLocator.1.3.nupkg` | `B6826C427C0223FF7E8F341E3441DA6D1B8E0D172FDB405054BA6BFB76917078` | DLL HintPath présente |
| Unity/4.0.1 | nuget.org | `packages/Unity.4.0.1/Unity.4.0.1.nupkg` | `22CCEFA0F0726AE670A61FB70E90CC5D1C6596EE768B27EA7DE71236152AC548` | deux DLL net45 présentes |
| Prism.Core/6.1.0 | nuget.org | `packages/Prism.Core.6.1.0/Prism.Core.6.1.0.nupkg` | `192EBE3EF1BD08C71961D3145B5A343BBF9D2587AA90388C4D1E27493BA33F72` | `Prism.dll` net45 présente |
| Prism.Wpf/6.1.0 | nuget.org | `packages/Prism.Wpf.6.1.0/Prism.Wpf.6.1.0.nupkg` | `14AAC89F0BAF80847F523DD375A1A06FE52F9C9D0024807AD74D9579967DCB3D` | `Prism.Wpf.dll` net45 présente |
| Prism.Unity/6.1.0 | nuget.org | `packages/Prism.Unity.6.1.0/Prism.Unity.6.1.0.nupkg` | `B41C8C1F2133B82BBA2926F0DE94CE32CB3121CF362A0CEC3117562F5C1B7C4B` | package présent; nom fourni `Prism.Unity.Wpf.dll`, pas le nom attendu |
| Microsoft.NETFramework.ReferenceAssemblies.net452/1.0.3 | nuget.org | `packages/Microsoft.NETFramework.ReferenceAssemblies.net452.1.0.3/...nupkg` | `4533EE146F03EE09F020D12812D02A9959B8A135BC2B867CEEFD68E030DE2CC2` | `mscorlib.dll`/`System.dll` v4.5.2 présentes |
| Cegid.Retail.AutoTest.Model/1.0.6 | Artifactory all-nuget | `packages-private/Cegid.Retail.AutoTest.Model.1.0.6/...nupkg` | `E5F4ADF4F997DDFD742F265212B8C91FD9410CBBCDC815C2F756EE23D7BB3D62` | DLL net452 présente |
| Cegid.Retail.CompareFileStream/1.0.0 | Artifactory all-nuget | `packages-private/Cegid.Retail.CompareFileStream.1.0.0/...nupkg` | `D2F792B736800FC56F004AC789849002BCC8C67A1F00C409EAF2D3AD022F3587` | DLL net452 présente |
| Cegid.Retail.IndentText/1.0.0 | Artifactory all-nuget | `packages-private/Cegid.Retail.IndentText.1.0.0/...nupkg` | `85E4BD4C4750A463D45C20CC31979C93991A9A87988087CE065C40B1DC63B242` | DLL net452 présente |
| Cegid.Retail.Svn/1.0.2 | Artifactory all-nuget | `packages-private/Cegid.Retail.Svn.1.0.2/...nupkg` | `8374B5051F7289E56F3BB2706E63893CEA7841FCF1B8AC96FA95FDA57C734FAB` | DLL net452 présente |
| Cegid.Retail.XmlDiff/1.0.3 | Artifactory all-nuget | `packages-private/Cegid.Retail.XmlDiff.1.0.3/...nupkg` | `1FDCC0CB64482B30626446E6DD5DACC34E523C2CD775CA877BEEFD1614EE4BF2` | trois DLL net452 présentes |

## Manquants et limites

La recherche nuget.org de `System.Windows.Interactivity` n'a trouvé aucun package exact; les DLL locales vérifiées aux emplacements Blend/VS connus n'existent pas. Aucune substitution n'a été téléchargée. Les DLL staging ne sont pas copiées dans `worktrees/...`; les HintPath du projet ne sont donc pas encore satisfaits depuis le worktree. Aucun build, test, restauration de solution, installation système ou modification de fichier source n'a été effectué. Verdict : blocage sur `System.Windows.Interactivity` et le câblage Prism.Unity; compilation UNKNOWN.
