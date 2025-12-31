-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Core Logic

Bridge = nil
Config = Config or {}

-- Initialisation propre via l'objet partagé du Bridge
TriggerEvent('vs_bridge:getSharedObject', function(obj) 
    Bridge = obj 
end)

-- Attente de l'initialisation pour confirmer le lien
CreateThread(function()
    Wait(500)
    if Bridge then
        print(("^2%s ^7Bridge successfully linked. Mode: ^5%s^7"):format(Config.Prefix, Bridge.GetFramework()))
    else
        print(("^1%s ^7CRITICAL ERROR: Could not link to vs_bridge!^7"):format(Config.Prefix))
    end
end)

--- Export Global LogAction
exports('LogAction', function(targetSource, category, action, metadata)
    if not category or not action then return end

    if targetSource and targetSource > 0 then
        if ValidateLogRequest(targetSource, {category = category, action = action}) then
            InternalLog(category, action, targetSource, metadata)
        end
    else
        InternalLog(category, action, 0, metadata)
    end
end)

RegisterNetEvent('vs_logger:server:log', function(data)
    local _source = source
    if ValidateLogRequest(_source, data) then
        InternalLog(data.category, data.action, _source, data.metadata)
    end
end)