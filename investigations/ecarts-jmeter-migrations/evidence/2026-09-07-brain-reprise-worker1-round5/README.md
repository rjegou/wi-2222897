# Collecte Worker 1 — orchestration locale Clienteling

Date : 2026-09-07. Périmètre limité à l’orchestration locale ; FrenchTaxesRules
et les 20 générations Clienteling V22–V25 déjà prouvées sont exclus.

## Point d’entrée exercé

Le dispatcher historique est `Migration_Jmeter_RJE_Sandbox/step_01_launchMigration.bat`:
il cherche un dossier `Y2_Plugins_*` puis appelle le `Testautos2Jmeter.bat`
injecté dans ce dossier. La copie isolée a exercé ce véritable point de génération
(`Testautos2Jmeter.bat`) avec la campagne descriptor consommée :

`IntegratedTests/AutoTest/Data/WebServices/WebServices.xml`.

Le staging était `C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710`.
Le script de fixture est conservé dans `orchestration-fixture/`; il reprend le
contrat du BAT sans publier, pousser, créer de branche/PR, lancer de pipeline,
appeler JFrog distant, SQL ou IIS.

## FACT — package et exécution

Le premier essai a sélectionné par erreur le cache 2.0.41 (`7C5C...09DC`) et
produit 151 JMX ; il n’est pas retenu comme résultat corrigé. Après correction
du descripteur isolé vers `2.0.42-soapnamespace.20260907`, le second essai a
affiché la restauration depuis le cache et terminé avec code `0`.

| élément consommé | SHA-256 |
|---|---|
| package corrigé `Cegid.Retail.AutoTest.Console.2.0.42-soapnamespace.20260907` | `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` |
| `Cegid.Retail.AutoTest.Api.dll` sélectionnée | `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B` |
| `Cegid.Retail.AutoTest.Console.exe` | `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` |

Le générateur a consommé le descriptor WebServices et produit `151` fichiers
JMX. Les `151` JMX ont été chargés avec `XmlDocument.Load` sans erreur et sont
conservés dans `orchestration-jmx/`. Les cinq plans Clienteling sélectionnés
dans cette sortie sont raccordés au descriptor et donnent :

| plans | valeur endpoint dans le JMX frais |
|---|---|
| 3 Deployment FullTextSearch | `ClientelingDeploymentService.svc` |
| 2 Mobility ClientelingParameters | `ClientelingMobilityService.svc` |

Les logs `orchestration-corrected2.stdout.log` et `orchestration-corrected2.stderr.log`
sont hashés respectivement `D9B12B9B2DFAB0E4D8D6A7CF1D4F7DE4AD981CA68175460150C96333CAD9DA17`
et `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855`.
Le stdout montre explicitement la version restaurée, le chemin du descriptor,
les fichiers consommés, puis les 151 générations.

## FACT / UNKNOWN — limites

FACT : la chaîne locale package → DLL → Console → descriptor → JMX fonctionne
sur une copie isolée avec code 0 et postconditions de comptage/parsing.
FACT : le worktree `Migration_Jmeter_RJE_Sandbox` est resté propre ; les
modifications Clienteling existantes n’ont pas été touchées.

UNKNOWN : succès HTTP métier, installation MSI, exécution SQL/IIS et comportement
du pipeline distant. La chaîne locale ne valide pas ces dimensions. UNKNOWN
également : décision de support autorisé `ClientelingProductsService.svc` ;
aucun test Products n’a été activé, supprimé ou exécuté.

La validation d’orchestration utile et indépendante est donc clôturée au niveau
génération locale. La prochaine action nécessite soit une décision support
Products, soit un environnement HTTP/MSI autorisé ; elle ne doit pas être
déduite du code de sortie Console seul.
