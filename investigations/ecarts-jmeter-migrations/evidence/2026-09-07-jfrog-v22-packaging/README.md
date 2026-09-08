# JFrog V22 — synthèse des lectures du 2026-09-07

Provenance : réponses REST JFrog et Azure DevOps observées pendant la conversation du 2026-09-07, transcrites ici après collecte. Ce fichier est une synthèse de résultats, pas une archive JSON brute ni une inspection binaire. Fraîcheur : snapshot daté ; revalider disponibilité et hashes avant acquisition/exécution.

Conclusion et protocole canoniques : [finding 004](../../findings/004-french-taxes-rules-v21-v23-build-4429167.md).

## Accès et méthode

- Base : `https://cegid.jfrog.io/artifactory`.
- Le premier accès anonyme à `/api/storage/retail-software-production` répondait 401. Avec le token fourni par l'utilisateur, `GET /api/system/ping` répond `OK` et les lectures ciblées réussissent. Un ping seul ne prouve pas les droits sur un dépôt.
- Source du token autorisée par l'utilisateur : `C:\Users\jegour\OneDrive - CEGID\Documents\jfrogToken.txt`. Charger uniquement en mémoire dans un header Bearer ; ne pas afficher, copier ou consigner sa valeur. Ne pas confondre avec le fichier sensible homonyme du worktree Migration_Jmeter_RJE_Sandbox.
- Référence d'accès existante : [contexte JFrog](https://dev.azure.com/cegid/Retail) <!-- lien d'origine vers la KB `context/references/jfrog/`, hors de ce depot -->.
- Lectures : `GET /api/storage/{repo}/y2-distrib/22.0`, puis `/22.0.23`, GET direct du manifeste, GET des métadonnées des trois fichiers du packaging ; POST AQL limité aux trois noms de ZIP candidats en production, opération de recherche uniquement.
- Aucun PUT, DELETE, copy/move, promotion ou déploiement. Aucun ZIP téléchargé, aucun nouveau fichier temporaire ni secret copié.

## FACT — packaging retrouvé

Dans le dossier standard `retail-software-production/y2-distrib/22.0`, `22.0.23` est la version numériquement la plus élevée listée. Cette observation n'est pas un inventaire de tous les dépôts ou chemins personnalisés. Le dossier staging `y2-distrib/22.0/22.0.23` existe mais ne contient aucun enfant listé.

En production, `/y2-distrib/22.0/22.0.23/` contient :

| Fichier | Taille octets | lastModified UTC | SHA-256 renvoyé par JFrog |
|---|---:|---|---|
| ArtifactsToDownload.json | 5448 | 2025-11-17T13:30:05.072Z | 4874efcc106a3fd5c69661655227bd9c204998a87e681ba2fb4335fd923727f0 |
| Edition2022_Package23.zip | 1290723031 | 2025-11-17T13:30:14.491Z | 2fb4ba3ff9f3e3fc59007b11d7d75021ab54e5b8e629141e5545a0e88bae6476 |
| Saas_Retail_Package_22.0.23.zip | 1076424817 | 2025-11-17T13:30:12.531Z | 1e2480315bc471b8325f3242f240385048f8bc5b81478b64758a864f77b760bf |

[Manifeste lu directement](https://cegid.jfrog.io/artifactory/retail-software-production/y2-distrib/22.0/22.0.23/ArtifactsToDownload.json) : Core `22.0.0.2068`, Common `22.0.3.311`, Identity `22.0.6.117`, FrenchTaxesRules `22.0.6.379`, AuthenticationServer `1.0.1.429` (`OnPremOnly`). Empreintes ci-dessus : métadonnées serveur, pas calcul local sur les ZIP.

## FACT — packages individuels disponibles

Recherche AQL avec `repo=retail-software-production`, union exacte des trois noms ci-dessous, champs `repo,path,name,size`, limite 20 : trois résultats, total 3.

| Chemin relatif à retail-software-production | Taille octets |
|---|---:|
| Y2.Core/22.0/Y2.Core.22.0.0.2068.zip | 417167428 |
| Y2.Core.Common/3.311/Y2.Core.Common.22.0.3.311.zip | 32019299 |
| IdentityPlugin/6.117/Y2.Plugin.Identity.22.0.6.117.zip | 3410969 |

Leurs hashes individuels et leur contenu n'ont pas été acquis. Avant un essai : lire les métadonnées exactes, télécharger dans un staging dédié, comparer le hash local au serveur et vérifier les dépendances d'installation.

## FACT — correspondance Azure DevOps

- Dépôt `Y2_SaaS_Packaging`, ID `d8fc31a0-4050-423b-a7cd-1b3866edadb3`.
- Tag `22.0.23`, commit `68a1355db15a52da2efd1b3b0bb2c07aad187223` ; les cinq versions pertinentes du manifeste Git concordent avec celles lues dans JFrog. Aucun hash d'égalité complète Git/JFrog calculé.
- Pipeline 1614 `Y2_SaaS_Packaging CI`, [build 3335646](https://dev.azure.com/cegid/Retail/_build/results?buildId=3335646), numéro `22.0.23`, même commit, résultat `succeeded`, fin `2025-11-18T08:44:23.210098+00:00`.
- `az pipelines runs artifact list --run-id 3335646` renvoie `[]` au moment de la lecture ; cela ne prouve pas pourquoi les artefacts ne sont plus listés.
- Au tag, `pipeline-template/build/publish-to-artifactory.yml` prévoit la publication du manifeste avec les ZIP vers `retail-software-staging/${packageArtifactPath}`. Cette chaîne statique ne prouve pas l'historique de promotion du fichier actuellement en production.

## UNKNOWN et suite

Disponibilité acquise ne signifie pas correction validée. La combinaison proposée conserve un plugin plus récent que celui du packaging ; compatibilité et disparition des 174 refus restent à démontrer par l'avant/après décrit dans la fiche 004. Aucun résultat de test nouveau n'est produit par cette collecte.
