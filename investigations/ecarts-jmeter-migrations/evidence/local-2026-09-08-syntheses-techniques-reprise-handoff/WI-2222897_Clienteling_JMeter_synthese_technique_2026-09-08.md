# WI-2222897 — Clienteling JMeter — Synthèse technique de reprise

**Date :** 2026-09-08  
**Périmètre :** Clienteling `master` / V26, pipeline isolé Azure DevOps `14264`  
**But de cette synthèse :** figer les éléments techniques prouvés avant la pause, afin de reprendre sans refaire les investigations déjà menées.

---

## 1. Objectif de la phase

L’objectif était de rendre possible un rejeu Clienteling V26 réellement comparable en environnement Docker, puis d’intégrer les wrappers de provisionnement/attestation déjà préparés avant de lancer :

`Build → GenerateJmx → JMeter Cur/Fix`

La priorité était d’obtenir des preuves runtime réelles avant de lancer les campagnes métier.

---

## 2. Pipeline isolé et agent Docker

### Pipeline utilisé

- Repo : `Y2_Plugins_Clienteling`
- Repo ID : `7776ac72-1788-4bea-9422-e5f0dacadc74`
- Branche isolée : `refs/heads/sandbox/clienteling/wi2222897-isolated-replay`
- Définition : `14264`
- YAML : `ci/wi2222897/azure-pipelines.clienteling-wi2222897.yml`

### Changement déjà publié

Le stage `TargetDiagnostic`, initialement sur le pool privé `Private VS2019`, a été modifié de façon minimale pour utiliser :

```yaml
pool:
  vmImage: windows-2025
```

Commit actuel de la branche isolée :

```text
c20755d802d1fb56a93289dd19b92622eb7f2c54
```

### Preuve

Run :

```text
4446303
```

Résultat :

- pipeline `succeeded`
- `Target diagnostic - hosted Windows 2025` : `succeeded`
- autres stages volontairement `skipped` avec `diagnosticOnly=true`
- OS : `Microsoft Windows NT 10.0.26100.0`
- Docker : `29.7.2`

### Conclusion

Le problème « les agents privés n’ont pas Docker » est clos pour ce besoin.

**Ne plus investiguer les agents privés A/B.**  
`windows-2025` est une cible valide pour la suite du pipeline isolé.

---

## 3. Wrappers runtime déjà préparés

Répertoire :

```text
C:\clones\wi-2222897\investigations\ecarts-jmeter-migrations\replay-prep\2026-09-08-clienteling-isolated\scripts
```

Scripts :

- `Invoke-Wi2222897PlatformDeploy.ps1`
- `Invoke-Wi2222897JmeterContainer.ps1`
- `Assert-Wi2222897ClientelingRuntime.ps1`
- `Remove-Wi2222897OwnedTarget.ps1`

Les quatre scripts ont été parsés sous PowerShell sans erreur.

Ils couvrent notamment :

- ownership strict des conteneurs/réseaux ;
- cleanup uniquement des ressources du run ;
- secret SQL absent des arguments ;
- création/vérification du `DataRoot` ;
- vérification SQL ;
- vérification `W3SVC` ;
- probes Clienteling Deployment/Mobility ;
- réseau Docker privé ;
- sidecar JMeter sur le même réseau ;
- attestation runtime.

**Ils ne doivent pas être réécrits sans défaut concret identifié.**

---

## 4. Valeurs PlatformDeploy V26 maintenant résolues

La meilleure preuve est le build historique Clienteling V26 :

```text
Build : 4432554
Commit : 1bcb509c38c31d337fcc5419c7b89d61a19fbe3a
```

Ce build avait réellement exécuté les campagnes Cur et Fix.

### Version PlatformDeploy

```text
PlatformDeploy 5.0.86
```

Archive installée historiquement :

```text
$(Agent.TempDirectory)\Y2.Tools.PlatformDeploy\PlatformDeploy.5.0.86.zip
```

Extraction :

```text
$(Agent.TempDirectory)\Deploy
```

### Script de déploiement

Valeur runtime résolue :

```text
$(Agent.TempDirectory)\Deploy\docker-pipeline-deploy.ps1
```

### DeployConfig Cur

```text
$(Agent.TempDirectory)\Deploy\Docker\data\v26-Cur.cy2px
```

### DeployConfig Fix

```text
$(Agent.TempDirectory)\Deploy\Docker\data\v26-Fix.cy2px
```

