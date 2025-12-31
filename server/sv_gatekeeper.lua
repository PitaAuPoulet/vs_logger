-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Internal Security Layer

--- Validate Client Payload before logging
function ValidateLogRequest(source, data)
    if not source or source <= 0 then return false end
    if type(data) ~= "table" then return false end
    if not data.category or not data.action then return false end
    return true
end

--- Fonction interne d'insertion
function InternalLog(category, action, source, metadata)
    local identifier = "SYSTEM"
    local name = "Server"

    -- Si c'est un joueur, on tente de récupérer ses infos via le Bridge
    if source and source > 0 then
        -- Sécurité : on vérifie si le Bridge et la fonction existent
        if Bridge and Bridge.GetPlayerFromId then
            local xPlayer = Bridge.GetPlayerFromId(source)
            if xPlayer then
                identifier = xPlayer.getIdentifier()
                name = xPlayer.getName()
            end
        else
            -- Fallback sur les natives FiveM si le bridge n'est pas encore prêt
            identifier = GetPlayerIdentifier(source, 0) or "Unknown"
            name = GetPlayerName(source) or "Unknown"
        end
    end

    MySQL.prepare('INSERT INTO ' .. Config.Database.TableName .. ' (identifier, playerName, category, action, metadata) VALUES (?, ?, ?, ?, ?)', {
        identifier, name, category, action, json.encode(metadata or {})
    })
end