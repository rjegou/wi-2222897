# Dépannage de la migration et des campagnes JMeter

## Objet et règle de preuve

Ce guide réorganise les erreurs et contrôles décrits dans `jmeterTroubleshooting.pdf` et dans la procédure générale. Une différence de résultat ne devient un écart de migration que lorsque le cas, les données, les packages, la configuration et l'environnement sont comparables.

## Diagnostic rapide

| Symptôme | Vérification | Action ciblée |
|---|---|---|
| `SqlExpectedValue` inattendu | La requête commence-t-elle par `SELECT` et renvoie-t-elle bien un compteur ? | supprimer une balise sans requête correspondante ou corriger la valeur attendue |
| erreur de syntaxe SQL sur une chaîne | Quote simple ou double quote ? Format d'origine de la chaîne ? | utiliser les quotes SQL attendues et corriger la regex à la source |
| date valide en local mais rejetée dans le pipeline | Format dépendant de la locale, par exemple `12/21/2099` | utiliser ISO 8601 : `yyyy-MM-dd` ou `yyyy-MM-ddTHH:mm:ss` |
| payload XML rejeté | Déclaration XML et namespaces présents | retirer la déclaration `<?xml ...?>` si le consommateur l'interdit ; déclarer les namespaces réellement utilisés |
| diff XML vide ou incorrect | XPath par défaut inadapté à la réponse | inspecter la réponse et ajuster l'XPath du corps métier |
| local vert, pipeline rouge | dépendances, données ou locale différentes | rendre le JMX autonome et comparer versions, backup, paramètres et réponses |
| déploiement JMeter en échec | packages, tenant, backup, rôles et app settings | corriger le `cy2px`, pas le plan de test |
| HTTP 500 sur un cas EC/NC | sémantique du cas et réponse SOAP réelle | vérifier l'attente explicite ; ne pas introduire de règle globale de skip |
| total de tests publiés en baisse alors que la tâche d'exécution est verte | grouper les tests manquants par préfixe de plan : un groupe entier disparu signale un plan non chargé | chercher `Problem loading XML` / `NonGUIDriver` dans le log du plan concerné, pas dans les résultats |
| `IllegalArgumentException: Problem loading XML` avec `… cannot be cast to org.apache.jorphan.collections.HashTree` | alternance élément JMeter / `<hashTree>` rompue autour de l'élément et de la ligne cités | comparer les **octets** du JMX avec la version qui se chargeait, autour de la ligne signalée ; corriger chez le producteur du fichier, pas à la main |

## 1. Contrôles avant migration

### `SqlExpectedValue`

Le document signale des balises `SqlExpectedValue` présentes sans requête SQL `SELECT` correspondante. Dans ce cas, la balise n'a pas de résultat à contrôler et doit être supprimée ou rattachée à la bonne requête.

Exemple de forme cohérente :

```xml
<SqlExpectedValue>select count(distinct et_pays) from etabliss</SqlExpectedValue>
```

Ne pas automatiser une suppression globale sans vérifier la structure du plan.

### Chaînes et dates SQL

- Une chaîne SQL doit généralement être entourée de quotes simples, pas de doubles quotes.
- Toute correction automatique doit partir du format exact de la source et être testée sur des exemples représentatifs.
- Pour rendre les requêtes indépendantes de la locale, utiliser ISO 8601 :

  ```text
  1994-06-18
  2024-06-27T16:00:00
  ```

Ces contrôles sont particulièrement importants au regard du défaut de conversion de dates déjà prouvé dans l'investigation du WI.

### Payload XML

- Si la première ligne contient `<?xml version="1.0" encoding="utf-8"?>` et que le service attend seulement le fragment XML, la retirer.
- Déclarer les namespaces utilisés par le payload. Le PDF montre notamment des déclarations de type `xmlns:i`, `xmlns:w3.org/2001/XMLSchema-instance` et un namespace métier.
- Valider le fragment obtenu avec le contrat du service ; ne pas recopier une déclaration de namespace sans connaître le préfixe réellement utilisé.

## 2. Corriger après génération

