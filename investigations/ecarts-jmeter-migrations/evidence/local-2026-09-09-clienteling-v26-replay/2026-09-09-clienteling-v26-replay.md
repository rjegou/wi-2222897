# WI-2222897 — Synthèse technique du replay isolé Clienteling V26

## Contexte

Travail réalisé sur le plugin **Clienteling V26** dans le cadre de la PBI **WI-2222897**.

Objectif de cette séquence :

> Faire progresser un replay isolé du pipeline Clienteling jusqu'à une vraie exécution JMeter Cur/Fix, sans toucher aux pipelines CI normaux, templates partagés ni branches partagées, et caractériser précisément le premier blocage restant à chaque étape.

### Périmètre technique

- Projet Azure DevOps : `Retail`
- Repository : `Y2_Plugins_Clienteling`
- Definition isolée : `14264`
- Branche : `sandbox/clienteling/wi2222897-isolated-replay`
- YAML : `ci/wi2222897/azure-pipelines.clienteling-wi2222897.yml`
- Workspace local : `C:\clones\wi-2222897\.work\clienteling-plugin`
- Workspace général : `C:\clones\wi-2222897`

### Paramètres de replay utilisés

- `apiBuildId = 4444962`
- `apiDefinitionId = 2637`
- `apiCommit = 4c22cb2850a150161f44080815375527c4daad48`
- `consoleBuildId = 4445025`
- `consoleDefinitionId = 2641`

SHA-512 JMeter 5.6.3 utilisé :

`387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B0163076`

---

## Méthode de travail utilisée

La progression a été volontairement conduite **blocage par blocage**.

À chaque run :

1. observer uniquement le premier échec réel ;
2. formuler une hypothèse précise ;
3. utiliser le LLM local pour une investigation courte et ciblée ;
4. demander une preuve avant toute modification ;
5. appliquer un patch minimal ;
6. relire le diff ;
7. commit avec `git commit --only` ;
8. push ;
9. relancer le pipeline isolé ;
10. recommencer sur le blocage suivant.

Cette méthode a évité de multiplier les corrections spéculatives et a permis de prouver que chaque patch faisait réellement progresser le replay.

---

# 1. Blocages franchis

## 1.1 SHA JMeter incorrect

Le SHA JMeter utilisé initialement était tronqué.

Ancien :

`...B016307`

Correct :

`...B0163076`

### Résultat

Le téléchargement et la vérification de JMeter ont pu être franchis.

---

## 1.2 Fichier historique `v26-Cur.cy2px` introuvable

Erreur initiale :

`Historical V26 config not found: v26-Cur.cy2px`

### Cause

Le fichier `.cy2px` n'était pas directement dans l'artefact historique. Il était contenu dans :

`Y2-Deployment-Logs.zip`

### Correctif

Le pipeline isolé a été adapté pour :

- récupérer `Y2-Deployment-Logs.zip` ;
- l'extraire ;
- récupérer `v26-${variant}.cy2px` ;
- le copier dans le runtime ;
- contrôler son hash.

### Résultat

La configuration historique V26 a pu être matérialisée correctement.

---

## 1.3 PlatformDeploy absent du job JMeter

Build concerné : `4451986`

Erreur :

`Required deployment input is missing: ...docker-pipeline-deploy.ps1`

### Cause

`platformDeploy` était checkouté dans un autre job Azure DevOps, pas dans le job JMeter qui exécutait le replay.

### Correctif

Ajout du checkout de PlatformDeploy dans chaque job JMeter concerné.

Commit associé : `d33ac0bbe`

### Résultat

Le job JMeter a pu appeler réellement PlatformDeploy.

---

## 1.4 Clé `RetailJfrogApiKey` absente

Build concerné : `4452281`

Erreur : `RetailJfrogApiKey is mandatory.`

### Cause

Le wrapper isolé invoquait PlatformDeploy sans transmettre la clé attendue.

### Correctif

Dans le YAML :

- ajout du variable group `RetailJfrogVariables` ;
- exposition du secret uniquement sous forme de variable d'environnement : `RETAIL_JFROG_API_KEY: $(RetailJfrogApiKey)`.

