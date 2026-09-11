# Candidat de transport local de package — provenance

## Statut

Dossier de préparation révisable, produit le 2026-09-09. Aucun build, aucune queue et
aucune lecture distante n'ont été effectués pour ce livrable. Ce dossier ne prétend pas
être un pipeline exécutable sans paramètres vérifiés.

## Sources autorisées

- `C:/clones/wi-2222897/investigations/ecarts-jmeter-migrations/findings/017-campagnes-reelles-azdo-inventorytracking-frenchtaxesrules-20260908.md`
  : transport `PipelineArtifact + manifest` rapporté comme suffisant sur InventoryTracking
  (run 4447425), mais package FrenchTaxesRules encore absent du conteneur.
- `C:/clones/wi-2222897/investigations/ecarts-jmeter-migrations/findings/018-frenchtaxesrules-v26-jmeter-execution-4448787.md`
  : raffinement rapporté sur FrenchTaxesRules : `localPackageRoot` dédié aux exactement
  quatre fichiers du manifest, distinct de l'artifact `_Software` complet (12 fichiers MSI/XML).

Les findings 017 et 018 sont la seule base technique de ce candidat. Le finding 018 est
explicitement rapporté et non revérifié ; son commit exact, son YAML et son isolation n'ont
pas été relus. Le finding 015 sert uniquement au cadrage de contrôle de campagne, pas à
décrire le transport. La restauration de couverture InventoryTracking est documentée comme
résultat du correctif JMX ; elle n'est pas attribuée au transport PipelineArtifact.

Le formulaire utilise `N` entrées, exactement celles du manifest sélectionné. Les quatre
entrées présentes dans `MANIFEST.csv` sont un formulaire d'exemple correspondant au cas
FrenchTaxesRules rapporté, pas une cardinalité générale.

## Fichiers de ce dossier

- `RESULT.md` : gabarit, contrôles, arrêts et critères d'attestation.
- `MANIFEST.csv` : formulaire à renseigner depuis le manifest effectivement sélectionné.
- `SHA256SUMS.txt` : empreintes des présents livrables documentaires ; il ne constitue pas
  une empreinte du package tant que le manifest n'est pas renseigné.
