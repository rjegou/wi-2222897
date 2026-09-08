# Clienteling releases/V8 V25 — analyse du build 4432672

Date de l'analyse : 2026-09-05.

## Limite de comparaison avec le legacy

Cette fiche analyse des cas JMeter non passés et leurs causes observables. Elle ne démontre pas un écart ni une régression par rapport au runner legacy. La collecte VM ajoutée le 2026-09-06 fournit trois exécutions Clienteling V8 listées dans `../evidence/legacy/curated/03_CLIENTELING/V8.md` (`test.9.12`, `.13`, `.18`). Chacune démarre `execute.plugin` puis s'arrête avant MSTest, car `override\Y2_Plugins_Clienteling_V8` est absent. FACT — zéro scénario est exécuté dans ces trois captures. UNKNOWN — elles ne correspondent pas à l'itération `test.9.22-20260904_11827` corrélée à `228`, dont le résultat aval reste inaccessible.

## Verdict

- V25 Fix : run Azure 6180806, 2 118 tests publiés, 1 636 passés et 482 non passés.
- V25 Cur : run Azure 6180903, 2 118 tests publiés, 1 636 passés et 482 non passés.
- Les deux jobs ont déployé leur pile et exécuté JMeter. Le build est `partiallySucceeded` à cause des résultats de tests.
- Les deux CSV contiennent 482 lignes. Les 482 clés `plan | TestCase | opération` et leurs catégories correspondent exactement entre Cur et Fix.
- Clienteling 25.0.9.21 est commun aux deux variantes. Les dépendances Cur/Fix diffèrent sans modifier une catégorie.

## Couverture causale complète

| Première cause observée | Cur | Fix | Classification |
|---|---:|---:|---|
| SQL Full-Text absent du conteneur | 224 | 224 | infrastructure d'exécution |
| Réponse HTTP 200 différente du fichier attendu | 82 | 82 | scénario/baseline ou produit, `UNKNOWN` |
| XPath `/soap:Fault` généré en `//` | 75 | 75 | outil de migration |
| HTTP 404 sur une cible inexistante | 23 | 23 | scénario/métadonnée et packaging Clienteling |
| XML Clienteling interne déséchappé | 23 | 23 | outil de migration |
| Collision SQL sur `MCAISSEDEVICE.MKD_CLE1` | 22 | 22 | scénario/backup |
| Assertion de statut, précondition ou postcondition | 14 | 14 | scénario/jeu de données, `UNKNOWN` |
| Chemin d'images laissé sous forme de placeholders | 8 | 8 | configuration/fixtures de migration |
| Date SQL ISO transformée en année-jour-mois | 6 | 6 | outil de migration |
| Fonction SQL `CLIENTELING_REMOVENONNUMERIC` absente | 2 | 2 | prérequis FTS/fixture de base |
| Faute métier ou contrat à confirmer | 2 | 2 | scénario ou produit, `UNKNOWN` |
| Littéral SQL Unicode corrompu | 1 | 1 | outil de migration |
| **Total** | **482** | **482** | |

La partition est disjointe et prend la première opération en faute du CSV. Elle ne recompte pas les assertions secondaires.

## Relation exacte avec V26

Les 482 clés V25 existent toutes dans V26 et gardent la même catégorie. V26 ajoute seulement trois cas de différence binaire : GetClassificationNodeImage TC11, GetCustomerImage TC07 et GetItemListImage TC11.

Cette inclusion exacte démontre la répétition des symptômes JMeter entre V25 et V26. Elle ne démontre pas leur comportement sous le runner legacy.

## 224 échecs — Full-Text Search absent

La répartition est identique à V24/V26 : ItemSearch:GetItems 116, Crm:SearchCustomers 59, ItemSearch:GetItemsFacets 27, Crm:GetDuplicateCustomers 12 et Common:CommonSearchByReference 10.

Deux cent dix appels Web contiennent la faute SQL Full-Text et quatorze prérequêtes JDBC renvoient SQL 7609. Le pipeline utilise `sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022`; le Dockerfile `y2-jmeter` n'ajoute pas Full-Text et les réponses des deux conteneurs confirment son absence.

**FACT — incompatibilité d'infrastructure commune.** Fournir une image où `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` vaut 1, initialiser le catalogue, puis rejouer les cinq plans.

## 105 échecs — quatre transformations fautives du générateur

- 75 XPath : 78 assertions JMX sont `//`; `CleanXpath` transforme `/soap:Fault` en `/`, puis en `//`.
- 23 XML internes : 9 UpdateMobileParameters, 7 GetMobileParameters, 4 GetItemsFacets et 3 GetItems. `RemoveSpecialCharsForXQuery` ne préserve pas l'esperluette des entités legacy ; les réponses portent `CBR_005_0269`.
- 6 dates : CreateReceipt TC45-TC47, GetIdempotencyLines TC01/TC02 et PurgeIdempotencyLines TC01. La source contient `2026-04-28`, le JMX `20262804`, refusé avec SQL 242.
- 1 Unicode : Keywords TC02, où `FixSqlUnicodeValue` ne gère pas `''` dans un littéral et produit SQL 102.

**FACT — défauts AutoTest.Api 1.1.46.** Corriger et tester les quatre transformations, republier API puis Console et régénérer les plans. Rechercher aussi les dates inversées qui restent valides et ne font pas échouer un test.

