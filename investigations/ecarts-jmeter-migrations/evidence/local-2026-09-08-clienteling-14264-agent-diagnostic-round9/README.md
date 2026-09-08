# Diagnostic distant borné — Clienteling 14264 — run 4445464

## Provenance

- Date de collecte : 2026-09-08 (Europe/Paris).
- Système source : Azure DevOps `cegid/Retail`.
- Définition : 14264 (pipeline isolé Clienteling).
- Commit YAML exécuté : `4ec1fb0865954118278a6b7bb60019cb15fe3b2c` sur `sandbox/clienteling/wi2222897-isolated-replay`.
- Run : `4445464`, résultat Azure DevOps `partiallySucceeded`.
- Artefact : PipelineArtifact `5037721`, nom `wi2222897-target-diagnostic-4445464`.
- Fichier relu indépendamment : `target-diagnostic.txt`, taille 118622 octets, SHA-256 `3FD7190E71581F4066F9C0B0DA5E22F4F772BC012C6152E2AB9521CB26EFAC3A`.
- Relecture : téléchargement du PipelineArtifact puis `Get-FileHash -Algorithm SHA256` local ; aucun secret n’a été affiché ou conservé.

## Pool, job et agent

`FACT` : les campagnes Clienteling antérieures ont utilisé la queue 591 (`Azure Pipelines`) pour les jobs hébergés et la queue 665 (`Private VS2019`) pour les jobs Windows privés. Le pool privé correspondant est le pool 94, non hébergé.

`FACT` : le diagnostic 4445464 a été exécuté sur la queue 665 / pool `Private VS2019`, agent `vm-alm-agent-02-A` (la variable machine produite par l’agent est `vm-alm-agent-02`), version agent `4.270.0`, OS `Microsoft Windows NT 10.0.17763.0`.

## Résultat du diagnostic sur l’agent distant

Le fichier relu contient les erreurs exactes suivantes pour chaque commande Docker (`docker --version`, `docker version`, `docker info`, `docker image ls --digests`) :

```text
error=The term 'docker' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

`where.exe docker` retourne `INFO: Could not find files for the given pattern(s).` Les sections Docker client/serveur, info et images/digests sont donc non disponibles sur cet agent.

La recherche bornée dans `$(Build.SourcesDirectory)` ne trouve aucun fichier `.bak`. Les références détectées sont des occurrences statiques dans les sources/YAML (dont le YAML du diagnostic et des fichiers CSS contenant le mot `docker`), pas une source d’image avec digest ni un backup exploitable.

## Chronologie des essais

- `4445292` : premier diagnostic, abandonné après découverte qu’une recherche récursive de `$(Agent.WorkFolder)` ne se terminait pas ; run annulé, aucun artefact exploitable.
- `4445454` : diagnostic borné, run réussi avec artefact `5037713`, mais le script initial ne conservait pas les erreurs Docker ; cette preuve est supersédée pour la conclusion de capacité.
- `4445464` : diagnostic borné avec capture explicite des erreurs/exit codes, artefact `5037721` relu ci-dessus. Aucun stage Preflight, Build, GenerateJmx, Cur ou Fix n’a démarré, conformément au paramètre `diagnosticOnly=true`.

## Conclusion qualifiée

- `FACT` : l’agent Azure DevOps effectivement sélectionné n’a pas de client Docker accessible dans son `PATH` et le checkout ne contient pas de backup `.bak` détecté.
- `FACT` : le candidat Console accepté reste `4445025/5037277`, version 2.0.43, SHA-256 package `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`; cette provenance n’a pas été remplacée par le diagnostic.
- `INFERENCE` : provisionner une cible éphémère puis exécuter Build/GenerateJmx/Cur/Fix sur ce pool ne peut pas satisfaire les préconditions tant qu’un moteur Docker compatible et une source autorisée d’image/backup ne sont pas accessibles à l’agent.
- `UNKNOWN` : l’image attendue, son digest, le backup restaurable et la connectivité privée JMeter restent non attestés ; le diagnostic n’a effectué aucune installation ni modification de service, permission ou donnée partagée.

Déblocage minimal : affecter le job à un agent/pool disposant de Docker et de la ressource image/backup autorisée, ou rendre ces deux ressources accessibles à `Private VS2019`. Aucun changement de droits, service connection, feed partagé ou données collègues n’a été effectué.
