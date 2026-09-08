# Trois chantiers BW isolés — 2026-09-08

Statut : commandes proposées, aucune instance lancée. [Contrat commun](CONTRAT.md).

| Chantier | Valeur | Mission | Espace exclusif |
|---|---|---|---|
| couverture | Couverture BeforeMigration et chaîne de génération isolée | [Mission](couverture.md) | C:/clones/wi-2222897-bw/20260908/couverture |
| inventorytracking | InventoryTracking : restaurer la campagne de 86 tests | [Mission](inventorytracking.md) | C:/clones/wi-2222897-bw/20260908/inventorytracking |
| clienteling | Clienteling : retrouver le backup V26 et le transport des images | [Mission](clienteling.md) | C:/clones/wi-2222897-bw/20260908/clienteling |

## Commandes PowerShell proposées

A exécuter chacune dans un terminal distinct, une seule fois par espace. Ne pas lancer si une
session y est déjà active ; vérifier les PID de cette session sans interrompre les autres.
Syntaxe vérifiée par lecture de C:/Users/jegour/bin/bw.cmd et brain-worker/remote.ps1 le 2026-09-08.
Les trois espaces existent ; run.ps1 exige un Path résoluble. Aucun test de lancement effectué.

```powershell
bw -Mission "Lire C:/clones/wi-2222897-bw/20260908/couverture/AGENTS.md et executer uniquement la mission attribuee." -Path "C:/clones/wi-2222897-bw/20260908/couverture" -MaxRounds 12

bw -Mission "Lire C:/clones/wi-2222897-bw/20260908/inventorytracking/AGENTS.md et executer uniquement la mission attribuee." -Path "C:/clones/wi-2222897-bw/20260908/inventorytracking" -MaxRounds 12

bw -Mission "Lire C:/clones/wi-2222897-bw/20260908/clienteling/AGENTS.md et executer uniquement la mission attribuee." -Path "C:/clones/wi-2222897-bw/20260908/clienteling" -MaxRounds 12
```

## Consolidation après les trois résultats

L'intégrateur relit RESULT.md, hashes et tests dans chaque espace, puis intègre une seule fois les
findings, matrices, décisions, STATUS et JOURNAL. Les instances ne committent jamais le dépôt commun.
Les preuves volumineuses restent hors dépôt. La validation métier et toute publication partagée
restent distinctes des preuves locales. FrenchTaxesRules (rejeu corrigé V26 et minima V22 Fix) et
Full-Text restent au backlog ; ils ne sont pas oubliés ni déclarés résolus par ce lot.
