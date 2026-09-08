---
type: "Evidence"
title: "Clienteling WI-2222897 — revue indépendante du préflight cible"
timestamp: "2026-09-08"
source_system: "Revue locale documentaire et preuves Azure DevOps indexées"
freshness: "2026-09-08"
---

# Verdict de revue

**STOP — le script round8 ne doit pas être exécuté à distance en l’état.** Il
réalise une restauration SQL potentielle, mais ne prouve pas une cible
Clienteling opérationnelle et ne respecte pas encore entièrement le contrat de
secret/ownership réseau. Aucun job n’a été lancé et aucun YAML n’a été modifié.

## FACT — observations locales distinctes d’Azure DevOps

### Local

- Le script relu est
  `evidence/local-2026-09-08-clienteling-target-preflight-round8/Invoke-Wi2222897TargetPreflight.ps1`.
  Il exige `-Provision`, fait `docker pull`, monte le backup, attend `sqlcmd`,
  exécute `RESTORE DATABASE`, puis écrit une attestation.
- Il ne vérifie ni IIS, ni un endpoint Clienteling, ni le démarrage de l’application,
  ni l’attachement réel du runner JMeter au réseau Docker.
- Il ne crée pas `DataRoot` dans le conteneur avant `RESTORE ... WITH MOVE`; le
  chemin peut donc être inexistant. La simple présence de `sys.databases` ne
  prouve pas le fonctionnement des services Clienteling.
- La fonction SQL passe actuellement `SQLCMDPASSWORD=<valeur>` comme argument
  à `docker exec`. La valeur n’est pas écrite dans le manifeste, mais elle peut
  être exposée par la ligne de commande/process inspection. Ce mode est refusé
  par le contrat de secret.
- Si le réseau nommé existe déjà, le script le réutilise puis son `catch` peut
  tenter de le supprimer; l’ownership de ce réseau n’est pas prouvé. Le réseau
  doit être refusé s’il existe, ou sa création/possession doit être tracée et sa
  suppression limitée à un réseau créé par ce run.

### Azure DevOps

- La preuve `evidence/agent-comparability-round7.md` identifie les jobs réels du
  build `4440884` : Cur sur `Azure Pipelines 2`, Fix sur `Azure Pipelines 3`,
  Windows 2025, image JMeter digestée
  `ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`; Docker
  pull/inspect/create réussissent pour ces jobs.
- Dans `4444389`, Fix sur `Azure Pipelines 9` échoue avant création du conteneur
  car `npipe:////./pipe/docker_engine` est absent; Cur est annulé avant fin.
  Ce sont des observations de jobs/agents Azure DevOps, pas une preuve du job
  isolé 14264.
- La source historique Clienteling déclare le tag image
  `cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`,
  `acr_y2jmeter_test`, V26 Cur/Fix/WebServices et
  `Tests/Backups/AUTO_V26_00.bak`. Le mécanisme historique passe par
  `task-deploy-in-containerized-job.v2.yml`, PlatformDeploy et
  `-LocalDBInContainer Backup`; il ne constitue pas une source isolée prouvée
  pour 14264.

## FACT — réseau et accès JMeter

Le réseau `--internal` sans ports publiés est correct pour limiter l’exposition,
mais le YAML 14264 actuel exécute JMeter dans un job Windows séparé et ne déclare
pas de conteneur JMeter attaché au réseau créé par le script. Le nom
`wi2222897-Cur/Fix-<run>` n’est donc pas automatiquement résolvable depuis ce
job. Pour rendre Cur/Fix exécutable, le responsable doit choisir et prouver une
seule voie :

1. exécuter le moteur JMeter dans un conteneur attaché au même réseau interne,
   avec les JMX montés depuis l’artefact courant; ou
2. exécuter les assertions JMeter dans le conteneur cible; ou
3. fournir une route privée explicitement attestée depuis le job Windows vers
   l’hôte applicatif, sans port partagé/public.

Un simple champ `appHost`/`dbHost` dans JSON ne suffit pas.

## Corrections obligatoires à transmettre au responsable 14264

1. Ajouter un probe applicatif obligatoire après restauration, avec URL fournie
   par le job et statut HTTP/contrat contrôlé. Les sources XML ciblées distinguent
   `ClientelingDeploymentService.svc` et `ClientelingMobilityService.svc`; ne pas
   inventer le host/port, les résoudre depuis la configuration effectivement
   déployée.
2. Créer/vérifier `DataRoot` dans le conteneur avant le restore et conserver le
   résultat `RESTORE FILELISTONLY`, les chemins `MOVE` et la vérification DB.
3. Remplacer `docker exec -e SQLCMDPASSWORD=<secret>` par un mécanisme qui ne
   place pas la valeur dans les arguments (par exemple variable de processus
   transmise par `--env SQLCMDPASSWORD` sans valeur, puis suppression immédiate,
   ou injection native du job). Ne jamais journaliser les arguments complets.
4. Refuser tout réseau préexistant de même nom et ne supprimer que le réseau
   effectivement créé par ce run; renforcer aussi le script de cleanup par
   vérification des labels réseau `wi.scope`/`wi.runId`.
5. Ne produire l’attestation `PASS` qu’après probe SQL, restauration, probe IIS/
   Clienteling, inspection image/digest, inspection mounts/ports et preuve de
   connexion du runner JMeter au réseau privé. Sinon produire `UNKNOWN`/échec,
   pas une attestation exploitable par le preflight 14264.

## Préconditions concrètes

- Agent Windows 2025 comparable avec Docker daemon réellement joignable; le
  pool/agent exact du job 14264 doit être relu dans la timeline.
- Image disponible par source autorisée et digest relu sur cet agent; le digest
  historique ne doit pas être réutilisé sans readback.
- Backup réel `AUTO_V26_00.bak` acquis dans un emplacement éphémère du run,
  SHA-256 calculée sur les octets consommés, puis restauration Cur et Fix
  séparées dans leurs ressources dédiées.
- Configuration Clienteling/MSI et endpoints réellement démarrés, avec preuve
  de probe avant JMeter.
- JMeter Cur/Fix dans le même contexte réseau privé, puis cleanup borné et
  readback de l’absence du conteneur/réseau.

**UNKNOWN** — aucune de ces préconditions n’est attestée pour 14264 au moment
de cette revue. Le diagnostic round8 est donc un brouillon opératoire, pas une
attestation et pas une autorisation de queue.
