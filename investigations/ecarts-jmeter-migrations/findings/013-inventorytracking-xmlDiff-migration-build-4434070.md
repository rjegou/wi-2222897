# Finding 013 — InventoryTracking migration 4434070 : XmlDiff non résolu

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`, lecture seule.
- Pipeline : définition `2072`, `InventoryTracking CI`.
- Build : `4434070` (`7.73`), branche source `refs/heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master`.
- Commit migration : `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.
- Preuves : cause initiale dans `../evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md`; validation AzDO dans `../evidence/2026-09-08-inventorytracking-azdo-access-diagnosis-round2/README.md`, `MANIFEST.csv` et `SHA256SUMS.txt`; contre-vérification d'accès dans `../evidence/2026-09-08-inventorytracking-azdo-independent/README.md`.

## Conclusion bornée

**FACT** — le build `4434070` n'est pas un run direct de `refs/heads/master`. Il provient de la branche de migration `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, au commit `4de185bb...`; les derniers builds de cette branche (`4434070` et `4432064`) échouent au même commit.

**FACT** — l'image/ACR et `Ensure_Docker_Image_Up_To_Date` réussissent en amont. `Build V26` échoue dans `VSBuild` log 51 : `MSB3245` sur `Cegid.Retail.XmlDiff`, puis quatre `CS0103` sur `XmlDiff` dans `GlobalSettingsDtoConvertersUnitTest.cs`. Les stages `TI JMeter V26`, Cur et Fix sont skipped.

**FACT** — le projet `Cegid.Retail.InventoryTracking.Services.Tests.csproj` conserve une référence `HintPath=..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`, tandis que `Services.Tests/packages.config` ne restaure ni `Cegid.Retail.XmlDiff` ni `XMLDiffPatch`. Le commit de migration supprime `WebServices.Tests` et son `packages.config`, qui contenait ces deux packages. Le master `20aa528...` conserve ce projet; son build `4435986` montre une résolution via `Sln\packages\Cegid.Retail.XmlDiff.1.0.0` pour WebServices.Tests et `Assemblies\Bin\Cegid.Retail.XmlDiff.dll` pour Services.Tests.

**INFERENCE** — la cause immédiate est l'acquisition/résolution manquante de `Cegid.Retail.XmlDiff` après le désenregistrement de l'ancien projet WebServices.Tests. La suppression du projet n'est pas démontrée comme fautive en soi; c'est la dépendance encore requise par Services.Tests qui n'est plus fournie dans le chemin attendu.

**UNKNOWN** — le mécanisme exact de suppression/non-restauration au run (package Core réellement contenu, restore effectif, templates externes et versions consommées) n'est pas entièrement prouvé. Le build `4435986` réussi est l'ancien pipeline master : son YAML ne déclare pas `TI_Jmeter_V26`; il ne valide donc pas la migration JMeter.

## Correctif candidat et test discriminant

Le correctif minimal candidat est de restaurer explicitement `Cegid.Retail.XmlDiff` `1.0.0` et sa dépendance `XMLDiffPatch` dans le projet conservant la référence, ou de remplacer la référence par l'emplacement/package supporté. Le choix reste à valider par le propriétaire et la compatibilité d'assembly.

Test local autorisé : checkout isolé du commit `4de185bb...`, changement minimal de déclaration, `dotNet-build: Build solution **\*.sln`, puis vérification de la résolution et de la disparition des quatre `CS0103`. Aucun code, package, pipeline, branche ou dépôt n'a été modifié dans cette collecte.

## Suite PBI

La correction candidate a maintenant été exercée par les builds `4440774` et `4440884` ci-dessous. L'état fonctionnel reste non validé : le delta `TC 122` est observé dans les résultats publiés, mais sa cause et sa reproductibilité restent `UNKNOWN`. La PR source n'a pas été retrouvée dans la requête datée; cela ne généralise pas à d'autres branches ou PR.

## Complément du 2026-09-08 — validation AzDO des runs InventoryTracking

**FACT** — la collecte REST Python/OpenSSL authentifiée relit la définition `2072`, les builds, timelines, artefacts et résultats individuels. Le build `4440774` (`7.75`) est `completed/succeeded` au commit `ef3d87034d38b88aca04c824061b140e2a29252c` sur `refs/heads/validation/WI-2222897-inventorytracking-xmldiff`; Build réussit et JMeter est skipped.

