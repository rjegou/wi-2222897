# Finding 016 — Clienteling V26 : le backup du rejeu a disparu de l'arbre Git, l'agent Docker est résolu

## Périmètre et provenance

- Système : Azure DevOps `cegid/Retail`, dépôt `Y2_Plugins_Clienteling`
  (`7776ac72-1788-4bea-9422-e5f0dacadc74`).
- Cible du rejeu isolé : définition `14264`, branche
  `refs/heads/sandbox/clienteling/wi2222897-isolated-replay`, YAML
  `ci/wi2222897/azure-pipelines.clienteling-wi2222897.yml`.
- Référence historique : build `4432554`, commit `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a`, runs
  JMeter `6180736` (Cur) et `6180750` (Fix) — cf. [finding 006](006-clienteling-v26-build-4432554.md).
- Preuve : [synthèse technique de pause rangée le 2026-09-08](../evidence/local-2026-09-08-syntheses-techniques-reprise-handoff/README.md),
  fichier `WI-2222897_Clienteling_JMeter_synthese_technique_2026-09-08.md`.
- **Niveau de preuve : rapporté, non revérifié.** Les identifiants ci-dessous ne sont soutenus que par
  ce document ; aucun n'a été relu par `az`/REST lors du rangement.

## Conclusion bornée

**FACT rapporté** — l'obstacle « les agents privés n'ont pas Docker » est clos pour ce besoin. Le stage
`TargetDiagnostic` a été basculé de `Private VS2019` vers `vmImage: windows-2025` ; commit de la
branche isolée `c20755d802d1fb56a93289dd19b92622eb7f2c54`, run `4446303` `succeeded`, stage
`Target diagnostic - hosted Windows 2025` `succeeded`, autres stages volontairement `skipped`
(`diagnosticOnly=true`), OS `Microsoft Windows NT 10.0.26100.0`, Docker `29.7.2`. Les diagnostics
privés `4445464` (02-A) et `4445516` (02-B) ne doivent plus être poursuivis.

**Limite explicite** — un stage vert dont les stages métier sont `skipped` ne prouve rien du rejeu.
`4446303` atteste un agent, pas une campagne.

**FACT rapporté** — les valeurs runtime PlatformDeploy V26 sont désormais résolues depuis les logs du
build `4432554`, qui avait réellement exécuté Cur et Fix :

| Élément | Valeur résolue |
|---|---|
| Version PlatformDeploy | `5.0.86` |
| Archive installée | `$(Agent.TempDirectory)\Y2.Tools.PlatformDeploy\PlatformDeploy.5.0.86.zip` |
| Extraction | `$(Agent.TempDirectory)\Deploy` |
| Script de déploiement | `$(Agent.TempDirectory)\Deploy\docker-pipeline-deploy.ps1` |
| DeployConfig Cur | `$(Agent.TempDirectory)\Deploy\Docker\data\v26-Cur.cy2px` |
| DeployConfig Fix | `$(Agent.TempDirectory)\Deploy\Docker\data\v26-Fix.cy2px` |
| Mode base locale | `-LocalDBInContainer "Backup"` |

Les `.cy2px` V26 sont fournis par le package PlatformDeploy, **pas** par le dépôt Clienteling. Cette
résolution lève l'`UNKNOWN` « chemins PlatformDeploy/config » du round 11, au niveau de preuve
rapporté.

**FACT rapporté** — le backup historique du rejeu est `AUTO_V26_00.bak`, base `AUTO_V26_00`, tenant
`TESTS_AUTO_JMETER`. Le build `4432554` le prenait dans
`$(Build.SourcesDirectory)\Y2_Plugins_Clienteling\Tests\Backups\AUTO_V26_00.bak` puis le copiait vers
`$(Agent.TempDirectory)\Deploy\Docker\data\AUTO_V26_00.bak`. Son objet Git LFS porte
`SHA-256 8B95C2BA5BC7C501F257AB71E777092E62D2470075A2491455D133E2CA3E7A4C`, `156 663 808` octets.