### Comparer local et pipeline

Un test peut réussir localement et échouer dans le pipeline si le serveur local fournit implicitement des dépendances absentes du conteneur. Le plan JMeter et son déploiement doivent donc être autonomes.

Comparer au minimum :

- commit et branche ;
- version du convertisseur et du workflow ;
- packages Fix/Cur ;
- backup et état initial de la base ;
- tenant, rôles et `CustomAppSettings` ;
- paramètres de campagne ;
- locale, fuseau, formats de date et protocole ;
- réponse SOAP/XML complète et assertion réellement évaluée.

Si la réponse est un XML complet, une simple différence de fichier peut être trop bruitée : comparer les données métier attendues élément par élément.

### Dates dépendantes de la locale

Le PDF illustre une date `12/21/2099` acceptée localement mais rejetée dans le pipeline par SQL Server (`conversion of a varchar data type to a datetime data type resulted in an out-of-range value`). La correction consiste à utiliser un format ISO non ambigu, pas à changer la locale du test sans autre analyse.

### XPath sur une réponse XML complète

Lors de la préparation d'un plan avec l'option « Diff Full Xml », le XPath par défaut peut viser un chemin de type `Body/<service>/Response` alors que le service renvoie une structure différente. Il faut :

1. conserver la réponse complète ;
2. identifier l'élément métier stable ;
3. ajuster le XPath au namespace et à la structure réels ;
4. rejouer le seul cas concerné avant de généraliser.

## 3. Lire les résultats sans surinterpréter

### Vérifier la couverture avant de comparer Cur et Fix

Un plan peut être présent dans Git, sélectionné, lancé, et malgré tout ne produire aucun résultat :
le runner poursuit avec le plan suivant après un échec de chargement, ce qui laisse
`Run Jmeter Tests Campaign` en `succeeded`. Deux campagnes peuvent alors afficher des compteurs
d'échecs strictement identiques tout en ayant perdu la même campagne entière — c'est exactement ce
qu'a produit le run InventoryTracking `4445575`
([finding 015](../../investigations/ecarts-jmeter-migrations/findings/015-inventorytracking-002-device-reassign-jmx-load-4445575.md)).

Ordre d'analyse à respecter :

1. total attendu, repris d'une exécution de référence identifiée ;
2. total réellement publié ;
3. périmètre commun, par **identité de test** et non par nombre ;
4. seulement ensuite, comparaison Cur / Fix.

Distinguer quatre états, jamais confondus : absent du dépôt, non sélectionné, non lancé, lancé mais
non chargé. Surveiller aussi les plans annoncés contre les plans réellement chargés, les erreurs
`NonGUIDriver`, et toute variation brutale de couverture. Côté Azure DevOps, les cas non passés
remontent en `unanalyzedTests` : ne pas lire uniquement `failedTests`, et ne pas confondre le
`succeededWithIssues` d'un `PublishTestResults` (« one or more test failures detected ») avec une
panne de publication.

### Familles d'erreurs

La procédure générale classe les erreurs en deux familles :

- **déploiement** : packages, versions, tenant, rôles, configuration et backup ;
- **campagne** : opération, assertion, payload, XPath ou donnée attendue.

Les règles historiques EC/NC mentionnent :

- EC : réponse SOAP en erreur avec un statut attendu de type 500 ;
- NC : réponse SOAP métier avec un résultat attendu de type 200 ;
- un autre préfixe peut être traité comme NC ;
- `Fix` peut apparaître dans certains identifiants de test sans désigner le mode de déploiement Fix.

Ces conventions doivent être vérifiées dans la source du plan et le générateur courant. Elles ne permettent pas d'ignorer globalement un test, un code ou un préfixe.

## 4. Boucle de correction

