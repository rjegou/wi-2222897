# Handoff archivé — écarts JMeter de la migration FrenchTaxesRules

> Document historique conservé pour traçabilité. Pour une reprise actuelle, utiliser `../../investigations/ecarts-jmeter-migrations/HANDOFF.md`. Les chemins relatifs décrits ci-dessous reflètent l'ancienne organisation et ne doivent pas servir de routeur.

## Conclusion exécutive

L'investigation a permis de trancher les hypothèses principales :

| Sujet | Verdict | Conclusion |
|---|---|---|
| Export TC08/09/10 — dates SQL | **Prouvé** | `Cegid.Retail.AutoTest.Api` inverse le mois et le jour des dates ISO déjà placées entre apostrophes. C'est la cause racine de TC08, puis de la pollution de TC09 et TC10. |
| `ExpectedValue=-1` | **Hypothèse réfutée** | `-1` signifie « exécuter la requête sans contrôler le nombre de lignes », et non « accepter une erreur SQL ». Le doublon de TC09 reste donc un vrai échec, provoqué en amont par TC08. |
| TC99 | **Règle de skip réfutée** | `Code=99` n'est pas une convention d'exclusion. Les cas sont actifs dans le legacy comme dans JMeter. Deux entrées de debug sans assertions provoquent réellement une faute HTTP 500. |
| FrenchTaxesRules TC22 | **Défaut indépendant crédible** | Le scénario repose sur deux lignes ayant la même date et sur un `TOP 1 ... ORDER BY date DESC` sans second critère. Son résultat est indéterministe et son attente paraît incohérente avec la date applicative configurée. Ce n'est pas, à ce stade, un défaut démontré du convertisseur. |
| « build legacy vert » | **Non démontré / assertion incorrecte** | Le build `4432288` est `canceled`. Le run publié de 522 tests ne contient que les tests unitaires ; il ne prouve pas le passage des tests d'intégration legacy concernés. |

La correction prioritaire est donc dans le NuGet de migration : remplacer la transformation des dates SQL apostrophées `YYYY-MM-DD -> YYYYDDMM` par `YYYY-MM-DD -> YYYYMMDD`. Il ne faut pas modifier globalement la gestion de `ExpectedValue=-1` ni ignorer globalement les TC99.

## Reprise sur un autre poste

Ce document est destiné à être fourni à un autre agent LLM. Son workspace sera :

```text
C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897
```

Sa mission est de reprendre l'analyse des écarts, de confirmer la classification ci-dessous et de préparer les actions correctives. Les conclusions déjà prouvées ne doivent être rouvertes que si une nouvelle preuve les contredit. Par défaut, rester en lecture seule dans Azure DevOps : ne pas pousser de branche, créer de PR ou relancer de pipeline sans demande explicite.

### Ressources à récupérer localement

Le point d'entrée opérationnel pour la collecte legacy est [`investigations/ecarts-jmeter-migrations/HANDOFF.md`](../../investigations/ecarts-jmeter-migrations/HANDOFF.md). La fiche des VMs, des chemins de rapports/TRX et des précautions de collecte est [`investigations/ecarts-jmeter-migrations/references/legacy_test_vm_technical_cheatsheet.md`](../../investigations/ecarts-jmeter-migrations/references/legacy_test_vm_technical_cheatsheet.md) ; la consulter avant toute recherche sur `Y2-TSTAUTOXXPG1` à `Y2-TSTAUTOXXPG4`.

Créer un sous-dossier `repos` et y cloner ces trois dépôts Azure DevOps du projet `Retail` :

| Dépôt | Révision à utiliser | Utilité |
|---|---|---|
| `Migration_Jmeter_RJE_Sandbox` | `13144a2fb5ef7c822fff3c0a64fed88e72339981` | Scripts de migration et NuGet `2.0.41` ayant servi à la génération. |
| `Y2_Plugins_FrenchTaxesRules` | `f80bc731571b2b5ed8a67da171b288873de428a6` ; comparer à `07a42172bebc65d17093e166ac08de22e4fe7248` | XML legacy, JMX générés, configuration et code métier du plugin. |
| `Y2_Tools_AutoTest_Api` | `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` | Source du générateur contenant `JmeterCodeGen.EscapeJdbcDate`. |

