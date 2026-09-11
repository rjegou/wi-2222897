# Finding 022 — Clienteling V26 : replay isolé bloqué au téléchargement JFrog

## Périmètre et provenance

- **Périmètre rapporté** : dépôt `Y2_Plugins_Clienteling`, définition isolée `14264`, branche
  `sandbox/clienteling/wi2222897-isolated-replay`.
- **Paramètres de référence** : API build `4444962`, définition API `2637`, commit API
  `4c22cb2850a150161f44080815375527c4daad48`, Console build `4445025`, définition Console `2641`.
- **Source** : [synthèse technique conservée](../evidence/local-2026-09-09-clienteling-v26-replay/README.md).
- **Statut** : `rapporté, non revérifié` ; aucune lecture Azure DevOps, JFrog ou dépôt distant n'a été effectuée lors de cette intégration.

## Conclusion bornée

**FACT documentaire** — la source reçue décrit une progression par premier blocage, avec des correctifs
rapportés sur les runs `4451986`, `4452281`, `4452432`, `4452572`, `4452629`, `4452683`, `4452739`
et `4452826` : téléchargement JMeter, récupération du `.cy2px` depuis un ZIP historique,
checkout PlatformDeploy dans le job JMeter, variable JFrog masquée, host et instance SQL rendus
portables, staging du backup dans `Docker\Data`, puis restore/build/publish du CLI JFrog.

**FACT rapporté** — le dernier run `4452826` est décrit comme atteignant la phase
`download-packages.ps1`, puis échouant sur `The download of one or more packages has failed`.
Le filtre de diagnostic whitelisté n'a extrait ni package ni code HTTP.

**INFERENCE bornée** — la profondeur atteinte réduit le blocage au contrat d'exécution de
PlatformDeploy et à son téléchargement de packages, mais ne permet pas d'identifier le package,
le statut HTTP, la cause d'accès ou une modification nécessaire.

**UNKNOWN** — tous les identifiants distants, la branche réellement consommée, le package fautif,
les permissions/URL JFrog, les effets externes éventuels, l'exécution de `GenerateJmx` et toute
exécution JMeter Cur/Fix.

## Reprise discriminante

Avant toute modification, relire directement la timeline et le log du run `4452826` (et, si besoin,
`4452739`) ; extraire uniquement le premier message d'erreur non sensible du CLI, sans afficher de
sortie brute ni secret. Vérifier si le format réel est `##[error]`, `Updating package`, un fichier
`downloadedPackages.json` ou une autre sortie prouvée. Ne pas publier, promouvoir, taguer, modifier
un pipeline normal ou relancer le replay sans autorisation explicite.
