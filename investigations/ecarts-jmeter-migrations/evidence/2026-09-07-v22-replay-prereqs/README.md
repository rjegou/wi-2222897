# Prérequis artefacts/données rejeu FrenchTaxesRules V22 — 2026-09-07

## Périmètre et provenance

Lecture seule du snapshot exact `Y2_Plugins_FrenchTaxesRules-v5-build-4429167`, build Azure DevOps `4429167`, commit `2d826b8fd19ecb4d7200f574414efb7583de8ed2`. Les artefacts de campagne proviennent de `evidence/build-4429167/_extracted/`. Aucun déploiement, restauration, pipeline ou lancement JMeter n'a été effectué.

## Backup

**FACT** — le snapshot contient un seul backup de données : `sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167/Tests/Backups/AUTO_V21_00.bak`, 150515712 octets, SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2`. L'en-tête commence par la signature SQL Server `MSSQLBAK`.

**FACT** — le pipeline passe le dossier `Tests/Backups` au template de déploiement et injecte `DB_NAME=$(backupName)` dans les propriétés JMeter. La valeur résolue de la variable de groupe `TestJmeterVariables` n'est pas présente dans le snapshot YAML. Le nom `AUTO_V21_00.bak` ne doit donc pas être transformé en exigence d'un backup V22.

**UNKNOWN** — backupName réellement résolu, base contenue, compatibilité SQL de restauration et possibilité effective de restaurer ce fichier sur une cible dédiée. La restauration doit rester séparée pour Cur et Fix, sur une cible explicitement dédiée, avec preuve de capacité et hash avant/après.

## Substitutions et sélection

**FACT** — le pipeline sélectionne par défaut les campagnes `LegacyServices` et `WebServices`, le fichier `v22-Cur.cy2px` ou `v22-Fix.cy2px`, puis `Tests/Backups`; il transmet aussi `APPSERVER_HOST`, `DB_HOST`, `DB_NAME`, `DB_INSTANCE`, `AUTHORITY_HOST`, `AUTHORITY_PORT` et `AUTHORITY_APPNAME` au template JMeter (`azure-pipelines.yml`, lignes 285-340).

**FACT** — les deux manifests sélectionnent exactement 12 JMX LegacyServices et 20 JMX WebServices. Les trois cas discriminants sont `LegacyServices/012-FrenchTaxesRules_Run.jmx`, `WebServices/006-Validation_SetDocumentErrorReason.jmx` et `WebServices/020-Purge_Execute.jmx`. Les hashes du snapshot source sont respectivement `B8F971F75B143F38A26AEB3CA83995E73A6BA17D7CE0FD33B5DAEEBA40BA754A`, `F3396523DA22A60FBF15415C1A6870301F423393304177A2730664D113F8F2C9` et `FF5EF18C1DE9CF157AD551A2B366CBE4019B48DACD68E7D2ECEA455827E78D22`.

**FACT** — les journaux de déploiement historiques confirment les installations MSI Cur/Fix avec statut `0`; ils ne prouvent pas la restauration du backup, les valeurs finales des variables, ni la consommation effective des binaires.

**FACT** — `ExternalsToRestore_V22.xml` déclare Common `22.0.2.300`, Core `22.0.0.1012` et Identity `22.0.5.182`, alors que `downloadedPackages.json`/les journaux d'installation Fix identifient Core `22.0.0.1011`. Cette divergence est une contrainte de compatibilité à vérifier ; elle ne prouve ni une erreur de restauration ni la cause des refus.

## Compatibilité de la proposition packaging

La proposition minimale reste limitée à Core `22.0.0.2068`, Common `22.0.3.311`, Identity `22.0.6.117`, en conservant FrenchTaxesRules `22.0.6.478` et AuthenticationServer `2.0.0.368`. Le manifeste JFrog 22.0.23 référence en revanche FrenchTaxesRules `22.0.6.379` et AuthenticationServer `1.0.1.429 OnPremOnly`; compatibilité complète **UNKNOWN**.

## Clarification revalidation JFrog

Le dossier `evidence/2026-09-07-jfrog-v22-packaging-revalidation/` contient exactement un fichier créé lors de la collecte : `README.md` (4131 octets au contrôle). Aucun ZIP, manifeste brut, JSON de métadonnées, `MANIFEST.csv` ou `SHA256SUMS.txt` n'y est conservé. Les SHA-256 des trois ZIP sont uniquement transcrits dans ce README : Core `1AC0BF6084F0AB62B38C2DC15BC72A7D3B57EEC6661FCF03F056322611144B7C`, Common `540E96AE56B912F1F27DD17865B76E342D72024B46CE5994F5CF9B7FC7A590D2`, Identity `7F4426E5DB4DD94B040BD39B8EB2A3485FD9387BCEC667DD9663A35E840A96CF`. Aucun fichier de hash séparé n'a été créé.
