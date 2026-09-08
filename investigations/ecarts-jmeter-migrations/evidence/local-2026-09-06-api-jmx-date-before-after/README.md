# Comparaison API originale / corrigée — EscapeJdbcDate

Date : 2026-09-06. Le worktree original `worktrees/Y2_Tools_AutoTest_Api` était propre à `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`. Aucun worktree n'a été modifié.

API originale chargée : `runtime-original/Cegid.Retail.AutoTest.Api.dll`, SHA-256 `A9155462C3F6ECE5D6C7ED634B735A83279E854501738C968768A3423320BD55`.
API corrigée chargée : `runtime-corrected/Cegid.Retail.AutoTest.Api.dll`, SHA-256 `51FB31F71D1BAC99114548B05AC66FF59A49F5AEBD7E09A4F970CF1E6915AD81`.
Les deux processus indiquent .NET Framework `v4.0.30319` et leurs chemins absolus dans `logs/run-*.log`.

`DateJmxHarness.cs` appelle directement `JmeterCodeGen.GenerateJmeter`, sans réflexion ni recopie de transformation. Adaptations de harnais uniquement : arguments de sous-dossier de sortie et d'empreinte attendue, pour séparer les processus et vérifier chaque DLL. Les six fixtures sont dans `fixtures/`.

Résultats : original code 1 (4 FAIL, 2 PASS) ; corrigé code 0 (6 PASS). Original : `20262804`, `20260504`, `20242902`, `20262804/20242902`; corrigé : `20260428`, `20260405`, `20240229`, `20260428/20240229`. Les témoins compact et slash sont inchangés.

`logs/xml-diff.tsv` et `logs/xml-diff.csv` conservent la comparaison structurelle : les quatre XML avec dates ISO diffèrent uniquement par `JDBCSampler/stringProp[@name='query']`; les deux témoins sont identiques (`exactXml=True`).

Commandes et sorties : `logs/build-original-command.txt`, `logs/compile-*.log`, `logs/run-*-command.txt`, `logs/run-*.log`, `jmx-original/`, `jmx-corrected/`, `*-results.tsv`. Limites : aucun JMeter, SQL, HTTP, Console, Docker, déploiement ou rejeu métier.
