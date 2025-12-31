-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Internal Security Layer

function ValidateLogRequest(source, data)
    if not source or source <= 0 then return false end
    if type(data) ~= "table" then return false end
    if not data.category or not data.action then return false end
    return true
end

function InternalLog(category, action, source, metadata)
    local identifier = "SYSTEM"
    local name = "Server"

    if source and source > 0 then
        if Bridge and Bridge.GetPlayerFromId then
            local xPlayer = Bridge.GetPlayerFromId(source)
            if xPlayer then
                identifier = xPlayer.getIdentifier()
                name = xPlayer.getName()
            end
        else
            identifier = GetPlayerIdentifier(source, 0) or "Unknown"
            name = GetPlayerName(source) or "Unknown"
        end
    end

    -- 1. Insertion SQL
    MySQL.prepare('INSERT INTO ' .. Config.Database.TableName .. ' (identifier, playerName, category, action, metadata) VALUES (?, ?, ?, ?, ?)', {
        identifier, name, category, action, json.encode(metadata or {})
    })

    -- 2. Envoi Discord (Nouveau)
    SendDiscordWebhook(category, action, source, metadata)
end