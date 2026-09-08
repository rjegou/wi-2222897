# Résultat InventoryTracking — 2026-09-08

## Verdict

**FACT** — Le build `4434070`, branche `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, commit `4de185bb...`, échoue d'abord sur `MSB3245` pour `Cegid.Retail.XmlDiff`, puis sur quatre `CS0103`; les stages JMeter sont skipped. Preuve primaire relue : `evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md`.

**FACT** — Le commit de migration supprime `WebServices.Tests/packages.config`, qui contenait `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28`, tandis que `Services.Tests` garde quatre usages de `XmlDiff` et sa référence historique. `4435986` master est vert mais son YAML ne contient pas `TI_Jmeter_V26`; il ne valide pas la migration.

**FACT** — Le clone privé contient le correctif minimal déjà matérialisé par le commit `ef3d87034d38b88aca04c824061b140e2a29252c` : ownership explicite des deux packages dans `Services.Tests/packages.config` et HintPath NuGet dans le `.csproj`.

## Tests

- `nuget restore .\Sln\InventoryTracking.sln -NonInteractive` : code 0; packages déjà présents. Avertissement NU1900 d'accès aux données de vulnérabilité NuGet.
- `MSBuild ...Services.Tests.csproj /t:ResolveAssemblyReferences /p:BuildProjectReferences=false /p:Restore=false` : code 0; la sortie diagnostique montre les deux DLL résolues depuis `Sln\packages`. Avertissements indépendants MSB3644 (.NET 4.8 targeting pack) et MSB3270 (architecture).
- Build complet : **NOT RUN / non concluant**. Le poste manque le targeting pack .NET 4.8 et plusieurs assemblies Cegid externes; cette limite est distincte de XmlDiff.
- Contrôle avant strict avec suppression de la DLL : **NOT RUN** (le test de copie de 311 MB dans le chemin long n'a pas permis de relancer MSBuild avec un répertoire de travail valide). Le baseline statique conserve le HintPath `..\Assemblies\Y2Core\...`; aucune prétention de reproduire le MSB3245 localement.

**UNKNOWN** — restauration/package réellement consommés par le pipeline au commit `4de185bb`, propagation au générateur/migrateur et résultat métier JMeter. Les revendications distantes `4440774`/`4440884` restent non revérifiées dans ce round.
