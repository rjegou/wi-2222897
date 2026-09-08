# Revue Console distante — build 4445025 / artefact 5037277

Date : 2026-09-08, Europe/Paris. Source : Azure DevOps Retail, puis extraction locale hors dépôt
documentaire. Aucun feed partagé, tag, promotion ou nouvel upload n'a été tenté.

## Provenance

**FACT** : le build `4445025` de la définition `2641` est `succeeded`, branche
`refs/heads/sandbox/frenchtaxesrules/console-api-artifact`, commit source
`dfda5e52e637e423432023d9fb6b870e92104703`. Son PipelineArtifact `Nuget` porte l'id `5037277`.
Le fichier `PROVENANCE.txt` téléchargé avec l'artefact indique explicitement Console `2.0.43`,
API `1.1.47-wi2222897-api-candidate`, API build `4444765`, API nupkg SHA
`296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F` et DLL API SHA
`A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.

Le clone Console était propre avant la lecture (`sandbox/frenchtaxesrules/console-api-artifact`,
HEAD `dfda5e52…`). Le commit Console modifie explicitement la référence API vers
`1.1.47-wi2222897-api-candidate`, ainsi que la version Console 2.0.43 et le pipeline isolé.

## Relecture indépendante du contenu

L'URL du PipelineArtifact a été téléchargée puis le nupkg extrait hors dépôt documentaire. Hashes
recalculés depuis les fichiers extraits :

| élément | valeur |
|---|---|
| nupkg | `Cegid.Retail.AutoTest.Console.2.0.43-wi2222897-console-candidate.nupkg` |
| nupkg SHA-256 | `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE` |
| nuspec version | `2.0.43-wi2222897-console-candidate` |
| dépendance nuspec | `Cegid.Retail.AutoTest.Api 1.1.47-wi2222897-api-candidate` |
| API DLL embarquée SHA-256 | `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E` |
| API assembly version | `1.1.46.0` |
| Console EXE SHA-256 | `AB4BBB596409B3A60107905E82577E9BC42C55467A8E602B7194DD2D8CE9B2AF` |
| Console assembly version | `2.0.43.0` |

Le hash DLL et le contenu de `PROVENANCE.txt` concordent. Le package est donc distinct du candidat
local SOAP `2.0.42-soapnamespace.20260907`, SHA nupkg
`803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`, qui embarque la DLL API
`57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`.

La timeline relue du run confirme `Download exact API candidate PipelineArtifact`, `NuGet pack` et
`Publish artifact ... on pipeline` réussis. `Artifactory Generic Upload` et `Publish Artifactory
BuildInfo` sont `skipped`; aucun effet de feed partagé n'est donc observé pour ce build.

## Tests discriminants sur la DLL embarquée

Les méthodes ont été appelées par réflexion sur `tools\Cegid.Retail.AutoTest.Api.dll` extraite de
ce nupkg, sans substitution de DLL :

| correction | vecteur | résultat |
|---|---|---|
| `EscapeJdbcDate` | `'2026-04-28'` → `'20260428'` | PASS |
| `FixSqlUnicodeValue` | `SELECT 'NN''é' AS V` → `SELECT N'NN''é' AS V` | PASS |
| `RemoveSpecialCharsForXQuery` | `&lt;ClientelingParameters&gt;` → échappement `&amp;` | PASS |
| `CleanXpath` | `/soap:Fault` → `//Fault` | PASS |
| `PrepareXPathAssertion` | chemin SOAP 1.1 namespace-aware | PASS; `namespaceAware=True` |

**FACT** : les quatre corrections fonctionnelles et le contrôle SOAP déjà utilisés pour le candidat
local sont présents dans la DLL réellement embarquée par 4445025. **INFERENCE** : pour ces vecteurs
discriminants, le candidat distant est fonctionnellement équivalent au candidat local. **UNKNOWN** :
la provenance binaire n'est pas la même : l'artefact distant revendique API build 4444765, tandis que
le commit source corrigé demandé est `4c22cb2850a150161f44080815375527c4daad48`. Il ne faut donc pas
fusionner les deux preuves ni réécrire leurs hashes.

## Proposition explicite à WORKER 2

Pour 14264, utiliser explicitement le couple distant `4445025 / 5037277` si le choix assumé est le
package Console `2.0.43-wi2222897-console-candidate` et sa dépendance API `1.1.47` issue de 4444765.
Le manifeste ci-joint conserve cette provenance. Le candidat local `803D…` reste une autre option,
non interchangeable et non transportée par ce build.
