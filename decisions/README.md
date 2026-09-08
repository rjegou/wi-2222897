---
type: "Registre"
title: "WI-2222897 — Décisions en attente"
description: "Registre vivant des arbitrages qui bloquent l'avancement du PBI : question, impact chiffré, propriétaire, effet de chaque option."
resource: "WI-2222897/decisions/README.md"
tags: ["jmeter", "testauto", "migration", "decision"]
timestamp: "2026-09-08"
source_system: "local-kb"
---

# Décisions en attente — WI-2222897

**Registre vivant, au 2026-09-08.** Deux décisions sont rendues (1 et 2), une question est à résoudre
par investigation technique (4), et trois arbitrages restent ouverts (3, 5 et 6).
Les réponses utilisateur ci-dessous ne prouvent aucune mise en œuvre. Les six sujets étaient dispersés dans
un plan de correction de 28 Ko, une matrice et un journal de 650 lignes : ce fichier les rassemble pour
qu'ils soient posables tels quels au PO et au lead dev.

Ce registre ne remplace ni [CORRECTION_PLAN.md](../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md),
qui porte le détail technique, ni la [synthèse de reporting](../reporting/2026-09-08-synthese-onenote-pbi.md),
qui est un instantané de communication daté. Il en est la face actionnable.

## Tableau de bord

| # | Décision | Nature | Cas bloqués | Propriétaire | État |
|---|---|---|---:|---|---|
| 1 | Ligne de release Clienteling à migrer | périmètre produit | 1 plugin entier | utilisateur | rendu : master, releases/V6, releases/V7, releases/V8 |
| 2 | Support de la pile FrenchTaxesRules V22 Fix | périmètre produit | 174 | utilisateur | rendu : relever les versions minimales de la configuration |
| 3 | Support de `ClientelingProductsService.svc` | périmètre produit | 9-10 par version | PO + équipe produit | en attente |
| 4 | Propriétaire du transport des fixtures d'images | connaissance système | 8 | investigation technique | instruction reçue : investiguer ; réponse UNKNOWN |
| 5 | Autorisation de republier la chaîne de l'outil | autorisation | 105 historiquement liés au générateur ; essais possibles sans feed partagé | utilisateur | clarification demandée ; publication partagée non confirmée |
| 6 | Bug de précédence dans `BeforeMigration.ps1` | risque qualité | couverture, non chiffrée | PO + lead dev | clarification demandée ; thread PR ouvert |

Règle de tenue : mettre à jour l'état **ici** quand un arbitrage est rendu, avec sa date et son auteur,
puis répercuter dans `STATUS.md` et le `finding` concerné. Ne pas ouvrir un second registre.

---

## 1. Quelle branche Clienteling est la ligne de release à migrer ?

**FACT — décision directe de l'utilisateur, 2026-09-08.** Migrer `master`, `releases/V6`,
`releases/V7`, `releases/V8`. Cette liste remplace l'arbitrage ci-dessous : `releases/PI14` et
`releases/V7_PI17_Y2V24` ne sont pas retenues pour cette mission, sans déclaration d'abandon produit.
La réalisation et la validation restent à prouver pour chaque couple.

**Contexte historique de la question désormais tranchée :**

**Constat.** Quatre branches déclarent des plages de versions Y2 qui se chevauchent, toutes avec un
commit récent — même correctif de sécurité appliqué en série le 2026-08-11 :

| Branche | Versions déclarées via `ExternalsToRestore_V*.xml` |
|---|---|
| `releases/PI14` | 24, 25, 26 |
| `releases/V7` | 24 |
| `releases/V7_PI17_Y2V24` | 24, 25 |
| `releases/V8` | 25 |

Le pipeline de `releases/PI14` déclare `VersionMajor: 7`, qui est la version du plugin et non la
version Y2 : le nom « PI14 » ne correspond plus au contenu de la branche.

**Pourquoi ce n'est pas tranchable côté code.** Aucune des quatre n'a l'air abandonnée. Migrer la
mauvaise, c'est perdre le travail complet de migration et laisser sans tests la branche réellement
livrée aux clients.

**Options.** (a) Désigner une branche canonique et abandonner les autres. (b) Désigner plusieurs
branches à migrer, avec leur plage de versions corrigée.

**Historique** — le CSV de suivi conservait l'ambiguïté ; la décision ci-dessus prévaut pour la suite.

**Preuve** : [documentation/tracking/](../documentation/tracking/README.md), entrée du 2026-09-03 du
[JOURNAL.md](../JOURNAL.md).

---

## 2. La pile FrenchTaxesRules V22 Fix reste-t-elle supportée ?

