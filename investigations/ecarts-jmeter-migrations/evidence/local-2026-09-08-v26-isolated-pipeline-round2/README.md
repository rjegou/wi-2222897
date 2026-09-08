# Candidat de pipeline V26 isolé — FrenchTaxesRules

Date de préparation : 2026-09-08 (Europe/Paris). Portée : matérialiser une chaîne
reviewable sans queue, publication externe, modification distante ou rejeu métier.

## Provenance distante relue

- API : `Y2_Tools_AutoTest_Api`, id `60951ba6-fb32-4a61-9b7d-9df7b31d575c`.
- Ref exacte : `refs/heads/sandbox/frenchtaxesrules/api-jmeter-fixes`.
- HEAD : `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- Requête correcte : `GET .../refs?filter=heads/sandbox/frenchtaxesrules/api-jmeter-fixes&$top=1000`.
  La variante sans préfixe `heads/` retourne zéro résultat dans cette API; c'était la cause du
  faux `NOT_FOUND` de la collecte précédente. La réponse correcte contient une ref et aucun
  continuation token.

## Définitions examinées

- `2054 — FrenchTaxesRules CI` : YAML `/azure-pipelines.yml`, dépôt
  `Y2_Plugins_FrenchTaxesRules`, `master`, triggers master/releases, publication Artifactory
  staging, TestAutos et stage Promote/Tag. **Non isolée; ne pas la mettre en queue.**
- `11454 — Y2_WebApps_FrenchTaxesRules_Jmeter` : YAML `azure-pipelines-Jmeter.yml`, dépôt
  référencé `Y2_WebApps_FrenchTaxesRules` id `1e641c9d-cac0-47ab-8d57-49ce1fada8f6`. La lecture
  du dépôt référencé répond HTTP 404; sa chaîne exacte n'est donc pas reconstructible depuis la
  lecture actuelle. Son build `4426188` a échoué au stage `Jmeter`; ce n'est pas une voie fiable.
- Build `4432510` : Build réussi, Cur/Fix `succeededWithIssues`, publication Artifactory staging
  réussie. Il démontre l'exécution historique des stages, pas l'isolation.

## Contrat du candidat

Le YAML joint :

- désactive CI, PR et schedules;
- exige les commits plugin/API, le package Console et son SHA-256, PlatformDeploy, les cibles
  applicatives/SQL et un marqueur de cible dédiée; toute valeur manquante provoque un refus;
- épingle plugin `26.0.10.75`, Core `26.0.0.1762`, image JMeter digest
  `sha256:ea74f21a...c0a9dbf2` et JMX Export corrigé `C59BD01D...EB0C`;
- séquence `Build` puis `JMeter_Cur` puis `JMeter_Fix`, avec déploiement et campagne dans chaque
  cible dédiée; `JMeter_FullCampaign` reste opt-in (`runFullCampaign=false`) et refuse un nom de
  campagne absent, afin que la campagne complète ne puisse démarrer qu'après le minimum;
- exécute d'abord `ExportRunOnly` puis `DocumentSignatureSignOneOnly`; le contrôle attendu est
  Export_Run TC08/TC09/TC10 puis DocumentSignature_SignOne TC02; les plans complets doivent
  conserver les résultats absent/skipped et aucune assertion ne peut être assouplie;
- conserve seulement un PipelineArtifact de preuve, contenant provenance, JTL, JUnit, logs,
  manifestes du JMX effectivement passé à JMeter, package et backup hashés; aucun upload staging,
  promotion, tag ou TestAutos n'est référencé.

Les templates `replay-assets/templates/*.candidate.yml` sont des dépendances à copier dans le
commit exécuté avec le YAML. Le candidat ne doit pas être publié ou mis en queue tant que ces
templates, le descripteur `DocumentSignatureSignOneOnly`, le backup, les packages et les cibles
dédiées ne sont pas présents et hashés.

Le descripteur `ExportRunOnly` doit rester explicitement raccordé au JMX corrigé
`Tests\Export_Run\001-Export_Run.jmx` (hash ci-dessus). Le plan `Export_Run` est complet : le
runner doit conserver tous ses résultats et vérifier TC08 puis TC09/TC10, pas prétendre que le
nom de campagne sélectionne uniquement trois cas. La preuve hardened précédente avait encore un
écart de collecte : son script cherchait `Tests\LegacyServices\010-Export_Run.jmx`, alors que le
contrat corrigé copie `Tests\Export_Run\001-Export_Run.jmx`; ce script ne doit donc pas être
réutilisé sans correction.

## Audit des effets et limites

**FACT** — le candidat ne contient aucune tâche Artifactory staging, promotion, tag, TestAutos ou
push. **FACT** — la publication déclarée est un PipelineArtifact du run seulement.

**UNKNOWN** — disponibilité d'un agent compatible, daemon Docker associé au job conteneur,
PlatformDeploy exact, package Console `2.0.43`, backup `AUTO_V26_00.bak`, descripteur
`DocumentSignatureSignOneOnly`, cibles et droits de la future définition. Le YAML est donc
préparé et fail-closed, mais pas encore publiable/exécutable.

## Vérification locale effectuée

- Relecture statique des définitions et timelines par REST Azure DevOps, PAT uniquement en mémoire;
  aucun secret n'est conservé.
- Contrôle textuel du YAML : `trigger: none`, `pr: none`, `schedules: []`, trois stages, absence
  des mots-clés d'effets externes interdits dans les tâches exécutables, et présence des quatre
  identités/version/hash obligatoires.
- `git diff --check` doit être exécuté après intégration du candidat; aucun fichier canonique
  partagé n'a été modifié par ce lot.
