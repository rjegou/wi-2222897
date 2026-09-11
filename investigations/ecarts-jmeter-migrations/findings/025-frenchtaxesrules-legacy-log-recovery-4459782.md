# Finding 025 — FrenchTaxesRules Legacy : run 4459782 sans résultat de test rapporté

**Date d'intégration : 2026-09-11** · **Source :** [fiche reçue](../evidence/local-2026-09-11-frenchtaxesrules-legacy-log-recovery/source-fiche.md) · **Statut : rapporté, non revérifié**

## Périmètre

La fiche concerne le run Azure DevOps `4459782`, le plugin `Y2_Plugins_FrenchTaxesRules`, la branche `master`, la version `10.87`, la VM `Y2-TSTAUTOXXPG2` et le label `test.10.87-20260911_073620`.

## Conclusion bornée

- **FACT documentaire** — une fiche reçue le 2026-09-11 rapporte que le workflow a atteint `executeWorkflowPlugin`, mais pas `executeWF_PluginOneCore` ni `executeIntegrationTest`.
- **FACT documentaire** — cette fiche rapporte qu'aucun TRX, `.mstest.log`, log, XML de résultat ou rapport lié n'a été trouvé dans le workspace du run, et que le XML NAnt observé faisait `0` octet.
- **INFERENCE** — si ces observations sont exactes et complètes, aucun test MSTest Legacy n'a démarré pour ce run et il n'existe pas de résultat Legacy comparable à mettre en regard de JMeter.
- **INFERENCE rapportée** — le point de blocage le plus probable est le traitement PowerShell 5.1 d'une réponse `Invoke-WebRequest` JFrog sans `-UseBasicParsing`.
- **UNKNOWN** — la lecture directe des logs, la reproduction indépendante, la cause exacte du blocage, le contenu du script concerné et la rotation effective du secret ne sont pas prouvés par cette intégration.

## Complément de portée — PG3 et code commun

- **FACT documentaire** — un complément du 2026-09-11 rapporte le même arrêt sur la VM
  `Y2-TSTAUTOXXPG3` avec `Y2_Plugins_InventoryTracking_V5` : `executeWorkflowPlugin` est la
  dernière trace, sans `executeWF_PluginOneCore`, `executeIntegrationTest` ou `StartWorkflowAsync`.
- **FACT documentaire** — ce complément rapporte aussi un XML NAnt associé au run, présent mais à
  `0` octet.
- **FACT documentaire** — PG2 et PG3 sont rapportées comme utilisant le même
  `Artifactory_fct.ps1`, avec un SHA-256 identique. La valeur du hash n'est pas fournie et aucune
  comparaison d'octets n'a été effectuée dans cette intégration.
- **INFERENCE rapportée** — la répétition du symptôme sur deux VM Legacy et deux plugins renforce
  l'hypothèse d'un problème transversal au socle VM Legacy ou au code commun d'accès JFrog, plutôt
  que d'un défaut propre à FrenchTaxesRules, InventoryTracking ou une branche donnée.
- **INFERENCE rapportée** — le suspect principal reste un `Invoke-WebRequest` PowerShell 5.1 sans
  `-UseBasicParsing` et sans timeout explicite.
- **UNKNOWN** — la transversalité n'est pas indépendamment vérifiée ; le contenu exact du script,
  le hash, la réponse JFrog, le timeout et la première instruction bloquante restent à établir.

## Conséquence pour l'enquête JMeter/Legacy

Le run `4459782` ne doit pas être ajouté comme baseline Legacy ni utilisé pour qualifier une régression JMeter. Il peut servir de piste de diagnostic du lanceur Legacy et de définition d'un rejeu discriminant, sous réserve d'un accès read-only aux logs et d'un contrôle des secrets avant partage.

## Rejeu discriminant attendu

Après correction autorisée du composant propriétaire, vérifier séparément :

1. retour rapide de l'appel JFrog avec timeout explicite ;
2. présence de `executeWF_PluginOneCore`, `executeIntegrationTest` et `StartWorkflowAsync` dans les logs ;
3. création effective du TRX, du `.mstest.log` et du rapport ;
4. rotation/révocation du secret exposé, sans jamais le recopier dans la documentation.

Ce finding ne constitue ni une autorisation de modifier le dépôt Legacy, ni une preuve de succès d'un rejeu.

Le complément de portée est conservé dans la [preuve documentaire dédiée](../evidence/local-2026-09-11-legacy-jfrog-cross-vm-symptom/README.md).
