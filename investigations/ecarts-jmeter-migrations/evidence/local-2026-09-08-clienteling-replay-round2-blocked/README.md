---
type: "Evidence"
title: "Clienteling master V26 — décision de non-lancement Round 2"
description: "Contrôle des préconditions de pipeline isolé et motif concret de non-lancement du Build + JMeter Cur/Fix."
resource: "WI-2222897/investigations/ecarts-jmeter-migrations/evidence/local-2026-09-08-clienteling-replay-round2-blocked/README.md"
tags: ["Clienteling", "Azure DevOps", "JMeter", "blocked"]
timestamp: "2026-09-08"
source_system: "Azure DevOps REST API + preuves locales partagées"
---

# Clienteling master V26 — décision de non-lancement Round 2

## Provenance

- Collecte : 2026-09-08, après lecture de l'état local Round 1 et des preuves API/Console produites par le worker outils.
- Source distante déjà relue : Azure DevOps `Retail`, définitions `2065` Clienteling CI, `2637` AutoTest API, `2641` AutoTest Console et `5224` JMeter Workflow ; détails et empreintes dans [`local-2026-09-08-clienteling-replay-prep-round1`](../local-2026-09-08-clienteling-replay-prep-round1/README.md).
- Source locale partagée : [`local-2026-09-08-api-sandbox-preparation`](../../parallel/2026-09-08-parallel-1788841150349/bw1-tools/evidence/local-2026-09-08-api-sandbox-preparation/README.md) et rapport candidat Console Round 3.
- Aucun PAT, secret, package ou fichier de credentials n'est recopié ici.
- Aucun pipeline, branche, définition, package, feed, image, tag, promotion ou run n'a été créé ou modifié pendant ce contrôle.

## Faits bloquants

**FACT** — le candidat API n'est pas disponible sur la branche distante d'essai. `refs/heads/sandbox/clienteling/api-jmeter-fixes` pointe sur `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`, identique à `master`. Le patch local quatre corrections est seulement conservé sous `patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch` et n'est pas consommé par un build Azure DevOps.

**FACT** — la tentative de branche candidate du worker outils a été refusée par Azure DevOps avec `VS403660` (`CreateBranch`, identité `rjegou@cegid.com`). Aucun contournement, push vers `master` ou modification de permission n'a été tenté.

**FACT** — le candidat Console local `2.0.42-soapnamespace.20260907` (`803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`) n'est ni publié ni relié à un build Clienteling. Sa propagation API → Console → migration → JMX reste `UNKNOWN`.

**FACT** — le seul pipeline Clienteling existant `2065` a les effets suivants dans son YAML live : trigger CI et schedule, contrôle/import ACR depuis JFrog, publication Artifactory staging, téléchargement JFrog lors du déploiement, stages `Promote` et `Tag_Sources`. Il n'est pas une définition isolée acceptable pour cet essai.

**FACT** — les templates transitifs live relus en Round 1 exécutent notamment `az acr import`, téléchargent PlatformDeploy depuis JFrog, écrivent des paramètres JMeter temporaires, publient les logs et peuvent promouvoir ou pousser un tag. Les conditions de branche ne constituent pas une preuve suffisante d'absence d'effet aval.

## Décision d'exécution

**VERDICT : non-lancement justifié.** Une queue de `2065` aurait consommé le package plugin courant `26.0.10.32` ou un artefact de sa propre construction, sans preuve du candidat API/Console corrigé, et aurait conservé des destinations partagées. Cela contredirait le périmètre Round 2 : branche/définition dédiée, aucun feed NuGet partagé, aucune promotion/tag/publication ou copie externe.

Ce n'est pas un blocage d'autorisation métier. C'est un blocage technique et de sécurité démontré par :

1. l'absence du correctif sur la branche API distante ;
2. le refus effectif de création/push de la branche candidate ;
3. l'absence de définition YAML isolée contenant le transport des packages et JMX par artefacts de pipeline ;
4. les effets partagés présents dans `2065` et ses templates.

## Préconditions exactes de reprise

Le prochain lancement pourra être considéré lorsque les éléments suivants seront prouvés dans une nouvelle collecte :

1. commit exact du patch API sur une branche de mission autorisée, build API réussi et `.nupkg` attaché à un artefact de pipeline avec SHA-256 ;
2. build Console attaché au même API par ID de build explicite, package/EXE/DLL embarquée hashés ;
3. migration et régénération des JMX dans un espace d'essai, manifeste/hash de chaque JMX transmis au job ;
4. YAML/definition Clienteling d'essai avec `trigger: none`, `pr: none`, schedules désactivés, aucun push NuGet/JFrog, aucun ACR import, Promote, Tag ou trigger aval ;
5. pool/agent Windows, image réellement consommée, backup, fixtures/images et endpoints isolés identifiés, avec nettoyage limité aux ressources du run ;
6. timeline attendue : `Build`, `TI_Jmeter_V26_Cur`, `TI_Jmeter_V26_Fix`, puis artefacts de résultats individuels JTL/JUnit/CSV et logs d'exécution ;
7. contrôle préalable des runs actifs et absence de destination partagée non prouvée.

## Portée de ce qui n'a pas été fait

- Aucun Build Azure DevOps n'a été lancé à Round 2.
- Aucun JMeter Cur/Fix n'a été lancé.
- Aucun package, JMX, image, backup ou résultat n'est revendiqué comme consommé.
- Les 485 échecs historiques du build `4432554` restent la baseline documentée ; aucun résultat nouveau ne permet de reclasser leurs causes.
- Les modifications préexistantes du dépôt documentaire et les preuves des autres workers ont été préservées ; aucun canonique n'a été modifié par cette preuve.

