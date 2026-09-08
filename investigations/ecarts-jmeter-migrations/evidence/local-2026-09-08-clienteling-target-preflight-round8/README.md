---
type: "Evidence"
title: "Clienteling WI-2222897 — préflight cible Cur/Fix round 8"
timestamp: "2026-09-08"
source_system: "Windows agent local, Docker CLI, sources Clienteling indexées"
freshness: "2026-09-08"
---

# Diagnostic cible éphémère

## FACT — capacités de l’agent observé

- `docker.exe` est présent en version client `27.4.0`.
- `docker version` retourne un client mais aucun serveur : le pipe
  `//./pipe/docker_engine` est absent. `docker info` retourne le même échec de
  connexion; le daemon n’est donc pas disponible dans ce contexte.
- La lecture WMI `Win32_OperatingSystem` est refusée; aucune conclusion OS/agent
  supplémentaire n’est tirée.
- Aucun backup `.bak` ni image/digest local n’a été trouvé dans le périmètre
  `.work` du workspace.

## FACT — sources Clienteling relues

Les sources indexées déclarent l’image taguée
`cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`
et le backup `Tests/Backups/AUTO_V26_00.bak`. Le digest
`sha256:ea74f21a...` est seulement historique dans une preuve d’un autre run et
ne doit pas être réutilisé. Le hash du backup et une source téléchargeable
Cur/Fix restent inconnus.

## Script livré

`Invoke-Wi2222897TargetPreflight.ps1` est un diagnostic exécutable fail-closed
pour le job isolé autorisé. Il :

Empreinte du script : SHA-256
`45F3116A8E5232A3C397B1F40C669B415BA53DB70EADEEC10EAE553E2C275772`.

1. exige `-Provision`, une référence image + digest, un chemin de backup fourni
   par l’agent et le hash attendu;
2. vérifie le daemon puis acquiert l’image par `docker pull image@sha256:...`;
3. copie et rehash le backup dans le dossier du run;
4. crée uniquement un réseau `--internal` et un conteneur labelisé
   `WI-2222897/<variant>/<run>` sans ports publiés;
5. attend SQL, exécute `RESTORE FILELISTONLY`, restaure effectivement
   `AUTO_V26_00`, puis vérifie `sys.databases`;
6. écrit le reçu de restauration et l’attestation seulement après ces contrôles.

Le mot de passe SQL doit uniquement être injecté dans la variable de processus
`WI2222897_SQL_SA_PASSWORD`; le script ne l’écrit pas dans les preuves. En cas
d’échec, le conteneur et le réseau portant les labels du run sont supprimés.

## Verdict

**BLOCKED — preuve live impossible dans l’agent observé.** Le script est prêt
pour intégration par le responsable 14264, mais son exécution ici serait une
écriture externe impossible : daemon Docker absent, image non accessible et
backup/hash non fournis. Déblocage minimal : job Windows compatible avec Docker
et service connection déjà autorisée, image digestée relue par `docker inspect`,
backup réel acquis puis hashé, variable SQL éphémère, exécution du script pour
Cur et Fix dans le même contexte réseau privé. Aucun lancement 14264, aucune
image/permission/donnée partagée n’a été modifiée dans cette collecte.
