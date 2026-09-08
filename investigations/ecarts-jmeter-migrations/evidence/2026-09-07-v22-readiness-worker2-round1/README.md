# Revue indépendante de readiness — FrenchTaxesRules V22

Date : 2026-09-07  
Worker : 2, round 1  
Périmètre : revue locale et statique du candidat `replay-prep/2026-09-07-v22-isolated/`. Aucun lancement, aucune queue et aucune mutation distante.

## Verdict

**NOT READY / BLOQUÉ avant rejeu.** Le préflight local est utile pour les entrées immuables et la disponibilité de services, mais il ne constitue pas une preuve d'isolation. Le candidat ne peut pas encore prouver le critère métier des 174 refus pour `FixHistorical` puis `FixCandidate`.

## Faits vérifiés

- **FACT — image historique connue mais référence YAML incorrectement qualifiée.** Le candidat contient le tag et le digest attendus aux lignes 14 et 20 de `replay-prep/2026-09-07-v22-isolated/azure-pipelines.candidate.yml`, mais la référence commence par `cegid-retail-docker-production/...` sans registre. Le `loginServer` accepté pour cette revue est `acrretaildocker-e2c3eugzbee2habm.azurecr.io`. L'identité complète à faire valider avant queue doit donc inclure ce registre, avec le même repository, tag et digest. Le login ACR ne prouve pas à lui seul que le pull de cette référence non qualifiée vise le bon registre.

- **FACT — deux variantes utilisent la même image, le même plugin, le même AuthenticationServer, le même backup et les mêmes JMX.** Les différences de versions Core/Common/Identity sont déclarées dans les stages `FixHistorical` et `FixCandidate` (YAML lignes 64-88 ; README du replay-prep). Les refs de dépôts sont des SHA locaux déclarés dans les resources (lignes 24-35), mais l'existence d'une définition/branche dédiée portant ce candidat n'est pas prouvée ici.

- **FACT — préflight d'entrées positif mais borné.** `Preflight-V22FrenchTaxesRules.ps1` exige digest, versions plugin/AuthServer, hash backup, six lignes de manifeste package, 12 JMX Legacy + 20 JMX Web, exactement 32 JMX et hashes identiques (lignes 22-32, 50-56, 67-105). Le test local `Test-V22ReplayFailureModes.ps1` passe : `baseline failure blocks candidate; candidate failure preserves cleanup; wrong count is rejected`.

- **FACT — readiness de services seulement.** `Assert-V22LocalContainerRuntime.ps1` vérifie que les hôtes applicatif/DB/authority sont `COMPUTERNAME`, que `sqlservr` et un worker IIS existent et que les ports 80/1433 écoutent. Il écrit un marqueur sous `Agent.TempDirectory`, mais ne vérifie ni l'identité/cycle de vie Azure du container, ni ses mounts, ni l'absence de cible partagée, ni l'isolement réseau (script lignes 12-24).

- **FACT — comptage 232+144.** Le script de comptage impose `LegacyServices=232` et `WebServices=144` (total 376) ; le test local l'a validé sur le substitut. Le pipeline appelle ce script après les deux campagnes (steps lignes 75-82).

- **FACT — les 174 refus sont décrits, non comparés.** `V22-174-REFUS-COMPARISON.md` partitionne 138 refus Legacy et 36 refus Web, avec les signatures `CBP50101`/`ID4266` et `FailedAuthentication`/`Access is denied`. Le YAML lance trois JMX discriminants puis les deux campagnes, mais ne contient aucune assertion qui extrait ces signatures, ne vérifie la postcondition baseline, ni ne compare les mêmes scénarios baseline/candidat. Le collecteur ne conserve que des compteurs génériques `successTrueCount`, `successFalseCount` et `errorMarkerCount` ; il ne produit pas cette comparaison.

- **FACT — secret incohérent avec la garantie annoncée.** Les steps injectent `RETAIL_JFROG_API_KEY` dans l'environnement, mais passent ensuite sa valeur au wrapper par `-RetailJfrogApiKey $key` (steps lignes 48-56). Cela contredit la promesse de clé hors arguments de sous-processus. La suppression de la variable après appel ne retire pas une éventuelle exposition de la ligne de commande du processus. `parameters.properties` contient aussi les credentials de test, même si ses ACL sont restreintes et qu'il n'est pas collecté.

- **FACT — nettoyage partiel.** Chaque variante supprime son dossier `V22-FrenchTaxesRules-<BuildId>-<variant>` sous `Agent.TempDirectory` en `condition: always()` (ligne 88). Cela ne prouve pas la destruction du container Azure, des mounts, des fichiers temporaires produits par les tasks JFrog/ExtractFiles, ni l'absence d'artefacts hors de ce dossier.

## Garanties minimales avant toute autorisation

1. Qualifier l'image dans `resources.containers` et la variable `image` avec le `loginServer` exact, puis vérifier que le service connection peut tirer exactement ce repository au digest attendu. Cette correction n'a pas été appliquée par ce worker.
2. Ajouter un contrôle d'isolation exécutable sur l'infrastructure réelle : run/container ID, image digest effectivement démarré, mounts, réseau, hôtes/ports, DB et IIS appartenant au même scope de run, et nettoyage vérifié. La readiness locale actuelle reste nécessaire mais insuffisante pour les deux jobs.
3. Supprimer le passage du secret JFrog en argument de processus, selon une interface du wrapper prouvée compatible avec une variable d'environnement ou un fichier temporaire ACL-restreint ; vérifier l'absence de secret dans les logs et la collecte. Ne pas considérer la simple suppression de variable comme preuve.
4. Vérifier réellement, pour **chaque** variante, que les six ZIP du manifeste sont ceux consommés et que les versions/assemblies déployées correspondent aux versions déclarées. Le manifeste seul prouve l'identité d'acquisition, pas la consommation runtime.
5. Ajouter une assertion fail-closed après la baseline : les trois cas discriminants et les résultats complets doivent montrer la signature historique attendue (`CBP50101`/`ID4266` ou `FailedAuthentication` selon scénario), sinon `INFRASTRUCTURE_BLOCKED` et arrêt. Après le candidat, comparer par scénario/assertion la disparition des 174 signatures, sans exiger zéro autre erreur métier.
6. Rendre explicite la provenance du backup effectivement injecté dans `parameters.properties` : le préflight hash le fichier `AUTO_V21_00.bak`, tandis que les steps imposent `DB_NAME=AUTO_V21_00`. Cette cohérence doit être vérifiée dans l'attestation de restauration, pas seulement déduite du nom.

## UNKNOWN restant

- Pull et démarrage runtime avec le `loginServer` exact ; identité et cycle de vie du container ; mounts, réseau et ressources partagées.
- Compatibilité réelle de l'agent `windows-latest` avec cette image Windows LTSC2022 et disponibilité de SQL/IIS dans le job.
- Consommation effective des six ZIP et des versions Core/Common/Identity par chaque variante.
- Résultat baseline/candidat et disparition des 174 refus ; aucun JMeter métier n'a été lancé.
- Branche/définition distante dédiée et autorisation explicite de queue. Les pauses historiques supersédées ne sont pas réactivées ; ce rapport ne demande aucune queue.

## Reproduction locale effectuée

Depuis la racine WI, exécution du test inerte :

`investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/scripts/Test-V22ReplayFailureModes.ps1 -ReplayRoot investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated`

Résultat : **PASS** pour les trois modes d'échec substitués. Cette réussite ne constitue ni une preuve d'isolation runtime ni une preuve métier.
