# Handoff manuel — validation positive/négative SOAP XPath + packaging

## Provenance

Document reçu hors du processus `brain-worker` (fichier déposé dans `Downloads`, daté 2026-09-07) et rangé ici tel que reçu, sans modification : [WI-2222897_JMeter_Legacy_Technical_Handoff_2026-09-07.md](WI-2222897_JMeter_Legacy_Technical_Handoff_2026-09-07.md).

**Ce fichier n'a pas été réexécuté ni revérifié lors de ce rangement.** Ses affirmations `FACT` sont rapportées comme telles par la source, pas confirmées de façon indépendante ici. Toute reprise doit distinguer ce qui est déjà canonique (voir ci-dessous) de ce qui reste à confirmer.

## Contenu

- Rappel et validation du correctif XPath SOAP namespace-aware (`//*[local-name()='Fault' and namespace-uri()='...']/detail/faultcode`) sur la DLL `Cegid.Retail.AutoTest.Api` SHA-256 `57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`, packagée dans Console `2.0.42-soapnamespace.20260907` et rejouée avec Apache JMeter 5.6.3 officiel (SHA-512 vérifié).
- **Point nouveau par rapport à l'évidence déjà indexée** : une validation **négative** complète (`ExpectedValue=0` → `XPath.negate=true`) est revendiquée comme exécutée de bout en bout (génération JMX + exécution JMeter réelle, `EXECUTION_POSTCONDITION=PASS`), avec la découverte que ce cas exige un `Control` XPath ordinaire (chemin générateur `XPathJmeter`) et non un `OutputControl` (chemin `XPathExtractor` + `XmlComparator`).
- Leçons méthodologiques : ne pas prendre un JMX existant comme preuve avant fin de process ; toujours supprimer le JMX cible avant régénération ; préférer un staging court (`C:\Temp\...`) pour éviter `MAX_PATH` avec `csc.exe` net452 ; un harness JSR223 doit utiliser `SampleResult.setResponseData/...` et non `prev` (qui peut être `null`) ; un exit code JMeter `0` ne garantit pas des assertions vertes, il faut inspecter le JTL.
- Point non résolu signalé par la source elle-même : il reste à vérifier si la DLL `57BE...` consolide aussi les correctifs `EscapeJdbcDate` et `FixSqlUnicodeValue` (DLL dédiée `22D85CAA8CA61F30EFADBD611BB584042575A64EB2D78ED3A3637EF1D02D81CC`), et à propager la preuve côté package/migration pour ces deux corrections.
- Reprend aussi des pistes déjà connues du workspace : écart `Y2_Plugins_FrenchTaxesRules releases/V5 v23` (`cur: 0 fail` / `fix: failJob InitializeContainers`) et hypothèse non validée de Ludo sur un mauvais packaging/version Fix.

## Relation avec l'évidence et les conclusions déjà canoniques

- Même hash DLL (`57BE...`) et même XPath que [`local-2026-09-07-soap-namespace-aware-round13/`](../local-2026-09-07-soap-namespace-aware-round13/) et que [finding 012](../../findings/012-jmeter-5-6-3-xpath-namespace.md) : la partie « validation positive » recoupe l'évidence déjà indexée, elle ne l'étend pas.
- [`HANDOFF.md`](../../HANDOFF.md) (section « Revue indépendante SOAP round13 », 2026-09-07) note explicitement en `UNKNOWN` qu'« aucun cas round13 avec négation `ExpectedValue=0` n'a été exécuté ». Ce document affirme que ce cas a maintenant été exécuté et validé. **Avant de lever cet `UNKNOWN` dans `HANDOFF.md`/`findings/012`, il faut rejouer indépendamment ce scénario négatif** (fixture `Control` avec `ExpectedValue=0`, DLL `57BE...`, JMeter 5.6.3) plutôt que de se fier au seul récit de ce handoff.
- Un pointeur de reprise a été ajouté dans `HANDOFF.md` (entrée datée 2026-09-07) pour rendre ce document découvrable depuis le point d'entrée canonique, sans en faire une conclusion validée.

## Addendum reçu le 2026-09-07 (postérieur au handoff ci-dessus)

