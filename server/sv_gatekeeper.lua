-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Internal Security Layer

--- Validate Client Payload before logging
--- @param source number Client source
--- @param data table Data to validate
--- @return boolean
function ValidateLogRequest(source, data)
    -- Vérification de base (en attendant l'intégration d'un Gatekeeper externe)
    if not source or source <= 0 then return false end
    
    -- Vérification de la structure des données
    if type(data) ~= "table" then return false end
    if not data.category or not data.action then 
        print(("^1%s ^7Security: Invalid payload structure from ID %s^7"):format(Config.Prefix, source))
        return false 
    end

    -- Protection contre le spam ou les strings trop longues
    if #data.action > 1000 then 
        print(("^1%s ^7Security: Action string too long from ID %s^7"):format(Config.Prefix, source))
        return false 
    end

    return true
end

-- Fonction interne d'insertion
function InternalLog(category, action, source, metadata)
    local identifier = "SYSTEM"
    local name = "Server"

    if source and source > 0 then
        local xPlayer = Bridge.GetPlayerFromId(source)
        if xPlayer then
            identifier = xPlayer.getIdentifier()
            name = xPlayer.getName()
        else
            identifier = GetPlayerIdentifier(source, 0) or "Unknown"
            name = GetPlayerName(source) or "Unknown"
        end
    end

    MySQL.prepare('INSERT INTO ' .. Config.Database.TableName .. ' (identifier, playerName, category, action, metadata) VALUES (?, ?, ?, ?, ?)', {
        identifier, name, category, action, json.encode(metadata or {})
    })
end