Récupérer ensuite, dans un sous-dossier `evidence`, les artefacts du build migré `4432510` dont le nom contient `LegacyServices_TestLogs`, `WebServices_TestLogs` ou `RunLogs`, pour les variantes `v26-Cur` et `v26-Fix`. Ce sont les six artefacts utiles au diagnostic. Les artefacts applicatifs `Nuget`, `Software`, `HtmlDocs` et les logs de déploiement ne sont pas nécessaires à cette analyse.

### Récupération des logs sur l'infrastructure legacy

Les deux messages du collègue, s'appuyant sur la page 13 de `procédureMigration.pdf` et sur le document technique de nettoyage post-migration, indiquent les emplacements suivants sur les VM legacy. Ces chemins sont des points d'investigation à vérifier directement sur la VM ; ils ne constituent pas une preuve que les fichiers des builds étudiés y sont encore présents.

| Emplacement | Rôle indiqué | Usage pour cette investigation |
|---|---|---|
| `D:\CegidUtils\CegidIntegrationTests\override` | Dossiers correspondant aux plugins et versions des tests legacy | **Premier emplacement à inspecter** sur `Y2-TSTAUTOXXPG2` pour retrouver la correspondance FrenchTaxesRules / version / configuration. |
| `C:\inetpub\wwwroot\integrationTestsReports` | Rapports de tests, avec des sous-dossiers du type `Retail VXX.XX Integration Tests` | Rechercher les rapports d'exécution et leur rattachement à une version. |
| `\\cbr-tstauto-sql\Archives\TRX\CBR_AUTO_TT_XX.XX` | Archives TRX des exécutions legacy | Rechercher les résultats TRX archivés par version. |
| `\\cbr-tstauto-sql\Outils\PublishTRX\Dashboard.SourceItems.xml` | Configuration alimentant le dashboard des tests | Vérifier les entrées publiées et leur éventuel lien avec les campagnes legacy. |

#### Cibles VM et accès documentaire

- La procédure mentionne les VM legacy `Y2-TSTAUTOXXPG1` à `Y2-TSTAUTOXXPG4` ; l'exemple donné pour POS est `Y2-TSTAUTOXXPG2`.
- Le document de suivi associe **FrenchTaxesRules à `Y2-TSTAUTOXXPG2`** ; cette association reste à confirmer par inspection de la configuration ou des artefacts.
- La procédure indique une connexion avec le compte `cegidgroup\SvcTestAutoRetail` / `SvcTestAutoRetail`. Aucun mot de passe n'est documenté ici et ne doit pas être recherché, recopié ou stocké dans le dossier.
- Des raccourcis vers les fichiers concernés seraient présents sur le bureau de la VM, notamment `Integration...`, `List integration...` et `override - Shortcut`. Ils peuvent servir de navigation rapide, mais les chemins explicites ci-dessus restent la référence à relever.
- **INFERENCE à confirmer** : une connexion RDP via `mstsc` est la méthode la plus probable au vu de la capture d'un bureau Windows. La documentation fournie ne confirme pas explicitement le protocole ni les paramètres de connexion.

Ordre de collecte recommandé, en lecture seule : (1) `D:\CegidUtils\CegidIntegrationTests\override` sur `Y2-TSTAUTOXXPG2`, (2) rapports sous `C:\inetpub\wwwroot\integrationTestsReports`, (3) archives TRX sur `cbr-tstauto-sql`, puis (4) `Dashboard.SourceItems.xml`. Pour chaque artefact trouvé, conserver le chemin complet, le nom de plugin/version, la date de modification et, si possible, le hash ; ne pas nettoyer ni modifier les emplacements legacy.

Conserver aussi les métadonnées et résultats publiés des builds :

- `4432510` : build migré et runs de tests `6180452`, `6180463`, `6180466`, `6180469` ;
- `4432288` : baseline legacy annulée et run unitaire `6180090` ;
- work items de contexte : PBI `2222897` et tâche `2223026`.

Le backup Git LFS `Tests/Backups/AUTO_V26_00.bak` du dépôt FrenchTaxesRules n'est nécessaire que pour un rejeu local. Il fait environ 151 Mo ; ne le télécharger qu'à ce moment-là.

### Accès Azure DevOps

L'agent dispose d'Azure CLI et du fichier PAT suivant :

```text
C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt
```

Initialisation minimale en PowerShell :

```powershell
$env:AZURE_DEVOPS_EXT_PAT = (Get-Content -Raw -LiteralPath 'C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt').Trim()
az extension add --name azure-devops --upgrade --only-show-errors
az devops configure --defaults organization=https://dev.azure.com/cegid project=Retail
az pipelines runs artifact list --run-id 4432510 -o table
```

