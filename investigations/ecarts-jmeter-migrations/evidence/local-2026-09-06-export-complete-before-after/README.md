# Export_Run complet — comparaison avant/après — 2026-09-06

## Provenance et complétude

Source : `worktrees/Y2_Plugins_FrenchTaxesRules`, `master`, commit `07a42172bebc65d17093e166ac08de22e4fe7248`, propre. Le plan source est `.../TestPlans/Export_Run.xml`, SHA-256 `A3F64788FCBCB1C1157DEBBCC233EABE9EA82A132A220182EE4A4999974373A4`.

Le contrôle lit `Input` sur chaque `TestCase` et extrait les chemins `OutputFiles\...xml` du nœud XML de comparaison (`XmlQueries` dans ce fichier). Il trouve dix entrées `Run_01.xml`–`Run_10.xml` et cinq sorties uniques `Run_05.xml`–`Run_09.xml`; tous existent dans la source et ont été copiés. La correspondance observée est TC05→05, TC06→06, TC07→07, TC08→08, TC09→09 et TC10→07. Aucun nom de sortie n'a été dérivé du numéro de cas.

## Exécution

Trial isolé : `C:\temp\rje-wi2222897-export-complete-20260906-175237\`. Artefact Console local run 4311240, nupkg SHA-256 `4ACE80675261D7D5DAD2DB3F0E8C7983790E1983D32C12661FF980C54B16E5DE`. Console originale/corrigée : SHA-256 `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F`; API originale `21A4AC70059F1B0DA716F0AD24E5CAB8AE92B679DCDD5B17034C2F02E21D3E98`; API corrigée `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`.

Commandes exécutées : `commands.txt`. Chaque variante a utilisé un processus distinct et un `--dstFolder` distinct. Codes Console : original `0`, corrected `0`. JMX et logs sont conservés dans `original/` et `corrected/`.

## Résultats ciblés

Voir `results.tsv`. TC08 : l'original produit `20160301` et `20150112`, le corrigé `20160103` et `20151201`. TC09 : `20160303` reste identique (cas non discriminant) ; `20160102` devient `20160201`. TC10 : les dates observées restent identiques (`20160401`), sans changement lié à la correction.

Le JMX contient 86 `JDBCSampler` dans chaque variante. Après normalisation des racines de chemins propres aux variantes et des littéraux de date, les JMX sont identiques (hash normalisé `2A892B31A8FB43975E3E4B7696897840779A9F05DBB34020D86DC028496541AE`). Aucune différence hors dates et chemins d'essai n'est observée. Après exécution, `Cegid.Retail.AutoTest.Console.log` diffère entre runtimes car il est généré par chaque processeur ; ce n'est pas une différence JMX ni une DLL.

Limites : aucune exécution JMeter, SQL ou HTTP ; la génération JMX ne prouve pas la réussite métier des TC08–TC10.
