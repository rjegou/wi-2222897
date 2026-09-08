# Round 8 — test réel init-container.ps1

Date : 2026-09-07 Europe/Paris. Aucun pipeline, droit, branche, worktree source ou document canonique partagé n'a été modifié.

## Portée et substitutions

Le harness `test-platformdeploy-init-container-round8.ps1` lance directement PowerShell 7.6 (`pwsh 7.6.5`) sur le vrai `init-container.ps1` original puis sur le vrai fichier corrigé du worktree isolé `Y2_Tools_PlatformDeploy_worker3_r5b`. Les deux variantes reçoivent les mêmes paramètres : `-coreVersion 26.0.0`, le même fichier `config.cy2px`, `-localDBMode None`, `-verbose`, et `TF_BUILD=true`.

Les seules substitutions sont aux frontières externes :

- `check-prerequisites.ps1` inerte, qui retourne 0 ;
- `deploy.ps1` inerte, qui écrit le résultat enfant puis retourne 0, retourne 7 ou lève une exception.

Les modules PowerShell réels (`Scripts/Modules`) et le code conditionnel de `init-container.ps1` sont copiés depuis chaque worktree correspondant. Aucun Docker, MSI, SQL, IIS ou déploiement réel n'est lancé. Le staging temporaire est supprimé par `finally`.

## Identité des fichiers

- original : `worktrees/Y2_Tools_PlatformDeploy/Src/Powershell/Code/Scripts/init-container.ps1`
  - SHA-256 `21607FE7F753892953A0EC02DCDCD2709EDCA8BCCBBF8A23BF60F67F68653997`
- corrigé : `worktrees/Y2_Tools_PlatformDeploy_worker3_r5b/Src/Powershell/Code/Scripts/init-container.ps1`
  - SHA-256 `1F44AE664B207AFB0A94151A603BFE9F794FF6589B0BA4CCC52D47DFDE50758E`

## Résultat réel

| variante | enfant | exception observée | Process.ExitCode | verdict |
|---|---:|---|---:|---|
| original | 0 | non | 0 | succès conservé |
| original | 7 | non | 0 | code enfant absorbé |
| original | exception | oui | 1 | exception bloquante |
| corrigé | 0 | non | 0 | succès conservé |
| corrigé | 7 | oui (`Deployment failed with exit code 7`) | 1 | code enfant propagé et bloquant |
| corrigé | exception | oui | 1 | exception bloquante |

**FACT** — La réserve round6 est fermée pour la postcondition de propagation : le vrai `init-container.ps1` original et corrigé sont exécutés avec les mêmes entrées, sous `TF_BUILD=true`; le code enfant 7 est absorbé avant et refusé après. Les six cas ont été exécutés par le même harness.

**LIMITATION** — Les dépendances externes sont inertes par construction. Ce résultat ne prouve pas la compatibilité MSI, SQL/IIS, Docker ou le health-check; il prouve uniquement le comportement de propagation du script réel aux frontières isolées.
