-- Author: Vitaswift | Part of: vs_logger
-- Nomenclature: CamelCase | Language: French Comments / English Code

Config = {}

-- Paramètres Généraux
Config.DebugMode = true          -- Active les logs de console détaillés
Config.Prefix = "[vs_logger]"    -- Préfixe pour les messages console

-- Intégration vs_gatekeeper
Config.SecurityLevel = "High"    -- [Low/Medium/High] définit la rigueur des validations
Config.LogClientTriggers = true  -- Log automatique des événements suspects détectés par le gatekeeper

-- Configuration de la Base de Données (Zero-SQL System)
Config.Database = {
    TableName = "vs_logs",
    AutoCreate = true,           -- Si true, le script génère la table au démarrage
    RetentionDays = 30           -- Nombre de jours avant purge automatique
}

-- Catégories de Logs
Config.LogCategories = {
    Admin = { color = 16711680, icon = "🛡️" }, -- Rouge
    Money = { color = 65280, icon = "💰" },    -- Vert
    Items = { color = 255, icon = "📦" },      -- Bleu
    System = { color = 8421504, icon = "⚙️" }, -- Gris
    Security = { color = 16753920, icon = "🚫" } -- Orange
}

-- Webhooks Discord (Exemple de structure)
Config.Webhooks = {
    Default = "YOUR_WEBHOOK_HERE",
    Critical = "YOUR_WEBHOOK_HERE"
}

-- Messages et Localisation
Config.Locales = {
    TableCreated = "La table de base de données a été créée avec succès.",
    UnauthorizedAccess = "Tentative d'accès non autorisée bloquée par vs_gatekeeper.",
    LogSuccess = "Action enregistrée avec succès."
}