### Mode de base locale

Le build historique appelait bien :

```text
-LocalDBInContainer "Backup"
```

Les logs historiques montrent explicitement :

```text
docker-pipeline-deploy.ps1
  -deployConfig "...v26-Cur.cy2px"
  -LocalDBInContainer "Backup"
```

et :

```text
docker-pipeline-deploy.ps1
  -deployConfig "...v26-Fix.cy2px"
  -LocalDBInContainer "Backup"
```

---

## 5. Backup Clienteling V26

### Backup historique

```text
AUTO_V26_00.bak
```

Base associée :

```text
AUTO_V26_00
```

Tenant historique connu :

```text
TESTS_AUTO_JMETER
```

### Source utilisée dans le build 4432554

```text
$(Build.SourcesDirectory)\Y2_Plugins_Clienteling\Tests\Backups\AUTO_V26_00.bak
```

Le pipeline le copiait ensuite vers :

```text
$(Agent.TempDirectory)\Deploy\Docker\data\AUTO_V26_00.bak
```

### Empreinte Git LFS du backup

Le pointeur Git LFS du commit historique donne :

```text
SHA-256 : 8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C
Taille  : 156663808 octets
```

Cette empreinte est celle de l’objet LFS historique correspondant au `.bak`.

---

## 6. Découverte importante : le backup a disparu des branches actuelles

Vérifications effectuées :

### Branche isolée actuelle

Commit :

```text
c20755d802d1fb56a93289dd19b92622eb7f2c54
```

Résultat :

```text
Tests/Backups : NOT FOUND
```

### `master` actuel

Résultat :

```text
Tests/Backups : NOT FOUND
```

Donc le backup présent dans le build historique `4432554` n’est plus présent dans l’arbre Git actuel de `master` ni dans la branche isolée.

Ce point doit être traité avant le provisionnement réel.

---

## 7. Git LFS : mécanisme historique prouvé

Le checkout Clienteling du build `4432554` contenait explicitement :

```text
git lfs version
git lfs install --local
Git LFS initialized.
git ... lfs fetch origin 1bcb509c38c31d337fcc5419c7b89d61a19fbe3a
```

Donc le `.bak` historique était bien récupéré via **Git LFS**.

### `.gitattributes` historique

Le commit historique possède un `.gitattributes`.

La réponse REST obtenue via `download=true` a renvoyé les octets ASCII :

```text
42 42 47 84 101 115 116 115 ...
```

Décodés en UTF-8, ils correspondent à :

```gitattributes
**/Tests/Backups/*.bak filter=lfs diff=lfs merge=lfs -text
```

C’est donc bien la règle Git LFS historique appliquée aux backups.

### Situation de la branche isolée

La branche isolée actuelle ne contient pas de `.gitattributes` à la racine.

Elle ne déclare pas non plus explicitement :

```yaml
checkout: self
lfs: true
```

dans le YAML isolé.

---

## 8. Ce qui reste à faire au prochain démarrage

### Priorité 1 — rétablir proprement l’accès au backup

Il faut choisir une stratégie minimale et traçable permettant au pipeline isolé d’obtenir exactement l’objet :

```text
SHA-256 8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C
```

La piste naturelle à vérifier est de restaurer dans la branche isolée :

1. la règle `.gitattributes` historique ;
2. le pointeur LFS historique `Tests/Backups/AUTO_V26_00.bak` ;
3. un checkout avec `lfs: true`.

Ne pas pousser manuellement les 156 Mo dans Git classique.

Avant modification, confirmer que l’objet LFS historique est encore téléchargeable depuis Azure DevOps.

### Priorité 2 — intégrer les wrappers runtime dans 14264

Une fois le backup accessible :

- installer `PlatformDeploy 5.0.86` ;
- utiliser les `.cy2px` Cur/Fix résolus ;
- provisionner Clienteling avec `-LocalDBInContainer Backup` ;
- attester image, digest, backup, SQL, W3SVC, endpoints et réseau ;
- créer le sidecar JMeter sur le réseau privé ;
- vérifier le cleanup scoped.

### Priorité 3 — seulement après attestation PASS

Lancer :

```text
Build
→ GenerateJmx
→ JMeter V26-Cur
→ JMeter V26-Fix
```

avec les candidats déjà préparés :

```text
API build     : 4444962
Console build : 4445025
```

