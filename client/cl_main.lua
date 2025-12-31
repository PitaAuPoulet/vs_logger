-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Client Logic

--- Helper pour envoyer un log au serveur de façon sécurisée
--- @param category string La catégorie (Admin, Money, etc.)
--- @param action string Description de l'action
--- @param metadata table (Optionnel) Données supplémentaires
function SendLogToServer(category, action, metadata)
    if not category or not action then return end

    local payload = {
        category = category,
        action = action,
        metadata = metadata or {}
    }

    TriggerServerEvent('vs_logger:server:log', payload)
end

-- Exemple d'export client pour utilisation externe
exports('SendLog', SendLogToServer)

-- Debug : Notification de démarrage en mode Debug
if Config.DebugMode then
    print(("^5%s ^7Client module initialized and ready."):format(Config.Prefix))
end