# Investigation V22 FrenchTaxesRules — Synthèse technique et recommandations

_Date : 2026-09-07_  
_Périmètre : WI-2222897 — écarts JMeter migrations — `Y2_Plugins_FrenchTaxesRules`, `releases/V5`, V22_

## 1. Résumé exécutif

L’investigation porte sur l’écart historique suivant en V22 :

- **Current** : 376 / 376 tests passent.
- **Fix** : 202 passent, **174 échouent**.
- Les 174 échecs Fix sont homogènes et liés à l’autorisation :
  - `CBP50101`
  - `ID4266`
  - `ClaimsPrincipalPermission.Demand()`
  - contrôle autour du module `FrenchTaxesRules`.

Les éléments recueillis montrent désormais avec une **bonne confiance** que l’écart est lié à la pile de versions utilisée par le packaging Fix, et plus particulièrement à la génération du framework d’autorisation embarquée via Core.

Le point le plus fort est le suivant :

- Fix utilise au runtime `Cegid.Erp.Services.Implementation 12.9.153.1506`.
- Current utilise au runtime `Cegid.Erp.Services.Implementation 12.9.185.17`.
- Le Core candidat `22.0.0.2068`, issu d’un packaging supérieur proposé comme piste, restaure `FWK-CEGID-NET-FULL 12.9.185`.
- Le NuGet `FWK-CEGID-NET-FULL 12.9.185` contient exactement `Cegid.Erp.Services.Implementation.dll 12.9.185.17`.
- C’est donc **exactement la même génération du provider d’autorisation que celle observée dans le Current qui passe 376/376**.

Cela renforce fortement l’hypothèse formulée par Ludo : lorsqu’un Current passe mais que le Fix échoue, il peut s’agir d’un mauvais alignement de versions dans le packaging Fix, corrigible en prenant les composants d’un packaging supérieur compatible.

La correction des **174/174 échecs** est désormais une hypothèse raisonnable, mais elle doit encore être confirmée par une exécution réelle isolée.

---

## 2. Travail réalisé

### 2.1 Caractérisation précise de l’échec V22

Les logs historiques ont permis de distinguer clairement :

- l’authentification globale ;
- l’autorisation du point d’entrée ;
- le contrôle fin réalisé ensuite dans l’adapter FrenchTaxesRules.

Dans le Fix :

- la demande de token AuthenticationServer réussit ;
- les appels `getauthorizationscopes` répondent HTTP 200 ;
- l’autorisation externe du endpoint `LegacyDispatcherService.svc` est accordée ;
- l’échec se produit ensuite dans le code généré FrenchTaxesRules lors d’un `ClaimsPrincipalPermission.Demand()`.

Conclusion : **ce n’est pas un problème de connexion, de token absent ou d’ACL IIS globale**. L’échec concerne le contenu ou l’interprétation des claims d’autorisation fine.

### 2.2 Comparaison des versions runtime Fix / Current

Versions observées historiquement :

| Composant | Fix V22 | Current V22 |
|---|---:|---:|
| Y2 Core | 22.0.0.1011 | 22.0.0.2096 |
| Y2 Common | 22.0.2.300 | 22.0.3.315 |
| Identity | 22.0.5.182 | 22.0.6.171 |
| FrenchTaxesRules | 22.0.6.478 | 22.0.6.478 |
| AuthenticationServer | 2.0.0.368 | 2.0.0.368 |
| `Cegid.Erp.Services.Implementation` | **12.9.153.1506** | **12.9.185.17** |

FrenchTaxesRules et AuthenticationServer sont donc identiques entre Fix et Current. Les principales différences sont Core / Common / Identity.

### 2.3 Analyse de Common

Les versions étudiées de `Y2_Core_Common` ne montrent pas de transformation permettant d’expliquer directement le problème :

- pas de conversion automatique entre `FrenchTaxesRules`, `purge`, `purge-settings`, etc. ;
- les scopes sont essentiellement transportés tels quels ;
- les objets étudiés sur les versions candidates / Current sont identiques ou très proches sur ce mécanisme.

Common est donc aujourd’hui un suspect secondaire.

### 2.4 Analyse d’Identity

Les tags suivants ont été retrouvés :

- `V5.182` → Fix historique ;
- `V6.117` → version candidate issue d’un packaging supérieur ;
- `V6.171` → Current historique.

