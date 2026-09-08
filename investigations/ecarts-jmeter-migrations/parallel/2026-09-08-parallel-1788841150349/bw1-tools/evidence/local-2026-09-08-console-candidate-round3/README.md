# Vérification locale du candidat Console — round 3

Date de collecte : 2026-09-08. Source : staging local isolé
`C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710`.
Aucune publication, restauration distante, reconstruction ou modification de source n'a
été effectuée dans cette collecte.

## Identité et contenu

FACT : le fichier `migration-tools\Cegid.Retail.AutoTest.Console.nupkg` est présent,
taille 398206 octets, SHA-256
`803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`.
Son nuspec embarqué déclare `Cegid.Retail.AutoTest.Console`
`2.0.42-soapnamespace.20260907` et la description « Isolated local evidence package;
never published. »

FACT : dans ce nupkg, `tools/Cegid.Retail.AutoTest.Api.dll` et
`tools/Cegid.Retail.AutoTest.Console.exe` sont présents. Les mêmes fichiers ont été
contrôlés dans l'extraction `Y2_Plugins_Clienteling\PublishedSharedTools\...\tools` :

| fichier | taille | SHA-256 |
|---|---:|---|
| `Cegid.Retail.AutoTest.Api.dll` | 182784 | `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B` |
| `Cegid.Retail.AutoTest.Console.exe` | 31624 | `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` |

L'assembly API chargée par réflexion est `Cegid.Retail.AutoTest.Api, Version=1.1.46.0`.
Cette identité binaire ne constitue pas une preuve de publication d'une version API
`1.1.47`.

## Fixtures comportementales sur la DLL réellement embarquée

La DLL extraite du candidat a été chargée par réflexion .NET avec résolution des
dépendances depuis son répertoire `tools`. Les sorties suivantes sont celles du
binaire hashé ci-dessus, sans rebuild.

| correction | vecteurs | résultat |
|---|---|---|
| `EscapeJdbcDate` | `'2026-04-28'` → `'20260428'` | FACT — PASS |
| `FixSqlUnicodeValue` | `SELECT 'NN''é' AS V` → `SELECT N'NN''é' AS V`; deux littéraux Unicode | FACT — PASS |
| `RemoveSpecialCharsForXQuery` | XML simple, apostrophe, `&amp;`, entités pré-encodées | FACT — PASS, `&` devient `&amp;` avant les autres remplacements |
| `CleanXpath` | `/soap:Fault` → `//Fault`; `/Result` → `//Result` | FACT — PASS pour la transformation locale |

Le contrôle adjacent `PrepareXPathAssertion('/soap:Fault[Code=1]')` retourne
`//*[local-name()=&apos;Fault&apos; and namespace-uri()=&apos;http://schemas.xmlsoap.org/soap/envelope/&apos;][Code=1]`
et positionne `namespaceAware=True` : FACT — PASS pour le chemin SOAP 1.1 testé.

## Limites

FACT : ces contrôles établissent le comportement des quatre méthodes dans la DLL
extraite du candidat et confirment la provenance package → DLL → EXE par empreintes.

UNKNOWN : aucune publication/feed, pipeline Azure DevOps, cache distant, SQL/HTTP/IIS,
ou campagne JMeter n'a été exécuté. Le nombre de 151 JMX et leur parsing XML ne suffit
pas à certifier une réussite métier ni tous les cas de production. Le candidat reste
un artefact local d'essai, explicitement non publié par son nuspec.

