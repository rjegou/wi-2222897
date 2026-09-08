---
type: "Reporting"
title: "WI-2222897 — Synthèse destinée à la page OneNote de suivi du PBI"
description: "Texte prêt à coller dans la page OneNote de suivi, en complément du contenu existant : travail accompli, résultats, décisions attendues et leçons utiles."
resource: "WI-2222897/reporting/2026-09-08-synthese-onenote-pbi.md"
tags: ["jmeter", "testauto", "migration", "reporting", "onenote"]
timestamp: "2026-09-08"
source_system: "local-kb"
---

# Synthèse pour la page OneNote de suivi — WI-2222897

**Portée du document.** Texte rédigé pour être collé dans la page OneNote de suivi de la PBI, lisible par le PO et le lead dev. Il **complète** le contenu déjà présent sur la page (outil modifié pour v26 / v22-25 / ≤v21, consigne LBAU sur mail + PR + déprovisionnement après merge, tableau rempli avec liens PR et runs, builds InventoryTracking en échec, comparatif Clienteling déclaré impossible, remarques de Ludo sur Cur/Fix) et ne le répète pas.

**Fraîcheur.** Consolidation locale au 2026-09-08. Les états Azure DevOps (builds, PR, branches) sont des snapshots datés à revalider avant toute décision engageante.

---

## 1. Travail accompli depuis la mise à jour précédente

**Périmètre reconstruit depuis les dépôts.** L'inventaire des couples dépôt/branche/version a été recalculé directement dans les 3 dépôts (lecture des `ExternalsToRestore_V<n>.xml`, pas de reprise à l'aveugle de l'Excel initial). Écarts trouvés : branches absentes de la source (`FrenchTaxesRules` V1/V6/V7, `InventoryTracking` V6, `Clienteling` V7/V7_PI17_Y2V24/V8/PI14) et anciennes branches Clienteling `releases/V2..V5` renommées `old-releases/V2..V5`. Des tentatives de migration poussées en 2025 sans PR ont aussi été repérées : elles ne doivent pas être comptées comme faites.

**PR de migration.** La PR 505832 (FrenchTaxesRules `releases/V6` → V24) a été vérifiée point par point contre les critères d'acceptation du PBI : image Docker conforme, pipeline réellement exécuté (build + JMeter, 100 % de tests passés), job legacy `TestAutos` supprimé. Les 8 commentaires SonarCloud ont été traités (6 corrigés par un commit de casse PowerShell, 2 en *won't fix* argumenté).

**Analyse des échecs terminée sur 8 des 9 couples suivis.** Pour chaque build listé dans le tableau de suivi, les runs et artefacts ont été relus et **chaque cas non passé a été rattaché à une cause**. Le diagnostic est clos ; ce qui reste ouvert est l'implémentation et le rejeu.

**Baseline legacy récupérée.** Les rapports legacy ont été récupérés sur `Y2-TSTAUTOXXPG2`, ce qui a débloqué une partie de la comparaison (voir §3).

**Corrections localisées et prototypées.** Les 4 défauts du générateur JMX sont dans un seul fichier (`Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`) : dates SQL ISO, littéraux Unicode, échappement XML, XPath SOAP. Les 4 sont corrigés, compilés et validés localement sur fixtures. **Rien n'est publié** : la chaîne API → Console → package de migration → régénération des JMX attend une autorisation.

---

## 2. Ce que les chiffres du tableau veulent réellement dire

> Point le plus important pour la lecture du tableau : **un nombre d'échecs n'est pas un nombre de régressions produit.**

Exemple de Clienteling master V26 (485 échecs, identiques en Cur et en Fix). Les 485 cas ont été classés par première cause en faute, groupes disjoints :

| Cause | Cas | Nature |
|---|---:|---|
| SQL Full-Text indisponible dans le conteneur | 224 | infrastructure d'exécution |
| XPath `/soap:Fault` généré en `//` (invalide) | 75 | défaut outil de migration |
| Réponse HTTP 200 différente de l'attendu | 85 | scénario/produit, à trancher |
| XML interne déséchappé | 23 | défaut outil de migration |
| HTTP 404 sur cible inexistante | 23 | métadonnées + packaging Clienteling |
| Collision SQL `MCAISSEDEVICE.MKD_CLE1` | 22 | scénario/backup |
| Assertions / préconditions | 14 | scénario/jeu de données, à trancher |
| Chemin d'images resté en placeholder | 8 | fixtures de migration |
| Date SQL ISO inversée (année-jour-mois) | 6 | défaut outil de migration |
| Fonction SQL `CLIENTELING_REMOVENONNUMERIC` absente | 2 | prérequis FTS |
| Contrat métier à confirmer | 2 | à trancher |
| Littéral SQL Unicode corrompu | 1 | défaut outil de migration |

