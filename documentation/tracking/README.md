# Suivi des plugins et branches

| Fichier | Statut | Usage |
|---|---|---|
| [repos_to_migrate.xlsx](repos_to_migrate.xlsx) | source reçue, potentiellement obsolète | conserver pour provenance |
| [repos_to_migrate_updated.csv](repos_to_migrate_updated.csv) | recalcul du 2026-09-03 | base lisible issue de l'investigation des dépôts |
| [2026-09-07-bilan-intermediaire-semaine-precedente.md](2026-09-07-bilan-intermediaire-semaine-precedente.md) | snapshot rapporté intégré le 2026-09-07 | bilan intermédiaire fourni par l'utilisateur ; états et liens à revalider |
| [2026-09-07-inventorytracking-live-revalidation.md](2026-09-07-inventorytracking-live-revalidation.md) | revalidation live partielle | build de migration/XmlDiff établis par Worker 2; WI/PR et validation JMeter restent UNKNOWN |

Le CSV reprend volontairement les colonnes `Nom, Branches, Versions` du tableur source. Les ambiguïtés et décisions sont consignées dans [JOURNAL.md](../../JOURNAL.md).

Pour une nouvelle mise à jour, produire un fichier daté dans ce dossier, documenter la règle de calcul et les commits consultés, puis mettre à jour [STATUS.md](../../STATUS.md). Ne pas présenter le CSV comme la preuve que le support Excel/OneNote demandé par le PBI a été actualisé.
