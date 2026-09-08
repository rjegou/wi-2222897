# Collecte Worker 1 — validation Clienteling V24/V25

Date : 2026-09-07, source locale `worktrees/Y2_Plugins_Clienteling` (branche
`master`). Les cinq XML déjà corrigés par le travail parallèle ont été utilisés
en lecture seule. Aucun document canonique partagé, aucune source de correction
et aucun test Products n’a été modifié.

## FACT — génération fraîche

Pour chaque version, un staging neuf a copié le package Console de
`evidence/local-2026-09-07-soap-package-round14/package-extracted-v2`, les
fixtures InputFiles/OutputFiles et les cinq plans corrigés. Le chemin de sortie
requis par le générateur a été créé explicitement :
`generated/IntegratedTests/AutoTest/Data/campaign/TestPlans/OutputFiles`.
La Console a été lancée par `Start-Process`, stdout/stderr redirigés, avec
`--Tstj=fixture/campaign.xml --dstFolder=generated`.

| version | code Console | JMX | parsing XML | endpoints observés |
|---|---:|---:|---|---|
| V24 | 0 | 5/5 | `XmlDocument.Load` réussi pour les 5 | 3 ClientelingDeployment + 2 ClientelingMobility |
| V25 | 0 | 5/5 | `XmlDocument.Load` réussi pour les 5 | 3 ClientelingDeployment + 2 ClientelingMobility |

Les sorties immuables sont dans `generated-jmx/v24/` et `generated-jmx/v25/`.
Les SHA-256 des cinq JMX sont, dans l’ordre Deployment Reset, Deployment
Catalog, Deployment Customer, Mobility Get, Mobility Update :

`BF5D337DA9DB0834690F0105D06F94D8C9C5306D2AF276D6E3211E2D7C7F5FF1`,
`4E1B0C75BDD7CC9C6624AD126E099075990DD3E12D51735794F44A73AF65F6C1`,
`824A070CAFDC2A40871CD28F499E0E2EF7EEDA383CBD78F5BF8B41993117DAF8`,
`015C138CE17016997708A013D43D21B9E480D03780E8BE66406D379D304582CC`,
`440B0CDFCE93CF7BE608B7E164463A0C669ADDC56CC1261BBC9B1C4C1001EE17`.

Les logs complets sont `generation-v24.stdout.log`, `generation-v24.stderr.log`
et `generation-v25-rerun.stdout.log`, `generation-v25-rerun.stderr.log`.
Les JMX V22/V23 de round3 ont les mêmes cinq hashes et le même contrôle ; la
matrice complète V22–V25 est donc : 20/20 JMX générés avec code 0, parsing XML
réussi, et endpoints spécifiques conformes aux manifests historiques.

## FACT — rapprochement historique

Les archives exactes V22–V25 et manifests sont conservés dans
`../2026-09-07-brain-reprise-worker1-round3/historical-snapshots/`. Les commits
sont V22 `97bc21d41`, V23 `f9ce510ab`, V24 `789ab7280`, V25 `119014398`.
Les sources historiques portaient les noms génériques `DeploymentService.svc`
et `MobilityService.svc`; les manifests de chaque version déclaraient les
services Clienteling spécifiques. Les JMX frais V24/V25 relus ici contiennent
les valeurs spécifiques, sans valeur générique exacte.

## FACT / UNKNOWN — ClientelingProductsService.svc

`805f68489` ajoute le service Products, le plan `Products_GetItemsV2.xml` et les
fixtures. Les commits de « dereferencement » `1bcb509c3`, `8744999ca`,
`a3b9c933d`, `8f1088fb5` retirent ensuite le plan/fixtures. Les manifests V22,
V23, V24 et V25 ne déclarent pas `ClientelingProductsService.svc`.

FACT : présence technique historique et actuelle. UNKNOWN : décision de support
autorisée, installation MSI et contrat supporté par version. Il faut une
confirmation explicite du propriétaire Clienteling pour V22–V25 avant d’activer
ou de supprimer le test Products. Aucun test Products n’a été changé.

## Orchestration et limites

La validation locale indépendante est la chaîne package → Console → JMX,
réalisée sans push, publication JFrog, pipeline, SQL ou IIS. L’inspection du
workflow confirme des étapes JFrog/promotion qui ne sont pas sûres à exécuter
dans ce lot ; elles ont donc été neutralisées par omission. Génération JMX
réussie ne prouve ni installation MSI ni succès HTTP métier. Prochaine action
utile : décision support Products, puis smoke HTTP Clienteling autorisé par
version.