Dans le wrapper :

- contrôle de présence de `RETAIL_JFROG_API_KEY` ;
- passage du paramètre `-RetailJfrogApiKey`.

Commit : `f75e1f96d`

### Résultat

PlatformDeploy a commencé à exécuter sa logique réelle.

---

## 1.5 Host historique non portable dans le `.cy2px`

Build concerné : `4452432`

Erreur :

`This host (...) or a host having the docker container token (__CONTAINER_HOST__) is not defined...`

### Investigation

Le `.cy2px` historique du build `4432554` contenait :

```xml
<host name="39C0EFC9EB14" roles="Y2, Cptx, AuthServer, WebApps, Wp" />
```

PlatformDeploy accepte explicitement :

```xml
<host name="__CONTAINER_HOST__" roles="..." />
```

### Correctif

Le pipeline isolé remplace désormais le `host/@name` historique par `__CONTAINER_HOST__`, avec contrôle qu'il existe exactement un host et vérification après sauvegarde.

Commit : `0397b4987`

### Résultat

Le premier blocage lié au host a été franchi.

---

## 1.6 Instance SQL historique non portable

Build concerné : `4452572`

Nouvelle erreur : `39C0EFC9EB14 : DNS name does not exist.`

### Cause

Le hostname historique apparaissait encore dans la définition du serveur SQL :

```xml
<server instance="39C0EFC9EB14\DOCKERSQLEXPR" driver="Sql2012">
```

### Investigation

La logique PlatformDeploy montre que, dans le mode container, la forme portable attendue est :

```xml
<server instance="__CONTAINER_HOST__\DOCKERSQLEXPR" driver="Sql2012">
```

Le token est ensuite résolu pendant l'initialisation du conteneur.

### Correctif

Le YAML isolé sélectionne `//databases/server`, vérifie qu'un seul serveur est présent, vérifie que le nom d'instance est `DOCKERSQLEXPR`, puis remplace le host historique par `__CONTAINER_HOST__`.

Commit : `c3c8f4ae2`

### Résultat

Le blocage DNS a été franchi.

---

## 1.7 Backup SQL non disponible dans le chemin attendu par PlatformDeploy

Build concerné : `4452629`

Erreur :

`Database backup AUTO_V26_00.bak not found in folder ...\Docker\Data`

### Cause

Le wrapper connaissait le chemin du backup, mais PlatformDeploy ne lit pas directement ce paramètre. Il cherche physiquement le backup dans `<PlatformDeploy>\Docker\Data`.

### Correctif

Dans `ci/wi2222897/scripts/Invoke-Wi2222897PlatformDeploy.ps1`, le wrapper :

- calcule `<PlatformDeploy>\Docker\Data` ;
- crée le dossier si nécessaire ;
- copie le backup fourni vers ce dossier ;
- conserve le nom réel du fichier.

Commit : `f9456eac58890db7b7b17ab5a7080878a816e88c`

### Résultat

Le run suivant est allé plus loin et n'a plus bloqué sur le backup.

---

## 1.8 `Cegid.Retail.JFrog.Cli.exe` absent

Build concerné : `4452683`

Erreur :

```text
The term '...\Tools\Cegid.Retail.JFrogCli\Cegid.Retail.JFrog.Cli.exe'
is not recognized...
```

### Cause prouvée

Le CLI JFrog n'est pas versionné directement dans le repo PlatformDeploy.

Le pipeline PlatformDeploy normal :

1. restaure les dépendances via `JFrogNuGet@1` ;
2. construit les outils ;
3. publie `Cegid.Retail.JFrog.Cli.csproj` ;
4. matérialise l'exécutable dans `Src\Powershell\Code\Tools\Cegid.Retail.JFrogCli`.

Le replay isolé faisait uniquement un checkout de PlatformDeploy. Il manquait donc toute la phase de préparation de l'outil.

### Correctif

Ajout dans le YAML isolé, avant PlatformDeploy :

