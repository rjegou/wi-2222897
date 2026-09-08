# Preuves Azure DevOps — pipeline 5224

Collecte effectuée le **2026-09-05** en lecture seule.

| Fichier | Rôle |
|---|---|
| `definition-5224.json` | métadonnées de la définition `Y2 Tools Jmeter Workflow` |
| `master-yaml-live.json` | contenu YAML récupéré pour la branche `master` |
| `sandbox-tests-rje-yaml-live.json` | contenu YAML récupéré pour `sandbox/tests_rje` |
| `build-4373772-timeline.json` | timeline du build de référence `4373772`, numéro `3.0.211` |

## Verdict borné

`FACT` — la définition 5224 est reliée au dépôt `Y2_Tools_Jmeter_Workflow` et le YAML observé empaquette/publie le NuGet workflow avant la construction des images.

`UNKNOWN` — ces fichiers ne prouvent pas directement le contenu final de l'image Docker ni l'identité/hash du package présent dans `C:\Tools`. Une validation concluante exige une inspection isolée de l'image et une comparaison de package/version/hash, sans publication externe.

Les captures sont brutes. Ne pas les éditer ; ajouter une nouvelle collecte datée si l'état courant doit être vérifié.
