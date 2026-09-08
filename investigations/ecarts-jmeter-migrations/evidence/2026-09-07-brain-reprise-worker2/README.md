# InventoryTracking — correctif XmlDiff, reprise Worker 2

Date : 2026-09-07 (Europe/Paris)

## Périmètre et provenance

- Dépôt : `Y2_Plugins_InventoryTracking`.
- Checkout isolé : `worktrees/InventoryTracking_Migration_AutoTest_Jmeter_On_master_worker2`.
- Base de migration : `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.
- Correctif local : `ef3d87034d38b88aca04c824061b140e2a29252c` (`Fix InventoryTracking XmlDiff test dependencies`).
- Aucun push, PR, pipeline ou écriture Azure DevOps effectué.

## Correctif testé

Le commit `ef3d8703` ne modifie que :

- `Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj`
- `Cegid.Retail.InventoryTracking.Services.Tests/packages.config`

Il rend explicites dans `Services.Tests` les packages déjà présents dans le `packages.config` supprimé de `WebServices.Tests` : `Cegid.Retail.XmlDiff` `1.0.0` et `XMLDiffPatch` `1.0.8.28`. Les deux références utilisent désormais `Sln\packages`.

## Résultats locaux

FACT — `nuget restore Sln\InventoryTracking.sln -NonInteractive -Verbosity normal` termine avec code `0` ; les deux packages sont présents sous `Sln\packages`.

FACT — MSBuild 17.14.14, cible `ResolveAssemblyReferences`, avec `BuildProjectReferences=false` et les reference assemblies net48 locales, termine avec code `0`. La résolution ciblée de `Cegid.Retail.XmlDiff` et `XMLDiffPatch` est donc démontrée.

FACT — le build complet de la solution termine avec code `1`, mais l’échec observé porte sur des assemblies Cegid absentes dans `ServiceContracts` (`Cegid.Framework`, `Cegid.Retail.Tools/Services`, `VersionningNamespace`, etc.). Ce blocage local est distinct de la résolution XmlDiff ; la réussite CI complète reste UNKNOWN sans agent/restore identiques au pipeline.

FACT — `git diff HEAD~1 --check` est propre et le worktree est propre après validation.

## Azure DevOps live

La tentative de lecture read-only du 2026-09-07 a utilisé le PAT local uniquement en mémoire. La CLI avec `AZURE_CONFIG_DIR` temporaire n’a pas fourni de résultat exploitable car l’extension Azure DevOps n’a pas pu être installée/chargée dans ce profil. Les appels REST/curl de repli ont échoué au handshake Schannel avec `SEC_E_NO_CREDENTIALS (0x8009030E)`.

UNKNOWN — dans cette session, aucune relecture live supplémentaire de WI/relations/PR/branche/build n’est revendiquée. Les faits live antérieurs restent ceux de `azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md` : branche de migration au commit `4de185bb`, build `4434070` en échec sur VSBuild log 51, JMeter skipped, et absence de ref commit explicite pour les templates externes.

## Prochaine validation CI proposée à BRAIN

Utiliser le commit `ef3d87034d38b88aca04c824061b140e2a29252c` dans une branche/queue explicitement isolée, après vérification live de la définition `2072` et des templates résolus. Le test discriminant est le même build de migration avec `Build V26` et `WebServices`/`Services.Tests` activés : le log VSBuild doit ne plus contenir `MSB3245` sur `Cegid.Retail.XmlDiff` ni les quatre `CS0103` correspondantes. Avant queue, examiner les effets de restore JFrog, publications, TestAutos et stages JMeter ; aucun run ne doit être lancé sur cette seule preuve locale.

