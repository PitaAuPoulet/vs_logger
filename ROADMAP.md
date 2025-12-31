# 🗺️ Roadmap : vs_logger
> **Standard :** CodeArchitect Elite | **Framework :** Universal via vs_bridge

---

## 📌 État Actuel
- **Version :** `v1.0.0`
- **Statut :** 🟢 Stable
- **Dernière mise à jour :** 31/12/2025

---

## 🟢 PHASE 1 : Fondations & Core (TERMINÉ)
- [x] **Architecture Modulaire** : Séparation stricte entre Gatekeeper, Webhooks et Main.
- [x] **Système Zero-SQL** : Création automatique de la table `vs_logs` via `oxmysql`.
- [x] **Liaison Elite Bridge** : Connexion dynamique avec `vs_bridge` pour le support multi-framework.
- [x] **Discord Webhook Engine** : Support des Embeds colorés et des métadonnées JSON.
- [x] **Sécurité Gatekeeper** : Validation des payloads pour empêcher les injections et le spam.

---

## 🟡 PHASE 2 : Optimisation & Sécurité (EN COURS)
- [ ] **Purge Automatique** : Système de nettoyage cyclique basé sur `Config.RetentionDays`.
- [ ] **Rate-Limiting Dynamique** : Protection contre le flood de logs par client.
- [ ] **Filtres de Catégories** : Possibilité d'activer/désactiver certaines catégories à chaud.
- [ ] **Smart Metadata** : Amélioration du formatage des tables JSON sur Discord pour une meilleure lisibilité.

---

## 🟠 PHASE 3 : Visualisation & Monitoring (FUTUR)
- [ ] **In-Game Logger UI** : Interface NUI (React/Vue) pour consulter les logs en temps réel en jeu.
- [ ] **Module Screenshot** : Capture d'écran automatique via `screenshot-basic` sur les logs de type "Security".
- [ ] **Statistiques Globales** : Exportation de données pour analyse de l'activité du serveur.
- [ ] **Web Dashboard** : Visualisation externe via une interface web sécurisée.

---

## 🔵 PHASE 4 : Écosystème Vitaswift
- [ ] **vs_admin Integration** : Liaison directe avec le futur système d'administration.
- [ ] **Logs de Mort Avancés** : Reconstitution de scènes via les métadonnées de dégâts.
- [ ] **Export PDF/CSV** : Génération de rapports pour les archives du serveur.

---

## 🛠️ Utilisation Technique
```lua
-- Exemple d'appel standard
exports.vs_logger:LogAction(source, "Admin", "Description de l'action", { extra = "data" })