Un second document, déposé dans `Downloads` et rangé ici tel que reçu, complète explicitement le handoff ci-dessus sans le remplacer : [WI-2222897_JMeter_Legacy_Handoff_Addendum_2026-09-07.md](WI-2222897_JMeter_Legacy_Handoff_Addendum_2026-09-07.md).

**Ce fichier n'a pas non plus été réexécuté ni revérifié lors de ce rangement.**

### Contenu nouveau par rapport au handoff et à l'évidence déjà indexée

- **Point non résolu du premier handoff, revendiqué comme levé** : la même DLL `57BE...` contiendrait et exécuterait correctement, en plus de SOAP namespace-aware, les correctifs `EscapeJdbcDate` et `FixSqlUnicodeValue` (testés par réflexion directe contre le binaire, sans rebuild), là où le premier handoff laissait ce point explicitement ouvert.
- **Propagation package/Console/JMX revendiquée pour SQL Unicode et date**, via un `Control` réel remplacé par un `SELECT` non destructif dans un staging isolé : JMX régénéré (code 0), requête JDBC finale relue avec `System.Xml.XmlDocument.Load()` conforme à l'attendu (`SELECT N'NN''é' AS UnicodeValue, '20260907' AS DateValue`), hash JMX `B392ED9D...`. Ceci va au-delà de la validation DLL seule et de la propagation déjà prouvée pour SOAP (round13) : elle n'était pas encore faite pour ces deux correctifs.
- **Piège méthodologique nouveau** : une lecture `Get-Content -Raw` sous Windows PowerShell 5.1 d'un JMX XML UTF-8 corrompt visuellement `é` en `Ã©` et masque aussi les entités XML (`&apos;`), produisant un faux négatif ; la source recommande `System.Xml.XmlDocument.Load()` à la place.
- **Diagnostic du cas `Y2_Plugins_FrenchTaxesRules releases/V5 V23`** (`build 4429167`, déjà connu dans [finding 004](../../findings/004-french-taxes-rules-v21-v23-build-4429167.md) et le HANDOFF comme « V23 Fix n'a exécuté aucun test, moteur Docker n'a pas répondu ») : la source ajoute un niveau de détail non présent dans le canonique — `Log ID 449`, erreur exacte `npipe:////./pipe/docker_engine ... The system cannot find the file specified`, et une répartition par agent (`V23-Cur` réussi sur `Azure Pipelines 51` ; `V23-Fix` échoué sur `Azure Pipelines 21` ; d'autres jobs du même build réussis sur `41`/`53`), concluant à un agent 21 défaillant/transitoire plutôt qu'à un défaut de migration ou de packaging Fix.
- **Écart chiffré non reconcilié** : cette source indique **quatre tentatives** `docker version` avant l'échec, alors que le canonique (`findings/004`, `HANDOFF.md`) indique **trois tentatives**. Ne pas trancher cet écart sans revérifier directement le log `Log ID 449` du build `4429167`.

### Avant de lever un `UNKNOWN` sur la base de ce seul document

- Revérifier indépendamment la consolidation `EscapeJdbcDate`/`FixSqlUnicodeValue` dans la DLL `57BE...` (réflexion directe sur le binaire, hash identique) avant de clore le point resté ouvert dans le premier handoff et dans [finding 012](../../findings/012-jmeter-5-6-3-xpath-namespace.md).
- Revérifier la propagation package→Console→JMX pour SQL Unicode/date (régénération réelle, lecture XML sûre, comparaison de hash) avant de la citer comme `FACT` canonique.
- Revérifier le log exact `Build ID 4429167 / Log ID 449` (texte d'erreur, nombre de tentatives, `workerName` par job) directement dans Azure DevOps avant de compléter [finding 004](../../findings/004-french-taxes-rules-v21-v23-build-4429167.md) avec le détail par agent, et trancher l'écart trois/quatre tentatives.
- Compléments ajoutés côté canonique pour rendre ce document découvrable et signaler les points ouverts : [finding 004](../../findings/004-french-taxes-rules-v21-v23-build-4429167.md), [finding 012](../../findings/012-jmeter-5-6-3-xpath-namespace.md), [HANDOFF.md](../../HANDOFF.md), sans en faire des conclusions validées.
