-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Security Layer

--- Validate Client Payload before logging
--- @param source number Client source
--- @param data table Data to validate
--- @return boolean
function ValidateLogRequest(source, data)
    -- Intégration vs_gatekeeper (Wrapper)
    local isSafe = exports['vs_gatekeeper']:VerifyPayload(source, data, {
        requiredKeys = {"category", "action"},
        strictMode = (Config.SecurityLevel == "High")
    })

    if not isSafe then
        print(("^1%s ^7Security Alert: Suspicious log attempt from ID %s^7"):format(Config.Prefix, source))
        -- Log l'alerte de sécurité automatiquement si configuré
        if Config.LogClientTriggers then
            InternalLog("Security", "Gatekeeper blocked a suspicious request", source)
        end
        return false
    end

    return true
end

-- Fonction interne d'insertion (non exposée directement au client)
function InternalLog(category, action, source, metadata)
    local xPlayer = Bridge.GetPlayerFromId(source)
    local identifier = xPlayer ? xPlayer.getIdentifier() : "SYSTEM"
    local name = xPlayer ? xPlayer.getName() : "Server"

    MySQL.prepare('INSERT INTO ' .. Config.Database.TableName .. ' (identifier, playerName, category, action, metadata) VALUES (?, ?, ?, ?, ?)', {
        identifier, name, category, action, json.encode(metadata or {})
    })
end