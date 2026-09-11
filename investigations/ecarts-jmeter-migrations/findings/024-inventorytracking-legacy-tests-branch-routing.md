# 024 — InventoryTracking : Testing Manager n'est pas un test attaché à chaque run

Date : **2026-09-10**. Périmètre : définition `2072`, dépôt `Y2_Plugins_InventoryTracking`.

## Verdict

`FACT` — le lancement des tests API legacy via Testing Manager est implémenté par le job YAML `TestAutos (on Premise)` et ce job n'existe que dans le YAML historique. Dans ce YAML, il dépend de `Publish`, dont la condition limite l'exécution à `master` et `releases/*`.

`FACT` — les YAML de migration relus aux commits `ef3d8703…` et `be3c9ac3…` ne contiennent ni `TestAutos` ni `launch-testsAutos`. Ils contiennent une chaîne JMeter distincte, pilotée par `pipelineDevMode` et `isMasterOrReleaseOrDevMode`.

`FACT` — les runs live confirment les deux comportements : `4455588` sur `releases/V5` exécute `TestAutos` ; `4440774` sur une branche de migration n'exécute ni TestAutos ni JMeter ; `4440884` et `4447425` exécutent JMeter Cur/Fix sans TestAutos.

`INFERENCE` — “un run AzDO sur une branche” ne signifie donc pas “lancer Testing Manager”. Le résultat dépend d'abord du YAML présent au commit du run, puis des conditions de branche et, pour la chaîne de migration, du paramètre `pipelineDevMode`.

## Pourquoi le comportement varie

1. Branche `master` ou `releases/*` avec YAML historique : `Build → Publish → TestAutos`. Testing Manager peut être soumis.
2. Branche de migration avec YAML `ef3d…` : `pipelineDevMode=false` par défaut ; le build peut finir vert tandis que `TI JMeter V26` est skipped.
3. Branche de migration avec YAML `be3c…` : `trigger/pr/schedule` sont désactivés ; un run manuel existe seulement si quelqu'un le queue. Avec `pipelineDevMode=true`, JMeter peut s'exécuter, mais Testing Manager reste absent du YAML.
4. Un échec en amont (`4434070`, Build failed) empêche aussi la chaîne aval, sans constituer un défaut de déclenchement Testing Manager.

## Frontière de preuve

`FACT` — le log de `4455588` montre uniquement la soumission SOAP asynchrone à `Y2-TSTAUTOXXPG3:8181/integrationlauncher`, HTTP 200 et résultat `1`.

`UNKNOWN` — le résultat final des tests legacy correspondants tant qu'un TRX/XML/log TestAuto final n'est pas relu sur les emplacements legacy. Un job Azure DevOps `succeeded` ne suffit pas.

## Rejeu discriminant recommandé

Pour vérifier une règle cible, choisir un commit et une branche explicites, relever le YAML à ce commit, queue un run non productif avec les paramètres visibles, puis collecter : timeline complète, log de soumission, identifiant d'itération legacy, et résultat final TRX/XML. Comparer séparément :

- YAML historique sur `releases/V5` : présence et exécution de `TestAutos` ;
- YAML de migration sur une branche de validation : absence structurelle de `TestAutos` et condition `pipelineDevMode` de JMeter.

Preuve détaillée : [matrice de collecte](../evidence/local-2026-09-10-inventorytracking-legacy-trigger-matrix/README.md).
