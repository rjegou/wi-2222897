# Procédure de migration AutoTest Legacy vers JMeter

## Objet et statut

Ce document réorganise la procédure humaine décrite dans `procédureMigration.pdf` et `migrationAutotests.pdf`. Il s'agit d'un guide historique : pour le WI 2222897, appliquer d'abord les règles par version et les images Docker décrites dans [`PBI_2222897_synthese_visio_Ludo.md`](../context/PBI_2222897_synthese_visio_Ludo.md), puis vérifier le comportement réel dans [`FONCTIONNEMENT_TECHNIQUE.md`](FONCTIONNEMENT_TECHNIQUE.md).

## Vue d'ensemble

```text
Cadrer la branche et prévenir l'équipe
  -> créer la branche de migration
  -> convertir les plans legacy en JMX
  -> préparer le backup et les fichiers Cur/Fix
  -> transformer le pipeline
  -> exécuter et comparer les résultats
  -> retirer les références legacy
  -> créer et faire valider la PR
  -> nettoyer l'infrastructure legacy après validation
```

## 1. Cadrer la migration

Avant de modifier un dépôt :

1. identifier le plugin, la branche source et les versions Y2 réellement supportées ;
2. vérifier l'historique des tests et les rapports legacy ;
3. vérifier que les échecs existants relèvent bien du plugin et que les résultats couvrent toutes les versions attendues ;
4. prévenir l'équipe du début de la migration et demander de ne pas modifier les tests pendant la période de conversion ;
5. relever le propriétaire/reviewer de la PR et le responsable fonctionnel des campagnes.

La source PDF de 2024 répartissait les plugins sur quatre VM :

| VM | Plugins | Branches |
|---|---:|---:|
| `Y2-TSTAUTOXXPG1` | 3 | 14 |
| `Y2-TSTAUTOXXPG2` | 5 | 21 |
| `Y2-TSTAUTOXXPG3` | 10 | 43 |
| `Y2-TSTAUTOXXPG4` | 12 | 48 |

Le même instantané affiche 32 plugins cibles, 29 migrés et une proportion de 91 %, en excluant du tableau les éléments `Done` par un filtre Excel actif. Ces chiffres sont historiques, pas un inventaire courant. Le suivi à utiliser pour le WI est `repos_to_migrate_updated.csv` et doit lui-même être revalidé contre les dépôts.

### Convention historique de branche

La procédure proposait :

```text
features/<identifiant>_Migration_AutoTest_Jmeter_On_<branche-source>
```

Le nom effectif doit respecter les règles actuelles du dépôt et du WI.

## 2. Préparer l'outillage

La procédure historique demandait de référencer :

- `Cegid.Retail.AutoTest.Console` pour convertir les plans legacy ;
- `Y2.Tools.Jmeter.Workflow` pour exécuter les campagnes JMeter ;
- un batch de lancement adapté aux campagnes et à leurs chemins ;
- `BeforeMigration.ps1` pour les corrections préalables ;
- `PostMigration.ps1` et un éventuel `bugfix-payload.csv` pour des corrections ciblées après génération.

Les versions `2.0.41` pour la console et `3.0.175` pour le workflow apparaissent dans la mise à jour du 2025-01-15. Elles sont **historiques** : les versions courantes proviennent de `migration-tools/consoleWorkflowVersions.json`.

Pour Y2 Core, les scripts étaient copiés sous `Dotnet/`; pour les plugins, ils étaient copiés à la racine du dépôt.

### Corrections pilotées par CSV

Le PDF décrit un fichier UTF-8, séparé par `LF`, dont chaque valeur est entourée de doubles quotes. Les colonnes sont :

| Colonne | Rôle |
|---|---|
| `CampaignName` | répertoire de campagne, par exemple `LegacyServices`, `MobilityServices` ou `WebServices` |
| `TestPlan` | première colonne du rapport CSV de la campagne |
| `TestCase` | deuxième colonne du rapport CSV |
| `Operation` | troisième colonne du rapport CSV |
| `SearchPayload` | chaîne recherchée dans le payload du JMX |
| `FixedPayload` | chaîne de remplacement obtenue après correction dans JMeter |