Télécharger les six artefacts retenus avec `az pipelines runs artifact download`. Ne jamais afficher, copier dans le workspace ou committer le PAT. À la fin de la session :

```powershell
Remove-Item Env:\AZURE_DEVOPS_EXT_PAT -ErrorAction SilentlyContinue
```

## Contexte et sources

- Workspace de reprise : `C:\Users\jegour\OneDrive - CEGID\Documents\repertoireTravailRon\missions\delivery-acceleration\context\WI-2222897`
- Les chemins historiques du premier poste ne sont pas requis ; utiliser les clones placés sous `repos` et les téléchargements placés sous `evidence`.
- Branche migrée : `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_master`
- Commit source master : `07a42172...`
- Commit migré : `f80bc731...`
- NuGet convertisseur : `repos\Migration_Jmeter_RJE_Sandbox\migration-tools\Cegid.Retail.AutoTest.Console.nupkg`
- Versions : console `2.0.41`, API `1.1.46`, workflow `3.0.175`
- Artefacts du build migré : `evidence\build-4432510`
- Build legacy : [4432288](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432288&view=results)
- Build migré : [4432510](https://dev.azure.com/cegid/Retail/_build/results?buildId=4432510&view=results)

Le PAT utilisé pour les lectures Azure DevOps est stocké localement. Sa valeur ne doit jamais être recopiée dans un rapport, une commande persistée ou un commit.

## Résultats observés sur le build migré

Le build `4432510` est `partiallySucceeded`, sur `f80bc731...`.

| Run | Total | Passed | Échecs |
|---|---:|---:|---:|
| LegacyServices-v26-Fix | 187 | 183 | 4 |
| LegacyServices-v26-Cur | 187 | 183 | 4 |
| WebServices-v26-Fix | 66 | 64 | 2 |
| WebServices-v26-Cur | 66 | 64 | 2 |

Cur et Fix échouent sur les mêmes cas. Les écarts sont reproductibles dans les deux variantes.

### Échecs LegacyServices

- `009-FrenchTaxesRules:Run - TC 22` : `C-PostQuery1` obtient `1`, attendu `2`.
- `010-Export:Run - TC 08` : le service répond HTTP 200 mais avec `RunStatus=Error`, `CBR_062_0005`, « Le format de la période est invalide ». Les six post-contrôles et deux nettoyages échouent.
- `010-Export:Run - TC 09` : `A-PreQuery3` rencontre une clé dupliquée sur `DAEMONSAFT`. Le service échoue ensuite sur la période ; `C-PostQuery1` et `D-FinalQuery3` échouent également.
- `010-Export:Run - TC 10` : `C-PostQuery2` obtient `2`, attendu `1`.

### Échecs WebServices

- `003-Validation:ValidateClosingsV2 - TC 99 - B-XQuery` : HTTP 500, faute `CBR_062_0005`, période invalide.
- `004-Validation:ValidateDocuments - TC 99 - B-XQuery` : HTTP 500, même faute métier.

## 1. Défaut prouvé dans la conversion des dates SQL

La DLL `Cegid.Retail.AutoTest.Api.dll` incluse dans le NuGet a été décompilée, puis la preuve a été retrouvée dans le dépôt source `Y2_Tools_AutoTest_Api`. À la révision `220de3d...`, la méthode `JmeterCodeGen.EscapeJdbcDate` contient exactement cette règle :

```csharp
Regex.Replace(query,
    "'(\\d{4})-(\\d{2})-(\\d{2})'",
    "'${1}${3}${2}'");
```

Les groupes sont réassemblés dans l'ordre année, **jour**, mois. Il faut les réassembler année, mois, jour :

```csharp
"'${1}${2}${3}'"
```

Une seconde règle de la même méthode traite les dates ISO non apostrophées avec `${1}${2}${3}` ; celles-ci sont correctement converties. Le défaut est donc limité aux dates déjà entourées d'apostrophes.

La ligne fautive a été introduite par le commit `7cdeaea0f089c6b93cf52d11ae8d5d3137a0b3cd` (`bugfix: sql jdbc date`).

### Preuve sur Export TC08

Source :

```sql
DSA_TARGETDATE = '2015-12-01'
DSA_DATEEXEC   = '2016-01-03'
```

JMX généré :

```sql
DSA_TARGETDATE = '20150112'
DSA_DATEEXEC   = '20160301'
```

Le legacy envoie les littéraux ISO d'origine. Le JMX change leur sens. Le service reçoit donc une période incohérente et retourne `CBR_062_0005`.

### Chaîne causale TC08 -> TC09 -> TC10

Les ThreadGroups sont sérialisés et `on_sample_error=continue`. Un échec ne stoppe donc pas la suite du plan.

1. TC08 insère une ligne portant la date erronée `20150112`.
2. Son nettoyage cherche les dates normales `20151201`, `20160101` et `20160201` : il ne supprime pas la ligne mal datée.
3. TC09 réutilise la même clé et rencontre le doublon. Sa propre date apostrophée `2016-02-01` a également été transformée en `20160102`.
4. TC10 voit encore la ligne résiduelle ; son comptage obtient `2` au lieu de `1`.

Les échecs TC09 et TC10 ne sont donc pas des défauts autonomes : ils sont des conséquences déterministes de TC08 et de la poursuite du plan après erreur.

### Correction et tests minimaux du NuGet

Corriger uniquement la chaîne de remplacement de la première regex, puis ajouter des tests unitaires pour :

| Entrée | Sortie attendue |
|---|---|
| `'2015-12-01'` | `'20151201'` |
| `'2016-01-03'` | `'20160103'` |
| `2016-02-01` | `'20160201'` |
| `'20160103'` | inchangée |

Il faut ensuite régénérer le plan Export et rejouer au minimum TC08, TC09 et TC10 sur une base propre. Une simple correction manuelle du JMX ne corrigerait pas le générateur et ne constitue pas le correctif durable.

## 2. `ExpectedValue=-1` : hypothèse réfutée

L'interprétation initiale « erreur SQL attendue » est fausse.

Le générateur C# legacy exécute la requête, mais omet seulement l'assertion sur le nombre de lignes lorsque la valeur vaut `-1`. Le code généré porte le commentaire `Control is not needed - skipped`, puis appelle néanmoins `CallExecuteSql(...)`.

Le générateur JMeter a la même sémantique :

- le sampler JDBC est toujours généré ;
- le statut technique du sampler doit rester correct ;
- l'assertion sur la valeur n'est ajoutée que si `ExpectedValue` ne contient pas `-1`.

Dans le corpus, cette convention apparaît 358 fois dans 11 plans. Changer globalement `-1` pour accepter les erreurs SQL masquerait donc de vrais défauts sur un périmètre important.

Pour Export TC09, la clé dupliquée n'est pas une erreur attendue : elle résulte de la ligne que TC08 n'a pas nettoyée. Aucun changement de sémantique n'est requis dans le NuGet sur ce point.

## 3. TC99 : ne pas introduire de skip global

Quatre cas `Code="99"` ont été retrouvés :

- deux cas WebServices libellés `NC - Pour debug`, sans contrôles, qui échouent ;
- un cas WebServices `Validation_ExportNf525`, avec de nombreux contrôles, qui passe ;
- un cas LegacyServices `DocumentSignature_SignOne`, sans contrôles, qui passe.

Le C# legacy généré contient des méthodes `[TestMethod]` actives pour ces TC99, sans attribut `[Ignore]`. Le générateur JMeter active lui aussi les cas selon `IsValidated`; `Code=99` n'est jamais interprété comme une exclusion.

Les deux TC99 en échec ont `IsSelected="true"` et `IsValidated="true"`, le commentaire `Aucune vérification`, et aucune assertion métier. Leurs requêtes comportent des périodes anciennes et le service retourne réellement HTTP 500 avec `CBR_062_0005`. JMeter attend HTTP 200 pour un cas `NC`, ce qui est cohérent avec les règles actuelles du générateur.

Conclusion :

- ne pas ignorer tous les `Code=99` ;
- ne pas ignorer tous les cas sans contrôle ;
- si ces deux scénarios ne doivent plus faire partie de la campagne, les désactiver explicitement dans la source (`IsValidated=false`) ;
- s'ils vérifient volontairement une faute, les transformer en cas d'erreur explicites avec le contrôle XML et le statut attendus.

Une règle implicite fondée sur le numéro ou le texte `Pour debug` introduirait des divergences silencieuses entre les runners.

## 4. FrenchTaxesRules TC22 : scénario indéterministe ou attente obsolète

Le JMX ne montre pas d'altération de dates sur TC22. La date applicative est `2016-04-01` dans les configurations legacy et JMeter : l'hypothèse d'une horloge différente est réfutée.

Le setup crée cependant deux lignes `DAEMON` pour le magasin 110 avec la même `DAE_DATEDEBEXEC = 2013-01-01`, l'une en statut `INP`, l'autre en statut `NOT`.

Le code métier sélectionne la dernière ligne avec :

```sql
SELECT TOP 1 ...
FROM DAEMON
WHERE DAE_ETABLISS = ...
ORDER BY DAE_DATEDEBEXEC DESC
```

Il n'existe aucun second critère de tri. Lorsque deux lignes ont exactement la même date, SQL Server peut retourner l'une ou l'autre selon le plan d'exécution ou l'index utilisé. Une différence d'environnement/base/driver peut donc révéler l'indétermination, mais le contrat SQL est déjà insuffisant.

Le résultat JMeter fournit des indices utiles :

- les prérequêtes passent ;
- le service retourne `RunStatus=Success` ;
- le post-contrôle compte un seul `NOT` au lieu de deux ;
- le nettoyage supprime trois daemons, preuve que le service en a bien créé un.

Avec une date courante fixée à 2016 et des lignes datées de 2013, l'attente simultanée « deux `NOT` » et « aucun closing rattaché au daemon `INP` devenu `NOT` » paraît également incohérente avec le comportement métier actuel. Cette conclusion doit être validée par le propriétaire fonctionnel avant de modifier le test ou la requête.

Options de correction, à arbitrer hors de cette investigation :

1. rendre le setup non ambigu en donnant des dates distinctes ;
2. ajouter un critère de tri métier stable à la requête `TOP 1` ;
3. réviser les attentes si le scénario décrit un comportement devenu obsolète.

Il n'y a pas de preuve justifiant un changement du convertisseur pour TC22.

## 5. Le build legacy ne constitue pas une baseline verte

Le build `4432288`, lancé sur le commit source `07a42172...`, est terminé avec le résultat **`canceled`**, et non `succeeded`.

Azure DevOps associe à ce build un run de 522 tests tous réussis, mais les noms examinés appartiennent à `Cegid.Retail.FrenchTaxesRules.Services.Tests` : il s'agit des tests unitaires. Ce run ne contient pas les campagnes AutoTest legacy `LegacyServices.AutoTest` ou `WebServices.AutoTest` concernées ici.

Il n'est donc pas établi que TC22 ou les TC99 aient réussi sous le runner legacy sur cette révision. Toute comparaison « legacy vert / JMeter rouge » doit être reformulée ainsi : les écarts JMeter sont observés, mais la réussite des mêmes scénarios legacy n'a pas été démontrée par les résultats publiés du build cité.

## 6. Autres constats

- Le workflow lance JMeter avec un fichier de résultats JTL et conserve également le XML brut du plan. Le XML brut contient les réponses SOAP et les messages d'assertion nécessaires au diagnostic.
- `jtl_junit_converter.py` remonte surtout `responseMessage` (`OK` ou `Internal Server Error`) et masque souvent la vraie assertion dans Azure DevOps. Ce n'est pas la cause des échecs, mais cela dégrade fortement leur lisibilité.
- Le script de prétraitement contient un défaut indépendant : `CreateMissingInputFiles` compare `IsSelected -eq "flase"` au lieu de `false`.
- Le commit migré change principalement les codes/noms de plans et les classifications `EC`/`NC`; aucune modification intentionnelle des requêtes Export incriminées n'explique l'inversion des dates.

## Plan de reprise recommandé

1. Corriger `EscapeJdbcDate` dans le dépôt source de `Cegid.Retail.AutoTest.Api` et publier une version corrigée du NuGet.
2. Ajouter les tests unitaires de conversion de dates listés plus haut.
3. Régénérer tous les JMX depuis les XML, sans retouche manuelle.
4. Rejouer Export TC08/09/10 sur une base propre et vérifier aussi le nettoyage final.
5. Faire arbitrer les deux TC99 par les propriétaires des plans, puis les désactiver explicitement ou décrire l'erreur attendue.
6. Faire arbitrer TC22 côté métier/données ; stabiliser le setup ou le `ORDER BY` avant d'en faire un signal de migration.
7. Publier ou archiver un vrai résultat legacy des mêmes scénarios si une comparaison stricte entre runners reste requise.
8. En amélioration séparée, enrichir la conversion JTL -> JUnit avec le message d'assertion et un extrait de la réponse.

## État de la livraison

- Aucun code produit, XML source ou JMX généré n'a été modifié.
- Seul ce handoff a été mis à jour.
- L'investigation a été arrêtée à la demande de l'utilisateur après consolidation des preuves disponibles.
