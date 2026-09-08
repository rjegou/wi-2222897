# Diagnostic rapide Console — 2026-09-06

FACT — deux blocages de l'essai local identifiés et levés, sans changement des binaires ni des worktrees :
1. PathTooLongException dans JmeterGenerator.CloneDirectory : le chemin profond sous evidence dépasse les contraintes du runtime. Preuve : diagnostic-exe.log, appel public Launcher.ExecuteTest dans un exécutable diagnostique avec copie de la configuration Console.
2. Après déplacement dans un chemin court, FileNotFoundException sur fixtures/TestPlans/input.xml. La fixture était dans fixtures/input.xml ; la génération attend inputFolder = dossier campagne + TestPlans. Preuve : missing-input-diagnostic.log.

Attention : le premier essai diagnose.ps1 chargeait Launcher dans PowerShell sans la configuration Console ; son erreur de liaison Svn est un effet de ce diagnostic, pas la cause établie de l'exécutable officiel. Les essais Add-Type ont échoué avant exécution ; le wrapper diagnostique a ensuite été compilé avec csc .NET Framework local.

## Rejeu officiel réussi

Racine courte dédiée : C:\temp\rje-wi2222897-20260906-console
Deux copies séparées original/corrected, issues des runtimes de la preuve précédente. Dans chaque copie : input.xml copié vers fixtures/TestPlans/input.xml ; répertoires out-fixed/IntegratedTests/Workflow et out-fixed/IntegratedTests/AutoTest/Data/campaign/TestPlans/OutputFiles créés. Aucun changement du runtime ou de sa configuration pour le rejeu officiel.

Depuis le répertoire runtime de chaque variante, commande exécutée (remplacer <variante> par original puis corrected) :

```powershell
.\Cegid.Retail.AutoTest.Console.exe --tstj=C:\temp\rje-wi2222897-20260906-console\<variante>\fixtures\campaign.xml --dstFolder=C:\temp\rje-wi2222897-20260906-console\<variante>\out-fixed
```

FACT — les deux processus officiels terminent avec code 0 et produisent chacun six JMX XML valides. Extraction structurelle de //JDBCSampler/stringProp[@name='query'] : corrected 6/6 conformes ; original quatre divergences ISO et deux témoins conformes. Voir assertions.json, results.json, runtime-hashes.csv et verified-original/verified-corrected (fixtures après génération, sorties et logs).

Le wrapper diagnostique a observé l'API corrigée chargée au chemin court ; l'exécutable officiel ne trace pas lui-même cette identité. Les empreintes des runtimes et les résultats différents à fixtures identiques étayent la propagation. Aucun contrôle de modules du processus officiel n'est revendiqué.

Portée : Console officielle 2.0.42 avec substitution locale de l'API, sur six fixtures synthétiques. Compilation du source Console, fabrication NuGet/pipeline, image Docker et rejeu métier restent UNKNOWN. Aucun accès distant, push, publication, SQL, HTTP ou JMeter exécuté. Les quatre worktrees API/Console ont conservé leur état (seul le correctif API préexistant est modifié).

Conclusion : pas besoin de pipeline Azure DevOps pour lever ce blocage. Pour une future fabrication, conserver NuGet uniquement comme artefact de run et vérifier tous les effets aval avant lancement. Les fichiers temporaires restent présents et sont inscrits dans RESOURCES.md.
