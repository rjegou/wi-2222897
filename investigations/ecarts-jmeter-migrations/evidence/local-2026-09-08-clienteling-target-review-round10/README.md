---
type: "Evidence"
title: "Clienteling WI-2222897 — scripts runtime corrigés round 10"
timestamp: "2026-09-08"
source_system: "Préparation locale replay-prep; aucune exécution Docker/Azure DevOps"
freshness: "2026-09-08"
---

# Livrables corrigés

Les scripts ajoutés dans `replay-prep/2026-09-08-clienteling-isolated/scripts/`
sont :

- `Assert-Wi2222897ClientelingRuntime.ps1` : vérifie image/digest, labels,
  réseau interne, absence de ports, hash backup, démarre `W3SVC`, vérifie SQL,
  sonde les URLs explicites `ClientelingDeploymentService.svc` et
  `ClientelingMobilityService.svc`, exige un reçu PlatformDeploy contenant
  `-LocalDBInContainer Backup`, puis exige le conteneur JMeter dans le même
  réseau avant d’écrire l’attestation.
- `Remove-Wi2222897OwnedTarget.ps1` : supprime seulement un conteneur et réseau
  dont les labels `wi.scope` correspondent exactement à `WI-2222897/<variant>/<run>`.

Le secret SQL n’est jamais un paramètre : la fonction SQL transmet uniquement le
nom `SQLCMDPASSWORD` à `docker exec` et restaure immédiatement la variable de
processus. Les arguments, manifests et erreurs ne contiennent pas la valeur.

## Validation discriminante

- Parse PowerShell des deux scripts : à effectuer avant publication/transport.
- Parse PowerShell exécuté : `Assert-Wi2222897ClientelingRuntime.ps1` et
  `Remove-Wi2222897OwnedTarget.ps1` retournent zéro erreur. Tests négatifs
  exécutés : un réseau non préfixé est refusé (`negative-network PASS`) et un
  conteneur hors périmètre est refusé par cleanup (`negative-cleanup PASS`).
- Les protections négatives sont explicites : mauvais labels, image non digestée,
  réseau non interne, ports publiés, backup divergent, URL ambiguë, JMeter non
  attaché et réseau/target non possédé provoquent un échec avant attestation.
- La restauration SQL n’est plus présentée comme suffisante : l’attestation
  exige le probe W3SVC, les deux probes Clienteling et le rattachement JMeter.
- Les URLs sont fail-closed : elles doivent cibler explicitement
  `ClientelingDeploymentService.svc` et `ClientelingMobilityService.svc`.
- Le réseau privé n’est pas supposé accessible depuis le job hôte : le JMeter
  doit être un conteneur `wi2222897-jmeter-*` attaché au même réseau.

## Préconditions restant à prouver

Le mécanisme historique relu reste PlatformDeploy avec
`-LocalDBInContainer Backup`; son template télécharge PlatformDeploy/backup et
publie des logs, mais sa résolution isolée pour 14264 reste à intégrer par le
responsable. Le pool Windows 2025 avec daemon Docker doit être sélectionné sur
la base des jobs `4440884` Cur agent 2/Fix agent 3; le job `4444389` Fix agent 9
prouve le risque inverse (pipe Docker absent).

Le chemin réel de `AUTO_V26_00.bak`, le digest courant de l’image, le déploiement
MSI/PlatformDeploy, les URLs effectives/ports et la création du conteneur JMeter
restent UNKNOWN. Aucun run, image, permission, donnée partagée ou YAML n’a été
modifié dans cette collecte.