1. Identifier le premier échec causal, pas seulement les erreurs en cascade.
2. Rejouer le JMX concerné localement avec le même backup et les mêmes packages.
3. Inspecter les requêtes, réponses, assertions et nettoyages.
4. Corriger au niveau propriétaire de la cause : `cy2px`, données, XML legacy, règle de conversion ou code métier.
5. Régénérer les JMX si la source ou le convertisseur change.
6. Rejouer sur une base propre.
7. Archiver les logs et noter le commit, le build, la campagne, le type Fix/Cur et la version Y2.
8. Si le défaut appartient à l'outil de migration, créer un bug distinct et conserver le cas minimal reproductible.

## 5. Ne pas corriger sans preuve

- Ne pas conclure « legacy vert » à partir d'un run qui ne contient pas la même campagne.
- Ne pas accepter une erreur SQL uniquement parce que `ExpectedValue=-1` apparaît dans le test.
- Ne pas ignorer globalement les cas `Code=99`.
- Ne pas modifier manuellement un JMX comme correction durable d'un défaut du générateur.
- Ne pas attribuer un échec à JMeter si les versions, le backup ou les paramètres diffèrent.
- Ne pas conclure à l'égalité de deux gros fichiers depuis un champ d'API ambigu : télécharger les
  octets, comparer la taille, puis le SHA-256. Une comparaison par le champ JSON `content` de l'API
  Git a déjà produit un faux « fichiers identiques » sur un JMX de 4 Mo qui différait de 1 230 octets.
- Ne pas comparer des plans par leur nom de fichier complet : les préfixes numériques diffèrent entre
  un jeu régénéré et une branche (`001-Export_Run.jmx` contre `010-Export_Run.jmx`). Mapper par nom
  fonctionnel après retrait du préfixe `^\d+-`, exiger exactement une correspondance de chaque côté et
  refuser l'écriture si le mapping est ambigu.

Les cas déjà analysés sont classés avec leurs preuves dans [`../../investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md`](../../investigations/ecarts-jmeter-migrations/cases/STATUS_MATRIX.md).

## 6. Leçons opérationnelles rapportées (audit BW3 et FrenchTaxesRules V26, 2026-09-09)

Ces points viennent de deux documents reçus dans `Downloads`, rangés sans modification dans
[`evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/`](../../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/README.md)
et détaillés dans le [finding 018](../../investigations/ecarts-jmeter-migrations/findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md).
Statut : `rapporté, non revérifié` — utile comme méthode même sans revérification indépendante des
chiffres cités.

### Comparaison de campagnes

- **Un écart de volume ne se résume jamais à un chiffre.** `1991 -> 1905` doit devenir une liste
  nominative regroupée par plan, pas « 86 tests manquants ». C'est ce regroupement qui a révélé que
  les 86 absences de `002-Device:Reassign` étaient un seul plan non chargé, pas un bruit diffus.
- **Comparer des identités métier (`plugin | variante | plan | cas`), jamais des `runId`/`resultId`/
  `attempt`.** Ces derniers restent utiles comme provenance, mais deux exécutions du même test
  deviennent artificiellement incomparables si l'identité les inclut.
- **Vérifier la pagination de chaque endpoint REST séparément.** Un endpoint Azure DevOps peut
  renvoyer un résultat partiel tout en semblant valide ; l'exhaustivité doit être démontrée par
  endpoint, pas supposée parce qu'un autre endpoint était complet.
- **Chercher les deltas dans les deux sens.** Absents, ajoutés, changements de statut, changements de
  message, retries/doublons — un build peut présenter à la fois des absences et des changements de
  statut sur les cas restants (7 changements en plus des 86 absences sur `4445575`).
- **Un hash source ne prouve pas les octets consommés au runtime.** Le SHA-256 d'un JMX à une
  `sourceVersion` prouve le contenu Git ; un message de chargement prouve qu'un plan nommé a été
  tenté, mais aucun des deux ne prouve seul que ce sont ces octets qui ont été exécutés. Rester en
  `UNKNOWN` quand cette preuve manque plutôt que de l'inférer.
- **Ne jamais attribuer une preuve au mauvais build.** Un manifeste produit par une génération
  distincte (ex. build `4445025`) ne doit pas servir de preuve du contenu exécuté par un autre build
  (ex. `4432510`) : toujours consigner BuildId, commit/`sourceVersion`, provenance du fichier et date.

