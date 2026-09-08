# Contrat commun des trois instances BW

Statut : PROPOSITION PREPAREE, AUCUNE INSTANCE LANCEE. Source : décisions utilisateur du 2026-09-08.
Ce plan organise le travail ; le registre decisions/README.md reste canonique pour les décisions.

## Démarrage et frontières

Lire entièrement C:/clones/wi-2222897/AGENTS.md, README.md, STATUS.md et TASKS.md (parcours 5 et 7),
puis decisions/README.md, EXTERNAL-ARTIFACTS.md, patches/README.md et le handoff de l'enquête.
Lire les index avant les preuves ciblées. Les clones historiques ont été supprimés : ne pas
supposer leur existence. Les preuves externes sont sous C:/clones/wi-2222897-evidence, en lecture seule.
Appliquer les skills requis par les opérations réellement entreprises.

Chaque instance écrit uniquement dans le -Path qui lui est attribué, y compris clones indépendants,
sorties de génération, cache NuGet propre, profil AZURE_CONFIG_DIR propre et fichiers temporaires.
Ne pas créer de worktree rattaché à un clone partagé : il partagerait aussi des métadonnées Git.
Avant toute édition d'un clone : git status --short --branch et HEAD exact.
Ne jamais modifier la configuration Git globale, changer globalement de compte ou tuer un processus
d'une autre session. Ne pas créer de service, conteneur, base ou écoute réseau dans ce premier lot.

Le dépôt documentaire C:/clones/wi-2222897 et les espaces des deux autres instances sont en lecture seule.
Exception organisationnelle au flux de fin de session du dépôt canonique : chaque instance tient
son propre RESULT.md et son index local ; seul l'intégrateur mettra à jour STATUS, HANDOFF, JOURNAL,
decisions, cases et findings après revue. Aucun git add/commit dans le dépôt documentaire par les instances.
Pas de modification des preuves existantes, des patches conservés, des .work ou des clones historiques.

Systèmes externes en lecture seule : consultations et téléchargements ciblés autorisés, sans push,
création de branche/PR, commentaire, queue de pipeline, publication NuGet/Docker, Promote, Tag,
TestAutos ni nettoyage distant. Si un rejeu distant est requis, livrer un plan exact révisable,
ses effets et préconditions ; ne pas le lancer dans ce lot. La publication partagée reste une
décision ultérieure avec versions et destination précises. Ne jamais afficher ou conserver un secret ;
respecter le chargement temporaire du PAT et les fichiers sensibles identifiés dans AGENTS.md.

## Propriété et dépendances

| Instance | Ecritures source exclusivement dans ses clones | Dépendance commune |
|---|---|---|
| couverture | outil de migration et BeforeMigration.ps1 retrouvé dans son dépôt propriétaire ; copie privée API/Console si nécessaire | propriétaire unique des candidats de générateur commun de ce lot |
| inventorytracking | Y2_Plugins_InventoryTracking et tests locaux de chargement | si défaut du générateur commun, livrer une reproduction et une proposition, ne pas modifier API/Console/migration |
| clienteling | Y2_Plugins_Clienteling et copie privée du brouillon de provisionnement 14264 | ne pas modifier API/Console, PlatformDeploy commun ou les images SQL |

Les packages communs sont des entrées immuables identifiées par version/hash, copiées dans chaque
espace. Aucune instance ne consomme une sortie en cours d'écriture d'une autre : transmettre un
manifeste figé à l'intégrateur pour une seconde passe. Pas d'attente mutuelle entre les trois.
Aucun lancement supplémentaire de bw par les instances. Dans une instance, affecter aussi des
fichiers distincts aux workers internes ; un seul worker éditeur par clone.
L'implémentation bw actuelle prévoit jusqu'à trois workers internes par instance : trois commandes
ne signifient donc pas seulement trois workers. La limite de tours est un plafond, pas une preuve de fin.

## Livrables et postconditions

Dans son espace : README.md (index), RESULT.md, findings/, evidence/<sujet-et-objet>/,
patches/ et clones/ si nécessaires. Toute preuve : source/date/commit/build/méthode/fraîcheur,
manifestes et hashes ; ne pas faire entrer les binaires dans le dépôt documentaire.
RESULT.md doit distinguer FACT/INFERENCE/UNKNOWN, test avant/après, couverture nominative,
actions non exécutées, chemins des patches et ressources à conserver. Pas de conclusion métier
depuis une génération au code zéro, un chargement JMX ou un pipeline aux étapes skipped.
Un manque de preuve impose un verdict partiel explicite, pas une clôture fictive.
