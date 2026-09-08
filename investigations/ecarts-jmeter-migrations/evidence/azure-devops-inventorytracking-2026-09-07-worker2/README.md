# Collecte Azure DevOps — InventoryTracking/master — worker 2

Date de collecte : 2026-09-07 (Europe/Paris)

## Source et méthode

- Système : Azure DevOps `https://dev.azure.com/cegid`, projet `Retail`.
- Authentification : PAT local autorisé, lu uniquement en mémoire depuis `C:\Users\jegour\OneDrive - CEGID\Documents\azureToken.txt`, utilisé par `AZURE_DEVOPS_EXT_PAT`; aucune valeur de secret n'est conservée.
- Méthode : Azure CLI `az pipelines` / `az devops invoke`, lecture seule; aucune pipeline lancée, aucune écriture distante.
- Définition : `2072`, `InventoryTracking CI`, dépôt `Y2_Plugins_InventoryTracking`, YAML `/azure-pipelines.yml`, branche par défaut `refs/heads/master`.

## Résultat borné

**FACT** — Le build `4434070` (`7.73`) est terminé en échec le 2026-09-04. Il ne consomme pas directement `refs/heads/master` : `sourceBranch=refs/heads/InventoryTracking_Migration_AutoTest_Jmeter_On_master`, commit `4de185bb132cfbfb50643b6b53d6feb85508f4e2`.

**FACT** — Sa timeline prouve que `Ensure_Docker_Image_Up_To_Date` et les contrôles ACR/image réussissent, puis `Build V26` échoue au task `dotNet-build: Build solution **\\*.sln` (`VSBuild`, log 51). Le log contient `MSB3245` pour la référence absente `Cegid.Retail.XmlDiff`, puis quatre erreurs `CS0103` sur `XmlDiff` dans `Cegid.Retail.InventoryTracking.Services.Tests\GlobalSettings\GlobalSettingsDtoConvertersUnitTest.cs` (lignes 88, 159, 219, 293), MSBuild code 1.

**FACT** — Dans la même timeline, le stage `TI JMeter V26` est évalué faux (`and(False, ...)`) et `TI Jmeter V26-Cur` / `TI Jmeter V26-Fix` sont `skipped`; aucune campagne JMeter n'a donc été exécutée dans ce build.

**FACT** — Le YAML exact au commit de migration déclare l'image `cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, le conteneur `acr_y2jmeter_test`, les paramètres V26/Cur/Fix/WebServices, et les stages `TI_Jmeter_V26` avec jobs Cur/Fix. Il référence des templates externes `Pipelines_Templates`, `Y2_Tools_Jmeter_Workflow` et `Y2_Tools_PlatformDeploy` sans ref de commit explicite.

**FACT** — Le master officiel possède des builds postérieurs : `4435986` (`7.74`, 2026-09-05, commit `20aa528945ac33ba94598222b66fa3071c7e87b9`) est `succeeded`; `4402750` (`7.69`, 2026-09-06, même commit) est en échec uniquement dans `Promote` sur `ManualValidation`. Dans `4435986`, `Build V26` et `TestAutos (on Premise)` réussissent; `Promote` est ignoré car le run est planifié.

**FACT** — Le YAML exact du master au commit `20aa528...` ne déclare ni `resources.containers` ni stage `TI_Jmeter_V26`; son pipeline est l'ancien CI build/publish/TestAutos. Le succès `4435986` ne prouve donc pas la réussite de la migration JMeter.

## Qualification

- Cause prouvée du fail `4434070` : dépendance de compilation `Cegid.Retail.XmlDiff` absente/non résolue dans le build des tests, provoquant les quatre références `XmlDiff` non définies.
- Hypothèse non prouvée : l'image ACR ou sa sélection serait la cause. Les tâches de vérification ACR/image réussissent avant l'échec; elles ne sont pas discriminantes pour le fail observé.
- État courant de `master` : le dernier master lu (`4435986`) passe Build V26 et TestAutos, mais ce n'est pas une preuve de pipeline JMeter. La persistance du défaut dans la branche de migration doit rester **UNKNOWN** sans nouveau run de cette branche ou lecture de ses derniers commits.

## Recommandation à faible impact

Ne pas relancer Azure DevOps sans nécessité. Pour fermer le diagnostic migration, lire le commit courant de `InventoryTracking_Migration_AutoTest_Jmeter_On_master`, résoudre les templates externes aux commits réellement consommés, puis comparer la disponibilité de `Cegid.Retail.XmlDiff` dans `ExternalsToRestore_V26.xml` / packages au commit exact. Si une validation est autorisée ensuite, un run ciblé de cette branche avec V26/WebServices est le test discriminant; aucun lancement n'a été effectué ici.

## Limites

- Les logs et YAML complets ne sont pas recopiés dans cette collecte afin de limiter les duplications; leurs identifiants, URLs et empreintes sont dans `MANIFEST.csv` et `SHA256SUMS.txt`.
- Les templates référencés par alias de dépôt n'ont pas de ref commit prouvée dans le YAML consommé; leur contenu exact reste **UNKNOWN**.
- `Technical` dans la synthèse PBI n'est pas utilisé comme preuve d'exécution ou de causalité.
