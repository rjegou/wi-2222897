# WI-2222897 — Investigation écarts JMeter / Legacy
## Handoff technique — 2026-09-07

## 1. Objectif

Ce document synthétise les travaux réalisés autour des écarts entre tests Legacy et JMeter, avec un focus sur les corrections du générateur `Y2_Tools_AutoTest_Api`, leur propagation dans le packaging Console, et leur validation réelle avec Apache JMeter 5.6.3.

Il distingue autant que possible :

- **FACT** : démontré par une preuve reproductible.
- **INFERENCE** : conclusion raisonnable, mais non encore démontrée de bout en bout.
- **UNKNOWN** : point restant à investiguer.

---

## 2. État général de l'investigation

### Accès techniques

**FACT**

- Azure DevOps CLI/token : accès fonctionnel au projet `Retail`.
- JFrog Artifactory : token validé via `/artifactory/api/system/ping`.
- Il est donc possible de poursuivre l'investigation avec :
  - lectures ADO ;
  - inspection des builds ;
  - récupération de packages ;
  - et, si nécessaire, exécution de vrais pipelines Azure DevOps.

### Règle de sécurité retenue

Les vrais pipelines ADO peuvent être lancés uniquement lorsque cela apporte une preuve utile et avec un impact sur les collègues réduit au minimum.

Avant tout run réel, vérifier notamment :

- la cible exacte ;
- l'environnement ;
- les écritures externes possibles ;
- les versions de package ;
- les hôtes/VM utilisés ;
- les opérations SQL/IIS/déploiement ;
- les promotions/tags/push JFrog ;
- la possibilité d'utiliser un pipeline ou job isolé.

---

## 3. Correctif SOAP / XPath namespace-aware

### 3.1 Problème initial

Le générateur produisait historiquement des XPath de type :

```text
//Fault/detail/faultcode
```

ou des variantes dérivées de :

```text
/soap:Fault/detail/faultcode
```

Le comportement n'était pas robuste avec les namespaces XML SOAP.

### 3.2 Validation avec le vrai JMeter 5.6.3

**FACT**

Un Apache JMeter 5.6.3 officiel a été récupéré et vérifié par SHA512.

Tests réalisés avec le vrai moteur XPath JMeter :

- `namespace=false` + `//Fault`
  - ne matche pas un `soap:Fault` préfixé ;
  - matche un `Fault` sans namespace.

- `namespace=true` + XPath tenant compte du namespace SOAP
  - matche correctement un SOAP Fault quelle que soit la valeur du préfixe XML ;
  - rejette un Fault dans un mauvais namespace ;
  - rejette l'absence de Fault.

Conclusion :

> une simple suppression du préfixe `soap:` n'est pas sémantiquement suffisante.

### 3.3 Correctif retenu

Le correctif final génère :

```xpath
//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode
```

avec :

```xml
<boolProp name="XPath.namespace">true</boolProp>
```

### 3.4 Build local final

**FACT**

La DLL finale utilisée pour cette validation a le SHA256 :

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B
```

Elle provient du worktree :

```text
worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE
```

Le build net452 a réussi avec 0 warning / 0 erreur.

### 3.5 Validation positive

**FACT**

La chaîne suivante est prouvée :

```text
DLL finale 57BE...
    ↓
package Console local
    ↓
sélection/extraction du package
    ↓
runtime Console packagé
    ↓
génération d'un JMX
    ↓
XPath SOAP namespace-aware
    ↓
exécution réelle JMeter 5.6.3
    ↓
PASS
```

Le package local a été réellement extrait et la DLL contenue dans le runtime packagé correspond exactement au SHA256 `57BE...`.

Le JMX généré utilise bien le XPath namespace-aware.

### 3.6 Validation négative

Une lacune restait sur le cas :

```xml
<ExpectedValue>0</ExpectedValue>
```

qui doit produire :

```xml
<XPath.negate>true</XPath.negate>
```

#### Difficulté rencontrée

Le premier fixture utilisé était un `OutputControl`.

Or le générateur ne traite pas un `OutputControl` via `XPathJmeter`.

Pour un `OutputControl`, il passe par :

```text
XPathExtractor
+
XmlComparator
```

Alors qu'un `Control` XPath ordinaire passe bien par :

```text
XPathJmeter
```

C'était la raison pour laquelle le contrôle SOAP avait disparu du JMX lors du premier essai négatif.

#### Fixture corrigé

Un vrai `Control` ordinaire a été créé :

```xml
<Control Id="5130f6d3-875c-4d68-99cc-98e462f88d7b">
  <Label>compare full xml</Label>
  <Query>/soap:Fault/detail/faultcode</Query>
  <ExpectedValue>0</ExpectedValue>
