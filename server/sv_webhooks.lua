-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Discord Integration

function SendDiscordWebhook(category, action, source, metadata)
    local cfg = Config.LogCategories[category] or Config.LogCategories["System"]
    local webhook = Config.Webhooks[category] or Config.Webhooks.Default
    
    -- Sécurité : on ne tente pas l'envoi si le lien n'est pas configuré
    if not webhook or webhook == "VOTRE_WEBHOOK_ICI" or webhook == "" then return end

    local playerName = (source == 0) and "Système Serveur" or GetPlayerName(source)
    local playerID = (source == 0) and "N/A" or source

    local embed = {
        {
            ["color"] = cfg.color,
            ["title"] = cfg.icon .. " " .. cfg.title,
            ["description"] = "**Action:** " .. action .. "\n**Joueur:** " .. playerName .. " (ID: " .. playerID .. ")",
            ["fields"] = {},
            ["footer"] = {
                ["text"] = "Vitaswift Logger | " .. os.date("%d/%m/%Y %H:%M:%S"),
            },
        }
    }

    -- Conversion des métadonnées en champs Discord (Fields)
    if metadata and type(metadata) == "table" then
        for k, v in pairs(metadata) do
            local value = type(v) == "table" and json.encode(v) or tostring(v)
            table.insert(embed[1].fields, {
                ["name"] = tostring(k),
                ["value"] = value,
                ["inline"] = true
            })
        end
    end

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "vs_logger", 
        embeds = embed,
        avatar_url = "https://i.imgur.com/8N8yLUp.png" -- Optionnel
    }), { ['Content-Type'] = 'application/json' })
end