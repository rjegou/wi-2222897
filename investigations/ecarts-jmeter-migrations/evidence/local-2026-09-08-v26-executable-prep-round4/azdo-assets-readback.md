# Readback assets — 2026-09-08

Source : Azure DevOps REST, dépôt `Y2_Plugins_FrenchTaxesRules`, commit
`07a42172bebc65d17093e166ac08de22e4fe7248`, lecture authentifiée sans archivage
du PAT.

| Chemin | Résultat |
|---|---|
| `/IntegratedTests/AutoTest/Data/LegacyServices/TestPlans/Export_Run.xml` | trouvé, objectId `96f3288059e254843d982a805c0e1af2e44df9aa` |
| `/IntegratedTests/AutoTest/Data/LegacyServices/TestPlans/DocumentSignature_SignOne.xml` | trouvé, objectId `246a2c9b272035e602058f8eb2ee710644dd8d6a` |
| `/Tests/Backups/AUTO_V26_00.bak` | HTTP 404 dans ce dépôt/commit |
| `/Tests/Export_Run/001-Export_Run.jmx` | HTTP 404 dans ce dépôt/commit |
| `/Tests/LegacyServices/005-DocumentSignature_SignOne.jmx` | HTTP 404 dans ce dépôt/commit |

Le 404 établit seulement que ces trois chemins ne sont pas à ces emplacements
du commit interrogé. Il ne prouve pas l'indisponibilité d'un backup distant ou
d'un JMX produit par le workflow. Le mécanisme d'acquisition restant à vérifier
est le checkout de la branche/source de migration réellement consommée par le
workflow, puis la résolution du package Console et la génération des JMX.

Le build legacy `4423394` sur `master` a été observé `inProgress`, mais aucune
preuve de son nom de tenant, hôte, backup ou container ne le relie aux cibles
V26 proposées. Il ne constitue donc ni preuve de partage, ni autorisation pour
le rejoindre, l'annuler ou le nettoyer.
