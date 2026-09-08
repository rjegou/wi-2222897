# Clienteling releases/V6 V21 à V23 — analyse du build 4432602

Date de l'analyse : 2026-09-05.

## Limite de comparaison avec le legacy

Cette fiche analyse des cas JMeter non passés et leurs causes observables. Elle ne démontre pas un écart ni une régression par rapport au runner legacy. La collecte VM ajoutée le 2026-09-06 ne contient aucun rapport d'exécution Clienteling V6 : `../evidence/legacy/curated/03_CLIENTELING/V6.md` indexe seulement les configurations, fixtures et éléments de workflow. FACT — aucune exécution branch-specific n'est prouvée dans les fichiers récupérés. UNKNOWN — cela ne prouve ni une désactivation ni l'absence historique de toute exécution.

En conséquence, les verdicts `UNKNOWN` produit/scénario ci-dessous ne doivent pas être reformulés comme des écarts legacy sans un rejeu réellement comparable.

## Verdict

- V21 : aucune campagne JMeter exécutée ; le stage est `skipped`.
- V22 Cur : run 6180666, 2 096 tests publiés, 1 713 passés et 383 non passés.
- V23 Cur : run 6180673, 2 096 tests publiés, 1 708 passés et 388 non passés.
- V22 Fix et V23 Fix : aucun run JMeter. Les deux déploiements contiennent des MSI incompatibles avec les versions minimales choisies ; le contrôle `Test Y2 deployment` rencontre ensuite des connexions refusées et interrompt les jobs.

Les valeurs 383 et 388 sont deux totaux réels, pas un plafonnement à 383. Les CSV contiennent respectivement 383 et 388 lignes. Ils ont 381 couples `plan | TestCase | opération` en commun, avec la même signature normalisée. V22 possède deux postconditions supplémentaires en faute et V23 en possède sept, soit une différence nette de cinq.

Azure laisse `failedTests` nul sur ces runs et place les cas non passés dans `unanalyzedTests`. Les trois runs de zéro test associés au stage de build ne sont pas des campagnes JMeter et sont exclus.

## Couverture causale des runs Cur

| Première cause observée | V22 | V23 | Classification |
|---|---:|---:|---|
| SQL Full-Text absent du conteneur | 224 | 224 | infrastructure d'exécution |
| XPath `/soap:Fault` généré en `//` | 75 | 75 | outil de migration |
| XML Clienteling interne déséchappé par le générateur | 23 | 23 | outil de migration |
| HTTP 404 sur une cible inexistante | 22 | 22 | scénario/métadonnée et packaging Clienteling |
| Précondition ou postcondition de comptage | 17 | 22 | scénario/jeu de données, cause exacte à discriminer |
| Chemin d'images laissé sous forme de placeholders | 8 | 8 | configuration/fixtures de migration Clienteling |
| Différence avec le fichier attendu, résiduelle et bornée | 8 | 8 | produit ou scénario, `UNKNOWN` |
| Erreur métier enveloppée dans WP006 | 4 | 4 | scénario ou produit, cause interne connue |
| Fonction SQL `CLIENTELING_REMOVENONNUMERIC` absente | 1 | 1 | prérequis FTS/fixture de base |
| Littéral SQL Unicode corrompu | 1 | 1 | outil de migration |
| **Total** | **383** | **388** | |

Cette partition utilise la première opération en faute publiée dans chaque CSV, puis la première ligne JTL en échec pour ce couple plan/cas/opération. Elle ne recompte pas les assertions secondaires d'un même appel.

## 224 échecs — Full-Text Search absent

Les 224 cas se répartissent entre 210 appels qui renvoient une faute applicative et 14 prérequêtes JDBC avec l'erreur SQL 7609. Tous portent le même diagnostic SQL : le composant Full-Text Search n'est pas installé ou ne peut pas être chargé.

| Plan | Nombre |
|---|---:|
| ItemSearch:GetItems | 116 |
| Crm:SearchCustomers | 59 |
| ItemSearch:GetItemsFacets | 27 |
| Crm:GetDuplicateCustomers | 12 |
| Common:CommonSearchByReference | 10 |
| **Total** | **224** |

