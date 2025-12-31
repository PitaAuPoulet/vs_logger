# 🤖 Copilot Instructions | Vitaswift Architecture

## 📋 Profil du Projet
- **Développeur Principal :** Vitaswift
- **Standard de Code :** CodeArchitect Elite (Nomenclature CamelCase, code en anglais, commentaires en français).
- **Écosystème :** FiveM (GTA V) - Architecture modulaire propriétaire.

---

## 🧠 Mémoire Technique & Dépendances
- **Framework de Base :** Principalement QBCore, via une abstraction universelle.
- **Pont Central (vs_bridge) :** Initialise l'objet global `Bridge`. Sert de couche d'abstraction pour le support multi-framework.
- **Système de Log (vs_logger) :**
    - Système hybride SQL (oxmysql) et Discord (Webhooks).
    - **Zero-SQL** : Auto-création des tables via le script.
    - **Export Global** : `exports.vs_logger:LogAction(source, category, action, metadata)`.
- **Bibliothèques Clés :** `ox_lib` pour les utilitaires et `oxmysql` pour la persistance.

---

## 🛠️ Règles de Développement "Elite"
1. **Priorité au Bridge :** Toujours utiliser `Bridge.GetPlayerFromId(source)` plutôt que les appels natifs du framework.
2. **Ordre de Chargement :** Les fichiers `shared` doivent toujours précéder les scripts serveur/client dans le manifeste.
3. **Sécurité Gatekeeper :** Chaque export exposé au client doit passer par une fonction de validation de payload.
4. **Documentation :** Chaque nouvelle ressource doit inclure les fichiers `README.md`, `ROADMAP.md` et `LICENSE.md` selon les modèles établis.

---

## 📂 Nomenclature des Fichiers
- `client/cl_*.lua` : Scripts côté client.
- `server/sv_*.lua` : Scripts côté serveur.
- `shared/*.lua` : Configuration et données partagées.
- `fxmanifest.lua` : Toujours utiliser `lua54 'yes'`.

---

## 🚀 Intentions Futures (Roadmap Globale)
- **vs_notify** : Système de notifications personnalisé.
- **vs_admin** : Panel d'administration intégré utilisant les logs et le bridge.
- **Extensions vs_logger** : Screenshot-basic et système de purge automatique.