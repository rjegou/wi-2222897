# Complément daté — rectification 4444720 et périmètre PR InventoryTracking

**Date :** 2026-09-08 (Europe/Paris). **Source :** relecture REST Azure DevOps des preuves
`build-4444720-inventorytracking-docker-init` et `build-4444720-inventorytracking-docker-review-round3`.
Ce lot est un complément documentaire; les preuves antérieures ne sont pas réécrites.

## Rectifications établies

**FACT** — `4444720` atteint `Initialize containers` pour Cur et Fix et observe un login Docker et
le début du pull, mais aucun démarrage ni création de conteneur de campagne, aucun JTL et aucun
résultat JMeter avant l'annulation. Le cleanup réseau échoue ensuite sur réseau absent; c'est une
conséquence bornée, pas une preuve de panne Docker du daemon.

**FACT** — la timeline attribue l'issue directe à l'identité AzDO `Ronan JEGOU`. Cette identité
établit l'identité enregistrée par Azure DevOps; elle ne prouve pas à elle seule une intervention
manuelle de l'utilisateur.

**FACT** — le daemon réellement absent reste démontré uniquement pour le job Fix de `4444389`, où
`docker version` échoue sur `npipe:////./pipe/docker_engine` avant création du conteneur. Il ne faut
pas reporter cette preuve sur `4444720`.

**UNKNOWN** — sous-cause du blocage après pull/pendant l'initialisation, digest effectivement
inspecté par chaque job, révisions des templates externes, et transport des JMX/données.

## Décision supervisée et PR

**DECISION** — effectuer au plus un rejeu du candidat isolé existant, avec durée adaptée et suivi
jusqu'à l'état terminal; ne pas réécrire Docker. Cette décision ne constitue pas une preuve de
campagne et aucun rejeu n'est lancé dans ce lot.

**DECISION** — la PR candidate doit porter la migration complète issue de `4de185bb` et le seul
correctif XmlDiff `ef3d8703`; les diagnostics TC122, le préflight et leurs modifications JMX/YAML
sont exclus. La complétude des 5 137 chemins reste à revoir par le propriétaire source.

