# Trois synthèses techniques de pause — FrenchTaxesRules V26, InventoryTracking, Clienteling 14264

## Provenance

- Date de rangement : 2026-09-08, dépôt documentaire `C:\clones\wi-2222897`.
- Origine : trois fichiers Markdown déposés dans `Downloads` de l'utilisateur, produits hors du
  processus `brain-worker` et hors de la session qui les range. Rangés ici **tels que reçus, sans
  modification**.
- Méthode de rangement : copie octet à octet, puis empreinte SHA-256.
- Fraîcheur : les trois documents se datent eux-mêmes du 2026-09-08 et se présentent comme des points
  de pause.

| Fichier | SHA-256 | Taille |
|---|---|---:|
| [WI-2222897_FrenchTaxesRules_V26_synthese_technique_2026-09-08.md](WI-2222897_FrenchTaxesRules_V26_synthese_technique_2026-09-08.md) | `FEC62B959205B57781D1DC084DFE97ADEFE25A6F38179D95CFE9A11EBC38895E` | 17 435 o |
| [WI-2222897_InventoryTracking_synthese-technique_2026-09-08.md](WI-2222897_InventoryTracking_synthese-technique_2026-09-08.md) | `23E2F1CD0C08CD393DC9F435F848B77D219FC3633762DF5669F04521CC20D881` | 15 667 o |
| [WI-2222897_Clienteling_JMeter_synthese_technique_2026-09-08.md](WI-2222897_Clienteling_JMeter_synthese_technique_2026-09-08.md) | `E461E2283841E98C712CF5ACA47D50370E0EA9572D0A18C4020412603C6C7962` | 11 563 o |

**Aucune affirmation de ces documents n'a été réexécutée ni revérifiée dans ce rangement.** Elles sont
rapportées comme telles par leur source. Les identifiants de build, de run, de push et de commit
qu'elles citent n'existaient dans aucun document canonique de ce dépôt avant ce rangement : ils ne
sont donc soutenus, à ce stade, que par ces trois fichiers.

## Ce que chaque document apporte de nouveau

### FrenchTaxesRules V26 — préflight réussi et branche de validation poussée

- Le préflight runtime V26 aurait été **rejoué et réussi** : définition `14265`, branche
  `sandbox/frenchtaxesrules/v26-preflight-20260908`, commit `27644f216c9a056fa02a34a34c23e91687b1a5df`,
  build `4446410` `completed/succeeded`, `WI2222897_V26_PREFLIGHT passed=true`, digest
  `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`, `mounts=0`,
  `dangerousMounts=0`, `hostPortBindings=0`, `forbiddenNetworks=0`,
  `containerPresentAfterRemove=False`. Ceci **supersède l'échec par timeout du build `4445476`** déjà
  consigné dans [`local-2026-09-08-frenchtaxesrules-v26-preflight-round8/`](../local-2026-09-08-frenchtaxesrules-v26-preflight-round8/README.md).
- Le document argumente la preuve du `docker start -a` par **l'ordre d'exécution du script** relu
  (start, puis écriture de `container-os.json`, puis `passed=true`), et non par une ligne de log
  directe : c'est une `INFERENCE`, correctement présentée comme telle par la source.
- Une **branche de validation** aurait été créée puis écrite :
  `refs/heads/validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908`, base
  `f80bc731571b2b5ed8a67da171b288873de428a6` (HEAD de la branche de migration V26), push `5136500`,
  nouveau commit `c9a7c6feb76d8505f16aa22ef4f3aac5281d9f24`, `18` JMX corrigés remplacés, `1` déjà
  identique, `0` manquant, `0` inattendu.
- Le mapping des 19 JMX a été fait **par nom fonctionnel après suppression du préfixe numérique**, les
  préfixes différant entre le jeu généré et la branche (`001-Export_Run.jmx` contre
  `010-Export_Run.jmx`).
- Le jeu canonique des 19 JMX du build `4445025` est confirmé identique au jeu local `.work\jfull\Tests`
  (19 de chaque côté, 0 différence), ce qui recoupe [`build-4445025-jmx-generation/`](../build-4445025-jmx-generation/README.md).

### InventoryTracking — la campagne `002-Device:Reassign` ne se charge plus