Lecture : **environ 46 % des échecs viennent d'un seul problème d'infrastructure** (Full-Text) et **105 cas viennent de 4 défauts de l'outil de migration**, tous corrigés localement. Les mêmes catégories expliquent les volumes des autres branches Clienteling (V6 : 383 et 388 ; V7 : 380 ; V8 : 482).

Autres corrections de lecture du tableau, appuyées sur les runs :

- **FrenchTaxesRules V5 / V22 Fix : 174 cas non passés, pas 138** (138 LegacyServices + 36 WebServices). Cause prouvée : refus d'autorisation `CBP50101` / `FailedAuthentication`, le droit `allowedModule` attendu n'est pas projeté. C'est le cas d'école du conseil de Ludo (0 fail en Cur, fails en Fix ⇒ problème de pile/packaging Fix).
- **FrenchTaxesRules V5 / V23 Fix : aucun test n'a été exécuté.** Le job a échoué sur `Initialize containers` (moteur Docker injoignable). C'est un blocage d'agent, pas un résultat de test.
- **FrenchTaxesRules V7 / V25 : les libellés Cur et Fix sont inversés** dans la capture initiale. Les runs donnent Fix 90 et Cur 42.
- **Clienteling V6 / V22-V23 Fix : aucun run non plus.** Les MSI Fix ne satisfont pas leurs propres minima annoncés (erreurs d'installation 1603, puis connexions refusées).
- **FrenchTaxesRules master V26 : 6 échecs seulement**, dont la cause principale est l'inversion mois/jour des dates SQL ISO (TC08, avec TC09/TC10 en cascade).

---

## 3. InventoryTracking : cause des builds en échec identifiée

La ligne « Nbx pb de build fail pour plugin inventory tracking » a une cause unique et localisée.

Le build `4434070` (branche `InventoryTracking_Migration_AutoTest_Jmeter_On_master`) échoue sur `MSB3245` pour `Cegid.Retail.XmlDiff`, puis 4 erreurs `CS0103`. Le commit de migration supprime `WebServices.Tests` **et son `packages.config`**, qui portait `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28` — or `Services.Tests` utilise encore `XmlDiff`. La suppression du projet n'est pas fautive en soi : c'est la dépendance restée orpheline. Conséquence : `Build V26` échoue et **tous les stages JMeter sont skipped**, donc aucun résultat métier n'est disponible sur ce plugin.

Correctif candidat : redéclarer explicitement les deux packages dans le projet qui garde la référence. Un correctif de cette forme et deux runs de validation (`4440774` vert, puis `4440884` exécutant réellement les campagnes) ont été rapportés, avec **1 991 tests publiés de chaque côté et un écart net d'un seul test** (`002-Device:Reassign - TC 122`, HTTP 500 en Fix, passant en Cur). Ces deux runs viennent d'une source non revérifiée indépendamment : à confirmer avant d'être cités comme acquis.

Attention aussi : le build master `4435986` est vert, mais son YAML **ne déclare pas** `TI_Jmeter_V26`. Un master vert ne valide donc pas la migration.

---

## 4. Comparaison legacy / JMeter : possible, mais par une autre voie

La note « comparatif impossible car les branches non migrées n'exécutent aucun test » reste vraie pour la voie *branche non migrée*. La comparaison a été obtenue autrement, en récupérant les rapports legacy sur la VM `Y2-TSTAUTOXXPG2` :

- **FrenchTaxesRules master V26 Fix** (plugin `26.0.10.25`) : 253 scénarios legacy, 252 `Passed`, **TC22 `Failed`**. Les 6 cas JMeter non passés sont tous retrouvés côté legacy.
- **Clienteling master V26 Fix** (plugin `26.0.10.18`) : 2 131 scénarios legacy, 2 130 `Passed`, **`CreateReceipt` TC32 `Failed`**. Les 485 cas JMeter non passés sont tous retrouvés côté legacy.

Deux conclusions à retenir :

1. **TC22 (FrenchTaxesRules) et TC32 (Clienteling) échouent aussi en legacy.** Ce ne sont pas des régressions JMeter ; il faut chercher une cause commune scénario/produit/données.
2. Pour le reste, les versions de plugin et l'environnement diffèrent (ex. legacy `26.0.10.18` vs JMeter `26.0.10.23`) : la comparabilité est **insuffisante pour conclure**, dans un sens comme dans l'autre. Il ne faut pas modifier un attendu ou une fixture sur cette seule base.
3. Pour V21 à V25, **aucune baseline legacy comparable n'existe** : rapports absents, XML de zéro octet, ou exécutions arrêtées avant MSTest.

---

## 5. Corrections identifiées, avec leur propriétaire

| # | Sujet | Dépôt propriétaire | État |
|---|---|---|---|
| 1-4 | 4 défauts du générateur JMX (dates ISO, Unicode `''`, échappement XML, XPath SOAP) | `Y2_Tools_AutoTest_Api` (`JmeterCodeGen.cs`) | corrigés et compilés localement ; republication API → Console → package migration à autoriser |
| 5 | SQL Full-Text (224 cas) | `Pipelines_Docker_BaseImages` (images SQL 2019/2025) | en diagnostic — voir ci-dessous |
| 6 | Endpoints et packaging Clienteling | sources/config Clienteling + manifests MSI `Kits/V22..V26` | 5 attributs `WebService` erronés identifiés ; décision produit requise pour `ClientelingProductsService.svc` |
| 7 | Fixtures d'images Clienteling (8 cas) | Clienteling + mécanisme de transport | placeholder non résolu, 11 images absentes du snapshot migré ; **propriétaire du transport inconnu** |
| 8 | Piles Fix Clienteling V22/V23 incompatibles | config `Tests/Config/v2x-fix.cy2px` | décision de support requise |
| 9 | Autorisations FrenchTaxesRules V22 Fix (174 cas) | Identity/Core ou config V22 Fix | décision de support requise |

**Précision importante sur le Full-Text (item 5) :** les Dockerfiles SQL 2019/2025 activent bien `FEATURES=SQLENGINE,FullText`. Ce n'est donc **pas** une absence de fonctionnalité. Ce qui est observé est une **population Full-Text non terminale** : le probe atteint `PopulateStatus=1` puis expire dans sa fenêtre de 90 secondes, avant même d'exécuter `CONTAINSTABLE`. La cause exacte (service `MSSQLFDLauncher`/`fdhost`, crawl, word breaker, catalogue, disque, démarrage SQL) reste à établir ; un patch de diagnostic est prêt localement, non publié. Le correctif appartient aux images SQL de base, **pas au dépôt consommateur** `Y2_Tools_Jmeter_Workflow`.

Ordre d'implémentation retenu : générateur JMX d'abord (avec tests unitaires et bloc de non-régression), puis images SQL avec un smoke test bloquant sur `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')`, puis republication de la chaîne et régénération de **tous** les JMX, puis les sujets Clienteling nécessitant une décision.

---

## 6. Décisions attendues du PO et du lead dev

1. **Clienteling — quelle est la ligne de release à migrer ?** Quatre branches ont des plages de versions Y2 qui se chevauchent : `releases/PI14` (24-26), `releases/V7` (24), `releases/V7_PI17_Y2V24` (24-25), `releases/V8` (25). Toutes ont un commit récent. Le nom « PI14 » ne correspond plus au contenu de la branche. Non tranché volontairement.
2. **FrenchTaxesRules V22 Fix — cette pile reste-t-elle supportée ?** Si oui, le correctif appartient aux composants Identity/Core (projection du droit `allowedModule`). Si non, on relève les minima vers une pile supportée. 174 cas en dépendent.
3. **`ClientelingProductsService.svc`** est absent des manifests MSI V22 à V26 : l'ajouter au MSI, ou retirer explicitement ses cas des versions non supportées ? 9 à 10 cas par version.
4. **Qui transporte les fixtures d'images Clienteling** vers le conteneur (11 images, 8 cas) ? Le template PlatformDeploy inspecté ne les copie ni ne les monte.
5. **Autorisation de republier** l'API AutoTest puis la Console, de mettre à jour le package de l'outil de migration et de régénérer tous les JMX. Sans cela les 105 cas imputables au générateur resteront rouges.
6. **Bug de précédence dans `BeforeMigration.ps1`** (thread PR 3573422, laissé ouvert volontairement) : `-and` prioritaire sur `-or` fait que des TestCases ne commençant pas par `EC` ont pu être supprimés pendant la migration. Le risque est une **perte de couverture silencieuse** — un TC supprimé ne peut pas échouer, donc un build 100 % vert ne l'invalide pas. À arbitrer : WI dédié pour mesurer le delta de couverture legacy → JMeter, ou acceptation explicite du périmètre migré.

---

## 7. Leçons utiles retenues

**Sur la lecture des résultats**

- **Classer par première cause avant de compter.** 485 échecs = 1 problème d'infra (224 cas) + 4 bugs d'outil (105 cas) + une poignée de sujets produit. Communiquer le total brut donne une image fausse de l'état du plugin.
- **Quand Cur et Fix donnent le même total sur les mêmes cas, la cause est en amont** (infra ou outil de migration), pas dans le packaging. Le critère de Ludo — 0 fail en Cur + fails en Fix ⇒ mauvais packaging Fix — se vérifie bien sur FrenchTaxesRules V22, mais ne s'applique pas à Clienteling où les deux côtés échouent à l'identique.
- **Un job en échec sur `Initialize containers` ou `Test Y2 deployment` n'est pas un résultat de test.** C'est un blocage d'agent ou de pile ; ne pas l'attribuer au périmètre migré, ne pas le compter comme échec fonctionnel.
- **Vérifier que les stages attendus ont réellement tourné avant de qualifier un build.** Un master vert peut ne pas déclarer `TI_Jmeter_V26` (cas de `4435986`). Un build vert dont les stages JMeter sont *skipped* ne valide rien.
- **Dans Azure DevOps, ces cas apparaissent en `unanalyzedTests`, pas en `failedTests`.** Un filtrage naïf sur les tests en échec les rate entièrement.
- **Recompter depuis les runs et artefacts, pas depuis une capture.** Les relectures ont trouvé un sous-comptage (138 au lieu de 174) et une inversion des libellés Cur/Fix (V7/V25).

**Sur la conduite de la migration**

- **Ne pas modifier le script de migration sans rejouer la migration.** Les `.jmx` livrés sont la sortie d'une version exacte du script ; toucher sa logique sans régénérer désynchronise le script commité des tests commités. Corollaire pratique : les corrections de **casse** sont sûres, les **refactos de logique** ne le sont pas dans la même PR.
- **Sonar sur une PR de migration signale surtout le bruit du fichier ajouté, pas le vrai risque.** Les 8 commentaires portaient sur 2 fichiers d'outillage *one-shot* jamais appelés par la CI, et aucun ne pointait le bug de précédence réellement présent dans le même bloc de code. Réflexe utile avant de répondre : vérifier si le fichier est dans le chemin d'exécution CI (`grep` du script dans `azure-pipelines.yml` et les `.bat`).
- **Corriger dans le dépôt propriétaire, pas dans le consommateur.** Le Full-Text appartient aux images SQL de base ; le patcher dans `Y2_Tools_Jmeter_Workflow` déplacerait la responsabilité sans régler la cause.
- **Ne pas transformer un symptôme en cause.** « Full-Text absent » était l'hypothèse ; la mesure montre une population Full-Text qui n'aboutit pas dans la fenêtre du probe. Le correctif n'est pas le même.
- **Ne pas ajuster un attendu ou une fixture sur la seule base d'un écart legacy/JMeter** si les versions de plugin, les données et l'environnement ne sont pas alignés. Sans baseline comparable, le verdict reste « inconnu », pas « régression ».

**Sur l'outillage**

- **Pousser un commit via l'API REST AzDO (`pushes`) évite un clone** quand le dépôt est lourd (ici Git LFS sur les backups `.bak`). Il faut le `oldObjectId` de la ref, les contenus en base64, et une vérification post-push en re-téléchargeant les blobs. À savoir : l'API `/items` exige le **SHA complet**, un SHA court renvoie 404.
- **Attention à l'auto-complete armé sur une PR** avant de pousser : le push relance la validation et peut déclencher le merge si les approbations sont déjà là.

---

## 8. Ce qui reste à faire

1. Confirmer indépendamment les runs InventoryTracking rapportés, puis ouvrir la PR de migration du plugin.
2. Clore le diagnostic Full-Text (patch de diagnostic prêt, à autoriser) puis corriger les images SQL de base avec un smoke test bloquant.
3. Obtenir les décisions du §6, en particulier la ligne de release Clienteling et le support de la pile V22 Fix.
4. Après autorisation, republier la chaîne API → Console → package de migration, régénérer tous les JMX, puis rejouer d'abord les scénarios minimaux et seulement ensuite les campagnes complètes.
5. Poursuivre le processus PR déjà cadré par LBAU : mail de communication + PR pour les dépôts validés, déprovisionnement uniquement après merge.