### Distinguer build/déploiement, campagne et verdict métier

- **Un build sans JMeter n'est pas un échec fonctionnel.** Quand JMeter est `skipped` ou n'est jamais
  atteint (échec avant restore, avant déploiement), la conclusion correcte est « aucune preuve de
  succès métier ni de régression métier », jamais « les tests ont échoué ».
- **Séparer systématiquement trois questions** : les campagnes se sont-elles réellement exécutées ?
  la couverture attendue est-elle présente ? les tests métier sont-ils tous verts ? Un statut
  `partiallySucceeded` ne répond à aucune des trois à lui seul.
- **Cur et Fix identiques sur les mêmes échecs orientent le diagnostic vers une cause commune**
  (scénario, données, environnement, produit), pas vers le packaging Fix seul. À l'inverse, un Cur
  vert et un Fix rouge oriente vers la pile/packaging Fix en priorité.
- **Vérifier explicitement les cas discriminants historiques**, même quand le total d'échecs a changé :
  leur absence de la liste des échecs est un signal de validation plus fort qu'un simple comptage
  global.

### Incidents CI et artefacts

- **Ne pas transformer trop vite un incident transitoire en bug de pipeline.** Si un rejeu strictement
  identique (même agent, même compte, même package) réussit ensuite, privilégier l'hypothèse d'un
  incident filesystem transitoire plutôt que de modifier le code ou le template sans preuve de cause
  (ex. ne pas remplacer `Move-Item` par `Copy-Item` sans preuve).
- **Ajouter un diagnostic minimal juste avant la commande fautive**, pas une instrumentation large :
  une hypothèse précise, une observation, puis décision.
- **Vérifier les noms réels produits par le build avant de corriger un contrôle d'artifact.** Un
  contrôle qui attend un nom supposé peut échouer alors que l'artifact réel, cohérent avec le kit
  déclaré, porte un nom légèrement différent.
- **Distinguer artifact de build complet et sous-ensemble nécessaire au scénario.** Le bon contrôle
  est « les fichiers requis sont présents exactement une fois », pas « l'artifact ne contient que ces
  fichiers ».
- **Le contenu physique transmis à un déploiement piloté par manifest doit correspondre exactement au
  manifest.** Si l'outil de déploiement valide par manifest, ne pas lui transmettre un dossier
  contenant d'autres fichiers : construire un sous-dossier dédié contenant uniquement les fichiers
  attendus, tout en conservant la provenance (BuildId source, nom d'artifact, version, hashes) à côté.
- **Préférer une correction locale et réversible dans le dépôt consommateur** à une modification d'un
  template partagé, tant que la cause n'est pas générale et démontrée.
- **Après un remplacement manuel de YAML dans Azure DevOps, vérifier l'indentation et les parents**,
  pas seulement le contenu modifié : un remplacement peut casser silencieusement la structure
  `jobs → job → steps` autour d'un bloc pourtant correct.
- **Dès qu'un incident transitoire n'empêche plus l'objectif principal, revenir au chemin critique** :
  ne pas prolonger le diagnostic d'un incident déjà suffisamment expliqué au détriment de l'obtention
  des campagnes réelles.

## 7. Leçons opérationnelles rapportées (Clienteling V26, GenerateJmx, 2026-09-09)

Ces points viennent d'un document reçu dans `Downloads`, rangé sans modification dans
[`evidence/local-2026-09-09-clienteling-v26-generatejmx-testcampaign/`](../../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-clienteling-v26-generatejmx-testcampaign/README.md)
et détaillé dans le [finding 019](../../investigations/ecarts-jmeter-migrations/findings/019-clienteling-v26-generatejmx-testcampaign-outputfiles.md).
Statut : `rapporté, non revérifié` — utile comme méthode même sans revérification indépendante des
identifiants cités.

- **Un pipeline isolé n'hérite pas implicitement du contexte du pipeline historique.** Des variables
  comme `Product.Version` ou `BuildPlatform` peuvent manquer silencieusement et produire des erreurs
  qui ressemblent à des défauts de code (`Version Assemblies`, `solution configuration "Release|$(BuildPlatform)"
  invalid`) alors qu'elles viennent uniquement du contexte de pipeline. Comparer explicitement les
  variables du pipeline isolé à celles du pipeline d'origine avant de diagnostiquer plus loin.
- **`--tstj` de la Console attend un `TestCampaign`, jamais un `TestPlan` brut.** Lui fournir un
  `TestPlan` produit une erreur de désérialisation XML (`<TestPlan ...> was not expected`) qui peut
  se lire comme un défaut du plan alors que le plan est valide : seul le wrapper fourni à la Console
  est fautif. Un XML techniquement valide ne respecte pas forcément le contrat métier attendu par
  l'outil qui le consomme.
- **Un plan de test n'est pas autonome : la génération JMX peut dépendre de `InputFiles`/`ExpectedOutput`
  référencés.** Un manifeste de migration qui ne copie que le XML racine du plan peut produire un
  artefact incomplet (`DirectoryNotFoundException` sur `OutputFiles`) même quand le dépôt source
  contient bien toutes les ressources. Le manifeste doit représenter la dépendance fonctionnelle du
  plan, pas seulement son fichier racine — et ne copier que ce qui est réellement référencé
  (`TestCase/@Input`, `ExpectedOutput`), pas un répertoire entier, pour ne pas gonfler l'artefact.
- **Suivre la profondeur maximale atteinte dans le pipeline, pas seulement `Result=failed`.** Une
  séquence d'échecs de plus en plus loin (`Version Assemblies` → `VSBuild` → `OutputFiles` manquants →
  `TestPlan` au lieu de `TestCampaign`) confirme à chaque étape que la couche précédente est franchie ;
  c'est un signal de progrès, pas seulement une liste d'échecs indépendants.