Le pipeline utilise l'image `y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`. Son Dockerfile hérite d'une image SQL Express et ajoute JMeter, Java, Python et la configuration TCP ; il n'installe pas la fonctionnalité SQL Full-Text. L'erreur SQL observée dans le conteneur confirme que la fonctionnalité n'est pas disponible dans cette image exécutée.

**FACT — ce groupe est une incompatibilité entre les prérequis des tests Clienteling et l'image de test, pas 224 régressions produit indépendantes.** Propriétaire initial : image Docker de `Y2_Tools_Jmeter_Workflow` et son image SQL de base. Rejeu minimal : les cinq plans ci-dessus sur une image où `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` vaut 1, après initialisation du catalogue attendu.

## 99 échecs — trois défauts du générateur

### 75 XPath réduits à `//`

Le dépôt Clienteling contient 78 assertions JMX exactement égales à `//`; 75 apparaissent comme première faute avec `TransformerException: A location step was expected`. Les trois autres sont masquées par une faute antérieure de leur cas.

La source legacy demande notamment `/soap:Fault`. Dans `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`, `CleanXpath` ne traite spécialement que les chemins commençant par `/soap:Fault[`. Pour le chemin nu, la ligne qui remplace `soap:Fault` par une chaîne vide produit `/`, puis l'ajout d'un second slash produit `//`.

**FACT — défaut AutoTest.Api 1.1.46.** Corriger `CleanXpath` pour produire un XPath valide sur le nœud Fault, ajouter des tests unitaires pour `/soap:Fault`, `/soap:Fault[...]` et les chemins avec descendants, republier API et Console, puis régénérer les JMX.

### 23 XML Clienteling déséchappés

Les sources legacy stockent un document XML interne sous forme de texte dans `<Content>` : elles portent par exemple `&amp;lt;ClientelingParameters...&amp;gt;`. Le code C# legacy généré conserve correctement le littéral `&lt;ClientelingParameters...&gt;` dans la requête SQL. Les JMX, eux, ne conservent qu'un niveau d'échappement XML ; après lecture du JMX, SQL reçoit un élément `<ClientelingParameters>` imbriqué au lieu du texte encodé.

Les 23 appels concernés renvoient `CBR_005_0269`, « paramétrage clienteling non valide », dans ItemSearch:GetItems, ItemSearch:GetItemsFacets, Mobility:GetMobileParameters et Mobility:UpdateMobileParameters.

La méthode `RemoveSpecialCharsForXQuery` de `JmeterCodeGen.cs` échappe `<`, `>` et l'apostrophe, mais pas l'esperluette déjà présente dans une entité. Elle transforme donc une entité voulue dans la requête en balise après parsing du JMX.

**FACT — défaut AutoTest.Api 1.1.46.** Préserver l'esperluette avant l'écriture XML, avec des tests de non-régression sur du XML imbriqué encodé. Le rejeu minimal couvre un cas de chacun des quatre plans.

### 1 littéral Unicode cassé

`ItemSearch:Keywords` TC02 contient dans la source SQL un littéral avec des caractères non ASCII et une apostrophe SQL échappée par `''`. `FixSqlUnicodeValue` utilise le motif `'([^']*[^\x00-\x7F][^']*)'`, qui ne comprend pas les paires `''` à l'intérieur d'un littéral. Le JMX insère alors `N` entre les deux apostrophes et SQL renvoie l'erreur 102 dès `A-PreQuery1`.

**FACT — défaut AutoTest.Api 1.1.46.** Remplacer la regex par un traitement de littéraux SQL qui accepte `''`, puis tester ce cas exact et les chaînes Unicode simples avant régénération.

## 22 échecs — cibles HTTP inexistantes

| Cause | Plans | Nombre | Preuve |
|---|---|---:|---|
| Nom de service obsolète dans la source legacy | Deployment:ResetFTSCustomer, UpdateFTSCatalog, UpdateFTSCustomer | 3 | JMX et source ciblent `DeploymentService.svc`, alors que les manifests installent `ClientelingDeploymentService.svc` |
| Nom de service obsolète dans la source legacy | Mobility:GetClientelingParameters, UpdateClientelingParameters | 10 | JMX et source ciblent `MobilityService.svc`, alors que les autres plans et les manifests utilisent `ClientelingMobilityService.svc` |
| Service non packagé | Products:GetItemsV2 | 9 | le JMX cible correctement `ClientelingProductsService.svc`, présent dans les sources, mais absent des manifests MSI V22 et V23 |
| **Total** | | **22** | |

