# vs_logger (Sentinel Edition)

**Auteur:** Vitaswift  
**Version:** 1.1.0  
**Type:** Ressource Serveur FiveM

Système avancé de journalisation et de surveillance de sécurité pour les serveurs FiveM avec capacités anti-cheat intégrées.

## 🌟 Fonctionnalités

### Journalisation Principale
- **Architecture Zero-SQL**: Création automatique des tables de base de données - aucune configuration manuelle requise
- **Plusieurs Types de Logs**: Logs joueur, admin, sécurité, système et suspect
- **Intégration Discord**: Support de webhooks doubles (Logs standards + Alertes de sécurité)
- **Vérification de Grade**: Intégration avec `vs_bridge` pour la vérification des permissions
- **Optimisé pour la Performance**: Opérations asynchrones, file d'attente de requêtes, impact minimal sur le serveur

### Module de Sécurité Sentinel
- **Événements HoneyPot**: Piéger les exécuteurs de menus avec de faux événements
- **Détection de Motifs**: Identifier les mots-clés suspects dans les logs
- **Limitation de Taux**: Empêcher l'inondation de logs et le spam de déclenchements
- **Alertes Intelligentes**: Pas de faux positifs - les activités suspectes sont enregistrées comme "Suspect"
- **Surveillance en Temps Réel**: Alertes de sécurité immédiates pour les événements critiques

## 📋 Prérequis

- Serveur FiveM (Build 2802 ou plus récent)
- Ressource `vs_bridge` (pour la vérification des grades)
- **Base de données MySQL/MariaDB** (requis pour le stockage persistant)
- Ressource `oxmysql` ou `mysql-async` (pour la connexion à la base de données)

**Note:** Cette ressource utilise la syntaxe SQL spécifique à MySQL et nécessite une base de données MySQL/MariaDB pour fonctionner correctement.

## 🚀 Installation

1. Téléchargez et extrayez dans votre dossier `resources`
2. Ajoutez à votre `server.cfg`:
```cfg
ensure vs_bridge
ensure vs_logger
```

3. Configurez les webhooks dans `config.lua`:
```lua
Config.Webhooks = {
    Standard = {
        enabled = true,
        url = "VOTRE_URL_WEBHOOK_DISCORD"
    },
    Security = {
        enabled = true,
        url = "VOTRE_URL_WEBHOOK_SECURITE"
    }
}
```

4. Redémarrez votre serveur

## 💡 Utilisation

### Journalisation Basique
```lua
-- Depuis n'importe quel script côté serveur
exports.vs_logger:SendLog('player', 'Joueur Connecté', 'John Doe a rejoint le serveur', source)

exports.vs_logger:SendLog('admin', 'Action Admin', 'Le joueur a été expulsé', source, {
    Target = 'Joueur ID 5',
    Reason = 'Violation des règles'
})

exports.vs_logger:SendLog('security', 'Alerte de Sécurité', 'Activité suspecte détectée', source)
```

### Types de Logs
- `player` - Actions standard des joueurs
- `admin` - Commandes et actions admin (nécessite grade 3+)
- `security` - Événements de sécurité critiques (nécessite grade 4+)
- `system` - Événements au niveau système
- `suspect` - Généré automatiquement pour les activités suspectes

### Exports Disponibles

#### SendLog
```lua
exports.vs_logger:SendLog(logType, title, message, source, metadata)
```
- **logType**: string - Type de log (player, admin, security, system, suspect)
- **title**: string - Titre du log
- **message**: string - Message/description du log
- **source**: number - Source du joueur (optionnel)
- **metadata**: table - Données clé-valeur supplémentaires (optionnel)

#### CheckSuspiciousPatterns
```lua
local score, keywords = exports.vs_logger:CheckSuspiciousPatterns(text)
```
- **text**: string - Texte à analyser
- Retourne: score (number), keywords (table)

#### GetSuspiciousPlayerStats
```lua
local stats = exports.vs_logger:GetSuspiciousPlayerStats(identifier)
```
- **identifier**: string - Identifiant de licence du joueur
- Retourne: table avec statistiques de détection

#### GetSentinelStatus
```lua
local status = exports.vs_logger:GetSentinelStatus()
```
- Retourne: table avec statut du module sentinel

## 🔒 Fonctionnalités de Sécurité

### Événements HoneyPot
Les faux événements suivants sont enregistrés pour piéger les exécuteurs de menus:
- `vs_logger:giveAllWeapons`
- `vs_logger:addMoney`
- `vs_logger:teleportToCoords`
- `vs_logger:setGodMode`
- `vs_logger:healPlayer`
- `vs_logger:reviveAll`
- `vs_logger:nukeServer`
- `vs_logger:bypassAnticheat`

**Tout déclenchement de ces événements entraîne une alerte de sécurité immédiate!**

### Détection de Motifs
Scanne automatiquement les messages de log pour détecter les mots-clés suspects:
- **Cheats**: aimbot, wallhack, ESP, etc.
- **Menus**: Eulen, Lynx, RedEngine, etc.
- **Exploits**: injection, bypass, etc.
- **Actions Suspectes**: money drop, spawn vehicle, etc.

### Limitation de Taux
- Par défaut: 30 requêtes par minute par joueur
- Cooldown automatique après dépassement de la limite
- Alertes de sécurité après violations répétées
- Support de liste blanche pour les identifiants de confiance

