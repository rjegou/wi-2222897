# Documentation de migration AutoTest Legacy vers JMeter

Ce dossier sépare les guides lisibles, le contexte du WI, les documents sources historiques et les fichiers de suivi.

## Ordre de lecture

1. [Contexte du WI](context/README.md) : règles spécifiques et snapshot du PBI.
2. [Procédure de migration](guides/PROCEDURE_MIGRATION_JMETER.md) : déroulement opérationnel.
3. [Environnement et exécution locale](guides/ENVIRONNEMENT_ET_EXECUTION_LOCALE.md) : SQL, backups, `cy2px`, Fix/Cur et exécution.
4. [Dépannage](guides/DEPANNAGE_JMETER.md) : contrôles et diagnostic.
5. [Fonctionnement technique](guides/FONCTIONNEMENT_TECHNIQUE.md) : comportement établi par lecture du code.

Pour les échecs FrenchTaxesRules et Clienteling déjà analysés, partir du [handoff de l'investigation](../investigations/ecarts-jmeter-migrations/HANDOFF.md).

## Hiérarchie des sources

En cas de contradiction :

1. critères du WI et décisions datées pour le périmètre à livrer ;
2. code actuel et fonctionnement technique pour le comportement réellement implémenté ;
3. guides réorganisés ;
4. PDF historiques, à revalider avant exécution.

Les versions, branches, images, chemins d'infrastructure et exemples issus des PDF ne sont pas présumés actuels.

## Sous-dossiers

| Dossier | Contenu | Écriture attendue |
|---|---|---|
| [guides/](guides/README.md) | procédures Markdown consolidées | mettre à jour un guide existant ; éviter les doublons |
| [context/](context/README.md) | synthèse métier et snapshots du WI | nouveau snapshot daté avec provenance |
| [source-material/](source-material/README.md) | neuf PDF historiques inchangés | ajouter une source brute sans la réécrire |
| [tracking/](tracking/README.md) | tableur original et CSV recalculé | nouvelle version datée et méthode de calcul |

Un PDF hors périmètre a été déplacé sans suppression vers `../archive/out-of-scope/`.

## Règles documentaires

- Ne recopier aucun secret visible dans une capture.
- Signaler les valeurs historiques, propositions et inconnues.
- Pour une opération destructive décrite par une ancienne procédure, exiger une cible vérifiée et une autorisation explicite.
- Lier une preuve plutôt que recopier un long contenu brut.