</Control>
```

### 3.7 Génération négative réelle

**FACT**

Avec la DLL finale `57BE...`, le générateur a produit :

```xml
<boolProp name="XPath.negate">true</boolProp>
<stringProp name="XPath.xpath">//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode</stringProp>
<boolProp name="XPath.namespace">true</boolProp>
```

Le processus de génération a terminé avec :

```text
DIAGNOSTIC EXIT CODE: 0
```

### 3.8 Exécution négative avec JMeter 5.6.3

Un harness local a ensuite exécuté exactement cette sémantique.

Résultat final :

```text
FAULT_PRESENT      => false
NO_FAULT           => true
WRONG_NAMESPACE    => true

EXECUTION_POSTCONDITION=PASS
```

Message JMeter lorsque le Fault est présent :

```text
Specified XPath was found... Turn off negate if this is not desired
```

### 3.9 Conclusion SOAP

**FACT**

Le correctif SOAP est validé de bout en bout pour SOAP 1.1 :

```text
source generator
→ DLL finale
→ package Console
→ extraction/runtime
→ génération JMX
→ XPath namespace-aware
→ assertion positive
→ assertion négative
→ vrai Apache JMeter 5.6.3
```

La validation couvre :

- préfixe SOAP variable ;
- namespace SOAP 1.1 correct ;
- absence de Fault ;
- mauvais namespace ;
- assertion positive ;
- assertion négative.

### Limite connue

**UNKNOWN**

Aucun contrat SOAP 1.2 n'a été démontré.

Ne pas généraliser automatiquement le correctif à :

```text
http://www.w3.org/2003/05/soap-envelope
```

sans preuve sur les tests Legacy concernés.

---

## 4. Packaging Console / propagation

### 4.1 Versions connues

Le mécanisme de migration utilise notamment :

```text
Console  : 2.0.41
Workflow : 3.0.175
```

Une version Console locale de test :

```text
2.0.42-soapnamespace.20260907
```

a été utilisée pendant les validations.

### 4.2 Preuve de sélection du package

**FACT**

`checkPackage` a confirmé la sélection du package local :

```text
Package Cegid.Retail.AutoTest.Console 2.0.42-soapnamespace.20260907 consigne...
Bonne version deja installee
```

La DLL `Cegid.Retail.AutoTest.Api.dll` extraite du package a exactement le SHA256 :

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B
```

### 4.3 Wrapper diagnostic

Le petit wrapper utilisé autour de la Console est :

```csharp
using System;

internal static class PackagedConsoleDiagnostic
{
    private static int Main(string[] args)
    {
        try
        {
            new Cegid.Retail.AutoTest.Console.Launcher().ExecuteTest(args);
            return 0;
        }
        catch (Exception exception)
        {
            Console.WriteLine(exception);
            return 1;
        }
        finally
        {
            foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                if (assembly.GetName().Name == "Cegid.Retail.AutoTest.Api")
                    Console.WriteLine("LOADED_API=" + assembly.Location);
            }
        }
    }
}
```

Il ne contourne pas la Console :

> il appelle exactement `Launcher().ExecuteTest(args)`.

Son intérêt principal est de laisser remonter l'exception complète et d'afficher la DLL API réellement chargée.

---

## 5. Leçons apprises pendant la validation

### 5.1 Ne jamais considérer l'existence d'un JMX comme une preuve de succès

Le générateur peut créer ou commencer à écrire un JMX avant de lever une exception.

Exemple rencontré :

```text
DIAGNOSTIC EXIT CODE: 1
JMX EXISTS AFTER RUN: True
```

avec ensuite :

```text
DirectoryNotFoundException
```

ou :

```text
OutputFile not found
```

Règle :

> un JMX généré n'est valide comme preuve que si le processus complet se termine correctement.

---

### 5.2 Ne pas réutiliser un output préexistant pour conclure

Un premier essai avait copié le JMX positif du round précédent dans le nouveau dossier.

Le hash était identique :

```text
DDDFAB27...
```

Le fichier observé était donc un artefact stale et non une nouvelle génération.

Règle :

> supprimer explicitement le JMX cible avant chaque test de génération et vérifier `JMX EXISTS BEFORE RUN: False`.

---

### 5.3 Les chemins Windows longs peuvent fausser le diagnostic

La compilation du wrapper dans le chemin OneDrive très long a produit :

```text
CS0006 metadata file ... not found
```

alors que le fichier existait.

En staging court :

