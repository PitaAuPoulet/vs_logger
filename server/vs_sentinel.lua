--[[
    vs_logger - Module de Sécurité Sentinel
    Author: Vitaswift | Version: 1.0.0
    
    Surveillance de sécurité avancée avec événements HoneyPot et détection de motifs
]]

local suspiciousPlayers = {}
local honeyPotTriggers = {}

-- Compteurs pour la performance (éviter d'itérer sur les tables)
local suspiciousPlayersCount = 0
local honeyPotTriggersCount = 0

-- Drapeau d'état de la ressource
local isResourceStopping = false

-- Initialiser les événements HoneyPot
local function InitializeHoneyPots()
    if not Config.Sentinel.enabled then
        return
    end
    
    VsLog('info', _L('sentinel_initializing'))
    
    for _, eventName in ipairs(Config.Sentinel.honeyPotEvents) do
        RegisterServerEvent(eventName)
        AddEventHandler(eventName, function(...)
            local source = source
            local args = {...}
            
            -- Cet événement ne devrait JAMAIS être déclenché légitimement
            local identifier = GetPlayerIdentifierByType(source, "license")
            local playerName = GetPlayerName(source)
            
            -- Enregistrer le déclenchement
            LogHoneyPotTrigger(source, identifier, playerName, eventName, args)
            
            if Config.Debug then
                VsLog('error', _L('sentinel_honeypot_triggered', eventName, playerName, source))
            end
        end)
    end
    
    VsLog('success', _L('sentinel_honeypots_registered', #Config.Sentinel.honeyPotEvents))
end

-- Enregistrer le déclenchement d'un HoneyPot
function LogHoneyPotTrigger(source, identifier, playerName, eventName, args)
    -- Suivre les déclenchements pour ce joueur
    if not honeyPotTriggers[identifier] then
        honeyPotTriggers[identifier] = {}
        honeyPotTriggersCount = honeyPotTriggersCount + 1
    end
    
    table.insert(honeyPotTriggers[identifier], {
        timestamp = os.time(),
        event = eventName,
        args = args
    })
    
    -- Envoyer une alerte de sécurité immédiate
    local details = string.format(
        "**CRITIQUE: Événement HoneyPot Déclenché**\n\n" ..
        "🎯 **Événement:** `%s`\n" ..
        "👤 **Joueur:** %s [%d]\n" ..
        "🔑 **Identifiant:** %s\n" ..
        "📊 **Déclenchements Totaux:** %d\n" ..
        "⏰ **Horodatage:** %s\n\n" ..
        "⚠️ **Cet événement ne devrait jamais être déclenché par un gameplay légitime!**\n" ..
        "Cela indique que le joueur utilise un menu ou exécute des scripts non autorisés.",
        eventName,
        playerName,
        source,
        identifier,
        #honeyPotTriggers[identifier],
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    -- Envoyer via le logger principal
    exports.vs_logger:SendLog(
        "suspect",
        "🚨 Événement HoneyPot Déclenché",
        details,
        source,
        {
            ["Event Name"] = eventName,
            ["Trigger Count"] = tostring(#honeyPotTriggers[identifier]),
            ["Threat Level"] = "HIGH"
        }
    )
    
    -- Déclencher également un événement interne pour d'autres systèmes
    TriggerEvent('vs_sentinel:honeyPotTriggered', {
        source = source,
        identifier = identifier,
        playerName = playerName,
        eventName = eventName,
        triggerCount = #honeyPotTriggers[identifier]
    })
end

-- Vérifier les motifs suspects
function CheckSuspiciousPatterns(text)
    if not Config.Sentinel.patterns.enabled or not text then
        return 0, {}
    end
    
    local text_lower = string.lower(text)
    local matchCount = 0
    local matchedKeywords = {}
    
    -- Vérifier toutes les catégories de motifs
    for category, keywords in pairs(Config.Sentinel.patterns.keywords) do
        for _, keyword in ipairs(keywords) do
            local keyword_lower = string.lower(keyword)
            
            -- Vérifier si le mot-clé existe dans le texte
            if string.find(text_lower, keyword_lower, 1, true) then
                matchCount = matchCount + 1
                table.insert(matchedKeywords, {
                    category = category,
                    keyword = keyword
                })
                
                if Config.Debug then
                    VsLog('warning', _L('sentinel_keyword_detected', keyword, category))
                end
            end
        end
    end
    
    -- Vérifier par rapport au seuil
    local sensitivity = Config.Sentinel.patterns.sensitivity
    local threshold = Config.Sentinel.patterns.thresholds[sensitivity] or 2
    
    if matchCount >= threshold then
        return matchCount, matchedKeywords
    end
    
    return 0, {}
end

-- Exporter la fonction de vérification de motifs
exports('CheckSuspiciousPatterns', CheckSuspiciousPatterns)

-- Gérer la demande de vérification de motifs
RegisterServerEvent('vs_sentinel:checkPatterns')
AddEventHandler('vs_sentinel:checkPatterns', function(data)
    local suspiciousScore, matchedKeywords = CheckSuspiciousPatterns(data.message)
    if suspiciousScore > 0 then
        TriggerEvent('vs_sentinel:patternDetected', {
            source = data.source,
            message = data.message,
            score = suspiciousScore,
            keywords = matchedKeywords,
            original_log_type = data.original_log_type
        })
    end
end)

-- Gérer les événements de détection de motifs
RegisterServerEvent('vs_sentinel:patternDetected')
AddEventHandler('vs_sentinel:patternDetected', function(data)
    local source = data.source
    local identifier = GetPlayerIdentifierByType(source, "license")
    
    -- Suivre l'activité suspecte
    if not suspiciousPlayers[identifier] then
        suspiciousPlayers[identifier] = {
            detections = 0,
            patterns = {},
            firstDetection = os.time()
        }
        suspiciousPlayersCount = suspiciousPlayersCount + 1
    end
    
    local playerData = suspiciousPlayers[identifier]
    playerData.detections = playerData.detections + 1
    
    table.insert(playerData.patterns, {
        timestamp = os.time(),
        message = data.message,
        score = data.score,
        log_type = data.original_log_type
    })
    
    -- Envoyer une alerte seulement si plusieurs détections (éviter les faux positifs)
    if playerData.detections >= 2 then
        local playerName = GetPlayerName(source)
        
        local details = string.format(
            "**Motif Suspect Détecté**\n\n" ..
            "👤 **Joueur:** %s [%d]\n" ..
            "🔑 **Identifiant:** %s\n" ..
            "📊 **Nombre de Détections:** %d\n" ..
            "🎯 **Score du Motif:** %d\n" ..
            "📝 **Échantillon de Message:** ```%s```\n" ..
            "⏰ **Première Détection:** %s\n\n" ..
            "⚠️ **Statut:** SUSPECT (Révision manuelle recommandée)",
            playerName,
            source,
            identifier,
            playerData.detections,
            data.score,
            string.sub(data.message, 1, 200),
            os.date("%Y-%m-%d %H:%M:%S", playerData.firstDetection)
        )
        
        -- Enregistrer comme suspect (pas de triche confirmée - éviter les faux positifs)
        exports.vs_logger:SendLog(
            "suspect",
            "⚠️ Motif Suspect Détecté",
            details,
            source,
            {
                ["Detection Count"] = tostring(playerData.detections),
                ["Pattern Score"] = tostring(data.score),
                ["Threat Level"] = "MEDIUM"
            }
        )
    end
end)

-- Gérer la journalisation des activités suspectes
RegisterServerEvent('vs_sentinel:logSuspicious')
AddEventHandler('vs_sentinel:logSuspicious', function(data)
    local source = data.source
    local identifier = data.identifier
    local reason = data.reason
    local details = data.details
    
    local playerName = GetPlayerName(source) or "Unknown"
    
    local message = string.format(
        "**Activité Suspecte Détectée**\n\n" ..
        "👤 **Joueur:** %s [%d]\n" ..
        "🔑 **Identifiant:** %s\n" ..
        "⚠️ **Raison:** %s\n" ..
        "📝 **Détails:** %s\n" ..
        "⏰ **Horodatage:** %s\n\n" ..
        "🔍 **Action Requise:** Investigation manuelle recommandée",
        playerName,
        source,
        identifier or "Unknown",
        reason,
        details,
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    exports.vs_logger:SendLog(
        "suspect",
        "🔍 Activité Suspecte",
        message,
        source,
        {
            ["Reason"] = reason,
            ["Threat Level"] = "MEDIUM"
        }
    )
end)

-- Obtenir les statistiques des joueurs suspects
function GetSuspiciousPlayerStats(identifier)
    return suspiciousPlayers[identifier]
end

exports('GetSuspiciousPlayerStats', GetSuspiciousPlayerStats)

-- Effacer les données des joueurs suspects (pour enquêter sur les faux positifs)
RegisterServerEvent('vs_sentinel:clearPlayerData')
AddEventHandler('vs_sentinel:clearPlayerData', function(identifier)
    local source = source
    
    -- Vérifier la permission admin
    local isAdmin = false
    if Config.UseBridge then
        local success, grade = pcall(function()
            return exports[Config.BridgeName]:GetPlayerGrade(source)
        end)
        isAdmin = success and grade and grade >= Config.MinAdminGrade
    end
    
    if not isAdmin then
        VsLog('error', _L('sentinel_unauthorized_clear', source))
        return
    end
    
    if suspiciousPlayers[identifier] then
        suspiciousPlayers[identifier] = nil
        suspiciousPlayersCount = suspiciousPlayersCount - 1
        VsLog('success', _L('sentinel_cleared_data', identifier))
        
        exports.vs_logger:SendLog(
            "admin",
            "🗑️ Données Suspectes Effacées",
            string.format("Admin a effacé les données de joueur suspect pour l'identifiant: %s", identifier),
            source
        )
    end
end)

-- Nettoyage périodique des anciennes données
CreateThread(function()
    while not isResourceStopping and Config.Sentinel.enabled do
        Wait(Config.SentinelDataManagement.cleanupInterval)
        
        if isResourceStopping then break end
        
        local currentTime = os.time()
        
        -- Nettoyer les anciens déclenchements honeypot
        for identifier, triggers in pairs(honeyPotTriggers) do
            local validTriggers = {}
            for _, trigger in ipairs(triggers) do
                if currentTime - trigger.timestamp < Config.SentinelDataManagement.honeyPotRetention then
                    table.insert(validTriggers, trigger)
                end
            end
            
            if #validTriggers > 0 then
                honeyPotTriggers[identifier] = validTriggers
            else
                honeyPotTriggers[identifier] = nil
                honeyPotTriggersCount = honeyPotTriggersCount - 1
            end
        end
        
        -- Nettoyer les anciennes données de joueurs suspects
        for identifier, data in pairs(suspiciousPlayers) do
            local shouldClean = (currentTime - data.firstDetection > Config.SentinelDataManagement.suspiciousRetention) 
                and (data.detections < Config.SentinelDataManagement.minDetectionsToKeep)
            
            if shouldClean then
                suspiciousPlayers[identifier] = nil
                suspiciousPlayersCount = suspiciousPlayersCount - 1
            end
        end
        
        if Config.Debug then
            VsLog('info', _L('sentinel_cleanup'))
        end
    end
    
    if Config.Debug then
        VsLog('warning', _L('sentinel_cleanup_stopped'))
    end
end)

-- Commande pour vérifier les joueurs suspects (admin uniquement)
RegisterCommand('vs_suspicious', function(source, args, rawCommand)
    local isAdmin = false
    
    if Config.UseBridge then
        local success, grade = pcall(function()
            return exports[Config.BridgeName]:GetPlayerGrade(source)
        end)
        isAdmin = success and grade and grade >= Config.MinAdminGrade
    else
        isAdmin = true -- Autoriser si le bridge est désactivé
    end
    
    if not isAdmin then
        return
    end
    
    -- Lister tous les joueurs suspects
    local count = 0
    print(_L('report_suspicious_header'))
    
    for identifier, data in pairs(suspiciousPlayers) do
        count = count + 1
        print(string.format("^3" .. _L('report_suspicious_entry') .. "^7", 
            count, 
            identifier, 
            data.detections,
            os.date("%Y-%m-%d %H:%M:%S", data.firstDetection)
        ))
    end
    
    if count == 0 then
        print("^2" .. _L('report_suspicious_none') .. "^7")
    end
    
    print(_L('report_suspicious_footer'))
end, false)

-- Commande pour vérifier les déclenchements honeypot (admin uniquement)
RegisterCommand('vs_honeypot', function(source, args, rawCommand)
    local isAdmin = false
    
    if Config.UseBridge then
        local success, grade = pcall(function()
            return exports[Config.BridgeName]:GetPlayerGrade(source)
        end)
        isAdmin = success and grade and grade >= Config.MinAdminGrade
    else
        isAdmin = true -- Autoriser si le bridge est désactivé
    end
    
    if not isAdmin then
        return
    end
    
    -- Lister tous les déclenchements honeypot
    local count = 0
    print(_L('report_honeypot_header'))
    
    for identifier, triggers in pairs(honeyPotTriggers) do
        count = count + 1
        print(string.format("^3" .. _L('report_honeypot_entry') .. "^7", 
            count, 
            identifier, 
            #triggers
        ))
        
        for i, trigger in ipairs(triggers) do
            print(string.format("^1" .. _L('report_honeypot_trigger') .. "^7", 
                i,
                trigger.event,
                os.date("%H:%M:%S", trigger.timestamp)
            ))
        end
    end
    
    if count == 0 then
        print("^2" .. _L('report_honeypot_none') .. "^7")
    end
    
    print(_L('report_honeypot_footer'))
end, false)

-- Initialiser Sentinel au démarrage de la ressource
CreateThread(function()
    Wait(2000) -- Attendre que le système principal se charge
    
    if not Config.Sentinel.enabled then
        VsLog('warning', _L('sentinel_disabled'))
        return
    end
    
    print("^2========================================^7")
    print("^2[vs_sentinel]^7 Module de Sécurité")
    print("^2[vs_sentinel]^7 Anti-Cheat & Surveillance")
    print("^2========================================^7")
    
    InitializeHoneyPots()
    
    VsLog('success', _L('sentinel_pattern_active'))
    VsLog('info', _L('sentinel_sensitivity', Config.Sentinel.patterns.sensitivity))
    VsLog('success', _L('sentinel_ready'))
    VsLog('info', _L('sentinel_commands'))
end)

-- Exporter le statut de Sentinel
function GetSentinelStatus()
    return {
        enabled = Config.Sentinel.enabled,
        honeyPotEvents = #Config.Sentinel.honeyPotEvents,
        suspiciousPlayers = suspiciousPlayersCount,
        honeyPotTriggers = honeyPotTriggersCount,
        patternDetection = Config.Sentinel.patterns.enabled
    }
end

exports('GetSentinelStatus', GetSentinelStatus)

-- Nettoyage à l'arrêt de la ressource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    isResourceStopping = true
    VsLog('warning', _L('sentinel_stopped'))
end)

