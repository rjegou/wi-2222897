# Ressources et dépollution

- `fixtures/` : packages.config synthétiques et répertoire de test local.
- `checkPackage-test-results.txt` : sorties expurgées et codes de retour.
- `worktrees/migration/` : snapshot local indépendant, sans secret dans l’arbre courant.
- L’archive d’export intermédiaire contenant un fichier suivi sensible a été supprimée; le fichier sensible a été supprimé du clone et l’historique local purgé. Vérification finale : chemin absent et `git ls-files` sans token/secret/password/credential.
- Aucun cache, processus, téléchargement, queue, publication ou ressource distante créé par cette collecte. Nettoyage des artefacts temporaires : confirmé pour l’archive; état des ressources historiques externes : UNKNOWN, non touchées.

