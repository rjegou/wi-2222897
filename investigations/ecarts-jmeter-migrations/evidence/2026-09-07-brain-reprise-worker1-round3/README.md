# Collecte Worker 1 — Clienteling V22–V25

Date de collecte : 2026-09-07 (Europe/Paris). Source principale : dépôt local
`worktrees/Y2_Plugins_Clienteling`, branche `master`, consulté en lecture seule.
Les cinq XML de test comportaient déjà les modifications d’un autre travailleur;
ils n’ont pas été édités dans cette collecte. Aucun fichier canonique partagé n’a
été modifié.

## FACT — sources et manifests historiques

Les couples exacts ont été récupérés par `git archive` depuis l’historique local,
puis conservés dans `historical-snapshots/` avec empreinte SHA-256 :

| version | commit source | archive SHA-256 | manifest blob |
|---|---|---|---|
| V22 | `97bc21d41` | `21C6AC9CB01E363726ACB6A2D43C68F6B85E69CEC926FF2B466FD338669A3441` | `4effb73f6c7e73232ecba8f803783c50ae6a7fe1` |
| V23 | `f9ce510ab` | `E44823CB3F4D598C3074923A9333AF4489DE1C04B317C9DFD6F1607B454BCCF6` | `bca1f8129bbc6b10ca74ea90a95c165f23b70ec0` |
| V24 | `789ab7280` | `268165F1742750C51906B4A71E6254A3FE021C5A780896F55318E2D7F5D9CE6F` | `569b613220c8f9c4ffea1748f776c595c1979ab4` |
| V25 | `119014398` | `876FF23BA06D7FFC98F8237B2B4DDB3DB6D1954B9018F8E66B8D389AE9936A5D` | `faa76cc61d130b65760ae682cfc2ff3623487aff` |

Les cinq blobs XML sont identiques entre V22 et V25 : trois portent
`DeploymentService.svc`, deux portent `MobilityService.svc`. Les quatre manifests
déclarent `ClientelingDeploymentService.svc` et `ClientelingMobilityService.svc`.
Une recherche exacte dans les quatre manifests ne trouve pas
`ClientelingProductsService.svc`.

## FACT — validation de la correction et génération fraîche

Les cinq sources actuellement corrigées ont été lues par XML et hashées :

| fichier | SHA-256 | WebService attendu |
|---|---|---|
| Deployment_ResetFTSCustomer.xml | `F432EC1FD7362EF660A3D455B67FBF35B54C6283F13C3C8834FA0F159107257D` | ClientelingDeploymentService.svc |
| Deployment_UpdateFTSCatalog.xml | `21432AE4CED369F259EC5D46B6AFC5ABDE97D8D4375709927E8BA677983DF58D` | ClientelingDeploymentService.svc |
| Deployment_UpdateFTSCustomer.xml | `056913E3A20EABB3322FC5CF77282F73D1AD3594598F517F2186A8B11C2DC651` | ClientelingDeploymentService.svc |
| Mobility_GetClientelingParameters.xml | `3F755B7F0503251A412F61E7FF7E7FEA8A1B136CCD9432611C03BC6E935D7114` | ClientelingMobilityService.svc |
| Mobility_UpdateClientelingParameters.xml | `D6B2E716AC14A72302475D8A8D6637AB191164E38CB3A037ED93D7423A24A95F` | ClientelingMobilityService.svc |

Avec le package Console déjà acquis dans `local-2026-09-07-soap-package-round14`,
un staging neuf par version a été utilisé. `Start-Process` avec stdout/stderr
redirigés a produit un code de sortie `0` et cinq JMX pour V22 et V23. Chaque
JMX a été chargé avec `XmlDocument.Load`; les trois JMX Deployment contiennent
le service ClientelingDeployment, les deux JMX Mobility le service
ClientelingMobility, et aucun nom générique n’est présent. Les JMX frais sont
dans `generated-jmx/final5-v22/` et `generated-jmx/final5-v23/`.

Les tentatives V24/V25 ont atteint le générateur mais n’ont pas été conservées
comme validation réussie : les premiers runs sortaient `-1` avec quatre JMX,
puis la relance de correction de chemin n’a pas produit de lot exploitable.
Verdict V24/V25 génération fraîche : UNKNOWN, à rejouer avec la même structure
de sortie exacte `generated/IntegratedTests/AutoTest/Data/campaign/TestPlans/OutputFiles`.

## FACT / UNKNOWN — Products

Le commit `805f68489` (« feat: add Product GetItemsV2 », work item `#668989`)
ajoute le `.svc`, le plan `Products_GetItemsV2.xml` et ses fixtures. Les commits
`1bcb509c3`, `8744999ca`, `a3b9c933d` et `8f1088fb5`, tous intitulés
« dereferencement », suppriment ensuite le plan/fixtures et références de test.
La présence technique du service et du contrat est donc prouvée historiquement
et dans le code courant; son inclusion MSI V22–V25 n’est pas prouvée (absente
des manifests récupérés).

UNKNOWN : aucune décision explicite trouvée dans les sources locales examinées
qui autorise ou interdit le support produit pour V22–V25. Question extérieure
précise : le propriétaire Clienteling doit confirmer, par version, si
`ClientelingProductsService.svc` est un endpoint officiellement supporté,
installable dans le MSI et couvert par contrat. Sans cette décision, ne pas
activer ni supprimer le test Products.

## Limites et prochaine action

La génération JMX ne prouve ni installation MSI ni succès HTTP métier; aucun
appel Clienteling réel n’a été lancé. Les preuves JMeter fraîches complètes
restent donc V22/V23 seulement. Prochaine action utile : rejouer V24/V25 avec la
correction de staging de sortie, puis obtenir la décision support Products et
faire un smoke HTTP isolé par version après installation autorisée.