## 23 échecs — endpoints inexistants

- trois cas Deployment utilisent `DeploymentService.svc` au lieu de `ClientelingDeploymentService.svc` ;
- dix cas Get/UpdateClientelingParameters utilisent `MobilityService.svc` au lieu de `ClientelingMobilityService.svc` ;
- dix cas Products:GetItemsV2 ciblent `ClientelingProductsService.svc`, absent des quinze services du manifest MSI V25.

Les treize noms génériques sont déjà présents dans les sources legacy. Corriger les cinq métadonnées avant régénération. Pour Products, décider si le service doit être packagé ou si les cas ne s'appliquent pas à V25.

## 8 échecs — chemin et fixtures d'images

Les deux fichiers `v25-*.cy2px` conservent `${tests.folder}\${CustomImageFolder}`. Les huit réponses cherchent ce chemin littéral sous IIS et portent `CBR_005_0344`. Onze images existent dans le parent de migration ; aucune n'est conservée sous `Tests`.

**FACT — configuration/fixtures Clienteling incomplètes.** Monter les images, écrire un chemin réel et vérifier leur présence avant de rejouer Image:GetSerialNumberImage.

## 22 collisions de préconditions

Onze cas GetCashRegisterCPOSDevices et onze GetCPOSDevices échouent avant l'appel Web. Les prérequêtes modifient `MCAISSEDEVICE.MKD_DEVICECATEG` pour la caisse `036`, mais une combinaison identique existe déjà ; SQL 2601 refuse l'update sur `MKD_CLE1`.

**CAUSE PROBABLE — scénario non isolé ou backup V25 non conforme.** Inventorier les clés du backup avant chaque plan, rejouer un cas isolé après restauration, puis la campagne complète pour détecter une dépendance d'ordre.

## 82 différences aux fichiers attendus

| Famille | Nombre | Exemple de différence publiée |
|---|---:|---|
| GetFiscalDataForReceipt | 50 | ajout de `FR1` dans `TaxCode1` |
| GetCashRegisterCPOSDevices | 26 | périphérique TaxBox ajouté ou type différent |
| GetCPOSDevices | 2 | périphérique TaxBox ajouté ou type différent |
| GetClientData | 2 | JSON de configuration différent |
| GetItemImage et GetItemImages | 2 | contenu binaire Base64 différent |
| **Total** | **82** | |

Les réponses sont HTTP 200. Les traces longues sont tronquées et aucune exécution legacy équivalente n'est disponible.

**UNKNOWN — baseline ou comportement produit.** Rejouer les mêmes packages et le même backup sur un runner legacy qui exécute réellement les tests, puis faire valider les nouvelles valeurs avant toute mise à jour des attendus.

## 14 assertions d'état ou de statut

- six postconditions : SaveClientData TC01/02/07 et UpdateMobileParameters TC01/24/26 ;
- trois cas attendent HTTP 500 mais reçoivent HTTP 200 : GetCities TC02/TC03 et GetRegionsByCountryId TC05 ;
- deux préconditions Mobility ne trouvent pas la ligne attendue : GetCashRegisterCPOSDevices TC15 et GetCPOSDevices TC15 ;
- CreateReceipt TC32 manque sa postcondition ;
- GetFiscalDataForReceipt TC71 manque sa précondition et TC80 ne trouve pas la référence TaxBox attendue.

**UNKNOWN — scénario, backup, ordre ou contrat produit.** Rejouer isolément après restauration, puis en campagne ; faire confirmer le contrat des réponses HTTP 200.

## Quatre fautes résiduelles bornées

- UpsertFTSCustomer TC01/TC02 : fonction `dbo.CLIENTELING_REMOVENONNUMERIC` absente, probablement liée à l'initialisation FTS ou au backup ;
- GetHeaderList TC03 : `CBR_005_0010`, critères de recherche requis alors que le scénario attend HTTP 200 ;
- UpdateHeader TC01 : WP006/WP008 encapsulent un refus de transition vers « Expédiée ».

Les deux UDF sont un prérequis à vérifier après correction FTS. Les deux fautes métier restent `UNKNOWN` scénario ou produit et ne sont pas qualifiées d'écarts legacy.

## Dérive et intégrité des preuves

- snapshot local détaché et propre au commit exact `8f1088fb5f0d54fc7bb17caf351b98edcaa67706`, avec 2 304 fichiers suivis ;
- la branche distante `Clienteling_Migration_AutoTest_Jmeter_On_releases/V8` pointe encore sur ce commit ;
- aucun build plus récent de cette définition et de cette branche n'a été trouvé au 2026-09-05 ;
- les six ZIP utiles sont conservés et extraits sous `evidence/build-4432672` ;
- aucune réponse d'authentification brute n'est reproduite dans cette fiche.

## Ordre de correction recommandé

1. corriger l'image SQL/FTS et vérifier la fonction associée ;
2. corriger les quatre transformations AutoTest.Api et régénérer ;
3. corriger les endpoints et restaurer les fixtures d'images ;
4. stabiliser le backup et les préconditions ;
5. seulement ensuite discriminer les 82 réponses et les 16 cas de contrat/état, sans conclure à un écart legacy avant une comparaison réelle.
