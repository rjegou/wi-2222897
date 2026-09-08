# Round 4 — Preflight runtime dédié

Date : 2026-09-08 (Europe/Paris).

## Audit préalable

**FACT** — candidat local `worktrees/fulltext/fulltext-dedicated-preflight.yml`, SHA-256 `3D22CFBBFC0038FE62D230BF3C420BFB48A046C9BFDB3EF6300DA20D7CF7C43F`.

**FACT** — parse YAML PASS : `trigger=none`, `pr=none`, `schedules=[]`, stages `Host2022` et `Host2025`; deux blocs PowerShell parse PASS.

**FACT** — graphe limité à : VM Microsoft-hosted → collecte OS/Docker → pull read-only des images Server Core MCR → inspection ID/digest/OS/architecture → conteneur neutre `--network none`, entrypoint PowerShell inerte, sans mount ni port → inspection ciblée → `docker rm -f` du seul nom possédé en `finally`. Aucun checkout, SQL, IIS, restauration, JMeter, publication d’artefact, feed, JFrog, promotion, tag, downstream trigger ou registry push.

**FACT** — les propriétés imprimées sont limitées à OS/build/architecture, version Docker, propriétés image sélectionnées, digest, état du conteneur, réseau/mounts/ports et cleanup. Aucun `docker inspect` brut, credential ou secret n’est imprimé.

## Tentative distante et refus

**FACT** — branche cible vérifiée absente avant action : `investigation/wi-2222897-2026-09-08-parallel-1788841150349-env`; définition cible vérifiée absente : `WI-2222897 FullText Dedicated Preflight 20260908`.

**FACT** — une seule tentative REST HTTPS de création de branche/commit depuis le commit de base `e3b674b007071259fd74b024f6b4b48baf0a7f5d` a répondu HTTP `403` : `TF401027: You need the Git 'CreateBranch' permission to perform this action ... scope 'repository'`.

**FACT** — readback après refus : branche `0` correspondance, définition `0` correspondance. Aucun commit, branche, définition, run, conteneur ou image distante n’a été créé par cette tentative. Aucun retry ni contournement n’a été effectué.

## Résultat

**UNKNOWN** — OS/Docker/digest/mode container réels des VM Microsoft-hosted pour ce preflight, car le YAML n’a pas pu être branché ni exécuté.

**BLOCAGE EXTERNE MINIMAL** — accorder `Git CreateBranch` sur le dépôt `Pipelines_Docker_BaseImages` à l’identité autorisée, ou fournir une branche déjà créée portant exactement le YAML hashé et une définition dédiée sans effets. Après seulement, créer la définition dédiée et lancer un run unique; ne pas modifier la définition historique `14251`.

## Sources officielles

- VM fraîche par job Microsoft-hosted : https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops
- Routage pool/job : https://learn.microsoft.com/en-us/azure/devops/pipelines/process/runs?view=azure-devops
- Compatibilité Windows host/image : https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility
