# FrenchTaxesRules V26 — préparation exécutable round 4

Collecte du 2026-09-08, lecture locale et Azure DevOps REST. Ce dossier ne
publie aucune définition et ne lance aucun métier. Il remplace le candidat round
2 uniquement comme dossier de dépendances vérifiées ; aucun nouveau YAML avec
valeurs inconnues n'est ajouté.

## Assets et producteurs vérifiés

- **FACT** — le JMX Export corrigé est conservé hors dépôt dans
  `C:/clones/wi-2222897-evidence/local-2026-09-06-export-complete-before-after/corrected/001-Export_Run.jmx`.
  SHA-256 : `C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C`.
  La fixture source `Export_Run.xml` est dans le même lot ; cette preuve ne
  contient pas de JMX DocumentSignature_SignOne.
- **FACT** — au commit plugin `07a42172bebc65d17093e166ac08de22e4fe7248`,
  l'API Git du dépôt `Y2_Plugins_FrenchTaxesRules` expose les producteurs
  `IntegratedTests/AutoTest/Data/LegacyServices/TestPlans/Export_Run.xml`
  (objectId `96f3288059e254843d982a805c0e1af2e44df9aa`) et
  `.../DocumentSignature_SignOne.xml` (objectId
  `246a2c9b272035e602058f8eb2ee710644dd8d6a`). Ce sont les bons noms actuels,
  pas `DocumentSignatureSignOneOnly`.
- **FACT** — `DocumentSignature_SignOne.xml` source contient le cas `Code="02"`
  « Signature déjà présente », entrée `SignOne_02.xml`, avec la préparation SQL
  `MPIECECOMPL`, l'assertion `/soap:Fault/faultcode[text()='a:CBR_062_0028']`,
  puis le nettoyage SQL correspondant. Le descripteur minimal ajouté ici
  conserve exactement ces contrôles pour le cas sélectionné.
- **FACT** — le mécanisme réel de backup reste le checkout du plugin sous
  `Tests/Backups`, puis la restauration PlatformDeploy avec
  `-LocalDBInContainer Backup`; aucun backup n'est disponible dans l'archive
  locale ni dans le clone Migration_Jmeter_RJE_Sandbox (branche master réduite
  à README). Hash et disponibilité du fichier `AUTO_V26_00.bak` restent donc
  **UNKNOWN**, non assimilables à une absence distante générale.
- **FACT** — le mécanisme PlatformDeploy est le template réel
  `task-deploy-in-containerized-job.v2.yml` / `docker-pipeline-deploy-ps7.ps1`:
  téléchargement JFrog du ZIP, extraction, puis invocation dans le job
  containerisé. La version V26 réellement résolue et son SHA-256 ne sont pas
  fournis par les preuves FrenchTaxesRules ; le `5.0.86` documenté pour un
  autre run ne peut pas être réutilisé par inférence.

## Garde-fous

Les effets admissibles d'une future définition dédiée sont limités au job
containerisé, à la base/IIS dédiés et au nettoyage ciblé de `Agent.TempDirectory`.
Les tâches de feed partagé, staging, promotion, tag et TestAutos sont interdites.
L'image V26 historique est connue par digest, mais agent compatible, connexion
registre, mounts et cibles runtime doivent encore être attestés avant la queue.

## Verdict

Le descriptor TC02 est prêt pour revue, le JMX Export est vérifié et les
producteurs Git des descripteurs sont identifiés. La chaîne complète n'est pas
encore exécutable : backup hashé, JMX SignOne généré/consommable, package
Console/API aligné, PlatformDeploy V26 et attestation runtime manquent. Ne pas
publier ni lancer Build/JMeter tant que ces entrées ne sont pas reçues.
