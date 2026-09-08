# WI-2222897 — Complément au handoff technique
## Nouvelles preuves acquises après le handoff du 2026-09-07

Ce document complète :

```text
WI-2222897_JMeter_Legacy_Technical_Handoff_2026-09-07.md
```

Il ne remplace pas le handoff précédent. Il documente uniquement les avancées obtenues après sa rédaction.

---

## 1. Résumé des nouvelles conclusions

Trois avancées majeures ont été obtenues :

1. la DLL finale `57BE...` a été démontrée comme contenant **les trois corrections** :
   - SOAP namespace-aware ;
   - `EscapeJdbcDate` ;
   - `FixSqlUnicodeValue` ;

2. les corrections SQL Unicode et date ont été démontrées non seulement au niveau de la DLL, mais aussi via la chaîne réelle :

```text
DLL finale
→ package/runtime Console
→ génération JMX
→ requête JDBC finale
```

3. le cas réel :

```text
Y2_Plugins_FrenchTaxesRules
releases/V5
V23
Cur = OK
Fix = failJob InitializeContainers
```

a été retrouvé dans Azure DevOps et diagnostiqué.

La cause du run Fix étudié n'est pas un défaut JMeter ni un mauvais package applicatif observé : le job échoue avant cela parce que le daemon Docker n'est pas disponible sur l'agent Azure Pipelines utilisé.

---

# 2. DLL finale consolidée

## 2.1 DLL concernée

SHA256 :

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B
```

Cette DLL avait déjà été validée pour le correctif SOAP.

Une validation complémentaire a été faite directement contre ce binaire, sans rebuild.

---

## 2.2 EscapeJdbcDate

Le source du worktree contient bien :

```csharp
query = Regex.Replace(query, @"'(\d{4})-(\d{2})-(\d{2})'", "'${1}${2}${3}'");
```

et :

```csharp
query = Regex.Replace(
    query,
    @"(?<![\w'])\b(\d{4})-(\d{2})-(\d{2})\b(?![\w'])",
    "'${1}${2}${3}'"
);
```

La DLL finale `57BE...` a ensuite été testée directement par réflexion.

Vecteurs contrôlés :

```text
INPUT:    '2026-09-07'
EXPECTED: '20260907'
ACTUAL:   '20260907'
PASS:     True
```

et :

```text
INPUT:    datecol = 2026-09-07
EXPECTED: datecol = '20260907'
ACTUAL:   datecol = '20260907'
PASS:     True
```

Conclusion :

```text
ESCAPE_JDBC_DATE_POSTCONDITION: PASS
```

**FACT**

La DLL finale contient et exécute correctement le correctif `EscapeJdbcDate`.

---

## 2.3 FixSqlUnicodeValue

Le source confirme que `FixSqlUnicodeValue` est appelé dans le flux normal de transformation SQL avant `EscapeJdbcDate`.

Test direct contre la DLL finale :

```text
INPUT:
SELECT 'NN''é' AS V

EXPECTED:
SELECT N'NN''é' AS V

ACTUAL:
SELECT N'NN''é' AS V

PASS: True
```

Conclusion :

```text
FIX_SQL_UNICODE_POSTCONDITION: PASS
```

---

## 2.4 Conclusion consolidation DLL

Résultat global :

```text
FINAL_DLL_POSTCONDITION: PASS
```

**FACT**

La même DLL finale :

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B
```

contient donc bien :

```text
SOAP namespace-aware
+
EscapeJdbcDate
+
FixSqlUnicodeValue
```

Il n'est plus nécessaire de reconstruire une nouvelle DLL uniquement pour consolider ces trois corrections.

---

# 3. Propagation SQL/date à travers le package et la Console

## 3.1 Objectif

La validation directe de la DLL n'était pas suffisante.

Il fallait démontrer que les transformations survivent au chemin réel :

```text
package
→ runtime Console
→ lecture plan XML
→ génération JMX
→ requête JDBC
```

---

## 3.2 Fixture réel utilisé

Un vrai `Control` SQL déjà présent dans le plan a été utilisé comme point d'injection.

