# Politique d’isolation V22 — Worker 2 round 9

Date : 2026-09-07. Préparation locale uniquement ; aucun run ou système distant modifié.

## Politique reviewable

`replay-prep/2026-09-07-v22-isolated/V22-ISOLATION-POLICY.json` déclare un contrat indépendant des mounts observés :

- conteneur attendu `v22Jmeter` ; scope limité à un identifiant numérique de run, variante `FixHistorical`/`FixCandidate` et job correspondant ;
- mounts nécessaires seulement pour le workspace job Windows (`C:\__w\<n>`), tools (`C:\__t`) et externals (`C:\__a\externals`, lecture seule), avec tasks optionnel (`C:\__w\_tasks`, lecture seule) ; les sources doivent correspondre aux racines agent attendues ;
- refus explicite des chemins Docker socket/engine/pipe et de tout mount non apparié ;
- réseau limité au réseau Azure Pipelines `vsts_network_<hex>`, ID hexadécimal ;
- zéro port publié ; SQL/IIS/AuthenticationServer doivent rester sur le hostname du conteneur du job.

Les chemins `C:\__w`, `C:\__t`, `C:\__a` et les mounts Work/Tools/Externals proviennent du code source officiel de l’agent, pas d’une copie d’inspection runtime. Sources : `https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Microsoft.VisualStudio.Services.Agent/HostContext.cs` et `https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Agent.Worker/ContainerOperationProvider.cs`.

## Transfert et producteur

L’étape `target: host` inspecte l’ID exact obtenu depuis `Agent.ContainerMapping`/`Agent.ContainerId`, vérifie digest, état, hostname, mounts, réseaux et ports, puis valide l’attestation contre cette policy avant de la déplacer vers `Agent.TempDirectory`. Le job consomme ensuite ce fichier via `V22IsolationAttestationPath`. La policy est un fichier candidat manifeste, non généré par le producteur et non remplaçable par les valeurs observées.

## Tests

- Producteur avec faux `docker inspect`, policy réelle du candidat : PS7 et PS5.1 PASS ; ID exact accepté, mount Docker dangereux et mapping discordant refusés.
- Validateur : PS7 et PS5.1 PASS ; mount divergent et JSON null/tableau refusés.
- Failure modes, dry-run, syntaxe et manifeste SHA-256 : PASS.

## Run 4442225

`evidence/azure-devops-french-taxes-rules-v22-worker1-round16/README.md` établit que le préflight `4442225` a refusé une assertion `mounts` (`count=1;dangerous=1`), alors que digest, scope, réseau et ports passaient ; cleanup a supprimé son conteneur. FACT : cela confirme la nécessité de refuser un mount dangereux. UNKNOWN : la preuve ne donne pas la source/destination et concerne le conteneur du préflight, pas les jobs métier ; elle ne vaut pas attestation de leurs conteneurs.

## Préconditions runtime restantes

Le producteur réel doit être exécuté sur un agent Windows compatible avec `target: host`, Docker CLI et le mapping de conteneur. Le chemin hôte/chemin conteneur de `Agent.TempDirectory`, la policy effectivement chargée et les mounts réels des jobs restent à relire sur un run autorisé. Aucun élargissement de droits, socket ou réseau n’est demandé. Tant que ces vérifications ne sont pas faites, le garde-fou reste fermé avant SQL/IIS.