**FACT** — le build `4440884` (`7.76`) est `completed/partiallySucceeded` au même commit. Build réussit; Cur et Fix sont exécutés avec `1991` résultats chacun : Cur `1652 passed / 339 failed`, Fix `1651 passed / 340 failed`. Les artefacts Cur/Fix et la publication Artifactory staging sont présents dans l'index du build.

**FACT** — la jointure exacte des résultats donne `1991` clés communes, `1651 Pass/Pass`, `339 Fail/Fail`, un seul `Fail/Pass` et aucun `Pass/Fail`. Le seul delta est `002-Device:Reassign - TC 122` (référence `1127761`) : Fix échoue sur `B-XQuery:Internal Server Error`, Cur passe. Les autres différences de texte d'erreur restent des `Failed/Failed`.

**FACT** — la relecture de la ref exacte renvoie zéro résultat au moment de la collecte et la recherche de PR dont la source est cette branche renvoie zéro résultat. Cette absence est bornée à la requête datée et ne prouve ni suppression par un worker ni absence de toute PR historique.

**UNKNOWN** — cause applicative/reproductibilité de `TC 122`, mapping vers le sample JMeter brut, contenu exact des logs/artefacts au-delà des résultats publiés, et état fonctionnel métier. `4440884` ne constitue donc pas une validation fonctionnelle globale.

**FACT d'accès** — Python/OpenSSL fonctionne jusqu'à AzDO; Schannel échoue avec `SEC_E_NO_CREDENTIALS`. L'hypothèse d'un PAT expiré/invalide n'est pas établie. Les disparitions de clone ou verrous ne sont attribués à aucun worker sans preuve directe.

**FACT d'autorisation et prudence** — l'autorisation actuelle couvre les corrections, push, runs et la PR appropriée. La prochaine exécution doit toutefois maîtriser les effets partagés : `Ensure_Docker_Image_Up_To_Date`, publication staging, compteur de version et toute ressource ACR/Artifactory. Aucun nouveau run n'est lancé dans cette mise à jour documentaire.

## Complément du 2026-09-08 — reprise 4444389 et obstacle Docker

**FACT** — la collecte [reprise 4444389](../evidence/build-4444389-inventorytracking-docker-reprise-20260908/README.md) établit un état terminal `completed/canceled`, build `7.77`, sur la branche `validation/WI-2222897-inventorytracking-isolated-20260908`, avec le commit exécuté `13d0db910153952f1827f05f6532fa0f06741124`. La ref relue ensuite pointe vers `efba57ea5a96d346170f4407e37050985244dcee`, tête diagnostique ultérieure; cela ne remplace pas le commit exécuté.

**FACT** — le job JMeter Fix échoue pendant l'initialisation avant création du conteneur : trois appels `docker version` ne trouvent pas `npipe:////./pipe/docker_engine`, puis `ContainerId` est nul. Les erreurs de chemins d'archives/logs sont dérivées.

**FACT** — le job JMeter Cur suit une trajectoire différente : API Docker/client `1.55`, login, pull, création et démarrage du conteneur réussissent; l'annulation survient ensuite à `09:01:44.439Z`, avec étapes de campagne/publication skipped et cleanup du conteneur/réseau réussi.

**UNKNOWN** — la cause de l'annulation globale/Cur et la raison de l'absence du daemon Docker sur l'agent Fix ne sont pas exposées par les preuves; ne pas les qualifier de timeout, d'annulation manuelle ou de problème ACR. Le résultat fonctionnel de TC122 reste également UNKNOWN.

**Correction documentaire** — les formulations antérieures de type « autorisation manquante » sont obsolètes pour cette mission : l'utilisateur autorise corrections, push de branches de travail, pipelines et PR appropriée, sous contrainte d'impact minimal. Cette autorisation ne transforme toutefois pas 4444389 en validation métier et aucun push du dépôt documentaire n'est demandé.

## Complément du 2026-09-08 — source résolue et runs exploratoires 4444700/4444703/4444720

**FACT** — [la comparaison source live](../evidence/build-4444389-inventorytracking-docker-reprise-20260908/source-comparison.md) établit que `ef3d87034d38b88aca04c824061b140e2a29252c` est accessible, enfant direct de `4de185bb132cfbfb50643b6b53d6feb85508f4e2`, et que son diff exact porte sur `Cegid.Retail.InventoryTracking.Services.Tests.csproj` et `Cegid.Retail.InventoryTracking.Services.Tests/packages.config`. La branche migration reste à `4de185bb...`; `master` actuel est `20aa528945ac33ba94598222b66fa3071c7e87b9`.

