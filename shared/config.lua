-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite
-- Nomenclature: CamelCase | Language: French Comments / English Code

Config = {}

-- [[ Paramètres Généraux ]]
Config.DebugMode = true          -- Active les logs de console détaillés
Config.Prefix = "[vs_logger]"    -- Préfixe pour les messages console

-- [[ Sécurité & Gatekeeper ]]
Config.SecurityLevel = "High"    -- [Low/Medium/High] définit la rigueur des validations
Config.LogClientTriggers = true  -- Log automatique des événements suspects détectés par le gatekeeper

-- [[ Configuration de la Base de Données (Zero-SQL System) ]]
Config.Database = {
    TableName = "vs_logs",
    AutoCreate = true,           -- Si true, le script génère la table au démarrage
    RetentionDays = 30           -- Nombre de jours avant purge automatique
}

-- [[ Catégories de Logs ]]
-- Note: Le titre est utilisé pour l'en-tête de l'Embed Discord
Config.LogCategories = {
    Admin    = { color = 16711680, icon = "🛡️", title = "ACTION ADMIN" },
    Money    = { color = 65280,    icon = "💰", title = "TRANSACTION" },
    Items    = { color = 255,      icon = "📦", title = "INVENTAIRE" },
    System   = { color = 8421504,  icon = "⚙️", title = "SYSTEME" },
    Security = { color = 16753920, icon = "🚫", title = "ALERTE SECURITE" }
}

-- [[ Webhooks Discord ]]
Config.Webhooks = {
    Default  = "https://discord.com/api/webhooks/1455942589420146750/XkB-qtAz0AbUIx3fJrmaWK03JnAvgcoNzKOgaICEKy2pAdORtCdt_eZNt06Tp9_12qWs",
    Critical = "https://discord.com/api/webhooks/1455942589420146750/XkB-qtAz0AbUIx3fJrmaWK03JnAvgcoNzKOgaICEKy2pAdORtCdt_eZNt06Tp9_12qWs",
    
    -- Optionnel : Tu peux pointer les catégories vers des salons différents ici
    Admin    = "https://discord.com/api/webhooks/1455942589420146750/XkB-qtAz0AbUIx3fJrmaWK03JnAvgcoNzKOgaICEKy2pAdORtCdt_eZNt06Tp9_12qWs",
    Money    = "https://discord.com/api/webhooks/1455942589420146750/XkB-qtAz0AbUIx3fJrmaWK03JnAvgcoNzKOgaICEKy2pAdORtCdt_eZNt06Tp9_12qWs",
    Security = "https://discord.com/api/webhooks/1455942589420146750/XkB-qtAz0AbUIx3fJrmaWK03JnAvgcoNzKOgaICEKy2pAdORtCdt_eZNt06Tp9_12qWs"
}

-- [[ Messages et Localisation ]]
Config.Locales = {
    TableCreated = "La table de base de données a été créée avec succès.",
    UnauthorizedAccess = "Tentative d'accès non autorisée bloquée par vs_gatekeeper.",
    LogSuccess = "Action enregistrée avec succès."
}