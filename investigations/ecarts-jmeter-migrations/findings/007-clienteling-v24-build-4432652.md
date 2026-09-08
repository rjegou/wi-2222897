# Clienteling releases/V7 V24 — analyse du build 4432652

Date de l'analyse : 2026-09-05.

## Limite de comparaison avec le legacy

Cette fiche analyse des cas JMeter non passés et leurs causes observables. Elle ne démontre pas un écart ni une régression par rapport au runner legacy. La collecte VM ajoutée le 2026-09-06 contient cinq rapports Clienteling V7 listés dans `../evidence/legacy/curated/03_CLIENTELING/V7.md` (`test.7.317`, `.319`, `.321`, `.323`, `.328`), mais chacun mesure zéro octet. FACT — aucun scénario ni résultat n'est lisible dans ces fichiers. UNKNOWN — l'exécution V24 exacte, notamment l'itération `test.7.326-20260904_105812` corrélée à `227`, reste sans preuve aval.

## Verdict

- V24 Fix : run Azure 6180729, 2 118 tests publiés, 1 738 passés et 380 non passés.
- V24 Cur : run Azure 6180751, 2 118 tests publiés, 1 738 passés et 380 non passés.
- Les deux jobs ont déployé leur pile et exécuté JMeter. Le build est `partiallySucceeded` à cause des résultats de tests.
- Les deux CSV contiennent 380 lignes. Les 380 clés `plan | TestCase | opération` et leurs catégories causales correspondent exactement entre Cur et Fix.
- Clienteling 24.0.7.325 est commun aux deux variantes. Les versions des dépendances diffèrent sans modifier une catégorie.

## Couverture causale complète

| Première cause observée | Cur | Fix | Classification |
|---|---:|---:|---|
| SQL Full-Text absent du conteneur | 224 | 224 | infrastructure d'exécution |
| XPath `/soap:Fault` généré en `//` | 75 | 75 | outil de migration |
| HTTP 404 sur une cible inexistante | 23 | 23 | scénario/métadonnée et packaging Clienteling |
| XML Clienteling interne déséchappé | 23 | 23 | outil de migration |
| Assertion de statut, précondition ou postcondition | 11 | 11 | scénario/jeu de données, `UNKNOWN` |
| Chemin d'images laissé sous forme de placeholders | 8 | 8 | configuration/fixtures de migration |
| Date SQL ISO transformée en année-jour-mois | 6 | 6 | outil de migration |
| Réponse HTTP 200 différente du fichier attendu | 5 | 5 | scénario/baseline ou produit, `UNKNOWN` |
| Fonction SQL `CLIENTELING_REMOVENONNUMERIC` absente | 2 | 2 | prérequis FTS/fixture de base |
| Faute métier ou contrat à confirmer | 2 | 2 | scénario ou produit, `UNKNOWN` |
| Littéral SQL Unicode corrompu | 1 | 1 | outil de migration |
| **Total** | **380** | **380** | |

Cette partition est disjointe et repose sur la première opération en faute publiée. Elle ne recompte pas les assertions secondaires.

## Répétition exacte avec V26

Sur les 380 clés V24, 378 existent aussi dans V26 et portent la même catégorie. Les deux clés propres à V24 sont :

- Mobility:GetAccessRights TC02 B-XQuery, différence de réponse XML ;
- GetFiscalDataForReceipt TC71 A-PreQuery4, précondition de comptage.

V26 possède 107 clés non passées absentes de V24, notamment les 22 collisions `MCAISSEDEVICE` et 80 différences de réponse supplémentaires. La répétition des 378 signatures accélère le diagnostic, mais ne constitue toujours pas une baseline legacy.

## 224 échecs — Full-Text Search absent

La répartition est identique à V26 : ItemSearch:GetItems 116, Crm:SearchCustomers 59, ItemSearch:GetItemsFacets 27, Crm:GetDuplicateCustomers 12 et Common:CommonSearchByReference 10.

Deux cent dix appels Web contiennent la faute SQL Full-Text et quatorze prérequêtes JDBC renvoient SQL 7609. Le pipeline utilise `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`. Le Dockerfile `y2-jmeter` n'ajoute pas Full-Text à son image SQL de base, et les réponses exécutées confirment son absence.

**FACT — incompatibilité d'infrastructure commune.** Fournir une image où `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` vaut 1, initialiser le catalogue, puis rejouer les cinq plans.

## 105 échecs — quatre transformations fautives du générateur

- 75 XPath : le snapshot contient 78 assertions `//`; `CleanXpath` transforme `/soap:Fault` en `/`, puis en `//`.
- 23 XML internes : 9 UpdateMobileParameters, 7 GetMobileParameters, 4 GetItemsFacets et 3 GetItems. `RemoveSpecialCharsForXQuery` n'échappe pas l'esperluette des entités legacy ; les réponses portent `CBR_005_0269`.
- 6 dates : CreateReceipt TC45-TC47, GetIdempotencyLines TC01/TC02 et PurgeIdempotencyLines TC01. La source legacy contient `2026-04-28`, le JMX `20262804`, refusé avec SQL 242.
- 1 Unicode : Keywords TC02, où `FixSqlUnicodeValue` ne gère pas l'apostrophe SQL `''` et produit une syntaxe invalide.

