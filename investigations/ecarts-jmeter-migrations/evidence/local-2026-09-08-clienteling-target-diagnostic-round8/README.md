# Diagnostic cible 14264 — round 8

Date : 2026-09-08, Europe/Paris. Définition observée : `14264` (`WI-2222897 Clienteling Isolated Replay`).

## Candidat Console accepté

**FACT** : le manifeste `local-2026-09-08-console-build-4445025-review-round7/manifest-console-4445025.json`
est intégré comme provenance distincte : run `4445025`, artefact `5037277`, version
`2.0.43-wi2222897-console-candidate`, package SHA-256
`796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE`, API build amont `4444765`.
Le package local `803D…` n'est plus requis comme candidat unique.

## Runs 14264 récents

**FACT** : les runs `4445072`, `4445085` et `4445099` sont tous terminés `canceled`, sur la branche
`sandbox/clienteling/wi2222897-isolated-replay`, respectivement aux commits
`23830d47c0cdb31d8c84020ecd3a701824c03661`, `13b4443675bcdbb62e6da9fcdb9565dd5e671fb5` et
`0cf1736787def6d4fe2788b73cafdd8777768730`. Leur raison est `individualCI`; aucune timeline,
aucun log et aucun artefact n'est disponible, ce qui indique une annulation avant exécution d'un job.
Aucun run résiduel en cours n'a été laissé ignoré.

## Diagnostic lecture seule de l'agent observé

Commandes exécutées : `docker --version`, `docker info`, `docker image ls`, recherche des `.bak` sous
`.work`. Résultats directs conservés dans `.work/target-diagnostic-round8/diagnostic.txt` :

- Docker client `27.4.0` présent ; avertissement d'accès refusé au fichier de configuration Docker ;
- `docker info` et `docker image ls` échouent car le pipe `//./pipe/docker_engine` est absent : aucun
  daemon Docker accessible dans cet agent ;
- aucune image locale ni aucun digest lisible ;
- aucun backup `.bak` dans le périmètre `.work`.

Le script fail-closed `local-2026-09-08-clienteling-target-preflight-round8/Invoke-Wi2222897TargetPreflight.ps1`
refuse correctement toute provision sans image digestée, backup/hash et mot de passe SQL éphémère.
Je n'ai pas utilisé `-Provision`, créé de réseau/conteneur, tiré d'image, restauré de base ou modifié
de donnée partagée.

## Verdict

**BLOCKED — diagnostic réel reproductible.** L'agent observé ne permet pas de produire l'attestation
de cible exigée par le preflight : daemon Docker absent, image/digest absent, backup/hash absent.
En conséquence, aucun Build/GenerateJmx/Cur/Fix n'a été relancé avec des paramètres incomplets.

Déblocage minimal : un job Windows autorisé avec daemon Docker, accès privé à l'image digestée et au
backup `AUTO_V26_00.bak`, puis exécution du script de préflight pour Cur et Fix dans le même réseau
interne. L'attestation devra être produite après `RESTORE FILELISTONLY`, restauration et vérification
de `sys.databases`, pas fabriquée à partir d'une attestation locale.

