# WI-2222897 — Synthèse technique du run BW3

## Objectif du run

Le run BW3 avait pour objectif de finaliser le validateur de comparaison et de consolider une collecte **LIVE Azure DevOps** des campagnes JMeter, en particulier pour **InventoryTracking**, puis d'établir l'état réel de **FrenchTaxesRules** et **Clienteling** sans modifier les systèmes distants.

Le périmètre était strictement en **lecture seule** côté Azure DevOps et autres systèmes distants. Les seules écritures autorisées concernaient les outils, rapports et preuves dans l'espace privé du run.

---

## Travail réalisé

### 1. Finalisation du validateur de comparaison

Le validateur existant a été repris et complété sans être reconstruit.

Les points suivants ont été fiabilisés :

- pagination indépendante pour chaque endpoint REST ;
- collecte exhaustive des Test Runs et résultats ;
- identité logique des tests basée sur `plugin | variante | plan | cas` ;
- conservation correcte des noms contenant `:` comme `Device:Reassign` ;
- conservation de `attempt`, `runId` et `resultId` comme provenance sans les intégrer à l'identité fonctionnelle du test ;
- détection des collisions, doublons et retries ;
- distinction entre plans annoncés, publiés, chargés et réellement exécutés ;
- détection des erreurs `NonGUIDriver` ;
- gestion explicite de `UNKNOWN` lorsqu'une preuve directe est absente ;
- tests bornés dédiés aux cas de pagination, collision/retry et plan absent.

Les tests de validation du collecteur et du comparateur sont passés.

---

## 2. Collecte LIVE InventoryTracking

Les builds et Test Runs suivants ont été collectés directement via Azure DevOps :

- builds `4447425`, `4440884`, `4445575` ;
- Test Runs `6189957`, `6189960`, `6185924`, `6185925`, `6188843`, `6188849`.

La pagination a été vérifiée et la collecte complète des six runs obtenue.

### Résultats principaux

Les quatre premiers runs contiennent chacun **1 991 résultats**.

Les deux runs du build `4445575` contiennent chacun **1 905 résultats**.

Le delta est donc de **86 tests absents par variante**.

Ces 86 absences ont été identifiées **nominativement** et sont toutes rattachées au plan :

`002-Device:Reassign`

En plus de ces absences, **7 changements de résultats par variante** ont été identifiés et exportés nominativement avec les statuts/messages avant-après.

Le cas `TC122` a été rendu explicite dans le rapport :

- sur la campagne comparable : `Fix = Failed`, `Cur = Passed` ;
- sur `4445575` : le cas est absent avec les autres tests de `Device:Reassign`.

Quatre erreurs `NonGUIDriver` ont également été confirmées dans les logs.

---

## 3. Inventaire et hash des JMX InventoryTracking

Le run a reconstruit l'inventaire des JMX aux trois `sourceVersion` étudiées.

Résultat :

- **32 chemins JMX** attendus ;
- **96 blobs analysés** au total sur les trois sourceVersions ;
- **31 JMX identiques** entre les versions ;
- `Device_Reassign` est le JMX qui diffère ;
- chaque contenu source a été hashé en SHA-256.

Point important : le rapport distingue désormais clairement :

- le **hash Git du fichier source** ;
- la preuve que le runner a tenté de charger un plan ;
- la preuve éventuelle que les **octets runtime** sont effectivement identiques au fichier Git.

Un log de chargement prouve qu'un plan nommé a été tenté ou rejeté, mais **ne prouve pas à lui seul l'identité des octets consommés à l'exécution**.

Lorsque cette preuve n'existe pas, le verdict reste `UNKNOWN`.

---

## 4. FrenchTaxesRules

Le build cible :

`4447926`  
commit : `61d7f16e34d4ee0537e3e32b1c8a883db5006c9b`

a été revérifié directement.

Résultat :

- build terminal : **failed** ;
- échec avant JMeter sur `restore-externals` ;
- erreur ciblée : `Move-Item Access denied` ;
- stages Cur/Fix JMeter non exécutés ;
- **0 Test Run métier attribuable au build** ;
- **0 artefact JMeter exploitable**.

La baseline `4432510` contient, elle, des résultats métier historiques :

- environ **253 tests par variante** ;
- 19 plans JMX de référence.

Le run BW3 a corrigé une confusion de provenance : le manifeste de génération des 19 JMX provenait d'un autre build (`4445025`) et ne devait pas être présenté comme une preuve directe du contenu exécuté par `4432510`.

Conclusion correcte :

**FrenchTaxesRules ne peut pas être validé fonctionnellement sur le build cible puisque les tests JMeter n'ont pas été exécutés.**

Cela ne démontre ni une régression métier ni un succès métier.

---

## 5. Clienteling

Les builds étudiés ont également été revérifiés.

Pour `4447427` et `4447443` :

- aucun Test Run métier exploitable ;
- JMeter non exécuté ;
- sur `4447443`, le rapport distingue désormais correctement :
  - les étapes `VerifyInputs / Preflight` en échec ;
  - les étapes de génération/JMeter ensuite `skipped`.

La baseline `4432554` a été utilisée comme référence historique.

