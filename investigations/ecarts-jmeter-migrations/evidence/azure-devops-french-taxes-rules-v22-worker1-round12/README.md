# Préflight V22 corrigé et migration de branche neutre — Worker 1 round 12

Date : 2026-09-07. Collecte immuable des métadonnées et logs non sensibles ; aucun rejeu métier.

## Branche, définition et provenance

- Définition `14246`, nom `WI-2222897 V22 Runtime Preflight 20260907`.
- Branche neutre : `refs/heads/investigation/wi-2222897-v22-preflight-20260907`.
- Commit : `cd632126c17f3ac95c8a29b079d0e243fa538e54`, parent `5036e501ba797ab7efc861add60b111a40ff8141`.
- Diff du commit : une seule ligne dans `/azure-pipelines.wi2222897-v22-preflight.yml`.
- Définition relue après mutation : branche neutre et YAML `/azure-pipelines.wi2222897-v22-preflight.yml`.
- L’ancienne référence de branche explicitement désignée a été supprimée après vérification : aucune exécution active ; `oldObjectId=5036e501…`, suppression réussie.

## Référence et preview

Le YAML distant relu au commit corrigé contient exactement :

`acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`

La preview serveur contient le même hostname, repository, tag et digest. Elle confirme `trigger` désactivé, `pr` désactivé, `schedules: []` et `checkout:none`.

## Run unique corrigé

Run `4442120`, lancé après la relecture du commit et de la preview. Résultat final `succeeded`, terminé `2026-09-07T16:32:13.050441+00:00`.

Timeline : Initialize succeeded ; checkout skipped ; login registry succeeded ; inspection host/image/container/mounts/network succeeded ; hash des sorties succeeded ; post-job checkout et Finalize Job succeeded.

Log inspection : `Digest: sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`, image téléchargée, message de fin sans credentials.

Log hash : deux sorties hashées présentes uniquement dans `Agent.TempDirectory`, aucune publication d’artefact.

## Qualification des preuves

**FACT** — acquisition de l’image au digest attendu et exécution complète du préflight read-only réussies.

**FACT** — le YAML interdit les triggers, le checkout et la publication d’artefact ; aucun stage métier n’est présent dans ce pipeline.

**FACT limité** — la tâche de nettoyage/finalisation a réussi et le script contient un `finally` borné au conteneur nommé du run.

**UNKNOWN** — valeurs détaillées du JSON d’inspection (OS exact de l’image, ID du conteneur, mounts et réseaux), car elles sont restées dans Agent.TempDirectory et n’ont pas été publiées par conception. Le run ne constitue pas un rejeu métier.

Le worktree de travail initialement pollué par la tentative LFS précédente n’a pas été restauré, nettoyé ou checkouté.
