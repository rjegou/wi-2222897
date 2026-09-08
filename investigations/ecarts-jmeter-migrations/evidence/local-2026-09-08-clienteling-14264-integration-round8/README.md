# Intégration 14264 — Console 4445025 et diagnostic cible

Date : 2026-09-08, Europe/Paris.

## Configuration distante publiée

**FACT** : la branche dédiée `sandbox/clienteling/wi2222897-isolated-replay` a reçu le commit
`a1be1292132450b513039b260b96a55be642481a`. La relecture Git REST indépendante confirme le blob
YAML `bcac55e51d777c7f669c79d9e67230bddf87d2a9` et les valeurs acceptées :

- Console build `4445025`, définition `2641` ;
- package Console SHA-256 `796563797BBA329B2D041A2921735BC86C5F2DCADAED269FEDF77BB13542F1BE` ;
- DLL API embarquée SHA-256 `A7D3BB84C4105ADCB626AFE570C42167FADC9F5A04602A6EF223530C98A9021E` ;
- API package SHA-256 `B416C52F58D5129C36540C13E9C9BA36CCB064FE5433EE3D21C8094A9E3E5AC4` ;
- API commit attendu conservé `4c22cb2850a150161f44080815375527c4daad48`.

La provenance API du Console 4445025 reste explicitement le build `4444765`; elle n'est pas
confondue avec le run API `4444962`.

## Vérification des runs précédents

**FACT** : les runs 14264 `4445072`, `4445085` et `4445099` sont tous `completed/canceled`,
raison `individualCI`, sans timeline, log ni artefact. Aucun run résiduel n'a été ignoré.

## Diagnostic cible réel

**FACT** : sur l'agent observé, Docker client `27.4.0` est présent, mais `docker info` et
`docker image ls` échouent sur le pipe absent `//./pipe/docker_engine`; aucune image/digest local
et aucun backup `.bak` n'ont été trouvés sous `.work`. Le diagnostic est conservé dans
`local-2026-09-08-clienteling-target-diagnostic-round8/`.

Le script fail-closed de préflight n'a donc pas été exécuté avec `-Provision`; aucune image,
réseau, conteneur, restauration SQL ou donnée partagée n'a été modifiée. Aucune attestation réelle
ne peut être produite depuis cet agent.

## Verdict

La configuration 14264 ne requiert plus le package local `803D` comme candidat unique et est prête
à consommer explicitement 4445025. Le rejeu Build/GenerateJmx/Cur/Fix reste bloqué proprement par
l'absence d'une attestation cible produite sur un agent Windows/Docker autorisé. Ne pas relancer une
campagne avec paramètres d'attestation manquants.

