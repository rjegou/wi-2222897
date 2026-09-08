# FrenchTaxesRules releases/V7 V25 — analyse du build 4429629

Date de l'analyse : 2026-09-05.

## Verdict

Les 132 échecs publiés sont couverts par des signatures comptées : 90 en Fix et 42 en Cur. La capture utilisateur a inversé les libellés Cur et Fix ; les quatre runs Azure et leurs quatre CSV d'erreurs confirment les totaux Azure.

Le build cumule plusieurs causes. Il n'existe pas une régression unique imputable à JMeter :

- la variante Fix utilise des dépendances minimales qui ne fournissent pas trois paramètres NF525 attendus par les scénarios ; cette famille couvre 84 des 90 tests Fix, avec un défaut de conversion de date supplémentaire sur Export TC08 à TC10 ;
- 21 tests Cur dépendent d'un état initial `SO_NF525ACTIF` actif que le plan n'initialise pas ; TC50 rétablit cet état en cours de campagne ;
- le défaut prouvé du convertisseur de dates ISO est aussi présent en V25 et explique les trois échecs Cur du plan Export ;
- les six mêmes cas `DailyRegisterClosing` échouent en Cur et Fix après un retour métier positif, mais aucune baseline legacy comparable ne permet de trancher entre scénario obsolète et produit ;
- les douze échecs Web Cur se répartissent entre une fixture de clôture devenue incohérente, une ligne de base absente, deux TC99 actifs avec période invalide et une écriture de journal absente.

## Comptage Azure DevOps

| Run | Variante | Campagne | Total | Passed | Failed |
|---:|---|---|---:|---:|---:|
| 6178258 | Fix | LegacyServices | 185 | 136 | 49 |
| 6178260 | Fix | WebServices | 65 | 24 | 41 |
| 6178259 | Cur | LegacyServices | 185 | 155 | 30 |
| 6178261 | Cur | WebServices | 65 | 53 | 12 |

Les nombres d'échecs sont calculés par `totalTests - passedTests`, car le champ Azure `failedTests` est nul sur ces runs. Les quatre CSV d'erreurs contiennent exactement un enregistrement par TestCase en échec et totalisent également 132 lignes ; ils confirment 90 échecs Fix et 42 échecs Cur.

Les contenus LegacyServices inclus dans les deux artefacts WebServices sont byte-identiques aux 90 fichiers des artefacts LegacyServices correspondants. Ils ont été exclus du comptage.

## Packages réellement déployés

| Package | Cur | Fix |
|---|---|---|
| Y2.Core | 25.0.0.3553 | 25.0.0.2925 |
| Y2.Core.Common | 25.0.4.406 | 25.0.4.364 |
| Y2.Core.AuthenticationServer | 2.0.0.368 | 2.0.0.368 |
| Y2.Plugin.Identity | 25.0.6.171 | 25.0.5.444 |
| Y2.Plugin.FrenchTaxesRules | 25.0.9.24 | 25.0.9.24 |

Le fichier `Tests/Config/v25-fix.cy2px` du commit du build épingle les versions Fix ci-dessus. `Tests/Config/Readme.md` définit Fix comme le produit courant sur les dépendances minimales supportées et Cur comme le produit courant sur les dépendances courantes.

## Couverture exacte des 132 premières fautes

| Signature causale ou première signature | Nombre | Couverture |
|---|---:|---|
| Fix — mise à jour d'un paramètre NF525 sur zéro ligne | 70 | Run 26, Export 2, DocumentSignature 1, WebServices 41 |
| Fix — conséquence du même paramétrage absent | 13 | Run B-XQuery 4, Export B-XQuery 2 et PostQuery 5, DocumentSignature B-XQuery 2 |
| Fix — Export TC09, doublon laissé par la date mal convertie de TC08 | 1 | `A-PreQuery3` |
| Cur et Fix — état post-appel `DailyRegisterClosing` différent de l'attendu | 12 | les mêmes TC15, TC21 et TC23 à TC26 dans chaque variante |
| Cur — loi France inactive au démarrage de `FrenchTaxesRules:Run` | 21 | B-XQuery, code métier CBR_062_0031 |
| Cur — Export TC08 à TC10, date convertie puis cascades | 3 | PostQuery1, A-PreQuery3, PostQuery2 |
| Cur Web — fixture de clôture jugée incohérente | 8 | B-XQuery des TC05 à TC08, TC10, TC11, TC20 et TC21 |
| Cur Web — ligne PIEDBASE attendue mais absente | 1 | ValidateClosingsV2 TC09, `A-PreQuery3` |
| Cur Web — TC99 actifs avec période invalide | 2 | ValidateClosingsV2 et ValidateDocuments, HTTP 500 / CBR_062_0005 |
| Cur Web — événement de journal attendu mais absent | 1 | ExportNf525 TC30, `C-PostQuery7` |
| **Total** | **132** | **aucun cas non classé** |

