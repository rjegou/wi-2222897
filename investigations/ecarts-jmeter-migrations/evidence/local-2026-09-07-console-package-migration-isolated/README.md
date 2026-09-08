# Console package -> migration isolée

Date : 2026-09-07.

## Portée et isolation

Cette collecte utilise uniquement un staging temporaire dédié :
`C:\Users\jegour\AppData\Local\Temp\wi2222897-console-package-migration-20260907-b`.

Aucun dépôt Git, cache partagé, package feed, Artifactory/JFrog, pipeline Azure DevOps, SQL Server, HTTP, backup, secret ou publication n'a été utilisé. Les worktrees ont été contrôlés avant l'essai : API RJE modifiée/non commitée, Console RJE propre, migration propre. Le cache canonique `worktrees/Migration_Jmeter_RJE_Sandbox/migration-tools/Cegid.Retail.AutoTest.Console.nupkg` n'a pas été utilisé comme destination ni modifié.

## Package fabriqué

NuGet utilisé : `6.12.2`.

Le package local distinct est `Cegid.Retail.AutoTest.Console` version `2.0.42-cleanxpath.20260907`. Il a été fabriqué à partir du runtime Console 2.0.42 extrait dans `evidence/packages-extracted/console-2.0.42-current/tools`, avec remplacement de l'API par la DLL corrigée issue de `evidence/local-2026-09-06-api-build-net452-complete/obj/Debug/`. Le nuspec de l'essai est conservé dans `isolated-console-package.nuspec`.

FACT : le nupkg existe et son SHA-512 est `C0194F20A219926B5302DA4D4C8890920058D5D65B3BBCF926BEC0AE6122081CC34404179E4515E8CE1336EA18FF0A87C647376657B2A227040D5193106236A2`.

FACT : le contenu extrait contient `tools/Cegid.Retail.AutoTest.Console.exe` (assembly `2.0.42.0`, SHA-256 `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`) et `tools/Cegid.Retail.AutoTest.Api.dll` (assembly `1.1.46.0`, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`). Ce hash API est celui de la DLL corrigée réellement injectée dans le package; il est distinct du cache Console 2.0.41 (`334155e6c2e4291dbe29694a2bbb067409eca78c925a75e530d1f7cedaf2743b`) et du runtime Console 2.0.42 non corrigé (`21A4AC70059F1B0DA716F0AD24E5CAB8AE92B679DCDD5B17034C2F02E21D3E98`).

La DLL `22D85CAA8CA61F30EFADBD611BB584042575A64EB2D78ED3A3637EF1D02D81CC`, mentionnée dans la preuve FixSqlUnicodeValue, est une autre compilation corrigée issue d'un autre staging/scénario. Elle ne doit pas être comparée comme si elle était le même binaire que `51FB...` : les deux artefacts ont des périmètres de compilation différents.

## Consommation par les scripts réels de migration

Un `PublishedSharedTools` temporaire a été créé avec un `packages.config` déclarant exactement `2.0.42-cleanxpath.20260907`, le nupkg dans le répertoire package et son extraction sous `Cegid.Retail.AutoTest.Console`.

FACT : `worktrees/Migration_Jmeter_RJE_Sandbox/migration-tools/checkPackage.ps1` a été exécuté avec ce staging et un chemin de cache également temporaire. Il a retourné `0`, a reconnu `Bonne version deja installee : 2.0.42-cleanxpath.20260907`, et a consigné une copie dans le cache temporaire. La sélection de version et la présence de l'exécutable ont donc été contrôlées par le script réel, sans modifier le cache partagé.

La sortie brute de ce contrôle est conservée dans `logs/checkPackage.log`.

FACT : l'exécutable réellement lancé était celui extrait du package : `...\PublishedSharedTools\Cegid.Retail.AutoTest.Console\tools\Cegid.Retail.AutoTest.Console.exe`. La commande a d'abord retourné `-1` avec `DirectoryNotFoundException` parce que le générateur exigeait `migration-output\IntegratedTests\AutoTest\Data\campaign\TestPlans\OutputFiles`. Après création de cette structure inerte dans le staging, la même commande a retourné `0` et produit six JMX (`001-plan01.jmx` à `006-plan06.jmx`). Les journaux sont `logs/generation-first-attempt.log` et `logs/generation-rerun.log`; les JMX sont dans `generated-jmx/`.

## Verdict et limites

FACT : cette collecte prouve le contenu d'un nupkg local, son hash API exact, sa sélection par `checkPackage.ps1` et l'exécution Console→JMX avec cette chaîne package.

INFERENCE : la propagation package est techniquement réalisable localement, mais elle n'est pas encore une propagation officielle : aucun package n'a été publié et `consoleWorkflowVersions.json` canonique n'a pas été modifié.

UNKNOWN : compilation complète de Console depuis le source avec dépendances alignées, publication/consommation Azure DevOps, orchestration complète `step_00`/`step_01`, sélection de campagnes par un plugin réel, et réussite métier. La génération n'a exécuté ni SQL, ni HTTP, ni JMeter.

## Séparation avec le correctif SOAP round13

Le hash API `51FB31...` documenté dans ce package est celui de l’artefact Console local précédent. Le correctif générateur SOAP round13 est un autre artefact, documenté sous `evidence/local-2026-09-07-soap-namespace-aware-round13/`, SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`. Ce package ne prouve donc pas la présence du correctif SOAP round13.
