-- Author: Vitaswift | Version: 1.0.0

-- Système de localisation pour vs_logger
Locales = {}
Config = Config or {}
Config.Locale = Config.Locale or 'fr'

-- Fonction pour récupérer une traduction
function _L(key, ...)
    local translation = Locales[Config.Locale] and Locales[Config.Locale][key]
    if not translation then
        translation = Locales['en'] and Locales['en'][key]
    end
    if not translation then
        return key
    end
    
    if ... then
        return string.format(translation, ...)
    end
    return translation
end

-- Fonction de logging compatible avec vs_bridge
-- Utilise Bridge.Log si disponible, sinon print
function VsLog(level, message, ...)
    local formattedMessage = message
    if ... then
        formattedMessage = string.format(message, ...)
    end
    
    -- Essayer d'utiliser vs_bridge pour le logging
    if Config.UseBridge and GetResourceState(Config.BridgeName) == 'started' then
        local success = pcall(function()
            exports[Config.BridgeName]:Log(level, formattedMessage)
        end)
        
        -- Si vs_bridge.Log n'existe pas, utiliser print avec couleur
        if not success then
            local colorCode = '^7'
            if level == 'error' then
                colorCode = '^1'
            elseif level == 'warning' then
                colorCode = '^3'
            elseif level == 'success' then
                colorCode = '^2'
            end
            print(string.format('%s[vs_logger]^7 %s', colorCode, formattedMessage))
        end
    else
        -- Fallback vers print avec couleur
        local colorCode = '^7'
        if level == 'error' then
            colorCode = '^1'
        elseif level == 'warning' then
            colorCode = '^3'
        elseif level == 'success' then
            colorCode = '^2'
        end
        print(string.format('%s[vs_logger]^7 %s', colorCode, formattedMessage))
    end
end
