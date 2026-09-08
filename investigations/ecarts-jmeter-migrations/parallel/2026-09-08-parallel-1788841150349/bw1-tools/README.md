# BW1 tools — synthèse API / Console / migration — WI-2222897

Date: 2026-09-08 Europe/Paris. Scope: `Y2_Tools_AutoTest_Api`, `Y2_Tools_AutoTest_Console`, et préparation locale de consommation migration. Toutes les écritures restent dans B.

## Contents

- [`RESULT.md`](RESULT.md): dated verdicts and limits.
- [`CORRECTIONS.md`](CORRECTIONS.md): exhaustive API-scope matrix.
- [`evidence/api/README.md`](evidence/api/README.md): commands, outputs and hashes.
- [`evidence/console/README.md`](evidence/console/README.md): clone, nuspec, dépendances, écart package et inventaire XML.
- [`evidence/console/legacy-source-inventory.tsv`](evidence/console/legacy-source-inventory.tsv): chemins, provenance, hashes et UNKNOWN explicites.
- [`worktrees/api`](../../../../../EXTERNAL-ARTIFACTS.md): independent local clone/copy baseline plus patch.
- [`INTEGRATION.md`](INTEGRATION.md): contract for Console/package consumers.
- [`RESOURCES.md`](RESOURCES.md): resources and cleanup status.
- [`evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/README.md`](evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/README.md): live artifact 5037140 inventory, hashes, and the proven `downloadedPackages.json` contract for the experimental local transport.
- [`evidence/local-2026-09-08-inventorytracking-transport-candidate-round7/README.md`](evidence/local-2026-09-08-inventorytracking-transport-candidate-round7/README.md): independent candidate diff, exact file hashes, positive/negative fixture tests, and review gates.

The baseline source snapshot was clean at `worktrees/Y2_Tools_AutoTest_Api` HEAD `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`; the independent local baseline is commit `8461c8db6ec532834f1b047013716fbc2dd3c718`. No source repository was modified.

## État consolidé

FACT : l'API locale candidate `FB497E2B86B50398952842D573AEB79488C6FA610007295D38EFA07248DA9A89` passe les tests API documentés. FACT : le clone Console est propre à `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`. FACT : le package Console local 2.0.41 vérifié a l'API `334155E6...`, et omet quatre références binaires présentes dans le csproj. INFERENCE : le prochain package doit contrôler explicitement API, Console et toutes les dépendances avant cache. UNKNOWN : compilation Console source, package final avec FB497E..., cache/version de migration, génération source XML→JMX via ce package et rejeu métier.

Incident migration rapporté : un fichier secret aurait été exporté transitoirement puis retiré. Aucune valeur n'a été lue, affichée ou copiée par cette voie. Le retrait et le nettoyage des chemins ne sont pas indépendamment vérifiés tant que le worker migration n'a pas contrôlé ses ressources.