Contrôle d'origine :

```xml
<Control Id="891ff160-bcf4-406a-b3b0-82c0378b368d">
  <Label>update Keywords</Label>
  <Query>UPDATE MARTICLEMOTCLE ...</Query>
  <ExpectedValue>1</ExpectedValue>
</Control>
```

Dans un staging isolé uniquement, il a été remplacé par un vecteur non destructif :

```xml
<Control Id="891ff160-bcf4-406a-b3b0-82c0378b368d">
  <Label>RJE_PROPAGATION_VECTOR_UNICODE_DATE</Label>
  <Query>SELECT 'NN''é' AS UnicodeValue, '2026-09-07' AS DateValue</Query>
  <ExpectedValue>1</ExpectedValue>
</Control>
```

Le choix d'un `SELECT` évite toute écriture SQL éventuelle.

---

## 3.3 Runtime utilisé

La DLL réellement chargée par la Console avait bien le SHA256 :

```text
57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B
```

Le JMX cible était explicitement supprimé avant la génération :

```text
JMX EXISTS BEFORE RUN: False
```

Le générateur a terminé correctement :

```text
DIAGNOSTIC EXIT CODE: 0
JMX EXISTS AFTER RUN: True
```

Le wrapper a confirmé :

```text
LOADED_API=C:\Temp\wi2222897-sqlprop\runtime\Cegid.Retail.AutoTest.Api.dll
```

---

## 3.4 Requête JDBC générée

Dans le JMX produit :

```xml
<stringProp name="query">
SELECT N&apos;NN&apos;&apos;é&apos; AS UnicodeValue, &apos;20260907&apos; AS DateValue
</stringProp>
```

Une fois le XML décodé :

```sql
SELECT N'NN''é' AS UnicodeValue, '20260907' AS DateValue
```

C'est exactement la transformation attendue.

---

## 3.5 Faux négatif PowerShell rencontré

Un premier contrôle avait donné :

```text
UNICODE FIX PRESENT: False
```

alors que le JMX contenait visiblement la bonne transformation.

Deux causes de faux négatif ont été identifiées.

### XML entities

Le fichier brut contient :

```text
&apos;
```

et non directement :

```text
'
```

Une recherche texte brute sur :

```text
N'NN''é'
```

échoue donc logiquement.

### Encodage PowerShell 5.1

Une lecture via :

```powershell
Get-Content -Raw
```

avait également produit :

```text
é
→
Ã©
```

Le fichier n'était pas corrompu.

Le problème venait de la lecture du fichier UTF-8 par Windows PowerShell 5.1.

---

## 3.6 Validation finale correcte

Le JMX a été relu via :

```text
System.Xml.XmlDocument.Load()
```

qui respecte l'encodage XML.

Résultat :

```text
QUERY READ BY XmlDocument.Load():
SELECT N'NN''é' AS UnicodeValue, '20260907' AS DateValue
```

Postconditions :

```text
UNICODE FIX PRESENT: True
DATE FIX PRESENT: True
ORIGINAL DATE GONE: True
EXACT EXPECTED QUERY: True
UTF8 C3 A9 BYTE SEQUENCE FOUND: True
```

Résultat final :

```text
PACKAGE_SQL_PROPAGATION_POSTCONDITION=PASS
```

JMX SHA256 :

```text
B392ED9DA7DF1C4E2CA0F7144BBFA50B56C2070649CD59411B6ACFBB2CE18A4F
```

---

## 3.7 Conclusion propagation

**FACT**

Les trois corrections sont désormais prouvées dans la même chaîne réelle :

```text
source
→ DLL finale 57BE...
→ package/runtime Console
→ génération JMX
```

avec :

```text
SOAP namespace-aware
+
SQL Unicode
+
date JDBC
```

Le sujet principal n'est donc plus la consolidation du générateur.

---

# 4. Nouvelle leçon PowerShell / XML

Pour les fichiers XML UTF-8 contenant des caractères non ASCII :

### À éviter comme preuve sémantique sous Windows PowerShell 5.1

```powershell
Get-Content -Raw
```

