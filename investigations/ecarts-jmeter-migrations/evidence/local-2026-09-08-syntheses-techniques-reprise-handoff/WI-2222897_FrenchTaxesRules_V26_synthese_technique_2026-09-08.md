# WI-2222897 — FrenchTaxesRules V26 — Synthèse technique au point de pause

**Date :** 2026-09-08  
**Périmètre :** reprise manuelle de la mission `FrenchTaxesRules` après interruption de BW.  
**Objectif atteint à ce stade :** obtenir une preuve runtime V26 isolée et fiable, puis préparer une branche de validation contenant les JMX corrigés.  
**Important :** aucun vrai run métier Cur/Fix/JMeter n'a encore été relancé avec les JMX corrigés au moment de cette pause.

---

## 1. Acquis amont conservés

Les investigations et corrections amont suivantes sont considérées comme acquises et n'ont pas été rejouées inutilement :

- API AutoTest corrigée :
  - build Azure DevOps `4444765`
  - définition `2637`
  - branche `sandbox/frenchtaxesrules/api-jmeter-fixes`
  - commit `9081ecfe7aa07f5e584073d2af1828d3ac9f7235`
  - version `1.1.47-wi2222897-api-candidate`
- Les 4 corrections `JmeterCodeGen` ont été exercées sur la DLL réellement construite :
  - dates SQL ;
  - Unicode ;
  - échappement XML ;
  - XPath SOAP.
- Console corrigée :
  - build `4445025`
- Génération FrenchTaxesRules :
  - `19/19 JMX`
- Le jeu de 19 JMX issu du build `4445025` a été retrouvé ici :

```text
C:\clones\wi-2222897\investigations\ecarts-jmeter-migrations\evidence\build-4445025-jmx-generation\generated-jmx
```

- Un second jeu local `.work\jfull\Tests` a été comparé au jeu canonique :
  - `19` JMX de chaque côté ;
  - `0` différence ;
  - `0` fichier supplémentaire.

Conclusion : le jeu corrigé des 19 JMX est figé et ne doit pas être régénéré sans contradiction factuelle nouvelle.

---

## 2. Préflight runtime V26 : terminé et vert

### Configuration utilisée

Dépôt :

```text
Y2_Plugins_FrenchTaxesRules
```

Repo ID :

```text
1d6b05fb-70bc-4884-adba-46d9e96651d8
```

Branche de préflight :

```text
refs/heads/sandbox/frenchtaxesrules/v26-preflight-20260908
```

Définition :

```text
14265 — WI2222897 FrenchTaxesRules V26 Runtime Preflight 20260908
```

Commit finalement testé :

```text
27644f216c9a056fa02a34a34c23e91687b1a5df
```

Image V26 :

```text
sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025
```

Digest attendu :

```text
sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2
```

### Run final

Build :

```text
4446410
```

Résultat :

```text
completed / succeeded
```

Commit réellement exécuté :

```text
27644f216c9a056fa02a34a34c23e91687b1a5df
```

Le commit attendu et le commit exécuté sont identiques.

### Preuves runtime obtenues

Le log final contient :

```text
WI2222897_V26_PREFLIGHT passed=true
```

avec :

```text
digest=...@sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2
imageOs=windows
imageArchitecture=amd64
mounts=0
dangerousMounts=0
hostPortBindings=0
forbiddenNetworks=0
```

Le cleanup contient :

```text
WI2222897_V26_PREFLIGHT_CLEANUP containerPresentAfterRemove=False
```

### Preuve du `docker start -a`

Le script réellement exécuté a été relu. L'enchaînement est :

1. validation du digest ;
2. `docker create` ;
3. `docker container inspect` ;
4. vérification mounts / réseaux / ports ;
5. assertion de whitelist ;
6. `Invoke-DockerBounded "start -a $containerId"` ;
7. écriture de la sortie dans `container-os.json` ;
8. seulement ensuite :
   `WI2222897_V26_PREFLIGHT passed=true` ;
9. cleanup final dans le `finally`.

Extrait essentiel :

```powershell
Invoke-DockerBounded "start -a $containerId" 120 (Join-Path $out 'docker-start') |
    Set-Content -LiteralPath (Join-Path $out 'container-os.json') -Encoding UTF8

Write-Host "WI2222897_V26_PREFLIGHT passed=true ..."
```

Comme le build est `succeeded` et que `passed=true` est écrit après `start -a`, le démarrage du conteneur et la collecte de l'OS sont considérés comme attestés.

### Conclusion préflight

Le préflight V26 est **définitivement vert** :

- digest correct ;
- `docker create` réussi ;
- inspection réussie ;
- aucun mount ;
- aucun mount dangereux ;
- aucun réseau interdit ;
- aucun host port binding ;
- `docker start -a` franchi ;
- OS du conteneur collecté ;
- assertion finale réussie ;
- conteneur temporaire supprimé.