- Run `4445575`, définition `2072`, branche `validation/WI-2222897-inventorytracking-isolated-20260908`,
  commit `95aede774dcc45ba7e69abe163e6be410ae0c496`, `partiallySucceeded` : Build, préflight Docker,
  JMeter Cur et Fix **réellement exécutés**. C'est le premier run rapporté qui franchit le transport
  local jusqu'aux campagnes.
- Cur (`6188849`) et Fix (`6188843`) publient `1905` tests, `1591` passés, `314` non passés, et les
  `314` sont **exactement les mêmes** des deux côtés (`0` seulement Cur, `0` seulement Fix).
- Mais la baseline `4440884` publiait `1991` tests (`6185925` Cur, `6185924` Fix). Les `86` tests
  absents appartiennent **tous** au plan `002-Device:Reassign`, dont `TC122`, seul delta Cur/Fix connu.
- Cause rapportée : JMeter 5.6.3 lance bien le plan, puis échoue à le charger —
  `java.lang.IllegalArgumentException: Problem loading XML`, causé par
  `ClassCastException: org.apache.jmeter.protocol.http.control.HeaderManager cannot be cast to org.apache.jorphan.collections.HashTree`,
  chemin `/jmeterTestPlan/hashTree/hashTree/hashTree[19]/hashTree[6]/HeaderManager`, ligne `8522`. Le
  runner continue avec le plan suivant, donc la tâche d'exécution reste verte.
- Le `.jmx` diffère réellement entre les deux commits, établi par téléchargement des **octets** :
  `ef3d8703…` = `4 097 371` o / `39E6036031D1AD30304405D3E08DA159DA89B94F0E1ADC7B4BB6A5C14CFBE59E`,
  `95aede77…` = `4 098 601` o / `A59C06A49C64306F674143D4C4FAED73C234CD15047C0913BA47944C1CE313BA`.
  Le document **corrige explicitement** sa propre conclusion intermédiaire « Same JMX = True », issue
  du champ JSON `content` de l'API Git, jugé non fiable pour un fichier de plusieurs Mo.
- Le transport local `PipelineArtifact + manifest` remplace le staging Artifactory ; il lie le package
  à `sourceBuildId`, `artifactName`, nom, version et hash attendu, et ses huit tests locaux passent.
  Le fallback embarqué sous `/.pipeline/inventorytracking-transport/` est présenté par la source
  elle-même comme un **mécanisme d'investigation à ne pas reprendre tel quel dans une PR finale**.
- Un push PlatformDeploy est rapporté sur `sandbox/WI-2222897-inventorytracking-local-transport` :
  commit `a490cd537a1671030141248e7b9a66d31a456485`, push `5135960`, fichiers distants
  re-téléchargés et SHA-256 vérifiés.

### Clienteling 14264 — agent Docker résolu, backup V26 disparu de l'arbre Git

- Le stage `TargetDiagnostic` de la définition `14264` aurait été basculé du pool privé
  `Private VS2019` vers `vmImage: windows-2025`, commit de branche isolée
  `c20755d802d1fb56a93289dd19b92622eb7f2c54`, run `4446303` `succeeded` avec
  `Microsoft Windows NT 10.0.26100.0` et Docker `29.7.2`, autres stages volontairement `skipped`
  (`diagnosticOnly=true`). Conclusion de la source : ne plus investiguer les agents privés A/B.
- Les valeurs runtime PlatformDeploy V26 sont résolues **depuis les logs du build historique
  `4432554`** (commit `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a`), qui avait réellement exécuté Cur et
  Fix : `PlatformDeploy 5.0.86`, archive `PlatformDeploy.5.0.86.zip`, extraction
  `$(Agent.TempDirectory)\Deploy`, script `docker-pipeline-deploy.ps1`, configurations
  `Docker\data\v26-Cur.cy2px` et `v26-Fix.cy2px`, mode `-LocalDBInContainer "Backup"`.
- **Découverte bloquante** : le backup `Tests/Backups/AUTO_V26_00.bak`, présent dans le checkout de
  `4432554`, est **absent de l'arbre Git actuel** de `master` comme de la branche isolée
  (`Tests/Backups : NOT FOUND`). Son objet Git LFS historique est
  `8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`, `156 663 808` octets ; la règle
  `.gitattributes` historique était `**/Tests/Backups/*.bak filter=lfs diff=lfs merge=lfs -text`, et
  la branche isolée n'a ni ce `.gitattributes` ni `checkout: self` / `lfs: true`.