lorsque l'encodage du fichier n'est pas explicitement maîtrisé.

### Préférer

```powershell
$xml = New-Object System.Xml.XmlDocument
$xml.Load($path)
```

puis lire :

```powershell
$node.InnerText
```

Cela permet :

- le décodage correct des XML entities ;
- le respect de l'encodage déclaré ;
- l'absence de faux négatifs `é` / `Ã©`.

---

# 5. Investigation du cas FrenchTaxesRules releases/V5 V23

## 5.1 Cas recherché

Le cas fonctionnel à retrouver était :

```text
Y2_Plugins_FrenchTaxesRules
releases/V5
V23
Cur : 0 fail
Fix : failJob InitializeContainers
```

Le build Azure DevOps exact a été identifié :

```text
Build ID: 4429167
```

---

## 5.2 Timeline V23

Dans ce build :

```text
TI Jmeter V23-Cur
→ succeeded
```

et :

```text
TI Jmeter V23-Fix
→ failed
```

Le job Fix échoue sur :

```text
Initialize containers
```

Les campagnes JMeter V23-Fix suivantes sont ensuite :

```text
skipped
```

Donc :

**FACT**

Aucun test JMeter V23-Fix n'a réellement été exécuté dans ce run.

---

# 6. Cause exacte du fail InitializeContainers

Log concerné :

```text
Build ID: 4429167
Log ID: 449
```

Le job exécute :

```text
C:\Windows\system32\docker.EXE version --format '{{.Server.APIVersion}}'
```

Le message d'erreur est :

```text
failed to connect to the docker API at npipe:////./pipe/docker_engine;
check if the path is correct and if the daemon is running:
open //./pipe/docker_engine:
The system cannot find the file specified.
```

Le pipeline retente plusieurs fois avec backoff de 10 secondes.

Après quatre tentatives :

```text
Exit code 1 returned from process:
C:\Windows\system32\docker.EXE
version --format '{{.Server.APIVersion}}'
```

---

## 6.1 Conclusion immédiate

**FACT**

Le run V23-Fix étudié échoue parce que le client Docker n'arrive pas à joindre le daemon Docker.

Il ne s'agit pas d'un échec d'un test JMeter.

Il ne s'agit pas non plus d'une preuve d'un problème de package Fix, car le pipeline n'atteint pas les étapes où ce package pourrait réellement être testé.

---

# 7. Comparaison des agents Cur / Fix

Les jobs V23 Cur et Fix n'ont pas utilisé le même agent.

### V23-Cur

```text
workerName: Azure Pipelines 51
result: succeeded
```

L'initialisation des containers réussit également sur :

```text
Azure Pipelines 51
```

### V23-Fix

```text
workerName: Azure Pipelines 21
result: failed
```

L'échec `Initialize containers` se produit sur :

```text
Azure Pipelines 21
```

D'autres jobs du même build ont également réussi à initialiser Docker sur :

```text
Azure Pipelines 41
Azure Pipelines 53
```

---

## 7.1 Conclusion infrastructure

**INFERENCE FORTE**

La meilleure explication actuelle est :

```text
agent Azure Pipelines 21 défaillant ou état Docker transitoire
```

et non :

```text
défaut de la migration JMeter
```

ou :

```text
mauvais packaging Fix
```

Le daemon Docker semble simplement ne pas avoir été disponible sur l'agent 21 au moment du job.

---

# 8. Impact sur l'hypothèse de Ludo

Hypothèse de départ :

> lorsqu'il y a 0 fail sur Cur et des fails sur Fix, il peut s'agir d'un mauvais packaging/version Fix ; essayer les versions issues d'un packaging supérieur.

Cette hypothèse reste potentiellement pertinente pour d'autres écarts.

Mais pour :

```text
build 4429167
V23-Fix
```

elle n'explique pas l'échec observé.

Pourquoi :

```text
Initialize containers
échoue avant l'exécution des campagnes JMeter
```

et l'erreur est exclusivement liée à :

```text
docker_engine
```

---

# 9. Action suivante recommandée sur V23-Fix

Chercher un autre build contenant le même couple :