```text
C:\Temp\wi2222897-neg
```

la compilation a réussi immédiatement.

Règle :

> pour les anciens outils .NET Framework / `csc.exe`, préférer un staging très court pour éviter les problèmes `MAX_PATH`.

---

### 5.4 Le type XML du contrôle est essentiel

`Control` et `OutputControl` suivent des branches différentes du générateur.

Pour un `OutputControl` :

```text
XPathExtractor
→ XmlComparator
```

Pour un contrôle XPath ordinaire :

```text
XPathJmeter
```

Un test de `XPath.negate` doit donc utiliser un `Control`, pas un `OutputControl`.

---

### 5.5 `ExpectedValue=0` est bien la convention de négation

Dans `XPathJmeter` :

```csharp
var invertAssertion = query.ExpectedValue == 0 ? "true" : "false";
```

Donc :

```text
ExpectedValue = 0
→ XPath.negate = true
```

Cette convention a maintenant été confirmée à la fois :

- dans le code ;
- dans le JMX généré ;
- et dans JMeter 5.6.3.

---

### 5.6 Un exit code JMeter 0 ne signifie pas que toutes les assertions sont vertes

JMeter peut terminer correctement avec :

```text
JMETER EXIT CODE: 0
```

tout en contenant des samples en échec.

Il faut inspecter le JTL / les champs :

```text
label
success
failureMessage
```

et vérifier les postconditions métier du test.

---

### 5.7 Le premier harness JMeter était lui-même faux

Le premier script Groovy utilisait :

```groovy
prev.setResponseData(...)
```

Dans un `JSR223Sampler`, `prev` peut être `null`.

Résultat :

```text
Response was null
```

sur tous les tests.

La correction a consisté à utiliser :

```groovy
SampleResult.setResponseData(...)
SampleResult.setResponseCode(...)
SampleResult.setSuccessful(...)
```

Après cette correction, les trois postconditions XPath ont été validées.

Règle :

> toujours distinguer un échec du système testé d'un échec du harness de test.

---

### 5.8 Les fixtures doivent être complets

La génération JMeter dépend de fichiers externes présents sous :

```text
TestPlans/InputFiles
```

et parfois de :

```text
OutputFiles
```

Les erreurs rencontrées incluent :

```text
ItemKeywords_01.xml missing
ItemKeywords_02.xml missing
GetKeywords_02.xml missing
```

Les vrais `ItemKeywords_01.xml` et `_02.xml` ont été retrouvés dans Clienteling.

Leur contenu est identique entre :

- master ;
- V6 ;
- V7 ;
- worktree local.

Les hashes sont :

```text
ItemKeywords_01.xml
47F7D4E69965ADABD350B83B1BAE0BC48ABAA11F25751110FEE0FDC6FE6978C8

ItemKeywords_02.xml
55ABCBC44528624DE89D1BBF441A1CF53C816E5AE2D3A75D57DED95074C37408
```

---

## 6. Autres corrections du générateur

Trois familles principales ont été identifiées :

1. `EscapeJdbcDate`
2. `FixSqlUnicodeValue`
3. SOAP / XPath namespace-aware

### 6.1 EscapeJdbcDate

Problème identifié :

```text
yyyy-mm-dd
```

pouvait être transformé dans un ordre incorrect.

Correction visée :

```text
${1}${3}${2}
→
${1}${2}${3}
```

### 6.2 FixSqlUnicodeValue

Un défaut réel a été reproduit sur un littéral SQL Unicode contenant une apostrophe SQL échappée.

Ancien comportement observé :

```text
SELECT ... 'NN''é' ...
```

pouvait devenir :

```text
SELECT ... 'NN'N'é' ...
```

Une DLL dédiée au correctif a produit le résultat attendu.

SHA256 de cette DLL dédiée :

```text
22D85CAA8CA61F30EFADBD611BB584042575A64EB2D78ED3A3637EF1D02D81CC
```

### Point restant critique

**UNKNOWN**

