# Récupération des logs de tests Legacy — synthèse

## Contexte

Investigation réalisée sur le run Azure DevOps `4459782` pour :

- plugin : `Y2_Plugins_FrenchTaxesRules`
- branche : `master`
- version : `10.87`
- VM Legacy : `Y2-TSTAUTOXXPG2`
- label : `test.10.87-20260911_073620`

L’objectif était de récupérer les résultats Legacy permettant une comparaison avec les tests JMeter : TRX, `.mstest.log`, XML de rapport et résultat final.

## Méthode de récupération

La VM Legacy est accessible depuis le poste utilisateur via les partages administratifs SMB :

`\\Y2-TSTAUTOXXPG2\D$`  
`\\Y2-TSTAUTOXXPG2\C$`

Il faut privilégier ces chemins UNC directs. Les lecteurs PowerShell temporaires de type `LEGACY:` peuvent se déconnecter silencieusement et produire de faux négatifs.

Les principaux emplacements utiles identifiés sont :

- workspace du run :  
  `D:\Temp\TempoAutoTest\<GUID>`
- logs du host :  
  `D:\CegidUtils\CegidIntegrationTests\integrationTestsHost-ip00.log`
- log wrapper :  
  `D:\CegidUtils\CegidIntegrationTests\integrationTestsHost-nw00.log`
- XML NAnt :  
  `C:\Users\SvcTestAutoRetail\AppData\Roaming\CegidIntegrationTests\<project>_<label>.xml`
- rapports normalement archivés dans :  
  `D:\wwwroot\integrationTestsReports`

## Résultat de l’investigation

Pour le run `4459782` :

- le workflow Legacy a bien été reçu ;
- `execute.plugin` a été atteint ;
- `executeWorkflowPlugin` a bien été lancé ;
- `executeWF_PluginOneCore` n’a jamais été atteint ;
- `executeIntegrationTest` n’a jamais été atteint ;
- aucun appel `StartWorkflowAsync` n’a été observé ;
- MSTest n’a donc jamais démarré.

Le dossier `IntegrationTests` du workspace existe mais est vide.

Aucun fichier `.trx`, `.mstest.log`, `.log`, `.xml`, `report` ou `result` lié aux tests n’a été trouvé dans le workspace.

Le XML NAnt du run existe mais reste à `0` octet.

Le log principal s’arrête exactement sur le lancement de :

`executeWorkflowPlugin`

Aucune ligne n’est écrite ensuite.

Conclusion :

`TEST_EXECUTION_STARTED = NO`  
`TRX_FOUND = NO`  
`MSTEST_LOG_FOUND = NO`  
`LEGACY_TEST_RESULT = NO TEST EXECUTED`

## Problème observé

`executeWorkflowPlugin` interroge JFrog avant de lancer les tests.

La fonction Legacy appelle :

`Invoke-WebRequest`

sans `-UseBasicParsing`.

Un test contrôlé réalisé depuis la VM a montré que :

- avec `-UseBasicParsing`, l’URL JFrog répond correctement en HTTP `200` en environ `510 ms` ;
- avec l’appel Legacy sans `-UseBasicParsing`, PowerShell 5.1 reste bloqué après l’appel.

Le vrai processus PowerShell du run est également resté longtemps bloqué à cet endroit.

Cela indique que le problème n’est probablement pas un défaut réseau ni un problème de ressource JFrog.

Un problème de token JFrog est également très peu probable puisque la même URL et la même authentification aboutissent à un HTTP `200` lorsque `-UseBasicParsing` est utilisé.

## Cause la plus probable

La cause la plus probable est donc :

`executeWorkflowPlugin`
→ appel JFrog
→ `Invoke-WebRequest` PowerShell 5.1 sans `-UseBasicParsing`
→ réponse HTTP reçue
→ blocage lors du traitement local de la réponse
→ `executeWF_PluginOneCore` jamais atteint
→ `executeIntegrationTest` jamais lancé
→ aucun test Legacy exécuté.

Le rôle exact du moteur de parsing historique d’Internet Explorer n’est pas prouvé à 100 %, mais le comportement a été reproduit de manière suffisamment forte pour cibler cette zone.

## Solution envisagée

Modifier la fonction utilisée pour les appels JFrog afin d’utiliser :

`Invoke-WebRequest ... -UseBasicParsing`

Il serait également pertinent d’ajouter un timeout explicite afin qu’un appel externe ne puisse plus bloquer indéfiniment un run Legacy.

Après modification, la validation minimale attendue est :

1. vérifier que l’appel JFrog retourne rapidement ;
2. confirmer que `executeWF_PluginOneCore` est atteint ;
3. confirmer que `executeIntegrationTest` puis `StartWorkflowAsync` apparaissent dans les logs ;
4. vérifier la création effective des TRX / `.mstest.log` / rapports Legacy.

## Point sécurité

Le script Legacy contient actuellement un secret JFrog en clair. Ce secret ayant été exposé pendant l’investigation, il doit être considéré comme compromis et faire l’objet d’une rotation/révocation indépendamment du correctif technique.