```text
FrenchTaxesRules
releases/V5
V23-Fix
```

et vérifier :

1. si `Initialize containers` y réussit ;
2. quel agent a été utilisé ;
3. si les campagnes JMeter Fix s'exécutent alors réellement ;
4. seulement ensuite, comparer les résultats Cur/Fix.

### Critère de clôture de l'incident Docker

Si un nouveau run V23-Fix :

```text
utilise un autre agent
+
passe Initialize containers
```

alors le fail du build `4429167` pourra être classé avec une très forte confiance comme :

```text
incident infrastructure transient lié à l'agent
```

---

# 10. État de confiance mis à jour

| Sujet | Statut | Confiance |
|---|---|---|
| SOAP namespace-aware dans DLL 57BE | démontré | très élevée |
| EscapeJdbcDate dans DLL 57BE | démontré | très élevée |
| FixSqlUnicodeValue dans DLL 57BE | démontré | très élevée |
| DLL unique consolidant les trois corrections | démontré | très élevée |
| Propagation SQL Unicode package → JMX | démontré | très élevée |
| Propagation date package → JMX | démontré | très élevée |
| Encodage Unicode correct dans le JMX | démontré | très élevée |
| Build cible FrenchTaxesRules V23 retrouvé | démontré | très élevée |
| V23-Cur réussi | démontré | très élevée |
| V23-Fix échoue sur InitializeContainers | démontré | très élevée |
| Cause immédiate : daemon Docker inaccessible | démontré | très élevée |
| Fix et Cur sur agents différents | démontré | très élevée |
| Agent 21 défaillant/transitoire | très probable | élevée |
| Mauvais package Fix responsable du build 4429167 | non supporté par les preuves | faible |
| Hypothèse de Ludo sur d'autres runs | toujours à tester | ouverte |

---

# 11. Nouvelle séquence recommandée

L'ordre de travail recommandé devient désormais :

```text
1. Ne plus retravailler SOAP / EscapeJdbcDate / FixSqlUnicodeValue
   sauf nouvelle postcondition ou changement du binaire.

2. Canonicaliser les preuves finales :
   - DLL 57BE consolidée ;
   - SQL Unicode ;
   - date JDBC ;
   - package → Console → JMX ;
   - piège d'encodage PowerShell 5.1.

3. Rechercher un autre run FrenchTaxesRules releases/V5 V23-Fix.

4. Vérifier si InitializeContainers passe sur un autre agent.

5. Si Docker passe :
   analyser enfin les vrais résultats JMeter Fix.

6. Comparer alors Cur/Fix.

7. Tester l'hypothèse de Ludo uniquement sur les cas où
   le pipeline atteint réellement l'exécution des tests Fix.

8. Ne pas compter un failJob d'infrastructure comme un écart fonctionnel JMeter.
```

---

# 12. Principe important pour la suite

Les écarts doivent désormais être classés explicitement en deux catégories :

```text
A. écarts de résultats de tests
B. échecs structurels de pipeline
```

Exemple :

```text
Cur = 0 fail
Fix = failJob InitializeContainers
```

ne doit pas être interprété comme :

```text
Fix possède des tests en échec
```

mais comme :

```text
Fix n'a pas été exécuté
```

Cette distinction évite de rechercher inutilement un défaut de générateur ou de package alors que le pipeline est bloqué avant l'exécution.

---

# 13. Conclusion

Depuis le handoff précédent, la partie générateur a gagné un niveau de preuve supplémentaire important :

```text
SOAP + Unicode SQL + date JDBC
```

sont maintenant démontrés dans une même DLL finale et dans le chemin réel de génération JMX.

En parallèle, le premier cas structurel V23-Fix étudié a été expliqué :

```text
Build 4429167
V23-Cur → OK sur Azure Pipelines 51
V23-Fix → échec sur Azure Pipelines 21
InitializeContainers → Docker daemon inaccessible
```

La priorité doit donc passer des corrections locales du générateur à la qualification systématique des vrais runs Cur/Fix, en séparant :

```text
erreur fonctionnelle JMeter
```

de :

```text
incident infrastructure/pipeline.
```
