# Handoff Console SOAP namespace — Worker 3 round 4

Date : 2026-09-08 (Europe/Paris). Lecture seule; aucun upload, feed, push, mutation distante ou relance.

## Provenance et fichiers localisés

La piste annoncée renvoie à la preuve [worker 1 round 5](../../../../evidence/2026-09-07-brain-reprise-worker1-round5/README.md), indexée dans l'index des preuves. `EXTERNAL-ARTIFACTS.md` signale ce lot comme artefacts bruts hors dépôt (94,3 Mo). Le staging temporaire documenté existe encore :

`C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\`

Fichiers vérifiés :

| Objet | Chemin absolu | Hash constaté |
|---|---|---|
| package NuGet | `C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\migration-tools\Cegid.Retail.AutoTest.Console.nupkg` | `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` |
| API dans `tools/` du package | entrée `tools/Cegid.Retail.AutoTest.Api.dll` | `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B` |
| Console dans `tools/` du package | entrée `tools/Cegid.Retail.AutoTest.Console.exe` | `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` |
| descriptor | `C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\Y2_Plugins_Clienteling\Tests\WebServices.xml` | `44298C138F351364B628A0C15B7D3972808CA6A9ACE72432F31F94A764F91FC1` |

Les deux hashes internes ont été recalculés directement depuis les entrées ZIP, sans extraction ni écriture. Le package embarque bien les deux fichiers aux chemins `tools/`.

## JMX, plugin et paramètres

Le dossier plugin contient `151` fichiers `.jmx`. Comparaison par nom et SHA-256 avec `JMX-SHA256SUMS.txt` de la preuve : `151/151` correspondances, `0` manquante, `0` divergente. Le descriptor consommé est `IntegratedTests/AutoTest/Data/WebServices/WebServices.xml` (chemin dans la copie staging : `Y2_Plugins_Clienteling\Tests\WebServices.xml`). La sortie documente 3 plans Deployment FullTextSearch et 2 plans Mobility ClientelingParameters.

**FACT** — la preuve directe couvre la chaîne locale package → DLL → Console → descriptor → 151 JMX, avec parsing XML réussi. Le staging plugin a le HEAD Git `0c0fd26533e46b13e029276f90b5c085c1804012`, branche `master`, mais il est sale et ce HEAD n'est pas un commit InventoryTracking. Le commit d'origine du package/Console SOAP et les paramètres complets du dispatcher ne sont pas établis au-delà de la provenance de la preuve.

**ANNONCE utilisateur, confirmée sur les artefacts disponibles** — version `2.0.42-soapnamespace.20260907` et les trois empreintes annoncées correspondent au package et à ses entrées internes recalculées ci-dessus.

## Portée et rapport avec InventoryTracking

**FACT** — le correctif SOAP namespace-aware cible les contrôles contenant `soap:Fault`, en générant une XPath namespace-aware avec l'URI SOAP 1.1; les contrôles non SOAP conservent le chemin observé `//Result` avec namespace désactivé. La preuve round13 couvre aussi un rejeu JMeter 5.6.3 synthétique positif/négatif.

**UNKNOWN** — la présence et la consommation de ce package par les JMX InventoryTracking du commit `ef3d87034d38b88aca04c824061b140e2a29252c` ne sont pas prouvées. Les 151 JMX vérifiés sont Clienteling, pas InventoryTracking. Ce candidat ne prouve ni `EscapeJdbcDate`, ni `FixSqlUnicodeValue`, ni `RemoveSpecialCharsForXQuery`, ni une validation du pipeline AzDO InventoryTracking.

## Consommation isolée proposée aux Workers 1/2

Utiliser une copie temporaire dédiée, vérifier le SHA-256 du package avant décompression, extraire dans un répertoire hors clone partagé, puis exécuter uniquement la génération sur un descriptor fixture explicitement choisi. Vérifier ensuite le nombre de JMX, leur parsing XML et les hashes. Ne pas remplacer le cache partagé `migration-tools`, ne pas publier le package, ne pas toucher au plugin InventoryTracking ni relancer AzDO. Toute consommation dans InventoryTracking doit d'abord établir package/version/hash réellement injectés et le descriptor/JMX effectivement consommé.
