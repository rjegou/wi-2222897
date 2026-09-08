---
type: "EvidenceCollection"
title: "Clienteling WI-2222897 — audit indépendant du replay isolé"
timestamp: "2026-09-08"
source_system: "local workspace and prior Azure DevOps readback evidence"
freshness: "2026-09-08 local audit; no remote mutation and no pipeline launch"
---

# Audit indépendant du contrat `stage-console-candidate.ps1`

## Périmètre et méthode

Audit du contenu local de `replay-prep/2026-09-08-clienteling-isolated` et du contrat
`stage-console-candidate.ps1` livré dans `local-2026-09-08-api-remote-readback-round3`.
Les scripts PowerShell ont été relus et le staging du candidat a été rejoué localement.
Aucun YAML n'a été modifié, aucune définition Azure DevOps n'a été créée et aucun run
n'a été lancé.

## FACT — candidat Console localement accepté

Le rejeu positif du 2026-09-08 a utilisé le package local suivant :

`C:\clones\wi-2222897-evidence\local-2026-09-07-soap-package-round14\checkPackage-tools-v2\Cegid.Retail.AutoTest.Console.2.0.42-soapnamespace.20260907-v2.nupkg`

Le manifeste produit par le script est conservé dans
`stage-console-manifest.json` dans ce dossier. Valeurs observées :

- source commit déclaré : `4c22cb2850a150161f44080815375527c4daad48` ;
- version nuspec : `2.0.42-soapnamespace.20260907` ;
- package SHA-256 : `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` ;
- API DLL embarquée : `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B` ;
- Console EXE : `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` ;
- publication déclarée par le script : `PipelineArtifact-only`, `sharedFeedPublication=false`.

Le script rejette par comparaison de hash l'autre package local portant la même version
mais le SHA-256 `F12F...361F5F`; ce n'est donc pas une preuve de consommation distante.

## FACT — incohérence de hash à corriger avant exécution

Le YAML local `azure-pipelines.clienteling-wi2222897.yml` attend par défaut
`57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B`, sans le segment
`34`. L'extraction directe du package `803D...EEE55B` et le manifeste positif montrent
la valeur avec `34` : `...CFCB73434FE...`.

Le README de `local-2026-09-08-console-candidate-round3` porte également la variante
sans `34`, tandis que le handoff API et le script audité portent la variante avec `34`.
Il s'agit d'une contradiction documentaire/référentielle. Pour le package `803D...EEE55B`,
la valeur effectivement observée est celle avec `34`; le YAML doit être aligné par le
propriétaire avant tout run. Le YAML n'a pas été modifié dans cette collecte.

## FACT — défaut de transport et de contrats d'entrée

- Le package candidat observé existe sous `C:\clones\wi-2222897-evidence`, pas dans un
  PipelineArtifact Azure DevOps identifié par un run/build exact.
- Les paramètres `apiBuildId`, `consoleBuildId`, `migrationBuildId` et
  `jmeterArtifactBuildId` ont une valeur par défaut vide.
- `targetAttestationArtifact` a une valeur par défaut vide et `Assert-Wi2222897ArtifactManifest.ps1`
  exige pourtant un fichier réel dont le scope, les hôtes et le `cleanupScope` sont dédiés.
- `migrationDefinitionId` est vide par défaut. Aucun manifest de migration distant avec
  le mapping XML source → JMX n'a été prouvé.
- `jmeterArtifactName=wi2222897-jmx` est utilisé à la fois pour migration et JMeter, alors
  que `Invoke-Wi2222897JmeterVariant.ps1` exige un `jmeter.bat` présent dans l'input.
  La présence d'un tel artefact dans le build `5224` n'est pas prouvée.
- Les chemins des scripts dans le YAML pointent vers
  `$(Build.SourcesDirectory)\investigations\...`; cette arborescence existe dans le
  workspace documentaire local mais sa présence dans le dépôt Clienteling exécuté n'est
  pas démontrée.

## FACT — dépendances Migration et limites fonctionnelles

La preuve Migration existante (`parallel/.../bw1-tools/evidence/migration`) démontre le
contrôle de cache pour une fixture Console `2.0.41` et le refus d'un cache incompatible.
Elle ne démontre pas la propagation du candidat `2.0.42` vers
`consoleWorkflowVersions.json`, `PublishedSharedTools/packages.config`, le cache de
l'agent, puis une génération JMX réelle. Le script de staging ne met à jour aucun de ces
emplacements : il copie seulement le nupkg et produit son manifeste.

Le script de régénération exige ensuite un `migration/manifest.json`, des fichiers XML
source, l'EXE Console et une commande Console réussie; aucun de ces résultats n'est
présent dans cette collecte. Le script JMeter exige un JMX manifest hashé, `jmeter.bat`
et une attestation Cur/Fix; aucun résultat `.jtl`, log ou manifest de campagne n'a été
produit.

## Verdict

**NOT READY / UNKNOWN pour l'exécution distante.** Le candidat est validé localement et
le commit API `4c22cb2850a150161f44080815375527c4daad48` est une référence de branche déjà
lue dans les preuves précédentes. En revanche, la consommation distante du nupkg, le
Build réel, la régénération/consommation JMX et les campagnes Cur/Fix ne sont pas prouvés.

Préconditions minimales avant lancement : aligner le hash API du YAML sur le package
retenu, fournir des IDs de builds et manifests exacts pour API/Console/Migration/JMeter,
transporter le nupkg dans un PipelineArtifact hashé, fournir une attestation de cible
isolée par variante, puis obtenir les preuves séparées Build, Cur et Fix. Tant qu'une
destination ou publication partagée est nécessaire, l'exécution doit s'arrêter.
