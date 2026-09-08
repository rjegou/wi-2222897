# Chaîne de génération migration isolée — Round 9

Date : 2026-09-07.

## Portée

Le test utilise uniquement le staging temporaire `C:\Users\jegour\AppData\Local\Temp\wi2222897-r9-console-isolated-20260907`, les six XML indexés de `local-2026-09-06-console-quick-diagnosis/verified-original/fixtures/`, une copie locale du runtime Console 2.0.42 et une copie locale de la DLL API corrigée issue de `local-2026-09-06-api-build-net452-complete/obj/Debug/`.

Commande réelle exercée :

```text
Cegid.Retail.AutoTest.Console.exe --tstj=<staging>\fixtures\campaign.xml --dstFolder=<staging>\out
```

Le processus réel a chargé `Parameters.xml`, traité `campaign.xml`, puis produit `001-plan01.jmx` à `006-plan06.jmx`. Code de sortie : `0`.

## Frontières et non-effets

- `step_xxxxxxxxxxxxxxxx_00to05b.ps1`, `step_00_miseEnPlaceRepo.ps1`, `step_02_convertBak.ps1`, `commitPush.ps1` et tout orchestrateur global n'ont pas été exécutés.
- Aucun dépôt Git, SQL Server, réseau, Artifactory/JFrog, pipeline, commit, push, PR, backup ou package canonique n'a été utilisé.
- Le staging n'était pas un dépôt Git et ne contenait aucun backup ni credential.
- Le runtime Console/API a été copié localement; l'API corrigée a remplacé l'API présente dans la copie runtime. Les fichiers canoniques n'ont pas été modifiés.

## Portion prouvée

`step_00_miseEnPlaceRepo.ps1:220-240` génère les lignes `AutoTestConsole --tstj=... --dstFolder=...` dans un `Testautos2Jmeter.bat` de plugin. `Testautos2Jmeter.bat:9-46` vérifie/installe le package et exécute `BeforeMigration.ps1`; la copie du fichier de travail s'arrête à `:49` dans le snapshot local, les lignes Console sont ajoutées ultérieurement par `step_00`.

Le test Round 9 commence au point Console avec des XML déjà indexés. Il prouve la portion `Console + API corrigée + XML -> JMX`, pas l'orchestration complète, la sélection des campagnes par `step_00`, le package NuGet fabriqué, ni la préparation SQL/backup.

## Résultat et limite

`FACT` — Console officielle 2.0.42 avec DLL API corrigée locale : 6 JMX produits, code 0.

`FACT` — une première tentative dans le même staging a refusé la génération avec `DirectoryNotFoundException` sur `out\IntegratedTests\AutoTest\Data\campaign\TestPlans\OutputFiles`; la création de ce répertoire local attendu a débloqué la génération.

`UNKNOWN` — propagation via package NuGet, sélection exacte par l'orchestrateur, effets d'un vrai plugin/backup et génération métier complète.

Voir `manifest.tsv` et `console-rerun.log` pour les empreintes et la sortie non sensible.
