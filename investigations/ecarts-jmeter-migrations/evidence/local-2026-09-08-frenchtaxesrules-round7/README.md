# FrenchTaxesRules — inventaire et préflight V26 (round 7)

## Provenance

- Collecte : 2026-09-08, dépôt documentaire `C:\clones\wi-2222897`.
- Source des plans : dépôt Azure DevOps `Y2_Plugins_FrenchTaxesRules`, commit `07a42172bebc65d17093e166ac08de22e4fe7248`.
- Générateur observé : Console 2.0.43 du build 4445025, artefact 5037277 ; API 1.1.47 candidate du build 4444765, commit `9081ecfe7aa07f5e584073d2af1828d3ac9f7235`.
- Preuve de sortie détaillée : `../build-4445025-jmx-generation/manifest-observed.json` et `jmx-hashes.tsv`.

## FACT — origine du compteur 32

Le compteur fixe vient du script `migration-tools/Write-Wi2222897JmxManifest.ps1` au commit `c5aebe9a31ff23370ac6df196c8475970b97db3f`, ligne 26 : `if ($jmx.Count -ne 32)`. Le commit introduit ce nombre sans inventaire source ni table de correspondance. Le script compte les fichiers XML/JMX sous les racines qui lui sont passées ; il ne dérive pas 32 d'un catalogue de plans.

## FACT — inventaire source et sorties

Le commit source contient 19 `TestPlans/*.xml` au premier niveau :

`LegacyServices` (10) : `Closing_AnnualClosing`, `Closing_DailyRegisterClosing`, `Closing_DailyStoreClosing`, `Closing_MonthlyClosing`, `DocumentSignature_GetCustomerSigningVersion`, `DocumentSignature_GetDaemonSigningVersion`, `DocumentSignature_SignOne`, `EventSignature_Sign`, `Export_Run`, `FrenchTaxesRules_Run`.

`WebServices` (9) : `Purge_CreateParam`, `Purge_Execute`, `Purge_GetParam`, `Validation_ExportNf525`, `Validation_GetFrenchStores`, `Validation_ValidateClosingsV2`, `Validation_ValidateDocuments`, `Validation_ValidateEvents`, `Validation_ValidateParam`.

La génération Console a produit exactement une sortie JMX pour chacune de ces 19 entrées, code retour 0. Les chemins et SHA-256 de toutes les sorties sont dans `../build-4445025-jmx-generation/jmx-hashes.tsv`; le manifeste observé conserve aussi les hashes des XML source. Les JMX minimaux sont `generated-jmx/Export_Run/001-Export_Run.jmx` (SHA-256 `C59BD01D5C075961A781335D746A4F72B2CB331EC955CE828D4F6DE4C850EB0C`) et `generated-jmx/DocumentSignature_SignOne/001-DocumentSignature_SignOne.jmx` (SHA-256 `432AA8C477E875652D4A4991D84DB19DB0B3790469EB2DE81212F85F0F341AE9`).

## Verdict de périmètre

- **FACT** : 19 plans source correspondent nominativement à 19 sorties JMX ; aucune omission n'est démontrée pour ce périmètre.
- **FACT** : le validateur 32 ne fournit pas de correspondance avec 13 plans supplémentaires.
- **INFERENCE** : pour le commit source `07a42172`, l'attente 32 est erronée ; il ne faut pas qualifier 13 fichiers de manquants ni fabriquer des sorties.
- **UNKNOWN** : une campagne externe ou un autre périmètre métier pourrait viser 32 ; il faut alors fournir son inventaire nominatif avant d'étendre le validateur.

## Entrées V26 et préflight

- **FACT** : la branche historique `FrenchTaxesRules_Migration_AutoTest_Jmeter_On_master`, commit `f80bc731571b2b5ed8a67da171b288873de428a6`, référence l'image `cegid-retail-docker-production/y2-jmeter:sqlexpress2025-y2-aspnet-10-windowsservercore-ltsc2025`, digest historique `sha256:ea74f21a0d2ac3653ff843b393f6e97571500f6b41b2c2f71e94da23c0a9dbf2`.
- **FACT** : l'objet Git-LFS du backup `/Tests/Backups/AUTO_V26_00.bak` à ce commit est de taille 150765568 octets et porte l'identifiant LFS SHA-256 `23bfb0b670918fbe5f63ceeff36f66ef1855b46fd82c29bda9d34dfa6b7fc25f` ; le backup n'a pas été téléchargé ni restauré.
- **FACT** : les configurations distantes sont accessibles au commit historique ; hashes de contenu collectés en mémoire uniquement : `v26-cur.cy2px` = `ed9558c530bd683b6cc6e8aca802c00e687ed0ded01b3ee888da4a097b8d4922`, `v26-fix.cy2px` = `463bccc2e3d5e28694dafcdc9fa3200b635055db00da35cf712eb6826c00e3ef`, respectivement 1819 et 1850 octets.
- **FACT** : le build 4423394 de la définition 2054 était encore signalé `inProgress` lors de la dernière lecture ; aucune nouvelle queue n'a été lancée afin d'exclure un chevauchement.
- **UNKNOWN** : l'accès effectif actuel à l'image/digest, au pool capable de conteneurs, à la service connection `AzureContainerRegistry-Docker-Retail`, et aux destinations temporaires backup/PlatformDeploy n'est pas prouvé par cette collecte.
- **BLOCKER** : le YAML historique de la définition 2054 contient des effets partagés (Artifactory, Promote, TestAutos et publication de logs) et ne peut pas servir tel quel de pipeline isolé. Aucun YAML autonome à références résolues n'a été publié ni exécuté dans ce lot.

## Limites et suite autorisée

Aucun push, publication de feed partagé ou queue V26 n'a été effectué. La prochaine étape doit résoudre les références runtime (pool/image/service connection/destinations), rédiger un YAML autonome sans triggers/schedules ni Promote/Tag/TestAutos/Artifactory partagé, puis contrôler les runs actifs avant un unique préflight. Les tests JMeter restent **UNKNOWN** : génération JMX et préflight ne sont pas un résultat métier.
