# InventoryTracking – Investigation XmlDiff et validation du correctif

Date : 2026-09-07  
PBI / WI : **2222897**  
Repository : **Y2_Plugins_InventoryTracking**  
Pipeline Azure DevOps : **InventoryTracking CI** – ID **2072**

## 1. Contexte

Le build Azure DevOps **4434070**, lancé sur la branche :

`InventoryTracking_Migration_AutoTest_Jmeter_On_master`

échouait pendant **Build V26**, avant les stages JMeter.

Commit concerné :

`4de185bb132cfbfb50643b6b53d6feb85508f4e2`

L’erreur principale observée était une référence non résolue vers :

`Cegid.Retail.XmlDiff`

avec notamment :

- `MSB3245` sur l’assembly `Cegid.Retail.XmlDiff`
- erreurs `CS0103` consécutives dans les tests

Le problème empêchait donc toute validation JMeter : le pipeline s’arrêtait avant d’atteindre ces stages.

---

## 2. Cause identifiée

La branche de migration supprime le projet :

`Cegid.Retail.InventoryTracking.WebServices.Tests`

ainsi que son `packages.config`.

Or ce `packages.config` contenait notamment :

```xml
<package id="Cegid.Retail.XmlDiff" version="1.0.0" targetFramework="net48" />
<package id="XMLDiffPatch" version="1.0.8.28" targetFramework="net48" />
```

Le projet conservé :

`Cegid.Retail.InventoryTracking.Services.Tests`

continue à utiliser `Cegid.Retail.XmlDiff`, mais dépendait auparavant indirectement de la présence de ces packages.

La migration a donc supprimé le propriétaire historique de la restauration NuGet sans transférer explicitement cette responsabilité au projet restant.

### Conclusion causale

La suppression de `WebServices.Tests` lors de la migration a créé une perte de dépendance pour `Services.Tests`.

Le correctif doit rendre `Services.Tests` autonome vis-à-vis de ces packages.

---

## 3. Correctif préparé

Worktree utilisé :

`InventoryTracking_Migration_AutoTest_Jmeter_On_master_worker2`

Deux fichiers ont été modifiés :

- `Cegid.Retail.InventoryTracking.Services.Tests/Cegid.Retail.InventoryTracking.Services.Tests.csproj`
- `Cegid.Retail.InventoryTracking.Services.Tests/packages.config`

### packages.config

Ajout de :

```xml
<package id="Cegid.Retail.XmlDiff" version="1.0.0" targetFramework="net48" />
<package id="XMLDiffPatch" version="1.0.8.28" targetFramework="net48" />
```

### csproj

La référence historique :

```xml
<Reference Include="Cegid.Retail.XmlDiff">
  <HintPath>..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll</HintPath>
</Reference>
```

a été remplacée par une référence explicite vers le package restauré :

```xml
<Reference Include="Cegid.Retail.XmlDiff, Version=1.0.0.0, Culture=neutral, PublicKeyToken=3ea389785c619660, processorArchitecture=MSIL">
  <SpecificVersion>False</SpecificVersion>
  <HintPath>..\Sln\packages\Cegid.Retail.XmlDiff.1.0.0\lib\net452\Cegid.Retail.XmlDiff.dll</HintPath>
</Reference>
```

Une référence explicite à `XMLDiffPatch` a également été ajoutée :

```xml
<Reference Include="XmlDiffPatch, Version=1.0.8.28, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a">
  <HintPath>..\Sln\packages\XMLDiffPatch.1.0.8.28\lib\net\XmlDiffPatch.dll</HintPath>
</Reference>
```

---

## 4. Validation locale de la restauration NuGet

La restauration a été exécutée sur :

`Sln\InventoryTracking.sln`

Résultat :

- `nuget restore` : **exit code 0**
- `Cegid.Retail.XmlDiff 1.0.0` restauré avec succès depuis le JFrog Cegid
- `XMLDiffPatch 1.0.8.28` restauré avec succès
- les DLL attendues sont présentes dans `Sln\packages`

Chemins validés :

```text
Sln\packages\Cegid.Retail.XmlDiff.1.0.0\lib\net452\Cegid.Retail.XmlDiff.dll
Sln\packages\XMLDiffPatch.1.0.8.28\lib\net\XmlDiffPatch.dll
```

Cette étape a confirmé que le correctif repose sur des packages réellement disponibles dans les feeds utilisés par le poste / pipeline.

---

## 5. Limitation du build local complet

Le poste ne disposait pas du targeting pack .NET Framework 4.8.

Pour éviter une installation globale, le package suivant a été utilisé temporairement :

`Microsoft.NETFramework.ReferenceAssemblies.net48` version `1.0.3`

Cela a permis à MSBuild de dépasser l’erreur `MSB3644`.

Le build complet local a ensuite échoué plus loin dans `ServiceContracts`, à cause d’assemblies Cegid non présentes localement, notamment :

