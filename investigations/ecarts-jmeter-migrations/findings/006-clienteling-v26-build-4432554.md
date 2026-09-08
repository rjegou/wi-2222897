# Clienteling master V26 — analyse du build 4432554

Date de l'analyse : 2026-09-05.

## Limite de comparaison avec le legacy

Cette fiche analyse des cas JMeter non passés et leurs causes observables. Les Test Runs Azure DevOps du build legacy `4432556` restent vides, mais une preuve aval distincte récupérée sur Y2-TSTAUTOXXPG2 le 2026-09-06 établit une exécution réelle de Clienteling master V26 Fix SQL.

FACT — `../evidence/legacy/raw/missing-supplement/PublishedReports/Y2_Plugins_Clienteling_master_26.0.test.10.18-20260804_031847_Y2_Plugin_Fix_sql.trx` contient 2 131 scénarios élémentaires : 2 130 `Passed`, 1 `Failed`. Les 485 identifiants plan/TestCase non passés sous JMeter Fix sont tous présents : 484 `Passed`, seul `SaleAndSellers_CreateReceipt` TC32 `Failed`.

FACT — le TC32 legacy et JMeter exécutent la même requête de postcondition sur `MCHPSUTILISATDATA`, attendent `1` et obtiennent `0`. Ce cas n'est plus un `UNKNOWN` faute de baseline : l'échec est déjà observé en legacy. Sa cause fonctionnelle reste `UNKNOWN`.

UNKNOWN — les 484 autres couples ne sont pas encore des régressions JMeter démontrées. Le legacy utilise Clienteling `26.0.10.18` sur la VM avec Core Fix `26.0.0.1762`; JMeter utilise Clienteling `26.0.10.23` dans un conteneur. L'équivalence du backup, des autres dépendances, des payloads complets et de l'environnement n'est pas établie. L'inventaire exact par plan/TestCase est dans `../evidence/LEGACY_TEST_INVENTORY.md`.

## Verdict

- V26 Fix : run Azure 6180736, 2 118 tests publiés, 1 633 passés et 485 non passés.
- V26 Cur : run Azure 6180750, 2 118 tests publiés, 1 633 passés et 485 non passés.
- Les deux jobs ont terminé le déploiement et exécuté JMeter. Le build est `partiallySucceeded` à cause des résultats de tests, pas d'un blocage d'installation.
- Les deux CSV contiennent exactement 485 lignes. Les 485 couples `plan | TestCase | opération` sont communs et leur catégorie causale est identique en Cur et Fix.
- Le package Clienteling est le même dans les deux déploiements, `26.0.10.23`. Les dépendances Cur et Fix diffèrent, sans modifier une seule catégorie d'échec.

Azure place ces cas dans `unanalyzedTests` et non dans `failedTests`. Le run de zéro test associé au stage de build est exclu.

## Couverture causale complète

| Première cause observée | Cur | Fix | Classification |
|---|---:|---:|---|
| SQL Full-Text absent du conteneur | 224 | 224 | infrastructure d'exécution |
| XPath `/soap:Fault` généré en `//` | 75 | 75 | outil de migration |
| Réponse HTTP 200 différente du fichier attendu | 85 | 85 | scénario/baseline ou produit, `UNKNOWN` |
| HTTP 404 sur une cible inexistante | 23 | 23 | scénario/métadonnée et packaging Clienteling |
| XML Clienteling interne déséchappé | 23 | 23 | outil de migration |
| Collision SQL sur `MCAISSEDEVICE.MKD_CLE1` | 22 | 22 | scénario/backup |
| Assertion de statut, précondition ou postcondition | 14 | 14 | scénario/jeu de données, `UNKNOWN` |
| Chemin d'images laissé sous forme de placeholders | 8 | 8 | configuration/fixtures de migration |
| Date SQL ISO transformée en année-jour-mois | 6 | 6 | outil de migration |
| Fonction SQL `CLIENTELING_REMOVENONNUMERIC` absente | 2 | 2 | prérequis FTS/fixture de base |
| Faute métier attendue ou contrat à confirmer | 2 | 2 | scénario ou produit, `UNKNOWN` |
| Littéral SQL Unicode corrompu | 1 | 1 | outil de migration |
| **Total** | **485** | **485** | |

La partition prend la première opération en faute du CSV et la ligne JTL en échec portant exactement le même libellé. Les groupes sont disjoints. Les assertions secondaires d'un même appel ne sont pas recomptées.

