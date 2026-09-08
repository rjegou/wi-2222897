# Build 4432510 — sélection image et données initiales

Date : 2026-09-06. Périmètre strict : job `TI Jmeter V26-Fix`, campagne `LegacyServices`, build 4432510. Aucun pipeline, conteneur, SQL, téléchargement ou publication lancé. Les secrets et URL masquées par Azure DevOps ne sont pas conservés.

## Image historique

FACT : l’étape `Initialize containers` (timeline log 110) exécute un pull de :

`<registre masque>/cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`

Digest affiché par Docker : `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`.

Le registre est masqué dans le log Azure ; aucun tag courant n’a été résolu. Le job démarre ensuite le conteneur avec les volumes de l’agent et du workspace. Cette image est donc la référence historique observée, et non une simple valeur YAML non résolue.

## Données initiales réellement utilisées

FACT : le log `Copy databases` (timeline log 140) trouve deux fichiers dans le checkout : `C:\__w\1\s\Y2_Plugins_FrenchTaxesRules\Tests\Backups\AUTO_V26_00.bak` et `Readme.md`, puis copie le backup vers `C:\__w\_temp\Deploy\Docker\data\AUTO_V26_00.bak`.

FACT : le log `Launch Y2 deployment` du Fix (timeline log 142) appelle `docker-pipeline-deploy.ps1` avec `-LocalDBInContainer Backup`. Le script charge `v26-Fix.cy2px`, annonce `Restore databases into container`, puis journalise `AUTO_V26_00` restaurée et ses pages traitées. Le chemin backup est donc sélectionné par le mode `Backup`, pas par des données supposées déjà incluses dans l’image.

Le `cy2px` désigne le tenant/base `TESTS_AUTO_JMETER` / `AUTO_V26_00`; la source de fichier est le checkout du build. L’empreinte du `.bak` n’est pas disponible localement et le backup n’a pas été téléchargé.

## Limites et préparation isolée

FACT : le JMeter V26 Fix s’exécute après ce déploiement dans le même job conteneurisé ; la campagne lit les JMX du checkout `Tests\LegacyServices`, dont `010-Export_Run.jmx`.

Reproduction exacte historique : possible pour image/tag/digest et mécanisme de backup, mais encore UNKNOWN pour l’identité cryptographique du backup et l’état exact du checkout distant si aucun artefact local correspondant n’est conservé.

Nouvel essai maîtrisé : figer le digest ci-dessus, le plugin `26.0.10.75`, le Core `26.0.0.1762`, `v26-Fix.cy2px`, `AUTO_V26_00.bak` avec hash vérifié, et un checkout isolé contenant le JMX corrigé. Ne pas substituer un backup ou un tag plus récent.

Action suivante unique : obtenir le hash du `AUTO_V26_00.bak` depuis un artefact déjà identifié, sans télécharger ni restaurer le fichier.
