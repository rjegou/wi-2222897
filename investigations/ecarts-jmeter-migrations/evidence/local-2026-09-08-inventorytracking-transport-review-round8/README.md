# Revue patch transport InventoryTracking — round 8

Date : 2026-09-08 (Europe/Paris). Source revue : `.work/transport-round7` (dossier opérateur), preuve PipelineArtifact `5037140`, scripts PlatformDeploy archivés. Aucun push, queue, publication ou mutation distante.

## Résultats vérifiés

**FACT** — `test-local-transport.ps1` s’exécute avec succès : `normal-path-static PASS`, puis `positive`, `wrong-version`, `wrong-hash`, `duplicate-file`, `unexpected-root-file`, `missing-manifest` et `ALL CASES PASS`. Le helper refuse les fichiers absents, version/hash incorrects, doublons, fichier inattendu à la racine et manifeste absent.

**FACT (round 9)** — la correction ajoutée renforce le contrôle de fichier inattendu et vérifie aussi la provenance positive retournée par le helper. En revanche, la recherche ciblée de `sourceBuildId` ne trouve aucune nouvelle propriété : le YAML continue d’écrire `artifactId = $(Build.BuildId)`, et le helper continue d’accepter toute valeur non vide. L’observation de provenance reste donc ouverte.

**FACT** — `prepare-local-inventorytracking-package.ps1` limite le nom à `Y2.Plugin.InventoryTracking`, impose exactement quatre fichiers, vérifie chaque SHA-256 et refuse une destination déjà existante. Le YAML télécharge `$(componentVersion)_Software` depuis `download: current`, crée le manifeste dans chaque job Cur/Fix et passe les quatre paramètres au template. Les dépendances restent résolues via le packagelist temporaire sans l’entrée du seul plugin.

**FACT** — l’option est vide par défaut dans le template ; la branche normale de `download-packages.ps1` conserve `$effectiveDeployConfig = $deployConfig`. Aucun fallback `lastV*` de package InventoryTracking n’est ajouté, et aucune publication partagée n’est introduite par ce patch. Le choix `platformDeployVersion: lastV5` concerne l’outil PlatformDeploy lui-même, pas le package plugin substitué.

## Défaut concret à corriger

**FACT** — le YAML produit `artifactId = '$(Build.BuildId)'` (ligne 310), tandis que la preuve live identifie le PipelineArtifact `26.0.7.83_Software` par l’ID de ressource `5037140`. Le fixture de test utilise `5037140`, mais le manifeste effectivement produit lors d’un run contiendra l’ID du build, sans contrôle de l’ID artifact ni hash de l’archive téléchargée. Le helper vérifie seulement que `artifactId` est non vide.

**IMPACT :** le run peut prouver le bon Build et les hashes des quatre fichiers, mais pas l’identité exacte de l’objet PipelineArtifact consommé ; le test fixture ne couvre pas cette divergence. Ce défaut ne justifie pas de réécrire la chaîne Docker, mais empêche l’attestation stricte demandée.

**Correction minimale recommandée avant queue :** conserver `Build.BuildId` comme provenance du run, mais renommer explicitement le champ (`sourceBuildId`) et ajouter l’identifiant logique `artifactName`, la taille/hash du package source quand disponible, puis vérifier dans le helper `artifactName == "$(componentVersion)_Software"`, `sourceBuildId == Build.BuildId` et l’ensemble exact des fichiers/hashes. Si l’ID ressource 5037140 est requis, le récupérer par lecture REST de l’artefact courant ou l’attester séparément ; ne pas hardcoder 5037140 pour le prochain run.

## Avis

**AVIS CONDITIONNEL FAVORABLE pour un run inerte après cette correction de provenance.** Les garanties de sélection, refus, dépendances, option normale et transport dans les deux jobs sont présentes statiquement et les tests locaux passent. Aucun résultat runtime n’est requis avant de permettre la queue, mais le prochain run doit relire les blobs/templates réellement utilisés et publier uniquement des preuves PipelineArtifact isolées.

**PR fonctionnelle inchangée :** migration complète `4de185bb` + `ef3d8703` + XmlDiff ; adaptation transport exclue.

## Cur/Fix / TC122

**UNKNOWN** — aucun nouveau run post-patch ni résultat JTL/TC122 n’est disponible dans cette revue. `4444887` a échoué avant JMeter dans les deux variantes.
