# Revue locale du patch diagnostic Full-Text — round5

Date : 2026-09-07 (Europe/Paris). Périmètre : correction locale du seul fichier `worktrees/Pipelines_Docker_BaseImages_worker2_round9/validation/WI-2222897/sql-fulltext-hosted-build.yml`. Aucun push, queue, publication distante, Dockerfile, probe, secret ou ressource V22 n’a été touché.

## État Git et correction

- **FACT** — avant correction, le worktree était détaché et le seul fichier modifié était le YAML diagnostic; le hash observé était `2698D6F4EFF7FBEE88419336AB169C823196156B656FCA3DCD48633CF6EF06B6`.
- **FACT** — la revue de ce hash était bloquante : accolade `}` supplémentaire dans le script SQL2025; un échec de `docker ps` pouvait être traité comme une liste vide et donc comme une absence.
- **FACT** — correction appliquée : suppression de l’accolade supplémentaire; capture de `$LASTEXITCODE` après `docker ps`; `remaining=UNKNOWN` et avertissement si l’inspection échoue, dans les deux stages.
- **FACT** — hash final : `6C6FD9EC35AD02DA4B71DB8562888BB479441BCC44BED78D4B169E7DB66E21B3`.
- **FACT** — diff final du YAML : 100 lignes ajoutées, 22 supprimées; `git diff --check` passe. La modification reste locale et non publiée.

## Extraction et parse complets

Commande reproductible :

```powershell
pwsh -NoLogo -NoProfile -File investigations/ecarts-jmeter-migrations/evidence/local-2026-09-07-sql-fulltext-patch-review-round5/Test-FullTextPatchRound5.ps1
```

Résultat : `SCRIPT_PARSE=PASS count=2`; les scripts sont extraits dynamiquement jusqu’à la ligne `displayName` suivante, sans tronquer leur dernière ligne. Le parse YAML indépendant trouve les stages `SQL2019`, `SQL2025`, `trigger: none`, `pr: none`, `schedules: []`.

Commande de parse YAML indépendante : `python -c "import yaml; ... yaml.safe_load(...) ..."` ; résultat observé : `YAML_PARSE=PASS stages=SQL2019,SQL2025 trigger=none pr=none schedules=[]`.

## Fixtures inertes

Le harnais exécute le bloc de cleanup extrait de chaque stage avec un faux `docker` :

| Fixture | Résultat attendu et observé |
|---|---|
| suppression réussie + inspection vide | absence confirmée, aucun avertissement |
| conteneur restant | avertissement, pas d’absence confirmée |
| suppression échouée | avertissement |
| `docker ps` échoué | `remaining=UNKNOWN`, avertissement; jamais absence confirmée |
| smoke échoué | cleanup exécuté, erreur smoke relancée après `finally` |
| collecte diagnostic échouée | erreur capturée, cleanup exécuté |

**FACT** — les mêmes quatre fixtures de cleanup passent pour SQL2019 et SQL2025. Le harnais vérifie aussi dans chacun des scripts extraits la présence du `catch` de collecte diagnostic, du `finally` de cleanup et de la relance de l’erreur smoke; les contrôles de flux synthétiques confirment cleanup puis relance de l’échec smoke et cleanup après échec de collecte. **UNKNOWN** — comportement Docker réel du patch tant qu’il n’est pas exécuté sur agent; aucune queue n’était autorisée dans cette tâche.

## Contrôles complémentaires

- **FACT** — aucune valeur de secret n’est présente dans le YAML corrigé ou le harnais; seules les références d’environnement `sa_password` existent dans le script, sans valeur.
- **FACT** — aucune commande `docker push`, JFrog, Artifactory, promotion, tag source ou publication externe n’a été ajoutée; la publication reste limitée aux Pipeline Artifacts du YAML.