Il faut maintenant vérifier si la DLL finale :

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B
```

embarque réellement aussi :

- le correctif `FixSqlUnicodeValue` ;
- le correctif `EscapeJdbcDate`.

Le nom du worktree suggère au moins `EscapeJdbcDate`, mais cela ne doit pas être considéré comme une preuve.

---

## 7. Actions futures recommandées

### Priorité 1 — Vérifier la consolidation des trois corrections dans `57BE...`

Exécuter des vecteurs contrôlés directement contre la DLL finale :

#### EscapeJdbcDate

Entrée contrôlée contenant :

```text
yyyy-mm-dd
```

Vérifier la transformation attendue.

#### FixSqlUnicodeValue

Entrée contrôlée contenant :

```sql
SELECT ... 'NN''é' ...
```

Vérifier que la sortie reste correctement échappée.

Objectif :

> déterminer si `57BE...` constitue déjà la DLL consolidée finale.

---

### Priorité 2 — Prouver la propagation package pour les correctifs SQL/date

Si `57BE...` contient bien les trois corrections :

```text
DLL finale
→ package Console
→ extraction
→ génération réelle JMX
→ inspection des expressions générées
```

Ne pas se limiter à appeler les méthodes unitaires de la DLL.

Il faut idéalement démontrer les transformations à travers le même chemin réel de migration que SOAP.

---

### Priorité 3 — Canonicaliser les preuves manuelles

Les travaux réalisés après l'arrêt de `brain-worker` doivent être intégrés dans l'état canonique de l'investigation.

À documenter au minimum :

- package final `57BE...`;
- validation positive SOAP ;
- validation négative SOAP ;
- harness JMeter 5.6.3 ;
- hashes ;
- fixtures ;
- logs ;
- distinction `Control` / `OutputControl`;
- erreurs de staging rencontrées ;
- résultat final `EXECUTION_POSTCONDITION=PASS`.

Créer un README/HANDOFF dans les dossiers d'evidence concernés si nécessaire.

---

### Priorité 4 — Revenir sur les écarts réels de plugins

Une fois le générateur consolidé, reprendre les branches présentant encore des écarts Legacy/JMeter.

Exemple important :

```text
Y2_Plugins_FrenchTaxesRules
releases/V5
v23
cur : 0 fail
fix : failJob InitializeContainers
```

Ce cas est structurellement différent d'un simple écart de résultat de test.

Il faut distinguer :

```text
test failures
≠
pipeline/job infrastructure failure
```

---

### Priorité 5 — Tester l'hypothèse de Ludo sur les versions Fix

Hypothèse communiquée :

> lorsqu'il y a 0 fail sur `cur` et des fails sur `fix`, le problème peut venir d'un mauvais packaging/version Fix ; prendre une version provenant d'un packaging supérieur pourrait corriger le problème.

Statut :

**INFERENCE / HYPOTHÈSE NON VALIDÉE**

Actions suggérées :

1. identifier exactement le package/version Fix utilisé dans un cas défaillant ;
2. identifier le package utilisé par une version supérieure connue comme saine ;
3. comparer provenance, build, version et contenu ;
4. reproduire avec une version corrigée dans un environnement à faible impact ;
5. vérifier si l'écart disparaît.

---

### Priorité 6 — Exploiter désormais les accès ADO/JFrog fonctionnels

Les blocages précédents d'accès ne sont plus valides.

Il est maintenant possible de :

- interroger les builds ;
- inspecter les artifacts ;
- identifier les packages réellement consommés ;
- comparer cur/fix ;
- inspecter `InitializeContainers`;
- et, lorsque justifié, lancer un pipeline réel isolé.

---

## 8. Recommandations pour les futurs runs Azure DevOps

Avant de lancer un pipeline :

### Vérifier

- definition id ;
- branche ;
- commit ;
- version ;
- artefacts ;
- environnement ;
- machine cible ;
- jobs réellement activés ;
- étapes de promotion ;
- push JFrog ;
- Docker push ;
- tags sources ;
- déploiement ;
- SQL ;
- IIS ;
- appels réseau ;
- secrets utilisés.

### Préférer

- une branche de test dédiée ;
- un YAML dont les effets externes sont désactivés ;
- un job unique ;
- une cible dédiée ;
- une exécution reproductible ;
- une preuve récupérable dans les artifacts/logs.

### Éviter

- les environnements partagés ;
- les écritures sur des ressources utilisées par les collègues ;
- les promotions ;
- les tags ;
- les publications non nécessaires ;
- les modifications permanentes de configuration.

---

## 9. Pipelines connus

### Y2 Tools Jmeter Workflow

Definition :

```text
5224
```

Repo :

```text
Y2_Tools_Jmeter_Workflow
```

Branche :

```text
master
```

YAML :

```text
azure-pipeline.yml
```

Le pipeline master contient potentiellement :

- Build ;
- Docker ;
- Promote ;
- Tag_Sources ;
- JFrog / BuildInfo ;
- publication/promotion.

Une variante `tests_rje` a été identifiée avec plusieurs effets externes désactivés, mais les jobs de tests restent capables de modifier des ressources externes.

---

## 10. Cas réels à reprendre

### FrenchTaxesRules

Exemples déjà identifiés :

```text
Y2_Plugins_FrenchTaxesRules master V26
```

Builds observés :

```text
4426342
4432510
```

Le build 4432510 a fourni une preuve utile :

- SOAP 1.1 ;
- `detail` et `faultcode` non namespacés.

Cela soutient le XPath retenu :

```xpath
//*[local-name()='Fault' and namespace-uri()='http://schemas.xmlsoap.org/soap/envelope/']/detail/faultcode
```

### releases/V5

Cas à investiguer :

```text
v23
cur : 0 fail
fix : failJob InitializeContainers
```

La priorité est de déterminer si le défaut vient :

- du packaging Fix ;
- de la version consommée ;
- d'un problème de container initialization ;
- d'un artifact manquant ;
- ou d'une différence d'infrastructure.

---

## 11. Inventaire SOAP utile

Une analyse antérieure a trouvé environ :

```text
377 JMX contenant Fault
```

dont environ :

```text
40 avec XPath.negate=true
```

et aucun avec :

```text
XPath.namespace=true
```

dans l'ancien état.

Cela montre que le comportement namespace-aware constitue une modification importante du générateur et justifie les validations réelles réalisées.

---

## 12. État de confiance actuel

| Sujet | Statut | Confiance |
|---|---|---|
| Problème SOAP préfixé / namespace | démontré | très élevée |
| Correctif XPath namespace-aware | démontré | très élevée |
| Build DLL finale | démontré | très élevée |
| Package contenant la DLL finale | démontré | très élevée |
| Extraction/sélection du package | démontré | très élevée |
| Génération JMX positive | démontré | très élevée |
| Exécution JMeter positive | démontré | très élevée |
| Génération SOAP négative | démontré | très élevée |
| Exécution SOAP négative | démontré | très élevée |
| SOAP 1.2 | non démontré | faible |
| EscapeJdbcDate dans DLL 57BE | à vérifier | inconnue |
| FixSqlUnicodeValue dans DLL 57BE | à vérifier | inconnue |
| Propagation package SQL/date | à prouver | inconnue |
| Hypothèse packaging supérieur de Ludo | à tester | moyenne/faible |
| Cause releases/V5 InitializeContainers | à investiguer | inconnue |

---

## 13. Prochaine séquence recommandée

Ordre conseillé :

```text
1. Vérifier EscapeJdbcDate dans DLL 57BE
2. Vérifier FixSqlUnicodeValue dans DLL 57BE
3. Si les deux sont présents : prouver leur propagation package/génération
4. Canonicaliser les nouvelles preuves dans HANDOFF/README
5. Reprendre les vrais écarts plugin
6. Investiguer releases/V5 / InitializeContainers
7. Vérifier la provenance/version Fix
8. Tester l'hypothèse de Ludo
9. Lancer un vrai pipeline ADO uniquement si nécessaire et à faible impact
```

---

## 14. Commande suggérée pour reprendre avec brain-worker

Depuis la racine WI-2222897 :

```powershell
bw "reprends l'investigation des écarts JMeter/legacy en cours dans WI-2222897 et avance au maximum à partir de l'état canonique existant et des nouvelles preuves acquises depuis le dernier run. Les accès Azure DevOps et JFrog sont désormais fonctionnels. Tu peux lancer de vrais pipelines Azure DevOps si cela est utile, à condition de limiter au maximum tout impact sur le travail des collègues. Réconcilie les preuves locales produites pendant l'interruption avec l'état canonique. Arrête-toi uniquement lorsqu'aucune piste utile ne peut continuer sans risque significatif ou prérequis extérieur bloquant." "." "30"
```

L'objectif volontairement reste général : le brain dispose de davantage de contexte global et doit pouvoir choisir lui-même la meilleure prochaine piste.

---

## 15. Conclusion

La principale avancée depuis le dernier arrêt de `brain-worker` est la fermeture complète de la piste SOAP.

Le correctif namespace-aware n'est plus seulement une hypothèse de code :

```text
il est compilé,
packagé,
chargé depuis le package,
utilisé par la Console,
présent dans le JMX généré,
et validé par le vrai JMeter 5.6.3,
en assertion positive comme négative.
```

Le prochain enjeu n'est donc plus SOAP.

Le point de décision immédiat est de savoir si la DLL finale `57BE...` constitue déjà le **build consolidé des corrections SOAP + EscapeJdbcDate + FixSqlUnicodeValue**. Ce résultat déterminera s'il faut encore produire un package final consolidé ou si l'investigation peut passer directement aux écarts réels observés dans les pipelines/plugins.