Puis comparer les résultats réels au baseline historique `4432554`.

---

## 9. Baseline historique Clienteling V26 à conserver

Build de référence :

```text
4432554
```

Runs JMeter historiques :

```text
Cur : 6180736
Fix : 6180750
```

Les deux avaient publié :

```text
2118 tests
485 cas non passés
```

Cette baseline est utile pour comparer les effets des corrections, mais ne doit pas être confondue avec une nouvelle preuve runtime.

---

## 10. Leçons techniques réutilisables

### Azure Pipelines

- Un stage vert ne prouve rien si les stages métier sont `skipped`.
- Vérifier explicitement la timeline du build avant de qualifier un run.
- Pour un besoin Docker Windows actuel, ne pas conclure à partir d’un agent privé ancien : `windows-2025` a ici fourni Docker `29.7.2`.

### PlatformDeploy

- Ne pas deviner les chemins runtime : les récupérer dans les logs d’un build qui a réellement exécuté le job.
- Pour Clienteling V26, les `.cy2px` sont fournis par le package PlatformDeploy, pas par le repo Clienteling.
- Les valeurs prouvées sont `v26-Cur.cy2px` et `v26-Fix.cy2px`.

### Git LFS

- La présence d’un `.bak` dans un ancien checkout ne signifie pas qu’il existe encore dans l’arbre Git actuel.
- Pour un fichier LFS, le SHA-256 de l’objet réel est disponible dans le pointeur Git :
  `oid sha256:<hash>`.
- Le checkout historique doit être inspecté pour savoir si `lfs fetch` a réellement été exécuté.
- Restaurer un pointeur LFS est préférable à republier manuellement un gros binaire si l’objet historique existe toujours côté serveur.

### REST Azure DevOps

- Pour les URLs PowerShell, utiliser `${Variable}` devant `?` pour éviter les erreurs d’interpolation.
- Pour les POST JSON sous Windows PowerShell 5.1, envoyer les octets UTF-8 plutôt qu’une chaîne JSON brute si nécessaire.
- L’API `/items` peut retourner des représentations différentes selon `includeContent`, `download`, `resolveLfs` et le type de client.
- Avec `download=true`, `Invoke-WebRequest` peut exposer le contenu sous forme d’octets ; insérer directement `.Content` dans une collection PowerShell peut donc produire une liste de nombres ASCII.
- Dans ce cas, décoder explicitement :

```powershell
[Text.Encoding]::UTF8.GetString([byte[]]$Response.Content)
```

plutôt que d’afficher directement `.Content`.

### Investigation

- Éviter les scans récursifs globaux : ils produisent beaucoup de bruit pour peu d’information.
- Préférer une source autoritative précise :
  1. build historique connu ;
  2. timeline ;
  3. log du job concerné ;
  4. blob Git exact au commit concerné.
- Une vérification à la fois permet de distinguer rapidement faits prouvés, hypothèses et données historiques.

---

## 11. État à la pause

### Résolu

- agent Docker compatible ;
- `windows-2025` validé ;
- version PlatformDeploy ;
- chemin du script PlatformDeploy ;
- `DeployConfig` Cur ;
- `DeployConfig` Fix ;
- mode `LocalDBInContainer Backup` ;
- chemin historique du backup ;
- SHA-256 et taille du backup ;
- mécanisme Git LFS historique ;
- règle `.gitattributes` historique.

### Non résolu

- méthode exacte retenue pour rendre le backup historique accessible dans la branche isolée ;
- vérification que l’objet LFS historique est toujours récupérable ;
- image Clienteling exacte + digest du nouveau run ;
- URLs exactes des probes Deployment/Mobility dans le nouveau runtime ;
- image JMeter exacte + digest du nouveau run ;
- intégration effective des wrappers dans le YAML 14264 ;
- attestation de provisionnement réelle ;
- nouveau rejeu Build → GenerateJmx → Cur/Fix.

---

## 12. Règle de reprise

À la reprise, **ne pas recommencer l’investigation agent / PlatformDeploy / backup depuis zéro**.

Le premier sujet à reprendre est :

> Vérifier que l’objet Git LFS `8B95C2BA...` est encore disponible côté Azure DevOps, puis choisir le changement minimal permettant à 14264 de matérialiser `Tests/Backups/AUTO_V26_00.bak` sur l’agent `windows-2025`.

Seulement ensuite intégrer le provisionnement runtime.
