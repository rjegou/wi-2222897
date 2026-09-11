# Inventaire Azure DevOps — branches créées par `rjegou@cegid.com`

**Collecte :** 2026-09-10, projet `cegid/Retail`, identité active `rjegou@cegid.com` (Ronan JEGOU).

## Règle de calcul

`FACT` — Lecture seule de l’API Azure DevOps Git refs sur les 12 dépôts du périmètre, filtre
`refs/heads/`, puis conservation des refs dont `creator.uniqueName` vaut exactement
`rjegou@cegid.com`. Le SHA est l’`objectId` de la ref au moment de la collecte.

Cette collecte porte sur les refs actuellement présentes. `UNKNOWN` — elle ne recense pas les
branches déjà supprimées, car aucun journal d’audit de suppression n’a été collecté ici. Le champ
`creator` est la preuve Azure DevOps de création de la ref ; l’auteur du premier commit ou le nom
de branche seuls ne suffisent pas.

## Résultat

`FACT` — 48 branches actuelles dans 10 dépôts. `Y2_Core` et `Y2_SaaS_Packaging` : aucune ref
`heads` créée par cette identité retournée par la collecte.

| Dépôt | Branches actuelles créées par l’identité (HEAD au 2026-09-10) |
|---|---|
| `Migration_Jmeter_RJE_Sandbox` | `current-state-2026-09-05` (`13144a2f`), `main` (`b83e7f90`), `master` (`892c9e30`), `migration-tools-updates` (`4c8f031e`) |
| `Y2_Tools_Jmeter_Workflow` | `sandbox/tests_rje` (`b962f77b`) |
| `Y2_Tools_AutoTest_Api` | `sandbox/clienteling/api-jmeter-fixes` (`4c22cb28`), `sandbox/frenchtaxesrules/api-jmeter-fixes` (`9081ecfe`) |
| `Y2_Tools_AutoTest_Console` | `sandbox/frenchtaxesrules/console-api-artifact` (`dfda5e52`) |
| `Y2_Plugins_Clienteling` | `Clienteling_Migration_AutoTest_Jmeter_On_master` (`1bcb509c`), `Clienteling_Migration_AutoTest_Jmeter_On_releases/V6` (`8744999c`), `Clienteling_Migration_AutoTest_Jmeter_On_releases/V7` (`a3b9c933`), `Clienteling_Migration_AutoTest_Jmeter_On_releases/V8` (`8f1088fb`), `sandbox/clienteling/wi2222897-isolated-replay` (`afe035ec`) |
| `Y2_Plugins_FrenchTaxesRules` | `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_master` (`f80bc731`), `..._releases/V1` (`1f23a616`), `..._releases/V2` (`5f5d31d0`), `..._releases/V3` (`44df4431`), `..._releases/V4` (`df523d74`), `..._releases/V5` (`d3124c89`), `..._releases/V6` (`ebc4b54d`), `..._releases/V7` (`54e9227c`), `sandbox/WI-2222897-frenchtaxesrules-jmeter-fix-20260909` (`bd3688e4`), `sandbox/WI-2222897-frenchtaxesrules-v22-packaging-validation-20260909` (`f565c1bd`), `sandbox/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908` (`d7dbbab1`), `sandbox/WI-2222897-ftr-v26-azdo-20260908` (`c9e1f94a`), `sandbox/frenchtaxesrules/v26-preflight-20260908` (`27644f21`), `sandbox/wi-2222897-v22-preflight-20260907` (`68f1f7a8`) |
| `Y2_Plugins_InventoryTracking` | `InventoryTracking_Migration_AutoTest_Jmeter_On_master` (`4de185bb`), `..._releases/V1` (`304ee600`), `..._releases/V2` (`da00f307`), `..._releases/V3` (`22e40d07`), `..._releases/V4` (`af2ecdc4`), `..._releases/V5` (`b300ef28`), `..._releases/V6` (`468cf2f8`), `sandbox/WI-2222897-inventorytracking-azdo-20260908` (`be3c9ac3`), `sandbox/WI-2222897-inventorytracking-isolated-20260908` (`95aede77`), `sandbox/WI-2222897-inventorytracking-xmldiff` (`ef3d8703`) |
| `Pipelines_Docker_BaseImages` | `sandbox/WI-2222897-sql-fulltext` (`5ac3c54a`) |
| `Y2_Tools_PlatformDeploy` | `sandbox/WI-2222897-inventorytracking-local-transport` (`a490cd53`) |
| `Pipelines_Templates` | `features/2124517-marqueur-leadtime-cortex` (`7df85715`), `features/rje_POC_VMImageRefresh` (`95dbc6aa`), `features/rje_bug_VS` (`8a1678af`), `features/rje_correctif_fail_popup_chrome_mdp` (`6c043738`), `features/rje_etude_error_403` (`77d52781`), `sandbox/2124455-leadtime-live-validation` (`799851aa`), `sandbox/2124455-leadtime-live-validation-t9` (`7410cd60`), `sandbox/2124455-leadtime-promote-events` (`799851aa`), `sandbox/rje_creaVm` (`a4cfcdc3`) |
| `Y2_Core` | aucune |
| `Y2_SaaS_Packaging` | aucune |

Les SHA abrégés ci-dessus sont uniquement une lecture pratique ; la collecte complète des HEAD est
reproductible avec `az repos ref list --filter heads/` et le filtre `creator.uniqueName` indiqué.
