# API Clienteling — delta sandbox publié, round 2

Date de collecte : 2026-09-08. Source : clone frais dans le workspace
`C:\clones\wi-2222897\.work\clienteling-api` et lectures AzDO indépendantes.
Périmètre : publier uniquement le correctif API sur la branche sandbox
autorisée. Aucun push master, PR, feed partagé, promotion, tag ou queue de
pipeline n'a été effectué.

## Résultat

**FACT** — la branche distante
`refs/heads/sandbox/clienteling/api-jmeter-fixes` existe et pointe maintenant
sur le commit :

```text
4c22cb2850a150161f44080815375527c4daad48
```

Le push a été limité à :

```text
220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2..4c22cb2850a150161f44080815375527c4daad48
```

**FACT** — relecture indépendante par `git ls-remote` :

```text
4c22cb2850a150161f44080815375527c4daad48 refs/heads/sandbox/clienteling/api-jmeter-fixes
```

## Delta et provenance

Le commit contient un seul fichier modifié :
`Cegid.Retail.AutoTest.Api/JmeterCodeGen.cs`, 105 lignes ajoutées et 15
supprimées. Le delta vient de
[`patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch`](../../../../../../patches/Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE.patch),
SHA-256 :
`9D57E24B02212C453B70005FCB0975D95BDD79B3878455855EEB183EF0BAF5FB`.

Les quatre corrections publiées sont :

1. ordre ISO de `EscapeJdbcDate` ;
2. parcours des littéraux SQL et préfixe Unicode `N` de
   `FixSqlUnicodeValue` ;
3. échappement XML/XQuery dans `RemoveSpecialCharsForXQuery` ;
4. conservation de `Fault` et assertion SOAP 1.1 namespace-aware dans
   `CleanXpath`/`PrepareXPathAssertion`.

La branche reste basée sur le commit master
`220de3d978e7f10acda1c09dd0bf95ffaa4a2ca2`. La version source inchangée est
`1.1.46` (`SolutionInfo.cs`).

## Contrats package et migration

Le candidat Console déjà vérifié reste :

| Élément | Version / hash SHA-256 |
|---|---|
| API DLL candidate | assembly `1.1.46.0`, `57BEACA20DE071673C208305A670969A943420CFCB734FE7F30E4C13522F7B` |
| Console nupkg | `2.0.42-soapnamespace.20260907`, `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` |
| Console EXE candidate | `82A1134B73F2D9CC572EC2E77E33177D49691B6A40A8DB71CFC2CFE00ED75A9F` |
| API source delta | patch `9D57E24B02212C453B70005FCB0975D95BDD79B3878455855EEB183EF0BAF5FB` |

**INFERENCE** — le build API publié sur cette branche doit produire le
package API correspondant à `SolutionInfo.cs` `1.1.46`; il ne remplace pas à
lui seul le nupkg Console candidat. La chaîne attendue reste API → Console →
`Migration_Jmeter_RJE_Sandbox/migration-tools` → régénération JMX.

**UNKNOWN / dépendance WORKER 2** — le remplacement du nupkg Console dans
Migration, la mise à jour de `consoleWorkflowVersions.json`, les hashes du
package effectivement consommé et la régénération des JMX n'ont pas été
effectués. Ils nécessitent le contrat d'artefacts et l'environnement isolé
préparés par WORKER 2. Aucun fichier de migration n'a été poussé.

## Triggers et effets

**FACT** — la définition AzDO API `2637` (`AutoTest_Api CI`) consomme
`azure-pipelines.yml`. La lecture live du YAML indique :

- `trigger` limité à `master` ;
- schedules limités à `master` et `releases/*` ;
- upload Artifactory, BuildInfo et stage Promote conditionnés à `master` ou
  `releases/*` ;
- publication `PipelineArtifact` présente pour le build.

La branche sandbox n'est donc pas ciblée par le trigger YAML observé et aucun
run n'a été demandé dans cette session. Le futur build/JMeter isolé doit rester
manuel, avec artefact PipelineArtifact uniquement, triggers automatiques
explicitement désactivés et sans publication partagée.

## Clone et exception d'ownership

**FACT** — le clone local existant
`C:\clones\Migration_Jmeter_RJE_Sandbox` appartient à
`CEGIDGROUP\\jegour`, est propre sur `main` à `b83e7f90311aa0071b63518555dce6a64205b496`,
et possède le remote AzDO attendu. Son état a été lu avec l'exception limitée
à la commande :

```text
git -c safe.directory=C:\clones\Migration_Jmeter_RJE_Sandbox status --short --branch
```

Aucune configuration Git globale n'a été modifiée. Aucun fichier de ce clone
n'a été édité, conformément à la restriction filesystem.

## Validation et limites

**FACT** — `git apply --check`, application du patch, `git diff --check`,
commit et push ont réussi. Le clone API local est propre après commit.

**FACT / blocage local** — `dotnet build Cegid.Retail.AutoTest.Api.sln
--configuration Release --no-restore` échoue avant compilation avec MSB3644 :
les assemblys de référence `.NETFramework,Version=v4.5.2` ne sont pas installés
sur l'agent local.

**FACT** — les contrôles comportementaux du candidat Console embarqué restent
ceux de la preuve round 1 : les quatre méthodes passent sur les DLL hashées.

**UNKNOWN** — aucun Build API AzDO, package de migration, Console rebuild,
régénération JMX, JMeter Cur/Fix ou résultat métier n'est encore prouvé. Le
prochain run doit publier les manifests et hashes des fichiers réellement
consommés avant toute conclusion fonctionnelle.