**FACT** — la collecte [4444720](../evidence/build-4444720-inventorytracking-docker-init/README.md) établit Build et le stage/job de préflight Docker réussis, tandis que Cur et Fix restent à `0%` dans `Initialize containers` sur les agents `Azure Pipelines 29` et `44`; aucun résultat JMeter, conteneur de campagne ou artefact métier n'est produit. Les jobs sont ensuite annulés après plus de quinze minutes pour libérer les agents.

**FACT borné** — `4444700` et `4444703` sont des runs exploratoires annulés avant JMeter parce que le paramètre effectif `pipelineDevMode` était `False`; ils ne constituent pas des campagnes métier. Pour `4444720`, le blocage `Initialize containers` est prouvé, mais la sous-cause exacte du runtime/daemon et la raison détaillée de l'initialisation restent UNKNOWN.

**UNKNOWN** — consommation effective de l'image/package/JMX/données par les jobs conteneurisés 4444720, cause fonctionnelle/reproductibilité de TC122, et existence d'une PR historique. L'absence actuelle d'une PR/ref ne permet pas de nier les commits `4de185bb` ou `ef3d8703`.

## Rectification datée — 4444720 n'est pas une panne Docker démontrée

Voir le [complément daté](../evidence/build-4444720-inventorytracking-review-correction-20260908/README.md), ajouté sans réécrire les preuves antérieures.

**FACT** — 4444720 atteint `Initialize containers`; les logs montrent login Docker et début du pull, mais aucun démarrage/création de conteneur, JTL ou résultat JMeter avant annulation. L'initialisation est donc non achevée pendant un téléchargement actif; aucune panne du daemon n'est démontrée par ce run. Le daemon absent reste un fait distinct et limité au Fix de 4444389.

**FACT borné** — la timeline enregistre l'identité AzDO utilisée pour l'annulation; cette identité ne prouve pas à elle seule une action manuelle de l'utilisateur.

**DECISION supervisée** — un seul rejeu du candidat isolé existant, durée adaptée, suivi jusqu'à l'état terminal, sans réécriture Docker. La PR candidate doit regrouper la migration complète et le seul correctif XmlDiff; les diagnostics TC122 et préflight sont exclus.

## Complément du 2026-09-08 — 4444887 : transport/déploiement bloqué avant JMeter

Voir la [preuve primaire 4444887](../evidence/build-4444887-inventorytracking-container-replay-20260908/README.md), collectée par relecture live Azure DevOps de la définition `2072`, branche `validation/WI-2222897-inventorytracking-isolated-20260908`, commit `efba57ea5a96d346170f4407e37050985244dcee`.

**FACT** — le run `4444887` est terminal `completed/failed`. Build et préflight Docker réussissent; les deux jobs Cur/Fix initialisent leur conteneur avec succès. Les étapes de publication staging, promotion et tag sont skipped par les conditions de la branche isolée.

**FACT** — Cur et Fix échouent ensuite dans `Launch Y2 deployment` : PlatformDeploy `5.0.86` ne trouve pas `Y2.Plugin.InventoryTracking.26.0.7.83` dans `retail-software-staging`. Prepare/Run JMeter, conversion JTL et extraction d'erreurs sont skipped pour les deux variantes.

**INFERENCE bornée** — l'obstacle causal de `4444887` est le transport/déploiement du package attendu vers le staging de cet essai isolé. Il ne constitue pas un échec fonctionnel du plugin, puisque JMeter n'a pas démarré.

**UNKNOWN** — campagne JMeter Cur/Fix, TC122, image/digest consommés, JMX/données/assertions et méthode de transport autorisée au-delà de ce run.

**DÉCISION transport** — résoudre par artefact privilégié strictement isolé, sans réactivation du staging partagé, promotion ou tag. Les recommandations Docker de la revue round3 et du retour worker 2 round4 sont supersédées pour cette décision par 4444887; leurs preuves historiques ne sont pas modifiées.

## Complément du 2026-09-08 — contrat PlatformDeploy et substitution locale expérimentale