- restore avec `JFrogNuGet@1` ;
- `ArtifactoryCloudV2-Retail` ;
- repo virtuel `all-nuget` ;
- protocole v2 ;
- publication uniquement de `Cegid.Retail.JFrog.Cli.csproj` ;
- sortie vers `Src\Powershell\Code\Tools\Cegid.Retail.JFrogCli` ;
- contrôle explicite de présence de `Cegid.Retail.JFrog.Cli.exe`.

Le `dotnet publish` utilise `--no-restore` mais pas `--no-build`, car le restore est déjà réalisé par la tâche JFrog alors qu'aucun build préalable du projet n'existe dans le job isolé.

Commit : `13ef7c0e3a5fa96e18c134b4213d7d8ac367ac75`

Run : `4452739`

### Résultat

Le CLI JFrog est désormais trouvé et exécuté.

---

# 2. Dernier blocage atteint

## 2.1 Échec de téléchargement d'un package

Run : `4452739`

Erreur :

```text
The download of one or more packages has failed
Process aborted
```

### Mécanisme identifié

PlatformDeploy appelle :

```text
Cegid.Retail.JFrog.Cli.exe download packagelist <deployConfig> ...
```

La liste de packages provient du `v26-Cur.cy2px`.

Packages identifiés dans cette configuration :

- `Y2.Core 26.0.*`
- `Y2.Core.Common 26.0.*`
- `Y2.Core.AuthenticationServer 2.0.*`
- `Y2.Plugin.Identity 26.0.*`
- `Y2.Plugin.Technical 26.0.*`
- `Y2.Plugin.LoyaltyEngine 26.0.*`
- `Y2.Plugin.Settings 26.0.*`
- `Y2.Plugin.Company 26.0.*`
- `Y2.Plugin.Employee 26.0.*`
- `Y2.Plugin.FrenchTaxesRules 26.0.*`
- `Y2.Plugin.TaxEngine 26.0.*`
- `Y2.Plugin.Clienteling 26.0.10.23`

### Limitation rencontrée

Le wrapper isolé capturait la sortie complète de PlatformDeploy dans `$raw`, mais masquait volontairement la sortie détaillée en cas d'échec :

```powershell
throw 'PlatformDeploy failed; raw output intentionally not persisted.'
```

Le nom du package fautif n'était donc pas visible.

---

# 3. Patch diagnostic sécurisé

Une investigation du code du CLI a permis d'identifier les formats de logs utiles :

```text
[INF] Updating package {packageName}
[INF] Download package {filename}
[FTL] Download failed
[FTL] The download of one or more packages has failed
```

Le CLI peut également produire une erreur HTTP .NET de la forme :

```text
Response status code does not indicate success: {status} (...)
```

Le code du CLI ne journalise pas directement la valeur de `X-JFrog-Art-Api`.

### Principe retenu

Ne jamais réafficher arbitrairement la sortie brute.

Le wrapper a été modifié pour ne restituer que :

- le dernier fichier ZIP associé à `Download failed` ;
- éventuellement le code HTTP.

Whitelist utilisée :

- fichier : `[A-Za-z0-9][A-Za-z0-9._-]*\.zip`
- HTTP : `[1-5][0-9]{2}`

Commit : `afe035ec73cdc0c376f0d57b23772186a7f5129c`

Run : `4452826`

---

# 4. État final au moment de l'arrêt

Run : `4452826`

Résultat :

```text
The download of one or more packages has failed
Process aborted
...
PlatformDeploy failed; diagnostic:
```

Le diagnostic whitelisté est resté vide.

### Conclusion

À ce stade :

- le CLI JFrog est bien présent ;
- il est bien exécuté ;
- PlatformDeploy atteint bien la phase `download-packages.ps1` ;
- au moins un téléchargement échoue ;
- le package fautif n'a pas encore été identifié ;
- le format réel de la sortie du chemin d'échec ne correspond pas au filtre diagnostic prévu, ou l'échec intervient avant la ligne `Download package <filename>` attendue.

Le replay n'a donc **pas encore atteint une exécution JMeter Cur réelle**.

---

# 5. Progression globale obtenue

