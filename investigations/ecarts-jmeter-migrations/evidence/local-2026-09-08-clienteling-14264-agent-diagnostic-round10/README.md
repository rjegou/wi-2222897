# Diagnostic borné agent 02-B — Clienteling 14264

## Provenance

- Collecte : 2026-09-08, Azure DevOps `cegid/Retail`.
- Définition : 14264 — `WI-2222897 Clienteling Isolated Replay`.
- Branche : `sandbox/clienteling/wi2222897-isolated-replay`.
- Commit exécuté : `f8858ad73df9c9eca7e438e609b6effebb677a9b`.
- Push de la configuration de demande d’agent : `5135278`, parent `4ec1fb0865954118278a6b7bb60019cb15fe3b2c`.
- Run : `4445516`, terminé `partiallySucceeded`.
- Artefact : PipelineArtifact `5037823`, `wi2222897-target-diagnostic-4445516`.
- Fichier téléchargé indépendamment puis rehashé : `target-diagnostic.txt`, 118627 octets, SHA-256 `FDF1082CCA3CCA76ACB4E64BE002F3E9661388FEFCF074020B659923E04E2EA5`.

## Sélection effective

`FACT` : la demande YAML ajoutée au stage `TargetDiagnostic` est `Agent.Name -equals vm-alm-agent-02-B`, dans le pool `Private VS2019`.

`FACT` : le timeline du run confirme queue 665, job `Inspect Windows/Docker/image/backup capabilities`, agent `vm-alm-agent-02-B`, version 4.270.0 et OS `Microsoft Windows NT 10.0.17763.0`.

Les autres stages sont explicitement `skipped` : Preflight, Build, GenerateJmx, JMeter Cur et JMeter Fix. Aucun provisionnement ni donnée partagée n’a été modifié.

## Capacités observées

Le fichier relu indique, pour `docker --version`, `docker version`, `docker info` et `docker image ls --digests` :

```text
error=The term 'docker' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

`where.exe docker` ne trouve aucun fichier. La recherche bornée du checkout ne trouve pas de `.bak` et ne constitue pas une preuve d’absence de la source distante du backup ; cette disponibilité reste `UNKNOWN`.

## Comparaison historique 4440884

`FACT` : le build historique InventoryTracking `4440884` a utilisé le même pool privé/queue 665 et l’agent `vm-alm-agent-02-A` pour le job `Build V26`. Ses logs 99/101 montrent Docker client/serveur API `1.55`, un `docker pull` réussi de l’image `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`, puis la création et le démarrage réussis du conteneur.

`FACT` : dans le même build, l’acquisition/vérification ACR et la comparaison de digest ont été exécutées sur l’agent hébergé `Azure Pipelines 43`, image Ubuntu 24.04, agent 5.278.0. Ce job n’est pas une preuve de capacité Docker actuelle de `Private VS2019`.

`INFERENCE` : l’absence Docker sur 02-A au run 4445464 et sur 02-B au run 4445516 montre une indisponibilité actuelle des deux agents testés, alors que 02-A avait cette capacité le 2026-09-07. Elle ne justifie pas de conclure que tous les agents du pool sont incapables.

## Verdict et suite minimale

- `FACT` : le pool autorisé et la demande d’agent fonctionnent ; 02-B est sélectionné et online, mais Docker n’est pas accessible.
- `UNKNOWN` : capacités Docker des autres agents du pool, source réelle du backup et possibilité de restauration depuis cette source.
- `INFERENCE` : Build/GenerateJmx/Cur/Fix ne doivent pas être lancés avant sélection d’un agent privé actuellement capable de Docker et attestation de l’accès à l’image/backup.

Déblocage minimal : remettre à disposition un agent Windows compatible avec Docker ou sélectionner un pool déjà autorisé qui expose cette capacité, puis vérifier depuis le job l’image V26 et la source backup réelle. Aucune installation, modification de service connection, permission ou ressource partagée n’a été effectuée.