Le diff V5.182 → V6.171 montre une évolution importante de la gestion des autorisations.

En particulier, Identity V6 introduit un `ModuleCatalog.GetUserAuthorizationScopes()` qui produit explicitement des claims :

```text
ClaimType = "allowedModule"
```

Identity V6.117 possède déjà cette implémentation moderne, comme V6.171.

Cela place :

- Fix Identity 5.182 du côté ancien ;
- Candidate Identity 6.117 et Current Identity 6.171 du côté moderne.

Cette évolution est cohérente avec la famille du problème observé, même si Identity ne publie pas directement un claim `FrenchTaxesRules` dans le code analysé. Ce constat renforce le candidat sans suffire seul à démontrer la correction.

### 2.5 Identification du Core candidat

Le packaging supérieur étudié propose notamment :

- Core `22.0.0.2068`
- Common `22.0.3.311`
- Identity `22.0.6.117`

Pour Core `22.0.0.2068`, les propriétés JFrog donnent :

```text
build.name      = Y2_Core CI
build.number    = 22.0.0.2068
build.timestamp = 1757093083170
```

soit une publication le **2025-09-05 vers 17:24 UTC**.

La branche correcte du repository `Y2_Core` est :

```text
releases/V22
```

Le commit immédiatement antérieur à la publication est :

```text
e24de4fe8a6adf886b6d4ef942366a3a4fce09b4
2025-09-05T17:00:00Z
Merged PR 416695: feat: change call Leagacy UserManagement
```

Il constitue donc un candidat très fort pour la source ayant produit Core `22.0.0.2068`.

Le Current `22.0.0.2096` correspond au HEAD / tag :

```text
7c9f454d1c304b051e636a7acdca30caa3a419ac
```

### 2.6 Origine de `Cegid.Erp.Services.Implementation.dll`

La recherche dans les `.csproj` montre que `Y2_Core` ne contient pas l’implémentation de `AuthorizationServiceFactory`.

Les projets référencent :

```text
..\..\Packages\CBP.Net\Content\BIN\Erp\Cegid.Erp.Services.Implementation.dll
```

La DLL provient donc du package externe restauré dans `Packages\CBP.Net`.

Pour **Core Candidate 2068** comme pour **Core Current 2096**, `ExternalsToRestore.xml` contient :

```xml
<nuget
  name="FWK-CEGID-NET-FULL"
  version="12.9.185"
  source="."
  destination=".\Packages\CBP.Net"
  ignoreOnBuildKits="false"/>
```

Le package a été retrouvé dans JFrog :

```text
Repo : retail-nuget-production
Path : CBP12_9/12.9.185/DotNet
Name : FWK-CEGID-NET-FULL.12.9.185.nupkg
Size : 15.21 MB
```

Le NuGet a été téléchargé et inspecté directement.

Il contient :

```text
content/BIN/Erp/Cegid.Erp.Services.Implementation.dll
```

Version exacte :

```text
FileVersion    : 12.9.185.17
ProductVersion : 12.9.185.17
```

C’est **exactement la version observée dans le Current historique qui passe 376/376**.

---

## 3. Ce que l’on peut maintenant considérer comme établi

### FACT

Le Fix V22 échoue sur 174 tests avec le même mécanisme d’autorisation fine `ID4266 / ClaimsPrincipalPermission.Demand()`.

### FACT

Le Current V22 passe 376/376.

### FACT

FrenchTaxesRules `22.0.6.478` et AuthenticationServer `2.0.0.368` sont identiques dans Fix et Current.

### FACT

Fix charge :

```text
Cegid.Erp.Services.Implementation 12.9.153.1506
```

### FACT

Current charge :

```text
Cegid.Erp.Services.Implementation 12.9.185.17
```

### FACT

Core Candidate `22.0.0.2068` restaure :

```text
FWK-CEGID-NET-FULL 12.9.185
```

### FACT

Ce NuGet contient :

```text
Cegid.Erp.Services.Implementation 12.9.185.17
```

### FACT

Core Current `22.0.0.2096` restaure également `FWK-CEGID-NET-FULL 12.9.185`.

### FACT

Identity Candidate `22.0.6.117` possède déjà le mécanisme moderne de publication de claims `allowedModule`, comme Current `22.0.6.171`, contrairement à Fix `22.0.5.182`.

### INFERENCE FORTE

