# Finding 019 — Clienteling V26 : GenerateJmx progresse, TestCampaign requis, OutputFiles à embarquer

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`, dépôt `Y2_Plugins_Clienteling`.
- Cible du rejeu isolé : définition `14264`, branche
  `refs/heads/sandbox/clienteling/wi2222897-isolated-replay`.
- API build de référence : `4444962` ; Console build de référence : `4445025` (définition Console `2641`).
- Suite chronologique du [finding 016](016-clienteling-v26-backup-lfs-absent.md) (backup
  `AUTO_V26_00.bak` matérialisé, agent `windows-2025` Docker-compatible).
- Preuve : [rangement du 2026-09-09](../evidence/local-2026-09-09-clienteling-v26-generatejmx-testcampaign/README.md),
  fichier `2026-09-09-clienteling-v26-jmeter-synthese-technique.md`.
- **Niveau de preuve : rapporté, non revérifié.** Les push IDs, commits et build IDs ci-dessous ne sont
  soutenus que par ce document ; aucun n'a été relu par `az`/REST lors de cette intégration.

## Conclusion bornée

**FACT rapporté** — deux variables de pipeline manquantes bloquaient le rejeu isolé avant même
`GenerateJmx` : `Product.Version: '26.0.10.23'` (bloquait *Black Marble Version Assemblies*) et
`BuildPlatform: 'any cpu'` (bloquait VSBuild sur `solution configuration "Release|$(BuildPlatform)"
invalid`). Les deux valeurs viennent du pipeline Clienteling historique et ont été rétablies dans le
pipeline isolé, qui a ensuite atteint `GenerateJmx`.

**FACT rapporté — première faute causale dans GenerateJmx** — l'artefact `migration` du build
`4449477` ne contenait que le XML racine des plans (ex.
`IntegratedTests/AutoTest/Data/WebServices/TestPlans/Deployment_ResetFTSCustomer.xml`), sans les
ressources `InputFiles`/`ExpectedOutput` référencées. Cause : `ci/wi2222897/scripts/New-Wi2222897MigrationManifest.ps1`
ne faisait qu'un `Copy-Item -LiteralPath $source -Destination $dest -Force` du XML principal. Les
ressources existent pourtant intégralement côté dépôt pour les trois plans ciblés
(`Deployment_ResetFTSCustomer.xml` : 1 réf/0 manquante ; `Mobility_GetClientelingParameters.xml` : 11/0 ;
`Image_GetSerialNumberImage.xml` : 18/0) : le défaut est localisé au **staging de migration**, pas au
contenu du dépôt.

**FACT rapporté — correctif 1** — `New-Wi2222897MigrationManifest.ps1` et
`Invoke-Wi2222897JmxRegeneration.ps1` modifiés pour embarquer les ressources réellement référencées et
pré-positionner les `OutputFiles` attendus. Push `5138407` (`20aac8f5…` → `8cc14f2f8b83ea642a021e0e2ba8b872ab95c664`,
2 fichiers). Rejeu déclaré : build `4449640`.

**FACT rapporté — deuxième faute causale dans GenerateJmx** — le rejeu progresse plus loin puis échoue
sur `System.InvalidOperationException: <TestPlan xmlns='TestAutomation'> was not expected.` Cause : le
script appelait `Cegid.Retail.AutoTest.Console.exe --tstj=<TestPlan.xml>` alors que `--tstj` attend un
`TestCampaign`, pas un `TestPlan` brut. Un XML syntaxiquement valide n'implique donc pas qu'il respecte
le contrat métier attendu par la Console.

**FACT rapporté — contrat retrouvé** — la structure `TestCampaign` correcte (wrapper avec un ou
plusieurs `<TestPlanItem item="TestPlans\Plan.xml" />`, référençant une arborescence
`Campaign.xml` / `TestPlans\Plan.xml` / `InputFiles\` / `OutputFiles\`) a été retrouvée dans des preuves
locales d'une génération JMX déjà fonctionnelle, plutôt que reconstruite par hypothèse.

**FACT rapporté — correctif 2** — `Invoke-Wi2222897JmxRegeneration.ps1` modifié pour : créer une
fixture temporaire canonique, copier le `TestPlan` sous `TestPlans\` avec ses `InputFiles`/
`ExpectedOutput`, générer le wrapper `TestCampaign`, appeler la Console avec `--tstj=<campaign.xml>`,
vérifier qu'un seul JMX est produit, le recopier au chemin exact consommé par le stage JMeter, calculer
son SHA-256, puis supprimer la fixture. Push `5138712` (`8cc14f2f…` → `28f71268426de6f196c2f4672b526489819c6393`,
1 fichier).

**Limite explicite** — ce document ne revendique aucune exécution de `JMeter Cur`/`JMeter Fix` : l'état
déclaré s'arrête à la résolution rapportée des quatre blocages ci-dessus (`Product.Version`,
`BuildPlatform`, ressources `OutputFiles` manquantes, `TestPlan` au lieu de `TestCampaign`). Aucun des
trois JMX de la campagne isolée n'est prouvé généré par ce document ; le stage JMeter n'est pas prouvé
démarré.

**UNKNOWN** — résultat du rejeu attendu sur `28f71268…` (`GenerateJmx` passe réellement, les 3 JMX sont
produits, JMeter démarre, premiers résultats Cur/Fix) ; contenu exact et hash des JMX régénérés ;
confirmation indépendante des push IDs `5138407`/`5138712` et des builds `4449477`/`4449640`.

## Ordre de reprise

1. Relancer la définition `14264` sur `28f71268426de6f196c2f4672b526489819c6393` avec
   `apiBuildId=4444962`, `consoleBuildId=4445025`, `consoleDefinitionId=2641`.
2. Vérifier uniquement `GenerateJmx`, `JMeter Cur`, `JMeter Fix` — pas d'autre paramètre à changer en
   même temps.
3. Si `GenerateJmx` échoue encore, analyser le premier message d'erreur Console avant toute nouvelle
   modification (méthode déjà appliquée deux fois dans cette séquence, cf. section 10 du document
   source).
4. Ne pas confondre la définition `14264` (replay isolé WI-2222897) avec la `2065` (CI Clienteling
   normale) : un incident observé dans l'une ne doit pas être corrigé au titre de l'autre sans preuve
   de partage réel.
5. Comparer tout résultat Cur/Fix obtenu au baseline historique `4432554` (`2118` tests, `485` non
   passés de chaque côté, cf. [finding 006](006-clienteling-v26-build-4432554.md)) sans présenter ce
   baseline comme une preuve runtime nouvelle.
