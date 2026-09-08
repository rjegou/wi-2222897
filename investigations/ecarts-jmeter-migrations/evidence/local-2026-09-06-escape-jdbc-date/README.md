# Reproduction locale — EscapeJdbcDate — 2026-09-06

## Provenance

- Date : 2026-09-06.
- Source : worktree local `worktrees/Y2_Tools_AutoTest_Api`, branche `master`.
- Commit vérifié : `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- Méthode source : `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs:684-696`, `EscapeJdbcDate`.
- SHA-256 du fichier source : `2336440E91372B23482C65878D5D708A177B90317CB08A4DA23A43524820626E`.
- Le fichier source est identique à celui du commit vérifié (`git diff --exit-code` ciblé).

## Harnais et exécution

`reproduce-escape-jdbc-date.ps1` copie exactement le corps de la méthode. Seules la classe du harnais et la visibilité `public` diffèrent. La dépendance directe est `System.Text.RegularExpressions.Regex`; aucune référence API, réflexion, installation ou restauration n'est utilisée.

Commande exécutée depuis ce dossier :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\reproduce-escape-jdbc-date.ps1
```

Le script compile le harnais en mémoire avec `Add-Type` et écrit `results.json` et `results.txt` dans ce dossier.

## Résultats

| Entrée | Attendu | Obtenu | Verdict |
|---|---|---|---|
| `'2026-04-28'` | `'20260428'` | `'20262804'` | FAIL |
| `'2026-04-05'` | `'20260405'` | `'20260504'` | FAIL |
| `'20260428'` | `'20260428'` | `'20260428'` | PASS |
| `'2026/04/28'` | `'2026/04/28'` | `'2026/04/28'` | PASS |

## Limites

Cette preuve reproduit la regex actuelle et son défaut ; elle ne valide ni la compilation de l'API, ni la génération d'un JMX, ni le comportement Console/migration. Aucune correction n'est déclarée validée.
