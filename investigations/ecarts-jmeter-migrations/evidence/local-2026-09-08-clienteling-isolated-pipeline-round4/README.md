---
type: "Evidence"
title: "Clienteling WI-2222897 — branche et définition isolées, preflight fail-closed"
description: "Création live de la branche Clienteling dédiée, publication du YAML isolé et run manuel arrêté avant métier faute d'artefacts exacts."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-isolated-pipeline-round4/README.md"
timestamp: "2026-09-08"
source_system: "Azure DevOps CLI"
---

# Clienteling WI-2222897 — Round 4

## Branche dédiée

**FACT** — lecture live du dépôt `Y2_Plugins_Clienteling` :

- repository ID : `7776ac72-1788-4bea-9422-e5f0dacadc74` ;
- `refs/heads/master` avant création :
  `0c0fd26533e46b13e029276f90b5c085c1804012` ;
- branche créée : `refs/heads/sandbox/clienteling/wi2222897-isolated-replay` ;
- `newObjectId` à la création : `0c0fd26533e46b13e029276f90b5c085c1804012`.

La création a réussi avec une seule commande `az repos ref create` et le PAT en
mémoire de processus. Aucune permission n'a été modifiée. La branche API
historique `sandbox/clienteling/api-jmeter-fixes` n'a pas été détournée.

## Configuration publiée

**FACT** — commit de configuration poussé sur la branche dédiée :

```text
edb02f3466f218a57f64856aaba2a7f47908830b
```

Le commit contient uniquement `ci/wi2222897/` : le YAML isolé et trois scripts
PowerShell. Le YAML contient `trigger: none`, `pr: none`, `schedules: []`, et
aucune commande JFrog, Artifactory, ACR import, Promote, Tag ou git push. Les
seules publications prévues sont des `PipelineArtifact`.

Le hash API DLL attendu dans le YAML est la valeur complète calculée sur le
candidat embarqué :
`57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`.

## Définition et run réel

**FACT** — définition dédiée créée sans premier run automatique :

| Élément | Valeur |
|---|---|
| ID | `14264` |
| Nom | `WI-2222897 Clienteling Isolated Replay` |
| Dépôt | `Y2_Plugins_Clienteling` |
| Branche par défaut | `refs/heads/sandbox/clienteling/wi2222897-isolated-replay` |
| YAML | `ci/wi2222897/azure-pipelines.clienteling-wi2222897.yml` |

**FACT** — un seul run manuel contrôlé a été queue :

| Élément | Valeur |
|---|---|
| Build/run | `4444892` |
| Source commit | `edb02f3466f218a57f64856aaba2a7f47908830b` |
| Début | `2026-09-08T10:05:53.443048Z` |
| Fin | `2026-09-08T10:06:54.456957Z` |
| Résultat | `failed` |
| Définition | `14264` |
| Raison | `manual` |

Le log final du job `VerifyInputs` contient exactement :

```text
Required input is missing: apiBuildId
PowerShell exited with code '1'.
```

Le run s'est donc arrêté au premier contrôle `Preflight`, avant Build
Clienteling, GenerateJmx, JMeter Cur ou JMeter Fix. Aucun résultat métier,
JMX, SQL/IIS, feed partagé ou publication externe n'est revendiqué.

## Interprétation et prochaine action minimale

**FACT** — le refus historique `VS403660` n'est pas reproduit ici : il
concernait la création d'une branche API nouvelle et la permission
`CreateBranch`. La création Clienteling actuelle a réussi.

**FACT** — le nouveau blocage est fonctionnel et précis : aucun ID exact
d'artefact n'a été fourni au run. Les paramètres attendus sont
`apiBuildId`, `consoleBuildId`, `migrationBuildId`, `jmeterArtifactBuildId` et
`targetAttestationArtifact`.

**SUITE** — produire les builds/manifests API, Console et migration/JMX, ainsi
que l'attestation de cible dédiée, puis relancer la définition `14264` avec
ces IDs exacts. Ne pas lancer `2065 — Clienteling CI`, ne pas utiliser de feed
partagé, et ne pas contourner le preflight.

