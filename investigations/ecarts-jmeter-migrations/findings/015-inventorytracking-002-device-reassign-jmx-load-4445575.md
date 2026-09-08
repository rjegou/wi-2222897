# Finding 015 — InventoryTracking 4445575 : `002-Device:Reassign` lancé mais non chargé par JMeter

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`, définition `2072` `InventoryTracking CI`.
- Run : `4445575`, branche `refs/heads/validation/WI-2222897-inventorytracking-isolated-20260908`,
  commit `95aede774dcc45ba7e69abe163e6be410ae0c496`.
- Baseline de couverture : run `4440884`, commit `ef3d87034d38b88aca04c824061b140e2a29252c`
  (cf. [finding 013](013-inventorytracking-xmlDiff-migration-build-4434070.md)).
- Preuve : [synthèse technique de pause rangée le 2026-09-08](../evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/README.md),
  fichier `WI-2222897_InventoryTracking_synthese-technique_2026-09-08.md`.
- **Niveau de preuve : rapporté, non revérifié.** Aucun identifiant de ce finding n'a été relu par
  `az`/REST dans le rangement qui l'a produit. Les qualifications `FACT rapporté` ci-dessous nomment
  ce que la source affirme avoir mesuré, pas ce que ce dépôt a vérifié.

## Conclusion bornée

**FACT rapporté** — `4445575` est `partiallySucceeded` et traverse réellement
`Build → Docker preflight → JMeter Cur → JMeter Fix`. `Build`, `Build V26`,
`Docker preflight for isolated JMeter` et `Verify Docker daemon before JMeter` réussissent ;
`TI Jmeter V26-Cur`, `TI Jmeter V26-Fix` et `TI JMeter V26` sont `succeededWithIssues` ; `Promote` est
`skipped`. Le transport local par `PipelineArtifact + manifest` est donc suffisant pour exécuter les
campagnes : l'obstacle de transport du run `4444887` est levé pour ce parcours.

**FACT rapporté** — le `succeededWithIssues` provient uniquement des tâches `PublishTestResults`
(« There are one or more test failures detected in result files »). `Prepare Jmeter Campaign Run` et
`Run Jmeter Tests Campaign` réussissent des deux côtés. Ce n'est ni une panne Azure DevOps ni un échec
de lancement.

**FACT rapporté** — Cur (`6188849`) et Fix (`6188843`) publient chacun `1905` tests, `1591` passés,
`314` non passés/`unanalyzed`. La comparaison par **identité de test** donne `314` échecs communs,
`0` seulement Cur et `0` seulement Fix.

**FACT rapporté** — la baseline `4440884` publiait `1991` tests (`6185925` Cur : `1652` passés /
`339` non passés ; `6185924` Fix : `1651` / `340`). L'écart de couverture est de `1991 - 1905 = 86`
tests, et la comparaison nominative Cur↔Cur donne `86` manquants et `0` ajoutés.

**FACT rapporté** — les `86` tests absents appartiennent **tous** au plan `002-Device:Reassign`, dont
`TC122`, seul delta Cur/Fix connu de la baseline.

**FACT rapporté** — la cause n'est ni une suppression du fichier, ni un défaut de sélection, ni le
`Prepare`. Le `.jmx` est présent à `/Tests/WebServices/002-Device_Reassign.jmx`, le runner journalise
`Launch test Plan '002-Device_Reassign'` et exécute `jmeter.bat -n -t …`, mais JMeter 5.6.3 échoue
avant l'exécution :

```text
java.lang.IllegalArgumentException: Problem loading XML
  ClassCastException: org.apache.jmeter.protocol.http.control.HeaderManager
    cannot be cast to org.apache.jorphan.collections.HashTree
  /jmeterTestPlan/hashTree/hashTree/hashTree[19]/hashTree[6]/HeaderManager
  ligne 8522
```

Le runner enchaîne ensuite sur `003-Device_Connect`, ce qui laisse la tâche d'exécution verte alors
que la campagne n'a produit aucun résultat.

**FACT rapporté** — les deux versions du plan diffèrent réellement, établi par téléchargement des
octets et non par un champ d'API :

| Commit | Taille | SHA-256 |
|---|---:|---|
| `ef3d87034d38b88aca04c824061b140e2a29252c` | `4 097 371` o | `39E6036031D1AD30304405D3E08DA159DA89B94F0E1ADC7B4BB6A5C14CFBE59E` |
| `95aede774dcc45ba7e69abe163e6be410ae0c496` | `4 098 601` o | `A59C06A49C64306F674143D4C4FAED73C234CD15047C0913BA47944C1CE313BA` |

Écart de `1 230` octets. La source **corrige explicitement** sa propre conclusion intermédiaire
`Same JMX = True`, obtenue depuis le champ JSON `content` de l'API Git, non fiable pour un fichier de
plusieurs mégaoctets.

**FACT rapporté** — les deux runs ont tourné sur des workers différents (`Azure Pipelines 2` contre
`Azure Pipelines 18`) mais sur la même image `windows-2025` version `20260830.247.1`. Un changement
d'image agent est donc raisonnablement écarté.

**INFERENCE** — le message `HeaderManager cannot be cast to HashTree` est typique d'une rupture de
l'alternance attendue entre un élément JMeter et son `<hashTree>` associé. La modification du plan
entre `ef3d8703…` et `95aede77…` est le suspect prioritaire, avant toute hypothèse d'environnement
JMeter.

**UNKNOWN** — quelle modification exacte du JMX provoque l'erreur ; quel commit ou quel script l'a
produite (régénération, patch automatique de migration, fallback de transport ou autre commit
d'investigation) ; si la correction appartient au JMX généré, au générateur ou à un patch de
migration ; le statut final de `TC122` une fois la campagne restaurée ; et donc la décision de PR
finale.

**Aucune absence de régression n'est démontrée.** L'égalité stricte des `314` non-passés Cur/Fix porte
sur un périmètre amputé de `86` tests : elle ne vaut pas validation de la migration.

## Test discriminant à exécuter avant tout nouveau run

1. Télécharger les **octets** des deux versions de `002-Device_Reassign.jmx` (ne pas se fier au champ
   `content`).
2. Comparer uniquement la zone autour de la ligne ~8522 du nouveau fichier et isoler le premier écart
   structurel autour du `HeaderManager` fautif.
3. Remonter au commit ou au script producteur de cet écart.
4. Attribuer la correction au propriétaire réel : JMX versionné, générateur, ou script de migration.
5. Seulement ensuite, relancer un run et vérifier que la couverture revient à `1991` avant de
   comparer Cur et Fix.

Ne pas relancer `4445575` à l'identique ni un nouveau pipeline avant l'étape 3.

## Portée méthodologique

Ce cas établit deux contrôles à appliquer systématiquement, désormais consignés dans
[DEPANNAGE_JMETER.md](../../../documentation/guides/DEPANNAGE_JMETER.md) et le
[protocole d'investigation](../../../documentation/guides/PROTOCOLE_INVESTIGATION_ECARTS_LEGACY_JMETER.md) :

- `Run Jmeter Tests Campaign = succeeded` ne garantit pas que tous les plans annoncés ont été chargés ;
  vérifier plans annoncés, plans réellement chargés, tests publiés et erreurs `NonGUIDriver` ;
- comparer les couvertures **avant** de comparer Cur et Fix : deux côtés peuvent afficher des compteurs
  d'échecs identiques tout en ayant perdu la même campagne entière.
