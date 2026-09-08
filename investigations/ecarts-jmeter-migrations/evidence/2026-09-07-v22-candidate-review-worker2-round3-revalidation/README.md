# Revalidation round 3 — FrenchTaxesRules V22

Date : 2026-09-07  
Périmètre : revalidation finale des corrections locales du candidat `replay-prep/2026-09-07-v22-isolated/`. Aucun lancement métier ni mutation distante.

## Corrections vérifiées

- Le candidat conserve l'image complète `acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter`, tag historique et digest `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.
- `Invoke-V22PlatformDeploy.ps1:11-67` utilise uniquement la variable masquée `RETAIL_JFROG_API_KEY`; il reproduit le dépôt chiffré exact attendu par le CLI (`Retail-JfrogCli.json`, clé `JFROG`, AES/IV issus du code PlatformDeploy), invoque le script PS7 sans argument de clé et restaure la configuration en `finally`. Le script échoue si la révision PlatformDeploy utilise la clé ailleurs.
- La provenance du baseline est maintenant refusée avant toute écriture du job candidat par `Assert-V22BaselineAttestation.ps1`; le résumé contient image, plugin, AuthenticationServer, backup et versions historiques.
- `Assert-V22AuthorizationComparison.ps1:29-94` identifie les scénarios par labels JTL/XML et compare les catégories de signatures, avec baseline obligatoire `138 Legacy + 36 Web` puis disparition ciblée côté candidat. Les échecs non ciblés restent distincts.
- Les contrôles de readiness sont exécutés avant déploiement dans chaque variante; la vérification des packages et de `downloadedPackages.json` intervient après PlatformDeploy, avant les campagnes.

## Preuves locales

- `Test-V22ReplayFailureModes.ps1` : **PASS** sous PowerShell 7 et Windows PowerShell 5.1. La fixture inerte prouve 232+144, baseline 138+36 par scénario, attestation de provenance acceptée, candidat à zéro signature ciblée et conservation d'échecs non liés.
- `Invoke-V22RunnerDryRun.ps1` : **PASS**; préflight 32 JMX/backup/digest, orchestration, authentification JFrog temporaire, attestation, comparaison et nettoyage détectés sans SQL/IIS, JMeter ou publication.
- Analyse syntaxique PowerShell : **PASS** sur tous les scripts.
- `MANIFEST.sha256` : **PASS** après rehash de tous les fichiers manifestés.
- Recherche insensible à la casse du marqueur de nommage interdit dans le candidat et ce rapport : **0 occurrence**. Aucun nouveau nom partagé, commit, pipeline ou branche n'a été créé.

## Limites prouvées

- Le mécanisme JFrog est établi par lecture du code exact, mais aucune authentification réseau ni téléchargement réel n'a été exécuté.
- **UNKNOWN** : pull ACR, compatibilité agent/image, identité et isolation container, mounts, réseau, cibles partagées, restauration SQL/IIS et résultat JMeter.
- Les hashes ZIP et `downloadedPackages.json` établissent les entrées consommées par PlatformDeploy, pas l'assembly réellement chargé par IIS. Une preuve future doit relever les versions/hash des assemblies après installation, sans secret.
