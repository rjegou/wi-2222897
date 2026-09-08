# TC122 review — instrumentation, common failures and Console hash

Date: 2026-09-08 (Europe/Paris)

## Provenance and scope

This review uses the read-only Azure DevOps source `Y2_Plugins_InventoryTracking`, commit `ef3d87034d38b88aca04c824061b140e2a29252c`, JMX `Tests/WebServices/002-Device_Reassign.jmx` (REST response 200; 4,097,371 octets; SHA-256 `39E6036031D1AD30304405D3E08DA159DA89B94F0E1ADC7B4BB6A5C14CFBE59E`), and the previously collected immutable Cur/Fix result files. Scope remains Clienteling/local and the 151-JMX candidate; this is not proof of InventoryTracking consumption or of four distinct API corrections.

The JMX sequence is preserved: AuthServer token, `A-PreQuery1`..`A-PreQuery4`, `B-XQuery`, `C-PostQuery1`/`C-PostQuery2`, then `D-FinalQuery1`..`D-FinalQuery4`. TC122 fixture values are synthetic/non-secret. The referenced input path is `InputFiles\\Device\\Reassign_122.xml`; no separate input file was found in the read-only listing, so its external availability is UNKNOWN.

## TC122 instrumentation review

The reviewable patch inserts one JSR223 post-processor under the B-XQuery sampler. It does not change setup, order, assertions, SQL, payload, or business rules. It records response code, response byte count, SHA-256 of response bytes, SHA-256 of the URL path, and an allowlist of correlation header names. Each correlation value is SHA-256 hashed before logging. It does not log URL scheme/host/query, request headers, cookies, request/response body, user identifiers, or credentials.

FACT: the postcondition is discriminating: Cur/Fix can be compared by HTTP code, response size, body hash, and stable equality/difference of hashed correlation values, then joined to server evidence by timestamp and operation.

UNKNOWN: whether the server emits any allowlisted correlation header and whether the server log exposes a matching identifier. A replay must keep the same dataset, setup and sampler order; one replay is insufficient for reproducibility.

## 339 common failures and the 33 remainder

The exact identity join `(testCaseTitle, automatedTestName, testCaseReferenceId)` contains 339 Fail/Fail keys. Observed textual signatures are XML 197, SQL 187, HTTP 1; XML∩SQL is 78 and SQL∩HTTP is 1. Therefore the union is `197 + 187 + 1 - 78 - 1 = 306`, leaving 33 keys outside those categories.

FACT: the 33 are 29 `017-MobileSettings:UpdateDevice` first-signature `B-XQuery:OK`, 2 `004-Device:Disconnect` `A-PreQuery4:OK`, 1 `004-Device:Disconnect` `A-PreQuery5:OK`, and 1 `005-Device:Create` `C-PostQuery2:OK`. They must not be assigned to XML/SQL/HTTP without another error field.

FACT: the current report producer splits the first error message and does not preserve the JmxQuery/JmxPayload needed to identify the failing sampler. No available evidence demonstrates a malformed generator transform, SQL runtime defect, or incorrect business expectation.

Minimal safe correction: improve error projection to retain operation-level sampler correlation and all error signatures (including JmxQuery/JmxPayload only if redacted or hashed as appropriate). Do not change scenario assertions or classify the 33 as a product regression. Generator/scenario root cause remains UNKNOWN.

## Console candidate hash reconciliation

The explicitly referenced package exists at `C:\Users\jegour\AppData\Local\Temp\wi2222897-orchestration-clienteling-164805710\migration-tools\Cegid.Retail.AutoTest.Console.nupkg`. Streaming the ZIP entry `tools/Cegid.Retail.AutoTest.Api.dll` without extraction produced 182,784 octets and SHA-256:

`57BEACA20DE071673C208305A670969A943420CFCB73434FE7F30E4C13522F7B`

The same measurement produced package SHA-256 `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B`. Thus the measured DLL matches the worker-3 report variant containing `...73434FE...`; it does not match the user-message variant containing `...734FE7F...`. The differing bytes are not identity-proof for the latter; that value remains unverified/UNKNOWN. Console EXE and 151-JMX hashes are only the previously reported local evidence and do not establish pipeline publication or InventoryTracking consumption.

## Handoff

Worker 1 should use the updated `TC122-INSTRUMENTATION.patch`, preserve Cur/Fix setup and order, and report raw-vs-hashed logging criteria explicitly. No remote mutation or pipeline launch was performed in this review.
