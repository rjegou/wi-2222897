---
type: "Preuve"
title: "Rangement — audit BW3 (validateur + collecte LIVE) et leçons FrenchTaxesRules V26 (exécution JMeter réelle)"
description: "Deux documents reçus dans Downloads le 2026-09-09, copiés sans modification, avec leur SHA-256."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/README.md"
tags: ["jmeter", "testauto", "migration", "preuve", "provenance"]
timestamp: "2026-09-09"
source_system: "local-kb"
---

# Rangement — audit BW3 et leçons FrenchTaxesRules V26 (2026-09-09)

## Provenance

- **Sources reçues** : `C:\Users\jegour\Downloads\WI-2222897_BW3_travail_et_lecons.md` et
  `C:\Users\jegour\Downloads\2026-09-09-lecons-apprises-ftr-v26-jmeter.md`.
- **Méthode de collecte** : copie intégrale, sans modification, dans ce dossier le 2026-09-09.
- **Statut de fraîcheur** : ces deux documents rapportent des observations et actions faites par
  une session distincte de celle qui effectue ce rangement. Aucun des faits chiffrés qu'ils
  contiennent (builds, runs, hashes, volumes de tests) n'a été revérifié de façon indépendante ici.
  Traiter comme `rapporté, non revérifié` au sens de la règle de fraîcheur d'[AGENTS.md](../../../../AGENTS.md),
  au même titre que les [synthèses de pause du 2026-09-08](../local-2026-09-08-syntheses-techniques-reprise-handoff/README.md)
  déjà rangées selon ce même protocole.

## Empreintes SHA-256

```
2D02A2D266F99A4695BB7AC6CEEDE069FDB60A544D8448891E803C6E4425BF7F  WI-2222897_BW3_travail_et_lecons.md
72076B275402E9640265168DA34A53CD5D8A574A107DCA9843038151E4BEFFD1  2026-09-09-lecons-apprises-ftr-v26-jmeter.md
```

Les originaux de `Downloads` peuvent être supprimés par l'utilisateur : ce dossier en porte la copie
de référence.

## Contenu résumé

### `WI-2222897_BW3_travail_et_lecons.md`

Rapport d'un run d'audit (« BW3 »), périmètre annoncé strictement en lecture seule côté Azure DevOps :

- finalisation d'un validateur de comparaison de campagnes (pagination indépendante par endpoint,
  identité fonctionnelle `plugin | variante | plan | cas`, séparation identité/provenance, détection
  `NonGUIDriver`, gestion explicite `UNKNOWN`) ;
- collecte LIVE InventoryTracking confirmant les **86 tests** de `002-Device:Reassign` restaurés sur le
  run `4447425` (cohérent avec [finding 015](../../findings/015-inventorytracking-002-device-reassign-jmx-load-4445575.md)
  et [finding 017](../../findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md)),
  plus 7 changements de statut/message nominatifs et 4 erreurs `NonGUIDriver` ;
- inventaire JMX InventoryTracking sur trois `sourceVersion` : 32 chemins attendus, 96 blobs
  analysés, 31 JMX identiques, `Device_Reassign` seul JMX qui diffère ; distinction explicite entre
  hash Git source et octets réellement consommés au runtime (ce dernier point reste `UNKNOWN` quand la
  preuve manque) ;
- revérification de FrenchTaxesRules (build `4447926`, commit `61d7f16e…`) : échec avant JMeter sur
  `restore-externals` (`Move-Item Access denied`), 0 Test Run métier, 0 artefact JMeter — cohérent avec
  [finding 017](../../findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md).
  Correction de provenance notée : le manifeste des 19 JMX venait du build `4445025`, distinct de
  `4432510` ;
- revérification de Clienteling (builds `4447427`, `4447443`) : aucun Test Run métier exploitable,
  JMeter non exécuté, inversion Cur/Fix historique corrigée (`6180736 = Fix`, `6180750 = Cur`) ;
- livrable principal annoncé : `C:\clones\wi-2222897-bw\relais-20260909-01\validation\RESULT.md` (hors
  de ce dépôt, non inventorié dans [EXTERNAL-ARTIFACTS.md](../../../../EXTERNAL-ARTIFACTS.md) avant ce
  rangement — emplacement seulement rapporté, existence non revérifiée ici).

### `2026-09-09-lecons-apprises-ftr-v26-jmeter.md`

Synthèse d'une séquence de diagnostic et correction sur la branche de validation FrenchTaxesRules V26,
allant jusqu'à une **exécution réelle des campagnes JMeter Cur/Fix** :

- l'incident `Move-Item Access denied` du build `4447926` s'est révélé transitoire (un rejeu identique
  a réussi sur le même agent, compte et package) — **ne pas remplacer `Move-Item` par `Copy-Item`
  sans preuve de cause** ;
- l'artifact `_Software` produit réellement `E_IIS_SERVER_RETAIL_FRENCHTAXESRULES.MSI/.XML`, pas
  `E_IIS_SERVER_FRENCHTAXESRULES.MSI/.XML` comme le contrôle le supposait ;
- le `localPackageRoot` transmis au déploiement doit contenir exactement les fichiers du manifest : un
  sous-dossier dédié (`$(Pipeline.Workspace)\frenchtaxesrules-local-package`) a été créé pour ne
  transporter que les 4 fichiers requis, avec provenance préservée (`sourceBuildId`, `artifactName`,
  `packageVersion`, hashes SHA-256) ;
- **build final `4448787` (`partiallySucceeded`)** : JMeter Cur et Fix ont chacun exécuté **253 tests**
  (couverture quantitative alignée sur la baseline historique `4432510`/`4432288`, cf.
  [matrice legacy](../../cases/STATUS_MATRIX.md)) ; **51 échecs par variante, strictement identiques
  nom pour nom entre Cur et Fix** ; les cas discriminants historiques `Export_Run` TC08/09/10 et
  `DocumentSignature_SignOne` TC02 ne figurent pas parmi ces 51 échecs ;
- prochaine étape indiquée par le document source : regrouper les 51 échecs par cause réelle via les
  détails REST des résultats, plutôt que test par test.

## Ce que ce rangement ne fait pas

Ce README ne revérifie aucun build, run, hash ou compte de tests cité ci-dessus par une lecture directe
d'Azure DevOps. L'intégration correspondante dans les documents canoniques (voir
[STATUS.md](../../../../STATUS.md), [finding 018](../../findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md))
répercute ces chiffres avec la même réserve.
