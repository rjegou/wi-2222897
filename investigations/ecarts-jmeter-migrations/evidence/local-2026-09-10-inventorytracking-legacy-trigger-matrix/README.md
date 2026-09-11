# InventoryTracking — pourquoi Testing Manager n'est pas lancé sur chaque branche

Date de collecte : **2026-09-10**, Europe/Paris.

## Provenance

- Système source : Azure DevOps `https://dev.azure.com/cegid/Retail`.
- Dépôt : `Y2_Plugins_InventoryTracking`.
- Pipeline : définition `2072`, `InventoryTracking CI`, YAML `/azure-pipelines.yml`.
- Méthode : `az pipelines build definition show`, `az pipelines build list`, `az devops invoke` en lecture seule ; YAML relu à son commit exact ; timeline relue via l'API Build.
- Fraîcheur : snapshot live au 2026-09-10 ; les états futurs peuvent changer.
- Aucun pipeline, branche, run, artefact ou système externe n'a été modifié.

## Faits bruts bornés

### Contrats YAML

| Commit observé | Type de YAML | Déclenchement | Testing Manager / TestAutos | JMeter |
|---|---|---|---|---|
| `20aa528945ac33ba94598222b66fa3071c7e87b9` (`master`) | historique | `master`, `releases/*`, schedule | job `TestAutos`, après `Publish` | aucun stage `TI_Jmeter` |
| `e252f1bfffa8be74f387d9fb9238f332f6234fc1` (`releases/V5`) | historique | `master`, `releases/*`, schedule | job `TestAutos`, après `Publish` | aucun stage `TI_Jmeter` |
| `ef3d87034d38b88aca04c824061b140e2a29252c` (migration) | migration | paramètres `pipelineDevMode`; `Build` peut être automatique | aucun `TestAutos` / `launch-testsAutos` | stage `TI_Jmeter_V26`, conditionné par `isMasterOrReleaseOrDevMode` |
| `be3c9ac35e3424a1a9cfb5c7b2da0bb31edc0437` (migration corrigée) | migration | `trigger: none`, `pr: none`, `schedules: []` | aucun `TestAutos` / `launch-testsAutos` | stage `TI_Jmeter_V26`, conditionné par `isMasterOrReleaseOrDevMode` |

Dans le YAML historique, `Publish` porte la condition `succeeded()` et branche `master` ou `releases/*`. `TestAutos` dépend de `Publish`. Dans le YAML de migration, `pipelineDevMode` vaut `false` par défaut et `isMasterOrReleaseOrDevMode` est vrai seulement sur `master`/`releases/*` ou lorsque le paramètre est activé.

### Runs contrastés

| Build | Branche / commit | Résultat | Timeline observée |
|---:|---|---|---|
| `4440774` | `validation/WI-2222897-inventorytracking-xmldiff` / `ef3d8703` | `succeeded` | `Build` succeeded ; `TI JMeter V26` et Cur/Fix skipped ; aucun TestAutos |
| `4440884` | même branche / `ef3d8703` | `partiallySucceeded` | Cur/Fix JMeter exécutés ; aucun TestAutos |
| `4447425` | `validation/WI-2222897-inventorytracking-azdo-20260908` / `be3c9ac3` | `partiallySucceeded` | Cur/Fix JMeter exécutés ; `Publish` et `Promote` skipped ; aucun TestAutos |
| `4434070` | `InventoryTracking_Migration_AutoTest_Jmeter_On_master` / `4de185bb` | `failed` | `Build` failed ; `TI JMeter V26` skipped ; aucun TestAutos |
| `4455588` | `releases/V5` / `e252f1bf` | `succeeded` | job `TestAutos (on Premise)` succeeded ; étape `launch-testsAutos` exécutée |

Le build `4455588` prouve aussi la frontière asynchrone : l'étape envoie un SOAP `StartWorkflowAsync` à `http://Y2-TSTAUTOXXPG3:8181/integrationlauncher`, reçoit HTTP 200 et `StartWorkflowAsyncResult>1`, puis se termine. Cela prouve l'acceptation du lancement, pas le verdict final des tests sur la VM.

## Limites

- Cette collecte prouve le routage YAML et l'exécution des jobs Azure DevOps, pas le contenu final du Test Manager ni le verdict legacy aval.
- Les paramètres complets de tous les runs ne sont pas disponibles dans la projection CLI ; l'exécution JMeter de `4440884`/`4447425` et le skip de `4440774` sont toutefois directement établis par leurs timelines.
- `UNKNOWN` : une éventuelle autre définition, surcharge de pipeline, ou workflow externe qui lancerait Testing Manager indépendamment de `TestAutos` n'a pas été identifié dans ce périmètre.
