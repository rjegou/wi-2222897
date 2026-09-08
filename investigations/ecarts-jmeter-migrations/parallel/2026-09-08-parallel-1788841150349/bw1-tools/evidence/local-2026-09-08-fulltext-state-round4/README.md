# État local Full-Text et traces de reprise — round 4

Date de collecte : 2026-09-08 (Europe/Paris). Lecture locale bornée : aucune queue,
arrêt, publication, push ou nouvelle requête distante.

## Traces de builds

FACT : la dernière trace indexée du build Azure DevOps `4442156`
(`WI-2222897-SQLFullText-HostedBuild-20260907.4`, définition `14251`, branche
`sandbox/WI-2222897-sql-fulltext`, commit `0baf69c1ce3c37462364f4b5a269ee1e24a73b9a`)
le laisse `inProgress`, sans `finishTime`. La timeline montre SQL 2019 `failed` et
SQL 2025 `inProgress`; les publications d'artefacts sont `skipped` ou `pending`.

FACT : pour le build `4442685`, les artefacts SQL 2019/2025 n'ont pas été récupérés par
les voies officielles bornées : redirection vers `artprodsu6weu.artifacts.visualstudio.com`
non suivie avec le PAT et endpoint ticketé HTTP 404. Aucun secret n'a été affiché ou
persisté.

UNKNOWN : état final actuel de `4442156`, contenu des logs d'artefacts, état runtime
SQL/Full-Text après timeout et résultat `CONTAINSTABLE`. Les traces sont des snapshots.

## Processus locaux

FACT : les PID des trois orchestrateurs consignés (`18468`, `6100`, `22320`) ne sont
plus retournés par `Get-Process`. Aucun processus `java`, `jmeter`, `docker`, `sqlservr`,
`dotnet`, `msbuild`, `az` ou `git` n'a été listé; des `cmd`/`powershell` restent présents
mais ne sont pas attribuables à Full-Text sans lire leurs arguments.

FACT : `Get-CimInstance Win32_Process` a été refusé (`Accès refusé`), donc la relation
parent/enfant et les arguments n'ont pas été collectés. Aucun processus non attribuable
n'a été arrêté.

## Contrôle avant reprise

Il faut une lecture authentifiée et fraîche du build/run : état final, timeline complète,
logs du probe et artefacts téléchargeables. Ensuite seulement vérifier cible isolée,
identité/scopes et absence de run concurrent avant une queue manuelle. Aucun nouveau run
n'a été lancé dans cette collecte.
