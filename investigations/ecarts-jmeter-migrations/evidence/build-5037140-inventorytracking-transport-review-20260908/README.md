# InventoryTracking — revue transport PlatformDeploy / PipelineArtifact 5037140

## Provenance

- Date : 2026-09-08 (Europe/Paris).
- Sources : Azure DevOps REST read-only (`Retail`, builds `4444887` and `4444888`) and local evidence indexed under `parallel/2026-09-08-parallel-1788841150349`.
- Scope : revue indépendante de l’entrée expérimentale PlatformDeploy ; aucune queue, publication, branche, fichier historique ou système distant modifié.
- Fraîcheur : collecte live le 2026-09-08 ; patch opérateur recherché dans les emplacements de travail indexés à cette date.

## Identité et chemin observés

**FACT** — le build `4444887` (definition `2072`, number `7.83`) est `completed/failed`, sur `refs/heads/validation/WI-2222897-inventorytracking-isolated-20260908`, commit `efba57ea5a96d346170f4407e37050985244dcee`, pool hosted `Azure Pipelines` (79). Son artefact `26.0.7.83_Software` a l’ID PipelineArtifact `5037140` et une taille déclarée de `1,705,531` octets. Les artefacts Nuget, HtmlDocs et Cur/Fix logs sont distincts.

**FACT** — dans le contrat PlatformDeploy extrait (`parallel/.../bw2-environments/evidence/platformdeploy/round4-private-staging-20260908/extracted/Scripts/download-packages.ps1`, lignes 27–39), le producteur actuel appelle `Cegid.Retail.JFrog.Cli.exe download packagelist <deployConfig> -f <folder> -di <folder>/downloadedPackages.json`; aucun paramètre de racine locale, PipelineArtifact ou hash Build n’est accepté.

**FACT** — cette étape précède les installations dépendantes et écrit le manifeste `downloadedPackages.json`. Le package Build 5037140 existe donc côté Azure DevOps, mais sa consommation par PlatformDeploy n’est pas démontrée. Le run `4444887` a échoué dans les deux variantes à la résolution de `Y2.Plugin.InventoryTracking.26.0.7.83` dans `retail-software-staging`, avant JMeter.

## Revue du patch opérateur

**UNKNOWN / point bloquant de revue** — aucun patch concret référencé par l’opérateur pour `localPackageRoot`, `downloadedPackages.json`, `5037140` ou une option expérimentale PlatformDeploy n’est présent dans les dossiers indexés au moment de cette collecte. La preuve disponible est le contrat de conception round 5, qui indique explicitement qu’aucun diff exécutable n’était alors préparé. Il est donc impossible d’attester substitution ciblée, hash retrouvé dans Cur et Fix, manifeste compatible ou conservation des dépendances.

**FACT (mise à jour)** — le dossier opérateur round 6 apporte désormais les quatre fichiers réels et leurs hashes, mais reste une proposition de contrat : aucun diff exécutable PlatformDeploy ni preuve d’utilisation dans Cur/Fix n’y est fourni. Les fixtures et tests inertes préparés dans [le lot round 7](../local-2026-09-08-inventorytracking-transport-tests-round7/README.md) passent 7/7 assertions, y compris les cinq refus discriminants et le chemin normal sans option. Cela valide le contrat de test, pas l’implémentation opérateur.

Les critères minimaux à vérifier sur le prochain patch sont précis : (1) téléchargement de l’unique artefact Build `26.0.7.83_Software` par son identifiant et sa version, puis SHA-256 calculé et comparé dans chaque job Cur/Fix ; (2) remplacement uniquement de `Y2.Plugin.InventoryTracking` à la version exacte, avec les autres entrées du packagelist toujours résolues par le chemin normal ; (3) génération d’un `downloadedPackages.json` conforme au lecteur PlatformDeploy, après extraction, sans simple copie d’un manifeste incompatible ; (4) déploiement de la substitution avant installation et échec propagé à tout code non nul ; (5) absence de `lastV*`, cache ou package partagé en fallback ; (6) option désactivée = comportement YAML/source inchangé et aucune publication staging/JFrog/registry ; (7) test positif (package exact + dépendances) et négatif (hash, version, artefact ou manifeste erroné refusé).

**FACT** — le test local historique de propagation `test-platformdeploy-differential-round6.ps1` couvre des codes enfants `0`, `7` et exception pour le wrapper, mais ne teste pas le transport PipelineArtifact, le manifeste ou la substitution d’un seul plugin. Il constitue une preuve partielle, pas les tests positifs/négatifs requis ici.

## Avis et transmission

**AVIS : pas encore favorable pour le run.** Ce n’est pas un blocage Docker : 4444887 a initialisé ses conteneurs puis a atteint PlatformDeploy. Le verrou actuel est l’absence de patch et de tests transport vérifiables dans le workspace. Dès dépôt du patch concret et des deux tests inertes ci-dessus, l’avis pourra devenir favorable pour exécuter le run ; aucun résultat runtime JMeter n’est exigé avant cette autorisation technique.

**PR conservée séparément :** migration complète `4de185bb` + correctif `ef3d8703` + XmlDiff, diagnostics exclus. L’adaptation expérimentale de transport ne doit pas entrer dans cette PR.

## Résultats Cur/Fix et TC122

**FACT** — aucun nouveau run Cur/Fix ni JTL/TC122 postérieur à `4444887` n’est présent dans cette collecte. `4444887` n’a exécuté ni Prepare/Run JMeter, ni conversion JTL ; aucun verdict de régression ne peut en être tiré.

**FACT (lecture live complémentaire)** — le run antérieur `4444719` (`7.81`) est également `completed/failed`, même branche/commit, et ses deux logs `Launch Y2 deployment` (120, 133) montrent exactement la résolution JFrog du plugin `26.0.7.81` en Staging puis l’erreur `Artifact Y2.Plugin.InventoryTracking ... not found in Staging`; les dépendances Core/Common/Auth/Identity sont téléchargées avant cet échec. Il ne s’agit pas d’un résultat JMeter et cela confirme que le défaut précède la campagne.

**UNKNOWN** — digest d’image réellement consommé, JMX/données, package chargé après installation et comparabilité TC122 restent non établis pour ce run.
