# Comparaison d’initialisation — 4440884 vs diagnostics 14264

## Provenance

- Collecte : 2026-09-08, lecture Azure DevOps REST/CLI en lecture seule.
- Build historique : `4440884`, définition 2072, source `ef3d87034d38b88aca04c824061b140e2a29252c`.
- Diagnostics : `4445464` (02-A) et `4445516` (02-B).
- Pool privé : queue 665 / `Private VS2019` / pool 94.
- Candidat conservé : Console build `4445025`, artifact `5037277`, package SHA-256 `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`.

## Différence de contexte démontrée

`FACT` : le build 4440884 ne constitue pas un seul contexte d’exécution.

| Partie | Queue / agent | Initialisation observée | Docker |
|---|---|---|---|
| `Build V26` | queue 665, `vm-alm-agent-02-A` | job privé Windows, PowerShell/JFrog/NuGet ; log 84 ne montre pas de provisioning de runner ni de pull Docker | non démontré dans ce job |
| `TI Jmeter V26-Cur` | queue 591, `Azure Pipelines 2` | runner image `windows-2025`, release `20260830.247.1`; Docker `C:\Windows\system32\docker.EXE` | client/daemon API 1.55, pull et conteneur réussis ; log 190 |
| `TI Jmeter V26-Fix` | queue 591, `Azure Pipelines 3` | même image `windows-2025`, release `20260830.247.1`; Docker initialisé par le job conteneur | client/daemon API 1.55, pull et conteneur réussis ; log 196 |
| `TargetDiagnostic` 4445464 | queue 665, `vm-alm-agent-02-A` | stage direct PowerShell de la définition isolée, sans `container:` ni runner image provisioner | commande Docker absente |
| `TargetDiagnostic` 4445516 | queue 665, `vm-alm-agent-02-B` | même stage direct PowerShell, demande `Agent.Name -equals vm-alm-agent-02-B` | commande Docker absente |

`FACT` : les logs 190/196 montrent explicitement `windows-2025`, puis `docker.EXE version`, login, pull, création et démarrage du conteneur. Les logs 99/101 montrent la même initialisation Docker dans les jobs hébergés JMeter. Les logs 84 et les diagnostics privés ne montrent pas ce mécanisme.

`INFERENCE` : l’identité `vm-alm-agent-02-A` seule ne permettait pas de comparer les environnements. La différence est principalement le template/stage : les campagnes JMeter utilisent un job hébergé `windows-2025` avec conteneur Docker ; le diagnostic ajouté utilisait le pool privé comme job Windows direct. Le résultat « Docker absent » sur 02-A/02-B ne contredit donc pas la réussite Docker historique des jobs hébergés.

## Image et acquisition

`FACT` : le job hébergé de 4440884 vérifie l’ACR/JFrog avant les phases JMeter, puis les logs 190/196 tirent `sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025` et obtiennent le digest `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`. Le conteneur Windows démarre et son réseau NAT est créé.

`FACT` : les phases JMeter téléchargent aussi le PipelineArtifact du build 4440884 (1,1 Mo) vers `D:\a\1\26.0.7.76_nuget` avant les opérations de test.

`UNKNOWN` : aucune ligne des logs 190/196 ne prouve le téléchargement/restauration d’un fichier `.bak` ou d’un backup SQL distinct. Le mécanisme réel peut être contenu dans l’image ou dans une ressource non journalisée par ces étapes ; l’absence locale dans le checkout ne permet pas de trancher.

## Décision opérationnelle

`FACT` : l’hypothèse testable est maintenant discriminée sans explorer les 20 agents : le stage diagnostic direct n’est pas équivalent aux jobs JMeter hébergés qui fournissaient Docker.

`FACT` : aucun troisième diagnostic n’a été lancé et aucune installation, modification durable d’agent, permission, service connection ou donnée partagée n’a été touchée.

`INFERENCE` : pour obtenir une preuve Clienteling comparable, il faut intégrer le diagnostic dans le contexte hébergé Windows 2025/Docker (ou fournir un pool privé équivalent), tout en attestant séparément la source du backup. Le stage privé direct ne doit pas être utilisé pour conclure à l’incompatibilité générale de Docker.

Déblocage minimal : réutiliser le template/job hébergé qui a produit les logs 190/196, avec triggers désactivés et paramètres Clienteling isolés, ou fournir explicitement un équivalent privé Windows 2025 + Docker. Le candidat Console 4445025/5037277 reste inchangé.
