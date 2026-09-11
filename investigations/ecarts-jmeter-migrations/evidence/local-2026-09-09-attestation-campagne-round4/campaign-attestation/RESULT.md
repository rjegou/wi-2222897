# Campaign execution attestation — WI-2222897

Date de revue dérivée: 2026-09-09. Cette revue retraitée localement utilise les quatre rapports immuables `evidence/recollected2-build-*/collector-report.json` et le collecteur round 4; aucune nouvelle lecture distante n’a été effectuée.

| Build | JMeter stages/tasks | Test Runs by buildUri | Cur/Fix published counts | JMX Git bytes | Runtime JMX consumption | Cleanup |
|---:|---|---|---|---|---|---|
| 4447425 | FACT runner stage/tasks completed, no JMeter skip; plan loading/coverage separate | FACT: exact `vstfs:///Build/Build/4447425` query; 3 runs incl. empty | Cur 1991; Fix 1991 | FACT: 32 JMX blobs at sourceVersion | UNKNOWN | 6 structured log observations; result/scope UNKNOWN |
| 4440884 | FACT runner stage/tasks completed, no JMeter skip; plan loading/coverage separate | FACT: exact `vstfs:///Build/Build/4440884` query; 3 runs incl. empty | Cur 1991; Fix 1991 | FACT: 32 JMX blobs at sourceVersion | UNKNOWN | 6 structured log observations; result/scope UNKNOWN |
| 4445575 | FACT runner stage/tasks completed, no JMeter skip; FACT load errors for affected plan | FACT: exact `vstfs:///Build/Build/4445575` query; 3 runs incl. empty | Cur 1905; Fix 1905 | FACT: 32 JMX blobs at sourceVersion | UNKNOWN | 6 structured log observations; result/scope UNKNOWN |
| 4432554 | FACT runner stage/tasks completed, no JMeter skip; loading/coverage separate | FACT: exact `vstfs:///Build/Build/4432554` query; 3 runs incl. empty | Cur 2118; Fix 2118 | FACT: 151 JMX blobs at sourceVersion | UNKNOWN | 6 structured log observations; result/scope UNKNOWN |

The four source report SHA-256 values are listed in the root `SHA256SUMS.txt`. Controls reviewed: `run.build.id` and both URI fields when present; `totalTests`, unique result IDs and pagination; exact Run Jmeter Tests Campaign tasks; JMX blob hashes versus runtime identity; and cleanup log line provenance. Runtime JMX identity and cleanup success/exhaustiveness remain UNKNOWN. The reports contain the PAT path as provenance only; no secret value is persisted.

Reusable command:

```powershell
python scripts/invoke_bw3_collector.py --build <4447425|4440884|4445575|4432554> --output evidence/collection-<date>-<id>
```
