---
type: "Preuve"
title: "Synthèse technique — replay isolé Clienteling V26 jusqu'au téléchargement JFrog"
description: "Copie immuable d'un compte rendu reçu le 2026-09-09 ; les observations distantes restent rapportées."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-09-clienteling-v26-replay/README.md"
tags: ["jmeter", "clienteling", "jfrog", "platformdeploy", "preuve"]
timestamp: "2026-09-09"
source_system: "local-kb"
---

# Synthèse technique — replay isolé Clienteling V26

## Provenance et fraîcheur

- **Source reçue** : `C:\Users\jegour\Downloads\WI-2222897_synthese-technique-clienteling-v26-replay.md`.
- **Copie conservée** : [`2026-09-09-clienteling-v26-replay.md`](2026-09-09-clienteling-v26-replay.md), avec fins de ligne identiques à la source.
- **Empreinte source SHA-256** : `7B6EEEE3B5052CF2A6CD86E157871F76971A824EAFC9416E350117BDE413A6EC`.
- **Empreinte copie SHA-256** : `7B6EEEE3B5052CF2A6CD86E157871F76971A824EAFC9416E350117BDE413A6EC`.
- **Taille / lignes** : source et copie `18 396` octets / `633` lignes.
- **Méthode** : lecture locale et copie textuelle le 2026-09-09 ; aucun système distant n'a été relu pendant ce rangement.
- **Fraîcheur** : `rapporté, non revérifié`. Les runs, commits, pushs et causes restent des déclarations de la source.

## Éléments retenus

Le document décrit la progression du replay isolé `14264` sur
`sandbox/clienteling/wi2222897-isolated-replay`, des vérifications de JMeter et du `.cy2px`
jusqu'à l'appel réel de PlatformDeploy et au téléchargement de packages. Les runs rapportés vont
de `4451986` à `4452826`; le dernier blocage est `The download of one or more packages has failed`.

La source rapporte notamment la tokenisation du host et de l'instance SQL, le staging du backup,
la matérialisation du CLI JFrog et un correctif de diagnostic whitelisté. Elle ne revendique aucune
exécution JMeter Cur/Fix.

## Limites

Cette preuve ne confirme ni les identifiants distants, ni les commits/pushs, ni le package fautif,
ni l'absence d'effets externes au-delà de ce que la source affirme. Ne pas ouvrir ni consigner de
secret JFrog ; le document source n'en contient pas dans la copie conservée.
