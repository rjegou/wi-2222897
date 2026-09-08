# API distant et contrat Console — round 3

Date de collecte : 2026-09-08, Europe/Paris. Lecture distante fraîche
effectuée entre `2026-09-08T09:41:24.6122580Z` et
`2026-09-08T09:41:26.3060034Z`.

## Lecture AzDO fraîche

**FACT** — `git ls-remote` et un `git fetch` ciblé confirment :

```text
repository: Y2_Tools_AutoTest_Api
ref: refs/heads/sandbox/clienteling/api-jmeter-fixes
commit: 4c22cb2850a150161f44080815375527c4daad48
```

Le dépôt local a été utilisé uniquement comme cache de lecture. Le fichier
distant `Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs` est présent à ce commit,
avec blob Git `99fefba4fee617fac9698825c53a84da347d2e2c`.

Les contrôles textuels sur le contenu distant confirment la présence de :

- la correction `${1}${2}${3}` de `EscapeJdbcDate` ;
- le parseur de littéraux SQL et `alreadyUnicode` dans `FixSqlUnicodeValue` ;
- `Replace("&", "&amp;")` dans `RemoveSpecialCharsForXQuery` ;
- `SOAP_11_NAMESPACE` et `PrepareXPathAssertion`.

**FACT** — identité actuelle : dépôt API, branche sandbox existante, commit
`4c22cb2`. Cette lecture ne concerne ni le dépôt Console ni Migration.

## Contradiction VS403660 : chronologie et opération exacte

**FACT historique** — le refus documenté dans
`bw1-tools/evidence/local-2026-09-08-api-release-candidate/README.md` et
`bw1-tools/RESULT.md` concernait le commit local
`16a03a83c7e4d9a7c65237f556a4167604ed294b`, branche nouvelle
`WI-2222897/clienteling/autotest-api-1.1.47`, dans le dépôt
`Y2_Tools_AutoTest_Api`. L'opération refusée était la création de la ref
`refs/heads/WI-2222897/clienteling/autotest-api-1.1.47`; AzDO indiquait
`VS403660`, scope `repository`, permission `CreateBranch`, identité
`rjegou@cegid.com`.

**FACT actuel** — le commit `4c22cb2` n'a pas tenté cette opération. Il a été
envoyé en fast-forward vers la branche déjà existante
`refs/heads/sandbox/clienteling/api-jmeter-fixes`, et la relecture distante
confirme le SHA. Le refus historique de création de branche ne contredit donc
pas le push actuel : dépôt, branche et opération ne sont pas les mêmes.

**INFERENCE** — la permission `CreateBranch` manquante reste pertinente pour
toute nouvelle branche, mais elle n'est pas nécessaire pour le fast-forward de
la branche sandbox existante déjà autorisée. Aucun contournement ACL n'a été
effectué.

## Candidat Console validé : provenance et chemins

Le candidat à consommer est le nupkg explicitement décrit dans la preuve round
3, et non le fichier de même nom présent dans une autre collecte :

```text
package = C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\migration-tools\Cegid.Retail.AutoTest.Console.nupkg
version = 2.0.42-soapnamespace.20260907
package SHA-256 = 803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B
```

Le fichier existe encore et son nuspec porte bien la version ci-dessus ainsi
que la description d'artefact local jamais publié. Les fichiers embarqués
attendus sont :

| chemin dans le nupkg | taille | SHA-256 |
|---|---:|---|
| `tools/Cegid.Retail.AutoTest.Api.dll` | 182784 | `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B` |
| `tools/Cegid.Retail.AutoTest.Console.exe` | 31624 | `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` |

La DLL embarquée porte l'identité assembly
`Cegid.Retail.AutoTest.Api, Version=1.1.46.0`. Sa provenance comportementale
est la réflexion directe décrite dans
`evidence/local-2026-09-08-console-candidate-round3/README.md`, où les quatre
vecteurs corrigés et le chemin SOAP namespace-aware passent.

**FACT / rejet** — le fichier
`C:\clones\wi-2222897-evidence\local-2026-09-07-soap-package-round14\checkPackage-tools\Cegid.Retail.AutoTest.Console.2.0.42-soapnamespace.20260907.nupkg`
porte le hash `F12F37E641941907F67CC7640728AC2DA2CEEA974E5909E0E85667EBAD361F5F`,
mais son nuspec déclare `2.0.42-cleanxpath.20260907`. Il ne doit pas être
consommé comme le candidat SOAP namespace-aware malgré son nom de fichier.

## MSB3644 : reconstruction nécessaire ou évitable

**FACT** — le `dotnet build` local de la source API échoue avant compilation
avec `MSB3644`, faute d'assemblys de référence .NET Framework 4.5.2.

**FACT** — le candidat Console validé contient déjà la DLL API corrigée et a
passé les contrôles comportementaux sur cette DLL hashée. Aucune reconstruction
locale n'est donc nécessaire pour préparer le transport de ce candidat.

**UNKNOWN** — un Build API AzDO reste utile comme preuve de compilation du
commit `4c22cb2`, mais il ne doit pas être présenté comme la provenance du
nupkg Console `2.0.42-soapnamespace.20260907` sans rebuild Console et contrôle
des hashes. Aucun composant système n'a été installé.

## Contrat de transport pour WORKER 2

Le script adjacent `stage-console-candidate.ps1` :

1. exige le chemin absolu du nupkg candidat ;
2. vérifie le hash du nupkg et la version exacte du nuspec ;
3. extrait en répertoire temporaire ;
4. vérifie les hashes complets de la DLL API et de l'EXE Console ;
5. copie uniquement le nupkg et un manifeste JSON vers le répertoire
   d'artefact du pipeline.

Il ne publie ni feed, ni JFrog, ni image, et n'ajoute aucun binaire au dépôt
documentaire. Le pipeline appelant doit utiliser exclusivement
`PublishPipelineArtifact` après cette validation, avec les triggers
automatiques désactivés.

**UNKNOWN** — WORKER 2 doit encore fournir le chemin de staging effectivement
utilisé, le commit du YAML isolé, le hash du JMX régénéré et la preuve que le
cache Migration consomme exactement le nupkg validé.