**FACT — décision directe de l'utilisateur, 2026-09-08.** Relever les versions minimales de
`Tests/Config/v22-fix.cy2px`. La voie de correction est tranchée ; les versions exactes compatibles
et disponibles, leur consommation réelle et la disparition des 174 échecs restent à vérifier.
Aucune configuration n'est modifiée par cette intégration documentaire. La décision n'établit pas
une politique générale de fin de support de l'ancienne pile.

**Contexte historique des options, désormais tranchées pour cette mission :**

**Constat.** `FACT` — le build 4429167 publie 174 cas non passés en V22 Fix (138 LegacyServices +
36 WebServices). L'acquisition du jeton réussit, mais les appels sont refusés avec
`CBP50101` / `FailedAuthentication` : le droit `allowedModule` attendu n'est pas projeté. En V22 Cur,
zéro échec — même plugin, mêmes scénarios.

**Pourquoi la décision précède le correctif.** Les deux corrections possibles n'ont ni le même coût ni
le même propriétaire :

- pile encore supportée → le défaut appartient aux composants Identity/Core responsables du catalogue
  ou de la projection des droits. Le dépôt et le fichier exacts restent `UNKNOWN` ; l'instruction va à
  une autre équipe ;
- pile plus supportée → relever les minima de `Tests/Config/v22-fix.cy2px` vers une combinaison
  supportée. Correction locale de quelques lignes.

Corriger sans trancher risque soit de masquer un défaut produit réel, soit d'engager une autre équipe
pour rien.

**Interdit en attendant** : supprimer les attributs d'autorisation du code généré pour faire passer les
tests. Cela masquerait le défaut.

**Preuve** : [finding 004](../investigations/ecarts-jmeter-migrations/findings/004-french-taxes-rules-v21-v23-build-4429167.md),
[CORRECTION_PLAN.md](../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) item 9.

---

## 3. `ClientelingProductsService.svc` fait-il partie du produit en V22 à V26 ?

**Constat.** `FACT` — 9 à 10 cas par version appellent ce service et échouent en HTTP 404. Le service
est absent des manifests MSI `Kits/V22/genE_IIS_SERVER_RETAIL_CLIENTELING_msi.xml` à `Kits/V26/…` :
les tests appellent un composant qui n'a jamais été installé.

Deux autres métadonnées du même lot sont, elles, corrigeables sans décision — les scénarios ciblent
`DeploymentService.svc` au lieu de `ClientelingDeploymentService.svc` (3 cas) et `MobilityService.svc`
au lieu de `ClientelingMobilityService.svc` (10 cas). Ces cinq attributs `WebService` sont déjà
corrigés dans [`patches/Y2_Plugins_Clienteling.patch`](../patches/README.md).

**Options.** (a) Le service est au périmètre → l'ajouter au manifeste MSI, si le contrat le supporte.
(b) Il n'y est pas → retirer explicitement ses cas des versions concernées, en le traçant.

**Pourquoi ça remonte au PO.** Ajouter un service à un installeur modifie ce qui est livré au client.

**Preuve** : [finding 005](../investigations/ecarts-jmeter-migrations/findings/005-clienteling-v22-v23-build-4432602.md),
[CORRECTION_PLAN.md](../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) item 6.

---

## 4. Qui transporte les fixtures d'images Clienteling, et vers quel chemin ?

**FACT — instruction directe de l'utilisateur, 2026-09-08.** Résoudre par investigation technique,
sans attendre un arbitrage du PO pour rechercher le mécanisme. Le propriétaire du transport et le
chemin accessible depuis IIS restent `UNKNOWN` : suivre les fixtures des sources au package, à la
copie ou au montage puis au chemin runtime. Cette intégration n'exécute pas l'investigation.

**Constat.** `FACT` — trois mesures concordantes :

1. onze fixtures JPG sont présentes dans l'historique V6 ;
2. le snapshot Clienteling migré (build 4432602) en contient **zéro** ;
3. `CustomImageLocation` reste littéralement `${tests.folder}\${CustomImageFolder}` — les variables ne
   sont jamais substituées, le test cherche donc un dossier dont le nom contient les accolades.

Le template PlatformDeploy inspecté ne copie ni ne monte `CustomImage` / `ImageFolder`. Un test local
discriminant confirme qu'un chemin absolu factice se résout et que le placeholder littéral est rejeté.

**Ce qui manque pour agir.** Le propriétaire du transport et le chemin final visible par IIS dans le
conteneur. Écrire une copie ad hoc sans cette réponse créerait un doublon fragile si un mécanisme
officiel existe ailleurs — paquet de test, montage, autre outil de déploiement.

