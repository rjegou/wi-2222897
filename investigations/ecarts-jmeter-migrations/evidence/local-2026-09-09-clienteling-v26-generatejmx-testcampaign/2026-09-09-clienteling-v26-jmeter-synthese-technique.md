# WI-2222897 — Clienteling V26 — Synthèse technique et leçons apprises

## 1. Objectif de la séquence

L’objectif de cette séquence était de faire progresser le **replay isolé Clienteling V26** jusqu’à l’exécution réelle des tests JMeter, en éliminant méthodiquement les blocages de pipeline et de génération JMX.

Contexte principal :

- Définition Azure DevOps isolée : **14264 — WI-2222897 Clienteling Isolated Replay**
- Branche : `sandbox/clienteling/wi2222897-isolated-replay`
- API build de référence : `4444962`
- Console build de référence : `4445025`
- Console definition : `2641`
- Replay isolé lancé via REST avec `templateParameters`

---

## 2. Blocages corrigés avant la génération JMX

### 2.1. `Product.Version` manquant

Le pipeline isolé n’héritait pas de la variable utilisée historiquement par le pipeline Clienteling.

Valeur rétablie :

```yaml
Product.Version: '26.0.10.23'
```

Cela a permis de passer l’étape **Black Marble Version Assemblies**.

### 2.2. `BuildPlatform` manquant

Le build suivant a échoué sur :

```text
solution configuration "Release|$(BuildPlatform)" invalid
```

Le pipeline historique définissait :

```yaml
BuildPlatform: 'any cpu'
```

Cette variable a été ajoutée au pipeline isolé.

Résultat : le pipeline a enfin atteint **GenerateJmx**.

---

## 3. Premier blocage GenerateJmx : ressources `OutputFiles` absentes

Premier échec observé :

```text
System.IO.DirectoryNotFoundException:
Could not find a part of the path
...\Deployment_ResetFTSCustomer\TestPlans\OutputFiles
```

L’inspection de l’artefact `migration` du build `4449477` a montré qu’il ne contenait que :

```text
IntegratedTests/AutoTest/Data/WebServices/TestPlans/Deployment_ResetFTSCustomer.xml
```

Aucun `OutputFiles` n’était embarqué.

### Cause identifiée

Le script :

```text
ci/wi2222897/scripts/New-Wi2222897MigrationManifest.ps1
```

ne copiait que le XML principal :

```powershell
Copy-Item -LiteralPath $source -Destination $dest -Force
```

Les ressources référencées par les plans (`InputFiles`, `ExpectedOutput`) n’étaient pas intégrées à l’artefact.

### Vérification des ressources source

Les trois campagnes ciblées ont été inspectées :

- `Deployment_ResetFTSCustomer.xml`
- `Mobility_GetClientelingParameters.xml`
- `Image_GetSerialNumberImage.xml`

Toutes les ressources référencées existent dans le dépôt :

```text
Deployment_ResetFTSCustomer.xml
REFS    : 1
MISSING : 0

Mobility_GetClientelingParameters.xml
REFS    : 11
MISSING : 0

Image_GetSerialNumberImage.xml
REFS    : 18
MISSING : 0
```

Conclusion : le dépôt est cohérent ; le défaut venait uniquement du **staging de migration**.

---

## 4. Premier correctif de staging

Deux scripts ont été modifiés :

```text
New-Wi2222897MigrationManifest.ps1
Invoke-Wi2222897JmxRegeneration.ps1
```

Objectif du correctif :

- embarquer les ressources réellement référencées ;
- pré-positionner les `OutputFiles` attendus par le générateur.

Push Azure DevOps :

```text
OLD HEAD : 20aac8f5a8fc5e27fc56ef37217b934aff578949
NEW HEAD : 8cc14f2f8b83ea642a021e0e2ba8b872ab95c664
PUSH ID  : 5138407
FILES    : 2
```

Replay lancé :

