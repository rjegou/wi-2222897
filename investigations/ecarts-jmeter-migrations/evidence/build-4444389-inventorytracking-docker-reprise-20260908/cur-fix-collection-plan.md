# Collecte discriminante Cur/Fix — plan opérateur

Ce plan est préparatoire et ne lance aucune collecte distante.

Pour chaque job Cur et Fix, conserver l'identifiant du build, commit, branche, YAML SHA-256, image
et digest, package/version/hash effectivement consommés, JMX et données/fixtures exacts, puis les
résultats JMeter JTL et leur conversion JUnit. Les valeurs sensibles doivent être expurgées ou
remplacées par des hashes.

Pour TC122, joindre par clé stable (test case code/référence et nom de scénario) : résultat Cur/Fix,
échantillon JTL, requête et réponse expurgées ou leurs hashes, code HTTP, assertion XPath/XQuery,
message serveur et corrélateur côté serveur. Le corrélateur doit être conservé sans token ni secret.

Les contrôles minimaux avant comparaison sont : même scénario et contrat, même version/plugin,
même image et données, même environnement, même JMX effectivement consommé. La comparaison ne doit
conclure qu'après vérification de ces invariants.

**Décision de second rejeu :** inutile si les artefacts existants établissent ces invariants et
expliquent TC122; sinon demander uniquement un rejeu ciblé TC122 Cur/Fix avec cette instrumentation,
sans campagne complète ni publication supplémentaire.
