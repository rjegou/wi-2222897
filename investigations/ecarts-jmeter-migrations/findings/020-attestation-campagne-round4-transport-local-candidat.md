# Finding 020 — Round 4 (rapporté) : re-collecte indépendante des 4 builds, cleanup requalifié `UNKNOWN`, gabarit de transport local candidat

## Périmètre et provenance

- **Système** : Azure DevOps `cegid/Retail`, builds `4447425` (InventoryTracking), `4440884`
  (InventoryTracking, baseline), `4445575` (InventoryTracking, run tronqué) et `4432554`
  (Clienteling master V26).
- **Source** : clone de travail hors dépôt `C:\clones\wi-2222897-bw\relais-20260909-02\attestation\`
  (non versionné, non sauvegardé par ce dépôt — voir [EXTERNAL-ARTIFACTS.md](../../../EXTERNAL-ARTIFACTS.md)
  pour la règle générale sur les clones hors dépôt). Collecteur `scripts/invoke_bw3_collector.py`,
  copie durcie d'un relais précédent : whitelist stricte des 4 builds ci-dessus, refus explicite du
  build `2054` (FrenchTaxesRules, hors périmètre de ce collecteur) avant tout appel réseau, refus
  d'écrire dans un dossier de sortie non vide, PAT lu en mémoire depuis `azureToken.txt` et jamais
  journalisé. `python -m pytest -q tests/test_collector.py` : 8 tests passés (lus dans ce processus,
  voir `tests/test_collector.py` ci-dessous).
- **Preuve associée** : copie intégrale de la couche documentaire (sans les `collector-report.json`
  bruts, volumineux) dans
  [evidence/local-2026-09-09-attestation-campagne-round4/](../evidence/local-2026-09-09-attestation-campagne-round4/README.md).
- **Statut de fraîcheur : rapporté, non revérifié.** Le collecteur a effectué des lectures REST réelles
  *dans le processus source*, mais cette intégration ne relit pas Azure DevOps elle-même. Traiter au
  même titre que les intégrations des [finding 018](018-frenchtaxesrules-v26-jmeter-execution-4448787.md)
  et [finding 019](019-clienteling-v26-generatejmx-testcampaign-outputfiles.md).

## Partie 1 — Attestation de campagne consolidée (round 4)

**Rapporté** — pour les 4 builds, le collecteur établit par lecture REST fraîche :

| Build | Stage/tâches JMeter | Découverte des runs | Cur/Fix | JMX Git au `sourceVersion` | Cleanup |
|---:|---|---|---|---|---|
| `4447425` | tâche `Run Jmeter Tests Campaign` Cur/Fix `completed`, non `skipped` | requête exacte `buildUri=vstfs:///Build/Build/4447425`, 3 runs dont un vide | **1991 / 1991** | **32 blobs** hashés | `Remove-Item` en log de préparation seulement ; pas de preuve d'exécution |
| `4440884` | idem | idem (`.../4440884`) | **1991 / 1991** | **32 blobs** hashés | idem |
| `4445575` | idem, erreurs de chargement observées pour le plan affecté | idem (`.../4445575`) | **1905 / 1905** | **32 blobs** hashés | idem |
| `4432554` | idem | idem (`.../4432554`) | **2118 / 2118** | **151 blobs** hashés | idem |

**INFERENCE — convergence avec les collectes déjà versionnées.** Les quatre comptes Cur/Fix
concordent exactement avec les valeurs déjà établies indépendamment dans ce dépôt : `1991/1991` pour
`4447425` et sa baseline `4440884` ([finding 017](017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md)),
`1905/1905` pour le run tronqué `4445575` ([finding 015](015-inventorytracking-002-device-reassign-jmx-load-4445575.md)),
`2118/2118` pour Clienteling `4432554` ([finding 006](006-clienteling-v26-build-4432554.md), cité par
[finding 019](019-clienteling-v26-generatejmx-testcampaign-outputfiles.md)). Le compte des 32 chemins
JMX InventoryTracking recoupe aussi le chiffre indépendant « 32 chemins attendus » de l'audit BW3 du
2026-09-09 (voir
[evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/](../evidence/local-2026-09-09-bw3-audit-et-ftr-v26-execution-reelle/README.md)).
Cette convergence renforce la confiance sans constituer une lecture indépendante par ce processus.

