# Candidat local — EscapeJdbcDate — 2026-09-06

## Fidélité au code source

- Source : `worktrees/Y2_Tools_AutoTest_Api/Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs:684-696`.
- Commit contrôlé : `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2` ; fichier source inchangé par rapport à ce commit.
- Le harnais reprend les trois appels `Regex.Replace`, leurs motifs, leurs garde-fous et leur ordre. La seule différence de reproduction est l’enveloppe publique : `Original` et `Candidate` remplacent la méthode privée pour permettre l’appel du harnais.
- Le candidat ne change qu’une chaîne de remplacement : `${1}${3}${2}` devient `${1}${2}${3}` pour la première regex des dates apostrophées. Aucun motif ni contrôle de forme n’est modifié.

## Exécution

Commande exécutée depuis ce dossier :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\test-escape-jdbc-date-candidate.ps1
```

Code de sortie réel : `0`, conservé dans `exit-code.txt`. Le script écrit `results.json` et `results.txt`; il retourne `1` si un attendu candidat échoue ou si le candidat diffère de l’original sur un cas marqué « comportement à préserver ».

## Résultats original → candidat

| Cas | Original | Candidat | Verdict |
|---|---|---|---|
| `'2026-04-28'` | `'20262804'` | `'20260428'` | PASS |
| `'2026-04-05'` | `'20260504'` | `'20260405'` | PASS |
| `'20260428'` | `'20260428'` | `'20260428'` | PASS |
| `'2026/04/28'` | `'2026/04/28'` | `'2026/04/28'` | PASS |
| `'2024-02-29'` | `'20242902'` | `'20240229'` | PASS |
| `SELECT '2026-04-28', '2026-04-05'` | `SELECT '20262804', '20260504'` | `SELECT '20260428', '20260405'` | PASS |
| `SELECT 'no date here'` | inchangé | inchangé | PASS |
| `2026-04-28` sans apostrophes | `'20260428'` | `'20260428'` | PASS, comportement conservé |
| `2026-04-28T12:34:56` | `'2026-04-28T12:34:56'` | `'2026-04-28T12:34:56'` | PASS, comportement conservé |

`candidate.patch` montre le changement proposé pour `JmeterCodeGen.cs`; il n’a pas été appliqué.

## Limites et verdict

Verdict maximal : **correction de transformation validée dans le harnais**. La compilation de l’API, l’intégration de la méthode réelle, la génération JMX, le packaging Console et le rejeu restent `UNKNOWN`. La preuve précédente est inchangée.
