--[[
    vs_logger - Configuration
    Author: Vitaswift | Version: 1.0.0
]]

Config = {}

-- Métadonnées Vitaswift
Config.Author = "Vitaswift"
Config.Version = "1.1.0"
Config.Prefix = "vs_"
Config.Locale = "fr" -- Langue par défaut (fr/en)

-- Intégration Bridge
Config.UseBridge = true
Config.BridgeName = "vs_bridge"
Config.MinAdminGrade = 3 -- Grade minimum requis pour les logs de sécurité

-- Configuration Base de Données (MySQL/MariaDB)
Config.AutoCreateTables = true -- Zero-SQL: Créer automatiquement les tables si elles n'existent pas

-- Configuration Webhook
Config.Webhooks = {
    -- Webhook des logs standards
    Standard = {
        enabled = true,
        url = "", -- Ajoutez votre URL de webhook Discord ici
        colors = {
            info = 3447003,    -- Bleu
            success = 3066993, -- Vert
            warning = 15844367, -- Orange
            error = 15158332   -- Rouge
        }
    },
    
    -- Webhook des alertes de sécurité (séparé pour haute priorité)
    Security = {
        enabled = true,
        url = "", -- Ajoutez votre URL de webhook de sécurité ici
        color = 15158332, -- Rouge
        mentionRole = "" -- Optionnel: ID du rôle Discord à mentionner (@everyone, @here, ou ID de rôle)
    }
}

-- Configuration de Limitation de Taux
Config.RateLimit = {
    enabled = true,
    maxRequestsPerMinute = 30, -- Maximum de logs par joueur par minute
    cooldownAfterLimit = 60,   -- Cooldown en secondes après avoir atteint la limite
    alertAfterViolations = 3,  -- Envoyer une alerte de sécurité après X violations
    whitelist = {
        -- Steam IDs qui contournent la limitation de taux (pour les scripts de confiance)
        -- Exemple: "steam:110000xxxxxxxx"
    }
}

-- Configuration Sentinel (Anti-Cheat)
Config.Sentinel = {
    enabled = true,
    
    -- Événements HoneyPot (faux événements pour piéger les exécuteurs de menus)
    honeyPotEvents = {
        "vs_logger:giveAllWeapons",
        "vs_logger:addMoney",
        "vs_logger:teleportToCoords",
        "vs_logger:setGodMode",
        "vs_logger:healPlayer",
        "vs_logger:reviveAll",
        "vs_logger:nukeServer",
        "vs_logger:bypassAnticheat"
    },
    
    -- Détection de Motifs Suspects
    patterns = {
        enabled = true,
        sensitivity = "medium", -- low, medium, high
        
        -- Mots-clés suspects par catégorie
        keywords = {
            cheats = {
                "aimbot", "wallhack", "esp", "triggerbot", "noclip", 
                "godmode", "speedhack", "fly hack", "teleport hack"
            },
            
            menus = {
                "eulen", "lynx", "redengine", "modest", "cherax",
                "stand", "2take1", "impulse", "phantom-x", "terror"
            },
            
            exploits = {
                "exploit", "bypass", "inject", "lua executor", "menu base",
                "trigger spam", "event flood", "native abuse"
            },
            
            suspicious_actions = {
                "money drop", "spawn vehicle", "delete entity", "freeze player",
                "crash server", "admin abuse", "permission bypass"
            }
        },
        
        -- Correspondances minimales requises pour signaler comme suspect
        thresholds = {
            low = 1,
            medium = 2,
            high = 3
        }
    }
}

-- Configuration des Types de Logs
Config.LogTypes = {
    player = {
        enabled = true,
        webhook = "Standard",
        color = "info"
    },
    
    admin = {
        enabled = true,
        webhook = "Standard",
        color = "warning",
        requiresGrade = 3
    },
    
    security = {
        enabled = true,
        webhook = "Security",
        color = "error",
        requiresGrade = 4 -- Grade plus élevé requis
    },
    
    system = {
        enabled = true,
        webhook = "Standard",
        color = "info"
    },
    
    suspect = {
        enabled = true,
        webhook = "Security",
        color = "error"
    }
}

-- Paramètres de Performance
Config.Performance = {
    asyncDatabase = true,        -- Utiliser des opérations de base de données asynchrones
    batchLogging = false,        -- Journalisation par lots (expérimental)
    batchSize = 10,              -- Nombre de logs par lot
    batchInterval = 5000,        -- Intervalle en ms
    maxConcurrentQueries = 5     -- Requêtes de base de données concurrentes maximales
}

-- Gestion des Données Sentinel
Config.SentinelDataManagement = {
    cleanupInterval = 600000,    -- Intervalle de nettoyage en millisecondes (10 minutes)
    honeyPotRetention = 3600,    -- Conserver les déclenchements honeypot en secondes (1 heure)
    suspiciousRetention = 86400, -- Conserver les données suspectes en secondes (24 heures)
    minDetectionsToKeep = 5      -- Conserver les données si le joueur a ce nombre de détections
}

-- Mode Debug
Config.Debug = false -- Définir à true pour la journalisation verbeuse

return Config
