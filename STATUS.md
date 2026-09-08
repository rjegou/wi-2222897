# État consolidé — WI-2222897

**Snapshot du 2026-09-08.** Ce fichier ne contient que l'**état courant**. Les 27 sections datées
qui retraçaient l'historique jour par jour ont été déplacées sans perte dans
[archive/status-history-2026-09.md](archive/status-history-2026-09.md).

Motif de la séparation : l'ancien fichier mêlait l'état courant et son historique sans ordre
chronologique, et conservait des sections explicitement mentionnées comme supersédées à côté
de l'état en vigueur. Il fallait le lire intégralement pour connaître l'état.

Règle pour la suite : une modification d'état met à jour **la section concernée ci-dessous**.
Une nouvelle section datée va dans le fichier d'historique, pas ici.

## Où lire quoi

| Question | Fichier |
|---|---|
| Qu'est-ce qui bloque, et qui doit trancher ? | [decisions/README.md](decisions/README.md) |
| Quel est l'état de chaque domaine ? | la section « Synthèse » ci-dessous |
| Quelle est la cause d'un échec précis ? | [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) puis `findings/` |
| Que faut-il implémenter, et où ? | [CORRECTION_PLAN.md](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) |
| Que dire au PO / lead dev ? | [reporting/2026-09-08-synthese-onenote-pbi.md](reporting/2026-09-08-synthese-onenote-pbi.md) |
| Qu'est-ce qui s'est passé tel jour ? | [JOURNAL.md](JOURNAL.md) et l'historique d'état |
| Où sont les artefacts lourds ? | [EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md) |

## Synthèse

État par domaine au **2026-09-08**. Chaque ligne renvoie à la preuve qui la soutient.

| Domaine | État | Preuve canonique | Suite sûre |
|---|---|---|---|
| Périmètre et critères du WI | documentés | [README.md](README.md), [synthèse du PBI](documentation/context/PBI_2222897_synthese_visio_Ludo.md) | relire le work item live si une décision dépend de son état actuel |
| Procédure de migration | documentée, valeurs historiques signalées | [documentation/README.md](documentation/README.md) | revalider versions, chemins et prérequis avant exécution |
| Inventaire plugins/branches | 19 couples recalculés depuis les dépôts le 2026-09-03 ; bilan intermédiaire intégré le 2026-09-07 | [documentation/tracking/](documentation/tracking/README.md) | trancher la ligne de release Clienteling — [décision 1](decisions/README.md) |
| Diagnostic des échecs | 8 des 9 couples suivis classés `TERMINE` ; chaque cas non passé est rattaché à une cause. InventoryTracking reste `DIAGNOSTIC PARTIEL` | [matrice de statut](investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md) | implémenter les causes prouvées ; ne pas rouvrir un verdict sans preuve contraire |
| Comparaison legacy/JMeter | baseline V26 obtenue pour FrenchTaxesRules (253 scénarios) et Clienteling (2 131) ; **aucune baseline comparable pour V21–V25** | [matrice legacy](investigations/ecarts-jmeter-migrations/cases/LEGACY_COMPARISON_MATRIX.md) | ne reclasser qu'à scénario, contrat, versions, données et environnement identiques |
| Générateur JMX (4 défauts) | `EscapeJdbcDate`, `FixSqlUnicodeValue`, `RemoveSpecialCharsForXQuery` et `CleanXpath` corrigés, compilés et testés **localement** ; 105 cas concernés | [CORRECTION_PLAN.md](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) items 1–4 | autorisation de publication accordée le 2026-09-08 ; exécution encore bloquée par l’accès/les permissions — [décision 5](decisions/README.md) |
| SQL Full-Text (224 cas) | requalifié : les Dockerfiles activent bien `FullText`, mais la population n'aboutit pas dans la fenêtre de 90 s du probe. Patch de diagnostic prêt, **non publié** | [finding 014](investigations/ecarts-jmeter-migrations/findings/014-sql-fulltext-runtime-4442685.md) | autoriser le patch de diagnostic borné, puis corriger les images SQL de base avec un smoke test bloquant |
| InventoryTracking | cause du build initial prouvée ; correctif `ef3d8703` exercé : `4440774` Build réussi/JMeter skipped, `4440884` Build + Cur/Fix exécutés (1991 chacun), 339 échecs communs et seul delta `TC 122` Fix Failed/Cur Passed ; publication staging exécutée ; état fonctionnel et PR source non validés | [finding 013](investigations/ecarts-jmeter-migrations/findings/013-inventorytracking-xmlDiff-migration-build-4434070.md), [preuve round 2](investigations/ecarts-jmeter-migrations/evidence/2026-09-08-inventorytracking-azdo-access-diagnosis-round2/README.md) | lire les artefacts pour qualifier `TC 122`, maîtriser les effets partagés avant toute nouvelle exécution, puis préparer la PR appropriée si la source est retrouvée |
| Pipeline NuGet JMeter 5224 | chaîne de fabrication statique documentée ; contenu final de l'image non prouvé | [preuves pipeline](evidence/azure-devops/pipeline-5224/README.md) | inspecter une image isolée et comparer package/version/hash |
| Rejeu métier | **NOT RUN.** L'autorisation utilisateur est accordée, mais aucun rejeu n'a été exécuté ; les brouillons de pipeline restent inertes | [replay-prep/](investigations/ecarts-jmeter-migrations/replay-prep/) | obtenir l'accès distant, prouver package/version/hash et JMX consommés, puis master/V26 avant releases/V7 |
| Livrables globaux PBI | tableau de suivi rempli ; synthèse de reporting produite le 2026-09-08 ; notification Ludo/Lydie à confirmer | [reporting/](reporting/2026-09-08-synthese-onenote-pbi.md) | confirmer la notification et le processus PR/mail cadré par LBAU |
| Décisions bloquantes | **5 en attente**, dont 3 relèvent du périmètre produit ; décision 5 rendue le 2026-09-08 | [decisions/README.md](decisions/README.md) | résoudre les arbitrages restants ; l'accès opérationnel est un blocage technique, pas une absence d'autorisation |