## 224 échecs — Full-Text Search absent

| Plan | Nombre |
|---|---:|
| ItemSearch:GetItems | 116 |
| Crm:SearchCustomers | 59 |
| ItemSearch:GetItemsFacets | 27 |
| Crm:GetDuplicateCustomers | 12 |
| Common:CommonSearchByReference | 10 |
| **Total** | **224** |

Deux cent dix appels Web renvoient une faute SQL encapsulée et quatorze prérequêtes JDBC renvoient directement SQL 7609. Tous portent le diagnostic « Full-Text Search is not installed, or a full-text component cannot be loaded ».

Le pipeline du commit du build utilise `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`. Le Dockerfile de `Y2_Tools_Jmeter_Workflow` prend l'image SQL comme base puis ajoute Java, Python, JMeter et la configuration TCP ; il n'ajoute pas Full-Text. L'erreur SQL exécutée dans les deux conteneurs confirme que l'image de base utilisée ne fournit pas ce composant.

**FACT — ces 224 cas sont une incompatibilité d'infrastructure commune, pas 224 régressions produit.** Propriétaire initial : image `y2-jmeter` et son image SQL de base. Rejeu minimal : les cinq plans ci-dessus sur une image où `FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')` vaut 1, après initialisation du catalogue.

## 105 échecs — défauts prouvés du générateur

### 75 XPath réduits à `//`

Le snapshot contient 78 assertions JMX exactement égales à `//`; 75 sont la première faute publiée, avec `TransformerException: A location step was expected`. Les trois autres sont masquées par une opération antérieure.

Dans AutoTest.Api 1.1.46, `CleanXpath` ne traite spécialement que les chemins commençant par `/soap:Fault[`. Pour `/soap:Fault`, le remplacement de `soap:Fault` donne `/`, puis l'insertion d'un second slash produit `//`.

**FACT — défaut de `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`.** Corriger `CleanXpath`, tester `/soap:Fault`, `/soap:Fault[...]` et les chemins descendants, republier API et Console, puis régénérer les plans. Les 75 cas ne recouvrent aucun des 224 cas FTS.

### 23 XML internes déséchappés

Les sources legacy stockent le document interne sous forme de texte, par exemple `&amp;lt;ClientelingParameters...&amp;gt;`. Les JMX ne conservent plus que `&lt;ClientelingParameters...&gt;`; après lecture XML, SQL reçoit donc un élément imbriqué au lieu du texte encodé.

Les 23 appels renvoient la désérialisation « End element `Content` expected; found `ClientelingParameters` ou `CommonParameters` » et `CBR_005_0269` :

| Plan | Nombre |
|---|---:|
| Mobility:UpdateMobileParameters | 9 |
| Mobility:GetMobileParameters | 7 |
| ItemSearch:GetItemsFacets | 4 |
| ItemSearch:GetItems | 3 |

`RemoveSpecialCharsForXQuery` échappe `<`, `>` et l'apostrophe, mais pas l'esperluette d'une entité déjà encodée.

**FACT — défaut AutoTest.Api 1.1.46.** Échapper l'esperluette avant l'écriture du JMX et ajouter un test de round-trip sur un XML interne encodé. Rejeu minimal : un cas de chacun des quatre plans.

### 6 dates SQL inversées

Les six prérequêtes insèrent une date legacy `2026-04-28`. Les JMX portent `20262804`, que SQL refuse avec `S0003 242` car 28 devient le mois. Les plans concernés sont CreateReceipt TC45 à TC47, GetIdempotencyLines TC01/TC02 et PurgeIdempotencyLines TC01.

La règle `EscapeJdbcDate` remplace explicitement `'yyyy-mm-dd'` par `'yyyyddmm'`. C'est le même défaut déjà prouvé sur FrenchTaxesRules.

**FACT — défaut AutoTest.Api 1.1.46.** Générer `yyyymmdd`, ajouter un test avec un jour supérieur à 12, régénérer au minimum ces trois plans et rechercher les dates silencieusement valides dans tous les JMX.

### 1 littéral Unicode cassé

ItemSearch:Keywords TC02 échoue en prérequête avec SQL 102. La regex de `FixSqlUnicodeValue` ne comprend pas une apostrophe SQL échappée par `''` et insère `N` au milieu du littéral.

