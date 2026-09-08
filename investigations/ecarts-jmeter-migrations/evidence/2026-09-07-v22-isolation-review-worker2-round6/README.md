# Revue isolation V22 — Worker 2 round 6

Date : 2026-09-07. Revue locale uniquement ; aucun fichier Worker 1, run ou système distant modifié.

## Provenance

Le SHA `a2a442c98f05b2e57d02a98fd7228967ee4104df` n’est pas présent comme objet Git dans les worktrees locaux ni dans les preuves indexées. Le prédicat audité est donc la copie candidate locale `replay-prep/2026-09-07-v22-isolated/scripts/Assert-V22LocalContainerRuntime.ps1`, sans attribuer cette copie au SHA absent.

## Prédicat audité

Lignes 10-12 : exige le marqueur de build, le hostname et une image digest-pinnée. Lignes 13-14 : exige que les trois endpoints applicatif/SQL/AuthenticationServer soient le hostname courant. Lignes 16-21 : exige `sqlservr`, un worker IIS et les ports 80/1433 en écoute. Lignes 23-26 : crée un marqueur sous `Agent.TempDirectory`.

Les tests synthétiques couvrent null, tableau vide, tableau à un élément et objet unique pour la projection `Where-Object LocalPort` : **PASS**. Les fixtures labels same-host/different-DB : **PASS**. Une fixture avec mêmes processus, ports et labels mais mounts, networks ou scope différents serait acceptée : le script ne reçoit ni ne lit ces trois propriétés. C’est une restriction volontaire documentée par la ligne 26 (« does not attest container identity, mounts, lifecycle or absence of shared targets »), pas une preuve d’isolation.

Défaut démontré : `RunId` n’était pas borné au scope du répertoire ; des séparateurs pouvaient produire un chemin hors du répertoire racine. Correction locale ajoutée : refus des séparateurs/séquences parent, normalisation et vérification de préfixe avant écriture. Fixtures `build-FixHistorical-prewrite`, `..\\escape`, `\\..\\escape`, `x/../../escape` : **SCOPE FIXTURES PASS**. Syntaxe et manifeste : **PASS**.

## Transposition aux jobs métier

Dans `scripts/steps-replay-variant.yml` :

1. lignes 12-17 : checkouts ; lignes 18-30 : création du dossier et écriture de `v22-fix.cy2px`.
2. lignes 31-33 : readiness locale avant téléchargement JFrog et déploiement.
3. `FixCandidate` : lignes 34-39, attestation baseline avant téléchargement/déploiement.
4. lignes 40-60 : téléchargement, extraction, hash ZIP et restauration/déploiement.
5. lignes 61-67 : vérification packages puis readiness post-déploiement ; elle est explicitement annotée « not isolation proof ».
6. lignes 68+ : JMeter, campagnes, comparaison et cleanup.

Conclusion précise : aucune écriture SQL/IIS/PlatformDeploy n’intervient avant le garde-fou readiness propre à chaque job ; l’écriture de configuration temporaire sous `Agent.TempDirectory` intervient avant ce garde-fou. En revanche, aucun des deux jobs ne porte une preuve de mounts, networks, identité de conteneur ou absence de cible partagée. Ne pas simuler cette attestation dans le candidat ; elle doit rester une preuve runtime issue du préflight/exécution autorisée.

## Obstacle technique restant

Le seul défaut local corrigé est le scope du marqueur. L’isolation runtime détaillée reste **UNKNOWN** : le contrôle actuel prouve la readiness services/ports et l’alignement des hostnames, pas l’isolation. Le digest confirmé reste inchangé. Aucun nouveau run n’est requis pour ce diagnostic.