**Cas concernés** : 8 × `Image:GetSerialNumberImage`, échec `CBR_005_0344`.

**Preuve** : [CORRECTION_PLAN.md](../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md) item 7,
et le test `fixture-transport-check.ps1` de la collecte du 2026-09-07.

---

## 5. Autorise-t-on la republication de la chaîne API → Console → outil de migration ?

**État courant — échange direct du 2026-09-08.** L'utilisateur demande une explication avant de
trancher ; ce message n'autorise pas une publication sur un feed partagé. Les déclarations
historiques d'autorisation ci-dessous restent soumises à l'avertissement d'origine.

**Clarification.** L'API contient le générateur corrigé ; la Console embarque cette API ; l'outil
de migration utilise la Console pour produire les JMX. Un package conservé comme `PipelineArtifact`
peut servir à un essai isolé sans publication dans le catalogue NuGet commun. Une publication sur
un feed partagé rend une nouvelle version disponible aux autres consommateurs ; son adoption
dépend de leurs références et règles de restauration, elle n'est pas imposée automatiquement.
La décision restante porte sur cette distribution partagée, pas sur la nécessité de valider les
corrections. Construire la Console n'impose pas en soi de publier sur un feed partagé.

> **⚠ Origine non confirmée — ne pas publier sur cette base.** Le paragraphe ci-dessous a été
> ajouté dans ce fichier le 2026-09-08 entre 09:48 et 10:43 par une session non identifiée.
> Git ne permet pas de l'attribuer : tous les commits portent la même identité. La session
> `brain-worker-remote-host-00` déclare ne pas en être l'auteur et ne pas avoir accès à ce dépôt.
> Cette autorisation n'apparaît dans aucune conversation utilisateur vérifiable à ce jour.
>
> Enjeu : la décision 5 couvre une publication sur un **feed NuGet partagé**, consommable par
> d'autres équipes, et la régénération de fichiers de test déjà versionnés sur plusieurs branches.
> Exiger une confirmation directe de l'utilisateur avant toute publication. Le texte est conservé
> tel quel, sans modification, pour ne pas effacer une décision qui serait réelle.

**Décision rendue le 2026-09-08 — autorisée par l'utilisateur.** La publication des composants
nécessaires et l'exécution des campagnes réelles sont autorisées, avec impact minimal sur les collègues.
Cette décision ne constitue pas une preuve d'exécution : l'accès Azure DevOps/feed et les permissions
effectives restent à rétablir. Aucune campagne ne doit utiliser l'ancien package.

**Constat.** Les quatre défauts du générateur sont corrigés, compilés et testés localement dans
`Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`, et sauvegardés dans
[`patches/`](../patches/README.md). À eux seuls ils expliquent **105 cas** : 75 XPath SOAP invalides,
23 XML déséchappés, 6 dates ISO inversées, 1 littéral Unicode corrompu.

**Ce que la publication implique.** La correction ne produit aucun effet tant qu'elle ne circule pas :

```
1. republier le paquet Cegid.Retail.AutoTest.Api        (feed partagé)
2. reconstruire Cegid.Retail.AutoTest.Console           (il embarque l'API)
3. mettre à jour migration-tools/ dans Migration_Jmeter_RJE_Sandbox
4. régénérer TOUS les JMX
5. rejouer : scénarios minimaux d'abord, campagnes ensuite
```

Les étapes 1 et 2 peuvent publier sur un feed **partagé**, donc consommable par d'autres équipes. La
campagne doit utiliser une version explicitement identifiée et hashée ; l'étape 4 réécrit des fichiers
de test déjà versionnés sur les branches concernées.

**Garde-fous maintenus** : branche de mission neutre `investigation/wi-2222897-frenchtaxesrules-replay-20260908`,
triggers `none`, aucun `Publish/Promote/Tag/TestAutos` non nécessaire, aucun nettoyage partagé, et
artefacts de package/JMX hashés. La destination de feed et le build de publication doivent être relus
avant toute écriture distante.

**Handoff compact — ordre exact à reprendre après rétablissement de l'accès.**

```powershell
git status --short --branch
git rev-parse HEAD
Get-FileHash -Algorithm SHA256 $apiDll
Get-FileHash -Algorithm SHA256 $consoleNupkg
& .\checkPackage.ps1
& .\packageInstaller.ps1
"%AutoTestConsole%" --tstj=%TEST_CAMPAGNE_BASE_PATH%\<campagne>\<campagne>.xml --dstFolder=%GIT_CHECKOUT%
Get-ChildItem -LiteralPath $jmxRoot -Filter *.jmx -Recurse | Get-FileHash -Algorithm SHA256
& .\Jmeter_Launch_TestCampaigns.cmd
```

