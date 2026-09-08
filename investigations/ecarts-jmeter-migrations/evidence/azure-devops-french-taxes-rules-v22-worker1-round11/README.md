# Correction provenance préflight V22 — Worker 1 round 11

Date : 2026-09-07. Lecture/collecte bornée ; aucun nouveau run.

**FACT** — la définition `14246` consomme `/azure-pipelines.wi2222897-v22-preflight.yml` à la racine de `Y2_Plugins_FrenchTaxesRules`. La branche dédiée distante est `refs/heads/codex/wi-2222897-v22-preflight-20260907` au SHA `5036e501ba797ab7efc861add60b111a40ff8141`.

**FACT** — lecture Git Items API au SHA distant : `historicalImage` reste non qualifiée (`cegid-retail-docker-production/y2-jmeter:...@sha256:268476...`), malgré les garde-fous `trigger:none`, `pr:none`, `schedules:[]`, `checkout:none`, login registry et cleanup.

**FACT local** — le candidat round10 porte la référence complète confirmée : `acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter:sqlexpress2019-y2-aspnet-10-windowsservercore-ltsc2022@sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.

**FACT / conflit** — le dépôt exact était `master` propre avant tentative ; le checkout dédié a échoué sur le credential store Git/LFS et a laissé le worktree avec de nombreuses modifications/suppressions. Ces changements ne sont pas restaurés ni écrasés.

**VERDICT** — correction non publiée ; aucun nouveau préflight autorisé sans résolution du conflit de worktree et publication contrôlée de la correction, suivie d’une relecture indépendante du SHA et de la preview.