Cette mécanique est une correction explicite, traçable et ciblée. Elle ne justifie pas une réécriture globale des JMX.

## 3. Convertir les tests

1. Mettre à jour `.gitignore` pour exclure les résultats JMeter et les fichiers de paramètres locaux :

   ```gitignore
   # Tests Jmeter
   Results
   Tests/**/Results
   Tests/**/parameters.properties
   ```

   Pour Y2 Core, préfixer ces chemins par `Dotnet/`.

2. Autoriser explicitement le suivi des backups sous Git LFS si le dépôt les ignore déjà.
3. Mettre à jour les lanceurs `Jmeter_Launch_GUI.cmd` et `Jmeter_Launch_TestCampaigns.cmd`.
4. Lancer le batch de migration depuis la racine du dépôt.
5. Contrôler la console et les fichiers produits. En cas d'erreur, corriger la source ou la règle de conversion, supprimer la campagne JMeter générée, puis relancer.
6. Ne pas livrer dans `IntegratedTests` les modifications temporaires utilisées seulement pour rendre les XML convertibles si elles ne font pas partie de la correction produit attendue.

La procédure historique suggère un commit intermédiaire `migration autotests legacy to jmeter`. Le script actuel peut effectuer plusieurs commits et pushs ; vérifier [`FONCTIONNEMENT_TECHNIQUE.md`](FONCTIONNEMENT_TECHNIQUE.md) avant exécution.

## 4. Préparer les données et les déploiements

### Backup SQL

- Utiliser le backup de la plus petite version supportée par la branche, sauf preuve qu'un jeu distinct est nécessaire.
- Restaurer et convertir le backup au format SQL Server 2019, puis le recompresser.
- Stocker le résultat sous `Tests/Backups/` avec un nom du type `AUTO_V<major>_00.bak`.
- Utiliser Git LFS et vérifier que le dépôt contient le binaire, pas seulement un pointeur LFS.
- Vérifier les comptes de test attendus sans recopier de secrets dans le dépôt ni dans cette documentation.

Voir [`ENVIRONNEMENT_ET_EXECUTION_LOCALE.md`](ENVIRONNEMENT_ET_EXECUTION_LOCALE.md) pour les détails et les précautions Git LFS.

### Déploiements Fix et Cur

Créer deux fichiers `cy2px` par version majeure :

```text
Tests/Config/v<major>-fix.cy2px
Tests/Config/v<major>-cur.cy2px
```

- **Fix** valide le plugin avec les dépendances minimales ou précisément attendues.
- **Cur** valide le plugin avec les dernières versions compatibles des dépendances.

Le fichier doit définir au minimum les packages, la base à restaurer, les paramètres applicatifs nécessaires et les rôles à déployer. À partir de V23, la procédure historique demande un Authentication Server en HTTPS et un bloc `WebAppsSettings` sur `Cegid Retail HTTPS Site`.

## 5. Transformer le pipeline

La procédure historique ajoute :

- les paramètres `pipelineDevMode`, `versionsToTest`, `typesToTest` et `campaignsToTest` ;
- les groupes de variables Azure/JFrog/JMeter ;
- les dépôts de templates de déploiement et de workflow JMeter ;
- un conteneur Windows JMeter ;
- un stage par version et type Fix/Cur ;
- l'archivage des résultats, journaux de campagne et logs applicatifs ;
- les dépendances des stages de promotion ;
- une note de release et une section `Tests` dans le README du plugin.

Elle retire la génération et l'exécution des tests AutoTest legacy du pipeline migré. Le script actuel automatise ces transformations et impose des images différentes pour V26/master et les autres branches : ne pas reprendre littéralement l'ancien exemple d'image présent dans le PDF.

## 6. Exécuter et valider

Pour une branche autorisant l'exécution :

1. lancer le pipeline avec `pipelineDevMode=true` ;
2. vérifier les rapports par version, type et campagne ;
3. vérifier les logs de déploiement et d'exécution ;
4. comparer chaque échec avec le même scénario legacy, sur des données et dépendances comparables ;
5. corriger le `cy2px` si l'échec concerne le déploiement, les packages, le tenant ou les paramètres ;
6. corriger le plan ou l'outil uniquement si la cause est démontrée ;
7. relancer les campagnes concernées sur une base propre.

