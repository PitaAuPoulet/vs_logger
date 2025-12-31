-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Core Logic

Bridge = nil
Config = Config or {}

-- Tentative de récupération du Bridge via export (plus robuste)
CreateThread(function()
    local attempts = 0
    while Bridge == nil and attempts < 10 do
        attempts = attempts + 1
        TriggerEvent('vs_bridge:getSharedObject', function(obj) 
            Bridge = obj 
        end)
        
        if not Bridge then
            -- Fallback si l'event ne répond pas : essai via export
            local bridgeRes = GetResourceState('vs_bridge')
            if bridgeRes == 'started' then
                Bridge = exports['vs_bridge']:GetBridgeObject()
            end
        end
        
        if not Bridge then Wait(1000) end
    end

    if Bridge then
        print(("^2%s ^7Bridge successfully linked. Mode: ^5%s^7"):format(Config.Prefix, Bridge.GetFramework()))
    else
        print(("^1%s ^7Warning: Bridge connection timed out. Using standalone mode.^7"):format(Config.Prefix))
    end
end)

--- Export Global
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