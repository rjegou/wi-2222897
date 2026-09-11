---
type: "Preuve"
title: "Attestation de campagne round 4 (4 builds) et gabarit de transport local — copie du clone bw relais-20260909-02"
description: "Couche documentaire copiée sans modification depuis un clone hors dépôt ; empreintes SHA-256 recalculées et confrontées à celles déclarées par la source."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-attestation-campagne-round4/README.md"
tags: ["jmeter", "testauto", "migration", "preuve", "provenance", "azure-devops"]
timestamp: "2026-09-09"
source_system: "local-kb"
---

# Rangement — attestation de campagne round 4 et gabarit de transport local (2026-09-09)

## Provenance

- **Source** : `C:\clones\wi-2222897-bw\relais-20260909-02\attestation\` — clone de travail hors
  dépôt (non versionné, non sauvegardé par ce dépôt), espace « BW » au sens de
  [RESOURCES.md](../../../../RESOURCES.md#espaces-bw-préparés-le-2026-09-08--instances-non-lancées).
- **Méthode de collecte** : copie binaire directe (`cp`), sans relecture ni retranscription, de la
  couche documentaire produite par ce clone : `RESULT.md`, `MANIFEST.csv`, `SHA256SUMS.txt` (renommé
  ici `SOURCE-SHA256SUMS.txt` pour éviter toute confusion avec les empreintes recalculées ci-dessous),
  le collecteur `scripts/invoke_bw3_collector.py`, ses tests `tests/test_collector.py`, les deux
  sous-dossiers `campaign-attestation/` et `local-package-transport/`, et le `README.md`/`MANIFEST.csv`
  de chacun des quatre dossiers `recollected2-build-<id>/`.
- **Volontairement laissé hors dépôt** : les quatre fichiers `collector-report.json` bruts (≈ 2 Mo
  chacun, ≈ 8 Mo au total), captures REST complètes (requêtes, pages, réponses). Ils restent à
  `C:\clones\wi-2222897-bw\relais-20260909-02\attestation\evidence\recollected2-build-<id>\collector-report.json`,
  conformément à la règle de ce dépôt sur les artefacts bruts volumineux (voir
  [EXTERNAL-ARTIFACTS.md](../../../../EXTERNAL-ARTIFACTS.md)). Le `README.md` de provenance de chaque
  dossier est, lui, copié ici.
- **Statut de fraîcheur : rapporté, non revérifié** au sens de la règle de fraîcheur d'
  [AGENTS.md](../../../../AGENTS.md). Le collecteur a effectué des lectures REST Azure DevOps réelles
  *dans le processus source* (whitelist stricte des 4 builds, refus du build `2054`, PAT lu en mémoire
  uniquement) ; cette intégration ne relit pas Azure DevOps elle-même et ne revérifie donc pas les
  chiffres cités. Traiter au même titre que
  [local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/](../local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/README.md)
  et [local-2026-09-09-clienteling-v26-generatejmx-testcampaign/](../local-2026-09-09-clienteling-v26-generatejmx-testcampaign/).

## Intégrité — confrontation des empreintes

Les empreintes SHA-256 ont été recalculées sur chaque fichier copié dans ce dossier et comparées à
`SOURCE-SHA256SUMS.txt` (copie du fichier d'empreintes produit par la source). **Concordance totale**
pour les 12 fichiers que la source hachait : `RESULT.md`, `MANIFEST.csv`, `scripts/invoke_bw3_collector.py`,
`tests/test_collector.py`, `campaign-attestation/RESULT.md`, `campaign-attestation/README.md`,
`local-package-transport/RESULT.md`, `local-package-transport/README.md`, et les quatre
`recollected2-build-<id>/README.md`. Le détail est dans [SHA256SUMS.txt](SHA256SUMS.txt) de ce dossier
(colonne recalculée ici, à confronter à `SOURCE-SHA256SUMS.txt`). Les `MANIFEST.csv` de chaque
sous-dossier n'étaient pas dans la liste d'empreintes de la source ; ils sont copiés tels que trouvés,
sans confrontation possible au-delà de la copie binaire elle-même.

## Contenu résumé

Voir [finding 020](../../findings/020-attestation-campagne-round4-transport-local-candidat.md) pour la
conclusion bornée FACT/INFERENCE/UNKNOWN. En bref :

- re-collecte fraîche des 4 builds `4447425`, `4440884`, `4445575`, `4432554` : stages/tâches JMeter
  non skipped, découverte des runs par `buildUri` exact, comptes Cur/Fix convergents avec les valeurs
  déjà versionnées, inventaire JMX Git haché au `sourceVersion` (32 blobs InventoryTracking × 3 builds,
  151 blobs Clienteling) ;
- cleanup requalifié `UNKNOWN` par un signal de grep de log (`Remove-Item`) sans preuve d'exécution —
  nuancé dans le finding par le signal plus fort déjà établi pour `4447425` (`Stop Containers`
  `succeeded`, 2026-09-08) ;
- un gabarit candidat révisable de transport local de package (`local-package-transport/`), dérivé
  uniquement des findings 017 et 018, tous paramètres `UNKNOWN` tant qu'un couple cible n'est pas
  sélectionné.

## Ce que ce rangement ne fait pas

Aucune lecture Azure DevOps, aucune relance de build ni modification de pipeline n'a été effectuée pour
produire ce rangement. Les 8 tests `pytest` du collecteur ont été lus mais pas ré-exécutés dans ce
processus.
