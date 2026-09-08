---
type: evidence
title: InventoryTracking 4440884 — reconciliation of JTL and errors counters
date: 2026-09-07
freshness: derived from round9/round10 immutable projections and local producer source
---

# FACT — reconciliation

- `13 501` is the number of logical CSV records obtained by the tolerant
  comma-JTL read in round9. `13 781/13 782` counts physical lines after a
  fallback `splitlines()` parser; multiline payload fields inflate that count
  and produced one bogus Fix row (`2290,0`). Therefore the fallback counts are
  rejected as record counts. The logical CSV count is the valid invariant.
- `141` is the count of the exact phrase `Incorrect syntax` in the aggregate
  Azure result-check logs. `183` is the count of error-CSV records classified
  by `SQLServerException`/`Incorrect syntax`. They measure different scopes;
  neither is silently substituted for the other.
- The errors projection has 339 Cur and 340 Fix error records. The extra Fix
  record is not a contradiction: the projection includes all errors and the
  Cur-only TC122/B-XQuery row disappears in Fix, while another independent
  error row remains. Identity is `(TestPlan,TestCase,Operation)`, never
  `success`; the projection files preserve signature separately.
- Direct JTL identity (plan,label) differs only by the known malformed fallback
  row `002-Device_Reassign | 2290 | 0`; after excluding that row, Cur/Fix
  identities align. TC122 is Cur false / Fix true for B-XQuery, C-PostQuery1
  and C-PostQuery2.

# FACT — first SQL and producer

The first error CSV record is `002-Device:Reassign / TC 105 / A-PreQuery3`,
classified `SQLIncorrectSyntax` in both variants. The producer is
`New-ReportErrorCsv` in `PipelineTemplates/task-run-campaign.v1.yml`: it reads
JUnit XML errors and splits the first error message on `;|` and `:`. It then
joins details by `TestPlan/TestCase/Operation`, explaining why the CSV is the
correct source for the signature while JTL is the source for success status.
The exact non-sensitive generated query shape is recorded in
`round9/jmx-first-failure.txt`; its XML payload was not retained.

# Structure comparison and synthetic coverage

The historical Device_Reassign XML contains the same family of `MMOBILEINV`
controls and a `ReferenceDataRev0` XML value. The generated JDBC shape is an
`UPDATE MMOBILEINV`, Unicode literal prefix `N`, payload delimiter pair and
`SELECT @@ROWCOUNT`. No malformed delimiter or date transform is demonstrated
by this comparison. Existing isolated Console generation evidence
`round2/README.md` already exercised a synthetic SOAP/SQL/date fixture with
the corrected package; it proves generation/XML parsing, not SQL runtime.
No new business SQL execution was performed.

# INFERENCE / UNKNOWN

- `INFERENCE`: the Cur/Fix TC122 status delta is discriminant at assertion
  level, but not a business-success proof.
- `UNKNOWN`: root cause of TC105 SQL failure; the CSV signature is proved, but
  its excluded payload and absent SQL runtime prevent attribution to a specific
  generator transformation.
- `UNKNOWN`: complete cascade graph and legacy regression comparison.

Files: `producer-relevant-lines.txt`, Cur/Fix error and JTL projections copied
from round10/round9, `jmx-first-failure.txt`, `SHA256SUMS.txt`.
