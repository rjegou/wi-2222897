---
type: "EvidenceCollection"
title: "Clienteling WI-2222897 — préconditions JMeter et attestation cible"
timestamp: "2026-09-08"
source_system: "local Windows workspace; sources and scripts read-only"
freshness: "2026-09-08 local verification; no Azure DevOps run or publication"
---

# Périmètre

Collecte bornée pour le responsable du pipeline 14264. Aucun YAML, définition,
image, feed, cible ou donnée partagée n'a été modifié. Aucune campagne JMeter n'a
été lancée. Les chemins temporaires ci-dessous sont des sources locales relues,
pas des artefacts Azure DevOps identifiés.

## Artefact JMeter réel

**FACT** — une distribution Apache JMeter 5.6.3 contenant `bin/jmeter.bat` est
présente localement sous
`C:\Users\jegour\AppData\Local\Temp\jmeter-5.6.3-runtime\apache-jmeter-5.6.3`.
`jmeter.bat -v` a retourné la bannière Apache JMeter `5.6.3` le 2026-09-08.
La commande a émis uniquement des avertissements de plugins et de préférences
Windows; aucun plan de test n'a été exécuté.

**FACT** — l'archive source relue à trois emplacements locaux porte la même
empreinte SHA-512 :
`387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B016307`.
Les sources sont l'artefact d'évidence API indexé, l'évidence JMeter XPath et
`C:\Users\jegour\AppData\Local\Temp\jmeter-5.6.3-download\apache-jmeter-5.6.3.zip`.

**FACT** — l'extraction runtime contient 221 fichiers pour 80,671,624 octets,
dont 157 fichiers sous `lib` (77,928,820 octets) et 15 JAR sous `lib\ext`
(3,965,117 octets). Empreintes SHA-256 utiles : `bin\jmeter.bat` =
`2BF83EC8A782018DA51122F3F7411FA374FF45A55F698B50B5EE40972684F99B`,
`bin\jmeter.properties` =
`28F615FB66FEE752A5647E590E7231E0734856A546D88AA0CD62341985FF634F`.
Les extensions observées sont les JAR Apache JMeter standard (bolt,
components, core, ftp, functions, http, java, jdbc, jms, junit, ldap, mail,
mongodb, native et tcp).

**INFERENCE** — cette distribution est suffisamment caractérisée pour être
stagée par le worker artefacts dans un `PipelineArtifact` dédié contenant
`apache-jmeter-5.6.3\bin\jmeter.bat`, son archive et ce manifeste. Le build
Azure DevOps et le nom d'artefact exact restent à renseigner par le producteur;
aucun `jmeterArtifactBuildId` réel n'est établi ici.

## Contrat d'attestation lu

**FACT** — `Assert-Wi2222897ArtifactManifest.ps1` exige au minimum `scope`,
`cleanupScope`, `appHost` et `dbHost`, avec `scope=WI-2222897`, hôtes et scope
de nettoyage correspondant à `^wi2222897-[A-Za-z0-9._-]+$`. Le runner JMeter
exige en plus `variant=Cur|Fix`, un JMX manifest `kind=jmx`, un fichier JMX
hashé, et `jmeter.bat` dans l'input.

**FACT** — le contrat d'attestation hôte relu sous
`bw2-environments/evidence/attestation` vérifie l'identité de ressource et de
conteneur, état running, `imageDigest`, OS, run/job/tentative, hôte,
endpoint, mounts, networks, ports et propriétaire de cleanup. Les fixtures
valid/shared sont synthétiques et ne constituent pas une attestation Cur/Fix.

## Valeurs vérifiées et inconnues pour 14264

| Champ requis | Valeur établie | Statut / preuve |
|---|---|---|
| cible Cur/Fix | aucune cible live dédiée observée | UNKNOWN |
| image + digest | aucun digest réel Cur/Fix | UNKNOWN; les digests des fixtures sont synthétiques |
| backup + paramètres comparables | aucun backup/paramètre de cible attesté | UNKNOWN |
| données/fixtures | JMX et fixtures locales seulement; transport pipeline non prouvé | FACT local / UNKNOWN distant |
| réseau/endpoints/ports | aucune cible live vérifiée | UNKNOWN |
| ressources dédiées | préfixe contractuel `wi2222897-` seulement | UNKNOWN; aucun hôte producteur |
| cleanup ciblé | contrat exige un scope propriétaire `wi2222897-*`; exécution réelle absente | UNKNOWN |
| `jmeterArtifactBuildId` | aucun ID exact | UNKNOWN; preflight doit refuser |

Le diagnostic Full-Text borné déjà préparé reste pertinent comme précondition
SQL indépendante, mais sa résolution ne doit pas bloquer la caractérisation du
toolchain JMeter. Les 224 cas historiques ne sont pas un résultat d'une
nouvelle campagne Clienteling.

## Scripts exécutables préparés, non exécutés

`Invoke-Wi2222897EphemeralTarget.ps1` exige `-Provision`, une image locale
digest-pinnée, un backup acquis et hashé, ainsi qu'un reçu de restauration
`scope/runId/variant/status=PASS`. Il crée ensuite uniquement un réseau et un
conteneur portant les labels WI-2222897 du run, sans port publié, monte le backup
en lecture seule, inspecte l'identité réelle et écrit l'attestation seulement
après cette inspection. `Remove-Wi2222897EphemeralTarget.ps1` vérifie ces labels
avant de supprimer uniquement le conteneur et le réseau vide du run, puis vérifie
leur absence. Le réseau est interne et aucun port hôte n'est publié : le job
doit prouver le chemin réseau privé JMeter→cible ou exécuter JMeter dans le même
contexte. Les deux scripts ont zéro erreur de parsing PowerShell et n'ont pas été
exécutés.

## Contrat de dépôt à transmettre au worker artefacts

Déposer, sans publication partagée, un PipelineArtifact dont le manifeste
contient : build ID exact, définition, commit/source, archive et SHA-512
ci-dessus, version `5.6.3`, présence de `apache-jmeter-5.6.3\bin\jmeter.bat`,
empreintes des fichiers critiques, et liste des dépendances `lib`/`lib\ext`.
Le responsable 14264 doit ensuite renseigner `jmeterArtifactBuildId` et
`jmeterArtifactDefinitionId` et prouver la lecture indépendante de l'artefact.

La collecte amont round6 (`evidence/local-2026-09-08-clienteling-upstream-artifacts-round6`)
confirmait qu'aucun JMX éligible ni artefact distant Console/Migration/JMeter n'avait
été transporté. La preuve Round7 `local-2026-09-08-clienteling-isolated-pipeline-round7`
établit ensuite que la branche isolée `b790767c1cecb90d6913c8726aea532c29ea4582`
télécharge JMeter 5.6.3 directement dans chaque job Cur/Fix et vérifie la SHA-512
fixe ci-dessus. Le transport PipelineArtifact JMeter n'est donc plus une dépendance
du contrat courant; le manifeste local reste la référence de vérification.

## Verdict

**FACT** — le toolchain JMeter réel est disponible localement et hashé.
**UNKNOWN** — son transport PipelineArtifact, les cibles Cur/Fix, l'image/digest,
le backup/jeu de données, le réseau et le cleanup réel ne sont pas prouvés.
Le prochain test minimal est donc la production/lecture indépendante de cet
artefact et d'une attestation de cible dédiée avant tout lancement; aucune
attestation ne doit être fabriquée pour faire passer le preflight.
