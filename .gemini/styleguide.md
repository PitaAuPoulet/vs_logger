# Vitaswift Architecture Styleguide
**Author: Vitaswift | Version: 1.1.0**

Ce document définit les règles absolues pour tout développement au sein du namespace Vitaswift. L'agent Gemini doit utiliser ces règles pour chaque review de Pull Request.

## 1. Standards de Nommage
- **Préfixe Obligatoire :** Tous les fichiers, dossiers, variables globales et exports DOIVENT commencer par le préfixe `vs_`.
- **Exemple :** `vs_main.lua`, `vs_bridge`, `exports.vs_logger:SendLog`.

## 2. Doctrine Zero-SQL
- Aucun fichier `.sql` n'est autorisé.
- L'initialisation de la base de données (création de tables/colonnes) doit être gérée dynamiquement en Lua au démarrage de la ressource (Server-side).

## 3. Système de Bridge (vs_bridge)
- Interdiction d'utiliser des natives ou des fonctions spécifiques à un framework (ESX, QBCore, Ox) directement.
- Toute interaction (grade, inventaire, target, notification) doit impérativement passer par `vs_bridge`.

## 4. Sécurité Sentinel
- Chaque `RegisterNetEvent` déclenché par le client doit être validé côté serveur.
- Vérification systématique de la `source` et des permissions via le bridge pour toute action sensible.
- Implémentation obligatoire de protections contre le spam de triggers (Rate-limiting).

## 5. Documentation & Signature
- Chaque fichier doit comporter le header suivant : `Author: Vitaswift | Version: [VERSION]`.
- Les exports doivent être documentés avec leurs paramètres et types attendus.