**FACT rapporté — première faute causale du rejeu** — `Tests/Backups` est **absent de l'arbre Git
actuel**, aussi bien sur `master` que sur la branche isolée au commit `c20755d802d1…`
(`Tests/Backups : NOT FOUND`). Le pipeline isolé ne peut donc pas matérialiser le backup que le build
historique consommait.

**FACT rapporté** — le mécanisme historique était bien Git LFS : le checkout de `4432554` exécutait
`git lfs version`, `git lfs install --local` et `git … lfs fetch origin 1bcb509c…`, et le
`.gitattributes` du commit historique contient
`**/Tests/Backups/*.bak filter=lfs diff=lfs merge=lfs -text`. La branche isolée actuelle n'a ni ce
`.gitattributes` à la racine, ni `checkout: self` / `lfs: true` dans son YAML.

**INFERENCE** — la piste minimale et traçable est de rétablir dans la branche isolée la règle
`.gitattributes` historique, le pointeur LFS `Tests/Backups/AUTO_V26_00.bak` et un checkout
`lfs: true`, plutôt que de republier 156 Mo dans Git classique. Cette piste n'est valide que si
l'objet LFS historique est encore téléchargeable côté serveur.

**UNKNOWN** — disponibilité actuelle de l'objet LFS `8B95C2BA…` ; méthode retenue pour rendre le
backup accessible ; image Clienteling exacte et digest du nouveau run ; URLs exactes des probes
Deployment/Mobility dans le nouveau runtime ; image JMeter exacte et digest ; intégration effective
des wrappers `replay-prep` dans le YAML `14264` ; attestation de provisionnement réelle ; et bien sûr
le rejeu `Build → GenerateJmx → JMeter Cur/Fix`.

**Piège de nommage à ne pas rejouer** — `AUTO_V26_00.bak` désigne **deux fichiers différents** selon
le dépôt : `23bfb0b670918fbe5f63ceeff36f66ef1855b46fd82c29bda9d34dfa6b7fc25f` / `150 765 568` o dans
`Y2_Plugins_FrenchTaxesRules`, et `8B95C2BA…` / `156 663 808` o dans `Y2_Plugins_Clienteling`. Ne
jamais citer l'un pour l'autre ni conclure à une corruption depuis leur différence.

## Ordre de reprise

1. Vérifier que l'objet LFS `8B95C2BA…` est encore récupérable depuis Azure DevOps. **C'est le premier
   sujet à reprendre** ; ne pas relancer l'investigation agent, PlatformDeploy ou backup depuis zéro.
2. Choisir et appliquer le changement minimal permettant à `14264` de matérialiser
   `Tests/Backups/AUTO_V26_00.bak` sur l'agent `windows-2025`.
3. Intégrer les wrappers de `replay-prep/2026-09-08-clienteling-isolated/scripts/` — installation de
   `PlatformDeploy 5.0.86`, `.cy2px` Cur/Fix résolus, `-LocalDBInContainer Backup` — puis attester
   image, digest, backup, SQL, `W3SVC`, endpoints, réseau privé et cleanup scoped. Les quatre scripts
   sont parsés sans erreur et ne doivent pas être réécrits sans défaut concret identifié.
4. Seulement après attestation PASS : `Build → GenerateJmx → JMeter V26-Cur → JMeter V26-Fix`, avec
   les candidats déjà hashés (API build `4444962`, Console build `4445025`).
5. Comparer au baseline historique `4432554` (`2118` tests, `485` non passés de chaque côté) **sans**
   présenter ce baseline comme une nouvelle preuve runtime.

## Réconciliation avec la clôture documentaire

La clôture du 2026-09-08 enregistrait « aucun nouveau run, push, provisionnement » et le commit distant
vérifié `f8858ad73df9c9eca7e438e609b6effebb677a9b`. Le commit `c20755d802d1…` et le run `4446303`
rapportés ici sont postérieurs : la phase a été reprise après sa clôture. Le fait est consigné tel
quel, sans attribution à une session identifiée.
