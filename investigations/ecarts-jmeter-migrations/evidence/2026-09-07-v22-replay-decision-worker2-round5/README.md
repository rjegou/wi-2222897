# Décision V22 — validation finale du candidat local

Date : 2026-09-07. Aucun run ajouté, aucune définition ou branche publiée, aucune mutation distante.

## Verdict

**Candidat local prêt pour examen ; queue encore non autorisée.** Le seul obstacle décisionnel réel avant une éventuelle queue est l’approbation métier explicite. Les autres éléments non disponibles sont des preuves qui ne peuvent être produites qu’au runtime et ne doivent pas être exigés avant l’exécution.

## Chaîne stageDependencies vérifiée

- Producteur : stage `FixHistorical`, job `FixHistorical`, étape `captureBaseline`.
- Production : `Write-Host ##vso[task.setvariable variable=V22BaselineAuthSummary;isOutput=true]$b64` après comparaison baseline réussie.
- Dépendance : stage `FixCandidate` déclare `dependsOn: FixHistorical` et `condition: succeeded()`.
- Consommation : la variable de job `V22_BASELINE_AUTH_SUMMARY_B64` reçoit l’expression `$[ stageDependencies.FixHistorical.FixHistorical.outputs['captureBaseline.V22BaselineAuthSummary'] ]`, puis le template l’expose à l’étape par `env: V22_BASELINE_AUTH_SUMMARY_B64: $(V22_BASELINE_AUTH_SUMMARY_B64)`.
- Sérialisation : JSON compact encodé UTF-8 en Base64 ; aucun caractère de contrôle YAML/commande n’est introduit par le payload Base64. Le consommateur refuse une valeur vide, un Base64 invalide, un JSON invalide, un total différent de 138 + 36 ou une provenance différente (image, plugin, AuthenticationServer, backup, Core/Common/Identity historiques).
- Validation acquise : la fixture locale et les tests PowerShell 7/5.1 passent. Limite : le transfert inter-agent Azure n’a pas été exécuté ni relu ; cette preuve reste UNKNOWN jusqu’à un run autorisé.

## Préconditions classées

### À établir avant la queue

- Approbation utilisateur explicite du rejeu métier, distincte du succès de préflight.
- Définition et branche candidates choisies avec noms neutres et sans publication préalable non autorisée.
- Variables/secrets opérationnels disponibles dans le périmètre approuvé, sans apparition dans les arguments ou logs.
- Image exacte conservée : `acrretaildocker-e2c3eugzbee2habm.azurecr.io/cegid-retail-docker-production/y2-jmeter`, tag historique confirmé et digest `sha256:2684760378b395af6d4843036b8d3cfc310cfb30909e23c838c822647f4da9cb`.

### Garde-fous avant écriture dans chaque job

- Runtime local ciblé par job et image attendue ; échec fermé avant PlatformDeploy.
- Backup attendu, packages et configuration exacte ; hash du ZIP PlatformDeploy vérifié avant invocation.
- Pour `FixCandidate`, attestation baseline reçue et validée avant téléchargement JFrog ou écriture de déploiement.
- JFrog temporaire via environnement masqué, sans argument secret, restauration/suppression dans `finally` sur les exceptions PowerShell.

### Preuves produites seulement après exécution

- Transport réellement résolu entre agents Azure et valeur effectivement consommée.
- Identité des mounts/réseaux et absence de cible SQL/IIS partagée.
- Packages effectivement chargés et assembly réellement chargée par IIS.
- Résultats comparables : baseline 174 signatures (138 Legacy + 36 Web), disparition ciblée côté candidat, nouveaux échecs/tests non exécutés séparés, et campagne 232 + 144.
- Cleanup réellement exécuté ; une terminaison forcée avant `finally` reste une limite opérationnelle à surveiller.

## Périmètre d’une approbation finale

Le candidat est `replay-prep/2026-09-07-v22-isolated/`. Les effets seraient strictement limités aux conteneurs/job scopes : restauration backup, déploiement SQL/IIS, trois JMX discriminants, campagnes Legacy/Web, comparaison et collecte scrubbed, puis nettoyage. Arrêt immédiat si préflight, attestation baseline, hash package, runtime local, comptage ou comparaison échoue. Aucun tag, promotion, PR, publication d’artefact ou nettoyage distant n’est inclus.

La définition de préflight existante `14246` et la branche `investigation/wi-2222897-v22-preflight-20260907` ne sont pas la définition de rejeu. Aucun aperçu serveur non exécutant du candidat n’a été réalisé : le candidat n’est pas publié comme définition Azure DevOps, et il n’existe donc pas de validation serveur à relire sans créer ou publier une ressource. Les validations disponibles sont locales et statiques.
