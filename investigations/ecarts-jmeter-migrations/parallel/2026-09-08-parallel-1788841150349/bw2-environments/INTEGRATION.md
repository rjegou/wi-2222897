# Proposition d'intégration

1. Conserver `finding014` comme constat causal partiel : `PopulateStatus=1` est établi, la cause FDHOST/crawl/configuration/espace reste `UNKNOWN`.
2. Reprendre uniquement le patch local `6C6FD9EC35AD02DA4B71DB8562888BB479441BCC44BED78D4B169E7DB66E21B3` pour une queue dédiée autorisée; ne pas augmenter le timeout par défaut.
3. Exiger comme postcondition Full-Text `PopulateStatus=0`, hit `CONTAINSTABLE` et cleanup vérifié. Si l'un manque, ne pas conclure à une image corrigée.
4. Documenter la chaîne image SQL→Y2-JMeter comme routage par tags seulement. Exiger une preuve de digest et de provenance du package/image avant d'attribuer un contenu à un build JMeter.

Aucune modification des documents communs, branche, définition, registry, feed ou image partagée n'a été réalisée.

## PlatformDeploy — proposition

1. Intégrer séparément le patch local `e20c50acf33d11d8bba1cd10facb89dfd4bd4902` après revue du propriétaire du dépôt; conserver le contrat actuel `deploy.ps1 -> exit $LASTEXITCODE -> init-container.ps1`.
2. Faire remonter dans l'attestation du runner la version PlatformDeploy réellement extraite, le code retour de déploiement, les logs MSI et le verdict health check; ne pas déduire un succès migration d'un job tolérant les tests.
3. Maintenir `$nbErr -gt 0` comme garde unique; ne pas ajouter de doublon dans PlatformDeploy ou le workflow.
4. Garder Full-Text bloqué jusqu'à `PopulateStatus=0`, résultat `CONTAINSTABLE` positif et cleanup confirmé. Garder l'attestation `Agent.ContainerMapping` et le transport fixture en `UNKNOWN` tant que le runtime exact n'est pas prouvé.
5. Pour vérifier le patch sans registry, construire une archive privée selon `job-build.platformDeploy.yml` (`CopyFiles` → `ArchiveFiles`), l'extraire dans un staging isolé, vérifier le hash de `Scripts/init-container.ps1`, puis exécuter le harness `TF_BUILD=true`. Cette preuve de contenu ne remplace pas une preuve de package consommé par le runner.
6. Conditions d'un futur rejeu métier: attestation hôte/consommateur validée avant download/restore/deploy; version PlatformDeploy et archive hashées; code retour MSI nul; health checks non tolérés; fixtures présentes à un chemin réel et hashé; seulement ensuite SQL/IIS/JMeter et postcondition métier.

7. Le packaging privé Round 4 prouve seulement la conservation du correctif entre source et extraction. Pour toute preuve de consommation, le runner doit publier dans son attestation la version extraite, le hash de l'archive et le hash du script effectivement lancé. La lecture AzDO fraîche des trois builds est restée UNKNOWN pour cause TLS local.

8. Le worker 1 entreprend un nouveau preflight autorisé; son résultat n'est pas disponible ici et ne doit pas être anticipé dans cette consolidation.
