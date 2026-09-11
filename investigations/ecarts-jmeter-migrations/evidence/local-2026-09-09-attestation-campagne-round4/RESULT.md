# WI-2222897 — attestation de campagne consolidée

Date de revue : 2026-09-09. Le collecteur `scripts/invoke_bw3_collector.py` est une copie locale du relais précédent, durcie en round 4. Les preuves sont dans `evidence/recollected2-build-*`; elles restent immuables et sont retraitées localement ici.

| Build | Stages/tâches JMeter | Runs | Cur/Fix | JMX Git au sourceVersion | Runtime | Cleanup |
|---:|---|---|---|---|---|---|
| 4447425 | FACT : stage complet ; tâches Run Jmeter Tests Campaign Cur/Fix completed, non skipped | FACT : URI canonique exact, 3 runs dont un vide | FACT 1991/1991 | FACT 32 blobs hashés ; exhaustivité UNKNOWN | UNKNOWN | UNKNOWN : lignes Remove-Item de préparation, pas preuve d’exécution/réussite |
| 4440884 | FACT : stage complet ; tâches Cur/Fix completed, non skipped | FACT : URI canonique exact, 3 runs dont un vide | FACT 1991/1991 | FACT 32 blobs hashés ; exhaustivité UNKNOWN | UNKNOWN | UNKNOWN : même limite |
| 4445575 | FACT : stage complet ; tâches Cur/Fix completed, non skipped ; erreurs de chargement observées | FACT : URI canonique exact, 3 runs dont un vide | FACT 1905/1905 | FACT 32 blobs hashés ; exhaustivité UNKNOWN | UNKNOWN | UNKNOWN : même limite |
| 4432554 | FACT : stage complet ; tâches Cur/Fix completed, non skipped | FACT : URI canonique exact, 3 runs dont un vide | FACT 2118/2118 | FACT 151 blobs hashés ; exhaustivité UNKNOWN | UNKNOWN | UNKNOWN : même limite |

FACT : la découverte utilise exclusivement `vstfs:///Build/Build/<id>` et conserve paramètres, pages et réponses. Les champs `run.build.id`, `build.uri` et `buildUri` sont contrôlés quand présents ; aucune contradiction n’a été observée. Les résultats sont comptés après attribution, avec `totalTests`, IDs uniques et pagination complète. Les runs vides sont conservés, sans créer de variante artificielle.

INFERENCE : les runs Cur/Fix découverts et leurs comptes sont compatibles avec les campagnes terminales documentées. Cela ne prouve ni l’identité des octets consommés par le runner, ni la réussite métier complète.

UNKNOWN : les lignes cleanup sont des commandes `Remove-Item` dans des logs de préparation ; aucune preuve de leur exécution ni de suppression réussie/exhaustive. Les erreurs de lecture de logs sont conservées dans les rapports si elles surviennent. Un inventaire JMX exhaustif prouve les blobs Git au commit, pas leur consommation runtime.

Commande réutilisable (nouveau dossier obligatoire) :

```powershell
python scripts/invoke_bw3_collector.py --build 4447425 --output evidence/collection-<date>-4447425
```

Le gabarit de transport local est le candidat [evidence/local-package-transport/RESULT.md](evidence/local-package-transport/RESULT.md), avec manifest limité et provenance associée.

Contrôles : `python -m py_compile scripts/invoke_bw3_collector.py`; `python -m pytest -q tests/test_collector.py` (8 tests) ; SHA-256 des lots ; refus du build 2054 avant réseau ; refus des sorties non vides. Aucun accès aux builds interdits, aucune écriture distante, aucun commit ou lancement bw.

Revue finale BRAIN le 2026-09-09 : 8 tests passés et empreintes du lot vérifiées. Voir la [revue dérivée](evidence/campaign-attestation/RESULT.md). La mission documentaire est terminée ; le WI-2222897 reste ouvert.
