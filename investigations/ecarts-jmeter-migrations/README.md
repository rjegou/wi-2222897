# Écarts JMeter des migrations restantes

Dernière consolidation locale : **2026-09-07 — reprise documentaire Round 2**.

## Reprendre l'enquête

1. Lire [HANDOFF.md](HANDOFF.md).
2. Identifier le couple plugin/branche dans [cases/STATUS_MATRIX.md](cases/STATUS_MATRIX.md).
3. Lire la fiche correspondante dans [findings/](findings/README.md).
4. N'ouvrir que les preuves et snapshots cités par la fiche, via leurs index.
5. Pour implémenter, partir du [plan de correction](CORRECTION_PLAN.md) et travailler dans un worktree du dossier racine, jamais dans `sources/`.

## Organisation et destination des nouvelles informations

| Emplacement | Contenu | Nouvelle information attendue |
|---|---|---|
| [HANDOFF.md](HANDOFF.md) | état autonome, limites et ordre de reprise | changement de phase, conclusion transversale ou blocage |
| [cases/](cases/README.md) | statut des couples et comparaisons | nouvelle ligne, verdict ou preuve discriminante |
| [findings/](findings/README.md) | conclusions atomiques par build/sujet | fiche numérotée avec `FACT/INFERENCE/UNKNOWN` |
| [evidence/](evidence/README.md) | artefacts bruts et index | dossier séparé par build/run/collecte |
| [sources/](../../EXTERNAL-ARTIFACTS.md) | clones et snapshots exacts | snapshot immuable avec branche, commit et build |
| [references/](references/README.md) | procédures d'accès ou de collecte | référence stable utile à plusieurs preuves |
| [CORRECTION_PLAN.md](CORRECTION_PLAN.md) | corrections prouvées, propriétaires et rejeux | mise à jour seulement après nouvelle preuve ou validation |

## Règles spécifiques

- **Règle centrale de cette investigation : elle recherche des écarts entre JMeter et Legacy, pas des échecs JMeter pris isolément. Si un même test case échoue dans les deux chemins, avec la même postcondition ou la même signature, l'outil de migration n'est pas mis en cause par cette observation ; il faut rechercher une cause commune côté produit, scénario, données ou environnement. Ce cas ne devient un écart de migration que si une différence propre à la migration est ensuite démontrée.**
- Azure DevOps et les VM restent en lecture seule par défaut.
- Séparer `FACT`, `INFERENCE` et `UNKNOWN`.
- Rechercher la première faute causale avant de compter les effets en cascade.
- Inspecter les TRX legacy, mais ne revendiquer la comparabilité qu'avec le même cas, contrat, versions, backup, paramètres et environnement.
- Une soumission asynchrone acceptée n'est pas un résultat final.
- Les preuves brutes et snapshots sont immuables ; tout nouveau résultat va dans un nouveau dossier.
- Le worktree `../../../worktrees/Y2_Tools_Jmeter_Workflow/` contient une modification utilisateur à préserver.
- Ne jamais ouvrir ni recopier `../../../worktrees/Migration_Jmeter_RJE_Sandbox/jfrogToken.txt`.
