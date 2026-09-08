# Finding 013 — InventoryTracking migration 4434070 : XmlDiff non résolu

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`, lecture seule.
- Pipeline : définition `2072`, `InventoryTracking CI`.
- Build : `4434070` (`7.73`), branche source `refs/heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master`.
- Commit migration : `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.
- Preuve primaire : `../evidence/azure-devops-inventorytracking-2026-09-07-worker2-round2/README.md`, `MANIFEST.csv`, `SHA256SUMS.txt`.

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

Relire les PR de la branche de migration et les relations du WI via la collecte live dédiée avant toute conclusion. Ne pas lancer de pipeline dans ce lot. Les campagnes JMeter, la validation du correctif, la PR de migration et le tableau Excel/notification restent non prouvés.

## Complément du 2026-09-07 — deux handoffs manuels externes, runs ADO réels revendiqués (non revérifiés)

**Non revérifié dans ce processus.** Deux documents manuels reçus hors `brain-worker` le même jour sont rangés sous [`evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/`](../evidence/local-2026-09-07-inventorytracking-xmldiff-ado-validation-handoff/README.md). Ils rapportent, sans preuve jointe revérifiée ici :

- **FACT rapporté** — un correctif appliqué sur une branche distante `validation/WI-2222897-inventorytracking-xmldiff` (commit `ef3d87034d38b88aca04c824061b140e2a29252c`), ajoutant explicitement `Cegid.Retail.XmlDiff 1.0.0` et `XMLDiffPatch 1.0.8.28` au `.csproj`/`packages.config` de `Services.Tests` — cohérent avec le correctif candidat déjà proposé ci-dessus.
- **FACT rapporté** — un run réel `Build ID 4440774` (`pipelineDevMode=false`) sur ce commit serait `SUCCEEDED`, avec `Build V26` passant et `TI JMeter V26` skipped (comportement attendu hors `master`/`releases/*`).
- **FACT rapporté, point supplémentaire du second document** — un second run réel `Build ID 4440884` (`pipelineDevMode=true`) aurait exécuté réellement les campagnes JMeter Cur/Fix (`partiallySucceeded`, `succeededWithIssues`) : 1991 tests publiés de chaque côté, 339 échecs Cur, 340 échecs Fix, avec un **delta net d'un seul test** — `002-Device:Reassign - TC 122` (Run `6185924` Fix `Failed` sur `B-XQuery:Internal Server Error` ; Run `6185925` Cur `Passed`). Le mapping entre ce testcase publié et le sample JMeter brut n'aurait pas été retrouvé dans les `WebServices_TestLogs`/`RunLogs` déjà téléchargés ; cause du HTTP 500 et reproductibilité restent `UNKNOWN` selon la source elle-même.

**Point d'attention non résolu** — ces deux runs vont au-delà de la consigne consignée dans `HANDOFF.md` (« créer aucun pipeline ; effectuer uniquement un checkout local isolé »), le second run ajoutant en plus des effets externes (image Docker, publication `ArtifactoryCloud staging`) non couverts par un simple build. Avant de citer `4440774`/`4440884`/`ef3d8703`/le delta `TC 122` comme `FACT` canonique dans ce finding : vérifier indépendamment via `az`/API REST l'existence et le statut réels de ces builds et de cette branche, l'absence de merge vers une branche partagée, et concilier explicitement l'écart avec la consigne de prudence antérieure.

**Verdict arbitré** — la cause et le correctif candidat de ce finding restent inchangés et seraient confirmés en substance par cette source. Le statut `corrigé et validé` du blocage XmlDiff, ainsi que l'écart fonctionnel `TC 122`, ne doivent pas remplacer l'`UNKNOWN` de ce finding (mécanisme exact restore, campagnes JMeter, PR de migration) sans revérification indépendante.
