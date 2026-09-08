# Revue offline worker 1 — InventoryTracking / XmlDiff

Date : 2026-09-07 (Europe/Paris)

## Sources vérifiées

- `../azure-devops-inventorytracking-2026-09-07-worker2-round2/xml-diff-evidence.txt`, SHA-256 vérifié contre `SHA256SUMS.txt` : `418477637F81EFFEB85E05771850EE489045FFED0247D32771D767C88B1F2FE6`.
- `../azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md` et `MANIFEST.csv`, hashes vérifiés : README `2BAE2F8634F90F9C145C2383D63E4571D5507AD6A5856415F5A970A7A3C710FB`; manifest `B143E287E09D1CA9015C42E02BD1B37C275C7338B3EEAEF99BF39DC064C58723`.
- `worktrees/Migration_Jmeter_RJE_Sandbox/step_x_06_deref_avant_PR.ps1`, lu en lecture seule; état Git non vérifiable dans ce contexte à cause de `safe.directory`/propriétaire différent.

## Chaîne reconstituée

**FACT** — le commit `4de185bb...` supprime `Cegid.Retail.InventoryTracking.WebServices.Tests` et son `packages.config` (source primaire, `xml-diff-evidence.txt:27-28`). Ce fichier supprimé déclarait `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28` (`:19-21`).

**FACT** — `Services.Tests.csproj` conserve la référence `Cegid.Retail.XmlDiff` avec `HintPath=..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll` (`:7-10`), tandis que le `packages.config` Services.Tests conservé ne déclare pas XmlDiff (`:19-21`).

**FACT** — `ExternalsToRestore_V26.xml` restaure quatre packages, et le log 44 est rapporté comme preuve de restauration réussie de `Cegid.Retail.Y2.Core.Net.Full 26.0.0.1030` (`:12-17`, `:23-25`). Cela ne prouve pas que le DLL XmlDiff est contenu dans ce package.

**FACT de provenance worker 2** — le log 51 de 4434070 est rapporté avec `MSB3245` sur `Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`, puis quatre `CS0103` sur `XmlDiff`; le log 45 de 4435986 est rapporté avec un DLL provenant de `Sln\packages\Cegid.Retail.XmlDiff.1.0.0` et copié vers `Assemblies\Bin` (`:23-25`). Le contenu brut des logs 44/45/51 n’est pas présent : la résolution MSBuild n’est donc pas directement réexaminable ici.

## Code de migration ciblé

**FACT** — `step_x_06_deref_avant_PR.ps1:53-60` déduit le nom du plugin depuis le premier dossier `Y2_Plugins_*` (`:6-17`), puis supprime systématiquement le dossier `<plugin>.WebServices.Tests` s’il existe.

**FACT** — le même script supprime les lignes `Cegid.Retail.XmlDiff.dll`, `Cegid.Retail.XmlDiff.xml` et `xmldiffpatch.dll` du `.Tests.nuspec` (`:160-203`). Il ne supprime pas XmlDiff d’un `packages.config` de Services.Tests : la section `:135-157` retire uniquement `Cegid.Retail.AutoTest.Console` de `PublishedSharedTools/packages.config`.

**INFERENCE** — l’outil de migration peut systématiquement retirer le projet WebServices.Tests et les entrées de packaging XmlDiff, alors qu’un projet Services.Tests conservé utilise encore la référence XmlDiff. La preuve établit un risque causal concret pour cette branche, mais ne prouve pas à elle seule que ce script a été exécuté pour produire exactement `4de185bb...` ni que le package Core ne contient jamais le DLL.

## Maillons manquants

- **UNKNOWN** : contenu brut numéroté des logs de restauration 44, compilation 51 et master 45; les extraits rapportés n’ont pas de fichier primaire local.
- **UNKNOWN** : contenu du package `Cegid.Retail.Y2.Core.Net.Full 26.0.0.1030` et présence/absence effective de `Cegid.Retail.XmlDiff.dll`.
- **UNKNOWN** : mapping exact du `.Tests.nuspec` supprimé vers les fichiers du commit et preuve d’exécution du script sur InventoryTracking.
- **UNKNOWN** : cause exacte de non-résolution (package absent, destination Y2Core non alimentée, ou référence obsolète); `MSB3245` est la cause immédiate rapportée, pas encore la cause racine finale.

## Contrôle durable borné au PBI

Ajouter dans une validation locale isolée un contrôle statique avant `VSBuild` : pour chaque `Reference Include` non framework dans les projets `*.Tests.csproj`, résoudre le `HintPath` et vérifier l’existence du DLL; pour chaque DLL, rechercher une source déclarative (`packages.config`, `ExternalsToRestore_V*.xml`, ou contenu package) et signaler toute référence sans acquisition. Le contrôle doit échouer explicitement sur `Cegid.Retail.XmlDiff` dans Services.Tests, sans modifier le dépôt ni lancer de pipeline. Le test discriminant suivant est un build local du commit `4de185bb...` avec acquisition XmlDiff explicitement tracée, puis comparaison des erreurs `MSB3245`/`CS0103`.
