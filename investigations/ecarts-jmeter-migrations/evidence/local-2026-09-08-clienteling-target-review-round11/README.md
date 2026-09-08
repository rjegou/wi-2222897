---
type: "Evidence"
title: "Clienteling WI-2222897 — complétude du contrat cible round 11"
timestamp: "2026-09-08"
source_system: "Relecture YAML 14264, templates Clienteling indexés et replay-prep local"
freshness: "2026-09-08"
---

# Verdict

**FACT — le YAML 14264 actuel ne produit aucun élément cible.** Il télécharge
une attestation externe, lance Build/GenerateJmx, puis exécute JMeter dans un
job Windows séparé. Il ne référence ni PlatformDeploy, ni `DataRoot`, ni image
digestée, ni réseau Docker, ni conteneur JMeter.

Les assertions round10 exigeaient donc des éléments sans producteur. Trois
scripts de contrat ont maintenant été ajoutés dans le replay-prep, sans modifier
le YAML :

1. `Invoke-Wi2222897PlatformDeploy.ps1` invoque le script PlatformDeploy réel
   fourni par le job avec `-deployConfig ... -LocalDBInContainer Backup`, hash le
   backup avant écriture, refuse un réseau préexistant, produit un reçu expurgé,
   vérifie labels/réseau interne et crée/vérifie `DataRoot` dans la cible.
2. `Assert-Wi2222897ClientelingRuntime.ps1` consomme ce reçu, démarre/vérifie
   W3SVC, SQL, les deux endpoints Clienteling et l’attachement JMeter avant
   attestation PASS.
3. `Invoke-Wi2222897JmeterContainer.ps1` crée, sur demande explicite `-Run`, un
   sidecar JMeter digesté attaché au réseau privé, avec mounts JMX/runtime/sortie
   et labels du run. Sans `-Run`, il retourne seulement un contrat DRY.

## Producteurs et limites prouvées

| Élément | Producteur prévu | Preuve actuelle |
|---|---|---|
| reçu PlatformDeploy | wrapper round11 autour du script fourni au job | aucun chemin réel de script/config dans 14264 |
| restauration/backup | PlatformDeploy `-LocalDBInContainer Backup` | template historique identifié; aucun run 14264 |
| DataRoot | wrapper via `docker exec` après déploiement | aucune cible Docker disponible localement |
| W3SVC/endpoints | runtime assertion après PlatformDeploy | aucun démarrage/probe live |
| contexte JMeter | sidecar round11 sur réseau cible | aucune image JMeter digestée/sidecar live |

Les jobs historiques `4440884` fournissent seulement une compatibilité
observée : Cur agent 2 et Fix agent 3 Windows 2025 avaient Docker fonctionnel;
`4444389` Fix agent 9 échouait sur le pipe Docker. Cela ne constitue pas une
preuve de pool/agent attribué à 14264.

## Validation locale

Les trois scripts ont été parsés avec zéro erreur PowerShell et `git diff --check`
ne signale aucune erreur. Le test négatif round10 réseau non scoped et cleanup
hors ownership reste PASS. Aucun script n’a été lancé avec Docker, aucune image,
permission, donnée, YAML ou ressource partagée n’a été modifiée.

## Préconditions avant toute queue

- fournir au job le chemin réel du script/config PlatformDeploy et un backup
  acquis; le reçu doit être produit par l’invocation réelle, pas fabriqué;
- sélectionner un agent Windows 2025 avec daemon Docker joignable et relire son
  identité dans la timeline;
- fournir image cible et image JMeter digestées, network/container names
  exclusivement WI-2222897/run-scoped;
- générer les URLs effectives des deux services dans la configuration déployée;
- exécuter le sidecar JMeter dans le même réseau privé, puis cleanup ownership
  strict et readback;
- seulement ensuite transmettre l’attestation courante au preflight 14264.

**STOP** — sans ces entrées réelles, exécuter les scripts créerait une cible
partielle ou un résultat non comparable.
