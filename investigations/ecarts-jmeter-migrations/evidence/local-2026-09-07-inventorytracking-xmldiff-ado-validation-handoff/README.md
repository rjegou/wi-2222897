# Handoff manuel — correctif XmlDiff InventoryTracking et run Azure DevOps réel revendiqué

## Provenance

Document reçu hors du processus `brain-worker` (fichier déposé dans `Downloads`, daté 2026-09-07) et rangé ici tel que reçu, sans modification : [inventorytracking_xmldiff_investigation_2026-09-07.md](inventorytracking_xmldiff_investigation_2026-09-07.md).

**Ce fichier n'a pas été réexécuté ni revérifié lors de ce rangement.** Ses affirmations sont rapportées comme telles par la source, pas confirmées de façon indépendante ici.

## Contenu

- Reprend et confirme la cause déjà canonique dans [finding 013](../../findings/013-inventorytracking-xmlDiff-migration-build-4434070.md) : la suppression de `WebServices.Tests`/`packages.config` par la migration prive `Services.Tests` de la restauration de `Cegid.Retail.XmlDiff` et `XMLDiffPatch`.
- Documente un correctif appliqué dans un worktree (`InventoryTracking_Migration_AutoTest_Jmeter_On_master_worker2`) sur `Services.Tests.csproj` et son `packages.config`, avec restauration NuGet locale réussie et `ResolveAssemblyReferences` réussi — ceci recoupe l'évidence déjà indexée dans [`2026-09-07-inventorytracking-local-xmldiff-validation/`](../2026-09-07-inventorytracking-local-xmldiff-validation/README.md).
- **Point nouveau et sensible** : le document revendique la création d'une branche distante `validation/WI-2222897-inventorytracking-xmldiff` (base `4de185bb...`, commit du correctif `ef3d87034d38b88aca04c824061b140e2a29252c`) et le lancement réel d'un run Azure DevOps sur la définition `2072` (`InventoryTracking CI`) avec `pipelineDevMode=false` — **build ID 4440774, build number 7.75, résultat SUCCEEDED**, `Build V26` passant, `TI JMeter V26` et `Promote` skipped (comportement attendu hors branche `master`/`releases/*`).
- Note methodologique retenue : `pipelineDevMode=true` active aussi JMeter, `Ensure_Docker_Image_Up_To_Date` et la publication staging ArtifactoryCloud (pas seulement les tests) ; `Promote` reste conditionné à `master`/`releases/*`.

## Point d'attention — écart avec la consigne de prudence déjà consignée

La dernière entrée `HANDOFF.md` sur ce sujet (« Revalidation primaire InventoryTracking migration (Worker 2 round2) ») concluait explicitement : *« créer aucun pipeline ; effectuer uniquement un checkout local isolé du commit de migration, tester la restauration/référence minimale, puis demander la collecte WI/PR avant toute conclusion de PR »*. Ce document revendique pourtant la création d'une branche distante et le lancement effectif d'un pipeline réel (build `4440774`).

**Ce rangement n'a ni confirmé ni infirmé cette exécution réelle** (accès Azure DevOps non revérifié dans cette passe). Avant de considérer `4440774`/`ef3d8703` comme une preuve canonique :

- vérifier via `az`/API REST que le build `4440774` existe réellement sur la définition `2072`, avec le statut, le commit et la timeline revendiqués ;
- vérifier que la branche `validation/WI-2222897-inventorytracking-xmldiff` existe et pointe sur `ef3d8703` ;
- confirmer qu'aucun merge/PR n'a été fait vers une branche partagée, comme l'affirme la section 8 du document ;
- concilier explicitement cet écart avec la consigne « créer aucun pipeline » avant de le traiter comme une avancée validée.

## Relation avec l'évidence et les conclusions déjà canoniques

