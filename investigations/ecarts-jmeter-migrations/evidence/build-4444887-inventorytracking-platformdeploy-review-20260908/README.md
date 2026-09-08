# Revue transport PlatformDeploy — build 4444887

**Date :** 2026-09-08 (Europe/Paris). **Méthode :** relecture de la preuve opérateur et des
analyses PlatformDeploy locales; aucune mutation distante et aucune modification des preuves
antérieures.

## Résultat du run

**FACT :** `4444887` (`7.83`) a exécuté `pipelineDevMode=true`, V26, Cur/Fix, WebServices. Build,
preflight Docker et initialisation des deux conteneurs réussissent; les pulls durent environ 9 min
06 s (Cur) et 11 min 13 s (Fix). Le diagnostic Docker précédent fondé sur `4444720` est donc
supersédé pour cette reprise.

**FACT :** `Ensure ACR`, publication Artifactory staging, Promote et Tag sont skipped. Dans Cur et
Fix, `Launch Y2 deployment` échoue avec PlatformDeploy `5.0.86` : les dépendances de production sont
téléchargées, puis le package `Y2.Plugin.InventoryTracking` version `26.0.7.83` est introuvable dans
`retail-software-staging`. Les étapes Prepare/Run JMeter, conversion JTL et extraction d'erreurs
sont skipped dans les deux jobs. Aucun résultat TC122 nouveau n'existe.

**FACT :** aucun fallback silencieux vers une version partagée n'est observé : l'absence du package
fait échouer le déploiement avec code 1. C'est un comportement fail-closed utile.

## Revue du contrat PlatformDeploy

**FACT local :** le template `task-deploy-in-containerized-job.v2.yml` résout une version
PlatformDeploy (fixe ou `lastV*`) depuis Artifactory, télécharge/extrait l'archive et transmet le
dossier de packages au script de déploiement. `install-packages.ps1` agrège les erreurs MSI dans
`$nbErr` et lève une exception si non nul. Le patch local `init-container.ps1` propage explicitement
le code retour de `deploy.ps1`; son harness local est validé, et son packaging privé conserve le hash
`2D713EE2149D20F5137BBAF5E459B4CAB4307883F4B93791C61D54C74D65CF1F`.

**FACT :** aucune preuve ne relie ce ZIP PlatformDeploy local au package effectivement consommé par
`4444887`; aucune preuve ne donne le hash du package plugin produit par Build ni le hash du fichier
transféré au conteneur. La résolution PlatformDeploy et le déploiement des dépendances sont donc
partiellement maîtrisés, mais le transport du plugin candidat ne l'est pas.

**FACT :** les conteneurs ont été initialisés, mais le run ne conserve pas de preuve de création,
montages, ports, dossier de packages, JMX consommé ou nettoyage final après déploiement; ces points
restent des postconditions du futur rejeu, pas des prérequis abstraits à inventer maintenant.

## Correction minimale recommandée

1. Conserver le package exact produit par Build comme Pipeline Artifact immuable et enregistrer son
   nom, sa version `26.0.7.83`, son SHA-256 et son chemin de téléchargement.
2. Dans chaque job Cur/Fix, télécharger cet artefact dans le dossier attendu par PlatformDeploy,
   ou fournir au template un resolver local explicite; refuser si le fichier/hash/version ne
   correspondent pas.
3. Ne pas compter sur `retail-software-staging` partagé, ne pas réactiver une publication générique,
   et ne pas introduire de fallback `lastV*` pour le plugin candidat.
4. Avant Prepare/Run JMeter, journaliser seulement les identités expurgées : package/hash, version
   PlatformDeploy/sha256, image/digest, fixtures/JMX/hash et cible dédiée. Après déploiement, vérifier
   code retour, logs MSI et health checks; les résultats tolérés par `continueOnTestFailure` ne valent
   pas succès de migration.

**Avis :** le patch PlatformDeploy de propagation de code retour est favorable sur son périmètre
local; il n'est ni la cause de `4444887`, ni une preuve qu'il a été consommé par ce run. Le risque
matériel restant est exclusivement le transport/identité du package plugin candidat. Une fois ce
transport vérifié et le déploiement abouti, aucun blocage supplémentaire n'est imposé par cette
revue; le rejeu Cur/Fix fournira alors les preuves runtime et TC122.

## PR migration

Titre recommandé : `InventoryTracking: migrate legacy WebServices tests to JMeter`.

Description améliorée : `Merge the complete InventoryTracking migration from 4de185bb and the
XmlDiff dependency fix ef3d8703. Exclude efba57ea diagnostic/preflight changes. Source review covers
the legacy-to-JMeter file migration; build 4440884 established a prior Cur/Fix comparison, while
4444887 established container initialization but stopped before JMeter because the Build package was
not transported to PlatformDeploy. Final PR acceptance requires a successful Cur/Fix replay with
package/version/hash, image/digest, JMX/data provenance, deployment logs and TC122 comparison.`

No PR was created in this review.
