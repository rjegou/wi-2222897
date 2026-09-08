# V22 candidate artifacts and provenance — Worker 1 round 4

Date de collecte : 2026-09-07 (Europe/Paris). Périmètre strictement read-only ; aucun pipeline, queue, publication, promotion ou déploiement lancé.

## PlatformDeploy : identité du ZIP versus commit du code

**FACT** — les logs du run Azure DevOps `4429167` donnent la chaîne historique suivante :

- `JFrogGenericArtifacts`, logs `242`, `245`, `261` (succès) : source `retail-software-production/Y2.Tools.PlatformDeploy/PlatformDeploy.5.0.86.zip`, téléchargement `1` réussi ;
- `ExtractFiles`, logs `244`, `246`, `263` (succès) : extraction du fichier `C:\__w\_temp\Y2.Tools.PlatformDeploy\PlatformDeploy.5.0.86.zip` ;
- version ZIP : `5.0.86` ;
- source exacte : `https://cegid.jfrog.io/artifactory/retail-software-production/Y2.Tools.PlatformDeploy/PlatformDeploy.5.0.86.zip`.

**FACT** — une lecture JFrog actuelle du même chemin (token en mémoire, jamais reproduit) a répondu HTTP `200`, taille `7,566,674` octets, SHA-256 serveur `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295`, et le flux téléchargé en mémoire a donné `7,566,674` octets et le même SHA-256. Métadonnée JFrog : `lastModified=2026-08-18T14:24:42.963Z`, SHA-1 `f01fb95807ae6e962e95b0adea44b6074ed1a0af`.

**FACT** — le checkout PlatformDeploy du run `4429167` était au commit code `93f91487ee717185599555a42df3cb5d024ace89` (log checkout `231`/`227`). Ce commit est une provenance du dépôt, pas l'identité cryptographique du ZIP distribué. Le YAML de replay renseigne maintenant séparément `platformDeployCommit=93f...`, `platformDeployVersion=5.0.86` et `platformDeployZipSha256=625E...`.

## Image historique

**FACT historique** — le log ACR du run `4429167`, log `15`, associait le tag `y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022` au digest `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.

**UNKNOWN actuel** — la disponibilité actuelle du digest n'a pas pu être revalidée dans cette collecte : les requêtes JFrog/ACR depuis ce poste ont échoué avant réponse HTTP avec `The SSL connection could not be established` ; `curl.exe` a retourné Schannel `SEC_E_NO_CREDENTIALS (0x8009030E)`. Le digest historique ne doit donc pas être présenté comme actuellement tirable. Le YAML candidat conserve son image 2025 explicitement sélectionnée ; aucune substitution implicite n'a été faite.

## Packages baseline / candidat

**FACT candidat, revalidation JFrog du 2026-09-07 référencée** — les trois ZIP candidats ont été lus en HTTP 200, téléchargés en flux et vérifiés par SHA-256 dans `../2026-09-07-jfrog-v22-packaging-revalidation/README.md` :

| composant | version | chemin | SHA-256 |
|---|---|---|---|
| Y2.Core | 22.0.0.2068 | `Y2.Core/22.0/Y2.Core.22.0.0.2068.zip` | `1AC0BF6084F0AB62B38C2DC15BC72A7D3B57EEC6661FCF03F056322611144B7C` |
| Y2.Core.Common | 22.0.3.311 | `Y2.Core.Common/3.311/Y2.Core.Common.22.0.3.311.zip` | `540E96AE56B912F1F27DD17865B76E342D72024B46CE5994F5CF9B7FC7A590D2` |
| Y2.Plugin.Identity | 22.0.6.117 | `IdentityPlugin/6.117/Y2.Plugin.Identity.22.0.6.117.zip` | `7F4426E5DB4DD94B040BD39B8EB2A3485FD9387BCEC667DD9663A35E840A96CF` |

**FACT historique** — le run `4429167` a acquis le baseline Fix via les chemins `Y2.Core/22.0/Y2.Core.22.0.0.1011.zip`, `Y2.Core.Common/2.300/Y2.Core.Common.22.0.2.300.zip` et `IdentityPlugin/5.182/Y2.Plugin.Identity.22.0.5.182.zip` (présents dans `downloadedPackages.json` et les logs d'installation).

**UNKNOWN** — aucun hash baseline n'est présent dans les preuves locales de ce lot, et sa disponibilité JFrog actuelle n'a pas pu être testée à cause de l'échec TLS local. Les versions baseline sont donc des identifiants historiques de l'acquisition, pas une preuve de re-tirabilité actuelle.

## Classification et suite

- **FACT** : PlatformDeploy `5.0.86` et son SHA-256 sont résolus ; les deux placeholders correspondants ont été remplacés, sans modifier le commit code.
- **FACT** : les hashes candidats Core/Common/Identity existent dans la revalidation JFrog datée du même jour.
- **UNKNOWN** : disponibilité actuelle de l'image historique ; hashes/disponibilité actuelle des trois ZIP baseline ; compatibilité runtime et résultat JMeter.
- **INFERENCE** : le replay peut acquérir un ZIP PlatformDeploy immuable par chemin + SHA, mais il reste prématuré de figer l'image historique ou de conclure sur le baseline sans revalidation réseau indépendante.
