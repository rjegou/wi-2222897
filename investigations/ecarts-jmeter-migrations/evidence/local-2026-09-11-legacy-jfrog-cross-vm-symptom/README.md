# Complément de portée — symptôme JFrog Legacy sur PG2 et PG3

## Provenance

- Date d'intégration : 2026-09-11.
- Source : complément fourni dans la demande utilisateur du 2026-09-11.
- Systèmes concernés : VM Legacy `Y2-TSTAUTOXXPG2` et `Y2-TSTAUTOXXPG3`.
- Objets cités : `Y2_Plugins_FrenchTaxesRules` sur PG2 et `Y2_Plugins_InventoryTracking_V5` sur PG3 ; script commun `Artifactory_fct.ps1`.
- Méthode : intégration documentaire, sans collecte nouvelle sur Azure DevOps, les VM ou JFrog.
- Fraîcheur : rapporté le 2026-09-11, non revérifié indépendamment.

## Complément intégré

Le même symptôme est rapporté sur PG3 avec `Y2_Plugins_InventoryTracking_V5` : le log s'arrête
sur `executeWorkflowPlugin`, sans trace de `executeWF_PluginOneCore`, `executeIntegrationTest`
ou `StartWorkflowAsync`. Le XML NAnt associé au run existe mais est rapporté à `0` octet.

PG2 et PG3 utilisent le même `Artifactory_fct.ps1`, avec un SHA-256 rapporté identique. La valeur
du hash n'est pas fournie dans le complément et n'est donc pas recopiée ici.

## Limites

Cette fiche ne contient ni logs bruts, ni XML NAnt, ni script, ni hash vérifiable. Elle ne prouve
pas la cause exacte, le contenu de la réponse JFrog, un timeout effectif ou l'absence complète de
processus descendant. Elle ne justifie aucune modification de code, de VM, de pipeline ou de secret.