## 🎮 Commandes Admin

### /vs_suspicious
Voir tous les joueurs signalés avec activité suspecte
- Affiche le nombre de détections et les horodatages
- Nécessite grade admin (3+)

### /vs_honeypot
Voir tous les déclenchements d'événements honeypot
- Affiche les événements déclenchés et les horodatages
- Nécessite grade admin (3+)

## ⚙️ Configuration

### Limitation de Taux
```lua
Config.RateLimit = {
    enabled = true,
    maxRequestsPerMinute = 30,
    cooldownAfterLimit = 60,
    alertAfterViolations = 3
}
```

### Sensibilité des Motifs
```lua
Config.Sentinel.patterns = {
    enabled = true,
    sensitivity = "medium", -- low, medium, high
    thresholds = {
        low = 1,
        medium = 2,
        high = 3
    }
}
```

### Réglage de Performance
```lua
Config.Performance = {
    asyncDatabase = true,
    maxConcurrentQueries = 5
}
```

## 🔧 Configuration Avancée

### Événements HoneyPot Personnalisés
Ajoutez des événements factices personnalisés dans `config.lua`:
```lua
Config.Sentinel.honeyPotEvents = {
    "vs_logger:giveAllWeapons",
    "votre_evenement_personnalise",
    -- Ajoutez-en plus...
}
```

### Mots-clés Suspects Personnalisés
Ajoutez des mots-clés personnalisés à détecter:
```lua
Config.Sentinel.patterns.keywords.custom = {
    "votre_mot_cle",
    "autre_mot_cle"
}
```

### Personnalisation des Webhooks
```lua
Config.Webhooks.Standard.colors = {
    info = 3447003,    -- Bleu
    success = 3066993, -- Vert
    warning = 15844367, -- Orange
    error = 15158332   -- Rouge
}
```

## 📊 Comment Ça Marche

### Philosophie Zero-SQL
1. Le script démarre et vérifie les tables de base de données
2. Si les tables n'existent pas, elles sont créées automatiquement
3. Aucune exécution SQL manuelle nécessaire
4. Intégration transparente avec MySQL/oxmysql

### Flux de Vérification de Grade
1. Demande de log reçue avec type de log sensible
2. Le système vérifie le grade du joueur via `vs_bridge`
3. Si non autorisé, une alerte de sécurité est déclenchée
4. La demande légitime se poursuit normalement

### Détection HoneyPot
1. Faux événements enregistrés au démarrage du serveur
2. L'exécuteur de menu déclenche un faux événement
3. Détection et journalisation immédiates
4. Alerte de sécurité envoyée à Discord
5. Joueur signalé pour révision manuelle

### Détection de Motifs
1. Chaque message de log est scanné
2. Mots-clés comparés aux motifs configurés
3. Score calculé en fonction des correspondances
4. Seuil vérifié par rapport à la sensibilité
5. Plusieurs détections déclenchent une alerte suspect

## 🛡️ Prévention des Faux Positifs

Le système est conçu pour **NE JAMAIS bannir ou expulser automatiquement**:
- Les activités suspectes sont enregistrées avec le statut "Suspect"
- Révision manuelle recommandée pour toutes les alertes
- Plusieurs détections requises avant l'alerte
- Distinction claire entre problèmes confirmés et suspectés
- Commandes admin pour enquêter sur les joueurs signalés

## 📝 Événements

### Événements Serveur (Internes)
- `vs_sentinel:honeyPotTriggered` - Quand un événement honeypot est déclenché
- `vs_sentinel:patternDetected` - Quand un motif suspect est détecté
- `vs_sentinel:logSuspicious` - Journalisation générale d'activité suspecte
- `vs_sentinel:clearPlayerData` - Effacer les données de joueur suspect (admin uniquement)

## 🔍 Dépannage

### Les logs n'apparaissent pas dans Discord
- Vérifiez les URL de webhook dans `config.lua`
- Vérifiez que les URL de webhook sont valides
- Consultez la console du serveur pour les messages d'erreur
- Activez le mode debug: `Config.Debug = true`

### Erreurs vs_bridge
- Assurez-vous que la ressource `vs_bridge` est démarrée avant `vs_logger`
- Vérifiez que `Config.UseBridge` est défini sur `true`
- Vérifiez que `Config.BridgeName` correspond au nom de votre ressource bridge

### Limitation de taux trop stricte
- Ajustez `Config.RateLimit.maxRequestsPerMinute`
- Ajoutez des identifiants de confiance à la liste blanche
- Désactivez la limitation de taux: `Config.RateLimit.enabled = false`

## 📄 Licence

Cette ressource fait partie de l'écosystème Vitaswift.

## 🤝 Support

Pour les problèmes, questions ou contributions:
- Vérifiez les options de configuration dans `config.lua`
- Activez le mode debug pour une journalisation détaillée
- Consultez la sortie de la console pour les erreurs
- Consultez `.github/copilot-instructions.md` pour les standards de développement

## 🎯 Feuille de Route

- [ ] Tableau de bord web pour visualiser les logs
- [ ] Détection de motifs avancée basée sur l'IA
- [ ] Intégration avec plus de bridges de framework
- [ ] Système de notation automatique des menaces
- [ ] Outils d'analyse des données historiques

---

**Rappel:** Ceci est un outil de sécurité - configurez-le correctement et examinez régulièrement les alertes!
