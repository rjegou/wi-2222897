# FrenchTaxesRules — récupération des logs Legacy du run 4459782

## Provenance

- Date d'intégration : 2026-09-11.
- Source reçue : `C:\Users\jegour\Downloads\Fiche de synthèse — récupération des logs de tests Legacy.md`.
- Système source déclaré : Azure DevOps run `4459782` et VM Legacy `Y2-TSTAUTOXXPG2`.
- Méthode d'intégration : copie documentaire de la fiche reçue, sans collecte nouvelle sur Azure DevOps ou la VM.
- Fraîcheur : document reçu le 2026-09-11 ; contenu rapporté, non revérifié indépendamment.
- Artefacts bruts : aucun ajouté ; les chemins de logs décrits restent hors dépôt.

La fiche intégrée est une synthèse de diagnostic, pas une preuve brute. Les résultats et la cause
technique qu'elle rapporte sont donc repris dans le [finding 025](../../findings/025-frenchtaxesrules-legacy-log-recovery-4459782.md)
avec leur niveau de preuve. Aucun secret n'est recopié.

## Empreinte

SHA-256 de la fiche source : `B8DD4A1B83DB5499456A4F7A0A8E8966C3146C66D9E6668B7103FBAC517FBCED`.

## Limites

- Le contenu des fichiers de la VM n'est pas présent dans ce dépôt.
- La fiche ne permet pas de prouver indépendamment l'absence de démarrage MSTest, le blocage
  PowerShell 5.1, ni la causalité de `-UseBasicParsing`.
- Aucun correctif, pipeline, publication, rotation ou révocation n'a été effectué dans cette intégration.