- `Cegid.Framework.Common`
- `Cegid.Retail.Common`
- `Cegid.Retail.Tools`

avec de nombreuses erreurs dérivées autour de `VersionningNamespace`.

Ces erreurs sont distinctes du problème XmlDiff et montrent que le poste local ne reproduit pas complètement l’environnement de build Azure DevOps.

---

## 6. Validation locale ciblée de XmlDiff

Plutôt que de reconstruire tout le produit, une validation ciblée a été exécutée avec :

`ResolveAssemblyReferences`

sur :

`Cegid.Retail.InventoryTracking.Services.Tests.csproj`

avec les ProjectReferences désactivées.

Résultat :

- MSBuild : **exit code 0**
- `Cegid.Retail.XmlDiff` résolu vers le nouveau `HintPath`
- `XMLDiffPatch` résolu vers le nouveau `HintPath`
- aucune erreur XmlDiff
- aucune erreur de résolution associée

Cette validation cible directement le mécanisme responsable de l’échec du build 4434070.

---

## 7. Preuves persistées

Les éléments de preuve ont été enregistrés dans :

`investigations/ecarts-jmeter-migrations/evidence/2026-09-07-inventorytracking-local-xmldiff-validation`

Contenu :

- `README.md`
- `local-build-full.txt`
- `resolve-assembly-references-full.txt`

Hashes SHA256 enregistrés :

```text
local-build-full.txt
D13B6C5ACC9657DF638A650A28B55F72B41E8E2C22ECA66248ED964651BDBF01

README.md
7D77D0E2202EFE25C2060031817937482398441E9594E4796652112C26BE3D11

resolve-assembly-references-full.txt
10E63EE7305A84D79C7626B2ABDAB04516FB2D5116B54F51352DBF304DB2E0AF
```

---

## 8. Branche de validation Azure DevOps

Une branche isolée a été créée pour éviter toute modification de la branche de migration existante :

`validation/WI-2222897-inventorytracking-xmldiff`

Base :

`4de185bb132cfbfb50643b6b53d6feb85508f4e2`

Commit du correctif :

`ef3d87034d38b88aca04c824061b140e2a29252c`

Message :

`Fix InventoryTracking XmlDiff test dependencies`

La branche distante a été vérifiée et pointe bien sur ce commit.

Aucun merge ni PR n’a été réalisé.

---

## 9. Validation réelle Azure DevOps

Pipeline :

`InventoryTracking CI`

Pipeline ID :

`2072`

Run de validation :

**Build ID 4440774**

Paramètres :

```text
branch = validation/WI-2222897-inventorytracking-xmldiff
pipelineDevMode = false
```

Résultat global :

**SUCCEEDED**

Build number :

`7.75`

Commit réellement construit :

`ef3d87034d38b88aca04c824061b140e2a29252c`

### Timeline

```text
Snyk Security Scan   : succeeded
Build V26            : succeeded
Build                : succeeded
Check generate code  : succeeded
TI JMeter V26        : skipped
Promote              : skipped
Finalize build       : succeeded
```

Aucun record en échec.

### Conclusion

Le correctif est maintenant validé dans l’environnement Azure DevOps réel.

L’étape **Build V26**, qui échouait auparavant sur `Cegid.Retail.XmlDiff`, passe avec le correctif.

La confiance sur la cause et sur le correctif est donc désormais élevée.

---

## 10. Comportement important du pipeline

Le YAML contient le paramètre :

`pipelineDevMode`

affiché dans l’interface comme :

**Run tests on your dev branch.**

Valeur par défaut :

`false`

Sur une branche de développement / validation :

### pipelineDevMode = false

- Build V26 exécuté
- JMeter ignoré
- publication Artifactory staging ignorée
- Promote ignoré

C’est le mode utilisé pour la validation XmlDiff.

### pipelineDevMode = true

Le pipeline active également :

- les stages JMeter
- `Ensure_Docker_Image_Up_To_Date`
- `Publish to ArtifactoryCloud staging`

Le stage `Promote` reste néanmoins protégé par une condition supplémentaire et ne s’exécute que sur :

- `master`
- `releases/*`

Donc une branche `validation/*` ne peut pas promouvoir.

---

## 11. Leçons apprises

### 11.1 Une migration qui supprime un projet peut supprimer indirectement des dépendances

Supprimer un projet de tests et son `packages.config` n’est pas neutre si d’autres projets comptaient implicitement sur les packages restaurés par ce projet.

Le processus de migration doit vérifier non seulement les références directes, mais aussi les dépendances historiquement restaurées par les projets supprimés.

### 11.2 Un `HintPath` vers un dossier partagé peut masquer le vrai propriétaire d’une dépendance

La référence historique :

`..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`

rendait le projet dépendant d’un mécanisme extérieur à lui-même.

