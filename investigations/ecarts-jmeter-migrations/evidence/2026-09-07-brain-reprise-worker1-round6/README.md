# InventoryTracking build 4440884 — analyse primaire read-only

Collecte du 2026-09-07 depuis Azure DevOps `cegid/Retail`, sans relance ni
mutation. Build `4440884`, numéro `7.76`, définition `2072` (`InventoryTracking
CI`), dépôt `Y2_Plugins_InventoryTracking`, branche
`refs/heads/validation/WI-2222897-inventorytracking-xmldiff`, commit
`ef3d87034d38b88aca04c824061b140e2a29252c`. Queue `Azure Pipelines` (591),
raison `manual`, fenêtre UTC `12:45:49–13:56:07`, résultat global
`partiallySucceeded`.

Paramètres effectifs du build : `pipelineDevMode=true`,
`campaignsToTest=[WebServices]`, `typesToTest=[Cur,Fix]`,
`versionsToTest=[26]`. Aucun paramètre libre additionnel n’est exposé dans
`build-show.json`.

## Faits directement prouvés

- `log-51.json` : `dotNet-build: Build solution **\\*.sln` terminé `succeeded`,
  `0 Error(s)`. La ligne C# de `Services.Tests` référence effectivement
  `Sln\\packages\\Cegid.Retail.XmlDiff.1.0.0\\lib\\net452\\Cegid.Retail.XmlDiff.dll`
  et `XMLDiffPatch.1.0.8.28`. La compilation XmlDiff est donc résolue dans ce
  build précis.
- `log-52.json` : tests d’assemblies `48 total / 48 Passed`, VSTest code `0`.
- `log-131.json` et `log-138.json` : déploiements containerisés V26 Fix et Cur,
  restauration de base et installations MSI se terminent par `Done !`; les
  tâches timeline sont `succeeded`. `log-145.json` et `log-153.json` terminent
  les contrôles de déploiement Cur/Fix.
- `log-152.json` et `log-160.json` : préparation des campagnes Cur/Fix réussie.
- `log-161.json` et `log-162.json` : JMeter exécute réellement la campagne
  `WebServices` Cur/Fix ; chacune lance 32 plans, termine 32 plans et clôt la
  campagne. Les tâches timeline sont `succeeded`.
- `log-168.json` et `log-171.json` : le contrôle aval lit les résultats des
  campagnes Cur/Fix et trouve, dans chaque variante, 141 occurrences
  `SQLServerException: Incorrect syntax` et 123 `B-XQuery: ... differences were
  found`. Les signatures sont donc communes aux deux variantes, sans preuve
  qu’elles soient causées par XmlDiff.
- `log-170.json` et `log-173.json` : les Test Results sont publiés dans les runs
  `6185924` et `6185925`, mais avec erreurs signalant des échecs de tests ; ceci
  explique `succeededWithIssues` des jobs `TI Jmeter V26-Cur/Fix` et le résultat
  global `partiallySucceeded`.

Les résumés de timeline sont dans `timeline-result-summary.json` et
`timeline-stage-job.txt`. `signature-summary.txt` est hashé
`CCF97E2D829182F6915111EF254E5D42CA5A6B1E7EB7A6D41D29F5911B9691B5`.

## Premier défaut discriminant

**FACT** : le défaut XmlDiff de 4434070 est résolu dans 4440884 au niveau
compilation et tests d’assemblies. Le déploiement Cur/Fix, la préparation et
l’exécution JMeter atteignent aussi leur postcondition technique.

**FACT** : le premier défaut discriminant restant apparaît au contrôle des
résultats de campagne, après exécution JMeter : erreurs SQL de pré/post-requêtes
et différences XML, présentes dans Cur et Fix. **INFERENCE** : ce n’est pas un
blocage de compilation, de déploiement ou de génération ; il faut maintenant
isoler la première requête/scénario commun fautif avant d’attribuer une cause.

**UNKNOWN** : cause racine des `Incorrect syntax`, scénario JMeter/SQL précis,
contenu des réponses XML et éventuelle relation avec le changement XmlDiff.
Les résultats legacy ne sont pas appelés comme régression : aucune
comparabilité scénario/contrat/données/environnement n’est établie ici.

## Artefacts et provenance

`build-show.json`, `timeline.json`, `logs-index.json`, les logs causaux
`log-48.json`, `log-50.json`, `log-51.json`, `log-52.json`, `log-55.json`,
`log-131.json`, `log-138.json`, `log-145.json`, `log-152.json`, `log-153.json`,
`log-160.json`, `log-161.json`, `log-162.json`, `log-168.json`, `log-170.json`,
`log-171.json` et `log-173.json` sont hashés dans `SHA256SUMS.txt` (manifeste
SHA-256 : `525DA48D8CD415E3FFEE3D0273ECC12A4DE53D29E503556B2C540AF94EF52D49`).

Les deux artefacts WebServices Cur/Fix ont été téléchargés temporairement avec
Python `requests` et TLS vérifié, uniquement pour confirmer leur structure ;
empreintes ZIP locales : Cur `AFAD8CBED10BE1A32BAF003DB68F08C446DDDAC4341B4C4CABF2A54A7DC10AE7`,
Fix `E771F5442AA77CB03536DCA365B65838DC7DB417D45417D3F36F4FC29FCD3B5F`.
Ils contenaient chacun un ZIP WebServices imbriqué de 1 408 entrées. Aucun
contenu XML/JTL brut potentiellement sensible n’a été copié dans la collecte ;
les temporaires et configurations Azure ont été supprimés après lecture.

## Prochaines actions possibles

1. Extraire, dans un environnement approuvé, un sous-ensemble JTL non sensible
   autour de la première signature SQL commune (Cur/Fix) et rattacher chaque
   erreur à son plan/TC.
2. Comparer la requête générée et les paramètres de ce TC avec la source
   legacy correspondante ; ne conclure à une régression qu’après la gate de
   comparabilité complète.
3. Garder le correctif XmlDiff comme validé au niveau build 4440884 ; ne pas le
   confondre avec les échecs métier SQL/XML persistants.

Aucun push, queue, commentaire, publication, promotion, tag ou système métier
n’a été modifié dans cette collecte.
