# Ressources et nettoyage

## Créées

- `evidence/fulltext/patch-review-rerun.txt` : sortie expurgée du test local, sans secret.
- `evidence/fulltext/file-hashes.tsv` : empreintes SHA-256 des fichiers déclaratifs relus.
- `worktrees/fulltext/` : répertoire réservé; aucun clone ni fichier produit.
- `worktrees/platformdeploy/` : clone indépendant local, source `93f91487...`, patch commit `e20c50acf33d11d8bba1cd10facb89dfd4bd4902`.
- `evidence/platformdeploy/` : README, harnesses et scripts fixtures inertes; aucun secret.
- Source historique figée relue : `investigations/ecarts-jmeter-migrations/evidence/2026-09-07-brain-reprise-consolidated/README.md` (4432602 → PlatformDeploy 5.0.86, tag/commit et limites d'archive).
- Source workflow relue : `worktrees/Y2_Tools_Jmeter_Workflow` HEAD `4db2dcdab647249de3cdc27eadaf15a158b3a26a`, avec modification utilisateur préexistante `azure-pipeline.yml` préservée.
- `evidence/platformdeploy/round4-private-staging-20260908/` : archive et extraction privées; source/extraction hashées identiquement le 2026-09-08.
- `evidence/platformdeploy/round4-packaging-azdo.md` : manifeste packaging et lecture AzDO ciblée; aucune donnée sensible ni artefact distant copié.

## Nettoyage

**FACT** — aucun conteneur, volume, service SQL/IIS, branche, définition, package, image ou artefact externe n'a été créé ou lancé par ce round. Aucun nettoyage externe requis.

**UNKNOWN** — l'état runtime des anciens builds 4442685/4442156 n'est pas reconstitué; les preuves indiquent un `docker rm -f` dans le YAML, sans logs de cleanup récupérables.

**FACT** — Round 2 n'a créé ni lancé de ressource externe; aucun nettoyage externe requis. Le clone et les fixtures restent présents dans le périmètre exclusif pour reprise contrôlée.

**FACT** — l'archive privée PlatformDeploy a été construite et extraite dans `round4-private-staging-20260908`; source et extraction `init-container.ps1` ont le même hash.

**UNKNOWN** — la lecture AzDO ciblée a échoué au TLS avant réponse; aucune ressource distante n'a été créée, modifiée ou téléchargée.