---

## 3. Chaîne CI V26 réelle identifiée

Définition réelle du plugin :

```text
2054 — FrenchTaxesRules CI
```

### Master brut

Dernier master observé :

```text
Build 4436133
Branch refs/heads/master
Commit 07a42172bebc65d17093e166ac08de22e4fe7248
```

Résultat :

```text
completed / failed
```

Cause utile :

```text
dotNet-build: Sign binaries ...
```

Le build casse avant les tests. Il n'est donc pas pertinent comme preuve de la chaîne JMeter.

### Branche de migration V26 existante

Branche :

```text
refs/heads/FrenchTaxesRules_Migration_AutoTest_Jmeter_On_master
```

HEAD observé et revalidé :

```text
f80bc731571b2b5ed8a67da171b288873de428a6
```

Build de référence :

```text
4432510
```

Résultat :

```text
completed / partiallySucceeded
```

Ce build confirme que la chaîne V26 migrée fonctionne réellement :

- `Build V26` : succeeded ;
- déploiement Fix : succeeded ;
- déploiement Cur : succeeded ;
- `Test Y2 deployment` : succeeded des deux côtés ;
- JMeter LegacyServices Fix : exécuté ;
- JMeter LegacyServices Cur : exécuté ;
- JMeter WebServices Fix : exécuté ;
- JMeter WebServices Cur : exécuté ;
- les `PublishTestResults` sont en `succeededWithIssues`, ce qui explique le `partiallySucceeded`.

Cette branche constitue donc la bonne base pour la validation des JMX corrigés.

---

## 4. Mapping des 19 JMX corrigés vers la branche V26

La branche V26 contient exactement `19` JMX :

```text
/Tests/LegacyServices/001-Closing_AnnualClosing.jmx
/Tests/LegacyServices/002-Closing_DailyRegisterClosing.jmx
/Tests/LegacyServices/003-Closing_DailyStoreClosing.jmx
/Tests/LegacyServices/004-Closing_MonthlyClosing.jmx
/Tests/LegacyServices/005-DocumentSignature_SignOne.jmx
/Tests/LegacyServices/006-DocumentSignature_GetCustomerSigningVersion.jmx
/Tests/LegacyServices/007-DocumentSignature_GetDaemonSigningVersion.jmx
/Tests/LegacyServices/008-EventSignature_Sign.jmx
/Tests/LegacyServices/009-FrenchTaxesRules_Run.jmx
/Tests/LegacyServices/010-Export_Run.jmx
/Tests/WebServices/001-Validation_GetFrenchStores.jmx
/Tests/WebServices/002-Validation_ValidateEvents.jmx
/Tests/WebServices/003-Validation_ValidateClosingsV2.jmx
/Tests/WebServices/004-Validation_ValidateDocuments.jmx
/Tests/WebServices/005-Validation_ExportNf525.jmx
/Tests/WebServices/006-Validation_ValidateParam.jmx
/Tests/WebServices/007-Purge_CreateParam.jmx
/Tests/WebServices/008-Purge_GetParam.jmx
/Tests/WebServices/009-Purge_Execute.jmx
```

Le jeu généré local utilise des préfixes numériques différents, par exemple :

```text
001-Export_Run.jmx
```

alors que la branche contient :

```text
010-Export_Run.jmx
```

Le mapping a donc été fait par **nom fonctionnel après suppression du préfixe numérique**, et non par nom de fichier brut.

Résultat :

```text
Local JMX : 19
Mapped    : 19
Problems  : 0
```

---

## 5. Branche de validation créée

Avant création :

- HEAD de la branche source revalidé ;
- source toujours sur `f80bc731...` ;
- branche cible absente.

Branche créée :

```text
refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908
```

HEAD initial :

```text
f80bc731571b2b5ed8a67da171b288873de428a6
```

La création REST a été vérifiée :

```text
REST success : True
REST status  : succeeded
HEAD CORRECT : True
```

Une deuxième tentative de création a correctement détecté :

```text
TARGET EXISTS : True
STATUS : STOP - NO WRITE PERFORMED
```

Ce comportement confirme que le garde-fou d'idempotence a fonctionné.

---

## 6. Comparaison branche / JMX corrigés

Les 19 JMX de la branche ont été comparés par SHA-256 avec le jeu corrigé local.

Résultat :

```text
Identical : 1
Different : 18
Problems  : 0
```

Le seul fichier déjà identique n'a pas été republié.

Les 18 autres JMX ont été préparés pour remplacement.

---

## 7. Push des 18 JMX corrigés

Avant écriture :

```text
Expected HEAD : f80bc731571b2b5ed8a67da171b288873de428a6
Actual HEAD   : f80bc731571b2b5ed8a67da171b288873de428a6
HEAD MATCH    : True
```