Voir le [contrat de transport round5](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-contract-round5/README.md) et la [revue PlatformDeploy de 4444887](../evidence/build-4444887-inventorytracking-platformdeploy-review-20260908/README.md), sans recopier leurs preuves.

**FACT** — le Build a bien publié l'artefact PipelineArtifact isolé `26.0.7.83_Software`, ID `5037140`, taille déclarée `1 705 531` octets. Cela prouve l'existence de l'artefact dans le service PipelineArtifact, pas sa consommation par PlatformDeploy.

**FACT** — le contrat actuel télécharge PlatformDeploy et ses packages via JFrog; `download-packages.ps1` appelle obligatoirement le CLI JFrog sur le packagelist. Aucune entrée locale, PipelineArtifact, URL ou cache local n'est accepté par le contrat observé. L'entrée locale du plugin est donc inexistante pour ce parcours.

**INFERENCE bornée** — la limitation est technique et située dans le transport/contrat de déploiement; elle ne constitue ni un arbitrage fonctionnel ni un défaut métier du plugin.

**DÉCISION supervisée** — implémenter et tester une substitution locale expérimentale du seul plugin via PipelineArtifact, sans staging partagé. Le test devra prouver version/hash, chemin consommé, déploiement, puis seulement JMeter Cur/Fix; aucun résultat TC122 n'est inféré avant ces postconditions.

## Complément du 2026-09-08 — artefact inspecté, contrat ArtifactItem et verrous distincts

Voir la [revue transport round6](../evidence/build-5037140-inventorytracking-transport-review-20260908/README.md) et l'[inventaire de l'artefact 5037140](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-pipelineartifact-5037140-round6/README.md), sans recopier leurs preuves.

**FACT** — l'artefact `26.0.7.83_Software` (`5037140`) contient exactement quatre fichiers : deux MSI et deux XML. Les quatre chemins et SHA-256 sont relevés dans l'inventaire round6; les XML déclarent les identifiants produit et la version `26.0.7.83`.

**FACT** — au commit PlatformDeploy `93f91487ee717185599555a42df3cb5d024ace89`, le modèle `PackageDownloaderService` sérialise des `ArtifactItem` `uri`, `filename`, `name`, `version`; le contrat d'installation attend les packages sous leur nom. L'implémentation de la substitution locale n'est pas présente dans les dossiers inspectés.

**FACT borné** — le verrou actif du clone PlatformDeploy et la restriction lecture seule du `.git` documentaire sont deux contraintes distinctes. Aucun des deux ne prouve qu'une préparation locale est impossible dans un dossier inscriptible.

**DÉCISION** — préparer indépendamment le patch et ses tests inertes, puis envisager une publication REST sur branche dédiée après revue. Ne pas toucher aux verrous, ne pas pousser GitHub et ne pas lancer d'acte distant dans cette consolidation.

## Complément du 2026-09-08 — candidat round7 implémenté, revue indépendante attendue

Voir le [candidat transport round7](../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-inventorytracking-transport-candidate-round7/README.md) et les [tests indépendants du contrat](../evidence/local-2026-09-08-inventorytracking-transport-tests-round7/README.md), sans recopier ni modifier leurs preuves.

**FACT** — le candidat est présent dans `.work/transport-round7/` : helpers de préparation locale, retrait limité du seul plugin du `.cy2px`, ajout des paramètres opt-in, propagation des paramètres et YAML d'essai. Les paramètres vides conservent le chemin normal.

**FACT rapporté par l'opérateur** — les tests locaux du candidat sont annoncés PASS : chemin normal, cas positif, version/hash erronés, doublon, manifeste manquant, garde-fous statiques et parsing PowerShell. Les hashes du candidat sont conservés dans la preuve round7.

**DISTINCTION** — les tests du lot `local-2026-09-08-inventorytracking-transport-tests-round7` sont des tests indépendants du contrat sur fixtures; les tests du candidat round7 couvrent les scripts/YAML locaux. Aucun n'est une exécution du helper dans un conteneur PlatformDeploy réel, et aucune revue indépendante des hashes n'est encore acquise.

**UNKNOWN** — revue indépendante du candidat, commits opérateur, run Azure DevOps, consommation dans Cur/Fix et résultat JMeter. Attendre ces éléments avant tout changement d'état runtime ou de PR.

## Complément du 2026-09-08 — revues round8 : mécanisme favorable, provenance à corriger

