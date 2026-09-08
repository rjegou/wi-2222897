# Matrice des corrections — périmètre migration

| cible | cause | avant/après exécuté | statut |
|---|---|---|---|
| `migration-tools/consoleWorkflowVersions.json` → `packages.config` | aucune cause de défaut prouvée | lecture statique + cache attendu 2.0.41 | FACT, mécanisme validé |
| `migration-tools/checkPackage.ps1` | aucune cause de défaut prouvée | cache absent/installé valide/mismatch, codes 0/0/1 | FACT, aucun patch |
| `Testautos2Jmeter.bat` | appel installer; installer présent côté plugin, absent de `migration-tools` | audit statique, pas de changement | UNKNOWN par plugin; aucun patch |
| `step_x_06_deref_avant_PR.ps1` | retrait initial limité à `WebServices.Tests`, laissant `LegacyServices.Tests` dans l’arbre et la solution | fixture avant/après; deux dossiers et deux blocs `.sln` retirés; `Y2.Core.Common` conservé | CORRIGÉ localement; validation plugin réel requise |
| propagation Console corrigée → migration | aucun package corrigé local disponible ici | non exécuté | UNKNOWN |

Le patch est limité au mécanisme générique de déréférencement. InventoryTracking/BW3 n’est pas touché. La validation sur plugin réel et la conservation exhaustive de ses références restent à faire.
