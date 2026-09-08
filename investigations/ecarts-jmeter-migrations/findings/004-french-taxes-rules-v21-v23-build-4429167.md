# FrenchTaxesRules releases/V5 V21 à V23 — analyse du build 4429167

Date de l'analyse : 2026-09-05.

## Complément du 2026-09-07 — conseil de Ludo et packaging supérieur

**Statut : candidat disponible, correction non validée.** La lecture Git/Azure DevOps puis JFrog authentifiée a identifié le packaging `22.0.23`. Voir la [synthèse de collecte datée](../evidence/2026-09-07-jfrog-v22-packaging/README.md) pour les chemins, empreintes serveur, méthodes et limites.

| Composant | Fix historique rouge | Candidat issu de 22.0.23 | Cur historique vert |
|---|---|---|---|
| Y2.Core | 22.0.0.1011 | 22.0.0.2068 | 22.0.0.2096 |
| Y2.Core.Common | 22.0.2.300 | 22.0.3.311 | 22.0.3.315 |
| Y2.Plugin.Identity | 22.0.5.182 | 22.0.6.117 | 22.0.6.171 |

**FACT** — le manifeste du packaging et les trois ZIP individuels sont présents dans `retail-software-production`. Le manifeste référence toutefois FrenchTaxesRules `22.0.6.379` et AuthenticationServer `1.0.1.429` (`OnPremOnly`), tandis que le build étudié utilise FrenchTaxesRules `22.0.6.478` et AuthenticationServer `2.0.0.368` en Cur comme en Fix.

**INFERENCE** — relever le trio Core/Common/Identity peut rétablir les droits absents de Fix. Cette hypothèse explique pourquoi un même plugin passe en Cur et rencontre 174 refus en Fix. Elle ne démontre ni le composant causal exact ni le minimum compatible.

**UNKNOWN** — compatibilité du trio candidat avec FrenchTaxesRules 22.0.6.478, contenu réel des ZIP et réussite métier. Une présence en production, un manifeste et un build réussi ne ferment pas ces points.

### Complément du 2026-09-07 — installation historique versus consommation effective

**FACT** — les journaux MSI du build 4429167 prouvent l'installation historique des versions Cur/Fix, avec statut Windows Installer `0` :

- Fix : Core `22.0.0.1011` (`../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/CBRCPTX.log:1016`), Common `22.0.2.300` (`../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/E_IIS_SERVER_RETAIL_Common.log:1301` et `../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/WORKER_PROCESS_RETAIL_Common.log:1216`), Identity `22.0.5.182` (`../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/E_IIS_SERVER_RETAIL_IDENTITY.log:1431` et `../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/WORKER_PROCESS_RETAIL_IDENTITY.log:1237`), FrenchTaxesRules `22.0.6.478` (`../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/E_IIS_SERVER_RETAIL_FRENCHTAXESRULES.log:1289` et `../evidence/build-4429167/_extracted/v22-Fix_Deployment_logs-runnervm0u1xh-Attempt#1/CPTX_FRENCHTAXESRULES.log:977`).
- Cur : Core `22.0.0.2096` (`../evidence/build-4429167/_extracted/v22-Cur_Deployment_logs-runnervm0u1xh-Attempt#1/CBRCPTX.log:1016`), Common `22.0.3.315` (`../evidence/build-4429167/_extracted/v22-Cur_Deployment_logs-runnervm0u1xh-Attempt#1/E_IIS_SERVER_RETAIL_Common.log:1384`), Identity `22.0.6.171` (`../evidence/build-4429167/_extracted/v22-Cur_Deployment_logs-runnervm0u1xh-Attempt#1/E_IIS_SERVER_RETAIL_IDENTITY.log:1425`), FrenchTaxesRules `22.0.6.478` (`../evidence/build-4429167/_extracted/v22-Cur_Deployment_logs-runnervm0u1xh-Attempt#1/E_IIS_SERVER_RETAIL_FRENCHTAXESRULES.log:1289`).

Ces lignes prouvent une installation MSI réussie et les versions enregistrées par les installateurs. Elles ne prouvent pas, à elles seules, que le service ayant refusé les appels a effectivement consommé chaque binaire, que le catalogue de droits a été chargé dans cet environnement, ni que la projection `allowedModule` a produit les claims attendues.