Dix-sept cas échouent sur l'assertion de statut et cinq autres atteignent d'abord une assertion XML avec une réponse HTTP 404 vide. Le total causal est donc 22.

**FACT — le générateur recopie ici le champ `WebService` de la source ; il n'invente pas les deux noms génériques.** Corriger les cinq métadonnées de plans dans Clienteling avant régénération. Ajouter le service Products aux manifests MSI V22/V23 ou retirer ces tests des versions où le service n'est pas supporté, selon la décision produit. Rejeu minimal : un cas par endpoint corrigé et les neuf cas Products.

## 8 échecs — répertoire d'images non migré

Les fichiers `v22-*.cy2px` et `v23-*.cy2px` configurent `CustomImageLocation` avec le littéral `${tests.folder}\${CustomImageFolder}` hérité de l'ancien workflow NAnt. La documentation du pipeline ne déclare comme placeholders remplacés que `__plugin_Version__` et `__CONTAINER_HOST__`. La valeur reste littérale jusque dans `web.config` ; les huit réponses portent `CBR_005_0344` et cherchent ce chemin sous le répertoire IIS.

De plus, les images de `IntegratedTests/Workflow/config_PLG/GetItemImage` existaient avant la migration mais ne figurent plus dans l'arbre du commit migré ; seuls les JMX et fichiers de réponse attendue sont conservés.

**FACT — configuration et fixtures Clienteling incomplètes.** Copier les images dans un emplacement connu du conteneur, définir `CustomImageLocation` avec ce chemin réel et vérifier la présence des fichiers avant JMeter. Rejeu minimal : les huit cas `Image:GetSerialNumberImage`.

## Groupes bornés restant à discriminer

### Fonction SQL absente

`Deployment:UpsertFTSCustomer` TC02 appelle une requête qui dépend de `dbo.CLIENTELING_REMOVENONNUMERIC`, mais la fonction n'existe pas. Le code produit la crée lors de l'initialisation ou de la mise à jour FTS, tandis que la campagne ne démontre pas qu'une initialisation réussie a eu lieu. C'est probablement une conséquence du prérequis FTS manquant ou d'un backup incomplet, mais l'artefact ne permet pas de choisir entre les deux.

Test discriminant : sur l'image corrigée, initialiser FTS, vérifier l'existence de la fonction et rejouer Upsert TC02.

### Quatre fautes métier enveloppées dans WP006

Les causes internes ne sont pas des indisponibilités génériques du worker :

- CreateReceipt TC33, TC34 et CreateReceipt_IJSQL TC15 : reçus non équilibrés ;
- UpdateHeader TC01 : transition de la commande vers « Expédiée » refusée.

L'absence d'une baseline legacy comparable ne permet pas de trancher entre données de scénario obsolètes et régression produit. Rejouer ces quatre payloads sur le runner legacy avec les mêmes packages et le même backup, puis faire valider la règle métier attendue.

### Préconditions et postconditions

V22 compte 8 préconditions et 9 postconditions de comptage en faute. V23 contient les mêmes 17 cas plus cinq cas nets : V22 seul a CreateReceipt TC38/TC39, tandis que V23 seul a CreateReceipt TC01/TC11 et CreateReceipt_IJSQL TC06/07/08/12/13.

Ces résultats bornent un problème d'état du backup, d'ordre ou de nettoyage des scénarios. Ils ne prouvent pas une faute produit. Le test discriminant est un rejeu isolé après restauration du backup, puis un rejeu dans l'ordre de campagne pour détecter une dépendance inter-cas.

### Huit différences B-XQuery avec les fichiers attendus

- quatre réponses HTTP 200 diffèrent des fichiers attendus : GetClientData TC01/TC07, GetItemImage TC03 et GetItemImages TC07 ; les fichiers de diff publiés sont tronqués avant la propriété décisive ;
- GetCities TC02/TC03 et GetRegionsByCountryId TC05 attendent HTTP 500 mais reçoivent HTTP 200 avec une collection vide ;
- GetHeaderList TC03 attend HTTP 200 mais reçoit `CBR_005_0010`, critères de recherche requis.