- [`findings/013`](../../findings/013-inventorytracking-xmlDiff-migration-build-4434070.md) : la cause et le correctif candidat qu'il propose correspondent au correctif décrit ici. Mettre à jour cette fiche seulement après la vérification ci-dessus.
- [`HANDOFF.md`](../../HANDOFF.md) : un pointeur a été ajouté pour rendre ce document découvrable, sans lever les `UNKNOWN` existants ni confirmer le run ADO revendiqué.
- [`evidence/2026-09-07-inventorytracking-local-xmldiff-validation/`](../2026-09-07-inventorytracking-local-xmldiff-validation/README.md) : couvre uniquement la validation locale (NuGet restore + ResolveAssemblyReferences), déjà canonique. Ce nouveau dossier est celui qui porte la revendication de run Azure DevOps réel.

## Second document reçu le même jour (17:15), même sujet : [HANDOFF_WI-2222897_2026-09-07.md](HANDOFF_WI-2222897_2026-09-07.md)

Reçu plus tard dans `Downloads`, rangé ici tel que reçu, sans modification. **Non revérifié.** Il reprend intégralement le contenu ci-dessus (même correctif, même branche `validation/WI-2222897-inventorytracking-xmldiff`, même commit `ef3d8703`, même build `4440774`/`SUCCEEDED`) et ajoute un contenu nouveau et significatif :

- **Escalade du point sensible déjà signalé ci-dessus** : au-delà du build `4440774` (`pipelineDevMode=false`, pas de JMeter), ce document revendique un **second run réel**, `Build ID 4440884`, avec `pipelineDevMode=true` — ce qui, selon le document lui-même, active `Ensure_Docker_Image_Up_To_Date`, la publication vers `ArtifactoryCloud staging`, et l'exécution réelle des campagnes JMeter Cur/Fix (`succeededWithIssues`). C'est un pas supplémentaire au-delà de la consigne « créer aucun pipeline ; effectuer uniquement un checkout local isolé » déjà en écart pour le premier run : celui-ci ajoute des effets externes (image Docker, publication staging) non couverts par le premier signalement.
- **Résultat métier nouveau** : sur ce second run, Fix et Cur publient chacun 1991 tests, avec un delta net d'exactement **un seul test** : `002-Device:Reassign - TC 122` (Fix `Failed` sur `B-XQuery:Internal Server Error`, Cur `Passed`). C'est la première fois qu'un écart JMeter réel Cur/Fix isolé et minimal est rapporté pour InventoryTracking depuis la correction XmlDiff.
- **Investigation du mapping TC122 → sample JMeter brut restée ouverte** : aucun fichier `TC 122` trouvé dans les `WebServices_TestLogs` extraits (Cur et Fix), ni de trace `TC 122` / `TestCaseCode=122` dans les `RunLogs` ; le document recommande d'inspecter les tâches de conversion JTL→JUnit et de regroupement par `TestCaseCode` avant de rechercher la cause applicative du HTTP 500.
- **Observation de fond sur le script de migration** : `step_x_06_deref_avant_PR.ps1` supprimerait des projets de test et des dépendances de `.nuspec` sans transférer systématiquement les dépendances encore requises par les projets conservés — dépassant le cas ponctuel InventoryTracking XmlDiff.
- Confirme explicitement qu'InventoryTracking (339 fails Cur / 340 fails Fix) ne correspond pas au pattern de l'hypothèse de Ludo (0 fail Cur / fails Fix) : signal pertinent ici est le delta d'un seul test, pas le volume.

### Avant de traiter ce second document comme canonique

- Vérifier indépendamment via `az`/API REST l'existence et le statut réels de `4440884` (en plus de `4440774` déjà signalé), sa timeline, et le fait qu'aucune image Docker ni artefact n'ait été publié au-delà d'un usage strictement local à ce run.
- Concilier explicitement ce second run avec la consigne « créer aucun pipeline » avant de le citer comme avancée validée dans `HANDOFF.md` ou `findings/013`.
- Revérifier indépendamment le comptage 1991/339/340 et l'unicité du delta TC122 (Test Runs `6185924`/`6185925`) avant de les citer comme `FACT`.
- Ne pas relancer de nouveau run tant que le mapping TC122 → sample brut n'est pas résolu par lecture des artefacts déjà téléchargés, conformément à la propre recommandation du document (« ne pas multiplier les runs sans bénéfice probatoire »).
