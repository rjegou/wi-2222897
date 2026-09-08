# Revue finale du candidat V22 — Worker 2 round 5

Date : 2026-09-07 (Europe/Paris). Lecture seule; aucun runner, pipeline, branche, définition ou service n'a été modifié.

## Corrections réellement constatées

- **FACT** — PlatformDeploy est désormais fixé à `5.0.86`, avec SHA-256 `625EEC7A139AAE87886E0CE40D075B36A3EC331A0EA021478FBEEF9D6E612295` dans `azure-pipelines.candidate.yml:10-11`. La provenance et le téléchargement HTTP 200 sont documentés dans `evidence/azure-devops-french-taxes-rules-v22-worker1-round4/README.md`.
- **FACT** — le candidat déclare un job container digesté et les deux variantes séquentielles (`azure-pipelines.candidate.yml:18-21`, `:33-82`). Le contrôle local vérifie hostname, processus SQL/IIS et ports 80/1433 (`scripts/Assert-V22LocalContainerRuntime.ps1:10-26`).
- **FACT** — le dry-run a exécuté la logique de production du préflight : `descriptors=2`, `discriminants=3`, `jmx=32`, `hashes=32`, `legacy=232`, `web=144`, `total=376`, puis a retourné `DRY-RUN PASS` et code de commande nul. Il n'a lancé ni déploiement, ni JMeter, ni réseau.

## Défauts non corrigés

1. **Templates** — `azure-pipelines.candidate.yml:49` passe toujours `INLINE_LOCAL_STEPS`. Le mode est accepté par le préflight, mais il n'existe pas de manifeste/hash des étapes inline et cela ne prouve pas une exécution équivalente aux templates approuvés.
2. **Checkout des scripts** — `azure-pipelines.candidate.yml:49` cherche le script sous `$(Build.SourcesDirectory)\investigations\...`, alors que `self` est le dépôt plugin (`:39-43`). La présence de ce chemin dans le checkout réel n'est pas prouvée.
3. **Secrets** — `scripts/steps-replay-variant.yml:47` passe `$(RetailJfrogApiKey)` en argument avec `-verbose`; `:55` écrit `USERNAME` et `PASSWORD` dans `parameters.properties`. Aucun scrubber ou preuve de non-journalisation n'est présent.
4. **Isolation** — le contrôle local (`Assert-V22LocalContainerRuntime.ps1:10-26`) ne vérifie pas l'identité réellement chargée du digest, les volumes/montages, le cycle de vie du container ni les ressources partagées. Il crée un marqueur local mais ne fournit pas une attestation indépendante.
5. **Manifeste commun absent** — `JMX-SHA256SUMS.txt` ne couvre que les 32 JMX. Aucun manifeste SHA-256 commun ne couvre le YAML, les scripts, PlatformDeploy, les packages, l'image, le backup et les paramètres finaux; les `MANIFEST.csv` existants sont séparés par collecte.
6. **Résultats absents** — aucun `.jtl`, log JMeter ou sortie expurgée du candidat n'est conservé. Le scan historique V22 reste sensible (101 fichiers contenant des motifs secrets); aucun contenu n'a été affiché/copier.

## Portée réelle du dry-run

**FACT** — `Invoke-V22RunnerDryRun.ps1:21` appelle effectivement `Preflight-V22FrenchTaxesRules.ps1`, vérifiant hash backup/JMX, manifestes et comptages. **FACT** — `:27-33` vérifie ensuite par texte la présence des triggers désactivés, étapes, ordre et absence de quelques motifs de sortie secrète.

**INFERENCE** — il s'agit d'un dry-run de préconditions et de structure; il ne constitue pas un appel de la logique de déploiement PlatformDeploy ni du runner JMeter. L'expression `DRY-RUN PASS` ne prouve ni restauration SQL/IIS, ni consommation package/image, ni résultat métier.

## Verdicts séparés

- **Préflight distant sans écriture : NON PRÊT.** Les triggers du YAML sont désactivés (`azure-pipelines.candidate.yml:2-4`), mais le commit des étapes inline, le chemin de checkout, l'isolation effective et le manifeste commun ne sont pas prouvés; le risque d'une nouvelle définition/branche et de ses ressources doit être vérifié séparément.
- **Rejeu métier : NON PRÊT.** Aucun résultat baseline/candidat, aucune observation expurgée d'authentification/projection/autorisation, aucune assertion des trois opérations et aucun compteur 376 n'est disponible.

## Sortie expurgée exigée avant queue

Pour chaque variante, conserver seulement : status HTTP d'acquisition, booléen token présent, présence booléenne des scopes attendus, version/hash des assemblies chargées, codes HTTP/métier, booléens `CBP50101`/`ID4266`/`FailedAuthentication`, assertions et compteurs. Ne jamais exporter token, claim complet, mot de passe ou payload sensible. Exécuter d'abord les trois cas discriminants, puis seulement la campagne 232+144.

Défauts restants transmis immédiatement à Worker 3 dans le statut de supervision; aucun changement du runner effectué.
