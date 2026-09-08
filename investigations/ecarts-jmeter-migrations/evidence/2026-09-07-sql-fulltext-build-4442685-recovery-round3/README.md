# Voies officielles de téléchargement — Full-Text 4442685

Date de collecte : 2026-09-07 (Europe/Paris). Source : Azure DevOps `cegid/Retail`, build `4442685`, artefacts `sql-fulltext-2019-evidence` et `sql-fulltext-2025-evidence`. Méthode : Python `requests`, certificats TLS vérifiés, PAT utilisé uniquement vers `dev.azure.com`. Aucun pipeline, run, définition, branche ou dépôt n’a été modifié.

## Méthode 1 — Get Artifact avec négociation ZIP

Référence officielle : [Build Artifacts - Get Artifact](https://learn.microsoft.com/en-us/rest/api/azure/devops/build/artifacts/get-artifact?view=azure-devops-rest-7.1). Requête `GET .../_apis/build/builds/4442685/artifacts?artifactName=...&api-version=7.1`, en-tête `Accept: application/zip`, certificats vérifiés et redirections désactivées.

- **FACT** — SQL2019 : HTTP `302`, destination `artprodsu6weu.artifacts.visualstudio.com`, aucun ZIP retourné.
- **FACT** — SQL2025 : HTTP `302`, destination `artprodsu6weu.artifacts.visualstudio.com`, aucun ZIP retourné.
- **Limite de sécurité** — la redirection externe n’a pas été suivie avec le PAT.

## Méthode 2 — Ticketed Artifacts

Référence officielle : [Ticketed Artifacts - Get](https://learn.microsoft.com/en-us/rest/api/azure/devops/build/ticketed-artifacts/get?view=azure-devops-rest-4.1). La métadonnée `Get Artifact` a été relue sur `dev.azure.com` pour rechercher `resource.downloadTicket`, puis l’endpoint ticketé officiel a été appelé uniquement sur `dev.azure.com`.

- **FACT** — les deux ressources contiennent les clés `data`, `downloadUrl`, `properties`, `type`, `url`; aucune clé `downloadTicket` n’est fournie.
- **FACT** — l’endpoint ticketé retourne HTTP `404` pour SQL2019 et SQL2025; aucun contenu ZIP n’est reçu.
- **FACT** — aucun PAT n’a été transmis à `artprodsu6weu.artifacts.visualstudio.com` ni à `spsprodweu3.vssps.visualstudio.com`.

## Conclusion de récupération

**FACT** — les deux voies officielles documentées et bornées n’ont pas permis de récupérer les artefacts. Cela établit une dépendance de téléchargement/authentification, pas l’absence du contenu. Les logs REST déjà collectés établissent toutefois que SQL2019 et SQL2025 atteignent le probe puis échouent sur `Full-Text population did not finish: [1]`; les diagnostics générés dans les artefacts, notamment DMV/ERRORLOG/cleanup, restent non lisibles.

**UNKNOWN** — `IsFullTextInstalled` numérique, `TableFullTextPopulateStatus`, lignes `sys.dm_fts_index_population`, erreurs FDHOST/ERRORLOG, `CONTAINSTABLE` et état final des conteneurs/bases. Aucun nouveau run ne doit être lancé uniquement pour contourner ce blocage.

