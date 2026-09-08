# Reproduction locale de la sélection XPath du runner

Date : 2026-09-06. Source : `evidence/local-2026-09-06-v26-fix-replay-draft/campaigns/ExportRunOnly.xml`. Méthode : lecture XML locale puis appel exact `Select-Xml -Xml $xml -XPath '//TestCampaign/TestPlanItem'` utilisé par `Scripts/jmeter-cli.ps1`; aucun runner, JMeter, pipeline, génération, téléchargement ou opération distante.

## Résultat réel

```text
Path             : ...\local-2026-09-06-v26-fix-replay-draft\campaigns\ExportRunOnly.xml
XPath            : //TestCampaign/TestPlanItem
DefaultNamespace : TestAutomation
Count            : 0
SelectedItems    :
```

**FACT** — zéro nœud est sélectionné. Aucun chemin de plan n’est produit par cette sélection. Le chemin `Tests\TestPlans\Export_Run.xml` est seulement la valeur théorique de `Join-Path` si un nœud était sélectionné; il ne constitue pas une preuve de chemin consommé dans l’état actuel.

Descripteur candidat : SHA-256 `DA0DD1CE05FDE44AD3BFAB73B891B8DB705D6703E2ED9E8046A98BA230A37E73`. Le namespace par défaut `TestAutomation` n’est pas associé à un préfixe dans l’XPath exact du runner.

## Contrat minimal proposé — non réalisé

Proposition documentaire uniquement, sans modification :

1. utiliser un descripteur compatible avec la résolution du runner, ciblant directement le JMX à exécuter (par exemple le chemin relatif réellement accepté par `Get-CampaignTestPlans`), et non un XML de génération ambigu;
2. fournir le JMX corrigé par un artefact/copie identifié, avec `source`, `destination`, commit/provenance et SHA-256;
3. vérifier l’existence, l’extension et le SHA-256 du fichier destination avant toute invocation JMeter;
4. conserver séparément la provenance de génération `07a42172...` et la baseline de rejeu `f80bc731571b2b5ed8a67da171b288873de428a6` / build `4432510`; aucune équivalence n’est acquise par le seul nom du fichier.

## Disponible / manquant

Disponible : runner local et lignes de résolution/invocation (`Scripts/jmeter-cli.ps1:302-327,160-169`), descripteur candidat, preuve de génération locale corrigée produisant `001-Export_Run.jmx` dans `out/Tests/Export_Run` (`local-2026-09-06-export-complete-before-after/corrected/console.stdout.log:20-23`).

À obtenir avant toute exécution : descripteur compatible effectivement sélectionné, JMX corrigé destination et hash, mécanisme de transport/copie, et preuve de rattachement à la baseline `4432510`/commit `f80bc731...`. Les blocages précédents restent inchangés : garde-fous SQL/IIS avant écriture, secrets dans les logs/archives, agent/acquisitions, isolation/effets aval. Résultat métier : **UNKNOWN**.