La conclusion antérieure sur l'absence des claims dans le jeton Fix est conservée comme **FACT rapporté par l'analyse expurgée existante** (`findings/004`, lignes 97-103). Aucun jeton ni secret n'a été consulté dans cette reprise. Les logs bruts démontrent directement `ClaimsPrincipalPermission`, `ID4266` et `CBP50101`, mais pas la valeur complète des claims.

**Verdict arbitré** — versions installées : `FACT` pour l'installation MSI historique ; consommation effective et projection du catalogue : `UNKNOWN`. La cause exacte reste `UNKNOWN` au niveau composant. L'incompatibilité de pile Core/Common/Identity demeure une `INFERENCE` forte, pas une correction démontrée.

### Leçons et recommandations pour la validation

1. Dans ce cas, Fix désigne des dépendances épinglées ; ne pas interpréter son nom comme une version nécessairement plus récente. « Packaging supérieur » signifie ici chercher une combinaison supérieure dans la famille V22, sans changer de version majeure.
2. Distinguer authentification et autorisation : les acquisitions de jeton passent ; rechercher les droits absents et les refus sur les opérations. Ne pas modifier les assertions pour rendre les tests verts.
3. Préparer un avant/après sur des cibles dédiées, avec les mêmes JMX, plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, configuration, image épinglée et backup hashé, restauré séparément pour chaque variante. Changer uniquement le trio. Il s'agit d'un candidat dérivé du packaging, pas du packaging intégral validé.
4. Reproduire d'abord les refus historiques. Contrôler installation et santé, puis un cas auparavant rouge de `FrenchTaxesRules:Run`, `SetDocumentErrorReason` et `Purge:Execute`. Collecter présence/absence des droits attendus, identités effectives et assertions métier, jamais les jetons bruts.
5. Si les trois cas passent, rejouer les 376 tests V22 pour détecter les effets de bord. Sinon, la pile Cur historique épinglée constitue un contrôle supplémentaire. Si même la baseline ne reproduit pas le défaut, conserver la causalité UNKNOWN jusqu'à résolution de la comparabilité.
6. Un succès valide le trio dans le contrat testé, pas la dépendance individuellement responsable ni la version minimale supportée. Une investigation complémentaire de versions est nécessaire pour ces deux conclusions.
7. Ne pas appliquer cette conclusion au blocage Docker V23 Fix, aux échecs communs Cur/Fix des autres branches, ni au rejeu Export_Run V26. Clienteling V22/V23 présente des incompatibilités MSI distinctes, à traiter selon la fiche 005.

Aucun correctif, test métier, nouveau déploiement ou rejeu n'a été réalisé dans cette investigation packaging. Le prompt opérateur remis à l'utilisateur propose les tests isolés ci-dessus ; sa rédaction ne constitue ni leur exécution ni une validation. La présente mise à jour est documentaire : préserver les worktrees et snapshots, aucune publication/promotion/tag ni cible partagée.

## Verdict

- V21 : aucune campagne JMeter exécutée ; le stage est `skipped` par conception dans le YAML du build.
- V22 Cur : 376 tests publiés, 376 passés.
- V22 Fix : 376 tests publiés, 202 passés et 174 non passés, tous couverts par une même famille d'autorisation. La capture ne comptait que les 138 LegacyServices et omettait les 36 WebServices.
- V23 Cur : 376 tests publiés, 376 passés.
- V23 Fix : aucun test JMeter exécuté ; le job échoue dans `Initialize containers` parce que `docker version` ne peut pas joindre le moteur après trois tentatives.

Les deux problèmes Fix sont distincts : une incompatibilité de droits avec les dépendances minimales V22 et une panne d'infrastructure Docker avant déploiement en V23.

## Exécution réellement observée

