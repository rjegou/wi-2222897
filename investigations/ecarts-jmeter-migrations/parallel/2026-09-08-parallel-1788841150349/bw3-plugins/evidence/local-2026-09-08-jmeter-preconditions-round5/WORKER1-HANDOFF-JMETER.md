# Handoff Worker 1 — JMeter 5.6.3 transport

Date: 2026-09-08. No remote publication was performed.

The local Apache JMeter distribution is at
`C:\Users\jegour\AppData\Local\Temp\jmeter-5.6.3-runtime\apache-jmeter-5.6.3`.
It contains `bin\jmeter.bat`; `jmeter.bat -v` returned `5.6.3`. The source ZIP
SHA-512 is
`387FADCA903EE0AA30E3F2115FDFEDB3898B102E6B9FE7CC3942703094BD2E65B235DF2B0C6D0D3248E74C9A7950A36E42625FD74425368342C12E40B016307`.
Critical file hashes and dependency counts are in `MANIFEST.csv`.

Round7 of definition 14264 now downloads Apache JMeter 5.6.3 directly in each
Cur/Fix job and verifies this SHA-512, so a JMeter PipelineArtifact is no longer
required by the current contract. Worker 1 should retain this manifest and verify
the download/readback in the job logs; do not use the historical `wi2222897-jmx`
name for a tool artifact and do not fetch from a shared feed or registry.
