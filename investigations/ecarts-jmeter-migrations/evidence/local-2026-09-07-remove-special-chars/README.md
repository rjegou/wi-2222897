# RemoveSpecialCharsForXQuery — validation locale

Date : 2026-09-07. Worktree API `Y2_Tools_AutoTest_Api_EscapeJdbcDate_RJE`; `EscapeJdbcDate`, `FixSqlUnicodeValue` et `CleanXpath` préservés.

FACT : `&` est échappée avant `<`, `>` et apostrophes. Compilation isolée BuildTools 17.14.14/net452 1.0.3 code 0; DLL SHA-256 `847FBE7A3E934FF144B46E18A35672A159DDE55BF15C1B1FEFD30B962A28550A`. Le test public passe quatre cas : entité préencodée, XML simple, CommonParameters avec apostrophe, esperluette déjà échappée. Non-régression CleanXpath/Unicode : PASS (6 + 9 cas).

LIMITATION : les quatre plans source→JMX demandés ne sont pas encore régénérés avec cette correction; la preuve ItemSearch précédente est antérieure au changement.
