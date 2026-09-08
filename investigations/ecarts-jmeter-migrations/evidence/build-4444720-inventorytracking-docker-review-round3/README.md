# Revue indépendante — build 4444720 et portée PR InventoryTracking

**Collecte :** 2026-09-08, lecture REST Azure DevOps par Python `urllib`, PAT lu uniquement en
mémoire; aucune mutation distante et aucun secret conservé. Les preuves existantes, notamment TC122,
restent inchangées.

## Verdict Docker

**FACT :** `4444720` (`7.82`) exécute le commit `efba57ea5a96d346170f4407e37050985244dcee`, avec
`pipelineDevMode=true`, versions `[26]`, types `[Cur,Fix]`, campagne `[WebServices]`. Build et stage
`Docker preflight for isolated JMeter` réussissent; Ensure ACR, staging, Promote et Tag sont skipped.

**FACT :** le preflight est le job `Verify Docker daemon before JMeter` sur agent `Azure Pipelines 42`,
Windows Server 2025 / image `windows-2025` (`20260830.247.1`), machine `runnervmohg0i`. Les jobs Cur et
Fix sont attribués séparément aux agents `Azure Pipelines 29` et `Azure Pipelines 44` (même image
Windows 2025, même machine reportée). Le preflight ne peut donc pas garantir le daemon et le runtime
du job containerisé réellement utilisé.

**FACT :** Cur et Fix atteignent chacun `Initialize containers`; Docker API/client `1.55`, login et
début de pull sont observés dans les logs `185` et `159`. Aucun `Container started successfully`,
aucune création de conteneur de campagne et aucun JTL/résultat JMeter n'est observé avant l'annulation.
Le cleanup réseau échoue ensuite par réseau absent, conséquence bornée. La timeline porte l'issue
directe `The build was canceled by Ronan JEGOU`.

**VERDICT BLOQUANT :** le preflight séparé est utile comme signal, mais ne satisfait pas la garantie
same-agent/same-runtime demandée. Le défaut résiduel est dans le pull/initialisation du job
containerisé, pas dans une absence Docker démontrée par le preflight.

**Correction minimale recommandée :** utiliser un agent Windows stable/dédié avec contrat Docker
compatible avec l'image, et vérifier `docker version`, pull par digest, `docker inspect` puis
create/start dans le contexte qui exécutera réellement Cur/Fix. Si le pipeline conserve `container:`
au niveau du job, la vérification séparée ne suffit pas; une stratégie de job hôte unique pilotant le
conteneur explicitement est le moyen déterministe de garder contrôle et campagne sur le même agent.
Ne pas redémarrer le pool global ni modifier une image ACR partagée.

## Effets partagés et transport

**FACT :** le run n'a pas publié staging, promu, tagué ou déclenché d'aval. L'artefact pipeline NuGet
du Build a été produit dans ce run précédent, mais aucun transport vers une campagne aboutie n'est
prouvé ici. Les montages/ports effectifs du conteneur ne sont pas disponibles car aucun conteneur de
campagne n'a démarré.

**UNKNOWN :** révision exacte des dépôts de templates externes (`azoTemplates`, `jmeterTemplates`,
`leoTemplates`) car leurs resources n'ont pas de `ref` immuable; cause précise du blocage après pull;
digest effectivement inspecté par chaque job; transport des JMX/données et nettoyage complet.

## Portée migration et PR

**FACT :** la branche `InventoryTracking_Migration_AutoTest_Jmeter_On_master` pointe vers
`4de185bb132cfbfb50643b6b53d6feb85508f4e2`; `master` pointe vers
`20aa528945ac33ba94598222b66fa3071c7e87b9`. Le diff complet live compte 5 137 chemins :
3 125 suppressions, 944 ajouts, 8 éditions, 530 suppressions avec renommage, 525 renommages et
5 éditions avec renommage. Les principaux ensembles sont `IntegratedTests` (3 569 chemins) et
`Tests` (1 471), avec suppression de l'ancien `Cegid.Retail.InventoryTracking.WebServices.Tests`
et de nombreux fichiers legacy, et ajout/renommage de la structure JMeter.

**FACT :** `ef3d8703` est le correctif technique XmlDiff, enfant de `4de185bb`; `efba57ea` ajoute
ensuite quatre changements, dont `Tests/WebServices/002-Device_Reassign.jmx` et
`azure-pipelines.yml`, avec le message `TC122 diagnostic and Docker preflight`.

**VERDICT PR :** ne pas ouvrir une PR depuis `efba57ea` tel quel : elle embarquerait les diagnostics
TC122/preflight. La base reviewable est la migration `4de185bb` plus le seul correctif XmlDiff
`ef3d8703` (patch exact conservé dans le lot précédent), sans le commit de diagnostic. Cela préserve
la portée complète migration du WI sans confondre correctif technique et instrumentation exploratoire.
La complétude fonctionnelle détaillée des 5 137 chemins reste à valider par le propriétaire source;
les compteurs seuls ne constituent pas cette validation.

## Cur/Fix et TC122

Les résultats antérieurs de `4440884` restent la seule comparaison : 1 991 résultats par variante,
339 Fail/Fail, 1 651 Pass/Pass et un seul delta TC122. Aucun nouveau résultat n'est produit par
`4444720`; aucun second rejeu n'est donc demandé maintenant. Un rejeu ciblé ne sera nécessaire que
si la prochaine exécution fournit des JTL et corrélateurs incompatibles ou incomplets pour TC122,
avec commit/YAML, image+digest, package/hash, JMX, données, requête/réponse expurgées, assertion,
code HTTP, message serveur et corrélateur.
