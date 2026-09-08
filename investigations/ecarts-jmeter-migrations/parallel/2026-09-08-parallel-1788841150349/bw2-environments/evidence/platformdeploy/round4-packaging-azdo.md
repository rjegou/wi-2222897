# Round 4 — packaging local et lecture AzDO

Date de collecte : 2026-09-08. Zone exclusive BW2.

## Packaging privé

**FACT** — le clone indépendant `worktrees/platformdeploy` était propre avant la collecte (`## master`). Les règles pertinentes de `Src/PipelineTemplates/job-build.platformDeploy.yml` ont été reproduites localement : copie de `Src/Powershell/Code/Scripts` dans un staging privé, archive ZIP, puis extraction privée. Aucun registry, feed, agent, Docker, SQL ou IIS n'a été utilisé.

Staging : `evidence/platformdeploy/round4-private-staging-20260908/`.

| Élément | Valeur |
|---|---|
| source `Scripts/init-container.ps1` | SHA-256 `2D713EE2149D20F5137BBAF5E459B4CAB4307883F4B93791C61D54C74D65CF1F` |
| archive `PlatformDeploy.local.zip` | SHA-256 `52B0125A7E00256D4138E591CC2F97B2FA9372A9E84D69C25B3D1B48E4681318`, 59 437 octets |
| extraction `Scripts/init-container.ps1` | SHA-256 `2D713EE2149D20F5137BBAF5E459B4CAB4307883F4B93791C61D54C74D65CF1F` |
| comparaison source/extraction | égale |
| parse du script extrait | 0 erreur |

**INFERENCE** — cette preuve établit que le correctif local est conservé par le packaging/extraction privé. Elle ne prouve pas que l'archive historique d'un runner V22/V26 est cette archive.

## Lecture AzDO ciblée

**UNKNOWN** — la lecture REST HTTPS ciblée des builds `4432602`, `4432554` et `4432510` n'a pas obtenu de réponse : l'environnement local a retourné `The SSL connection could not be established`. La CLI AzDO n'a pas été poursuivie car son profil global `.azure` est inaccessible en écriture; aucune configuration globale n'a été modifiée. Aucun artefact n'a été téléchargé.

Les faits historiques déjà indexés restent valides mais ne sont pas renforcés par cette collecte : `4432602` résout statiquement PlatformDeploy `5.0.86` / tag `V5.0.86` / commit `93f91487...`; l'égalité binaire avec le ZIP consommé est UNKNOWN. Les versions et commits réellement consommés par `4432554` et `4432510` restent UNKNOWN.

## Healthchecks et fixtures

**FACT** — le script local `test-container-ps7.ps1` invoque les contrôles page, SQL, health, worker et auth. `continueOnTestFailure=true` les rend tolérés dans le flux; cela ne constitue pas une postcondition de migration.

**UNKNOWN** — transport effectif des fixtures vers l'image/montage, digest de l'image consommée et attestation runtime `Agent.ContainerMapping` restent non prouvés. Prochain test discriminant : exécuter sur agent dédié une attestation hôte avant download/restore/deploy, puis conserver version/hash du package, chemins/hashes fixtures, codes MSI et verdicts health non tolérés.