- **Chercher une preuve d'exécution réelle avant de reconstruire une convention par hypothèse.** La
  structure `TestCampaign` correcte a été retrouvée dans un artefact local d'une génération JMX déjà
  réussie plutôt que déduite du nom de l'option `--tstj`.
- **Séparer strictement la définition de replay isolée de la définition CI normale du même plugin**
  (ici `14264` contre `2065` pour Clienteling). Un incident observé dans l'une ne doit pas être corrigé
  au titre de l'autre sans preuve qu'il est réellement partagé.

## 8. Leçons opérationnelles rapportées (attestation de campagne round 4, 2026-09-09)

Ces points viennent d'un collecteur et de ses rapports copiés sans modification dans
[`evidence/local-2026-09-09-attestation-campagne-round4/`](../../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-attestation-campagne-round4/README.md)
et détaillés dans le [finding 020](../../investigations/ecarts-jmeter-migrations/findings/020-attestation-campagne-round4-transport-local-candidat.md).
Statut : `rapporté, non revérifié` par ce processus — utile comme méthode même sans revérification
indépendante des chiffres cités.

- **Un grep de ligne de log (`Remove-Item`, `docker rm`) n'est pas un résultat de tâche.** Une ligne de
  commande de nettoyage dans un log de préparation ne prouve ni son exécution ni sa réussite ; seul le
  résultat d'une tâche identifiée (ex. `Stop Containers` = `succeeded` dans la timeline du build) est
  une preuve de cleanup. Les deux signaux ne se contredisent pas : ils répondent à des questions
  différentes, et l'absence du second ne doit pas être présentée comme une régression du premier quand
  il existe déjà pour un build donné.
- **Un même nombre dans deux systèmes différents peut être une coïncidence, pas une preuve.** Le
  compteur « 32 » du validateur JMX de FrenchTaxesRules (un dépôt) et le compte « 32 blobs JMX » de
  l'inventaire Git InventoryTracking (un autre dépôt) sont sans rapport malgré la valeur identique.
  Toujours qualifier un compteur par son système d'origine avant de le comparer.