La ligne Fix Export TC09 a deux défauts : sa première faute est le doublon causé par TC08, puis son appel métier reste lui aussi bloqué par le paramétrage NF525 absent. Elle n'est comptée qu'une fois dans le total.

## Cause A — dépendances minimales Fix incompatibles avec les fixtures

### Faits

- Soixante-dix premières fautes sont des `UPDATE PARAMSOC ... SELECT @@ROWCOUNT` qui renvoient zéro ligne.
- Les paramètres visés sont `SO_NF525DATEACTIVATION`, `SO_NF525ACTIF` et `SO_NF525VERSIONLS`.
- Les 41 tests Web Fix s'arrêtent tous sur ce prérequis avant l'appel métier.
- Les quatre appels `FrenchTaxesRules:Run` dont la première faute est B-XQuery et les appels Export correspondants retournent CBR_062_0031, c'est-à-dire une loi France inactive ou une date d'activation invalide.
- DocumentSignature TC07 reçoit `-2.3` au lieu de `1.0-2.3`; TC08 et TC09 reçoivent un numéro fiscal vide. La signature est néanmoins non vide et sa version est bien `S20`. La partie commune manquante est la valeur attendue de `SO_NF525VERSIONLS`.
- Les logs de déploiement Cur contiennent des scripts NF525 plus récents qui ne sont pas présents dans le lot Fix. Ils ne suffisent toutefois pas à dater précisément l'introduction de chacune des trois lignes.

### Conclusion

**INFERENCE FORTE — configuration/données de scénario, pas convertisseur JMeter.** La combinaison Fix épingle des dépendances minimales qui n'initialisent pas les lignes supposées par les tests. Le contrat doit être clarifié : soit ces dépendances ne sont plus supportées et `v25-fix.cy2px` doit être relevé, soit les scénarios doivent créer explicitement les paramètres manquants.

### Test discriminant et propriétaire

Sur deux déploiements propres Cur et Fix, lire uniquement l'existence et la valeur des trois `SOC_NOM`, avant toute campagne. Si Fix doit rester supporté, rendre la fixture autonome par création/restauration explicite et invalidation du cache. Propriétaire initial : dépôt FrenchTaxesRules pour la configuration et les données de test, avec décision de compatibilité côté produit/déploiement.

## Cause B — état initial non maîtrisé dans `FrenchTaxesRules:Run` Cur

### Faits

- Vingt-et-un cas Cur échouent avec CBR_062_0031.
- Le code produit lit d'abord `SO_NF525ACTIF`; il retourne immédiatement faux quand le paramètre est inactif, avant de vérifier la date d'activation.
- Plusieurs mises à jour de date réussissent dans ces tests : la répétition de CBR_062_0031 ne vient donc pas d'une conversion de ces valeurs numériques.
- TC42 échoue encore, TC50 et TC51 passent, puis TC53 à TC57 passent.
- TC50 force `SO_NF525ACTIF='-'` puis sa finalisation le remet à `X`. Le plan répare donc son prérequis au milieu de la campagne.

### Conclusion

**FACT — scénario dépendant de l'ordre et de l'état de la base.** Les cas antérieurs à TC50 supposent l'activation sans l'établir. Le correctif appartient au scénario FrenchTaxesRules : initialiser l'activation au démarrage ou rendre chaque cas autonome, puis invalider le cache de paramètres.

Rejeu minimal : base propre, TC10 seul avant et après activation explicite, puis TC53 seul.

## Cause C — conversion de dates ISO dans Export V25

### Faits

Les sources legacy du parent du commit et le JMX généré montrent les mêmes inversions qu'en V26 :

- TC08 : `'2016-01-03'` devient `'20160301'` ;
- TC08 : `'2015-12-01'` devient `'20150112'` ;
- TC09 : `'2016-02-01'` devient `'20160102'`.

Les requêtes de nettoyage restent au format attendu. En Cur, TC08 ne produit pas les deux lignes attendues, TC09 rencontre ensuite le doublon laissé par TC08 et TC10 compte une ligne résiduelle. En Fix, TC09 rencontre le même doublon ; le paramétrage NF525 absent masque en plus le comportement métier.

### Conclusion