Le nouveau modèle, basé sur `packages.config` + `Sln\packages`, rend la dépendance explicite et reproductible.

### 11.3 Un build local complet n’est pas toujours la meilleure preuve

Le build local était pollué par des dépendances Cegid absentes du poste.

L’utilisation ciblée de :

`ResolveAssemblyReferences`

a permis de tester précisément l’hypothèse XmlDiff sans reproduire tout l’environnement CI.

Pour ce type d’investigation, une validation ciblée peut fournir une meilleure preuve qu’un build local global partiellement représentatif.

### 11.4 Le pipeline réel reste la preuve finale

La validation locale a fortement augmenté la confiance, mais le run ADO `4440774` est la preuve décisive :

**Build V26 passe réellement dans le même pipeline qui échouait auparavant.**

### 11.5 Le mode dev du pipeline a des effets plus larges que les seuls tests

`pipelineDevMode=true` ne signifie pas seulement « exécuter JMeter ».

Il active également des opérations de préparation / publication staging.

Il faut donc vérifier les conditions YAML avant de lancer un run de tests sur une branche de développement.

---

## 12. Actions futures recommandées

### Priorité 1 – Décider si une validation JMeter complète est nécessaire

Le problème XmlDiff est résolu et validé.

Si l’objectif suivant est de vérifier la migration JMeter elle-même, lancer un nouveau run sur :

`validation/WI-2222897-inventorytracking-xmldiff`

avec :

`Run tests on your dev branch = true`

Cela exécutera les tests JMeter V26.

Attention : ce mode active également la publication vers ArtifactoryCloud staging et la vérification / import de l’image Docker.

Le stage Promote restera ignoré sur la branche de validation.

### Priorité 2 – Faire intégrer le correctif de manière propre

Après validation fonctionnelle suffisante :

- conserver le commit `ef3d8703` comme référence technique ;
- appliquer le correctif sur la branche de migration appropriée ;
- passer par le workflow PR habituel ;
- éviter un merge direct depuis la branche temporaire de validation si cela ne correspond pas au processus attendu par l’équipe.

### Priorité 3 – Corriger le mécanisme de migration

Le correctif InventoryTracking traite le symptôme dans ce repository.

Il faut aussi analyser le script de migration qui supprime `WebServices.Tests`.

Le script devrait détecter qu’un package appartenant au projet supprimé reste requis par un projet conservé, puis :

- transférer la déclaration du package ;
- ou rendre explicitement le projet conservé autonome ;
- ou au minimum signaler la perte potentielle de dépendance.

Objectif : éviter de reproduire le même défaut sur d’autres plugins.

### Priorité 4 – Rechercher le même pattern sur les autres migrations

Chercher les repositories où :

- un projet `WebServices.Tests` a été supprimé ;
- son `packages.config` contenait des dépendances absentes des projets conservés ;
- un projet restant conserve des références vers les mêmes assemblies.

Cette analyse peut être automatisée.

### Priorité 5 – Consolider la documentation du PBI

Reporter dans les documents de suivi de `WI-2222897` :

- cause racine InventoryTracking ;
- commit de validation `ef3d8703`;
- build ADO de validation `4440774`;
- résultat `Build V26 = succeeded`;
- JMeter non exécuté sur ce run ;
- prochaine décision : lancer ou non une validation JMeter avec `pipelineDevMode=true`.

---

## 13. État actuel synthétique

| Élément | État |
|---|---|
| Cause XmlDiff identifiée | Validée |
| Correctif préparé | Oui |
| NuGet restore local | Succès |
| Résolution XmlDiff locale | Succès |
| Build local complet | Non représentatif, bloqué par externals Cegid |
| Branche de validation distante | Créée |
| Correctif commité | `ef3d8703` |
| Build ADO réel | **Succès – 4440774** |
| Build V26 | **Succès** |
| JMeter V26 | Non exécuté sur 4440774 |
| Promote | Non exécuté |
| Validation JMeter complète | À décider |
| Correction du script de migration | À étudier |

---

## Conclusion

L’investigation a permis de passer d’un échec de compilation bloquant à une validation réelle du correctif dans Azure DevOps.

La cause est cohérente avec la migration : la suppression de `WebServices.Tests` a supprimé la restauration de packages encore nécessaires à `Services.Tests`.

Le correctif rend `Services.Tests` explicitement autonome pour `Cegid.Retail.XmlDiff` et `XMLDiffPatch`.

Le run **4440774** confirme que **Build V26 passe désormais** sur le commit corrigé.

La prochaine étape n’est plus d’investiguer XmlDiff, mais de décider si l’on souhaite utiliser cette branche pour une validation JMeter complète avec `pipelineDevMode=true`, puis faire intégrer le correctif proprement et renforcer le mécanisme de migration afin d’éviter ce type de régression sur d’autres plugins.