Le push REST a utilisé :

- un seul commit ;
- `oldObjectId = f80bc731...` ;
- uniquement les 18 fichiers réellement différents.

Push ID :

```text
5136500
```

Nouveau commit :

```text
c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24
```

Vérifications post-push :

```text
HEAD after push  : c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24
HEAD = commit    : True
JMX changes      : 18
Missing changes  : 0
Unexpected JMX   : 0
```

Statut final :

```text
STATUS : 18 CORRECTED JMX PUSHED AND VERIFIED
```

### État courant à retenir

Branche de validation :

```text
refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908
```

HEAD actuel :

```text
c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24
```

Ce commit contient les 18 remplacements nécessaires ; le 19e JMX était déjà identique.

---

## 8. Ce qui n'a PAS encore été fait

Au moment de la pause :

- aucun nouveau run de `FrenchTaxesRules CI` n'a encore été lancé sur
  `c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24` ;
- aucun résultat Cur/Fix corrigé n'est donc encore disponible ;
- aucun scénario métier n'a encore été validé avec les JMX corrigés ;
- aucune campagne complète n'a été relancée ;
- aucune PR n'a encore été créée pour cette validation ;
- aucune promotion / publication / tag / TestAutos inutile n'a été déclenché.

---

## 9. Prochaine étape à la reprise

Reprendre directement depuis :

```text
Branch:
refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908

HEAD:
c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24

Pipeline:
2054 — FrenchTaxesRules CI
```

Ne pas recommencer :

- le diagnostic API ;
- la compilation API ;
- la Console ;
- la génération des JMX ;
- le préflight runtime V26 ;
- le mapping des 19 JMX ;
- la comparaison des 19 JMX ;
- le push des JMX corrigés.

L'objectif immédiat à la reprise est de préparer puis exécuter les scénarios minimaux déjà retenus, dans cet ordre :

1. `Export_Run TC08`
2. `Export_Run TC09`
3. `Export_Run TC10`
4. `DocumentSignature_SignOne TC02`

Contraintes à conserver :

- comparabilité Cur/Fix ;
- mêmes données ;
- même backup ;
- même pile ;
- même image ;
- aucune publication/promotion/tag/TestAutos inutile ;
- ne jamais assouplir une assertion simplement pour obtenir du vert.

---

# Leçons techniques apprises

## 10. Azure DevOps REST : toujours verrouiller les écritures

Avant chaque écriture sur une branche existante :

1. relire le HEAD réel ;
2. comparer au HEAD attendu ;
3. utiliser ce SHA comme `oldObjectId`.

Ce mécanisme évite de pousser sur une branche qui aurait bougé entre l'investigation et l'écriture.

Pour créer une branche, utiliser :

```text
oldObjectId = 0000000000000000000000000000000000000000
```

et vérifier auparavant que la ref cible n'existe pas.

Après toute écriture :

- relire la ref ;
- vérifier que son HEAD correspond exactement au commit produit ;
- relire les changements du commit et contrôler qu'il n'y a ni fichier manquant ni fichier inattendu.

---

## 11. PowerShell 5.1 : attention aux tableaux JSON à un seul élément

Lors de la création d'une ref Azure DevOps, ceci a échoué :

```powershell
$BodyObject | ConvertTo-Json
```

Azure DevOps a répondu :

```text
Value cannot be null.
Parameter name: refUpdates
```

Cause : PowerShell 5.1 a déroulé le tableau à un élément et envoyé un objet au lieu d'un tableau JSON.

Utiliser :

```powershell
ConvertTo-Json -InputObject $RefUpdates
```

quand l'API exige explicitement un tableau, même s'il ne contient qu'un seul élément.

---

## 12. PowerShell interactif : éviter les constructions fragiles au collage

Deux problèmes rencontrés :

### `finally`

Dans un collage interactif PowerShell 5.1, un bloc `finally` peut être interprété séparément si le collage est découpé, donnant :

```text
finally : Le terme «finally» n'est pas reconnu...
```

Pour les petits scripts d'investigation collés dans la console, préférer une structure simple et éviter `finally` quand il n'est pas indispensable.

### Variable suivie immédiatement de `?`

Une URL écrite ainsi :

```powershell
".../builds/$BuildId?api-version=7.1"
```

a produit un mauvais résultat.

Préférer :

```powershell
".../builds/${BuildId}?api-version=7.1"
```

pour délimiter explicitement le nom de variable.

---

## 13. `$Matches` est une variable automatique PowerShell

Le premier script d'extraction de logs utilisait :

```powershell
$Matches = ...
```

et effectuait ensuite des tests avec `-match`.

Or `$Matches` est une variable automatique mise à jour par l'opérateur `-match`.

Résultat observé :