**FACT — défauts AutoTest.Api 1.1.46, identiques à ceux prouvés en V26.** Corriger et tester les quatre transformations, republier API et Console, puis régénérer les JMX. Les dates doivent aussi être recherchées dans les cas qui passent malgré l'inversion.

## 23 échecs — endpoints inexistants

- trois cas Deployment ciblent le nom legacy `DeploymentService.svc` au lieu de `ClientelingDeploymentService.svc` ;
- dix cas Get/UpdateClientelingParameters ciblent `MobilityService.svc` au lieu de `ClientelingMobilityService.svc` ;
- dix cas Products:GetItemsV2 ciblent `ClientelingProductsService.svc`, mais le service n'est pas listé dans le manifest MSI V24.

Les treize noms génériques sont déjà présents dans la source legacy et sont recopiés par le générateur. Corriger les cinq métadonnées de plans ; pour Products, décider si l'endpoint doit être packagé ou si ces tests ne s'appliquent pas à V24.

## 8 échecs — configuration et fixtures d'images

Les fichiers `v24-*.cy2px` conservent le littéral `${tests.folder}\${CustomImageFolder}`. Les huit réponses cherchent ce chemin sous IIS et portent `CBR_005_0344`. Le parent de migration contient onze images legacy ; le snapshot migré n'en contient aucune sous `Tests`.

**FACT — configuration/fixtures Clienteling incomplètes.** Monter les images dans le conteneur, écrire un chemin réel et vérifier leur présence avant de rejouer Image:GetSerialNumberImage.

## 5 différences aux fichiers attendus

- GetClientData TC01 et TC07 : JSON de configuration différent ;
- GetItemImage TC03 et GetItemImages TC07 : contenu Base64 différent ;
- GetAccessRights TC02 : libellé « Reprise de paniers en attente » attendu, « Reprise de tickets en attente » reçu.

Les réponses sont HTTP 200. Les traces d'images et de JSON sont tronquées avant la propriété décisive. Sans exécution legacy comparable, ces constats ne prouvent ni une régression produit ni une régression de migration.

**UNKNOWN — baseline ou comportement produit.** Rejouer avec le même package et le même backup sur le runner legacy s'il peut réellement exécuter la campagne, puis faire valider les valeurs attendues.

## 11 assertions d'état ou de statut

- six postconditions : SaveClientData TC01/02/07 et UpdateMobileParameters TC01/24/26 ;
- trois cas attendent HTTP 500 mais reçoivent HTTP 200 : GetCities TC02/TC03 et GetRegionsByCountryId TC05 ;
- CreateReceipt TC32 manque sa postcondition ;
- GetFiscalDataForReceipt TC71 attend 22 lignes à la quatrième prérequête.

**UNKNOWN — scénario, état du backup, ordre ou contrat produit.** Rejouer isolément après restauration, puis en campagne ; faire confirmer le contrat des trois réponses HTTP 200.

## Quatre fautes résiduelles bornées

- UpsertFTSCustomer TC01/TC02 : fonction `dbo.CLIENTELING_REMOVENONNUMERIC` absente, probablement liée à l'initialisation FTS ou au backup ;
- GetHeaderList TC03 : `CBR_005_0010`, critères de recherche requis alors que le scénario attend HTTP 200 ;
- UpdateHeader TC01 : WP006/WP008 encapsulent un refus de transition vers « Expédiée ».

Les deux UDF relèvent d'un prérequis à vérifier après correction FTS. Les deux fautes métier restent `UNKNOWN` scénario ou produit et exigent une décision de contrat, pas une qualification automatique d'écart legacy.

## Dérive et intégrité des preuves

- snapshot local détaché et propre au commit exact `a3b9c933ddeaaf1846785ea6bc044e4bf4a083bb`, avec 2 303 fichiers suivis ;
- la branche distante `Clienteling_Migration_AutoTest_Jmeter_On_releases/V7` pointe encore sur ce commit ;
- aucun build plus récent de cette définition et de cette branche n'a été trouvé au 2026-09-05 ;
- les six ZIP utiles sont conservés et extraits sous `evidence/build-4432652` ;
- aucune réponse d'authentification brute n'est reproduite dans cette fiche.

## Ordre de correction recommandé

1. corriger l'image SQL/FTS et vérifier la fonction associée ;
2. corriger les quatre transformations AutoTest.Api et régénérer ;
3. corriger les endpoints et restaurer les fixtures d'images ;
4. seulement ensuite discriminer les cinq réponses et les treize assertions/fautes métier restantes, sans les appeler écarts legacy avant une comparaison réelle.
