--[[
    vs_logger Configuration
    Author: Vitaswift
    Version: 1.1.0
]]

Config = {}

-- Vitaswift Metadata
Config.Author = "Vitaswift"
Config.Version = "1.1.0"
Config.Prefix = "vs_"

-- Bridge Integration
Config.UseBridge = true
Config.BridgeName = "vs_bridge"
Config.MinAdminGrade = 3 -- Minimum grade required for security logs

-- Database Configuration (MySQL/MariaDB)
Config.AutoCreateTables = true -- Zero-SQL: Automatically create tables if they don't exist

-- Webhook Configuration
Config.Webhooks = {
    -- Standard logs webhook
    Standard = {
        enabled = true,
        url = "", -- Add your Discord webhook URL here
        colors = {
            info = 3447003,    -- Blue
            success = 3066993, -- Green
            warning = 15844367, -- Orange
            error = 15158332   -- Red
        }
    },
    
    -- Security alerts webhook (separate for high priority)
    Security = {
        enabled = true,
        url = "", -- Add your security webhook URL here
        color = 15158332, -- Red
        mentionRole = "" -- Optional: Discord role ID to mention (@everyone, @here, or role ID)
    }
}

-- Rate Limiting Configuration
Config.RateLimit = {
    enabled = true,
    maxRequestsPerMinute = 30, -- Maximum logs per player per minute
    cooldownAfterLimit = 60,   -- Cooldown in seconds after hitting limit
    alertAfterViolations = 3,  -- Send security alert after X violations
    whitelist = {
        -- Steam IDs that bypass rate limiting (for trusted scripts)
        -- Example: "steam:110000xxxxxxxx"
    }
}

-- Sentinel Configuration (Anti-Cheat)
Config.Sentinel = {
    enabled = true,
    
    -- HoneyPot Events (fake events to trap menu executors)
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
    
    -- Suspicious Pattern Detection
    patterns = {
        enabled = true,
        sensitivity = "medium", -- low, medium, high
        
        -- Suspicious keywords by category
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
        
        -- Minimum matches required to flag as suspicious
        thresholds = {
            low = 1,
            medium = 2,
            high = 3
        }
    }
}

-- Log Types Configuration
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
        requiresGrade = 4 -- Higher grade required
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

-- Performance Settings
Config.Performance = {
    asyncDatabase = true,        -- Use async database operations
    batchLogging = false,        -- Batch multiple logs (experimental)
    batchSize = 10,              -- Number of logs per batch
    batchInterval = 5000,        -- Interval in ms
    maxConcurrentQueries = 5     -- Maximum concurrent database queries
}

-- Sentinel Data Management
Config.SentinelDataManagement = {
    cleanupInterval = 600000,    -- Cleanup interval in ms (10 minutes)
    honeyPotRetention = 3600,    -- Keep honeypot triggers for 1 hour
    suspiciousRetention = 86400, -- Keep suspicious data for 24 hours
    minDetectionsToKeep = 5      -- Keep data if player has this many detections
}

-- Debug Mode
Config.Debug = false -- Set to true for verbose logging

return Config