```text
System.Collections.Hashtable
```

à la place de la collection attendue.

Ne jamais utiliser `$Matches` comme nom de variable métier.

Préférer par exemple :

```powershell
$EvidenceLines
```

et, si nécessaire, utiliser :

```powershell
[regex]::IsMatch(...)
```

pour éviter les effets de bord.

---

## 14. Une ligne de succès n'est une preuve que si l'ordre du code est connu

Le log du préflight contenait :

```text
WI2222897_V26_PREFLIGHT passed=true
```

mais ne montrait pas directement la sortie de `docker start -a`, car `Invoke-DockerBounded` la stockait dans des fichiers.

Au lieu de relancer inutilement le pipeline, la bonne méthode a été de relire le script réellement exécuté et de démontrer que :

```text
docker start -a
    ↓
collecte container-os.json
    ↓
passed=true
```

Ainsi, un build `succeeded` contenant `passed=true` démontre que le `docker start -a` placé avant a terminé sans exception.

Leçon : quand les sorties sont redirigées, raisonner sur **l'ordre d'exécution et les points de throw**, pas uniquement sur les lignes visibles dans le log.

---

## 15. JMX : ne pas mapper par préfixe numérique

Les JMX générés corrigés utilisent par exemple :

```text
001-Export_Run.jmx
```

alors que la branche migrée utilise :

```text
010-Export_Run.jmx
```

Une copie naïve par nom complet aurait donc été incorrecte.

La stratégie robuste a été :

1. supprimer le préfixe `^\d+-` ;
2. comparer le nom fonctionnel restant ;
3. exiger exactement un match local et un match distant ;
4. refuser l'écriture si un mapping est ambigu.

Résultat :

```text
19 mapped / 0 problems
```

---

## 16. Ne pousser que les fichiers réellement différents

Avant le push, les fichiers distants ont été téléchargés et comparés au SHA-256 avec les fichiers locaux.

Résultat :

```text
1 identique
18 différents
```

Seuls les 18 fichiers différents ont été envoyés.

Bénéfices :

- commit plus lisible ;
- moins de bruit de diff ;
- meilleure traçabilité ;
- vérification post-push simple ;
- absence de modification artificielle du fichier déjà correct.

---

## 17. Séparer preuve runtime et preuve métier

Le préflight `4446410` ne valide pas FrenchTaxesRules fonctionnellement.

Il valide uniquement que l'environnement V26 ciblé peut être exécuté de manière isolée et conforme :

- image exacte ;
- digest exact ;
- absence de mounts dangereux ;
- absence de réseau interdit ;
- absence de host ports ;
- démarrage du conteneur ;
- cleanup propre.

La validation métier doit être faite ensuite via la vraie chaîne :

```text
Build V26 → Deploy Cur/Fix → JMeter Cur/Fix
```

Ne pas mélanger ces deux niveaux de preuve.

---

## 18. Toujours vérifier qu'un pipeline a réellement atteint JMeter

Le build master `4436133` échoue pendant la signature des binaires et ne donne donc aucune information sur JMeter.

À l'inverse, `4432510` fournit une vraie baseline parce qu'on observe explicitement :

- Build V26 succeeded ;
- déploiement Cur/Fix succeeded ;
- Test Y2 deployment succeeded ;
- Run JMeter LegacyServices Cur/Fix ;
- Run JMeter WebServices Cur/Fix.

Le résultat global `partiallySucceeded` est moins important que la timeline réelle des stages.

---

## 19. Garder les investigations très ciblées

Les investigations les plus efficaces ont utilisé :

- un Build ID précis ;
- un Log ID précis ;
- un petit jeu de motifs ;
- quelques dizaines de lignes maximum ;
- un TXT temporaire ouvert automatiquement dans Notepad.

Éviter les dumps complets de timeline ou de logs quand une seule preuve est recherchée.

Cela réduit fortement :

- le bruit ;
- le risque de manquer l'information importante ;
- le volume à copier-coller ;
- le temps d'analyse.

---

## 20. Résumé de reprise ultra-court

```text
PRECHECK V26
Build 4446410
Commit 27644f216c9a056fa02a34a34c23e91687b1a5df
Result succeeded
Runtime isolation attested

BASELINE PIPELINE
2054 — FrenchTaxesRules CI
Migration branch HEAD before validation:
f80bc731571b2b5ed8a67da171b288873de428a6
Reference build:
4432510

CORRECTED JMX
19/19 canonical set confirmed
18 differed from branch
1 already identical

VALIDATION BRANCH
refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908

CURRENT HEAD
c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24

PUSH
5136500
18 corrected JMX changed
0 missing
0 unexpected

NEXT
Run minimal corrected V26 validation:
Export_Run TC08
then TC09 / TC10
then DocumentSignature_SignOne TC02
```
