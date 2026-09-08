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

**Registre vivant, au 2026-09-08.** Six arbitrages bloquent l'avancement. Ils étaient dispersés dans
un plan de correction de 28 Ko, une matrice et un journal de 650 lignes : ce fichier les rassemble pour
qu'ils soient posables tels quels au PO et au lead dev.

Ce registre ne remplace ni [CORRECTION_PLAN.md](../investigations/ecarts-jmeter-migrations/CORRECTION_PLAN.md),
qui porte le détail technique, ni la [synthèse de reporting](../reporting/2026-09-08-synthese-onenote-pbi.md),
qui est un instantané de communication daté. Il en est la face actionnable.

## Tableau de bord

| # | Décision | Nature | Cas bloqués | Propriétaire | État |
|---|---|---|---:|---|---|
| 1 | Ligne de release Clienteling à migrer | périmètre produit | 1 plugin entier | PO + équipe Clienteling | en attente |
| 2 | Support de la pile FrenchTaxesRules V22 Fix | périmètre produit | 174 | PO + Identity/Core | en attente |
| 3 | Support de `ClientelingProductsService.svc` | périmètre produit | 9-10 par version | PO + équipe produit | en attente |
| 4 | Propriétaire du transport des fixtures d'images | connaissance système | 8 | lead dev + chaîne de déploiement | en attente |
| 5 | Autorisation de republier la chaîne de l'outil | autorisation | 105 | lead dev + PO | **autorisation revendiquée, origine non confirmée** |
| 6 | Bug de précédence dans `BeforeMigration.ps1` | risque qualité | couverture, non chiffrée | PO + lead dev | thread PR ouvert |

Règle de tenue : mettre à jour l'état **ici** quand un arbitrage est rendu, avec sa date et son auteur,
puis répercuter dans `STATUS.md` et le `finding` concerné. Ne pas ouvrir un second registre.

---

## 1. Quelle branche Clienteling est la ligne de release à migrer ?

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

**Non tranché volontairement** — documenté tel quel dans le CSV de suivi plutôt que résolu
arbitrairement.

**Preuve** : [documentation/tracking/](../documentation/tracking/README.md), entrée du 2026-09-03 du
[JOURNAL.md](../JOURNAL.md).

---

## 2. La pile FrenchTaxesRules V22 Fix reste-t-elle supportée ?

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

---

## 6. Que fait-on du bug de précédence dans `BeforeMigration.ps1` ?

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
