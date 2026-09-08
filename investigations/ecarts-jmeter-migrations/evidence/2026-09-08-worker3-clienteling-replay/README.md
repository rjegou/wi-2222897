# Worker 3 — Clienteling generator replay readiness

Date : 2026-09-08

## Périmètre

Contrôle préalable à un vrai pipeline Azure DevOps Build + JMeter Cur/Fix pour
Clienteling `master` V26, sans modification des documents canoniques partagés,
des branches distantes, des packages ou des pipelines.

## Faits vérifiés

- `STATUS.md` et la matrice identifient le build de référence Clienteling V26
  `4432554`, commit `1bcb509c38c31d337fcc5419c7b89d61a19fbe3a`, avec 485 cas non
  passés identiques en Cur et Fix.
- La preuve Worker 1 du 2026-09-07 identifie le package Console corrigé
  `2.0.42-soapnamespace.20260907`, SHA-256
  `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55`, et la DLL
  API consommée, SHA-256
  `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B`.
- Cette preuve locale rapporte une génération avec code `0`, 151 JMX parsés,
  et cinq plans Clienteling raccordés au descriptor WebServices : trois
  Deployment et deux Mobility. Elle ne prouve ni publication officielle, ni
  consommation par un pipeline, ni résultat HTTP/SQL métier.
- Avant toute édition, les worktrees ont été contrôlés avec
  `git -c safe.directory=<path> status --short --branch` :
  `Y2_Plugins_Clienteling` est `master` avec cinq XML de métadonnées modifiés;
  `Y2_Tools_Jmeter_Workflow` est `master` avec `azure-pipeline.yml` modifié;
  `Migration_Jmeter_RJE_Sandbox` est propre. Ces changements ont été préservés.

## Revalidation live

Le 2026-09-08, l’appel read-only aux définitions Azure DevOps
`https://dev.azure.com/cegid/Retail/_apis/build/definitions?api-version=7.1`
avec le PAT présent dans le chemin opérationnel documenté a répondu
`Authentication failed`. La commande CLI AzDO a également été empêchée par le
profil global non accessible et son installation d’extension n’a fourni aucune
définition exploitable.

Le contrôle complémentaire n’a trouvé aucun processus `az` actif. Le profil
temporaire utilisé pour le test a ensuite été supprimé. Les accès Git ont été
testés sans modifier la configuration globale; `.git/index.lock` était absent,
mais l’écriture de l’index a répondu `Permission denied`.

## Verdict

- FACT : la correction générateur est démontrée localement sur une fixture et
  un descriptor réel de génération isolée.
- FACT : les changements utilisateur des worktrees sont présents et non
  touchés.
- UNKNOWN : le pipeline, la branche d’essai dédiée, le NuGet réellement
  consommé, les JMX déposés, les stages Build/Cur/Fix, les logs finaux et les
  artefacts live.
- BLOCKER : sans authentification AzDO valide, il n’est pas possible de créer
  ou pousser la branche d’essai, queuer le pipeline, ni récupérer sa conclusion.

Aucun pipeline, push, publication, promotion, tag ou message externe n’a été
effectué dans cette collecte.

## Ressource temporaire

Le profil CLI temporaire `.az-worker3-live` a été créé dans la racine du dépôt
pour contourner le profil global en lecture seule, puis supprimé après contrôle
qu’aucun processus `az` ne l’utilisait. Il n’est pas présent dans le workspace.
