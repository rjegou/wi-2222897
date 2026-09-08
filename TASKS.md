# Parcours par tâche

Ce document répond à deux questions : **où lire** avant d'agir et **où écrire** le résultat. Les règles de sécurité de [AGENTS.md](AGENTS.md) restent prioritaires.

## 1. Comprendre ou actualiser le WI

Lire : [README.md](README.md), [STATUS.md](STATUS.md), puis [documentation/context/](documentation/context/README.md).

Produire :

- changement d'état consolidé dans `STATUS.md` ;
- nouvelle preuve brute du work item dans `evidence/azure-devops/work-item-2222897/YYYY-MM-DD/` ;
- trace de session dans `JOURNAL.md`.

Terminé lorsque la date, la source et les écarts avec le snapshot précédent sont explicites.

## 2. Migrer un couple plugin/branche

Lire dans cet ordre :

1. [synthèse du PBI](documentation/context/PBI_2222897_synthese_visio_Ludo.md) ;
2. [procédure](documentation/guides/PROCEDURE_MIGRATION_JMETER.md) ;
3. [fonctionnement technique](documentation/guides/FONCTIONNEMENT_TECHNIQUE.md) ;
4. `worktrees/Migration_Jmeter_RJE_Sandbox/README.md` et son état Git ;
5. [dépannage](documentation/guides/DEPANNAGE_JMETER.md) avant de qualifier un résultat.

Produire : code et fichiers générés dans le worktree/plugin de travail ; captures de validation dans une investigation existante ou nouvelle ; mise à jour du suivi dans `documentation/tracking/`.

Ne pas conclure sur un build vert sans vérifier que `Build` et tous les stages `TI JMeter V<n>` attendus ont réellement été exécutés et ont réussi.

## 3. Exécuter ou dépanner localement

Lire : [environnement local](documentation/guides/ENVIRONNEMENT_ET_EXECUTION_LOCALE.md), puis le README du worktree concerné.

Produire : résultats temporaires dans les dossiers prévus par l'outil ; si le résultat devient une preuve, le copier sans modification sous `investigations/<sujet>/evidence/local-YYYY-MM-DD-<cas>/` avec un `README.md` de provenance.

Terminé lorsque la postcondition fonctionnelle est vérifiée, pas seulement lorsque le processus retourne un code zéro.

## 4. Mettre à jour l'inventaire des plugins/branches

Lire : [documentation/tracking/README.md](documentation/tracking/README.md), les dépôts canoniques et les règles de support en vigueur.

Produire : un fichier daté dans `documentation/tracking/`. Ne pas écraser l'original historique sans conserver la provenance et la règle de calcul. Mettre à jour `STATUS.md` si le périmètre restant change.

## 5. Diagnostiquer un écart JMeter/legacy

Lire dans cet ordre :

1. [handoff canonique](investigations/ecarts-jmeter-migrations/HANDOFF.md) ;
2. [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) ;
3. [index des preuves](investigations/ecarts-jmeter-migrations/evidence/README.md) ;
4. fiche `findings/` du build ou du symptôme concerné ;
5. [matrice legacy](investigations/ecarts-jmeter-migrations/cases/LEGACY_COMPARISON_MATRIX.md) si une comparaison est revendiquée.

Produire :

- brute immuable : `evidence/build-<id>/`, `evidence/run-<id>/` ou `evidence/local-YYYY-MM-DD-<cas>/` ;
- snapshot de code exact : `sources/<repo>-<branche>-build-<id>/` ;
- conclusion atomique : `findings/NNN-<sujet>.md` ;
- changement de verdict : `cases/STATUS_MATRIX.md` et, si nécessaire, `cases/LEGACY_COMPARISON_MATRIX.md` ;
- reprise : `HANDOFF.md`.

Terminé lorsque chaque cause est soit prouvée et localisée, soit conservée en `UNKNOWN`, avec un rejeu discriminant défini.

## 6. Collecter une preuve Azure DevOps ou VM

Lire : l'index `evidence/README.md` de l'investigation et, pour le legacy, `references/legacy_test_vm_technical_cheatsheet.md`.

Produire un dossier séparé avec :

- `README.md` : date, source, identifiant, commande/méthode, portée et limites ;
- fichiers bruts inchangés ;
- `MANIFEST.csv` ou inventaire équivalent ;
- `SHA256SUMS.txt` pour un lot transmis ou volumineux.

Ne jamais mêler deux builds, deux variantes ou une preuve legacy et une preuve JMeter sans sous-dossiers explicites.

## 7. Implémenter une correction

Lire : [CORRECTION_PLAN.md](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md), la fiche `findings/` citée et le code actuel du dépôt propriétaire.

Produire : changement et tests dans un worktree dédié sous `worktrees/`. Les snapshots `sources/` restent intacts. Mettre à jour la fiche et le plan seulement après validation. Toute publication, promotion, PR ou relance distante exige l'autorisation prévue par la tâche.

Terminé lorsque le test unitaire ou smoke test échoue avant le correctif, passe après, et que le rejeu minimal prouve la disparition de la cause sans masquer les autres erreurs.

## 8. Travailler sur le pipeline 5224 ou le NuGet workflow

Lire : [index des preuves 5224](evidence/azure-devops/pipeline-5224/README.md), puis `worktrees/Y2_Tools_Jmeter_Workflow/README.md` et l'état Git.

Produire : code dans le worktree ; nouvelle collecte dans `evidence/azure-devops/pipeline-5224/<date-ou-build>/`. Préserver la modification locale actuelle. Pour un essai isolé, toutes les publications, promotions, tags et copies externes doivent rester désactivés.

## 9. Créer une nouvelle investigation

Créer uniquement si le sujet ne rentre pas dans l'enquête existante :

```text
investigations/<sujet>/
├── README.md       routage court
├── HANDOFF.md      état autonome et ordre de reprise
├── cases/          matrices et registres
├── findings/       conclusions atomiques
├── evidence/       preuves brutes et index
├── sources/        snapshots exacts, immuables
└── references/     procédures externes utiles à l'enquête
```

Indexer immédiatement la nouvelle enquête dans `investigations/README.md` et dans le routeur racine si elle devient un parcours principal.

## 10. Préparer un handoff LLM

Le handoff doit contenir : objectif, snapshot daté, périmètre, conclusions `FACT/INFERENCE/UNKNOWN`, matrice, chemins exacts, builds/runs/commits, état des worktrees, actions non réalisées, ordre de reprise et critères de fin. Il doit rester autonome mais renvoyer vers les preuves au lieu de les recopier.

Avant de terminer, vérifier les liens, mettre à jour `STATUS.md`, `JOURNAL.md` et `RESOURCES.md`.
