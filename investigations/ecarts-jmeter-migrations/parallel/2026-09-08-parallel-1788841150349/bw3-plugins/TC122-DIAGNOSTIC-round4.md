# Diagnostic TC122 — InventoryTracking Reassign

Date : 2026-09-08 (Europe/Paris)

## Source exacte

- Repository : `Y2_Plugins_InventoryTracking`
- Commit : `ef3d87034d38b88aca04c824061b140e2a29252c`
- JMX : `Tests/WebServices/002-Device_Reassign.jmx`
- Test case Azure : reference `1127761`, title `002-Device:Reassign - TC 122`
- Collecte JMX : API Git REST read-only, `includeContent=true`, réponse 200, 4,097,371 octets; SHA-256 `39E6036031D1AD30304405D3E08DA159DA89B94F0E1ADC7B4BB6A5C14CFBE59E`; contenu non copié dans le dépôt documentaire.

## Séquence et données non sensibles

Le ThreadGroup TC122 conserve l'ordre suivant : token AuthServer, `A-PreQuery1` à `A-PreQuery4`, `B-XQuery`, `C-PostQuery1`/`C-PostQuery2`, puis `D-FinalQuery1` à `D-FinalQuery4`. Le patch proposé n'insère qu'un PostProcessor après `B-XQuery`; aucune requête SQL, attente ou assertion n'est modifiée.

Les valeurs de fixture observées sont `tstauto-ts`, `T@T`, `NUMSERIE-1971-AA03` et `NUMSERIE-1978-AA03`. `A-PreQuery3` insère une dernière connexion synthétique; les commentaires du JMX indiquent que l'utilisateur de dernière connexion n'existe pas. `B-XQuery` utilise le corps SOAP généré dans le JMX et référence `InputFiles\\Device\\Reassign_122.xml`.

## Faits Cur/Fix

La ligne JTL Fix de `002-Device:Reassign - TC 122 - B-XQuery` est HTTP 500, `Internal Server Error`, 2 425 octets, échec d'assertion `code expected 200, received 500`. La ligne Cur porte le même label et plan, HTTP 200, 30 219 octets, succès; la requête envoyée est de 2 290 octets dans les deux cas. Aucun corps de requête n'est présent dans la ligne JTL.

Le log serveur Fix, dans la même seconde, mentionne `InventoryTrackingDeviceService.svc - Reassign`, `OperationStatus=Failed`, `ErrorId=CBR_181_0054` et l'utilisateur `T@T` inexistant.

- `FACT` : HTTP 500 Fix et HTTP 200 Cur sont prouvés dans les JTL.
- `FACT` : l'erreur serveur Fix `CBR_181_0054` est prouvée.
- `INFERENCE` : la ligne serveur correspond probablement à TC122, par timestamp, endpoint, opération et séquence.
- `UNKNOWN` : corrélation technique définitive JTL/log, cause de la différence Cur/Fix et reproductibilité.

## Réconciliation des 339 échecs communs

La jointure exacte `(testCaseTitle, automatedTestName, testCaseReferenceId)` donne 339 clés `Fail/Fail`. Les catégories de texte sont non exclusives : XML 197, SQL 187, HTTP 1, avec XML∩SQL=78 et HTTP∩SQL=1. L'union est donc `197 + 187 + 1 - 78 - 1 = 306`.

Le reliquat de 33 est réel et identifié dans les résultats bruts : 29 `017-MobileSettings:UpdateDevice` avec première signature `B-XQuery:OK`, 2 `004-Device:Disconnect` `A-PreQuery4:OK`, 1 `004-Device:Disconnect` `A-PreQuery5:OK`, 1 `005-Device:Create` `C-PostQuery2:OK`. Il ne faut pas l'ajouter artificiellement aux signatures XML/SQL/HTTP.

## Patch d'instrumentation

Voir `TC122-INSTRUMENTATION.patch`. Il ajoute un `JSR223PostProcessor` sous le sampler `TC 122 - B-XQuery` qui journalise uniquement : code HTTP, taille de réponse, SHA-256 du corps, SHA-256 du chemin HTTP et, pour les seuls en-têtes de corrélation `x-correlation-id`, `request-id`, `traceparent`, un SHA-256 de leur valeur. Aucun corps, cookie, identifiant utilisateur, valeur brute de chemin/corrélateur ou secret n'est journalisé; les assertions métier restent inchangées.

Rejouer strictement Cur puis Fix avec le même setup, ordre et dataset; comparer les corrélateurs, codes, tailles, hashes et logs serveur. Une répétition unique ne suffit pas à établir la reproductibilité.
