# Signatures de logs expurgées

Sources : API logs Azure DevOps des builds 4442156 et 4442685. Les lignes contenant des valeurs de secrets ont été exclues; aucun payload SQL brut n’est conservé.

```text
4442156 SQL2019: Successfully tagged sql-fulltext-smoke:2019
4442156 SQL2019: Full-Text population did not finish: [1]
4442156 SQL2025: Successfully tagged sql-fulltext-smoke:2025
4442156 SQL2025: Full-Text population did not finish: [1]
4442685 SQL2019: FULLTEXT_OBSERVATION_EXIT=0 ... Full-Text population did not finish: [1]
4442685 SQL2025: FULLTEXT_OBSERVATION_EXIT=0 ... Full-Text population did not finish: [1]
4442685: sql-fulltext-2019-evidence upload finished
4442685: sql-fulltext-2025-evidence upload finished
```

Le code du probe projeté dans les logs de préparation confirme l’ordre : assertion service Full-Text → création/index → attente `PopulateStatus=0` → `CONTAINSTABLE`.

