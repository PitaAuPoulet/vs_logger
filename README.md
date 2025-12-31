# 🛡️ vs_logger | Advanced Logging System

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/status-stable-green.svg?style=for-the-badge)
![Framework](https://img.shields.io/badge/framework-qb--core-orange.svg?style=for-the-badge)
![Security](https://img.shields.io/badge/gatekeeper-high-red.svg?style=for-the-badge)

### 💎 CodeArchitect Elite Standard
`vs_logger` est le moteur de traçabilité central de l'écosystème **Vitaswift**. Conçu pour la performance et la sécurité, il offre une journalisation hybride (SQL & Discord) avec une gestion intelligente des métadonnées.

---

## 📑 Sommaire
* [Aperçu](#-aperçu)
* [Dépendances](#-dépendances)
* [Fonctionnalités Clés](#-fonctionnalités-clés)
* [Structure Technique](#-structure-technique)
* [Installation](#-installation)
* [API & Exports](#-api--exports)
* [Configuration](#-configuration)

---

## 👁️ Aperçu
Le système centralise tous les événements serveurs et clients. Grâce au **Zero-SQL**, la base de données s'auto-gère, tandis que le moteur de Webhooks formate instantanément les alertes pour votre staff sur Discord.

---

## 📦 Dépendances
Pour fonctionner au sommet de ses capacités, `vs_logger` nécessite les ressources suivantes :

* 🧩 **vs_bridge** : Assure la communication avec le Framework (QBCore/ESX).
* 💾 **oxmysql** : Gestionnaire de base de données haute performance.
* 📚 **ox_lib** : Bibliothèque de fonctions utilitaires avancées.

---

## ✨ Fonctionnalités Clés
* 🔗 **Liaison Framework** : Intégration native avec `vs_bridge` pour identifier les joueurs.
* 🗄️ **Auto-Database** : Création automatique de la table `vs_logs` dès le premier lancement.
* 🛡️ **Gatekeeper Layer** : Filtrage et validation des requêtes pour empêcher le flood.
* 🎭 **Discord Embeds** : 5 catégories pré-configurées avec couleurs et icônes.
* 📊 **JSON Metadata** : Stockage flexible des données contextuelles (coord, items, banques).

---

## 📂 Structure Technique
L'architecture suit strictement la nomenclature **Elite** :

* **`server/sv_main.lua`** : Cœur logique et enregistrement des exports.
* **`server/sv_database.lua`** : Moteur d'initialisation et de persistance SQL.
* **`server/sv_webhooks.lua`** : Gestionnaire de requêtes HTTP vers l'API Discord.
* **`server/sv_gatekeeper.lua`** : Couche de sécurité et d'analyse des payloads.
* **`shared/config.lua`** : Point d'entrée unique pour la configuration.

---

## 🚀 Installation
1. Extraire le dossier `vs_logger` dans vos ressources.
2. S'assurer que les **dépendances** sont démarrées au préalable.
3. Définir vos URLs Webhooks dans `shared/config.lua`.
4. Ajouter `ensure vs_logger` dans votre `server.cfg`.

---

## 🛠️ API & Exports

### LogAction (Serveur uniquement)
Enregistre une action de manière persistante et notifie Discord.

```lua
exports.vs_logger:LogAction(targetSource, category, action, metadata)
