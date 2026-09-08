# Prérequis du rejeu FrenchTaxesRules V26 Fix

Date : 2026-09-06. Lecture seule ; aucun lancement, réseau, restauration SQL ou secret lu/conservé.

| Prérequis | Valeur exacte | Preuve | Disponible localement | Action suivante |
|---|---|---|---|---|
| Core | 26.0.0.1762 | `build-4432510/.../ProcessLauncher_2026_09_04_00.Log`, `build-4426342/.../v26-fix.cy2px` | Oui, preuve seulement | vérifier dans l’environnement ciblé |
| Plugin V26 Fix | 4432510 : 26.0.10.75 ; 4426342 : 26.0.10.67 | `findings/001...`, `findings/009...`, `downloadedPackages.json` | Oui, artefacts/logs | choisir un build et conserver sa cohérence |
| SQL | instance `...\DOCKERSQLEXPR`, driver configuré `Sql2012`, tenant `TESTS_AUTO_JMETER` | `build-4426342/.../v26-fix.cy2px` SHA-256 `C54E...3224`; run logs : service `MSSQL$DOCKERSQLEXPR` | Configuration/logs oui ; moteur exact non | obtenir métadonnée d’image ou version moteur |
| SQL Server 2019 | non démontré pour le périmètre V26 Fix | guides locaux seulement ; aucune ligne V26 Fix ne prouve 2019 | Non prouvé | corriger le compte rendu précédent : UNKNOWN |
| Backup | identité, source et date inconnues ; aucun backup matérialisé | `evidence/README.md`, absence dans le worktree/config local | Non | retrouver un artefact identifié, sans le copier ici |
| cy2px | V26 Fix `v26-fix.cy2px` ; packages Core/Auth/Identity/Plugin et tenant visibles ; secrets exclus de cette note | artefact de déploiement 4426342 ci-dessus | Oui pour 4426342 ; pas établi pour 4432510 | conserver le même fichier et ses versions |
| JMeter | 5.6.3, Java 21.0.5, JMeterHome `C:\tools\Jmeter` | `build-4432510/.../010-Export_Run/jmeter.log` SHA-256 `D497...9F23`; même version observée dans 4426342 | Observé dans logs de run | vérifier le package réellement remis à l’essai |
| Campagne/JMX | `010-Export_Run.jmx`, chargé depuis le checkout de pipeline `Y2_Plugins_FrenchTaxesRules\Tests\LegacyServices` | mêmes `jmeter.log` | JMX/chemin observés dans logs, source locale disponible | établir le contrat d’entrée de l’essai |
| Workflow/TestAutos | définition locale 2054 ; soumission `launch-testsAutos.v2.yml` vers TestAutos on-premise | `legacy-build-4432288/azure-pipelines-exact.json`, template local | Métadonnées oui ; résultat/consommation du JMX non | inspecter le manifeste d’entrée exact, sans lancer |

## Conclusions bornées

4426342 fournit la seule configuration `cy2px` V26 Fix retrouvée ; 4432510 fournit les logs JMeter/RunLogs mais pas une configuration de déploiement équivalente. Les deux builds divergent de version plugin et de commit ; ils ne sont pas une preuve interchangeable.

La génération Console locale validée ne démontre pas que TestAutos accepte un JMX corrigé comme entrée sans rebuild/publication d’image : `UNKNOWN`. Les logs JMeter démontrent le chargement d’un JMX et JMeter 5.6.3, pas la chaîne complète de préparation SQL ni la réussite métier.

Prochaine collecte minimale : obtenir, dans les artefacts déjà identifiés, le manifeste de déploiement contenant image/tag SQL, l’identité du backup et le contrat de dépôt du JMX ; comparer ces éléments à `v26-fix.cy2px`. Aucun pipeline ne doit être lancé avant cette collecte.
