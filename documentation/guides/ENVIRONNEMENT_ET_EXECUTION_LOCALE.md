# Environnement, données de test et exécution locale JMeter

## Objet et statut

Ce guide regroupe les prérequis et manipulations locales décrits dans les PDF. Les versions et chemins sont des repères historiques à revalider sur la machine et la branche concernées.

## 1. Prérequis de poste

Les documents citent :

- Java 21 ; le PDF signale un problème Groovy possible avec une version supérieure ;
- Python 3.12 ;
- SQL Server ;
- un pilote JDBC Microsoft compatible avec la version de Java ;
- Git et Git LFS ;
- JMeter et le workflow JMeter du dépôt ;
- les droits d'accès au dépôt, aux packages et aux sauvegardes SQL.

La procédure d'accès BDD utilise le pilote Microsoft JDBC 12.6 comme exemple historique. Vérifier la matrice de compatibilité officielle avant téléchargement, puis copier le JAR adapté sous `JMeter/lib/`.

### Services SQL

Vérifier dans SQL Server Configuration Manager et dans les services Windows que :

- l'instance SQL ciblée est démarrée ;
- `SQL Server Browser` est démarré lorsque la découverte d'instance est nécessaire ;
- le port, le nom d'instance et le protocole correspondent à la chaîne JDBC.

Le PDF montre aussi `SQL Server Agent`, mais n'établit pas qu'il soit requis pour JMeter.

## 2. Préparer le backup

### Choisir le bon backup

- Retenir par défaut la plus petite version supportée par la branche.
- Pour mettre à jour un backup, restaurer la base, installer une version **Fix** correspondant à la version à atteindre, appliquer les modifications nécessaires puis recréer le backup.
- Vérifier que les comptes de test attendus n'ont pas été modifiés.
- Ne jamais recopier dans Git ou dans un rapport les secrets présents dans les captures historiques.

### Format et stockage

1. Restaurer le backup sur SQL Server 2019.
2. Le recréer avec compression.
3. Le placer sous `Tests/Backups/`, par exemple `AUTO_V23_00.bak`.
4. Vérifier qu'il s'agit du fichier réel et non d'un pointeur Git LFS.

### Git LFS

La procédure historique recommande, en cas de problème de transfert de gros fichiers :

```powershell
git lfs install --skip-smudge
git lfs track "**/Tests/Backups/*.bak"
git config http.version HTTP/1.1
git push
git config http.version HTTP/2
```

`--skip-smudge` évite le téléchargement implicite des objets LFS ; il faut ensuite exécuter explicitement `git lfs pull` lorsque le contenu est nécessaire. Ne pas laisser une modification globale de protocole Git sans la remettre à son état initial.

## 3. Définir les modes Fix et Cur

### Cur

Le mode Cur prend les dernières versions compatibles des dépendances, qu'elles se trouvent en staging ou en production. Le PDF associe ce comportement à `selectVersion="Both"`.

### Fix

Le mode Fix vise des versions précises ou minimales :

- dépendances directes lues dans `ExternalsToRestore_Vxx.xml`, recherchées en production ;
- dépendances de niveau supérieur lues dans `IntegratedTests/Workflow/sdkvalidators.Y2Core.xx.0.Fix.config` ;
- versions exactes conservées lorsqu'elles sont nécessaires à la reproductibilité.

Le PDF propose de générer les fichiers `cy2px` à partir d'`ExternalsToRestore.xml` grâce à un template réutilisable placé avant la tâche de remplacement des jetons. Il suggère deux paramètres, `C2ypxPath` et `ExternalToRestorePath`, et une valeur de sélection de type `externalstore`. Cette idée est une **proposition**, pas une preuve d'implémentation. Le comportement actuel des scripts est documenté dans [`FONCTIONNEMENT_TECHNIQUE.md`](FONCTIONNEMENT_TECHNIQUE.md).

### Spécificité Audit

Une note attribuée à Hervé Dallery indique que les tests Audit ont besoin du dossier `C:\ProgramData\Cegid\TimeMeasurements` pour exporter le journal d'événements. Ce prérequis reste à confirmer dans l'environnement actuel.

## 4. Préparer les fichiers `cy2px`

Récupérer sous `Tests/Config` les deux fichiers correspondant à la version majeure et au type à tester :

```text
v<major>-fix.cy2px
v<major>-cur.cy2px
```

Contrôler au minimum :

- packages et versions ;
- `tenant id="TESTS_AUTO_JMETER"` ;
- `databaseName`, cohérent avec le backup sous `Tests/Backups/` ;
- `__CONTAINER_HOST__`, remplacé par l'instance SQL ;
- rôles Y2 à déployer ;
- paramètres applicatifs (`CustomAppSettings`) nécessaires aux campagnes ;
- HTTPS et `WebAppsSettings` pour les versions concernées.