```text
Build ID : 4449640
Run      : wi2222897-clienteling-isolated-20260909.9
Commit   : 8cc14f2f8b83ea642a021e0e2ba8b872ab95c664
```

---

## 5. Deuxième blocage GenerateJmx : mauvais type de XML fourni à la Console

Le nouveau run a progressé plus loin mais a échoué sur :

```text
<TestPlan xmlns='TestAutomation'> was not expected
```

Erreur complète :

```text
System.InvalidOperationException:
There is an error in XML document (2, 2).

<TestPlan xmlns='TestAutomation'> was not expected.
```

### Cause identifiée

Le script appelait directement :

```powershell
Cegid.Retail.AutoTest.Console.exe --tstj=<TestPlan.xml>
```

Or `--tstj` attend un **TestCampaign**, pas un `TestPlan`.

Le générateur doit recevoir un wrapper de cette forme :

```xml
<?xml version="1.0" encoding="utf-8"?>
<TestCampaign
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    Code="Closing_AnnualClosing"
    Comment="WI-2222897 isolated generation"
    Categories=""
    xmlns="TestAutomation">
  <TestPlanItem item="TestPlans\Closing_AnnualClosing.xml" />
</TestCampaign>
```

Cette structure a été retrouvée dans les preuves locales d’une génération JMX fonctionnelle.

---

## 6. Contrat réel du générateur JMeter

La structure validée est de type :

```text
<campaignRoot>\
    Campaign.xml
    TestPlans\
        Plan.xml
        InputFiles\
        OutputFiles\
```

Le wrapper `TestCampaign` référence le plan via :

```xml
<TestPlanItem item="TestPlans\Plan.xml" />
```

La Console génère ensuite le JMX dans une arborescence de type :

```text
Tests\<Campaign>\
```

Il faut ensuite matérialiser le JMX généré au chemin attendu par le pipeline JMeter, par exemple :

```text
IntegratedTests/AutoTest/Data/WebServices/TestPlans/Deployment_ResetFTSCustomer.jmx
```

---

## 7. Correctif TestCampaign appliqué

Le script :

```text
ci/wi2222897/scripts/Invoke-Wi2222897JmxRegeneration.ps1
```

a été modifié pour :