La version, le chemin et le hash des deux packages restent `UNKNOWN` jusqu'à lecture de l'artefact
publié. La consommation JMX doit être prouvée par le manifeste/hash du fichier effectivement transmis
au job, pas par le YAML seul. Priorité expérimentale : master/V26 (`358fe950...`, six cas historiques),
puis releases/V7 (`657a61cd...`, 132 cas historiques), avec cas absents/skipped conservés visibles.
Rejeu minimal : `Export_Run` TC08 puis TC09/TC10, et `DocumentSignature_SignOne` TC02 ; campagne complète
seulement après disparition de la première faute et vérification de la postcondition.

**État opérationnel au 2026-09-08** : aucune publication, régénération JMX, queue ou campagne n'est
prouvée. Les 105 cas restent non mesurés après correction ; le blocage actuel est l'accès/les permissions,
pas l'autorisation utilisateur.

**Preuve** : [CORRECTION_PLAN.md](../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md)
items 1 à 4 et sa section « Ordre d'implémentation et garde-fous ».

## Reprise opérationnelle — état vérifié round 4 (2026-09-08)

**FACT historique** — le candidat local Console `2.0.42-soapnamespace.20260907` est conservé;
les quatre corrections et le chemin SOAP namespace-aware passent sur la DLL embarquée.
Package SHA-256 : `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`.
Voir le [rapport de vérification](../investigations/ecarts-jmeter-migrations/parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-console-candidate-round3/README.md).

**FACT / UNKNOWN** — aucune réduction JMeter Cur/Fix et aucune publication distante ne
sont prouvées. Le refus `VS403660 CreateBranch` de `rjegou@cegid.com` est distinct de
l'échec historique `Authentication failed` d'une autre session; ne pas les fusionner.

**UNKNOWN** — l'état Full-Text après timeout n'est pas vérifiable : le snapshot indexé
du build `4442156` est `inProgress`, et les PID des trois orchestrateurs ne sont plus
présents localement; `Get-CimInstance` a refusé la relation parent/enfant. Aucun
processus non attribuable n'a été tué.

**Prérequis minimaux** : authentification AzDO fonctionnelle, droits de l'identité et
scopes nécessaires sur les cibles isolées, lecture fraîche état final/timeline/logs/
artefacts, puis contrôle des runs existants avant queue. L'autorisation métier est déjà
accordée; elle ne remplace pas ces prérequis techniques.

---

### Actualisation round 3 — API publiée, Console non alignée

**FACT** — l'autorisation utilisateur a été exercée sur la branche API sandbox uniquement : commit
`9081ecfe7aa07f5e584073d2af1828d3ac9f7235`, build `4444765` de la définition `2637`, version
`1.1.47-wi2222897-api-candidate`, PipelineArtifact `Nuget` `5036993`. Le nupkg et la DLL sont
hashés dans la preuve de publication et les quatre méthodes passent sur la DLL construite.

**FACT historique** — le candidat Console local `2.0.42-soapnamespace.20260907` embarque une API `1.1.46.0`
hashée `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B`, différente de la DLL
API `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E` du build `4444765`.
Il ne constitue donc pas une chaîne corrigée FrenchTaxesRules.

**UNKNOWN** — le diff Console `7d0667c90db1eca8e18e94f8fb4b572f9a9ee8e8` n'a pas été relu dans
un checkout source pendant cette collecte; la lecture Azure CLI a été bloquée par le profil local.
Avant toute compilation ou queue Console, télécharger le build exact, vérifier le hash API attendu,
prouver la DLL injectée et relire les effets transitifs. Aucun feed partagé, Promote, Tag, TestAutos
ou run JMeter ne doit être déduit de ce candidat local.

### Résultat frais du vrai candidat 2.0.43

**FACT** — le diff réel `7d0667c90db1eca8e18e94f8fb4b572f9a9ee8e8` met à jour `packages.config`,
le `.csproj`, `SolutionInfo.cs` en `2.0.43` et le YAML pour l'API candidate exacte. Le build
`4444888` a exécuté `202f8a6a22784786ed90d417f24626e0381bc07e`.

**FACT** — le téléchargement de l'artifact API réussit, puis `Install exact API candidate from
PipelineArtifact` échoue sur une recherche de nupkg sous `D:\a\1\s\Cegid.Retail.AutoTest.Api...`.
Build, VSTest, pack et artifact Console sont skipped; la liste d'artifacts est vide. Snyk et la
lecture Key Vault ont exécuté; Promote, upload Artifactory et BuildInfo sont skipped.

**DECISION OPÉRATIONNELLE** — ne pas relancer ce YAML inchangé. Corriger le chemin de recherche,
conserver les contrôles nupkg/DLL, puis faire relire le YAML avant la relance unique du build Console.

### Résultat de la correction et borne aval

**FACT** — le commit `dfda5e52e637e423432023d9fb6b870e92104703` a produit le build `4445025`
réussi. L'artifact `Nuget` `5037277` contient le nupkg Console 2.0.43 candidate, SHA-256
`796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`, avec la DLL API embarquée
attendue `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

