# Export_Run avant/après — blocage de complétude — 2026-09-06

## FACT

- Préparation contrôlée : `local-2026-09-06-export-run-tc08-tc10-prep/`, manifeste et plan complet conservés.
- Le plan `fixtures/TestPlans/Export_Run.xml` contient dix références `InputFiles\Export\Run_01.xml` à `Run_10.xml`.
- Présents dans la préparation : `Run_08.xml`, `Run_09.xml`, `Run_10.xml`.
- Manquants : `fixtures/TestPlans/InputFiles/Export/Run_01.xml` à `Run_07.xml` — liste complète dans `missing-inputs.tsv`.

## Décision

Arrêt avant création des espaces `original`/`corrected`, vérification des runtimes et lancement de Console. Aucun fichier n'a été supprimé, ajouté à la préparation, modifié ou généré. Aucun JMX, SQL, HTTP, JMeter, réseau ou packaging n'a été utilisé.

La comparaison avant/après du plan complet est donc `UNKNOWN`. Les cas TC08–TC10 seuls ne peuvent pas être exécutés ici sans supprimer ou modifier des cas du plan, ce qui est interdit par l'étape.
