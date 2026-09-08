# FrenchTaxesRules API — préparation de branche isolée

Date de collecte : 2026-09-08 (Europe/Paris)

## Périmètre

Cette collecte est bornée à la branche API créée manuellement pour WI-2222897. Aucun push,
aucune queue de pipeline, aucune publication de package, aucun changement Azure DevOps et aucun
document canonique partagé n'a été effectué.

## Provenance distante

- Système : Azure DevOps `https://dev.azure.com/cegid`, projet `Retail`.
- Dépôt : `Y2_Tools_AutoTest_Api`, id `60951ba6-fb32-4a61-9b7d-9df7b31d575c`.
- Référence : `refs/heads/sandbox/frenchtaxesrules/api-jmeter-fixes`.
- HEAD lu par `az repos ref list` et clone Git :
  `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- Dépôt lisible : `az repos show`, `az repos ref list` et clone mono-branche réussis avec PAT
  uniquement en mémoire de processus; le PAT n'est pas reproduit ici.

## Corrections reconstituées

Le patch `patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch` s'applique sans conflit au
HEAD distant. Il modifie uniquement `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` et reconstitue :

1. `EscapeJdbcDate` : ordre ISO `yyyyMMdd`.
2. `FixSqlUnicodeValue` : parcours des littéraux SQL, apostrophes doublées et préfixe `N`.
3. `RemoveSpecialCharsForXQuery` : échappement de `&` avant `<`, `>` et apostrophe.
4. `CleanXpath` plus préparation SOAP Fault namespace-aware dans `XPathJmeter`.

Les trois scripts présents sous le lot `.untracked/tests/` couvrent `CleanXpath`,
`FixSqlUnicodeValue` et `RemoveSpecialCharsForXQuery`. Aucun script séparé `EscapeJdbcDate` n'est
présent dans ce lot; sa validation antérieure reste une preuve distincte, non une exécution
rejouée ici.

## Pipeline candidat préparé localement

Le YAML distant lu sur le même HEAD est actuellement non isolé : trigger `master`, schedule
`master/releases/*`, version calculée depuis `SolutionInfo.cs`, et stage `Promote` conditionné
par master/releases.

Le clone temporaire contient un diff candidat non publié avec les garde-fous suivants :

- `trigger: none` et `pr: none` ; schedules supprimés ;
- `ComponentVersion` explicite : `1.1.47-wi2222897-api-candidate` ;
- lecture de `SolutionInfo.cs` retirée pour empêcher le retour silencieux à la version stable ;
- stage `Promote` forcé à `condition: false` ;
- les uploads Artifactory restent eux-mêmes limités aux branches `master`/`releases/*` dans le
  YAML, et le stage de promotion est désactivé.

Le diff candidat est local au clone temporaire
`C:\Users\jegour\AppData\Local\Temp\wi2222897-api-branch`; il n'est pas dans le dépôt
documentaire et n'a pas été poussé.

## Validations et limites

- `git status --short --branch` avant édition du clone : branche sandbox suivie par son remote,
  propre.
- `git apply` du patch API : succès.
- `git diff --check` après patch API et YAML candidat : aucune erreur de whitespace.
- Contrôle textuel du YAML candidat : `trigger: none`, `pr: none`, absence de `schedules`, version
  candidate explicite et `Promote condition: false` présents.
- Le clone frais ne contient pas `packages/`; aucune compilation net452 indépendante n'est
  revendiquée dans cette collecte. Les validations binaires antérieures sont référencées par
  l'index de preuves, mais ne remplacent pas un build de cette branche.
- Aucun build API, build Console, upload de package ou run JMeter n'a été lancé.

## Verdict

- **FACT** : branche distante existante et HEAD identifié; patch applicable exactement à ce HEAD.
- **FACT** : le YAML distant actuel n'est pas isolé pour un essai de branche.
- **FACT** : un diff candidat local avec déclenchements et promotion désactivés a été préparé et
  contrôlé statiquement.
- **UNKNOWN** : compilation depuis ce clone sans restauration/staging des dépendances; propagation
  API → Console → migration; résultat d'un vrai build ou run JMeter.

Étape suivante après revue technique : publier le diff candidat sur la branche existante, puis
relire le commit distant et lancer au maximum un build API manuel isolé; ne pas lancer Console ou
JMeter avant inspection de l'artefact et confirmation de la version candidate.
