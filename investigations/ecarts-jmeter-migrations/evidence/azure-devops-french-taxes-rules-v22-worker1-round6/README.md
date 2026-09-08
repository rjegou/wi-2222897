# Revue séquentielle de la préparation V22 — round 5

Date : 2026-09-07. Revue read-only, sans queue Azure DevOps. Les fichiers ont été hashés avant lecture, lus séquentiellement, puis hashés après lecture. Aucun fichier de credentials temporaire n'a été créé pendant cette revue.

## Intégrité de la révision

Le fichier `replay-prep/2026-09-07-v22-isolated/MANIFEST.sha256` signalait initialement un hash YAML `7183EC85...`, alors que la lecture donnait `89C556C8AA8321407E167AE324155C72E6D0EEB45C2E5E2D4C330DC52BF5BF33`. C'était un défaut réel : le YAML avait été modifié après génération du manifest. La ligne 2 du manifest a été corrigée vers `89C556...`.

Après correction, un contrôle immédiat a confirmé les dix entrées. Une modification concurrente est ensuite apparue pendant cette revue : les timestamps et hashes courants du YAML, README, `Invoke-V22RunnerDryRun.ps1` et `Preflight-V22FrenchTaxesRules.ps1` ont changé, mais le `MANIFEST.sha256` conserve leurs anciennes valeurs. Le contrôle final est donc volontairement déclaré en conflit, sans écraser le travail concurrent.

- `MANIFEST.sha256` : `E858DADFA340C16EFE995E7B204517DBB71963B896E58D7B21FCF18CA330F21D` (le manifest lui-même n'est pas inclus dans sa propre liste) ;
- `azure-pipelines.candidate.yml` : `89C556C8AA8321407E167AE324155C72E6D0EEB45C2E5E2D4C330DC52BF5BF33` ;
- `README.md` replay-prep : `EDB7CEBEA6E95AA39867100DC01D9BB8D9D8F67CB963C81A1B7F1702A90DDD79` ;
- `MANIFEST.csv` round5 : `E7CB72C2453EBEFCC26A39F6808E336F905784182B01D357B2D5D6234BE3E494` ;
- `README.md` round5 : `40D5050966536572B52AEB10D7AB35395E2565F3B724A7B6CCF6F8DF593320BD`.

État courant observé après le conflit : YAML `CB64B9BAB70B631277EE9C2837C4BF2B5229F48EEE7AAF13A64A0816FD0BFB9A` (2026-09-07 16:34:58), README replay-prep `9B26EA3F60E3E1EF49D2472E343DFACA46CE56CA6D431B749580E438192C41B6` (16:36:25), `Invoke-V22RunnerDryRun.ps1` `05E7E5FF1B3121E9B12FEAD905C0AC51894254C1CE59D542122DA74D1D128586` (16:35:21), `Preflight-V22FrenchTaxesRules.ps1` `3B33791FC91F4EDC65DF88D0311D7C0D3386C4E8AC771EE61186121671E6746A` (16:34:47). Le manifest contient encore respectivement `89C556...`, `EDB7CE...`, `9CAB9D...`, `E99C4E...` : **défaut d’intégrité restant, à résoudre séquentiellement avec Worker 3**.

## Secrets, chemins et collecte expurgée

**FACT — pas de fuite démontrée.** Le secret JFrog n'apparaît pas dans les fichiers. Dans `scripts/steps-replay-variant.yml:48-56`, la clé est seulement lue depuis une variable d'environnement masquée, transmise au script de déploiement, puis retirée de la variable et de l'environnement (`:52-53`). Le fichier `parameters.properties` contient un nom d'utilisateur et mot de passe aux lignes `64-70`, mais son ACL est limitée à l'identité du job et il n'est pas lu par la collecte. Le nettoyage conditionnel `always()` est en `:87-90`. La collecte round5 ne contient ni secret ni valeur de credential.

**DEFECT restant — chemin de checkout.** `azure-pipelines.candidate.yml:56,59` et `steps-replay-variant.yml:59,81,85` cherchent les scripts sous `$(Build.SourcesDirectory)\investigations\...`. Le YAML ne déclare aucun repository contenant nécessairement ce dossier ; `self` est le dépôt pipeline, tandis que `pluginSource`, `jmeterTools` et `platformDeploy` sont placés par les checkouts multi-repo. Ce chemin n'est pas prouvé présent dans le checkout. Verdict : préflight/rejeu **UNKNOWN/BLOCKED jusqu'à preuve ou correction du chemin**.

**DEFECT restant — image non cohérente avec l'image historique vérifiée.** Le manifest round5 prouve `sha256:268476...`, mais le YAML utilise encore l'image 2025 `azure-pipelines.candidate.yml:14,20` (`sha256:ea74f21a...`). Cela ne viole pas l'épinglage, mais empêche de qualifier le rejeu comme comparable au run historique. Verdict rejeu : **UNKNOWN** sur la comparabilité image.

**FACT — étapes et tests.** `steps-replay-variant.yml:72` exécute les trois JMX discriminants réels ; `:76-78` invoque les campagnes Legacy/Web réelles ; la fixture de `Test-V22ReplayFailureModes.ps1:12-24` est explicitement un test local du compteur, pas un substitut de campagne. Exécution locale : `FAILURE-MODES PASS`, comptages `232+144=376`, mauvais comptage rejeté, baseline défaillante bloquant le candidat, nettoyage préservé.

**FACT — expurgation.** `Collect-V22ScrubbedResults.ps1:11-35` conserve uniquement nom relatif, extension, taille, SHA-256, nombre de lignes et compteurs ; la politique explicite exclut URLs, credentials, tokens, claims, payloads et lignes brutes (`:34`).

## Verdicts distincts

### Préflight distant sans écriture métier

**VERDICT : NON PRÊT / BLOCKED.** Le script de préflight est conçu en lecture seule et `Assert-V22LocalContainerRuntime.ps1:23-26` ne crée qu'un marqueur sous `Agent.TempDirectory`; cependant le chemin de script depuis le checkout n'est pas prouvé (`azure-pipelines.candidate.yml:56,59`), et l'image de préflight est la candidate 2025, pas le digest historique. Aucun préflight distant n'a été créé ou lancé.

### Rejeu

**VERDICT : NON AUTORISÉ / BLOCKED.** Le rejeu contient une restauration/déploiement métier explicite (`steps-replay-variant.yml:48-57`), puis les campagnes JMeter (`:72-78`). Les secrets temporaires sont contrôlés et expurgés, mais le chemin de scripts et la comparabilité image ne sont pas résolus. Les hashes des packages baseline et PlatformDeploy sont prouvés séparément ; le YAML ne vérifie pas les hashes des trois packages baseline après acquisition. Aucune queue ne doit être lancée avant correction/proof de ces points.
