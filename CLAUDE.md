# WI-2222897 — instructions Claude Code

Dépôt de travail du PBI 2222897 (migration TestAuto legacy → JMeter).

1. Lire [README.md](README.md) pour le routage, puis [AGENTS.md](AGENTS.md) pour les règles de travail.
2. [AGENTS.md](AGENTS.md) est la référence : frontières de sécurité, langage de preuve
   `FACT` / `INFERENCE` / `UNKNOWN`, emplacements de production, nommage des preuves, fin de session.
3. Avant toute action distante ou conclusion actuelle, vérifier la fraîcheur : les états Azure DevOps
   consignés sont des snapshots datés.

Deux réflexes propres à ce dossier :

- ce dépôt ne contient que la couche documentaire ; les clones et artefacts lourds sont décrits dans
  [EXTERNAL-ARTIFACTS.md](EXTERNAL-ARTIFACTS.md) et exclus par `.gitignore` ;
- ce qui bloque le WI est dans [decisions/README.md](decisions/README.md) : six arbitrages en attente.
  Ne pas les trancher à la place du PO ou du lead dev.