Verdict : `UNKNOWN` produit/scénario. Il faut une décision de contrat et une baseline legacy équivalente ; une simple mise à jour des fichiers attendus ne serait pas une preuve.

## Déploiements Fix — incompatibilités de versions prouvées

### V22 Fix

| Composant en échec | Prérequis annoncé par MSI | Version installée |
|---|---|---|
| Clienteling Server IIS 22.0.6.695 | Core Server IIS >= 22.0.0.1130 | 22.0.0.1012 |
| LoyaltyEngine WorkerProcess 22.0.5.149 | Core WorkerProcess >= 22.0.0.1012 | 22.0.0.1011 |
| TaxEngine Server IIS et WorkerProcess 22.0.6.69 | Technical >= 22.0.2.757 | 22.0.2.417 |

### V23 Fix

| Composant en échec | Prérequis annoncé par MSI | Version installée |
|---|---|---|
| Technical Server IIS et WorkerProcess 23.0.2.757 | Common >= 23.0.3.179 | 23.0.3.154 |
| TaxEngine Server IIS et WorkerProcess 23.0.6.69 | Technical >= 23.0.2.757 | Technical 23.0.2.757 n'a pas pu s'installer |

Les configurations Fix épinglent ces versions incompatibles. Les variantes Cur utilisent notamment Core 22.0.0.2096 / 23.0.0.2009, Common 22.0.3.315 / 23.0.3.315 et Technical 22.0.2.1631 / 23.0.2.1631 ; tous leurs MSI s'installent avec le statut 0.

La timeline marque pourtant `Launch Y2 deployment` comme réussie dans les deux jobs Fix, puis `Test Y2 deployment` échoue : ping du worker, pages Web et acquisition du jeton rencontrent des connexions activement refusées. Les erreurs MSI 1603 ne sont donc pas propagées par l'étape de déploiement.

**FACT — les minima déclarés par Clienteling V22/V23 ne forment plus une pile installable avec Clienteling 6.695.** Relever les versions Fix jusqu'aux minima réellement exigés ou republier des packages compatibles. Ajouter en parallèle un garde-fou dans PlatformDeploy pour faire échouer `Launch Y2 deployment` dès un MSI non nul.

Rejeu minimal : d'abord le seul contrôle de santé V22 Fix et V23 Fix ; seulement lorsqu'il passe, lancer un cas JMeter par version. Les centaines de causes Cur ne doivent pas être attribuées aux jobs Fix tant que ceux-ci n'atteignent pas JMeter.

## Complément Round 2 — transport des fixtures Clienteling (2026-09-07)

**FACT** — le snapshot du build 4432602 conserve `CustomImageLocation=${tests.folder}\\${CustomImageFolder}` mais aucun fichier image; les preuves historiques V6 conservent onze JPG sous `config_PLG/GetItemImage`. Le template PlatformDeploy inspecté copie les bases et la configuration Docker, sans instruction `CustomImage`/`ImageFolder`.

**FACT discriminant** — la collecte [2026-09-07-brain-reprise-worker3](../evidence/2026-09-07-brain-reprise-worker3/README.md) exécute un test avec fixture factice : le placeholder littéral ne résout aucun chemin, tandis qu'un chemin absolu vers la fixture résout. **INFERENCE** — la décision de correction doit porter sur le propriétaire du transport et la valeur réellement visible par IIS. **UNKNOWN** — artefact/montage final, chemin IIS et support métier.

## Dérive et intégrité des preuves

- le clone local est détaché et propre au commit exact du build, `8744999cabb6cea993db49a2d2bf741ae2dd5454` ;
- la branche migrée distante `Clienteling_Migration_AutoTest_Jmeter_On_releases/V6` pointe encore sur ce commit ;
- aucun autre build de cette définition et de cette branche n'a été trouvé après 4432602 ;
- les dix ZIP utiles sont conservés sous `evidence/build-4432602`, avec extraction locale ;
- les fichiers bruts pouvant contenir des réponses d'authentification ne sont pas reproduits dans cette fiche.
