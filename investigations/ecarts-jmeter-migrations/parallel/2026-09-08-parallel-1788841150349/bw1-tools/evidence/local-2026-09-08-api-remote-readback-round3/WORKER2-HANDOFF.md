# Handoff immédiat vers WORKER 2

À consommer comme contrat strict pour le staging d'un PipelineArtifact :

- source API distante : `Y2_Tools_AutoTest_Api`,
  `refs/heads/sandbox/clienteling/api-jmeter-fixes`, commit
  `4c22cb2850a150161f44080815375527c4daad48` ;
- nupkg candidat valide :
  `C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\migration-tools\Cegid.Retail.AutoTest.Console.nupkg` ;
- version nuspec : `2.0.42-soapnamespace.20260907` ;
- nupkg SHA-256 :
  `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` ;
- `tools/Cegid.Retail.AutoTest.Api.dll` SHA-256 :
  `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B` ;
- `tools/Cegid.Retail.AutoTest.Console.exe` SHA-256 :
  `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`.

Utiliser `stage-console-candidate.ps1` avant toute génération. Le script arrête
le transport si un hash ou la version diverge, et ne publie que vers un
PipelineArtifact. Le fichier nommé
`...soapnamespace...nupkg` sous `local-2026-09-07-soap-package-round14` est à
rejeter : son nuspec déclare `2.0.42-cleanxpath.20260907` et son hash est
`F12F37E641941907F67CC7640728AC2DA2CEEA974E5909E0E85667EBAD361F5F`.

Le remplacement du cache Migration et la preuve du JMX effectivement consommé
restent à établir côté WORKER 2. Aucun feed partagé ne doit être utilisé.