Le PDF demande aussi `Garbage.TimeToLive.Max=0` lorsqu'un worker process WP est déployé. Pour POS et SC, il demande de supprimer l'ancien dossier de configuration versionné après reprise des paramètres utiles.

Pour le local, remplacer les jetons de machine, d'instance, de base et d'identité par des valeurs locales dans une copie non commitée. Ne pas mettre de secrets dans le dépôt.

## 5. Déployer localement

1. Récupérer le dépôt et les objets Git LFS utiles.
2. Restaurer le backup correspondant au `cy2px`.
3. Copier le fichier `cy2px` adapté dans le dossier de déploiement du kit LEO.
4. Renseigner les jetons attendus : instance SQL, nom de base, machine et paramètres d'administration.
5. Exécuter le déploiement Y2.
6. Ajouter `Cegid.Retail.QualityTools.dll` et appliquer le binding redirect si le composant testé l'exige.
7. Dupliquer `Tests/Config/parameters.properties.sample` en `Tests/Config/parameters.properties`, puis renseigner uniquement les paramètres locaux nécessaires aux campagnes.
8. Lancer JMeter avec `Jmeter_Launch_GUI.cmd` pour diagnostiquer ou `Jmeter_Launch_TestCampaigns.cmd` pour exécuter les campagnes.

Spécificité POS indiquée dans la procédure historique : ajouter `encrypt=false` à `DatabaseURL` dans la configuration JDBC SQL Server, puis vérifier que les requêtes contenant une date utilisent le format `yyyyMMdd`. Cette consigne doit être validée avec les exigences de sécurité et le pilote actuels avant application.

## 6. QualityTools et binding redirect

### Choix historique du package

- Pour une version Y2 supérieure ou égale à 20, la DLL `Cegid.Retail.QualityTools.dll` est indiquée dans le package `Y2.Core.Common`.
- Pour une version inférieure à 20, le PDF la situe dans `Cegid.Retail.Y2.Core.Net.Full`.

La version du package doit correspondre à la version de `Cegid.Retail.Common.dll` déployée. Le PDF propose de lire `downloadedPackages.json` du kit LEO ou les propriétés de la DLL installée, de télécharger le package correspondant, puis de copier `Cegid.Retail.QualityTools.dll` dans le `Bin` de l'application Y2.

### Binding redirect

Le script PowerShell montré dans le PDF :

1. exige une console administrateur ;
2. reçoit la version Y2, par exemple `InstallQualityTools.ps1 "24"` ;
3. lit la version de `Cegid.Retail.Common.dll` dans le `Bin` de l'application ;
4. récupère le package correspondant ;
5. copie `Cegid.Retail.QualityTools.dll` ;
6. appelle l'outil de binding redirect du kit dans `IntegrationTests` pour mettre à jour `web.config`.

Revalider les chemins, la source du package et le script courant avant exécution.

## 7. Désactiver la compression WCF

Ce contournement n'est à appliquer que si JMeter, TestingManager ou NEOLOAD ne peut pas communiquer avec les services legacy compressés.

Dans le `web.config` serveur :

- remplacer le `customBinding` nommé `zbin` par `basicHttpBinding` pour `LegacyDispatcherService` et `LegacyDispatcherServiceTran` ;
- supprimer `bindingConfiguration="zbin"` sur les endpoints concernés.

Impact documenté : ce changement rend Y2 inutilisable tant que le client n'est pas adapté. Il faut aussi supprimer le bloc `<system.serviceModel>` du fichier de configuration .NET du SmartClient (`eBOSS.exe.config` ou `eFO55.exe.config`, selon l'installation). Sauvegarder les fichiers et prévoir le retour arrière avant toute modification.

## 8. Contrôles après déploiement

- La base attendue est restaurée et accessible depuis la machine JMeter.
- Les pilotes JDBC sont chargés sans erreur.
- Les services Y2 et Authentication Server répondent sur les protocoles attendus.
- Les packages Fix/Cur et les rôles déployés correspondent au `cy2px`.
- Les campagnes utilisent un fichier `parameters.properties` local non commité.
- Les résultats locaux sont comparés au pipeline avec les mêmes données, versions et paramètres.

## Sources PDF

- [`faireTournerJmxLocalement.pdf`](../source-material/faireTournerJmxLocalement.pdf).
- [`prerequisAccesBdd.pdf`](../source-material/prerequisAccesBdd.pdf).
- [`majBackupTests.pdf`](../source-material/majBackupTests.pdf).
- [`definirFixEtCur.pdf`](../source-material/definirFixEtCur.pdf).
- [`QualityToolsBindingRedirect.pdf`](../source-material/QualityToolsBindingRedirect.pdf).
- [`desactiverCompressionWcf.pdf`](../source-material/desactiverCompressionWcf.pdf).
- [`procédureMigration.pdf`](../source-material/procédureMigration.pdf).