Le replay isolé a successivement franchi :

1. vérification de JMeter ;
2. récupération du `.cy2px` historique ;
3. extraction du ZIP historique interne ;
4. disponibilité de PlatformDeploy dans le bon job ;
5. transmission du secret JFrog ;
6. adaptation portable du host ;
7. adaptation portable de l'instance SQL ;
8. staging du backup SQL au contrat attendu ;
9. matérialisation du CLI JFrog ;
10. entrée réelle dans la phase de téléchargement des packages PlatformDeploy.

Le dernier blocage connu se situe donc maintenant **dans le téléchargement des packages JFrog**, nettement plus loin qu'au début de l'investigation.

---

# 6. Leçons techniques apprises

## 6.1 Un checkout d'un outil ne garantit pas qu'il soit exécutable

PlatformDeploy dépend de composants générés pendant son pipeline normal. Le simple checkout du dépôt n'était pas suffisant.

### Leçon

Lorsqu'on rejoue un outil hors de son pipeline d'origine, il faut reconstituer son **contrat runtime**, pas seulement récupérer ses sources : binaires générés, restore NuGet, outils auxiliaires, artefacts produits par un job précédent, secrets, répertoires de données et conventions de chemin.

---

## 6.2 Rejouer une configuration historique exige de la rendre portable

Le `.cy2px` historique contenait un nom de machine et une instance SQL liée à cette machine. Ces valeurs fonctionnaient dans l'environnement historique, mais pas dans le replay isolé.

### Leçon

Pour un replay reproductible, distinguer les données historiques à préserver des informations d'infrastructure à tokeniser ou réinterpréter. `__CONTAINER_HOST__` constituait ici le contrat portable prévu par PlatformDeploy.

---

## 6.3 Lire le code consommateur avant d'inventer un paramètre

Le backup SQL était déjà disponible dans le job, mais PlatformDeploy ne consommait pas directement son chemin. Il recherchait le fichier dans `Docker\Data`.

### Leçon

Quand un composant annonce « fichier absent », vérifier d'abord **où son code le cherche réellement** avant d'ajouter de nouveaux paramètres ou contournements. Le bon correctif a été de satisfaire son contrat existant.

---

## 6.4 Ne pas recopier aveuglément une commande d'un pipeline normal

Le pipeline normal publiait le JFrog CLI avec `--no-restore --no-build`. Ces options n'étaient valides que parce que des étapes antérieures avaient déjà restauré et construit la solution.

Dans le replay isolé :

- `--no-restore` est correct après `JFrogNuGet@1` ;
- `--no-build` aurait été incorrect.

### Leçon

Une commande ne peut pas être copiée indépendamment de ses préconditions. Il faut reconstruire la chaîne `restore -> build -> publish` et conserver uniquement les étapes réellement nécessaires.

---

## 6.5 Le premier échec réel est plus utile que le volume total de logs

Chaque correction a été choisie à partir du **premier blocage observable**.

### Leçon

Sur un pipeline complexe, progresser par **preuve causale** — `blocage -> preuve -> patch minimal -> replay` — est plus efficace qu'une investigation large immédiate.

---

## 6.6 Un diagnostic sécurisé doit être conçu comme une API

Le wrapper masquait volontairement `$raw` pour éviter les fuites de secrets. Le besoin de diagnostic ne justifiait pas de réafficher toute la sortie.

### Leçon

Lorsqu'un log brut peut contenir des secrets : ne pas faire `Write-Host $raw`, ne pas afficher arbitrairement les dernières lignes, parser uniquement les formats de lignes prouvés, appliquer une whitelist stricte et ne restituer que les champs nécessaires.

---

## 6.7 Un diagnostic vide est lui-même une information

Le run `4452826` a produit :

```text
PlatformDeploy failed; diagnostic:
```

Cela ne donne pas encore la cause, mais invalide une hypothèse : le chemin d'échec réel n'émet pas les lignes exactement sous la forme attendue par le filtre, ou l'échec arrive avant leur émission.

### Leçon

