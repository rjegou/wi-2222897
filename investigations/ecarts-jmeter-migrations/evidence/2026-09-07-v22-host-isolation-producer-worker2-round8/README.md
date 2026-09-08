# Producteur hôte d’attestation d’isolation V22 — Worker 2 round 8

Date : 2026-09-07. Aucun run, publication, socket Docker ajouté, privilège, réseau ou agent partagé modifié.

## Capacité vérifiée

La documentation Microsoft du ciblage d’étape confirme qu’un job conteneurisé peut exécuter une étape avec `target: host` sur l’hôte de l’agent. La documentation des variables prédéfinies confirme que `Agent.ContainerMapping` mappe les noms de ressources YAML vers les IDs Docker runtime. Le code source officiel de l’agent construit cette mapping et renseigne l’ID du job container. Sources primaires : `https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/target?view=azure-pipelines`, `https://learn.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops`, `https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Agent.Worker/ContainerOperationProvider.cs`.

## Producteur local préparé

`Write-V22HostIsolationAttestation.ps1` est appelé par une étape `target: host` avant la configuration temporaire et avant tout téléchargement/déploiement. Il exige : mapping `v22Jmeter`, `AGENT_CONTAINERID`, run/job/jobId, image digestée confirmée, chemin d’une politique préexistante et Docker CLI hôte. Il inspecte uniquement l’ID exact issu du mapping, refuse une identité divergente ou arrêtée, exige le digest exact, lit hostname, mounts, réseaux et ports, construit l’attestation, puis appelle le même validateur avant de déplacer le fichier vers `Agent.TempDirectory` consommé par le job conteneurisé.

La politique n’est jamais construite à partir des valeurs observées. Si `V22IsolationPolicyPath` est absent/non résolu, le producteur s’arrête. Aucun socket Docker n’est monté dans le conteneur et aucun privilège supplémentaire n’est demandé.

## Tests locaux

- `Test-V22HostIsolationProducer.ps1` : PS7 et PS5.1 PASS avec faux `docker inspect` ; extraction de l’ID exact et correspondance image/mounts/réseaux/ports acceptées ; mapping discordant refusé.
- `Test-V22IsolationAttestation.ps1` : PS7 et PS5.1 PASS ; mount divergent et formes JSON tableau/null refusés.
- `Test-V22ReplayFailureModes.ps1` et `Invoke-V22RunnerDryRun.ps1` PASS ; manifeste et syntaxe PASS.

## Limites runtime

Le faux Docker ne prouve pas que l’agent réel expose ces variables dans cette définition ni que `Agent.TempDirectory` est accessible avec le même chemin au consommateur. La policy réelle, le `docker inspect` d’un job autorisé et la correspondance runtime restent à établir. Tant qu’une politique indépendante et approuvée n’est pas fournie, le producteur échoue fermé avant SQL/IIS.
