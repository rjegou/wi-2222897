# PBI 2222897 — Synthèse des consignes de migration Legacy → JMeter

## Objectif

Finaliser la migration des derniers plugins / branches vers les tests JMeter afin de :
- rendre les pipelines compatibles avec les nouvelles plateformes supportées ;
- mettre à jour l'inventaire des erreurs restantes ;
- disposer d'une base fiable pour estimer les corrections encore nécessaires.

Le travail porte donc à la fois sur **l'outil de migration**, **l'exécution des pipelines** et **la collecte des résultats**.

## Règles par version

### Versions V21 et inférieures

Ces versions sont considérées comme **abandonnées**.

Conséquences :
- effectuer tout de même la migration ;
- commenter le **job de copie de l'image Docker vers l'ACR** ;
- commenter le **stage des tests JMeter** ;
- ne pas chercher à valider le résultat des tests ;
- créer une Pull Request.

En pratique, **aucune exécution des tests JMeter n'est attendue pour V21 et inférieur**.

### Versions supérieures à V21

- effectuer la migration ;
- exécuter le pipeline **build + tests JMeter** ;
- collecter les résultats / erreurs ;
- créer une Pull Request lorsque l'exécution est concluante.

Le transcript ne définit pas précisément le terme *tests concluants*. Ce qui est certain pour ce PBI est que l'objectif principal est de **faire tourner les pipelines et relever les erreurs restantes** afin de mettre à jour l'inventaire.

## Images Docker à appliquer

L'outil de migration doit être mis à jour car le comportement attendu a changé : auparavant la même image était utilisée partout.

Nouvelles règles :

- **V26 / `master`**  
  `win2025sql2025dotnet10`

- **Autres branches supportées**  
  `win2022sql2019dotnet10`

Ludo recommande de prendre comme référence le plugin / dépôt **Technical**, pour lequel ces adaptations ont déjà été faites manuellement. La référence Technical sert surtout à comprendre les modifications liées aux images ; le reste du mécanisme de migration ne change pas.

## Mise à jour de l'outil de migration

Adapter l'outil pour automatiser au minimum :

1. le choix de l'image Docker selon la version ;
2. pour V21 et inférieur :
   - commentaire du job de copie vers l'ACR ;
   - commentaire du stage des tests JMeter ;
3. conservation du comportement standard pour les versions supérieures à V21.

Une fois cette mise à jour faite, l'objectif est de pouvoir migrer rapidement l'ensemble des branches restantes.

## Exécution et collecte des erreurs

Après migration des branches supportées > V21 :

1. lancer les pipelines ;
2. relever les erreurs obtenues ;
3. consolider ces résultats dans le tableau Excel **Migration AutoTests Legacy To Jmeter** ;
4. disposer d'un inventaire à jour permettant d'estimer le volume de corrections restantes.

Ludo décrit explicitement l'objectif comme le fait de **refaire / mettre à jour le tableau pour savoir combien d'erreurs il reste**.

## Livrables attendus

- Outil de migration mis à jour.
- Branches / plugins restants migrés.
- PR créée pour chaque migration.
- Pipelines exécutés pour les versions > V21.
- Tableau Excel **Migration AutoTests Legacy To Jmeter** mis à jour avec les erreurs restantes.
- Ludo et Lydie notifiés après collecte des erreurs afin qu'ils puissent revoir / ajuster les PBI de correction associés aux couples plugin / branche.

## Points fiables issus de la visio

- V21 et inférieur sont explicitement qualifiées d'**abandonnées** par Ludo.
- Pour ces versions, on migre mais on ne cherche pas à faire fonctionner les tests.
- Deux blocs doivent être neutralisés : la copie vers l'ACR et le stage de tests JMeter.
- V26 correspond normalement à `master`.
- V26 utilise l'image Windows/SQL 2025 ; les autres branches supportées utilisent Windows 2022 / SQL Server 2019.
- Le dépôt / plugin Technical constitue l'exemple de référence pour les modifications liées aux images.
- Le but immédiat du PBI est surtout de **migrer, exécuter les branches pertinentes et inventorier les erreurs restantes**, pas de corriger toutes ces erreurs dans ce même PBI.

## Point restant ambigu

La définition exacte de **« tests concluants »** pour décider qu'une PR peut être créée n'est pas explicitée dans la visio. Le transcript confirme surtout la nécessité de lancer les tests sur les versions > V21 et d'en collecter les erreurs.
