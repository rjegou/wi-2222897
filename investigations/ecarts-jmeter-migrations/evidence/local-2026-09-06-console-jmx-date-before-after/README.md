# Console officielle — comparaison API originale/corrigée

Date : 2026-09-06. Essai local uniquement, sans compilation, exécution JMeter, SQL, HTTP, réseau ni publication.

## Provenance et identités

- Source : `evidence/packages-current/AutoTest_Console_4311240/Cegid.Retail.AutoTest.Console.2.0.42.nupkg`, run 4311240, SHA-256 `4ACE80675261D7D5DAD2DB3F0E8C7983790E1983D32C12661FF980C54B16E5DE`.
- Console dans les deux runtimes : `Cegid.Retail.AutoTest.Console 2.0.42.0`, token `4a78b93fa9cdb37d`, SHA-256 `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`.
- API originale : `Cegid.Retail.AutoTest.Api 1.1.46.0`, token `fe0ce61bd76bef19`, SHA-256 `21A4AC70059F1B0DA716F0AD24E5CAB8AE92B679DCDD5B17034C2F02E21D3E98`.
- API corrigée : même identité/version/token, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`.
- Comparaison des 16 fichiers de chaque runtime : seule `Cegid.Retail.AutoTest.Api.dll` diffère.

## Fixture et commande

La campagne `fixtures/campaign.xml` contient six plans XML sérialisés depuis les types officiels `TestCampaign`, `TestPlan` avec `xsi:type=DtoLegacyServiceTestPlan`, `TestCase` et `Control`. Chaque plan porte un seul `PreDataQueries/Control`; aucun endpoint n'est utilisé. La syntaxe `--tstj=<campagne> --dstFolder=<sortie>` est confirmée par `CommandLineOptions.cs` et `Program.cs`.

Les commandes wrapper exactes sont dans `logs/run-original-command.txt` et `logs/run-corrected-command.txt`; le wrapper lance le binaire officiel dans un processus Windows PowerShell 5.1 distinct.

## Résultats réels

| runtime | code Console | JMX | assertions query |
|---|---:|---|---|
| original | -1 | aucun | non exécutées |
| corrected | -1 | aucun | non exécutées |

Les deux stdout s'arrêtent après l'initialisation Unity/Bootstrapper; stderr est vide. Aucun appel SQL/HTTP n'est atteint. La cause exacte de l'arrêt reste `UNKNOWN`. Le chemin de l'API réellement chargée par le processus Console n'est pas observable dans ses traces ; les chemins/hash des DLL préparées sont consignés ci-dessus.

Verdict maximal non atteint : la génération JMX par Console officielle n'est pas validée. Recompilation Console, packaging, pipeline, Docker et rejeu métier restent `UNKNOWN`.