- **Une whitelist stricte de builds, opposable avant tout appel réseau, est un garde-fou réutilisable**
  pour tout script de collecte : refuser explicitement un identifiant hors périmètre (ici le build
  `2054`, hors champ de ce collecteur) avant la première requête évite qu'une erreur de paramètre
  élargisse silencieusement la portée d'une lecture même en lecture seule.
- **Refuser d'écrire dans un dossier de sortie non vide** évite d'mélanger deux collectes ou d'écraser
  une preuve déjà versionnée — cohérent avec la règle de ce dépôt de toujours créer un nouveau dossier
  de preuve daté plutôt que de réutiliser un dossier existant.
- **La convergence de plusieurs collectes indépendantes renforce la confiance sans remplacer une
  lecture directe.** Quatre comptes Cur/Fix confirmés à l'identique par deux collecteurs différents
  (celui-ci et l'audit BW3 du même jour) sont un signal fort, mais aucun des deux ne constitue à lui
  seul la revérification Azure DevOps indépendante que la règle de fraîcheur exige avant conclusion.

## 9. Leçons opérationnelles rapportées (FrenchTaxesRules V26, run 4452790, 2026-09-09)

Ces points viennent de la [synthèse technique reçue](../../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-frenchtaxesrules-v26-synthese-technique/README.md)
et du [finding 021](../../investigations/ecarts-jmeter-migrations/findings/021-frenchtaxesrules-v26-run-4452790-cy2px.md).
Statut : `rapporté, non revérifié`.

- **Un nom logique de pile n'est pas nécessairement un tag de registry.** Le mapping Docker doit être
  confirmé sur un run fonctionnel et dans le manifest réellement consommé ; ne pas injecter
  automatiquement `win2025sql2025dotnet10` comme tag sans cette preuve.
- **Tester l'idempotence d'un outil de migration.** Une seconde exécution de `Step_04_modifYml.py`
  sur un YAML déjà migré est rapportée comme générant des doublons et du bruit ; distinguer une base
  non migrée d'un patch minimal sur une base déjà transformée.
- **Un blocage `*.cy2px` est antérieur au verdict JMeter.** Même si le job Docker est dépassé,
  l'absence des fichiers attendus par `Configure cy2px files` ne prouve ni l'exécution des 19 JMX ni
  un échec métier ; identifier d'abord leur producteur et leur provenance.

## 10. Leçons opérationnelles rapportées (Clienteling V26, PlatformDeploy/JFrog, 2026-09-09)

Ces points viennent de la [synthèse du replay isolé](../../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-clienteling-v26-replay/README.md)
et du [finding 022](../../investigations/ecarts-jmeter-migrations/findings/022-clienteling-v26-replay-jfrog-download-4452826.md).
Statut : `rapporté, non revérifié`.

- **Reconstituer le contrat runtime, pas seulement le checkout.** La source rapporte que
  PlatformDeploy exigeait dans le job JMeter son outil JFrog construit/publié, son backup dans
  `Docker\Data`, et ses conventions de configuration portable.
- **Tokeniser les valeurs historiques seulement selon le contrat consommateur.** Le host et
  l'instance SQL historiques sont rapportés remplacés par `__CONTAINER_HOST__` après lecture du
  code PlatformDeploy ; cette méthode ne vaut pas preuve de correction sans lecture directe du run.
- **Un diagnostic sécurisé doit extraire des champs bornés.** Le run rapporté `4452826` atteint le
  téléchargement de packages mais le filtre whitelisté reste vide ; ne pas remplacer ce résultat
  par un dump brut potentiellement sensible. Vérifier d'abord le format réel de sortie (`##[error]`,
  package courant ou fichier temporaire) avant tout nouveau patch.
- **La profondeur du pipeline n'est pas un résultat JMeter.** Atteindre `download-packages.ps1`
  réduit le blocage, mais ne prouve ni `GenerateJmx`, ni les stages Cur/Fix, ni un résultat métier.

## Sources PDF

- [`jmeterTroubleshooting.pdf`](../source-material/jmeterTroubleshooting.pdf), 2 pages.
- [`procédureMigration.pdf`](../source-material/procédureMigration.pdf), sections d'analyse, de correction et d'exécution.