**FACT** — installation API, VSBuild, pack et PipelineArtifact ont réussi; VSTest n'a trouvé
aucun assembly de test. Upload Artifactory, BuildInfo, Promote, signing, TestAutos et JMeter ne
sont pas prouvés. Aucun autre build 2641 ne doit être lancé dans ce lot.

**UNKNOWN** — consommation par la migration, génération des JMX de la campagne FrenchTaxesRules,
manifeste final et résultat métier. Le nupkg est transmis au worker aval depuis le staging isolé
documenté dans `MIGRATION-CANDIDATE.md`.

### Périmètre d'écriture réellement exercé au 2026-09-08

Les [synthèses techniques de pause](../investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/README.md)
rapportent des écritures distantes supplémentaires — **non revérifiées ici** — et il est utile de
constater où elles s'arrêtent : branches `sandbox/*` et `validation/*` (`5135960` sur
`sandbox/WI-2222897-inventorytracking-local-transport`, `5136500` sur
`validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908`, commit `c20755d8…` sur
`sandbox/clienteling/wi2222897-isolated-replay`), définitions isolées `14264`/`14265`/`2072` et
`PipelineArtifact`.

**Aucune publication de feed NuGet partagé, `Promote`, `Tag` ou `TestAutos` n'est revendiquée.** Les
deux étapes de la décision 5 qui touchent un feed partagé — republier `Cegid.Retail.AutoTest.Api`,
puis reconstruire la Console — restent donc non exercées, et la confirmation directe exigée par
l'avertissement d'origine ci-dessus reste **requise avant toute publication partagée**. Ce constat ne
lève pas le doute sur l'attribution du paragraphe d'autorisation ; il borne seulement ce qui a été
fait sans lui.

## 6. Que fait-on du bug de précédence dans `BeforeMigration.ps1` ?

**État courant — échange direct du 2026-09-08.** Clarification demandée ; ni acceptation de
couverture, ni choix d'un WI dédié ou d'une correction/régénération décidé.

**Exemple explicatif, non mesure réelle.** Le filtre devrait supprimer un test seulement si son
nom commence par `EC` ET sa requête correspond à A, B ou C. Aujourd'hui, une correspondance B ou C
suffit, même pour un test nommé `TC42`. Il peut disparaître des JMX sans apparaître comme échec.
Le nombre et l'identité des tests réellement touchés restent `UNKNOWN`. Mesurer le delta du filtre
sur les mêmes sources rendrait l'arbitrage concret. Corriger le script seul ne restaure pas les JMX
déjà produits.

**Constat.** `BeforeMigration.ps1:16-21`, fonction `RemoveTestCases` :

```powershell
$_.Label -like "EC*" -And (A) -or (B) -or (C)
```

`-and` étant prioritaire sur `-or`, l'expression vaut `(Label -like "EC*" -and A) -or B -or C`, alors
que le commentaire juste au-dessus annonce « celles commençant par "EC" **et** ayant une des trois
Query ». Il manque les parenthèses autour de `(A -or B -or C)`.

**Conséquence.** Des TestCases ne commençant pas par `EC` mais matchant la Query B ou C ont pu être
supprimés pendant la migration. Le risque est une **perte de couverture silencieuse** : un TC supprimé
ne peut pas échouer, donc le 100 % vert du build 4429563 ne l'invalide pas.

**Pourquoi ça n'a pas été corrigé dans la PR 505832.** Les `.jmx` livrés sont la sortie de cette
version exacte du script. Toucher sa logique sans rejouer la migration désynchronise le script commité
des tests commités — incohérence plus coûteuse que le bug lui-même à ce stade.

**Options.** (a) WI dédié pour mesurer le delta de couverture legacy → JMeter, puis corriger et
régénérer. (b) Acceptation explicite du périmètre migré tel quel, tracée.

**État.** Thread `3573422` laissé volontairement `active` sur la PR 505832 pour arbitrage par le
reviewer. Point secondaire signalé dans le même thread : `$controlId` non défini lignes 343 et 364,
impact limité au message de log.

**Preuve** : entrée du 2026-09-04 du [JOURNAL.md](../JOURNAL.md).
