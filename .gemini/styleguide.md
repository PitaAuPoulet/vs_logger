# Vitaswift Development Style Guide
> Standards de développement pour l'architecture "CodeArchitect Elite".

## 1. Principes Généraux
* **Philosophie** : Robustesse maximale, Zéro dépendance directe aux frameworks.
* **Stack** : Lua 5.4, OxMySQL, FiveM Natives.

## 2. Règles de Nomenclature
### Ressources (Dossiers)
* Tout nouveau script doit être préfixé par `vs_`.
* Exemple : `vs_shop`, `vs_garage`.

### Fichiers
* Utiliser une nomenclature sémantique standard sans préfixe.
* `client.lua`
* `server.lua`
* `config.lua`
* `locales/fr.lua`

### Conventions de Langue
* **Code (Variables, Fonctions)** : ANGLAIS (CamelCase).
* **Commentaires & Documentation** : FRANÇAIS.
* **Commits** : Conventionnel (ex: `feat: ajout du système de logs`).

## 3. Architecture Technique

### A. Le "Bridge" (Dépendance Unique)
Tous les scripts doivent être agnostiques du framework (ESX/QBCore).
* **Règle** : Ne JAMAIS importer `ESX` ou `QBCore` directement.
* **Usage** : Tout passe par `vs_bridge`.
    * Framework : `Bridge.GetPlayer()`, `Bridge.GetJob()`
    * Inventaire : `Bridge.HasItem()`, `Bridge.AddItem()`
    * Logs : `Bridge.Log(level, message)` (Ne pas utiliser `print` ou `vs_logger` direct).

### B. Zero-SQL (Base de Données)
* **Interdiction** : Aucun fichier `.sql` dans le dépôt.
* **Implémentation** : La création des tables doit se faire au démarrage du serveur (`server.lua`).
* **Méthode** : Utiliser `MySQL.ready()` et la syntaxe `CREATE TABLE IF NOT EXISTS` pour garantir l'idempotence (pas d'erreur si la table existe déjà).

### C. Sécurité (Server-Side)
* Ne jamais faire confiance au client (Never Trust Client).
* Valider toutes les entrées, distances et quantités côté serveur.
* Utiliser des Tokens pour les événements sensibles.

## 4. Documentation
* Chaque fichier Lua doit commencer par l'en-tête :
  `-- Author: Vitaswift | Version: 1.0.0`
* Le fichier `config.lua` doit être abondamment commenté en français pour faciliter la configuration par l'utilisateur final.
