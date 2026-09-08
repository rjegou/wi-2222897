# Finding 013 — InventoryTracking migration 4434070 : XmlDiff non résolu

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`, lecture seule.
- Pipeline : définition `2072`, `InventoryTracking CI`.
- Build : `4434070` (`7.73`), branche source `refs/heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master`.
- Commit migration : `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.
- Preuves : cause initiale dans `../evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md`; validation AzDO dans `../evidence/2026-09-08-inventorytracking-azdo-access-diagnosis-round2/README.md`, `MANIFEST.csv` et `SHA256SUMS.txt`; contre-vérification d'accès dans `../evidence/2026-09-08-inventorytracking-azdo-independent/README.md`.

## Conclusion bornée

**FACT** — le build `4434070` n'est pas un run direct de `refs/heads/master`. Il provient de la branche de migration `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, au commit `4de185bb...`; les derniers builds de cette branche (`4434070` et `4432064`) échouent au même commit.

**FACT** — l'image/ACR et `Ensure_Docker_Image_Up_To_Date` réussissent en amont. `Build V26` échoue dans `VSBuild` log 51 : `MSB3245` sur `Cegid.Retail.XmlDiff`, puis quatre `CS0103` sur `XmlDiff` dans `GlobalSettingsDtoConvertersUnitTest.cs`. Les stages `TI JMeter V26`, Cur et Fix sont skipped.

**FACT** — le projet `Cegid.Retail.InventoryTracking.Services.Tests.csproj` conserve une référence `HintPath=..\Assemblies\Y2Core\Cegid.Retail.XmlDiff.dll`, tandis que `Services.Tests/packages.config` ne restaure ni `Cegid.Retail.XmlDiff` ni `XMLDiffPatch`. Le commit de migration supprime `WebServices.Tests` et son `packages.config`, qui contenait ces deux packages. Le master `20aa528...` conserve ce projet; son build `4435986` montre une résolution via `Sln\packages\Cegid.Retail.XmlDiff.1.0.0` pour WebServices.Tests et `Assemblies\Bin\Cegid.Retail.XmlDiff.dll` pour Services.Tests.

**INFERENCE** — la cause immédiate est l'acquisition/résolution manquante de `Cegid.Retail.XmlDiff` après le désenregistrement de l'ancien projet WebServices.Tests. La suppression du projet n'est pas démontrée comme fautive en soi; c'est la dépendance encore requise par Services.Tests qui n'est plus fournie dans le chemin attendu.

**UNKNOWN** — le mécanisme exact de suppression/non-restauration au run (package Core réellement contenu, restore effectif, templates externes et versions consommées) n'est pas entièrement prouvé. Le build `4435986` réussi est l'ancien pipeline master : son YAML ne déclare pas `TI_Jmeter_V26`; il ne valide donc pas la migration JMeter.

## Correctif candidat et test discriminant

Le correctif minimal candidat est de restaurer explicitement `Cegid.Retail.XmlDiff` `1.0.0` et sa dépendance `XMLDiffPatch` dans le projet conservant la référence, ou de remplacer la référence par l'emplacement/package supporté. Le choix reste à valider par le propriétaire et la compatibilité d'assembly.

Test local autorisé : checkout isolé du commit `4de185bb...`, changement minimal de déclaration, `dotNet-build: Build solution **\*.sln`, puis vérification de la résolution et de la disparition des quatre `CS0103`. Aucun code, package, pipeline, branche ou dépôt n'a été modifié dans cette collecte.

## Suite PBI

La correction candidate a maintenant été exercée par les builds `4440774` et `4440884` ci-dessous. L'état fonctionnel reste non validé : le delta `TC 122` est observé dans les résultats publiés, mais sa cause et sa reproductibilité restent `UNKNOWN`. La PR source n'a pas été retrouvée dans la requête datée; cela ne généralise pas à d'autres branches ou PR.

## Complément du 2026-09-08 — validation AzDO des runs InventoryTracking

**FACT** — la collecte REST Python/OpenSSL authentifiée relit la définition `2072`, les builds, timelines, artefacts et résultats individuels. Le build `4440774` (`7.75`) est `completed/succeeded` au commit `ef3d87034d38b88aca04c824061b140e2a29252c` sur `refs/heads/validation/WI-2222897-inventorytracking-xmldiff`; Build réussit et JMeter est skipped.

**FACT** — le build `4440884` (`7.76`) est `completed/partiallySucceeded` au même commit. Build réussit; Cur et Fix sont exécutés avec `1991` résultats chacun : Cur `1652 passed / 339 failed`, Fix `1651 passed / 340 failed`. Les artefacts Cur/Fix et la publication Artifactory staging sont présents dans l'index du build.

**FACT** — la jointure exacte des résultats donne `1991` clés communes, `1651 Pass/Pass`, `339 Fail/Fail`, un seul `Fail/Pass` et aucun `Pass/Fail`. Le seul delta est `002-Device:Reassign - TC 122` (référence `1127761`) : Fix échoue sur `B-XQuery:Internal Server Error`, Cur passe. Les autres différences de texte d'erreur restent des `Failed/Failed`.

**FACT** — la relecture de la ref exacte renvoie zéro résultat au moment de la collecte et la recherche de PR dont la source est cette branche renvoie zéro résultat. Cette absence est bornée à la requête datée et ne prouve ni suppression par un worker ni absence de toute PR historique.

**UNKNOWN** — cause applicative/reproductibilité de `TC 122`, mapping vers le sample JMeter brut, contenu exact des logs/artefacts au-delà des résultats publiés, et état fonctionnel métier. `4440884` ne constitue donc pas une validation fonctionnelle globale.

**FACT d'accès** — Python/OpenSSL fonctionne jusqu'à AzDO; Schannel échoue avec `SEC_E_NO_CREDENTIALS`. L'hypothèse d'un PAT expiré/invalide n'est pas établie. Les disparitions de clone ou verrous ne sont attribués à aucun worker sans preuve directe.

**FACT d'autorisation et prudence** — l'autorisation actuelle couvre les corrections, push, runs et la PR appropriée. La prochaine exécution doit toutefois maîtriser les effets partagés : `Ensure_Docker_Image_Up_To_Date`, publication staging, compteur de version et toute ressource ACR/Artifactory. Aucun nouveau run n'est lancé dans cette mise à jour documentaire.

## Complément du 2026-09-07 — deux handoffs manuels externes, runs ADO réels revendiqués (supersédé)

Deux documents manuels reçus hors processus sont conservés sous [`evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`](../evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/README.md). Leurs affirmations de runs sont désormais supersédées par la collecte datée du 2026-09-08 ci-dessus; ils restent utiles pour la provenance du correctif candidat.

- **FACT rapporté** — un correctif appliqué sur une branche distante `validation/WI-2222897-inventorytracking-xmldiff` (commit `ef3d87034d38b88aca04c824061b140e2a29252c`), ajoutant explicitement `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28` au `.csproj`/`packages.config` de `Services.Tests` — cohérent avec le correctif candidat déjà proposé ci-dessus.