Le trio de versions proposé par le packaging supérieur est beaucoup mieux aligné avec le Current fonctionnel que le packaging Fix historique.

### INFERENCE FORTE

Core `22.0.0.2068` apporte déjà la même génération de framework d’autorisation que Current, ce qui en fait un candidat particulièrement crédible pour supprimer les `ID4266`.

### NON DÉMONTRÉ

On ne peut pas encore affirmer que les 174 échecs disparaîtront réellement sans exécuter le scénario.

---

## 4. Leçons techniques utiles

### 4.1 Ne pas réduire un échec d’autorisation à AuthenticationServer

Un token peut être obtenu correctement et `getauthorizationscopes` peut répondre 200 alors qu’un contrôle fin échoue ensuite dans le service.

Pour ce type d’incident, distinguer systématiquement :

1. authentification ;
2. autorisation du endpoint ;
3. construction des claims ;
4. propagation des claims ;
5. vérification fine dans le code métier / adapter.

### 4.2 Le numéro du composant Core peut masquer une dépendance framework déterminante

`Y2.Core 22.0.0.xxxx` ne suffit pas à comprendre le comportement d’autorisation.

Il faut aussi inspecter ses externals, notamment :

```text
FWK-CEGID-NET-FULL
```

qui fournit réellement :

```text
Cegid.Erp.Services.Implementation.dll
```

La comparaison de la DLL runtime a ici été beaucoup plus informative que le simple numéro de version du package Core.

### 4.3 Le NuGet externe est souvent une preuve moins coûteuse que le package final

Plutôt que télécharger et analyser plusieurs ZIP Core d’environ 400 Mo, il a été plus efficace de :

1. retrouver `ExternalsToRestore.xml` ;
2. identifier `FWK-CEGID-NET-FULL 12.9.185` ;
3. retrouver le NuGet de 15 Mo dans JFrog ;
4. extraire uniquement la DLL intéressante ;
5. vérifier sa `FileVersion`.

Cette méthode est à privilégier pour les investigations similaires.

### 4.4 JFrog Build Info et propriétés artefact ne donnent pas les mêmes droits

Avec le token utilisé :

- lecture artefact : OK ;
- `/api/storage/...` : OK ;
- propriétés `?properties` : OK ;
- recherche AQL : OK ;
- Build Info `/api/build/...` : 403.

Ne pas bloquer une investigation sur Build Info : les propriétés artefact et AQL fournissent déjà beaucoup d’informations.

### 4.5 Les anciens runs Azure DevOps peuvent avoir été purgés

La recherche du build historique par `buildNumber` peut retourner zéro résultat même si JFrog conserve encore les artefacts et leurs propriétés.

Approche de repli efficace :

1. récupérer le timestamp JFrog ;
2. identifier la branche exacte ;
3. consulter l’historique Git autour de ce timestamp ;
4. associer le commit le plus proche au build.

### 4.6 Azure DevOps Git ne supporte pas nécessairement `--shallow-since`

Le serveur testé répond :

```text
fatal: Server does not support --shallow-since
```

Utiliser plutôt un fetch par profondeur :

```text
git fetch --depth=<N>
```

### 4.7 Prudence avec les sorties JSON de `az`

Quand une commande `az` doit être passée à `ConvertFrom-Json`, ne pas fusionner stderr avec stdout via :

```text
2>&1
```

Les warnings Azure CLI peuvent alors polluer le JSON.

Préférer :

```text
2>$null
```

lorsque l’erreur détaillée n’est pas nécessaire.

### 4.8 Pour les téléchargements JFrog, `curl.exe` est fiable et rapide

Approche validée :

```text
curl.exe --fail --location --retry 3 --silent --show-error \
  --header "Authorization: Bearer <TOKEN>" \
  --output <FILE> <URL>
```

Éviter de considérer un fichier local déjà présent comme valide sans hash ou contrôle de taille : un téléchargement partiel précédent peut sinon être réutilisé par erreur.

---

## 5. État du replay isolé

Un brouillon de replay isolé a déjà été préparé dans :

```text
investigations/ecarts-jmeter-migrations/replay-prep/2026-09-07-v22-isolated/
```

Il contient notamment :

```text
README.md
azure-pipelines.candidate.yml
scripts/Preflight-V22FrenchTaxesRules.ps1
```

Le principe est de pouvoir comparer proprement :

- Historical Fix ;
- Candidate.

