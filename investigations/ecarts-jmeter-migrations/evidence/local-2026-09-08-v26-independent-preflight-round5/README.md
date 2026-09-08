# FrenchTaxesRules V26 — vérification indépendante round 5

Collecte du 2026-09-08, lecture Azure DevOps et des preuves locales. Aucun
build Console, préflight distant, restauration SQL, métier, publication de
définition ou nettoyage partagé n'a été exécuté par cette collecte.

## Console 4444888 — résultat terminal

- **FACT** — build `4444888`, définition `2641`, branche
  `sandbox/frenchtaxesrules/console-api-artifact`, commit
  `202f8a6a22784786ed90d417f24626e0381bc07e`, est `completed/failed`.
- **FACT** — le téléchargement de l'artefact API a réussi, puis l'étape
  `Install exact API candidate from PipelineArtifact` a échoué sur :
  `Resolve-Path : Cannot find path 'D:\a\1\s\Cegid.Retail.AutoTest.Api.1.1.47-wi2222897-api-candidate.nupkg'`.
  Le dossier téléchargé était `D:\a\1\s\api-artifact`; l'étape cherchait le
  package à la racine du checkout. Aucun package Console final n'est donc
  prouvé par ce build.
- **FACT** — la timeline indique `Build=failed`, `Snyk Security Scan=succeeded`
  et `Promote=skipped`. Les étapes « Download secrets: cegid-codesigning » ont
  été observées dans la timeline ; aucun contenu secret n'a été lu ni archivé.

## Destinations et acquisition

- **FACT** — le template PlatformDeploy réel recherche dans le dépôt
  `retail-software-production`, motif
  `Y2.Tools.PlatformDeploy/PlatformDeploy.<version>.*`, télécharge vers
  `$(Agent.TempDirectory)/Y2.Tools.PlatformDeploy/`, extrait l'archive puis
  appelle `docker-pipeline-deploy-ps7.ps1`.
- **FACT** — la seule résolution/hachage PlatformDeploy disponible est
  historique et étrangère au run FrenchTaxesRules V26 : `5.0.86`, archive
  `PlatformDeploy.5.0.86.zip`, SHA-256
  `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295` ; le ZIP
  n'est pas présent localement et l'accès anonyme a répondu HTTP 401.
- **FACT** — le backup attendu par le template est
  `$(Build.SourcesDirectory)\Y2_Plugins_FrenchTaxesRules\Tests\Backups\AUTO_V26_00.bak`,
  restauré via `-LocalDBInContainer Backup`. Aucun fichier ni hash V26 n'est
  disponible dans les preuves locales consultées.
- **UNKNOWN** — accessibilité authentifiée actuelle de JFrog, version
  PlatformDeploy V26, backup réellement présent dans la branche/source
  consommée, agent Windows compatible, digest effectivement tiré, mounts et
  hôtes SQL/IIS dédiés.

## Décision de queue

Un préflight autonome strict devrait rester sans restauration et vérifier dans
le job : digest exact, marqueur de scope/run, `Agent.ContainerMapping`, mounts
autorisés, hôtes dédiés, existence/hash du backup et JMX, puis cleanup limité à
son répertoire temporaire. Il ne peut pas être publié ou lancé honnêtement avec
les variables V26 actuellement UNKNOWN. La prochaine entrée nécessaire est une
preuve de Worker 1 donnant le chemin/hash du package Console corrigé et la
source exacte des JMX ; ensuite seulement résoudre le backup/PlatformDeploy et
faire une queue contrôlée.