**FACT — défaut de l'outil de migration.** La chaîne propriétaire reste : corriger et versionner `Y2_Tools_AutoTest_Api`, mettre à jour et republier `Y2_Tools_AutoTest_Console`, puis mettre à jour `Migration_Jmeter_RJE_Sandbox`. Régénérer au minimum Export V25 et rejouer TC08 à TC10 sur une base propre.

## Groupe D — `DailyRegisterClosing`, verdict borné

Les mêmes six cas échouent en Cur et Fix. L'appel HTTP répond 200 et le métier retourne `Status=true`, mais les lignes CLOSING/CLOSINGTAX attendues sont absentes ou différentes. Les attentes JMX correspondent aux sources legacy et aucune inversion de date comparable à Export n'a été trouvée.

**UNKNOWN — produit ou scénario obsolète.** Le build legacy `4429632` fournit une preuve de 82 tests MSTest passés (`6178203`), mais aucune correspondance démontrée entre ces méthodes/fixtures et cette campagne JMeter d'intégration.

Test discriminant : exécuter TC15 ou TC23 avec le runner legacy et JMeter sur le même jeu de packages et deux bases propres équivalentes, puis capturer CLOSING/CLOSINGTAX immédiatement après l'appel, avant le nettoyage. Propriétaire initial : équipe FrenchTaxesRules scénario/produit.

## Groupe E — WebServices Cur

### Fixture `ValidateClosingsV2`

Huit premières fautes B-XQuery, plus la réponse de TC09, contiennent la même clôture 020 du 2014-05-23 jugée `IncoherentClosure`. Chaque cas la recrée dans ses prérequis ; ce n'est pas un résidu d'un test précédent. Les totaux réels valent systématiquement l'attendu plus un pour TC05 à TC11, TC20 et TC21. TC06 contient une seconde clôture incohérente propre à ce cas.

**INFERENCE FORTE — fixture de clôture devenue incompatible avec la validation produit.** Il faut rejouer TC05 seul sur une base propre et comparer la règle qui invalide cette clôture à la signature et aux montants de la fixture. Propriétaire : scénario et code de validation FrenchTaxesRules. Sans baseline legacy comparable, le partage précis entre scénario obsolète et régression produit reste UNKNOWN.

### TC09

`A-PreQuery3` tente de modifier une ligne PIEDBASE `FFO/206/3` et obtient zéro ligne. Les fautes suivantes sont des cascades. **Cause probable : baseline de données incomplète ou scénario non autonome.** Vérifier l'existence de la pièce après un déploiement propre, puis la créer dans la fixture si elle est un prérequis contractuel.

### TC99

Les TC99 de ValidateClosingsV2 et ValidateDocuments sont actifs. Ils appellent le service avec une période invalide, n'ont pas d'assertion métier adaptée et reçoivent HTTP 500 / CBR_062_0005. **FACT — défaut de scénario**, identique à la famille déjà observée en V26.

### ExportNf525 TC30

L'appel métier et les six premières postconditions passent. Seule la recherche de l'événement JOURNALEVENT `ADM/PLA/W05` attendu retourne zéro ligne. **UNKNOWN — journalisation produit modifiée ou attente obsolète.** Rejouer TC30 seul et vérifier le journal écrit par le service avant nettoyage ; propriétaire initial : scénario/produit FrenchTaxesRules.

## Limite de preuve générale

Aucun run legacy ne fournit une correspondance démontrée avec les mêmes cas JMeter, packages et base équivalente. Les TRX legacy existent et ont été analysés ; ils apportent une preuve MSTest, mais pas une baseline cas à cas pour cette campagne. Les causes liées au convertisseur, aux paramètres absents, à l'ordre de `FrenchTaxesRules:Run` et aux TC99 sont démontrées par les artefacts et le code. Les divergences de données métier restent volontairement classées comme causes probables ou UNKNOWN avec un rejeu discriminant explicite.

Preuve complémentaire du 2026-09-06 : les trois exécutions locales listées dans `../evidence/legacy/curated/02_FRENCH_TAXES_RULES/V7.md` (`test.9.17`, `.19`, `.20`) démarrent le workflow puis s'arrêtent avant tout lancement MSTest, avec le message factuel que `override\Y2_Plugins_FrenchTaxesRules_V7` n'existe pas. Elles exécutent donc zéro scénario et ne constituent pas une baseline V25. Elles ne correspondent pas non plus à l'itération `test.9.25-20260903_041353` soumise sous la corrélation `66`, dont le résultat aval reste `UNKNOWN`.
