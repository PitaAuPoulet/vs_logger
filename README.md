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
* [Fonctionnalités Clés](#-fonctionnalités-clés)
* [Structure Technique](#-structure-technique)
* [Installation](#-installation)
* [API & Exports](#-api--exports)
* [Configuration](#-configuration)

---

## 👁️ Aperçu
Le système centralise tous les événements serveurs et clients. Grâce au **Zero-SQL**, la base de données s'auto-gère, tandis que le moteur de Webhooks formate instantanément les alertes pour votre staff sur Discord.

---

## ✨ Fonctionnalités Clés
* 🔗 **Liaison Framework** : Intégration native avec `vs_bridge` pour identifier les joueurs (QBCore/ESX).
* 🗄️ **Auto-Database** : Création automatique de la table `vs_logs` dès le premier lancement.
* 🛡️ **Gatekeeper Layer** : Filtrage et validation des requêtes pour empêcher le flood et les injections.
* 🎭 **Discord Embeds** : 5 catégories pré-configurées avec couleurs, icônes et titres dynamiques.
* 📊 **JSON Metadata** : Stockage illimité de données contextuelles (coord, items, infos banques).

---

## 📂 Structure Technique
L'architecture suit strictement la nomenclature **Elite** :

* **`server/sv_main.lua`** : Cœur logique et enregistrement des exports.
* **`server/sv_database.lua`** : Moteur d