**FACT — défaut AutoTest.Api 1.1.46.** Remplacer la regex par un parseur de littéraux acceptant `''`, puis tester ce cas avant régénération.

## 23 échecs — endpoints inexistants

| Cause | Plans | Nombre |
|---|---|---:|
| Nom legacy `DeploymentService.svc`, alors que le MSI installe `ClientelingDeploymentService.svc` | ResetFTSCustomer, UpdateFTSCatalog, UpdateFTSCustomer | 3 |
| Nom legacy `MobilityService.svc`, alors que le MSI installe `ClientelingMobilityService.svc` | GetClientelingParameters, UpdateClientelingParameters | 10 |
| Service non packagé en V26 | Products:GetItemsV2 | 10 |
| **Total** | | **23** |

Le générateur a recopié les champs `WebService` des fichiers legacy pour les treize premiers cas. Products cible correctement `ClientelingProductsService.svc`, mais le manifest MSI V26 liste quinze services et ne contient pas Products.

**FACT — causes Clienteling, non créées par l'exécution JMeter.** Corriger les cinq métadonnées legacy avant régénération. Pour Products, ajouter le service au package V26 ou retirer les cas si l'endpoint n'est pas supporté. Rejeu minimal : un cas par endpoint Deployment/Mobility et les dix cas Products.

## 8 échecs — chemin et fixtures d'images absents

Les deux fichiers `v26-*.cy2px` écrivent littéralement `${tests.folder}\${CustomImageFolder}` dans `CustomImageLocation`. La documentation ne déclare que `__plugin_Version__` et `__CONTAINER_HOST__` comme placeholders remplacés. Les huit réponses cherchent ce chemin littéral sous IIS et portent `CBR_005_0344`.

Le parent du commit de migration contient onze images sous `IntegratedTests/Workflow/config_PLG/GetItemImage`. Le snapshot migré ne contient plus ce dossier ni aucun fichier JPG/PNG sous `Tests`.

**FACT — configuration et fixtures Clienteling incomplètes.** Copier les images vers un chemin connu du conteneur, renseigner ce chemin réel et valider sa présence avant JMeter. Rejeu minimal : les huit cas Image:GetSerialNumberImage.

## 22 échecs — préconditions SQL incompatibles avec le backup

Onze cas de Mobility:GetCashRegisterCPOSDevices et onze de Mobility:GetCPOSDevices échouent avant l'appel Web. Leurs prérequêtes modifient `MCAISSEDEVICE.MKD_DEVICECATEG` pour la caisse `036`. Le backup contient déjà une ligne avec la même combinaison de clé ; SQL refuse l'update avec 2601 sur l'index unique `MKD_CLE1`.

**CAUSE PROBABLE — scénario non isolé ou backup V26 non conforme à la précondition.** L'artefact démontre la collision, pas si la ligne préexistante est légitime. Propriétaire : scénarios et backup Clienteling. Test discriminant : restaurer le backup, inventorier les clés `MCAISSEDEVICE` avant chaque plan, puis rejouer un cas isolé et la campagne complète pour détecter une dépendance d'ordre.

## 85 réponses HTTP 200 différentes des attendus

| Famille de plans | Nombre | Exemple de différence publiée |
|---|---:|---|
| GetFiscalDataForReceipt | 50 | ajout de `FR1` dans `TaxCode1` |
| GetCashRegisterCPOSDevices | 26 | périphérique TaxBox ajouté ou type différent |
| GetCPOSDevices | 2 | périphérique TaxBox ajouté ou type différent |
| GetClientData | 2 | JSON de configuration différent |
| cinq plans Image | 5 | contenu binaire Base64 différent |
| **Total** | **85** | |

Un fichier attendu représentatif de chacune de ces familles est identique à la source legacy après normalisation des fins de ligne. La migration n'explique donc pas, à elle seule, les différences observées. Les traces publiées sont souvent tronquées à 500 caractères. Les 85 identifiants correspondants sont `Passed` dans le TRX legacy Fix `26.0.10.18`, mais aucune exécution legacy avec le package `26.0.10.23` et le même backup n'est disponible.

**FACT — les 85 cas passent dans la baseline legacy récupérée ; UNKNOWN — baseline obsolète, environnement ou comportement produit modifié.** Rejouer les mêmes cas sous le runner legacy avec Clienteling 26.0.10.23 et le même backup ; seulement ensuite valider fonctionnellement les nouvelles valeurs avant de mettre à jour les attendus. Ne pas appeler cet ensemble « régression JMeter » avant ce rapprochement.

