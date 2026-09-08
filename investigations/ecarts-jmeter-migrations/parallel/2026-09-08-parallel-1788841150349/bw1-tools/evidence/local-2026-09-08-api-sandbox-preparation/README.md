# Préparation reviewable — candidat API/Console Clienteling

Date de collecte : 2026-09-08. Périmètre : préparer le delta minimal pour une
exécution Azure DevOps isolée du candidat Console Clienteling, sans push, PR,
queue, publication de feed/JFrog, promotion ni tag.

## Verdict court

**FACT** — l'authentification PAT fournie par l'utilisateur est fonctionnelle
pour une lecture Azure DevOps : `az repos show` et `az repos ref list` ont
réussi avec un profil CLI temporaire et une variable de processus. Le secret
n'a pas été affiché, écrit dans ce dépôt, ni persisté.

**FACT** — le dépôt `Y2_Tools_AutoTest_Api` existe dans le projet `Retail` et
la branche distante suivante existe :

```text
refs/heads/sandbox/clienteling/api-jmeter-fixes
```

Elle pointe actuellement sur
`220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`, qui est aussi le `HEAD` master
référencé par le patch local. Aucun objet distant n'a été créé ou modifié.

**FACT** — le delta minimal reviewable est le patch API déjà extrait et
immuable dans [`patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch`](../../../../../../patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch).
Son SHA-256 est
`9D57E24B02212C453B70005FCB0975D95BDD79B3878455855EEB183EF0BAF5FB`.
Il modifie uniquement `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`.

Réapplication prévue, après obtention d'un clone dont le `HEAD` est vérifié :

```text
git apply patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch
```

Cette commande n'a pas été exécutée dans ce tour. Elle ne doit être exécutée
qu'après `git status --short --branch` et contrôle du `HEAD` exact.

## Corrections contenues dans le delta

Les quatre corrections sont dans `JmeterCodeGen.cs` :

1. `EscapeJdbcDate` conserve l'ordre ISO `yyyyMMdd` au lieu d'inverser mois et
   jour ;
2. `FixSqlUnicodeValue` parcourt les littéraux SQL, gère les apostrophes
   doublées et ajoute `N` uniquement aux littéraux Unicode ;
3. `RemoveSpecialCharsForXQuery` échappe d'abord `&`, puis `<`, `>` et
   l'apostrophe ;
4. `CleanXpath` conserve le nœud `Fault`, tandis que `PrepareXPathAssertion`
   produit une assertion SOAP 1.1 namespace-aware et active le paramètre
   JMeter correspondant.

**FACT** — ces quatre comportements passent sur la DLL réellement embarquée
dans le candidat local. La preuve détaillée est
[`local-2026-09-08-console-candidate-round3`](../local-2026-09-08-console-candidate-round3/README.md).

## Chaîne de dépendances et empreintes

| Élément | Identité / provenance | Empreinte ou état |
|---|---|---|
| Source API | `Y2_Tools_AutoTest_Api`, base `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` | branche sandbox distante sur cette base |
| Patch source | `JmeterCodeGen.cs`, quatre corrections | `9D57E24B02212C453B70005FCB0975D95BDD79B3878455855EEB183EF0BAF5FB` |
| DLL API candidate | `Cegid.Retail.AutoTest.Api.dll`, version assembly `1.1.46.0` | `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B` |
| Console candidate | package `Cegid.Retail.AutoTest.Console` `2.0.42-soapnamespace.20260907` | nupkg `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` |
| Console executable | `Cegid.Retail.AutoTest.Console.exe` embarqué | `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` |
| Migration | `Migration_Jmeter_RJE_Sandbox/migration-tools` | remplacement du nupkg et de la version restent à préparer et prouver |

**INFERENCE** — pour une exécution complète, le package Console candidat doit
être consommé par l'outil de migration, puis les JMX doivent être régénérés
depuis ce package. La présence de la branche API seule ne prouve pas cette
propagation.

## Contrat d'exécution Azure DevOps à conserver

Le futur YAML/definition isolé doit être relu avant toute queue et attester,
dans le commit effectivement exécuté :

- `trigger: none`, `pr: none`, `schedules: []` ;
- aucune étape aval, aucun push, feed/JFrog, promotion ou tag ;
- publication limitée à un `PipelineArtifact` expurgé des secrets ;
- un seul run manuel, ressources éphémères dédiées, nettoyage ciblé ;
- manifeste des commits, package, DLL, EXE, JMX effectivement consommés ;
- triggers automatiques désactivés et artefacts conservés même en échec.

**UNKNOWN** — aucun YAML de pipeline isolé n'est présent dans cette preuve et
aucun pipeline n'a été lancé. Ces garde-fous sont le contrat de préparation,
pas une preuve d'exécution.

## Blocages et limites

**FACT** — le clone local `C:\clones\Migration_Jmeter_RJE_Sandbox` existe,
mais `git status --short --branch` est refusé par Git pour `dubious ownership`.
Je n'ai pas modifié la configuration globale `safe.directory` et je n'ai pas
touché au clone.

**FACT** — le workspace documentaire partagé était déjà dirty avant cette
écriture ; cette collecte ajoute uniquement le présent dossier de preuve.

**UNKNOWN** — la publication du delta sur la branche distante, la mise à jour
du package de migration, la régénération JMX et tout résultat Build/JMeter
restent non réalisés. Le prochain worker doit résoudre l'accès au clone ou
recloner la source, vérifier le `HEAD`, appliquer le patch, compiler/package
localement, puis soumettre une définition isolée seulement après revue des
effets et triggers.
