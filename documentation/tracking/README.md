# Suivi des plugins et branches

| Fichier | Statut | Usage |
|---|---|---|
| [repos_to_migrate.xlsx](repos_to_migrate.xlsx) | source reçue, potentiellement obsolète | conserver pour provenance |
| [repos_to_migrate_updated.csv](repos_to_migrate_updated.csv) | recalcul du 2026-09-03 | base lisible issue de l'investigation des dépôts |
| [2026-09-07-bilan-intermediaire-semaine-precedente.md](2026-09-07-bilan-intermediaire-semaine-precedente.md) | snapshot rapporté intégré le 2026-09-07 | bilan intermédiaire fourni par l'utilisateur ; états et liens à revalider |
| [2026-09-07-inventorytracking-live-revalidation.md](2026-09-07-inventorytracking-live-revalidation.md) | revalidation live partielle | build de migration/XmlDiff établis par Worker 2; WI/PR et validation JMeter restent UNKNOWN |

Le CSV reprend volontairement les colonnes `Nom, Branches, Versions` du tableur source. Les ambiguïtés et décisions sont consignées dans [JOURNAL.md](../../JOURNAL.md).

Pour une nouvelle mise à jour, produire un fichier daté dans ce dossier, documenter la règle de calcul et les commits consultés, puis mettre à jour [STATUS.md](../../STATUS.md). Ne pas présenter le CSV comme la preuve que le support Excel/OneNote demandé par le PBI a été actualisé.

## Dépôts Azure DevOps investigués pendant WI-2222897

Liste consolidée à partir des clones/worktrees et des preuves de l'investigation. Tous relèvent du
projet `cegid/Retail` et suivent le format
`https://dev.azure.com/cegid/Retail/_git/<nom>`.

### Dépôts principaux — clones, worktrees ou snapshots

| Dépôt | Périmètre investigué |
|---|---|
| `Migration_Jmeter_RJE_Sandbox` | outil d'orchestration et régénération des JMX |
| `Y2_Tools_Jmeter_Workflow` | workflow, images et exécution JMeter |
| `Y2_Tools_AutoTest_Api` | générateur JMX et corrections de transformation SQL/XPath |
| `Y2_Tools_AutoTest_Console` | chaîne Console/API et génération de campagnes |
| `Y2_Plugins_Clienteling` | campagnes Clienteling, branches V26 et historiques V21–V25 |
| `Y2_Plugins_FrenchTaxesRules` | campagnes FrenchTaxesRules, notamment V22 et V26 |
| `Y2_Plugins_InventoryTracking` | campagne InventoryTracking, XMLDiff et cas `002-Device_Reassign` |
| `Pipelines_Docker_BaseImages` | images SQL 2019/2025 et diagnostic Full-Text |
| `Y2_Tools_PlatformDeploy` | transport, déploiement et propagation des codes de retour |

### Dépôts de support consultés dans les preuves

| Dépôt | Rôle dans l'investigation |
|---|---|
| `Pipelines_Templates` | templates YAML de restauration, build, publication et campagnes |
| `Y2_Core` | provenance des dépendances et des versions runtime restaurées |
| `Y2_SaaS_Packaging` | provenance d'un package de packaging V22 consulté côté JFrog |

Les dépôts de support ne constituent pas des dépôts de correction du WI. Les noms présents dans des
chemins d'artefacts ou des configurations, mais sans investigation directe établie dans les preuves,
ne sont pas ajoutés à cette liste. La liste des clones supprimés et leur correspondance avec le dépôt
d'origine restent détaillées dans [EXTERNAL-ARTIFACTS.md](../../EXTERNAL-ARTIFACTS.md).