Voir les [deux revues round8](../evidence/build-5037140-inventorytracking-transport-review-round8/README.md) et [revue du patch](../evidence/local-2026-09-08-inventorytracking-transport-review-round8/README.md), sans modifier leurs preuves.

**FACT** — les tests locaux du transport passent : chemin normal, cas positif, version/hash erronés, doublon, fichier inattendu et manifeste manquant; la revue du mécanisme est favorable sous réserve. Le mode opt-in conserve le chemin JFrog normal pour les dépendances et exclut la publication staging partagée.

**FACT** — la revue identifie un défaut ciblé de provenance : le YAML produit actuellement `artifactId = $(Build.BuildId)`, alors que l'artefact de référence est nommé `$(componentVersion)_Software`. Cette valeur de BuildId est une provenance du Build source, pas l'identité ressource de l'artefact consommé.

**DÉCISION** — corriger avant queue en enregistrant explicitement `sourceBuildId` et `artifactName`, et en vérifiant dans chaque job les hashes des quatre fichiers effectivement transportés : `E_IIS_SERVER_RETAIL_INVENTORYTRACKING.MSI` (`3698C2BF67A61132B1AD878386AFF36C0F6845D31246031ACF767145D3115736`), XML IIS (`AE9A5D4A5A118117E957B65FD2010F00A0EE93616640B4271B6B63B34A57D0EB`), `TASKSCHEDULER_RETAIL_INVENTORYTRACKING.MSI` (`5A2084B4368E89346529290FD4FB87DE1AB0558C2BF514FB44369B80C906B308`) et XML TaskScheduler (`A62A31EB4B733F7BA255194070919014AEC37718B386EFF1DC9D58B97F2A2EE1`). Aucun hash d'archive n'est exigé arbitrairement; la preuve porte sur les fichiers extraits et réellement transportés.

**UNKNOWN** — correction/revue des fichiers, commits opérateur, run Azure DevOps et exécution PlatformDeploy/Cur/Fix. Aucun résultat JMeter ou TC122 nouveau n'est acquis.

## Complément du 2026-09-07 — deux handoffs manuels externes, runs ADO réels revendiqués (supersédé)

Deux documents manuels reçus hors processus sont conservés sous [`evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`](../evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/README.md). Leurs affirmations de runs sont désormais supersédées par la collecte datée du 2026-09-08 ci-dessus; ils restent utiles pour la provenance du correctif candidat.

- **FACT rapporté** — un correctif appliqué sur une branche distante `validation/WI-2222897-inventorytracking-xmldiff` (commit `ef3d87034d38b88aca04c824061b140e2a29252c`), ajoutant explicitement `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28` au `.csproj`/`packages.config` de `Services.Tests` — cohérent avec le correctif candidat déjà proposé ci-dessus.

## Complément du 2026-09-08 — run 4445575 : transport franchi, couverture perdue

Le transport local a été exercé jusqu'aux campagnes dans le run `4445575`, commit
`95aede774dcc45ba7e69abe163e6be410ae0c496`. La conclusion atomique et ses chiffres sont dans
[finding 015](015-inventorytracking-002-device-reassign-jmx-load-4445575.md) ; niveau de preuve
rapporté, non revérifié.

**FACT rapporté** — Build, préflight Docker et JMeter Cur/Fix sont réellement exécutés : l'obstacle de
transport du run `4444887` est levé pour ce parcours. Cur `6188849` et Fix `6188843` publient `1905`
tests chacun, `314` non passés strictement identiques des deux côtés.

**FACT rapporté** — la couverture chute de `1991` à `1905` par rapport à `4440884` ; les `86` tests
manquants sont tous ceux du plan `002-Device:Reassign`, qui échoue au chargement JMeter
(`HeaderManager cannot be cast to HashTree`, ligne 8522). `TC122`, seul delta Cur/Fix de la baseline,
fait partie des tests absents.

**Conséquence sur ce finding** — l'absence de `TC122` dans `4445575` **ne clôt pas** l'`UNKNOWN` sur
`TC122` : la campagne entière n'a produit aucun résultat. Le correctif XmlDiff reste la cause prouvée
du build initial ; le statut fonctionnel de la migration et la décision de PR restent non acquis.

**UNKNOWN ajouté** — le fallback de transport embarqué sous `/.pipeline/inventorytracking-transport/`
est un mécanisme d'investigation. Il ne doit pas entrer tel quel dans la PR finale sans revue.
