# Consignes locales — WI-2222897

Ces règles s'appliquent à tout le dossier, sauf instruction plus spécifique dans un dépôt imbriqué.

## Démarrage obligatoire

1. Lire [README.md](README.md).
2. Lire [STATUS.md](STATUS.md) et vérifier sa date de fraîcheur.
3. Choisir le parcours correspondant à la tâche dans [TASKS.md](TASKS.md).
4. Avant d'éditer un dépôt, exécuter `git status --short --branch` dans ce dépôt précis.

Ne pas parcourir récursivement les preuves ou les snapshots avant d'avoir lu leurs index : le workspace contient plusieurs gigaoctets d'artefacts bruts.

## Frontières de sécurité

- **Ce dossier est un dépôt Git** (`C:/clones/wi-2222897`), versionné depuis le 2026-09-08.
  Committer par unité de travail cohérente. Le remote est un dépôt GitHub **privé** personnel :
  ne rien pousser sans demande explicite, et vérifier avant tout push que le contenu ajouté est
  publiable hors de l'infrastructure Cegid.
- Il ne contient que la **couche documentaire**. Les clones Git modifiables, les snapshots de dépôts
  et les artefacts bruts volumineux sont **hors dépôt** : voir [EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md).
  Ne pas les réimporter ici ; `.gitignore` s'y oppose déjà.
- Le travail non committé qui n'existait que dans les clones a été extrait dans
  [patches/](patches/README.md). Avant de recloner ou de modifier un dépôt, lire ce dossier :
  il contient les corrections effectives de la mission.
- Azure DevOps, les VM, Artifactory/JFrog et les autres systèmes externes sont en lecture seule par
  défaut. Ne pas pousser, créer de branche ou PR, commenter, voter, relancer, publier, promouvoir,
  taguer ou nettoyer sans demande explicite.
- Ne jamais ouvrir, afficher, copier, journaliser ou committer un secret. Deux points connus, aucun
  créé ici : `jfrogToken.txt` dans le clone `Migration_Jmeter_RJE_Sandbox`, et un mot de passe en dur
  dans `Generate_CSharp_Tablet.cmd` du dépôt `Y2_Plugins_InventoryTracking`. Détail en section 6 de
  [EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md).
- Un PAT Azure DevOps est disponible pour toute action autorisée, dans le fichier `azureToken.txt` du
  dossier `Documents` de l'utilisateur, hors de ce dépôt. L'initialiser uniquement dans le processus
  courant, ne jamais l'afficher, le persister ou le committer, puis supprimer la variable
  d'environnement après usage.
- Les `evidence/` sont des preuves : ne pas modifier leur contenu. Ajouter une nouvelle collecte dans
  un nouveau sous-dossier. Un `README.md` de renvoi signale les dossiers dont les artefacts bruts sont
  restés hors dépôt.
- `archive/` n'est jamais une source d'état courant, y compris
  [archive/status-history-2026-09.md](archive/status-history-2026-09.md). Ne l'utiliser que pour
  retracer une décision ou retrouver un document remplacé.

## Langage de preuve

Toute conclusion importante doit être qualifiée :

- `FACT` : soutenu par une preuve directe, localisée et datée ;
- `INFERENCE` : déduction explicite à partir de faits cités ;
- `UNKNOWN` : preuve absente, contradictoire ou comparabilité insuffisante.

Un pipeline vert ne prouve pas qu'un stage attendu a été exécuté. Une soumission asynchrone acceptée ne prouve pas le résultat final. Un enchaînement YAML statique ne prouve pas le contenu d'une image. Un TRX legacy doit être inspecté avant d'être jugé non pertinent, mais ne devient comparable à JMeter qu'avec le même scénario, contrat, versions, backup, paramètres et environnement.

## Où produire

| Type d'information | Emplacement |
|---|---|
| État courant du WI | [STATUS.md](STATUS.md) — **sans section datée** ; l'historique va dans `archive/` |
| Arbitrage en attente ou rendu | [decisions/README.md](decisions/README.md) |
| Communication vers le PO ou le lead dev | `reporting/`, un fichier daté par communication |
| Correction extraite d'un clone | `patches/`, avec son en-tête de branche et de `HEAD` |
| Mode opératoire stable | `documentation/guides/` |
| Contexte métier ou snapshot du WI | `documentation/context/` |
| Inventaire de suivi | `documentation/tracking/`, fichier daté |
| Nouvelle enquête | `investigations/<sujet>/` selon le gabarit de [TASKS.md](TASKS.md) |
| Preuve brute d'une enquête | `investigations/<sujet>/evidence/<sujet>/` |
| Conclusion atomique | `investigations/<sujet>/findings/NNN-<sujet>.md` |
| Matrice de suivi ou de comparaison | `investigations/<sujet>/cases/` |
| Trace chronologique de session | [JOURNAL.md](JOURNAL.md) |
| Ressource temporaire et dépollution | [RESOURCES.md](RESOURCES.md) |

Ne pas créer un deuxième document canonique pour le même sujet. Mettre à jour l'index parent dès
qu'un fichier ou un sous-dossier est ajouté.

## Nommage des dossiers de preuve

Le nom d'un dossier de preuve dit **le sujet et l'objet observé**, jamais son producteur :
`build-<id>-<sujet>/`, `run-<id>-<sujet>/`, `<repo>-<branche>-build-<id>/` ou
`local-YYYY-MM-DD-<sujet>/`. Le producteur, la date, la méthode et les limites vont dans le
`README.md` interne.

Les dossiers historiques nommés `…-worker<N>-round<M>` sont conservés sous leur nom : les renommer
casserait les liens cités par les `findings/`. Leur sujet est donné par
[l'index des preuves](investigations/ecarts-jmeter-migrations/evidence/README.md), qui liste aussi les
43 dossiers dont le `README.md` n'a pas encore de titre exploitable.

## Exigences de provenance

Pour toute nouvelle collecte, relever au minimum : date, système source, identifiant exact (build, run, commit, branche ou chemin), méthode de collecte et statut de fraîcheur. Ajouter un manifeste ou des empreintes pour les lots importants. Les noms recommandés sont `build-<id>/`, `run-<id>/`, `<repo>-<branche>-build-<id>/` ou `YYYY-MM-DD-<sujet>/`.

## Fin de session

Mettre à jour les documents canoniques avant le journal, puis committer. Ne déclarer une tâche terminée que si sa postcondition est prouvée. Consigner ce qui a été fait, ce qui ne l'a pas été, les décisions, les nouveaux `UNKNOWN` et les ressources à dépolluer.
