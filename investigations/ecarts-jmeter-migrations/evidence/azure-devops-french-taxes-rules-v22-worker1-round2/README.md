# Azure DevOps read-only — FrenchTaxesRules V22 — Worker 1 round 2

Date : 2026-09-07 (Europe/Paris). Collecte lecture seule ; aucun pipeline lancé.

## Méthode et diagnostic d'accès

La méthode primaire Worker 2 round2 a été rejouée avec :

- AZURE_CONFIG_DIR=.azconfig-worker1-r2 dans le workspace ;
- extension azure-devops 1.0.8 ;
- PAT lu depuis C:\\Users\\jegour\\OneDrive - CEGID\\Documents\\azureToken.txt, uniquement dans le processus ;
- PYTHONIOENCODING=utf-8 pour les réponses CLI.

Avant isolation, Azure CLI 2.80.0 échoue sur PermissionError: C:\\Users\\jegour\\.azure\\azureProfile.json. L'installation/lecture de l'extension sans AZURE_CONFIG_DIR reproduit le même blocage. Avec le répertoire isolé, l'extension s'installe et les appels REST/CLI fonctionnent.

Aucun appel n'a renvoyé HTTP 401, HTTP 403 ou erreur TLS pendant la collecte réussie. Une première commande timeline a échoué avec '-o était inattendu' après une requête JMESPath mal formée ; la même ressource avec --output json a réussi. Ce n'est pas un échec d'authentification.

## Build et définition V22

**FACT** — az pipelines build show :

- build 4429167, numéro 6.478, définition FrenchTaxesRules CI id 2054 ;
- dépôt Y2_Plugins_FrenchTaxesRules ;
- branche refs/heads/FrenchTaxesRules_Migration_AutoTest_Jmeter_On_releases/V5 ;
- commit 2d826b8fd19ecb4d7200f574414efb7583de8ed2 ;
- état completed, résultat failed ;
- pool/queue Azure Pipelines, id 591.

**FACT** — la timeline build 4429167 répond avec 462 records, dont 13 failed et 66 skipped. Build V22 est succeeded; TI Jmeter V22-Cur est succeeded; TI Jmeter V22-Fix est succeededWithIssues. Les erreurs V23 visibles dans la même timeline ne doivent pas être attribuées à V22.

**FACT** — le YAML /azure-pipelines.yml lu via l'API Git au commit exact répond HTTP 200, 15 855 octets, SHA-256 B4CCCFB0BA49085D66B5F2C96BA687B93752EBFBFB0B7F138CBDC3E48AFE7DB8. Il déclare versionsToTest: 21,22,23, typesToTest: Cur,Fix, campaignsToTest: LegacyServices,WebServices, et pathToExternalsToRestoreFile pour V22.

## Templates et variables

**FACT** — le YAML déclare les dépôts externes Pipelines_Templates, Y2_Tools_Jmeter_Workflow et Y2_Tools_PlatformDeploy, puis consomme notamment les templates task-deploy-in-containerized-job.v2.yml, task-install-y2-test-tools.v1.yml et task-run-campaign.v1.yml.

**FACT** — aucun ref explicite n'est présent pour ces trois dépôts dans le YAML au commit du build. Les commits réellement résolus/consommés par le run restent UNKNOWN ; les noms de templates ne constituent pas une preuve de commit.

**FACT** — les groupes référencés par le YAML sont AzSubInfos_CloudDevPub (id 3182, Vsts), AzSubInfos_CloudDevPriv (id 1122, Vsts), RetailJfrogVariables (id 471, Vsts) et TestJmeterVariables (id 1159, Vsts). Seuls noms/types/identifiants et noms de variables ont été lus ; aucune valeur n'a été affichée ou conservée.

## Agents

**FACT** — les builds 4429167 et 4434070 utilisent la queue Azure Pipelines id 591. La timeline 4429167 montre des workers historiques vm-alm-agent-07-A, vm-alm-agent-02-A, vm-alm-agent-06-A et workers hébergés Azure Pipelines <n>. La commande d'inventaire des agents statiques du pool hébergé renvoie une liste vide ; la disponibilité future d'un agent précis n'est pas démontrée.

## Conclusion

**FACT** — le blocage précédent était la configuration CLI globale, pas un refus Azure DevOps : AZURE_CONFIG_DIR isolé suffit ici à permettre la lecture avec le PAT autorisé.

**INFERENCE** — une collecte read-only plus large est techniquement possible dans ce processus, mais elle ne résout pas le manque de commits exacts des templates : il faut une timeline/export résolu ou une définition de pipeline qui expose ces versions.

**UNKNOWN** — commits réellement consommés de Pipelines_Templates, Y2_Tools_Jmeter_Workflow, Y2_Tools_PlatformDeploy, disponibilité d'un agent futur compatible, et toute décision de queue. Aucun pipeline n'a été lancé.