| Version | Variante | Campagne | Run | Total | Passed | Non passés | Verdict |
|---|---|---|---:|---:|---:|---:|---|
| 21 | Cur/Fix | Legacy/Web | aucun | 0 | 0 | 0 | stage skipped |
| 22 | Fix | LegacyServices | 6177995 | 232 | 94 | 138 | autorisation refusée |
| 22 | Fix | WebServices | 6178043 | 144 | 108 | 36 | autorisation refusée |
| 22 | Cur | LegacyServices | 6178032 | 232 | 232 | 0 | vert |
| 22 | Cur | WebServices | 6178055 | 144 | 144 | 0 | vert |
| 23 | Cur | LegacyServices | 6178035 | 232 | 232 | 0 | vert |
| 23 | Cur | WebServices | 6178058 | 144 | 144 | 0 | vert |
| 23 | Fix | Legacy/Web | aucun | 0 | 0 | 0 | arrêt avant JMeter |

Sur ces runs, Azure laisse `failedTests` nul et renseigne les cas non passés dans `unanalyzedTests`. Les CSV publiés confirment zéro ligne d'erreur en Cur, 138 en Legacy Fix et 36 en Web Fix.

Trois petits runs de deux tests appartiennent au stage de build et ne sont pas des campagnes JMeter ; ils sont exclus du tableau.

## V22 Fix — couverture des 174 refus

### LegacyServices : 138 fois la même faute d'autorisation

| Plan | Nombre |
|---|---:|
| Closing:AnnualClosing | 3 |
| Closing:AnnualGlobalClosing | 4 |
| Closing:DailyRegisterClosing | 13 |
| Closing:DailyStoreClosing | 8 |
| Closing:DailyStoreGlobalClosing | 4 |
| Closing:MonthlyClosing | 4 |
| Closing:MonthlyGlobalClosing | 6 |
| DocumentSignature:Sign | 20 |
| DocumentSignature:GetCustomerSigningVersion | 3 |
| DocumentSignature:GetDaemonSigningVersion | 3 |
| EventSignature:Sign | 32 |
| FrenchTaxesRules:Run | 38 |
| **Total** | **138** |

Tous échouent sur B-XQuery avec un fault SOAP `a:InternalError`, une `System.Security.SecurityException`, l'identifiant CBP50101 et le message ID4266 indiquant que `ClaimsPrincipalPermission` est refusée. Le code du commit du build demande `Resource="allowedModule"` et `Operation="FrenchTaxesRules"` sur ces adaptateurs Legacy.

### WebServices : 36 fois `FailedAuthentication`

| Plan | Nombre | Droit demandé par le code |
|---|---:|---|
| Validation:SetDocumentErrorReason | 8 | validation write et `FrenchTaxesRules` |
| Validation:SetClosingErrorReason | 8 | validation write et `FrenchTaxesRules` |
| Validation:SetEventErrorReason | 8 | validation write et `FrenchTaxesRules` |
| Validation:SetOtherErrorReason | 7 | validation write et `FrenchTaxesRules` |
| Purge:Execute | 5 | `french-tax-rules-purge:execute` |
| **Total** | **36** | |

Tous échouent sur B-XQuery avec `a:FailedAuthentication` et `Access is denied.` Les 108 autres tests Web passent.

### Authentification réussie, autorisation refusée

- Les 232 acquisitions de jeton Legacy Fix et les 144 acquisitions Web Fix répondent toutes HTTP 200 et sont marquées réussies par JMeter.
- Les propriétés de connexion utilisent les mêmes identifiants de test en Cur et Fix ; seule leur égalité a été vérifiée, sans exposer les valeurs.
- Les jetons sont des JWT et présentent les mêmes noms de claims généraux.
- Le jeton Fix ne contient ni la valeur `FrenchTaxesRules` ni `french-tax-rules-purge:execute` dans `allowedModule`.
- Cette absence couvre exactement 138 appels Legacy, 31 appels Set Web et 5 appels Purge, soit les 174 cas non passés.

**FACT — les requêtes sont authentifiées mais leurs droits sont insuffisants pour les opérations exécutées.** Ce n'est ni une indisponibilité d'AuthenticationServer ni 174 régressions fonctionnelles indépendantes.

## Différence de dépendances V22

| Package | Cur | Fix |
|---|---|---|
| Y2.Core | 22.0.0.2096 | 22.0.0.1011 |
| Y2.Core.Common | 22.0.3.315 | 22.0.2.300 |
| Y2.Core.AuthenticationServer | 2.0.0.368 | 2.0.0.368 |
| Y2.Plugin.Identity | 22.0.6.171 | 22.0.5.182 |
| Y2.Plugin.FrenchTaxesRules | 22.0.6.478 | 22.0.6.478 |

