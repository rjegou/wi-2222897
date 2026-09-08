# Matrice de postconditions restantes — 2026-09-07

| Postcondition PBI | Statut | Preuve disponible | Suite concrète |
|---|---|---|---|
| Inventaire des plugins/branches établi | FACT local, snapshot | `documentation/tracking/2026-09-07-bilan-intermediaire-semaine-precedente.md` contient 18 couples rapportés ; fraîcheur live non prouvée | Revalider branches/builds/PR en lecture seule, puis conserver les lignes sans preuve comme rapportées |
| InventoryTracking migration/V26 identifiée | FACT | Worker 2: définition `2072`, YAML `azure-pipelines.yml`, branche `refs/heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master`, commit `4de185bb...` | Lire les templates externes aux refs réellement consommées |
| `4434070` : Build et stages V26 | FACT partiel | `Build V26` échoue; `TI JMeter V26`, Cur et Fix sont skipped; l’image/ACR réussit en amont | Ne pas interpréter ce run comme une exécution JMeter |
| Cause immédiate du fail `4434070` | FACT | VSBuild log 51: `MSB3245` sur `Cegid.Retail.XmlDiff`, puis quatre `CS0103` sur `XmlDiff`, code 1 | Conserver la cause fonctionnelle au niveau compilation |
| Pourquoi `XmlDiff` n’est pas résolu | UNKNOWN | packages/restore, `ExternalsToRestore_V26.xml` et templates effectivement consommés non rapprochés au commit `4de185bb...` | Comparer package/reference/template au commit exact |
| `master` officiel `4435986` | FACT limité | commit `20aa528...`, Build V26 et TestAutos réussissent; YAML sans `TI_Jmeter_V26` | Ne pas utiliser ce vert comme validation de migration JMeter |
| InventoryTracking releases/V5 (V22–V23) | UNKNOWN live ; rapporté | bilan : build `4432364` en échec | Revalider séparément, sans transférer la cause master |
| InventoryTracking releases/V6 (V24–V25) | UNKNOWN live ; rapporté | bilan : build `4432476` en échec | Revalider séparément, sans transférer la cause master |
| InventoryTracking V21 et inférieur | Non attendu selon synthèse PBI | synthèse : versions abandonnées, migration sans tests JMeter attendus | Vérifier seulement que neutralisations prévues existent si la migration est effectuée |
| Erreurs métier à inventorier | PARTIEL | autres couples FrenchTaxesRules/Clienteling ont des matrices et preuves séparées ; aucune preuve InventoryTracking live | Après diagnostic, séparer infrastructure/pipeline des erreurs métier et joindre artefacts exacts |
| PR InventoryTracking migration | UNKNOWN | aucune liste PR live exploitable dans cette reprise; le build 4434070 n’est pas preuve de PR | Relire les PR par branche source exacte avant toute conclusion; aucune création ici |
| PR par migration concluante | NON PROUVÉ | synthèse PBI l'exige pour les versions > V21 mais ne définit pas précisément « concluante » | Décider après build/timeline JMeter réellement exécuté; aucune création ici |
| Tableau Excel/OneNote mis à jour et notification Ludo/Lydie | NON CLOS LOCAL | `STATUS.md` le classe non clos ; tracking README rappelle que le CSV ne prouve pas la mise à jour Excel/OneNote | Action de coordination/publication hors périmètre lecture seule, à décider explicitement |

## Parcours utile après diagnostic

1. Prouver le premier task causal de `4434070` et distinguer préparation, build, image/ACR et tests JMeter.
2. Si l'échec est infrastructurel, confirmer si un rerun minimal est nécessaire et obtenir une décision du superviseur avant tout lancement.
3. Si les tests ont réellement démarré, extraire les artefacts et inventorier les erreurs InventoryTracking séparément des causes déjà établies pour FrenchTaxesRules/Clienteling.
4. Revalider les branches V22–V25 avec leurs builds propres ; ne pas déduire leur cause de master/V26.
5. Après preuves et décision, produire les livrables globaux du PBI : suivi Excel canonique, PR si applicable, et notification externe. Ces actions ne sont pas exécutées dans ce lot.
