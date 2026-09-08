# Artefacts amont Clienteling — round 5

Date de collecte : 2026-09-08, Europe/Paris. Système source : Azure DevOps Retail et clones locaux
hors dépôt documentaire. Cette collecte est limitée aux artefacts PipelineArtifact et aux contrôles
de provenance ; aucun feed partagé, tag, promotion ou pipeline 2065 n'a été utilisé.

## API — transport distant effectivement disponible

**FACT** : la définition Azure DevOps `2637` a été lancée manuellement sur
`refs/heads/sandbox/clienteling/api-jmeter-fixes`. Le run `4444962` est terminé `succeeded`, avec
`sourceVersion=4c22cb2850a150161f44080815375527c4daad48` et fin
`2026-09-08T10:20:49.056567Z`.

**FACT** : le run expose l'artefact de pipeline `Nuget`, id `5037204`, type `PipelineArtifact`.
L'artefact a été téléchargé par son URL Azure DevOps avec le PAT tenu uniquement en mémoire, puis
relu depuis le fichier téléchargé sous `.work` (hors dépôt documentaire). Le package effectif est :

| élément | valeur recalculée |
|---|---|
| package | `Cegid.Retail.AutoTest.Api.1.1.46.nupkg` |
| package SHA-256 | `B416C52F58D5129C36540C13E9C9BA36CCB064FE5433EE3D21C8094A9E3E5AC4` |
| nuspec version | `1.1.46` |
| nuspec SHA-256 | `FC9922F6CC9807B9D7D836D6FF086A20171BCC66DA27E0D18F83BF2C4CACEC16` |
| DLL `Cegid.Retail.AutoTest.Api.dll` SHA-256 | `38E7BA8D507FB73A661DD111224DCFABBF78C22AB2ECE23BD9D2EF67ACCD2F3E` |

La lecture indépendante du YAML de la branche confirme que la version est dérivée de
`SolutionInfo.cs` (`ComponentVersion`) ; le run exact ne produit donc pas la version attendue
`1.1.47-wi2222897-api-candidate`. **INFERENCE** : le transport API est réel et rattaché au bon
commit, mais il ne satisfait pas le contrat de version/hachage de la chaîne Console préparée.
Il ne doit pas être injecté dans le candidat Console `2.0.42-soapnamespace.20260907`.

## Candidat Console — disponible localement seulement

**FACT** : le fichier local validé précédemment reste accessible :
`C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\migration-tools\Cegid.Retail.AutoTest.Console.nupkg`.
Son SHA-256 est `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` et son nuspec
déclare `2.0.42-soapnamespace.20260907`. Les hashes recalculés des fichiers embarqués sont : API
DLL `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`, Console EXE
`82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`.

**UNKNOWN** : aucun build/artefact Azure DevOps n'a transporté ce nupkg Console. Il reste interdit
de le déclarer consommable par la définition `14264` à partir du seul staging local.

## Cache Migration

**FACT** : le clone `C:\clones\Migration_Jmeter_RJE_Sandbox` existe et a été interrogé avec
`git -c safe.directory=<chemin exact> status --short --branch`; il est `main...origin/main [gone]`
et contient des modifications documentaires préexistantes, préservées. Le fichier de cache
`migration-tools\Cegid.Retail.AutoTest.Console.nupkg` est disponible, SHA-256
`212D33F7BE8DE8AC5923E82AC7BE0A0CEECBA5A71B631337B729F37CC889BE03`, mais son nuspec est
`2.0.39` et `consoleWorkflowVersions.json` indique Console `2.0.41` / Workflow `3.0.175`.

**INFERENCE** : le cache Migration est disponible techniquement, mais il n'est pas le candidat
Console `2.0.42-soapnamespace.20260907`; sa consommation serait une substitution non prouvée.

## Contrat pour la définition 14264

La définition `14264` doit refuser ces entrées tant qu'un artefact Console PipelineArtifact portant
le package `803D…` et un cache/artefact Migration explicitement versionné n'ont pas été produits et
rehashés. Le run API `4444962/5037204` peut être conservé comme preuve de transport par pipeline,
mais pas comme preuve de compatibilité Console. Les dépendances restantes sont donc : build ou
transport pipeline du candidat Console exact, transport/versionnement Migration exact, puis
relecture indépendante des fichiers téléchargés avant tout rejeu Cur/Fix.

