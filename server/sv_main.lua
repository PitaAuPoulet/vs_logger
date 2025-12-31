-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Core Logic

Bridge = nil
Config = Config or {}

-- nomenclature: CamelCase | Language: French Comments / English Code

--- Initialisation de la liaison avec le Bridge
--- Tentative de récupération de l'objet global Bridge
CreateThread(function()
    local attempts = 0
    -- Boucle d'attente pour laisser au vs_bridge le temps de s'initialiser
    while Bridge == nil and attempts < 10 do
        attempts = attempts + 1
        
        TriggerEvent('vs_bridge:getSharedObject', function(obj) 
            Bridge = obj 
        end)
        
        -- Fallback : Si l'event ne répond pas, on tente l'export direct
        if not Bridge then
            if GetResourceState('vs_bridge') == 'started' then
                local success, result = pcall(function()
                    return exports['vs_bridge']:GetBridgeObject()
                end)
                if success then Bridge = result end
            end
        end

        if not Bridge then 
            Wait(1000) 
        end
    end

    if Bridge then
        print(("^2%s ^7Bridge successfully linked. Mode: ^5%s^7"):format(Config.Prefix, Bridge.GetFramework()))
    else
        print(("^1%s ^7CRITICAL ERROR: Impossible de lier vs_bridge après 10 secondes.^7"):format(Config.Prefix))
    end
end)

--- Export Global : LogAction
--- Utilisable par n'importe quelle ressource tierce
--- @param targetSource number ID du joueur (ou 0 pour logs serveur)
--- @param category string Catégorie définie dans Config.LogCategories
--- @param action string Description textuelle de l'action
--- @param metadata table | nil Table de données additionnelles
exports('LogAction', function(targetSource, category, action, metadata)
    if not category or not action then 
        return print(("^1%s ^7LogAction error: Missing category or action.^7"):format(Config.Prefix)) 
    end

    -- Si c'est un log joueur, on valide via le Gatekeeper interne
    if targetSource and targetSource > 0 then
        if ValidateLogRequest(targetSource, {category = category, action = action}) then
            InternalLog(category, action, targetSource, metadata)
        end
    else
        -- Log console / système
        InternalLog(category, action, 0, metadata)
    end
end)

--- Event Serveur pour réception des logs Client
RegisterNetEvent('vs_logger:server:log', function(data)
    local _source = source
    
    -- Sécurité Gatekeeper : Validation du Payload
    if ValidateLogRequest(_source, data) then
        InternalLog(data.category, data.action, _source, data.metadata)
        
        if Config.DebugMode then
            print(("^5%s ^7Client Log [ID:%s]: %s"):format(Config.Prefix, _source, data.action))
        end
    end
end)

-- Signature de fin d'initialisation
if Config.DebugMode then
    print(("^5%s ^7Main module loaded. Waiting for Bridge..."):format(Config.Prefix))
end