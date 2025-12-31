-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Core Logic

Bridge = nil

-- Récupération de l'objet partagé du Bridge au démarrage
TriggerEvent('vs_bridge:getSharedObject', function(obj) Bridge = obj end)

--- Export Global pour les autres scripts
--- @param targetSource number L'ID du joueur (ou 0 pour le serveur)
--- @param category string La catégorie (Admin, Money, etc.)
--- @param action string Description de l'action
--- @param metadata table (Optionnel) Données supplémentaires
exports('LogAction', function(targetSource, category, action, metadata)
    if not category or not action then 
        return print(("^1%s ^7Error: Missing category or action in LogAction export."):format(Config.Prefix)) 
    end

    -- Si c'est un log venant d'un joueur, on passe par le Gatekeeper
    if targetSource and targetSource > 0 then
        local payload = { category = category, action = action }
        if ValidateLogRequest(targetSource, payload) then
            InternalLog(category, action, targetSource, metadata)
        end
    else
        -- Log système / serveur (toujours autorisé)
        InternalLog(category, action, 0, metadata)
    end
end)

--- Event décorrélé pour les appels Client via TriggerServerEvent
RegisterNetEvent('vs_logger:server:log', function(data)
    local _source = source
    
    -- Sécurité : On vérifie la structure via le Gatekeeper
    if ValidateLogRequest(_source, data) then
        InternalLog(data.category, data.action, _source, data.metadata)
        
        if Config.DebugMode then
            print(("^2%s ^7Log received from ID %s: %s"):format(Config.Prefix, _source, data.action))
        end
    end
end)