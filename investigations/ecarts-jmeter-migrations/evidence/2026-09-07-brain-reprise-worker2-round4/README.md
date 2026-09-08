# WI-2222897 — SQL Full-Text — reprise worker2 round4

Date de collecte : 2026-09-07 (Europe/Paris). Système source : Azure DevOps `cegid/Retail`, dépôt `Pipelines_Docker_BaseImages` (`e64dd3e2-a63a-411a-8473-f5c0b46b1749`), lecture REST Python `requests` avec TLS vérifié et PAT en mémoire uniquement. Aucun secret n'est recopié.

## Résultat

- **FACT** — Le pool Microsoft-hosted Azure Pipelines (pool 79) avait 55 agents en ligne au snapshot. Un échantillon signalait `Microsoft Windows`, build agent `5.278.0`; les capacités ne déclaraient pas Docker. Le pool privé 94 avait 20 agents en ligne, Windows `10.0.17763` (Server 2019), et est exclu de cette tentative car il est partagé et aucune capacité Docker n'y est prouvée.
- **FACT** — La branche dédiée `validation/WI-2222897-sql-fulltext-round4` n'existait pas au contrôle. La création par push REST a été refusée : `TF401027 ... Git 'CreateBranch' permission ... scope 'repository'`. Aucun commit, branche ou définition n'a donc été créé à distance.
- **UNKNOWN** — Le diagnostic réel sur agent Microsoft-hosted n'a pas pu être lancé sans branche contenant le YAML. Il n'existe donc pas de preuve runtime de `docker version`, `docker info`, installation Full-Text, ni `CONTAINSTABLE` dans ce round.
- **FACT** — Deux candidats YAML locaux sont prêts et valides syntaxiquement : un diagnostic read-only `windows-2025`, puis un build/smoke séparant SQL 2019 sur `windows-2022` et SQL 2025 sur `windows-2025`. Triggers, PR et schedules sont désactivés; aucune publication feed/ACR/JFrog, promotion, tag, déploiement ou déclenchement aval n'est présent.

## Fichiers et empreintes

- `sql-fulltext-hosted-diagnostic.yml` SHA-256 `6530537076796AA549122F10A5752A05BD27A1CCFA35551497504B5D51622B59`
- `sql-fulltext-hosted-build.yml` SHA-256 `C613BAEE025D2A479A43AFC63F6BD63F49C82BD09A70B658BC26EC2816639D55`

Le diagnostic utilise `checkout: none`, collecte OS/agent, `docker version`, `docker info` et `docker context ls`, puis publie uniquement le log minimal comme pipeline artifact. Le build/smoke reprend la correction round12 et ne pousse aucune image : SQL 2019 utilise la base `ltsc2022`, SQL 2025 `ltsc2025`; chaque stage construit localement, exécute le probe Full-Text, sauvegarde le log container et nettoie le container.

## Compatibilité examinée

La documentation Microsoft indique que les agents hébergés sont des VM neuves par job puis détruites : [Microsoft-hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops-2022). Les labels `windows-2022` et `windows-2025` sont documentés; la page de compatibilité Windows Containers précise que les versions hôte/image doivent être compatibles et que Hyper-V isolation élargit les couples supportés : [Windows container version compatibility](https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility), [Hyper-V isolation](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container).

## Prochaine action exécutable

Un opérateur disposant de `CreateBranch` doit pousser exactement les deux YAML sur une branche dédiée issue de `master` (`cd5a72235e5f71373acb8994cb3f60f2f6975b93`), créer une définition YAML dédiée pointant vers le diagnostic, puis lancer un seul run manuel. Si `docker info` est concluant, lancer séparément les stages 2019/2025 du second YAML et conserver le premier log causal. Ne pas réutiliser la définition 8090 : elle pointe vers `Images/y2-jmeter/JMeter-pipeline.yml` et possède un trigger CI.