Un pipeline JMeter rouge n'est pas, à lui seul, la preuve d'un écart de migration. La méthode de comparaison et les erreurs connues sont détaillées dans [`DEPANNAGE_JMETER.md`](DEPANNAGE_JMETER.md).

## 7. Retirer le legacy et créer la PR

Après validation des campagnes :

1. supprimer les projets de tests legacy uniquement s'ils ne contiennent aucun autre type de test utile ;
2. retirer les références correspondantes de la solution ;
3. supprimer le répertoire AutoTest historique ciblé ;
4. vérifier que les projets WebServices et LegacyServices attendus ont bien été retirés ;
5. retirer les outils/packages de génération legacy devenus inutiles ;
6. committer et pousser le déréférencement ;
7. créer la PR seulement lorsque les résultats sont conformes aux règles du WI ;
8. faire valider la PR par le binôme puis par un responsable de l'équipe propriétaire.

Pour les versions V21 et inférieures, le WI 2222897 demande une PR avec copie ACR et stage JMeter commentés. Pour les versions supérieures à V21, la PR n'est créée qu'après exécution concluante du build et des tests.

## 8. Informer l'équipe

### Message de début

Objet suggéré : `Début de la migration des tests automatiques pour <plugin> sur <branche>`.

Contenu minimal :

- plugin et branche concernés ;
- début de la conversion legacy vers JMeter ;
- demande de ne pas modifier les tests pendant la migration ;
- changements prévus : conversion, backup SQL 2019, pipeline JMeter, retrait du legacy ;
- impacts développeurs/QA : Git LFS, ligne de commande, SQL Server 2019 et JMeter.

### Message de fin

Objet suggéré : `Fin de la migration des tests automatiques pour <plugin> sur <branche>`.

Reprendre le périmètre effectivement réalisé, fournir le lien de PR et préciser les erreurs restantes ou arbitrages nécessaires. Pour le WI 2222897, notifier Ludo et Lydie après collecte des erreurs afin qu'ils puissent revoir les PBI de correction par plugin/branche.

## 9. Nettoyage post-PR

Le nettoyage des bases, backups, rapports, archives TRX, configurations de VM et entrées de dashboard est une opération destructive distincte de la migration. Ne l'exécuter qu'après fusion/validation, sur des cibles explicitement vérifiées, avec une autorisation dédiée. Aucun identifiant ou mot de passe visible dans le PDF source n'est repris ici.

Les emplacements historiques cités par le PDF sont :

| Emplacement | Contenu à identifier avant toute action |
|---|---|
| `D:\CegidUtils\CegidIntegrationTests\override` | dossiers de plugins/versions exécutés par le legacy |
| `C:\inetpub\wwwroot\integrationTestsReports` | rapports sous `Retail VXX.XX Integration Tests` |
| `\\cbr-tstauto-sql\Archives\TRX\CBR_AUTO_TT_XX.XX` | archives TRX par version |
| `\\cbr-tstauto-sql\Outils\PublishTRX\Dashboard.SourceItems.xml` | entrées publiées dans le dashboard |
| `\\cbr-tstauto-sql\BACKUP\TstAuto` et archives associées | backups legacy |

La fiche [`../../investigations/ecarts-jmeter-migrations/references/legacy_test_vm_technical_cheatsheet.md`](../../investigations/ecarts-jmeter-migrations/references/legacy_test_vm_technical_cheatsheet.md) est le point d'entrée pour une collecte en lecture seule. La présence d'un chemin dans le PDF ne prouve ni que l'artefact existe encore, ni qu'il appartient au build étudié.

## Sources PDF

- [`procédureMigration.pdf`](../source-material/procédureMigration.pdf), 13 pages.
- [`migrationAutotests.pdf`](../source-material/migrationAutotests.pdf), 2 pages dont une blanche.
- [`definirFixEtCur.pdf`](../source-material/definirFixEtCur.pdf), 2 pages dont une blanche.