Le fichier `Tests/Config/v22-fix.cy2px` épingle les trois versions Fix plus anciennes. Cur sélectionne les dernières versions 22.0 disponibles. Les journaux AuthenticationServer ont les mêmes signatures et volumes d'événements en Cur et Fix, ce qui renforce la séparation entre émission du jeton et autorisation dans l'application.

**INFERENCE FORTE — incompatibilité de la pile minimale Fix avec le catalogue ou la projection des droits attendus par FrenchTaxesRules 22.0.6.478.** Les artefacts prouvent le droit absent ; ils ne permettent pas seuls de trancher entre un défaut dans Identity/Core, un catalogue de droits incomplet dans le déploiement minimal et une version minimale devenue obsolète.

## Correctif et rejeu V22

Propriétaire initial : configuration de compatibilité FrenchTaxesRules V22 et composants Identity/Core responsables des droits `allowedModule`.

1. Sur un déploiement Fix propre, comparer le catalogue de droits et les valeurs `allowedModule` aux opérations demandées par le commit 2d826b8f.
2. Si les versions épinglées restent supportées, provisionner les droits manquants ou corriger leur projection dans le jeton.
3. Sinon, relever les minima de `v22-fix.cy2px` jusqu'à une combinaison supportée et documenter cette décision.
4. Rejeu minimal : un cas Legacy `FrenchTaxesRules:Run`, un cas Web `SetDocumentErrorReason` et un cas `Purge:Execute`. Vérifier acquisition du jeton, présence du droit attendu, puis absence de CBP50101/FailedAuthentication.

## V23 Fix — arrêt d'infrastructure avant test

La timeline exécute `TI Jmeter V23-Cur` avec succès, puis démarre `TI Jmeter V23-Fix`. La tâche `Initialize containers` tente trois fois `docker version`, attend dix secondes entre les essais, puis échoue avec le code 1. Les tâches ultérieures marquées en échec sont des conséquences de l'absence de conteneur. Aucun run V23 Fix n'est publié.

**FACT — infrastructure/agent Docker.** Ne pas compter ce job comme échecs de tests ni lui appliquer la cause d'autorisation V22. Le rejeu minimal est le job V23 Fix sur un agent dont le moteur Docker répond, après vérification indépendante de `docker version`.

### Complément du 2026-09-07 — handoff manuel, détail par agent (non revérifié)

**Non revérifié dans ce processus.** Un addendum manuel reçu hors `brain-worker`, rangé sous [`evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/`](../evidence/local-2026-09-07-soap-xpath-negative-validation-handoff/README.md) (fichier `WI-2222897_JMeter_Legacy_Handoff_Addendum_2026-09-07.md`), rapporte sur ce même build `4429167` V23-Fix, sans preuve jointe revérifiée ici :

- **FACT rapporté** — le log causal exact serait `Log ID 449`, avec le message `failed to connect to the docker API at npipe:////./pipe/docker_engine ... The system cannot find the file specified`.
- **FACT rapporté** — `V23-Cur` (réussi) aurait tourné sur `workerName: Azure Pipelines 51`, `V23-Fix` (échoué sur `Initialize containers`) sur `Azure Pipelines 21` ; d'autres jobs du même build auraient initialisé Docker avec succès sur `Azure Pipelines 41` et `53`.
- **INFERENCE rapportée** — l'agent `21` serait défaillant ou dans un état Docker transitoire, plutôt qu'un défaut de migration JMeter ou de packaging Fix.
- **Écart non reconcilié avec le canonique ci-dessus** — cette source indique **quatre tentatives** `docker version` avant l'échec ; la ligne canonique ci-dessus (établie le 2026-09-05) indique **trois tentatives**. Ne pas trancher cet écart sans relire directement le log `4429167` / `449`.