Un patch diagnostic doit lui aussi être testé comme une hypothèse. Si sa sortie reste vide, vérifier le format réel des objets capturés, le niveau de log, ou l'endroit exact où l'échec est généré.

---

## 6.8 Les scripts d'investigation doivent rester ciblés

Le travail a été plus efficace lorsque le LLM local recevait une mission limitée : une fonction, un fichier, un chemin, une hypothèse et une preuve attendue.

### Leçon

Pour les investigations Azure DevOps / PowerShell / PlatformDeploy : éviter les dumps massifs, demander des preuves courtes, produire des sorties déterministes et séparer investigation et modification.

---

# 7. Bonnes pratiques Git confirmées

Le workspace contenait une suppression préexistante sans rapport :

`Tests/Backups/AUTO_V26_00.bak`

Elle ne devait jamais être embarquée.

### Pratique utilisée

Toujours :

```text
git status
git diff
git diff --check
git commit --only <fichier>
```

Jamais :

```text
git add .
```

### Leçon

Dans un workspace long-lived ou partagé avec plusieurs investigations, `git commit --only` est une protection essentielle contre les commits parasites.

---

# 8. Collaboration efficace avec le LLM local

Le LLM local a été utilisé avec succès pour : recherche de code, inspection de fonctions ciblées, analyse d'un contrat de chemin, comparaison avec un pipeline normal, proposition d'un patch minimal, application d'un patch déjà décidé, commit/push/replay.

Approche efficace :

1. ChatGPT définit l'hypothèse ;
2. le LLM local la prouve ou la réfute ;
3. retour attendu structuré (`STATUS`, `CAUSE`, `EVIDENCE`, `MINIMAL_FIX`, `CONFIDENCE`) ;
4. validation ;
5. patch ;
6. diff ;
7. commit/push seulement après validation.

### Leçon

Le LLM local est particulièrement utile pour les tâches mécaniques et vérifiables. Pour une investigation ambiguë, il est préférable de lui donner le contexte essentiel, l'objectif unique, les contraintes et la forme de sortie attendue, sans lui imposer une stratégie technique trop détaillée.

---

# 9. Point de reprise si le travail redémarre plus tard

Dernier run : `4452826`

Dernier commit : `afe035ec73cdc0c376f0d57b23772186a7f5129c`

Premier blocage restant :

```text
The download of one or more packages has failed
```

Le patch diagnostic actuel produit :

```text
PlatformDeploy failed; diagnostic:
```

sans package ni code HTTP.

## Hypothèse de reprise

Avant toute nouvelle modification, inspecter précisément :

- la représentation réelle des éléments de `$raw` dans ce chemin d'échec ;
- les sorties exactes du CLI lorsqu'il échoue avant `Download package <filename>` ;
- si le mode `--azologs` transforme les lignes en commandes Azure DevOps du type `##[error]...`, ce qui pourrait expliquer que les regex actuelles ne matchent pas ;
- si le package courant est connu plus tôt via `Updating package <packageName>` même lorsque le nom du ZIP n'est jamais affiché ;
- si `downloadedPackages.json` ou un autre fichier temporaire partiel est créé avant l'abandon.

Toujours conserver les mêmes contraintes : aucun dump brut de secrets, pas de modification des pipelines normaux, pas de template partagé, une seule hypothèse à la fois, patch diagnostic minimal et replay isolé uniquement.

---

# 10. Conclusion

Le replay isolé Clienteling V26 n'a pas encore atteint JMeter, mais l'investigation a fortement réduit la distance au runtime réel.

Les blocages initiaux relevaient essentiellement de la **reconstruction du contrat d'exécution historique** : configuration, host, SQL, backup, secret, outil JFrog et dépendances PlatformDeploy.

Le replay atteint désormais le téléchargement réel des packages via le CLI JFrog.

Le principal enseignement de cette séquence est que la migration vers un replay isolé ne consiste pas simplement à « relancer le YAML » : il faut reconstruire explicitement toutes les dépendances implicites que le pipeline normal fournit autour de PlatformDeploy.

La méthode la plus fiable reste :

> **un premier blocage, une preuve, un patch minimal, un replay.**