1. créer une fixture temporaire canonique ;
2. copier le `TestPlan` dans `TestPlans\`;
3. copier ses `InputFiles` référencés ;
4. copier ses `ExpectedOutput` référencés ;
5. générer un wrapper `TestCampaign`;
6. appeler la Console avec `--tstj=<campaign.xml>`;
7. vérifier qu’un seul JMX est généré ;
8. recopier ce JMX au chemin exact consommé par le stage JMeter ;
9. calculer son SHA-256 ;
10. supprimer la fixture temporaire.

Push effectué :

```text
OLD HEAD : 8cc14f2f8b83ea642a021e0e2ba8b872ab95c664
NEW HEAD : 28f71268426de6f196c2f4672b526489819c6393
PUSH ID  : 5138712
FILES    : 1
```

---

## 8. État actuel

État à la fin de cette séquence :

```text
Branch : sandbox/clienteling/wi2222897-isolated-replay
HEAD   : 28f71268426de6f196c2f4672b526489819c6393
```

Les blocages déjà éliminés sont :

- `Product.Version`
- `BuildPlatform`
- absence de ressources référencées dans l’artefact migration
- invocation incorrecte de la Console avec un `TestPlan` au lieu d’un `TestCampaign`

Le prochain test doit relancer la définition **14264** avec les mêmes paramètres :

```text
apiBuildId          = 4444962
consoleBuildId      = 4445025
consoleDefinitionId = 2641
```

Le prochain objectif est de vérifier que :

1. `GenerateJmx` passe ;
2. les 3 JMX sont produits ;
3. le stage JMeter démarre réellement ;
4. les premiers résultats Cur/Fix sont obtenus.

---

## 9. Leçons techniques apprises

### 9.1. Reproduire le contrat réel du pipeline historique

Un pipeline isolé ne peut pas simplement reprendre quelques étapes : il faut restaurer explicitement les variables et conventions implicites du pipeline historique.

Exemples rencontrés :

```text
Product.Version
BuildPlatform
```

Ces omissions produisent des erreurs qui semblent liées au code alors qu’elles viennent uniquement du contexte de pipeline.

### 9.2. Ne pas confondre `TestPlan` et `TestCampaign`

Le paramètre Console :

```text
--tstj
```

attend un `TestCampaign`.

Lui fournir directement un `TestPlan` produit une erreur de désérialisation XML :

```text
<TestPlan ...> was not expected
```

La présence d’un XML techniquement valide ne signifie donc pas qu’il respecte le contrat métier attendu par la Console.

### 9.3. La migration JMX dépend de ressources annexes

Un plan n’est pas autonome.

La génération peut nécessiter :

```text
InputFiles
OutputFiles
```

Le manifeste de migration doit donc représenter **la dépendance fonctionnelle du plan**, pas seulement copier le XML racine.

### 9.4. Copier uniquement les dépendances réellement référencées

Le répertoire `OutputFiles` Clienteling contient un très grand nombre de fichiers.

Le bon compromis est de parser chaque plan et de copier uniquement :

- les attributs `TestCase/@Input`;
- les éléments `ExpectedOutput`.

Cela limite fortement la taille des artefacts et évite d’introduire des données sans rapport avec la campagne testée.

### 9.5. Une erreur plus loin dans le pipeline est souvent un progrès

La séquence des échecs a été :

```text
Version Assemblies
→ VSBuild
→ OutputFiles manquants
→ TestPlan fourni à la place de TestCampaign
```

Chaque nouveau blocage a confirmé que la couche précédente était désormais franchie.

Pour ce type de migration, il est plus utile de suivre **la profondeur maximale atteinte dans le pipeline** que de regarder seulement `Result=failed`.

### 9.6. Utiliser les preuves historiques avant de reconstruire un comportement

La bonne structure `TestCampaign` a finalement été retrouvée dans les artefacts locaux d’une génération déjà réussie.

Leçon : avant d’inventer une convention ou un wrapper, chercher :

```text
preuves de build
artefacts générés
scripts historiques
fixtures validées
```

Une preuve d’exécution réelle vaut mieux qu’une hypothèse tirée du nom d’une API.

### 9.7. Distinguer le pipeline isolé du pipeline Clienteling normal

Une exécution accidentelle de la CI Clienteling normale avait produit un bruit sans rapport avec le replay isolé, notamment autour de Git LFS.

Pour la suite, conserver une séparation stricte :

```text
Definition 14264 = replay WI-2222897 isolé
Definition 2065  = CI Clienteling normale
```

Ne pas corriger un problème observé dans `2065` lorsqu’on cherche à valider `14264`, sauf preuve qu’il est réellement partagé.

---

## 10. Méthode d’investigation qui a bien fonctionné

La méthode la plus efficace sur cette séquence a été :

```text
1. Reproduire un run exact
2. Identifier le premier task réellement bloquant
3. Inspecter l’artefact ou l’entrée exacte
4. Comparer avec une preuve historique fonctionnelle
5. Appliquer un patch minimal
6. Relancer sans changer d’autres paramètres
```

Cette approche évite les corrections spéculatives et permet d’attribuer chaque changement à une cause précise.

---

## 11. Prochaine étape recommandée

Relancer la définition Azure DevOps **14264** sur :

```text
28f71268426de6f196c2f4672b526489819c6393
```

avec :

```text
apiBuildId          = 4444962
consoleBuildId      = 4445025
consoleDefinitionId = 2641
```

Puis vérifier uniquement :

```text
GenerateJmx
JMeter Cur
JMeter Fix
```

Si `GenerateJmx` échoue encore, analyser uniquement le premier message d’erreur Console avant toute nouvelle modification.

