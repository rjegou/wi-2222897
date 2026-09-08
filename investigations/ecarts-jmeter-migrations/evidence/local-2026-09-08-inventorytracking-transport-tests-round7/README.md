# Fixtures et tests du contrat ArtifactItem — InventoryTracking

Date : 2026-09-08 (Europe/Paris). Source des quatre éléments : `parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/README.md`, artefact Build `5037140` du run `4444887`. Aucun téléchargement, push, queue ou système distant modifié.

Le fichier `artifact-item-fixtures.json` reprend les quatre fichiers réels et leurs SHA-256 publiés par la preuve opérateur. Le script `Test-ArtifactTransportContract.ps1` est un test inerte du contrat : il valide succès (identité/version/hash), absence, version erronée, hash altéré, sélection ambiguë, conservation des dépendances et chemin normal lorsque l’option est absente.

**Limite :** ces tests vérifient la logique de sélection/validation sur fixtures, pas l’exécution du patch dans un conteneur ni le contenu d’un package téléchargé pendant un run.

## Assertions requises sur le patch

- l’option locale est explicitement opt-in ; option absente = chemin JFrog existant inchangé ;
- seul `Y2.Plugin.InventoryTracking` version `26.0.7.83` est substitué ;
- les quatre fichiers et hashes attendus sont uniques et présents ;
- les dépendances restent dans le résultat de résolution ;
- absence, version ou hash incorrect, doublon et manifeste non conforme échouent sans fallback ;
- le BuildArtifactId `5037140` est vérifié dans chaque job Cur/Fix ; aucune publication partagée.