**Ne pas confondre** — le compteur de **32 blobs JMX InventoryTracking** ci-dessus n'a aucun rapport
avec le **compteur fixe 32** du validateur FrenchTaxesRules déjà documenté dans
[STATUS.md](../../../STATUS.md) (ligne « Générateur JMX ») et dans
[l'inventaire round7](../evidence/local-2026-09-08-frenchtaxesrules-round7/README.md) : deux dépôts,
deux mécanismes, même valeur numérique par coïncidence.

**UNKNOWN — exhaustivité des inventaires JMX.** Le collecteur hache tous les `.jmx` trouvés sous le
`sourceVersion` de chaque build, mais ne prouve pas que cette liste est exhaustive au sens du contrat
de campagne (aucune comparaison avec un manifeste de référence indépendant pour ces 4 builds).

**UNKNOWN → nuance requise — cleanup.** Le signal « cleanup » de ce round 4 est un grep de lignes
`Remove-Item`/`docker rm`/`docker stop` dans les logs de préparation, sans lien avec le résultat de la
tâche. Il ne réfute pas le fait déjà établi le 2026-09-08 dans
[RESOURCES.md](../../../RESOURCES.md#2026-09-08--reprise-directe-azdo-sans-bw--inventaire-et-dépollution)
par lecture directe de la timeline : pour `4447425` spécifiquement, la tâche `Stop Containers` est
`completed`/`succeeded` à 17:44:08 UTC (Fix) et 17:55:00 UTC (Cur) — un signal plus fort (résultat de
tâche) que celui de ce round 4 (grep de log). Pour `4440884`, `4445575` et `4432554`, aucun résultat de
tâche `Stop Containers` équivalent n'a été établi ailleurs dans ce dépôt : le cleanup y reste `UNKNOWN`
sans amélioration ni régression par rapport à l'état antérieur.

**Runtime JMX consumption : `UNKNOWN`** pour les 4 builds — le hash Git au `sourceVersion` prouve le
contenu au commit, pas les octets effectivement consommés par le runner JMeter, distinction déjà posée
par [finding 015](015-inventorytracking-002-device-reassign-jmx-load-4445575.md) et l'audit BW3 du
2026-09-09.

## Partie 2 — Gabarit candidat de transport local de package (non appliqué)

**Portée** : préparation documentaire seule pour un **prochain couple non nommé** du chantier ; aucun
build, queue ou lecture distante n'a été effectué pour ce livrable.

**FACT rapporté, dérivé de findings déjà versionnés** — le gabarit reprend exactement deux faits déjà
établis dans ce dépôt, sans en ajouter :

1. le transport `PipelineArtifact + manifest` a suffi au parcours InventoryTracking du run `4447425`
   ([finding 017](017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md)) — la
   restauration des 86 tests de `002-Device:Reassign` reste attribuée au correctif JMX
   (`<hashTree/>` manquant), **pas** au mécanisme de transport ;
2. FrenchTaxesRules utilise un sous-dossier `localPackageRoot` limité aux 4 fichiers exacts du
   manifest, distinct de l'artifact `_Software` complet de 12 fichiers
   ([finding 018](018-frenchtaxesrules-v26-jmeter-execution-4448787.md), lui-même **rapporté, non
   revérifié**).

**INFERENCE** — la procédure en 5 étapes et les conditions d'arrêt du gabarit (sélection stricte d'un
manifeste, copie limitée aux `N` entrées qu'il liste, refus de chemin absolu/traversée `..`/fichier
surnuméraire, hash et taille vérifiés avant passage au déploiement, preuve de cleanup séparée d'un
statut vert) sont un candidat réutilisable pour cadrer une prochaine préparation. Ce n'est pas une
interface publiée ni un pipeline exécutable : tous les paramètres (`sourceBuildId`, `artifactName`,
`packageVersion`, `manifestPath`, `localPackageRoot`, `deploymentTarget`, `sourceCommit`, et le couple
cible lui-même) sont explicitement `UNKNOWN` dans le gabarit et doivent être renseignés depuis le
manifeste réellement sélectionné avant tout usage — `N = 4` n'est qu'une valeur d'exemple issue du cas
FrenchTaxesRules rapporté, pas une constante générale.

**UNKNOWN** — le couple cible, tous ses paramètres de provenance, et le caractère isolé/committé/
généralisable du raffinement `localPackageRoot` de FrenchTaxesRules (déjà signalé `UNKNOWN` par
[finding 018](018-frenchtaxesrules-v26-jmeter-execution-4448787.md#ce-que-cette-fiche-résout-et-ce-qui-reste-ouvert)).
Ce gabarit ne constitue pas une preuve d'exécution même si un pipeline futur qui l'utilise devient vert.

## Ce que cette fiche ne fait pas

Aucune lecture Azure DevOps, aucune relance de build, aucune modification de pipeline, de package ou de
code n'a été effectuée pour produire cette fiche. Le contenu intègre des documents et un rapport de
collecteur produits par un processus distinct, copiés sans modification, avec confrontation réussie de
leurs empreintes SHA-256 aux valeurs déclarées par la source (voir
[evidence/local-2026-09-09-attestation-campagne-round4/README.md](../evidence/local-2026-09-09-attestation-campagne-round4/README.md)).