## 14 assertions d'état ou de statut à discriminer

- six postconditions : SaveClientData TC01/02/07 et UpdateMobileParameters TC01/24/26 ;
- trois cas attendent HTTP 500 mais reçoivent HTTP 200 : GetCities TC02/TC03 et GetRegionsByCountryId TC05 ;
- deux préconditions Mobility ne trouvent pas la ligne attendue : GetCashRegisterCPOSDevices TC15 et GetCPOSDevices TC15 ;
- CreateReceipt TC32 manque sa postcondition ;
- GetFiscalDataForReceipt TC71 manque sa précondition et TC80 ne trouve pas la référence TaxBox attendue.

FACT — treize de ces quatorze identifiants sont `Passed` dans le TRX legacy récupéré. `CreateReceipt` TC32 est `Failed` avec la même requête, la même attente et la même valeur observée que JMeter.

**UNKNOWN — scénario, état du backup, ordre ou contrat produit pour les treize legacy verts ; FACT — échec également legacy pour TC32.** Rejouer les treize cas legacy verts isolément avec le package `26.0.10.23` et le même backup, puis dans l'ordre de campagne. Pour les trois HTTP 200, faire confirmer le contrat attendu plutôt que transformer automatiquement les attendus. Pour TC32, rechercher la cause commune aux deux runners plutôt qu'un défaut de migration.

## Quatre fautes résiduelles bornées

- UpsertFTSCustomer TC01 et TC02 : la fonction `dbo.CLIENTELING_REMOVENONNUMERIC` est absente. C'est probablement une conséquence de l'initialisation FTS manquante ou d'un backup incomplet. Vérifier la fonction après correction de l'image et initialisation du catalogue.
- GetHeaderList TC03 : `CBR_005_0010`, critères de recherche requis. Le scénario attend HTTP 200 ; décision de contrat nécessaire.
- UpdateHeader TC01 : WP006/WP008 encapsulent le refus métier de passer la commande à « Expédiée ». Rejouer le payload sous le runner legacy et faire valider la transition attendue.

FACT — les quatre identifiants sont `Passed` dans le TRX legacy `26.0.10.18`. Les deux premiers restent classés prérequis/fixture. Les deux derniers restent `UNKNOWN` scénario ou produit, avec une différence legacy/JMeter constatée mais une comparabilité insuffisante pour conclure à une régression.

## Cur et Fix : même résultat malgré des piles différentes

Clienteling 26.0.10.23 est commun aux deux variantes. Cur utilise notamment Core 26.0.0.3219, Common 26.0.6.50 et Technical 26.0.4.7 ; Fix utilise Core 26.0.0.1762, Common 26.0.4.359 et Technical 26.0.2.1393.

Les 485 clés et leurs douze catégories sont strictement identiques. Cette observation ne prouve pas que les dépendances sont équivalentes ; elle démontre que la séparation Cur/Fix n'explique aucun des cas non passés de ce build.

## Dérive et intégrité des preuves

- snapshot local détaché et propre au commit exact `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a`, avec 2 307 fichiers suivis ;
- la branche distante `Clienteling_Migration_AutoTest_Jmeter_On_master` pointe encore sur ce commit ;
- aucun build plus récent de cette définition et de cette branche n'a été trouvé au 2026-09-05 ;
- les six ZIP utiles sont conservés et extraits sous `evidence/build-4432554` ;
- les fichiers bruts pouvant contenir des réponses d'authentification ne sont ni recopiés ni cités dans cette fiche.

## Ordre de correction recommandé

1. fournir une image SQL avec Full-Text et initialiser le catalogue/la fonction associée ;
2. corriger les quatre transformations prouvées dans AutoTest.Api, republier API puis Console et régénérer les JMX ;
3. corriger les endpoints et restaurer les fixtures d'images Clienteling ;
4. stabiliser le backup et les préconditions `MCAISSEDEVICE` ;
5. utiliser l'inventaire legacy désormais disponible pour cibler les 85 réponses et les 15 cas legacy verts de contrat/état ; rejouer avec package et backup identiques avant toute qualification de régression ; traiter CreateReceipt TC32 comme un échec commun aux deux runners.
