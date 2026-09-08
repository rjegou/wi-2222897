# Collecte Worker 1 — FrenchTaxesRules V22 autorisation / DLL

Date de collecte : 2026-09-07 (Europe/Paris). Portée strictement lecture seule.

## Sources et méthode

- Build Azure DevOps historique : `4429167`, snapshot plugin commit `2d826b8fd19ecb4d7200f574414efb7583de8ed2`.
- Source locale relue : `sources/Y2_Plugins_FrenchTaxesRules-v5-build-4429167/ExternalsToRestore_V22.xml`.
- Logs locaux relus : `evidence/build-4429167/_extracted/v22-Fix_RunLogs-Attempt#1/WorkerProcess/WorkerProcess_0_2026.09.03_001.Log` et équivalent `v22-Cur_RunLogs-Attempt#1`.
- Core candidate : dépôt Azure DevOps `Y2_Core`, commit `e24de4fe8a6adf886b6d4ef942366a3a4fce09b4`.
- Core current : dépôt Azure DevOps `Y2_Core`, commit `7c9f454d1c304b051e636a7acdca30caa3a419ac`.
- Les deux `ExternalsToRestore.xml` ont été lus via l'API Git Azure DevOps avec le PAT local, utilisé uniquement en mémoire ; aucune valeur secrète n'est conservée.
- NuGet téléchargé directement depuis JFrog : `retail-nuget-production/CBP12_9/12.9.185/DotNet/FWK-CEGID-NET-FULL.12.9.185.nupkg`, puis extrait localement.

## Résultats

**FACT** — le XML V22 Fix historique déclare `FWK-CEGID-NET-FULL` `12.9.153`, destination `Assemblies\\CBP`; il ne déclare pas `12.9.185`.

**FACT** — les logs d'exécution Fix chargent des assemblies `Cegid.Erp.*` en version `12.9.153.1506`, tandis que les logs Current chargent `Cegid.Erp.Services.Implementation` en version `12.9.185.17`.

**FACT** — les deux `ExternalsToRestore.xml` Core lus aux commits exacts candidate/current sont byte-identiques (SHA-256 `B22DC69CD6E82315345074020BD4FABF3C946427FC6350C1C69864FF77252DBB`) et déclarent tous deux `FWK-CEGID-NET-FULL` `12.9.185`, destination `Packages\\CBP.Net`.

**FACT** — le NuGet JFrog a répondu HTTP 200, taille `15,953,130` octets. Il contient `content/BIN/Erp/Cegid.Erp.Services.Implementation.dll`; l'AssemblyVersion vérifiée par reflection est `12.9.185.17`.

**INFERENCE** — le changement de framework externe `12.9.153` → `12.9.185` est une différence réelle et reproductible entre la pile Fix historique et la pile Core candidate/current. Il renforce l'hypothèse que le packaging Fix historique est incompatible avec les droits attendus, mais ne prouve pas que cette différence est la cause unique des 174 refus.

**UNKNOWN** — le replay V22 après remplacement du trio Core/Common/Identity, la consommation effective du catalogue `allowedModule`, la compatibilité complète avec FrenchTaxesRules `22.0.6.478`, et la disparition des 174 refus. Aucun pipeline, déploiement, restauration ou test métier n'a été lancé.

## Empreintes

Voir `MANIFEST.csv`. Le ZIP Core temporaire utilisé pour une inspection exploratoire n'est pas conservé dans cette collecte ; seuls les deux XML extraits et le NuGet nécessaire à l'inspection sont conservés.

## Protocole discriminant minimal

Sur deux cibles dédiées séparées Cur/Fix, conserver strictement le même plugin `22.0.6.478`, AuthenticationServer `2.0.0.368`, image, backup hashé, JMX et paramètres. Changer uniquement Core `22.0.0.2068`, Common `22.0.3.311` et Identity `22.0.6.117` par rapport au trio Fix historique. Contrôler avant/après : acquisition de token HTTP 200, présence des droits attendus sans journaliser le token, puis un cas `FrenchTaxesRules:Run`, un `SetDocumentErrorReason` et `Purge:Execute`; seulement si les trois passent, rejouer les 376 tests. Arrêter si backup, cible ou templates ne sont pas résolus et immuables.