**Verdict arbitré** — la cause racine « infrastructure/agent Docker » reste inchangée et confirmée en substance par cette source. Le détail par agent (`21` contre `51`/`41`/`53`) et le `Log ID 449` sont un raffinement plausible mais non revérifié ; l'écart trois/quatre tentatives doit être résolu avant de citer l'un ou l'autre chiffre comme `FACT`. Ne pas modifier la ligne « V23 Fix » du tableau « Exécution réellement observée » ci-dessus sur cette seule base.

## Dérive postérieure au build

La branche distante a avancé de 2d826b8f à d3124c89 par un seul commit `Updated azure-pipelines.yml`. Ce commit retire V21 de la liste par défaut et simplifie les conditions des stages, mais ne modifie ni les packages V22 Fix ni les droits. Aucun nouveau build de cette branche n'a été trouvé après 4429167 ; ce changement n'est pas une preuve de correction.

## Intégrité des preuves

Les artefacts WebServices contiennent une copie byte-identique des 98 fichiers LegacyServices déjà publiés séparément, en Cur comme en Fix. Ces copies ont été exclues. Le snapshot source local correspond au commit 2d826b8fd19ecb4d7200f574414efb7583de8ed2 ; il a été exporté avec Git LFS, sans modifier la branche distante.

## Preuve legacy aval récupérée le 2026-09-06

Les deux XML d'exécution listés dans `../evidence/legacy/curated/02_FRENCH_TAXES_RULES/V5.md`, `Y2_Plugins_FrenchTaxesRules_V5_test.6.473-20260807_083330.xml` et `Y2_Plugins_FrenchTaxesRules_V5_test.6.480-20260904_073359.xml`, démarrent `execute.plugin` puis s'arrêtent avant MSTest : le dossier `override\Y2_Plugins_FrenchTaxesRules_V5` est absent. FACT — zéro scénario legacy est exécuté dans ces deux captures. UNKNOWN — elles ne portent pas les mêmes versions/packages que les campagnes JMeter V21-V23 et ne fournissent aucune baseline comparable pour les 174 refus V22 Fix ou le blocage V23 Fix.

## Complément du 2026-09-07 — prérequis artefacts du rejeu V22

La collecte détaillée est indexée dans `../evidence/2026-09-07-v22-replay-prereqs/README.md`.

**FACT** — le snapshot du build 4429167 contient uniquement `Tests/Backups/AUTO_V21_00.bak` (150515712 octets, SHA-256 `3F80B46422D07FE3673AA3A8ECCD7FDFF66468ABC438A3A7E73DDC95466DB2E2`). Le pipeline transmet ce dossier au déploiement et utilise `DB_NAME=$(backupName)` ; la valeur de `backupName` n'est pas résolue dans le YAML disponible. Il est donc incorrect d'exiger par principe un backup nommé V22.

**FACT** — `LegacyServices.xml` sélectionne 12 JMX et `WebServices.xml` 20 JMX. Les trois cas du rejeu discriminant sont identifiés et hashés dans la collecte. **UNKNOWN** — restauration SQL, base réellement contenue, substitutions finales SQL/IIS et possibilité opérationnelle sur une cible dédiée.

**FACT** — `ExternalsToRestore_V22.xml` déclare Core `22.0.0.1012`, tandis que les packages/journaux Fix du build identifient Core `22.0.0.1011`. Cette divergence doit être contrôlée avant tout rejeu ; elle ne permet pas d'attribuer la cause.

**FACT** — la revalidation JFrog antérieure n'a créé/conservé qu'un README de synthèse dans son dossier ; aucun ZIP, JSON brut ou fichier de hashes séparé n'y est conservé. Les trois SHA-256 sont transcrits dans ce README. Cette revalidation n'est donc pas une preuve de disponibilité locale des ZIP.

**Suite sûre** — obtenir une cible dédiée explicitement autorisée, résoudre `backupName` et les paramètres sans exposer de secrets, vérifier la capacité SQL/IIS, puis restaurer séparément Cur et Fix avec manifeste/hash. Aucun lancement ni restauration n'a eu lieu.

## Complément du 2026-09-07 — audit du brouillon exécutable

La proposition locale est `replay-prep/2026-09-07-v22-isolated/`. Le préflight vérifie désormais le SHA-256 du backup, une attestation JSON sans secret portant le périmètre WI, les hôtes SQL/IIS et leur non-partage, la restauration séparée par variante, les 32 JMX historiques, les 32 JMX générés et les versions constantes plugin/AuthenticationServer. Le test négatif local a refusé l'absence d'attestation avant toute écriture.

