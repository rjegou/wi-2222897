# Revue indépendante du candidat FrenchTaxesRules V22 — Worker 2 round 4

Date : 2026-09-07 (Europe/Paris)
Périmètre : lecture seule du candidat `replay-prep/2026-09-07-v22-isolated/`, de ses scripts et des artefacts V22 historiques. Aucun pipeline, service, restauration, branche ou définition n'a été lancé/créé.

## Verdict

**NOT READY / non exécutable de manière prouvée.** Le candidat contient plusieurs arrêts fail-closed, mais aussi des chemins et une gestion des secrets incompatibles avec une exécution sûre. Aucun résultat de replay candidat n'est présent.

## Défauts précis

1. **Commit templates impossible.** `azure-pipelines.candidate.yml:49` transmet `-TemplatesCommit INLINE_LOCAL_STEPS`, alors que `scripts/Preflight-V22FrenchTaxesRules.ps1:16-18` exige un SHA-1 40-hex et rejette toute autre valeur. La définition s'arrêterait avant les tests.
2. **PlatformDeploy non résolu.** `azure-pipelines.candidate.yml:10-11` conserve `PLATFORM_DEPLOY_VERSION_REQUIRED` et `PLATFORM_DEPLOY_ZIP_SHA256_REQUIRED`; `:45` provoque donc un arrêt avant téléchargement. `steps-replay-variant.yml:30-46` ne peut pas fournir une version/hash exacts par lui-même.
3. **Chemin de script non garanti.** `azure-pipelines.candidate.yml:44-49` cherche le script d'investigation sous `$(Build.SourcesDirectory)\investigations\...`. Le checkout `self` est le dépôt plugin; le dossier d'investigation n'est pas prouvé dans ce dépôt. Le YAML candidat local n'est pas installé dans un dépôt/une définition.
4. **Secret en argument de processus.** `steps-replay-variant.yml:47` transmet `$(RetailJfrogApiKey)` à `docker-pipeline-deploy.ps1` et active `-verbose`. Même sans publication d'artefact, l'exposition dans ligne de commande, logs ou erreurs n'est pas exclue.
5. **Secret écrit en clair.** `steps-replay-variant.yml:55` écrit `USERNAME=$(testAutoUserName)` et `PASSWORD=$(testAutoPassword)` dans `parameters.properties`. Le nettoyage `:64-66` est postérieur et conditionnel à la fin du job; il ne protège ni les logs d'échec, ni les dumps, ni les copies temporaires. La suppression de `PublishPipelineArtifact` ne prouve donc pas l'absence de fuite.
6. **Isolation locale insuffisante.** `Assert-V22LocalContainerRuntime.ps1:10-26` vérifie `TF_BUILD`, `COMPUTERNAME`, processus SQL/IIS et ports 80/1433, puis crée un marqueur. Il ne prouve pas l'identité/cycle de vie du container, l'image réellement chargée, l'absence de volumes/montages, ni l'absence de ressources partagées.
7. **Compatibilité agent/container/image non établie.** Les jobs déclarent `container: v22Jmeter` et `pool: windows-latest` (`azure-pipelines.candidate.yml:18-21`, `:36-37`, `:60-61`, `:75-76`), mais aucune preuve live de compatibilité Windows Server Core LTSC2025, de l'endpoint ACR ou du daemon/container n'est jointe.
8. **Restauration et IIS/SQL non comparables.** Le déploiement utilise `-LocalDBInContainer Backup` (`steps-replay-variant.yml:47`) et réemploie `AUTO_V21_00` (`:55`), mais aucune sortie ne prouve avant/après le hash de backup restauré, l'identité des bases, la séparation Fix/Candidate ou la configuration IIS finale.

## Sorties et secrets examinés

- Le dossier candidat contient 7 fichiers, aucun `.jtl` ou log JMeter de replay.
- Le dossier Worker 3 disponible contient 4 fichiers, aucun résultat de replay.
- Scan borné des artefacts historiques V22 : 753 fichiers, dont 125 `.log`, 88 `.jtl` et 6 `parameters.properties`. Des motifs de secrets ont été détectés dans 101 fichiers (3213 occurrences); aucun contenu, jeton ou claim n'a été affiché, copié ou ajouté à cette preuve. Ces fichiers bruts doivent être traités comme sensibles et ne peuvent alimenter une conclusion sans extraction expurgée.

## Baseline/candidat et comptage

Les paramètres annoncés restent identiques pour plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, backup et JMX, avec variantes Fix `Core 22.0.0.1011/Common 22.0.2.300/Identity 22.0.5.182` et Candidate `22.0.0.2068/22.0.3.311/22.0.6.117`; ce sont des paramètres déclaratifs, pas une preuve de consommation. Aucun run candidat n'étant présent, le delta baseline/candidat, les trois opérations discriminantes et le total 232+144=376 restent **UNKNOWN**.

## Résultats expurgés exigés avant conclusion

Pour chaque variante et chaque opération, conserver uniquement : status HTTP de l'acquisition, booléen token présent, compteurs/présences booléennes des scopes `allowedModule` attendus, empreintes et versions des assemblies chargées, code HTTP/métier, booléens `CBP50101`, `ID4266`, `FailedAuthentication`, assertion JMeter et durée. Aucun token, claim complet, mot de passe, URL secrète ou payload sensible.

Le minimum est : `FrenchTaxesRules:Run`, `SetDocumentErrorReason`, `Purge:Execute`, puis les compteurs Legacy/Web et 376, avec baseline Fix et Candidate sur données restaurées séparément et mêmes JMX.

## Risque triggers / définition dédiée

Le fichier candidat contient `trigger: none`, `pr: none`, `schedules: []` (`azure-pipelines.candidate.yml:1-4`), ce qui réduit le risque de déclenchement automatique. Cela ne couvre pas une création de branche/définition : il faut vérifier les triggers de la définition cible, les ressources repository/containers, les permissions et les pipelines aval avant toute création. Aucune branche ni définition n'a été créée dans cette revue.
