# Préparation du rejeu métier Export_Run TC08–TC10 — 2026-09-06

## FACT

- La génération Console avant/après est validée sur le plan complet : preuve `../local-2026-09-06-export-complete-before-after/`, Console original/corrected code `0`, JMX comparés. Cette preuve ne contient ni SQL, ni JMeter, ni appel HTTP.
- Le plan impose l'ordre TC08 → TC09 → TC10. TC08 comporte trois prérequêtes et des contrôles finaux ; TC09 comporte trois prérequêtes et des contrôles `2/1/0` ; TC10 comporte une prérequête et des contrôles finaux. Les contrôles XML attendent `1`. TC09/TC10 sont sensibles à l'état résiduel de TC08 selon `findings/001-french-taxes-rules-v26.md`.
- Le guide local exige Java 21, SQL Server 2019, pilote JDBC compatible, JMeter/workflow, backup correspondant, packages/versions exacts, `cy2px`, tenant dédié, services SQL et services Y2/Authentication accessibles.
- Le worktree `Y2_Plugins_FrenchTaxesRules` au commit `07a42172...` ne contient pas de répertoire `Tests/Config` ni de backup local. L'équivalence du backup historique n'est pas démontrée.
- Les versions historiques ne sont pas interchangeables : legacy aval `FrenchTaxesRules 26.0.10.25`/Core Fix `26.0.0.1762`, build JMeter 4432510 `26.0.10.75`, build 4426342 `26.0.10.67`.

## Voies identifiées

- Local dédié : techniquement préférable, mais `UNKNOWN`/bloqué tant que backup, packages, `cy2px`, SQL Server 2019, services Y2/Auth, pilote JDBC et paramètres isolés ne sont pas fournis. Aucun service, base ou conteneur n'a été démarré.
- Pipeline : définition locale identifiée `2054 — FrenchTaxesRules CI`; build de référence `4426342` (runs LegacyServices Fix `6175734`, Cur `6175735`) et build `4432288` sur `master` au commit `07a42172...`. Le YAML prouvé contient Publish Artifactory, Promote/Tag et TestAutos sur `Y2-TSTAUTOXXPG2`; il n'est pas une voie isolée utilisable telle quelle. Définition sandbox exacte : `UNKNOWN`.

## Proposition non exécutée

Créer/identifier une définition d'essai dédiée, sans Publish, Promote, Tag ni consommateur partagé, épinglée au commit et aux artefacts exacts. Restaurer un backup Fix dans une base/tenant/ports dédiés, déployer la même pile produit, puis exécuter uniquement le JMX corrigé `Export_Run` TC08→TC09→TC10. Succès : aucune erreur SQL/date, contrôles XML attendus, contrôles post/final exacts et nettoyage vérifié. Comparer ensuite à l'API originale dans un second espace équivalent.

Limites : aucune connexion distante ni lancement pipeline ; réussite métier, comparabilité legacy et isolation effective restent UNKNOWN.
