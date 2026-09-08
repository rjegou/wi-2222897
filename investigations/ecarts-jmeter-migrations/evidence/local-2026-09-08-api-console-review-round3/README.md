# Revue indépendante API → Console — FrenchTaxesRules round 3

## Qualification supersédée

La mention du candidat Console historique `2.0.42-soapnamespace.20260907` ci-dessous ne qualifie
pas le vrai candidat Console 2.0.43. La revue du diff `7d0667c…` et du build `4444888` est
conservée dans [la collecte round 4](../local-2026-09-08-console-2.0.43-build-4444888-round4/README.md).

Date : 2026-09-08, Europe/Paris. Système source : preuves locales du workspace WI-2222897.
Périmètre : vérifier le contrat API publié au build 4444765 et le candidat Console présenté pour
la suite. Aucun build concurrent, queue, publication feed ou modification distante n'a été lancé.

## Contrat API transmis au Worker 2

FACT : le build API `2637/4444765` a produit le commit
`9081ecfe7aa07f5e584073d2af1828d3ac9f7235`, la version
`1.1.47-wi2222897-api-candidate` et le PipelineArtifact `Nuget` id `5036993`.

Chemins locaux exacts conservés dans la preuve de publication :

- nupkg : `C:\clones\wi-2222897\investigations\ecarts-jmeter-migrations\evidence\local-2026-09-08-api-publish-round2\artifacts\Cegid.Retail.AutoTest.Api.1.1.47-wi2222897-api-candidate.nupkg`
- DLL : `C:\clones\wi-2222897\investigations\ecarts-jmeter-migrations\evidence\local-2026-09-08-api-publish-round2\artifacts\Cegid.Retail.AutoTest.Api.dll`

FACT : nupkg SHA-256 `296D7EAA4031138369C39986BE9F38264AF5BAB96AE0DC1D29E2380567BB864F`;
DLL SHA-256 `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E`.
Le nupkg et la DLL ont été relus par hash, puis les quatre méthodes ont été invoquées sur la DLL
réellement construite; les quatre résultats sont `PASS`, sans les présenter comme VSTest ou résultat
fonctionnel JMeter.

## Revue du candidat Console

FACT : le candidat local Console est `2.0.42-soapnamespace.20260907`, nupkg SHA-256
`803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`.
Le manifeste conservé indique `sourceCommit=4c22cb2850a150161f44080815375527c4daad48`,
publication `PipelineArtifact-only` et aucun feed partagé. Les entrées internes sont : API DLL
SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B` et Console EXE
SHA-256 `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`.

CONSTAT BLOQUANT : ce candidat Console embarque l'API historique `1.1.46.0` et la DLL hashée
`57BE…`, pas la DLL API du build 4444765 hashée `A7D3…`. Il ne peut donc pas servir de preuve de
la chaîne corrigée FrenchTaxesRules, même si les contrôles locaux de ses méthodes passent.
Worker 2 doit télécharger ou copier l'artefact API exact ci-dessus, vérifier son hash avant toute
compilation/staging Console, puis produire un artefact Console dont le contenu interne est rehashé.

INDEPENDENT REVIEW : le diff source Console annoncé au commit
`7d0667c90db1eca8e18e94f8fb4b572f9a9ee8e8` n'est pas présent dans un checkout local de cette
collecte. La lecture Azure DevOps live n'a pas pu être répétée car le profil global Azure CLI est
protégé (`PermissionError` sur `C:\Users\jegour\.azure\azureProfile.json`). Il est donc `UNKNOWN`
que ce diff mette effectivement à jour la référence/package API; ne pas le déduire du seul nom de
branche ou du YAML.

## Effets transitifs et limites

FACT : le manifeste du candidat Console indique PipelineArtifact-only et `sharedFeedPublication=false`.
Les preuves disponibles ne montrent aucun Promote, Tag, TestAutos ou upload feed partagé pour ce
candidat. Cela ne prouve pas l'absence d'effets d'un futur pipeline Console; ses templates et la
timeline du build exact doivent être relus avant queue.

UNKNOWN : compilation Console avec l'API `A7D3…`, package migration réellement remplacé, JMX
effectivement consommés et run JMeter FrenchTaxesRules. Aucun de ces effets ne doit être annoncé
avant leurs hashes/logs directs.
