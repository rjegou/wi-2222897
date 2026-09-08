# Génération JMX réelle avec Console 2.0.43 candidate

Date : 2026-09-08 Europe/Paris. Collecte isolée, sans migration métier, SQL, HTTP, JMeter,
TestAutos, feed partagé, Promote ou tag.

## Provenance

FACT : package Console issu du build Azure DevOps `4445025`, commit Console
`dfda5e52e637e423432023d9fb6b870e92104703`, PipelineArtifact `Nuget` `5037277`.
Nupkg SHA-256 `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`.
Version `2.0.43-wi2222897-console-candidate`. DLL API embarquée SHA-256
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`; EXE Console
SHA-256 `AB4BBB596409B3A60107905E82577E9BC42C55467A8E602B7194DD2D8CE9B2AF`.

FACT : les plans et fichiers d'entrée/sortie ont été téléchargés par REST Azure DevOps depuis
`Y2_Plugins_FrenchTaxesRules`, commit `07a42172bebc65d17093e166ac08de22e4fe7248`, dans
`C:\clones\wi-2222897\.work\frenchtaxes-source-07a42172`. Le PAT n'a existé qu'en mémoire du
processus et n'est pas dans les preuves.

## Point d'entrée et commandes

FACT : `Testautos2Jmeter.bat` et `step_00_miseEnPlaceRepo.ps1` appellent
`Cegid.Retail.AutoTest.Console.exe --tstj=<campagne>.xml --dstFolder=<checkout>`. Le binaire
attend un XML racine `TestCampaign` dont `TestPlanItem.Item` pointe vers
`TestPlans\<plan>.xml`; invoquer directement un `TestPlan` échoue avec
`<TestPlan ...> n'était pas attendu`. Cette adaptation de prérequis est conservée dans
`make-campaign.ps1` et n'altère pas les plans source.

Commandes réellement exécutées, avec sorties conservées :

```text
Console.exe --tstj=.work\j\IntegratedTests\AutoTest\Data\Export_Run\Export_Run.xml --dstFolder=.work\j
exit 0; output Tests\Export_Run\001-Export_Run.jmx
Console.exe --tstj=.work\j\IntegratedTests\AutoTest\Data\DocumentSignature_SignOne\DocumentSignature_SignOne.xml --dstFolder=.work\j
exit 0; output Tests\DocumentSignature_SignOne\001-DocumentSignature_SignOne.jmx
```

Les logs `*.third.log.txt`/`*.third.stderr.txt` et `*.full.log.txt`/`*.full.stderr.txt` sont
conservés dans ce dossier. Les sorties sont sous `generated-jmx/`.

## Résultats

FACT : les deux campagnes prioritaires ont réussi code `0`, et les 19 plans top-level détectés
au commit source ont réussi code `0`, un JMX par plan : 10 `LegacyServices` et 9 `WebServices`.
Les hashes complets de chaque JMX sont dans `jmx-hashes.tsv`; le manifeste observé est
`manifest-observed.json`.

FACT : le JMX Export_Run a SHA-256
`C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C` et le JMX
DocumentSignature_SignOne a SHA-256
`432AA8C477E875652D4A4991D84DB19DB0B3790469EB2DE81212F85F0F341AE9`; les chemins exacts et hashes sont dans `jmx-hashes.tsv`. Aucun moteur
JMeter n'a été lancé : ces codes 0 sont des succès de génération Console uniquement.

## Écart de postcondition

FACT : `Write-Wi2222897JmxManifest.ps1` a été exécuté avec le package, la DLL API, la racine XML
source et `generated-jmx/`; il a échoué explicitement : `Expected exactly 32 generated JMX files,
found 19.` La sortie est conservée dans `manifest-32-attempt.log.txt`.

UNKNOWN : l'origine des 13 JMX supplémentaires attendus par ce manifeste. Le commit source
relue expose 19 plans top-level dans les dossiers `LegacyServices` et `WebServices`; aucun fichier
manquant n'a été inventé et aucun JMX utile n'a été supprimé.

## Opérations résiduelles

FACT : le contrôle local des processus attribuables à l'exécution interrompue n'a pas permis
d'établir un PID de worker : l'interrogation WMI des lignes de commande a été refusée et les
processus génériques observés n'étaient pas attribuables. Aucun processus Console actif n'était
présent à la fin de la génération. Ce contrôle ne constitue pas une preuve historique de
terminaison d'une annulation distante.

## Handoff immédiat V26

Voir `WORKER3-HANDOFF.md`. Les deux premiers JMX vérifiés sont disponibles sous
`generated-jmx/Export_Run/001-Export_Run.jmx` et
`generated-jmx/DocumentSignature_SignOne/001-DocumentSignature_SignOne.jmx`.
