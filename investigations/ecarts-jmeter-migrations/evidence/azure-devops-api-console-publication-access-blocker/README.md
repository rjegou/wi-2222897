# Accès publication API → Console → migration — blocage de permission

## Provenance

- Date : 2026-09-08 (Europe/Paris)
- Système source : Azure DevOps REST `https://dev.azure.com/cegid/Retail`
- Dépôts : `Y2_Tools_AutoTest_Api`, `Y2_Tools_AutoTest_Console`,
  `Migration_Jmeter_RJE_Sandbox`
- Méthode : REST Git authentifié avec le PAT autorisé en mémoire du processus; création d’une
  branche dédiée puis arrêt sur la réponse d’autorisation
- Fraîcheur : collecte live de cette session

## Faits

- REST authentifié vers `Y2_Tools_AutoTest_Api` : HTTP 200.
- Refs master live : API `220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`, Console
  `fa8a5fb411bbadcef16204f149bae3a65b0f7abb`, migration
  `892c9e30cd94aab3bc7d45585a60994dd3186021`.
- Le fichier API distant correspond à la base du patch sauvegardé; `git apply --check` local
  passe et produit une source corrigée de 86 354 octets, SHA-256
  `01489edc1ab556c903e9d40ea94356b161048a2f0fd5ed64d3545cac1bda605d`.
- La branche demandée `refs/heads/wi-2222897/frenchtaxesrules/api-jmeter-fixes` n’existait
  pas avant l’essai.
- Le push REST de cette branche est refusé HTTP 403 avec `TF401027`: permission Git
  `CreateBranch` manquante, identité `rjegou@cegid.com`, scope `repository`.
- Aucun commit, branche ou pipeline n’a été créé par cet essai. Un push direct sur `master` n’a
  pas été tenté.
- Le test Azure CLI avec `AZURE_CONFIG_DIR` temporaire a été tenté sans modifier le profil
  utilisateur; son retour authentifié n’est pas exploitable dans ce sandbox. La REST Python
  utilise TLS normal et répond correctement; aucun contrôle TLS n’a été désactivé.

## Verdict

`FACT` — l’accès réseau TLS et l’authentification PAT sont fonctionnels via REST.

`FACT` — la mutation nécessaire est bloquée par la permission Azure DevOps `CreateBranch`.

`UNKNOWN` — une version de package publiée ailleurs peut exister; cette collecte ne permet pas
de l’infirmer. Aucun package n’a été publié par cette session.

## Reprise autorisée

Après octroi de `CreateBranch` au PAT, ou fourniture d’une branche dédiée préexistante avec
permission de contribution, reprendre sur le commit API vérifié, puis publier Console et le
package de migration dans des coordonnées explicitement épinglées. Ne pas contourner le refus
par une écriture directe sur `master`.

## Sécurité

Le PAT n’est pas présent dans ce dossier, les sorties ou Git. Aucune configuration Git globale,
ACL, TLS ou profil utilisateur n’a été modifié.