Une inversion Cur/Fix dans le rapport initial a été corrigée :

- `6180736 = Fix` ;
- `6180750 = Cur`.

Conclusion correcte :

**les builds Clienteling examinés ne permettent pas de valider la migration fonctionnellement, faute d'exécution JMeter effective.**

---

## 6. Livrables produits

Livrable principal :

`C:\clones\wi-2222897-bw\relais-20260909-01\validation\RESULT.md`

Autres preuves principales :

- `PROGRESS.md`
- `evidence/inventory-live/collector-report.json`
- `evidence/inventory-live/jmx-inventory.json`
- `evidence/inventory-live/residual-deltas.json`
- `evidence/campaign-comparison/build-state.json`
- `evidence/campaign-comparison/ftr-baseline-jmx-scope.tsv`
- manifestes SHA-256 des preuves.

En fin de run :

- **10 entrées de manifeste vérifiées** ;
- **0 erreur de hash ou de fichier manquant**.

Aucune mutation distante n'a été effectuée.

---

# Leçons utiles apprises

## 1. Un nombre de résultats différent ne suffit jamais

Un écart comme `1991 -> 1905` ne doit pas être résumé par « 86 tests manquants ».

Il faut produire la **liste nominative** et déterminer leur regroupement.

Ici, les 86 cas absents sont tous concentrés dans `002-Device:Reassign`, ce qui transforme un simple écart quantitatif en signal technique exploitable.

---

## 2. Comparer les identités métier, pas les IDs d'exécution

Les `runId`, `resultId` et `attempt` sont indispensables pour la traçabilité, mais ne doivent pas faire partie de l'identité fonctionnelle d'un cas.

La bonne séparation est :

- identité fonctionnelle : plugin / variante / plan / cas ;
- provenance : build / runId / resultId / attempt.

Sinon, deux exécutions du même test deviennent artificiellement incomparables.

---

## 3. Toujours vérifier la pagination REST

Un endpoint Azure DevOps peut retourner un résultat partiel tout en semblant valide.

Une comparaison de campagnes n'est fiable que si chaque endpoint a sa propre logique de pagination et si l'exhaustivité est démontrée.

La récupération LIVE des six runs a notamment nécessité plusieurs pages.

---

## 4. Un stage vert ou un runner lancé ne prouve pas la couverture

Il faut distinguer :

- plan annoncé ;
- plan généré ;
- plan publié ;
- plan chargé ;
- test effectivement exécuté.

Un runner peut être vert alors qu'un plan n'a jamais été chargé.

Inversement, un plan sans testcase attendu ne doit pas être artificiellement déclaré manquant.

---

## 5. Un build sans JMeter n'est pas un échec fonctionnel

FrenchTaxesRules `4447926` échoue avant JMeter.

Clienteling présente également des builds où JMeter est skipped.

Dans ces situations, la conclusion correcte est :

**« aucune preuve de succès métier ni de régression métier »**

et non :

**« les tests ont échoué »**.

---

## 6. Hash source et consommation runtime sont deux preuves différentes

Le SHA-256 d'un JMX récupéré à une `sourceVersion` prouve exactement le contenu du fichier Git.

Il ne prouve pas automatiquement que ce sont ces mêmes octets qui ont été consommés par le runtime.

Même un message de chargement du fichier ne suffit pas à établir cette identité.

Cette distinction évite de surinterpréter les preuves techniques.

---

## 7. Ne jamais attribuer une preuve au mauvais build

Un manifeste ou un artefact produit pendant une génération distincte peut être utile comme référence, mais ne doit pas être présenté comme preuve d'une autre exécution.

Le cas FTR a montré l'importance de conserver systématiquement :

- BuildId ;
- commit/sourceVersion ;
- provenance du fichier ;
- date ;
- lien ou identifiant de la preuve.

---

## 8. Les deltas doivent être analysés dans les deux dimensions

Le build `4445575` ne présente pas uniquement :

- 86 absents ;

mais aussi :

- 7 cas présents dont le statut/message change.

Une comparaison fiable doit donc rechercher au minimum :

- absents ;
- ajoutés ;
- changements de statut ;
- changements de message ;
- retries/doublons.

---

## 9. `UNKNOWN` est un résultat valide

Lorsqu'une preuve n'existe pas, le bon verdict est `UNKNOWN`.

C'est préférable à une inférence non démontrée, notamment pour :

- les octets réellement consommés à runtime ;
- certains marqueurs de chargement ;
- l'environnement exact ;
- le cleanup complet ;
- la comparabilité entre campagnes qui n'ont pas réellement exécuté les mêmes tests.

---

## Conclusion

Le run BW3 a transformé une comparaison initialement fondée sur des volumes et des archives en un **audit reproductible, nominatif et traçable**.

**InventoryTracking dispose désormais d'une validation technique solide des campagnes et de leurs deltas ; FrenchTaxesRules et Clienteling restent non validables fonctionnellement sur les builds cibles car leurs campagnes JMeter n'ont pas été exécutées.**

L'audit BW3 est terminé, mais cela ne constitue ni une validation métier globale des trois plugins ni une clôture du PBI.
