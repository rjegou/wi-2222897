---
type: "Preuve"
title: "Rangement — Clienteling V26, GenerateJmx : Product.Version/BuildPlatform, OutputFiles manquants, TestPlan vs TestCampaign"
description: "Document reçu dans Downloads le 2026-09-09, copié sans modification, avec son SHA-256."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-clienteling-v26-generatejmx-testcampaign/README.md"
tags: ["jmeter", "testauto", "migration", "clienteling", "preuve", "provenance"]
timestamp: "2026-09-09"
source_system: "local-kb"
---

# Rangement — Clienteling V26, progression GenerateJmx (2026-09-09)

## Provenance

- **Source reçue** : `C:\Users\jegour\Downloads\2026-09-09-clienteling-v26-jmeter-synthese-technique.md`.
- **Méthode de collecte** : copie intégrale, sans modification, dans ce dossier le 2026-09-09.
- **Statut de fraîcheur** : ce document rapporte des observations et actions faites par une session
  distincte de celle qui effectue ce rangement. Aucun des identifiants qu'il contient (builds, push
  IDs, commits) n'a été revérifié de façon indépendante ici. Traiter comme `rapporté, non revérifié`
  au sens de la règle de fraîcheur d'[AGENTS.md](../../../../AGENTS.md), au même titre que les
  [synthèses de pause du 2026-09-08](../local-2026-09-08-syntheses-techniques-reprise-handoff/README.md)
  et le [rangement BW3/FrenchTaxesRules du 2026-09-09](../local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/README.md).

## Empreinte SHA-256

```
1213C7E7243626BD0315ADA06FA65E6D47347F9DB668C11A3F3D0298AE4763BB  2026-09-09-clienteling-v26-jmeter-synthese-technique.md
```

L'original de `Downloads` peut être supprimé par l'utilisateur : ce dossier en porte la copie de
référence.

## Contenu résumé

Séquence de diagnostic et correction sur la branche isolée `sandbox/clienteling/wi2222897-isolated-replay`
(définition `14264`), postérieure au déblocage du backup LFS documenté au
[finding 016](../../findings/016-clienteling-v26-backup-lfs-absent.md) :

- deux variables de pipeline manquantes rétablies : `Product.Version: '26.0.10.23'` et
  `BuildPlatform: 'any cpu'`, permettant d'atteindre le stage `GenerateJmx` ;
- premier échec `GenerateJmx` : `DirectoryNotFoundException` sur `TestPlans\OutputFiles`, cause
  identifiée dans `ci/wi2222897/scripts/New-Wi2222897MigrationManifest.ps1` qui ne copiait que le XML
  racine du plan, pas ses `InputFiles`/`ExpectedOutput` référencés (vérifiés présents et complets côté
  dépôt pour les trois plans ciblés) ; correctif poussé (push `5138407`, HEAD
  `8cc14f2f8b83ea642a021e0e2ba8b872ab95c664`) et rejeu lancé (build `4449640`) ;
- second échec `GenerateJmx` : `<TestPlan xmlns='TestAutomation'> was not expected`, cause identifiée —
  la Console (`--tstj`) attend un `TestCampaign` (wrapper avec `TestPlanItem`), pas un `TestPlan` brut ;
  structure retrouvée dans une preuve locale de génération fonctionnelle ;
- correctif appliqué dans `ci/wi2222897/scripts/Invoke-Wi2222897JmxRegeneration.ps1` : fixture
  temporaire canonique (`TestPlans\` + `InputFiles` + `ExpectedOutput`), génération du wrapper
  `TestCampaign`, appel Console, vérification d'un JMX unique généré, recopie au chemin JMeter attendu,
  hash SHA-256, suppression de la fixture ; push `5138712`, HEAD
  `28f71268426de6f196c2f4672b526489819c6393` ;
- état déclaré en fin de séquence : les deux variables de pipeline, l'absence de ressources annexes et
  l'inversion TestPlan/TestCampaign sont rapportés résolus ; aucun run n'a encore atteint
  `JMeter Cur`/`JMeter Fix` dans ce document — prochain test à faire sur `28f71268…` avec
  `apiBuildId=4444962`, `consoleBuildId=4445025`, `consoleDefinitionId=2641` ;
- méthode et leçons capitalisées dans le [finding 019](../../findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md)
  et la section 7 de [DEPANNAGE_JMETER.md](../../../../documentation/guides/DEPANNAGE_JMETER.md#7-leçons-opérationnelles-rapportées-clienteling-v26-generatejmx-2026-09-09).

## Ce que ce rangement ne fait pas

Ce README ne revérifie aucun build, push ID, commit ou chemin cité ci-dessus par une lecture directe
d'Azure DevOps. L'intégration correspondante dans les documents canoniques (voir
[STATUS.md](../../../../STATUS.md) et le [finding 019](../../findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md))
répercute ces éléments avec la même réserve.