Le pipeline d’origine `FrenchTaxesRules CI` ne doit **pas** être relancé tel quel pour cette investigation.

Selon `pipelineDevMode`, il peut provoquer des effets distants tels que :

- publication Artifactory ;
- import JFrog → ACR ;
- promotions ;
- tags ;
- autres effets aval.

Le replay isolé doit conserver les garde-fous suivants :

- aucun trigger automatique ;
- aucun PR trigger ;
- aucun schedule ;
- aucune publication ;
- aucune promotion ;
- aucun tag ;
- aucun import distant ;
- aucun downstream ;
- fail-closed au preflight.

Les investigations précédentes ont en revanche montré que la cible SQL / IIS utilisée par les jobs JMeter est locale au conteneur, ce qui réduit fortement le risque d’impact sur les environnements partagés.

---

## 6. Recommandation pour la suite

### Priorité 1 — rendre le replay reproductible

Avant l’exécution, retrouver dans les logs historiques `Initialize Containers` du run V22 :

```text
build 4429167
```

l’image exacte utilisée par :

```text
acr_y2jmeter_test
```

Idéalement récupérer :

- repository ;
- tag résolu ;
- digest si disponible.

But : éviter qu’une image de conteneur plus récente devienne une variable parasite dans le test.

### Priorité 2 — exécuter un replay isolé Candidate

Tester au minimum le scénario V22 FrenchTaxesRules avec le packaging candidat issu de la version supérieure.

Versions candidates actuellement identifiées :

```text
Core     22.0.0.2068
Common   22.0.3.311
Identity 22.0.6.117
```

en conservant :

```text
FrenchTaxesRules      22.0.6.478
AuthenticationServer 2.0.0.368
```

Le résultat attendu à vérifier est :

```text
174 authorization failures -> 0
```

et idéalement :

```text
376 / 376 PASS
```

### Priorité 3 — si le Candidate passe

Si le Candidate obtient 376/376 :

1. considérer la piste « packaging Fix trop ancien / incohérent » comme confirmée ;
2. documenter précisément le minimum de versions nécessaires ;
3. éviter de patcher les JMX pour masquer ces 174 erreurs ;
4. privilégier la correction du packaging / des dépendances ;
5. rattacher l’explication au changement de génération du framework d’autorisation et à l’alignement Identity/Core.

### Priorité 4 — si le Candidate échoue encore

Comparer alors les claims réellement produits entre Candidate et Current.

À capturer en priorité :

- réponse réelle de `getauthorizationscopes` ;
- claims présents dans le principal au moment du `ClaimsPrincipalPermission.Demand()` ;
- présence / absence de `allowedModule=FrenchTaxesRules` ;
- éventuelles différences Core / Identity après le packaging candidat.

À ce stade seulement, poursuivre l’analyse fine des assemblies ou du code d’autorisation.

---

## 7. Niveau de confiance actuel

### Cause générale : **forte confiance**

Le problème est lié à l’ancien alignement de versions du Fix plutôt qu’aux JMX eux-mêmes.

### Implication de la génération d’autorisation Core : **forte confiance**

Le passage :

```text
12.9.153.1506 -> 12.9.185.17
```

est directement corrélé au passage :

```text
174 ID4266 -> 0 ID4266
```

entre Fix et Current.

Le Core candidat apporte déjà exactement `12.9.185.17`.

### Correction complète des 174 échecs par le packaging candidat : **bonne confiance, à confirmer par exécution**

La cohérence technique est forte, mais le replay reste la preuve finale nécessaire.

---

## 8. Point de reprise conseillé pour Brain-Worker

Reprendre l’investigation FrenchTaxesRules `releases/V5` V22 à partir de ce constat :

> Le packaging candidat basé sur Core 22.0.0.2068 / Common 22.0.3.311 / Identity 22.0.6.117 est maintenant fortement étayé. Core 2068 restaure FWK-CEGID-NET-FULL 12.9.185, qui contient exactement Cegid.Erp.Services.Implementation 12.9.185.17, version observée dans le Current 376/376, contre 12.9.153.1506 dans le Fix aux 174 ID4266. Identity 6.117 possède également le mécanisme moderne `allowedModule` présent dans Current 6.171. La prochaine preuve de valeur est un replay V22 isolé et sans effets distants, idéalement avec l’image Docker historique exacte.

Aucune mutation distante n’a été réalisée pendant cette phase d’investigation.
