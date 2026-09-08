# Round 9 — Full-Text branche sandbox et arrêt avant push

Date : 2026-09-07 Europe/Paris. Aucun push, définition, queue, publication ou document canonique n'a été effectué.

## État initial et branche

- **FACT** — Avant toute opération, `git status --short --branch` dans `worktrees/Pipelines_Docker_BaseImages` a montré `master...origin/master` et exactement trois modifications locales non commitées : `Images/SqlExpress/2019/dockerfile`, `Images/SqlExpress/2025/dockerfile`, `Images/SqlExpress/tests.yml`.
- **FACT** — Lecture REST TLS vérifiée : dépôt `Pipelines_Docker_BaseImages`, branche `refs/heads/sandbox/WI-2222897-sql-fulltext`, commit `cd5a72235e5f71373acb8994cb3f60f2f6975b93`. La branche distante est bien issue du même commit que master annoncé.
- **FACT** — Le fetch Git ciblé n'a pas ajouté de ref locale `origin/sandbox/WI-2222897-sql-fulltext`; comme la lecture REST donne le commit exact identique à master, un worktree détaché local a été préparé sur ce SHA, sans changer la branche du clone sale. Chemin isolé final : `worktrees/Pipelines_Docker_BaseImages_worker2_round9`.

## Transfert vérifié dans le worktree isolé

Les fichiers ont été transférés sans modification de contenu. Hash source → isolé, tous égaux :

- SQL 2019 Dockerfile : `B8198C2A1B032564C2AD7CAC75FEE30F2822A4A05D4E0CE8F1D09FD2278C2234`
- SQL 2025 Dockerfile : `016EAE89BECC02487CEAA8970296EAEF67871AD0792D01DDFD7D4D9F9D775999`
- `Images/SqlExpress/tests.yml` : `24ABA90EB8D81BEBE5701EC27FB4DC7B1C8B15746C54018EFBA2CE624B7CF367`
- `fulltext-probe.ps1` : `C2A73DE90405528A667BA2AD217BB56EEDEF93FDFD09045129981301CB492B0F`
- `validation/WI-2222897/sql-fulltext-hosted-diagnostic.yml` : `6530537076796AA549122F10A5752A05BD27A1CCFA35551497504B5D51622B59`
- `validation/WI-2222897/sql-fulltext-hosted-build.yml` : `C613BAEE025D2A479A43AFC63F6BD63F49C82BD09A70B658BC26EC2816639D55`

Les deux YAML ont été relus localement : `trigger: none`, `pr: none`, `schedules: []`. Le build vise SQL 2019 sur `windows-2022` et SQL 2025 sur `windows-2025`; le diagnostic est read-only et le smoke publie seulement des artefacts de preuve.

## Vérification des triggers partagés et décision

La requête Azure DevOps par `repositoryId` a retourné six définitions existantes sur ce dépôt :

| ID | définition | YAML | métadonnée trigger |
|---:|---|---|---|
| 6823 | SqlExpress2019 | Images/SqlExpress/2019/sqlexpress2019-pipeline.yml | continuousIntegration, `branchFilters: []` |
| 6874 | IIS_Msmq | Images/IIS-Msmq/Iis-Msmq-pipeline.yml | continuousIntegration, `branchFilters: []` |
| 8090 | Pipelines_Docker_BaseImages | Images/y2-jmeter/JMeter-pipeline.yml | continuousIntegration, `branchFilters: []` |
| 10260 | Y2_Aspnet | Images/Y2-aspnet/Y2-aspnet-pipeline.yml | continuousIntegration, `branchFilters: []` |
| 14079 | Win2025-stack-pipeline | win2025-stack-pipeline.yml | continuousIntegration, `branchFilters: []` |
| 14084 | SqlExpress2025 | Images/SqlExpress/2025/sqlexpress2025-pipeline.yml | continuousIntegration, `branchFilters: []` |

Les YAML SQL 2019, SQL 2025 et Win2025 lisibles localement déclarent `trigger: none`; cependant le YAML référencé par 8090 (`Images/y2-jmeter/JMeter-pipeline.yml`) est absent du clone local et son comportement de branche ne peut pas être prouvé. Avec les métadonnées CI partagées et filtres vides, l'absence d'effet au push n'est pas démontrée.

**VERDICT** — Arrêt obligatoire avant push, conformément à l'instruction utilisateur. Aucun pipeline partagé ou aval ne doit être déclenché sans validation propriétaire ou neutralisation explicite des triggers. Le diagnostic hosted et les smokes restent prêts dans le worktree isolé, mais aucun runtime Full-Text n'est attesté dans ce round.