- Les quatre wrappers de `replay-prep/2026-09-08-clienteling-isolated/scripts/` sont confirmés parsés
  sans erreur et déclarés à ne pas réécrire sans défaut concret : cohérent avec les rounds 10 et 11
  déjà consignés.

## Écarts et points à réconcilier avant de citer ces documents comme `FACT`

1. **Deux backups différents portent le même nom de fichier.** `AUTO_V26_00.bak` vaut
   `23bfb0b670918fbe5f63ceeff36f66ef1855b46fd82c29bda9d34dfa6b7fc25f` / `150 765 568` o dans
   `Y2_Plugins_FrenchTaxesRules` (déjà consigné dans [`local-2026-09-08-frenchtaxesrules-round7/`](../local-2026-09-08-frenchtaxesrules-round7/README.md)),
   et `8B95C2BA…` / `156 663 808` o dans `Y2_Plugins_Clienteling` selon la présente source. Ne jamais
   fusionner ces deux valeurs ni les citer sans nommer le dépôt d'origine.
2. **La clôture documentaire Clienteling 14264 a été dépassée.** `STATUS.md` et `HANDOFF.md`
   enregistraient « aucun nouveau run, push, provisionnement » et le commit distant vérifié
   `f8858ad73df9c9eca7e438e609b6effebb677a9b`. La source rapporte un commit postérieur `c20755d802d1…`
   et un run `4446303` : la phase a donc été reprise après sa clôture. Le fait est consigné tel quel ;
   il n'est pas attribué à une session identifiée.
3. **Le conteneur résiduel du préflight `4445476` reste `UNKNOWN`.** Le cleanup vert de `4446410` porte
   sur son propre conteneur ; il ne prouve rien sur
   `wi2222897-frenchtaxesrules-v26-preflight-4445476`, dont la vérification/suppression reste l'action
   obligatoire déjà consignée.
4. **Aucun résultat métier corrigé n'existe encore.** Les trois documents le disent explicitement :
   aucun run `2054` sur `c9a7c6fe…`, aucun rejeu Clienteling Build → GenerateJmx → Cur/Fix, et le run
   InventoryTracking `4445575` a perdu une campagne entière. Préflight, génération et push de JMX ne
   sont pas des preuves de résultat.
5. **Périmètre d'écriture distante exercé.** Les écritures rapportées restent sur des branches
   `sandbox/*` et `validation/*` et sur des `PipelineArtifact`. Aucune publication de feed NuGet
   partagé, `Promote`, `Tag` ou `TestAutos` n'est revendiquée — la confirmation exigée par la
   [décision 5](../../../../decisions/README.md) reste donc requise avant toute publication partagée.

## Vérifications indépendantes à faire avant de lever un `UNKNOWN`

- Relire par `az`/REST l'existence, le commit exécuté et la timeline réelle de `4446410`, `4445575` et
  `4446303`, ainsi que les Test Runs `6188849` et `6188843`.
- Relire les refs `validation/WI-2222897-frenchtaxesrules-v26-corrected-jmeter-20260908` (HEAD attendu
  `c9a7c6fe…`), `sandbox/clienteling/wi2222897-isolated-replay` (`c20755d8…`) et
  `sandbox/WI-2222897-inventorytracking-local-transport` (`a490cd53…`).
- Confirmer que l'objet LFS Clienteling `8B95C2BA…` est encore téléchargeable côté Azure DevOps
  **avant** de choisir une stratégie de rétablissement du backup.
- Comparer les deux versions réelles de `002-Device_Reassign.jmx` autour de la ligne ~8522 et
  identifier le changement structurel, avant tout nouveau run InventoryTracking.

## Conclusions canoniques ouvertes par ce rangement

- [finding 015](../../findings/015-inventorytracking-002-device-reassign-jmx-load-4445575.md) — perte
  de couverture de `002-Device:Reassign` et cause de chargement JMX.
- [finding 016](../../findings/016-clienteling-v26-backup-lfs-absent.md) — backup V26 absent de l'arbre
  Git actuel et agent hébergé Docker-compatible.
- Lignes ajoutées à la [matrice de statut](../../cases/STATUS_MATRIX.md) pour le préflight V26
  `4446410`, la branche de validation FrenchTaxesRules et le diagnostic cible `4446303`.
