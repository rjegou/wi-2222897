# Resources and cleanup

- `worktrees/api/`: independent local source copy with its own `.git`, baseline commit `8461c8d…`, and uncommitted API patch. Retain for integration review.
- `evidence/api/runtime/`: local build output, including API DLL and copied build dependencies. Retain as evidence; no shared feed or publication.
- `evidence/api/obj/`: local MSBuild intermediates. Cleanup status: UNKNOWN; no deletion performed to preserve reproducibility.
- `evidence/api/build.log`, `rebuild.log`: scrubbed build logs from local compilation; no secrets intentionally included.

No external resources were created, queued, published, pushed, tagged or deleted.

Console round 2 : le package local sous `evidence/migration/fixtures/run/PublishedSharedTools/...` est conservé comme preuve, sans publication. L'incident d'un secret transitoirement exporté puis retiré est seulement rapporté ; aucune valeur n'a été lue ou affichée et le nettoyage n'est pas considéré indépendant avant vérification par le worker migration. Aucun nettoyage global ni suppression de logs n'a été effectué.
