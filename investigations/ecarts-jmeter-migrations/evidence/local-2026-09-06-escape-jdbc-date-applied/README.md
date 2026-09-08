# Correctif local appliqué — EscapeJdbcDate — 2026-09-06

## Provenance et isolation

- Branche locale : `sandbox/rje-wi2222897-escape-jdbc-date`.
- Worktree : `worktrees/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE/`.
- Base et HEAD : `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`.
- Source modifiée : `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`.
- SHA-256 source après correction : `AEEF6AA332A416A5AC8F1987E732095BE4C39AD619D157B5DBCA23525B0B8EF2`.

Le patch candidat a été vérifié puis appliqué exclusivement à la première substitution de `EscapeJdbcDate` : `${1}${3}${2}` → `${1}${2}${3}`. Aucun refactoring, changement de motif, version ou autre fichier n’a été effectué. Le patch appliqué est conservé dans `git-diff.patch`.

## Harnais extrait du fichier réel

Commande exécutée depuis ce dossier :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\test-modified-escape-jdbc-date.ps1
```

Le script résout le nouveau worktree, extrait l’unique signature `private static string EscapeJdbcDate(string query)`, équilibre les accolades en ignorant commentaires/chaînes, rend uniquement l’accès public pour `Add-Type`, puis échoue si la signature est absente ou ambiguë. Résultats dans `results.json` et `results.txt`; code réel `0` dans `exit-code.txt`.

## Résultats

Les neuf contrôles passent : ISO apostrophées `'2026-04-28'` → `'20260428'`, `'2026-04-05'` → `'20260405'`, compacte et motif `/` inchangés, bissextile `'2024-02-29'` → `'20240229'`, deux dates SQL corrigées, texte sans date inchangé, ISO sans apostrophes → `'20260428'`, date-heure entourée de quotes sans réordonnancement.

## Contrôles Git et limites

`git diff --check` retourne `0`; `git-diff.patch`, `git-status.txt`, `git-diff-check-exit-code.txt` et `encoding-eol-check.txt` sont conservés. Le worktree initial reste propre ; le nouveau worktree ne contient que `JmeterCodeGen.cs` modifié. Aucun commit, push, accès distant, restauration, installation, compilation de solution, packaging ou publication. Verdict : **correctif appliqué localement et testé dans le harnais** ; compilation API et génération JMX restent `UNKNOWN`.
