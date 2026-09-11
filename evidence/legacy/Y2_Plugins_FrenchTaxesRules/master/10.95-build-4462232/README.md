# Baseline Legacy — FrenchTaxesRules master — 10.95 / build 4462232

**Statut :** preuve locale de référence, collectée le 2026-09-11.

## Provenance

- Plugin : `Y2_Plugins_FrenchTaxesRules`
- Branche : `master`
- Version plugin : `10.95`
- Build Azure DevOps : `4462232`
- Run label : `26.0.test.10.95-20260911_021457`
- VM : `Y2-TSTAUTOXXPG2`
- Source : archive locale du dossier WI ; les quatre fichiers bruts sont conservés sans modification.

## Résultats

| Campagne | Compteur TRX | Résultats élémentaires | Échecs réels | Fichier |
|---|---:|---:|---:|---|
| Fix | 274 exécutés, 3 échecs de compteur | 253, 252 passés | 1 (`Test_22`) | `Fix.trx` |
| Current | 274 exécutés, 49 échecs de compteur | 253, 209 passés | 44 | `Current.trx` |

Le compteur TRX inclut les conteneurs MSTest ; la colonne « échecs réels » décompte les
résultats élémentaires pour éviter de compter leurs échecs propagés.

`workflow.log` trace la séquence Fix puis Current, la sélection d’Identity `26.0.7.221`,
l’exécution de MSTest et la génération/publication des TRX. Cette preuve établit ce qui a
été exécuté et les résultats observés ; elle ne suffit pas à elle seule à démontrer une
comparabilité cas à cas avec JMeter.

## Empreintes

Voir [`SHA256SUMS.txt`](SHA256SUMS.txt) et [`MANIFEST.csv`](MANIFEST.csv).