## Dépôts de travail

Les clones Git et worktrees ne sont **pas** dans ce dépôt : ils restent à leur emplacement d'origine,
avec leur état Git propre. Emplacements exacts et états relevés dans
[EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md).

Deux points à connaître avant d'y toucher :

- `Y2_Tools_Jmeter_Workflow` porte une **modification locale de l'utilisateur** dans `azure-pipeline.yml`
  (14 ajouts, 3 suppressions au snapshot du 2026-09-06). À préserver.
- `Y2_Plugins_FrenchTaxesRules` est signalé **pollué** depuis le 2026-09-07 après un checkout interrompu,
  et sa lecture Git échouait sur `dubious ownership`. Le reclonage propre tenté le 2026-09-08 a échoué
  avec Git exit 128 sans créer de worktree ; à reprendre après rétablissement de l'accès.

Toujours exécuter `git status --short --branch` dans le dépôt concerné avant de travailler :
les états consignés sont des snapshots, pas des verrous.

## Faits établis à ne pas rouvrir sans preuve contraire

- Le défaut `EscapeJdbcDate` inverse mois et jour pour certaines dates ISO apostrophées ; la correction durable passe par AutoTest.Api, Console, l'outil de migration, la régénération puis le rejeu.
- Mise à jour locale 2026-09-06 : correctif local compilé et génération JMX validée sur six fixtures ; comparaison avant/après conservée dans `investigations/ecarts-jmeter-migrations/evidence/local-2026-09-06-api-jmx-date-before-after/`. La validation Console a ensuite été acquise, voir les compléments ci-dessous. Docker et rejeu métier restent non validés.
- Dépendances Console vérifiées localement : `Svn 1.0.4` et `XmlDiff 1.0.5` trouvés, mais `XmlDiffPatch.View` garde un PublicKeyToken différent de la référence du projet ; compilation Console `UNKNOWN` et non relancée.
- `ExpectedValue=-1` désactive le contrôle du nombre de lignes, pas l'exécution SQL ni les erreurs techniques.
- Les codes Console `-1` initiaux ont été résolus : chemins trop longs et input.xml mal placé. Console officielle avec substitution de l'API validée sur six fixtures puis Export_Run ; recompilation Console et packaging non validés.
- Les soumissions `TestAutos` acceptées ne prouvent pas le résultat aval.
- SQL Full-Text appartient aux images SQL de base consommées par le workflow JMeter ; son absence ne doit pas être corrigée au hasard dans le dépôt consommateur.
- Les snapshots sous `investigations/ecarts-jmeter-migrations/sources/` sont des preuves, pas des branches de correction.

La formulation complète et les preuves sont dans le [handoff canonique](investigations/ecarts-jmeter-migrations/HANDOFF.md) et le [plan de correction](investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md).

## Principaux `UNKNOWN` ou décisions manquantes

Prochaine démarche : revue du brouillon selon le point de pause du handoff et le [protocole legacy/JMeter](documentation/guides/PROTOCOLE_INVESTIGATION_ECARTS_LEGACY_JMETER.md), déjà appliqué jusqu'aux validations locales et à la préparation du rejeu. Ne pas recommencer ces validations sans nouveau motif.

Précautions ajoutées le 2026-09-06 à la demande utilisateur : NuGet d'essai exclusivement en artefacts de pipeline, aucun push vers un feed partagé ; Docker local ou en artefact de préférence, publication éventuelle sous une identité dédiée après validation de sa destination. La section 0 du protocole couvre aussi triggers aval, ressources partagées, données et nettoyage ciblé. Ces règles sont documentées, leur application sur un run n'a pas encore été vérifiée.

- package/version/hash effectivement publiés et consommés par Console, migration et image JMeter ;
- contenu exact du NuGet dans l'image Docker finale, faute d'inspection directe ;
- comparabilité complète de plusieurs résultats legacy et JMeter ;
- mécanisme propriétaire de transport/montage des fixtures d'images Clienteling ;
- décision de support de certaines piles/branches et propriétaire exact de certains correctifs d'autorisation ;
- état courant des ressources Azure DevOps depuis les dernières vérifications datées ; l'authentification
  CLI/profil local et la lecture navigateur ont échoué dans la reprise du 2026-09-08.

Ne pas convertir ces points en actions de correction sans preuve nouvelle ou décision explicite.
