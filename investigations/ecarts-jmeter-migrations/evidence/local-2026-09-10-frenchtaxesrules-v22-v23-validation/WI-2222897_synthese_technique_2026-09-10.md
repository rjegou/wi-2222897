# WI-2222897 — Synthèse technique du travail réalisé et leçons apprises

**Date :** 2026-09-10  
**Périmètre :** FrenchTaxesRules — validation des configurations JMeter V22/V23 Cur/Fix et correction des minima de dépendances.

## 1. Objectif traité

L’objectif était de mettre en œuvre rapidement la recommandation de Ludo sur **FrenchTaxesRules V22 Fix** : relever les minima de dépendances de `v22-fix.cy2px` à partir du packaging candidat `22.0.23`, puis vérifier par un vrai rejeu JMeter que les 174 refus d’autorisation historiques disparaissent.

Le travail a été mené sur une branche de validation dédiée, sans modifier directement `releases/V5`.

---

## 2. V22 Fix — correction implémentée et validée

### Situation initiale

La configuration V22 Fix historique utilisait :

- `Y2.Core 22.0.0.1011`
- `Y2.Core.Common 22.0.2.300`
- `Y2.Plugin.Identity 22.0.5.182`
- `Y2.Core.AuthenticationServer 2.0.0.368`
- `Y2.Plugin.FrenchTaxesRules 22.0.6.478`

Cette pile provoquait **174 cas non passés** :

- 138 LegacyServices
- 36 WebServices

La cause commune observée était une **autorisation refusée** : droits `allowedModule` absents ou insuffisants dans la pile Fix.

### Candidat appliqué

Le trio issu du packaging `22.0.23` a été appliqué :

- `Y2.Core 22.0.0.2068`
- `Y2.Core.Common 22.0.3.311`
- `Y2.Plugin.Identity 22.0.6.117`

Les versions suivantes sont restées inchangées :

- AuthenticationServer `2.0.0.368`
- FrenchTaxesRules de la branche testée

### Résultat

Le run ciblé V22 Fix a fini par passer après correction du flux de publication Staging.

Le run global **4453591** a ensuite confirmé :

- V22 Cur : vert
- V22 Fix : vert
- toutes les campagnes V22 jouées avec succès

**Conclusion :** le relèvement du trio Core/Common/Identity corrige le défaut V22 Fix observé dans le contrat testé.

Ce résultat valide **la combinaison**, mais ne démontre pas quel composant exact du trio était causal ni quelle est la version minimale individuelle nécessaire.

---

## 3. Publication Staging — blocage intermédiaire identifié

Le premier run de validation du nouveau packaging a échoué avant les tests parce que la branche avait été volontairement protégée contre les effets externes.

Le déploiement cherchait :

`Y2.Plugin.FrenchTaxesRules 22.0.6.482`

dans :

`retail-software-staging`

mais le plugin n’y avait pas été publié.

Le log confirmait en revanche que les dépendances candidates étaient bien disponibles en Production :

- Core `22.0.0.2068`
- Common `22.0.3.311`
- Identity `22.0.6.117`
- AuthenticationServer `2.0.0.368`

Après autorisation explicite de la publication du plugin en **JFrog Staging**, le pipeline a été ajusté pour conserver :

- publication JFrog Staging : **autorisée**
- import/copie ACR sur branche dev : **désactivé**
- Promote : **désactivé**
- Tag : **désactivé**

Le run a alors pu aller jusqu’aux campagnes JMeter.

---

## 4. Sécurisation du pipeline de validation

Le pipeline historique activait plusieurs effets externes lorsque `pipelineDevMode=true`.

Un garde-fou temporaire a donc été ajouté pour permettre un rejeu sur branche de développement sans promotion involontaire.

Principe retenu :

- garder Build
- garder le déploiement nécessaire aux tests
- garder JMeter
- garder la publication des résultats/artifacts
- autoriser uniquement la publication Staging nécessaire au plugin
- bloquer ACR, Promote et Tag sur la branche de validation

Cette séparation est importante : le correctif fonctionnel et le garde-fou de validation ne doivent pas forcément finir ensemble dans la PR finale.

---

## 5. Branches et commits principaux

Branche de migration JMeter distante retrouvée :

`FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V5`

HEAD observé :

`d3124c8952dd1d56233881a4908477742c95a42a`

Branche de validation utilisée ensuite :

`sandbox/WI-2222897-frenchtaxesrules-v22-packaging-validation-20260909`

Commits notables :

- `28ebc53018795b18b9fc9590a91344d7e572a317` — relèvement des minima V22 Fix
- `aacbfd11ac61435a08da78f139b3b0d16d565c3a` — isolation du pipeline de validation
- `f565c1bd5b3f7a1c697ae0c2b909cc15b6ea952d` — réactivation de la publication JFrog Staging

La branche avait initialement été créée sous `validation/...`, puis renommée/recréée sous `sandbox/...` afin d’éviter un conflit avec les règles de nommage internes.

---

## 6. Runs Azure DevOps utiles

### Run 4452873

Premier rejeu du packaging candidat.

Résultat : échec avant JMeter car le plugin buildé n’était pas présent dans `retail-software-staging`.

Intérêt : validation que les trois dépendances candidates étaient bien trouvées et téléchargées.

### Run 4453511

Rejeu après réactivation de la publication Staging.

Résultat : V22 Fix passé.

### Run 4453591

Run manuel plus large.

Résultats constatés :

- tous les tests V22 sont verts
- V23 Cur est entièrement vert
- V23 Fix n’exécute pas JMeter

### Run 4453877

Tentative d’automatisation du run V23 Fix.

Problème : les paramètres runtime demandés via API n’ont pas été reflétés ; le run est parti avec les valeurs par défaut.

