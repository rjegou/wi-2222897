---
type: "Mission"
title: "WI-2222897 — Migration TestAuto Legacy vers JMeter"
description: "Point d'entrée du dépôt : état, décisions bloquantes, parcours par tâche, et périmètre de ce qui est versionné."
resource: "WI-2222897/README.md"
tags: ["jmeter", "testauto", "migration", "pipeline"]
timestamp: "2026-09-08"
source_system: "local-kb"
---

# WI-2222897 — Migration TestAuto Legacy vers JMeter

Dépôt de travail du PBI [2222897](https://dev.azure.com/cegid/Retail/_workitems/edit/2222897).
Il porte la mise à jour de l'outil de migration, la migration des derniers couples plugin/branche, et
le diagnostic des écarts entre les tests legacy et les tests JMeter.

## État en une minute

Au **2026-09-08** : le diagnostic est terminé sur 8 des 9 couples suivis — chaque cas non passé est
rattaché à une cause. Les quatre défauts du générateur JMX sont corrigés localement. Le périmètre
Clienteling est fixé à `master`, `releases/V6`, `releases/V7`, `releases/V8` ; les minima de
configuration FrenchTaxesRules V22 Fix doivent être relevés. Les images Clienteling sont à
investiguer. Trois arbitrages restent ouverts : Products, BeforeMigration.ps1 et publication NuGet
partagée (ces deux derniers à clarifier).

S'y ajoutent trois blocages techniques du rejeu, ouverts par les
[synthèses de pause du 2026-09-08](investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/README.md)
et non encore revérifiés : InventoryTracking perd les 86 tests de `002-Device:Reassign`, que JMeter
échoue à charger ([finding 015](investigations/ecarts-jmeter-migrations/findings/015-inventorytracking-002-device-reassign-jmx-load-4445575.md)) ;
Clienteling ne peut plus matérialiser son backup V26, absent de l'arbre Git actuel
([finding 016](investigations/ecarts-jmeter-migrations/findings/016-clienteling-v26-backup-lfs-absent.md)) ;
FrenchTaxesRules a ses 18 JMX corrigés poussés sur une branche de validation, mais aucun run ne les a
encore exécutés.

| Je veux… | Lire |
|---|---|
| savoir ce qui bloque et qui doit trancher | **[decisions/README.md](decisions/README.md)** — 3 arbitrages ouverts et 1 investigation technique |
| l'état par domaine | [STATUS.md](STATUS.md) |
| ce qu'on dit au PO et au lead dev | [reporting/2026-09-08-synthese-onenote-pbi.md](reporting/2026-09-08-synthese-onenote-pbi.md) |
| la cause d'un échec précis | [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md), puis le `findings/` cité |
| ce qu'il faut implémenter, et où | [CORRECTION_PLAN.md](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) |
| les corrections déjà écrites | [patches/README.md](patches/README.md) |
| reprendre le fil d'une investigation | [HANDOFF.md](investigations/ecarts-jmeter-migrations/HANDOFF.md) |
| l'historique jour par jour | [JOURNAL.md](JOURNAL.md), [archive/status-history-2026-09.md](archive/status-history-2026-09.md) |

## Le résultat à retenir

Un nombre d'échecs n'est pas un nombre de régressions. Sur la campagne Clienteling master V26
documentée, les 485 cas non passés — identiques en Cur et en Fix — se répartissaient ainsi :
**224 étaient associés à un problème d'infrastructure** (SQL Full-Text), **105 à quatre défauts
du générateur JMX** (tous corrigés,
[`patches/`](patches/README.md)), le reste de métadonnées, de fixtures et de sujets produit à trancher.
Détail dans [finding 006](investigations/ecarts-jmeter-migrations/findings/006-clienteling-v26-build-4432554.md).

## Ce que ce dépôt contient, et ne contient pas

Ce dépôt versionne la **couche documentaire** : Markdown, index, manifestes, empreintes, scripts,
patches — environ 60 Mo. Les clones Git, les snapshots de dépôts et les artefacts bruts volumineux
(environ 8,5 Go) restent hors dépôt : emplacements, commits de reconstitution et verdict de
conservation dans **[EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md)**.

Conséquence pratique : un lien vers un dossier de preuve résout bien, et son `README.md` de provenance
est présent, mais les fichiers bruts lourds n'y sont pas. La colonne « hors dépôt » de
[l'index des preuves](investigations/ecarts-jmeter-migrations/evidence/README.md) dit précisément ce
qui manque et où le retrouver.

## Carte du dépôt

```text
wi-2222897/
├── README.md                 point d'entrée et routage
├── AGENTS.md                 règles de travail, y compris pour un agent
├── STATUS.md                 état courant, sans historique
├── JOURNAL.md                trace chronologique des sessions
├── RESOURCES.md              ressources temporaires et dépollution
├── TASKS.md                  parcours lire/produire par type de tâche
├── EXTERNAL-ARTIFACTS.md     ce qui est resté hors dépôt, et comment le retrouver
├── decisions/                registre des arbitrages en attente
├── reporting/                synthèses destinées au PO et au lead dev
├── patches/                  corrections extraites des clones, avec leur mode de réapplication
├── documentation/            guides, contexte, suivi, PDF sources
├── investigations/           enquêtes, chacune avec findings, matrices et index de preuves
└── archive/                  historique d'état et documents remplacés
```

## Périmètre du WI

- `master` / V26 cible l'image `win2025sql2025dotnet10` ; les autres branches supportées ciblent
  `win2022sql2019dotnet10`.
- Pour V21 et inférieur, les étapes de publication et de campagne sont désactivées avant création de
  PR. Au-delà de V21, le pipeline doit réellement exécuter build **et** tests avant de conclure.
- Objectif enregistré : appliquer les images Docker attendues selon la version, migrer les derniers
  plugins/branches, inventorier les erreurs restantes, mettre à jour le suivi et notifier les
  interlocuteurs.

Snapshot local, pas une lecture live du work item. Détail et provenance dans
[documentation/context/](documentation/context/README.md).

## Règle de fermeture d'une session

1. mettre à jour le document canonique touché par la tâche ;
2. actualiser [STATUS.md](STATUS.md) si un verdict, un blocage ou une prochaine action change ;
3. actualiser [decisions/README.md](decisions/README.md) si un arbitrage est rendu ;
4. ajouter une entrée à [JOURNAL.md](JOURNAL.md) ;
5. mettre à jour [RESOURCES.md](RESOURCES.md) si une ressource temporaire bouge.

Ce dépôt étant versionné, un commit par session cohérente vaut mieux qu'un commit fourre-tout.