Les fichiers templates locaux ont été hashés (`task-run-campaign.v1.yml` SHA-256 `3B4044C54A3F39086A356FD5BDDB0405781911D4423CA89E133E2AC3A6B6B9B1`, `task-deploy-in-containerized-job.v2.yml` SHA-256 `B35C4A493A85245E2C823172F53925421D92F89DD829A51E7765FD8CFA3C1940`), mais leurs commits appartiennent à deux worktrees différents et ne prouvent pas le commit approuvé du dépôt `Pipelines_Templates`. Le placeholder `TEMPLATES_COMMIT_REQUIRED` est donc conservé. **UNKNOWN** — targets résolues, restauration, packages acquis dans le run et résultat final `jmeter -t`.

Le préflight accepte désormais les 32 JMX historiques comme entrées directes ; il n'exige pas de régénération. Le runner local est confirmé statiquement jusqu'à `jmeter.bat -n -t` (script `jmeter-cli.ps1`, lignes 161-169), sans exécution métier.

## Complément du 2026-09-07 — handoff manuel, piste DLL d'autorisation

**Non revérifié dans ce processus.** Un handoff manuel reçu hors `brain-worker` est rangé sous [`evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/`](../evidence/local-2026-09-07-french-taxes-rules-v22-authorization-handoff/README.md). Il rapporte, sans preuve jointe revérifiée ici :

- **FACT rapporté** — Fix charge `Cegid.Erp.Services.Implementation 12.9.153.1506` au runtime, Current charge `12.9.185.17`. Cette DLL provient d'un NuGet externe `FWK-CEGID-NET-FULL`, restauré par `ExternalsToRestore.xml` de `Y2_Core` dans `Packages\CBP.Net`, et non embarqué dans `Y2_Core` lui-même.
- **FACT rapporté** — le NuGet `FWK-CEGID-NET-FULL 12.9.185` (JFrog `retail-nuget-production`, `CBP12_9/12.9.185/DotNet`) contient exactement `Cegid.Erp.Services.Implementation.dll 12.9.185.17`, identique à Current. Le Core candidat `22.0.0.2068` comme le Core Current `22.0.0.2096` restaureraient ce même NuGet 12.9.185 selon leurs `ExternalsToRestore.xml` respectifs.
- **INFERENCE rapportée** — le trio candidat Core `22.0.0.2068` / Common `22.0.3.311` / Identity `22.0.6.117`, déjà identifié ci-dessus comme candidat, apporterait donc déjà la même génération de DLL d'autorisation que Current, ce qui renforce l'hypothèse « packaging Fix trop ancien » sans la démontrer.
- **Point additionnel non recoupé** — un timestamp JFrog (`build.timestamp = 1757093083170`, soit 2025-09-05 ~17:24 UTC) pour Core `22.0.0.2068` et un commit candidat sur `Y2_Core` branche `releases/V22` (`e24de4fe8a6adf886b6d4ef942366a3a4fce09b4`, PR 416695) sont proposés comme origine, ainsi que `7c9f454d1c304b051e636a7acdca30caa3a419ac` pour Current `22.0.0.2096`. Ces identifiants n'ont pas été revérifiés dans ce processus.
- **NON DÉMONTRÉ** — la source elle-même indique que la disparition des 174 échecs `ID4266` reste à confirmer par une exécution réelle du replay isolé `replay-prep/2026-09-07-v22-isolated/`, dont l'état (bloqué par le ref `Pipelines_Templates` et l'attestation de cible) est inchangé par ce handoff.

**Verdict arbitré** — cette piste ne remplace pas le verdict `UNKNOWN` déjà consigné plus haut (consommation effective, projection du catalogue, correction démontrée). Elle fournit un mécanisme causal plausible supplémentaire (la DLL `Cegid.Erp.Services.Implementation`) à vérifier indépendamment avant citation comme `FACT` : relecture directe des `ExternalsToRestore.xml` des deux Core, téléchargement et inspection du NuGet dans ce processus, et confirmation du commit Git candidat.