Le run discriminant V23 Fix a ensuite été relancé manuellement depuis l’UI avec les bons paramètres.

---

## 7. V23 Fix — nouveau blocage identifié

V23 Cur passe entièrement.

V23 Fix s’arrête dans `Test Y2 deployment`, avant JMeter.

Erreur principale :

`System.ArgumentException: The parameter 'sectionGroupName' is invalid`

Pile :

`Cegid.Retail.AspNetIdentityServer.IdentityServerConfiguration.ExtractAdditionalConfig`

Le WorkerProcess ne démarre ensuite pas correctement.

Un second symptôme apparaît plus tard :

`PasswordNotValid / invalid_username_or_password`

mais il est traité comme secondaire tant que l’application Retail elle-même n’est pas correctement initialisée.

### Versions V23 Cur réellement résolues

- Core `23.0.0.2010`
- Common `23.0.3.315`
- Identity `23.0.6.171`

### Versions V23 Fix historiques

- Core `23.0.0.1013`
- Common `23.0.3.154`
- Identity `23.0.5.243`

AuthenticationServer et FrenchTaxesRules ne sont pas la différence structurante entre Cur et Fix.

### Hypothèse actuellement testée

La stack trace pointe directement dans le composant Identity.

Un test discriminant a donc été préparé en modifiant **uniquement** :

`Y2.Plugin.Identity 23.0.5.243 -> 23.0.6.171`

sans toucher Core ni Common.

Branche :

`sandbox/WI-2222897-frenchtaxesrules-v23-identity-validation-20260910`

Commit :

`07397fd59da997cdc4c13541b6af8d0c1c457908`

Le run discriminant V23 Fix est en cours au moment de cette synthèse.

---

## 8. Leçons apprises

### 8.1 Toujours distinguer échec de déploiement et échec de test

Un stage JMeter absent ou skipped ne signifie pas que les tests ont échoué.

Exemple V23 Fix : l’échec se produit avant JMeter, dans la validation du déploiement Y2.

Il ne faut donc pas compter ces cas comme des tests fonctionnels rouges.

### 8.2 Cur est un excellent contrôle pour les piles Fix

Quand :

- Cur passe
- Fix casse
- plugin et AuthenticationServer sont identiques

la comparaison des versions Core/Common/Identity devient immédiatement très informative.

C’est exactement ce qui a permis de résoudre V22 et de cadrer V23.

### 8.3 Valider d’abord une combinaison, puis chercher la causalité fine

Pour V22, le trio du packaging `22.0.23` a rétabli un environnement fonctionnel.

C’était plus rapide et plus sûr que d’essayer immédiatement d’identifier la dépendance exacte responsable des claims.

Pour V23, la stack trace étant plus précise, un test Identity seule est pertinent avant d’aligner tout le trio.

### 8.4 Ne pas créer une infrastructure de replay inutile

Le pipeline existant permettait déjà de sélectionner :

- une version
- Cur ou Fix
- les campagnes LegacyServices/WebServices

Il était préférable de sécuriser ce pipeline plutôt que de créer un runner parallèle complexe.

### 8.5 Les effets externes d’un pipeline dev doivent être vérifiés avant exécution

`pipelineDevMode=true` ne signifie pas automatiquement « sans risque ».

Dans ce pipeline il activait notamment :

- publication JFrog
- logique ACR

Le garde-fou devait donc être explicite.

### 8.6 Certaines publications Staging sont nécessaires au test

Bloquer toutes les écritures empêchait le pipeline de tester le plugin fraîchement buildé.

La bonne approche n’est donc pas « aucune écriture », mais :

**autoriser uniquement les écritures nécessaires au contrat de validation.**

### 8.7 Les paramètres Azure DevOps REST doivent être vérifiés après queue

Le run `4453877` montre qu’une requête acceptée par l’API ne garantit pas que les paramètres runtime ont été appliqués comme attendu.

Pour un run discriminant important :

- inspecter immédiatement les paramètres réellement pris
- annuler si nécessaire
- utiliser l’UI si elle est plus fiable et rapide

### 8.8 Le nom de branche fait partie du contrat opérationnel

La branche `validation/...` a été remplacée par `sandbox/...` pour respecter les règles internes.

Pour les travaux temporaires de diagnostic/replay, utiliser directement un préfixe autorisé évite des corrections tardives.

### 8.9 Ne pas baser la PR sur `releases/V5` si la migration vit ailleurs

Le HEAD actuel de `releases/V5` ne contient plus les fichiers JMeter concernés.

La vraie base technique est la branche de migration :

`FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V5`

Il faut donc distinguer :

- branche release historique
- branche de migration JMeter
- branche sandbox de validation
- future branche/PR de livraison

---

## 9. État actuel

### Validé

- correction V22 Fix par relèvement Core/Common/Identity
- V22 Cur vert
- V22 Fix vert
- campagnes V22 complètes vertes
- V23 Cur vert
- mécanisme de publication Staging maîtrisé
- ACR/Promote/Tag neutralisés sur la branche de validation

### En cours

V23 Fix : test discriminant avec Identity `23.0.6.171` seule.

### Suite logique

Si V23 Fix démarre avec Identity seule :

- exécuter les campagnes complètes
- confirmer que le défaut `sectionGroupName` disparaît
- conserver le changement minimal si les tests passent

Si le défaut persiste :

- aligner ensuite Core sur `23.0.0.2010`
- Common sur `23.0.3.315`
- rejouer V23 Fix

Une fois V22 et V23 stabilisés :

- nettoyer les commits temporaires de validation
- préparer la PR finale avec uniquement les modifications nécessaires
- documenter clairement les versions minimales retenues et les runs de preuve
