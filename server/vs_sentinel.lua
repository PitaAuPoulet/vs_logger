--[[
    vs_logger - Sentinel Security Module
    Author: Vitaswift
    Version: 1.1.0
    
    Advanced security monitoring with HoneyPot events and pattern detection
]]

local suspiciousPlayers = {}
local honeyPotTriggers = {}

-- Counters for performance (avoid iterating tables)
local suspiciousPlayersCount = 0
local honeyPotTriggersCount = 0

-- Resource state flag
local isResourceStopping = false

-- Initialize HoneyPot Events
local function InitializeHoneyPots()
    if not Config.Sentinel.enabled then
        return
    end
    
    print("^2[vs_sentinel]^7 Initializing HoneyPot events...")
    
    for _, eventName in ipairs(Config.Sentinel.honeyPotEvents) do
        RegisterServerEvent(eventName)
        AddEventHandler(eventName, function(...)
            local source = source
            local args = {...}
            
            -- This event should NEVER be triggered legitimately
            local identifier = GetPlayerIdentifierByType(source, "license")
            local playerName = GetPlayerName(source)
            
            -- Log the trigger
            LogHoneyPotTrigger(source, identifier, playerName, eventName, args)
            
            if Config.Debug then
                print(string.format("^1[vs_sentinel]^7 HoneyPot triggered: %s by %s [%d]", 
                    eventName, playerName, source))
            end
        end)
    end
    
    print(string.format("^2[vs_sentinel]^7 %d HoneyPot events registered", #Config.Sentinel.honeyPotEvents))
end

-- Log HoneyPot Trigger
function LogHoneyPotTrigger(source, identifier, playerName, eventName, args)
    -- Track triggers for this player
    if not honeyPotTriggers[identifier] then
        honeyPotTriggers[identifier] = {}
        honeyPotTriggersCount = honeyPotTriggersCount + 1
    end
    
    table.insert(honeyPotTriggers[identifier], {
        timestamp = os.time(),
        event = eventName,
        args = args
    })
    
    -- Send immediate security alert
    local details = string.format(
        "**CRITICAL: HoneyPot Event Triggered**\n\n" ..
        "🎯 **Event:** `%s`\n" ..
        "👤 **Player:** %s [%d]\n" ..
        "🔑 **Identifier:** %s\n" ..
        "📊 **Total Triggers:** %d\n" ..
        "⏰ **Timestamp:** %s\n\n" ..
        "⚠️ **This event should never be triggered by legitimate gameplay!**\n" ..
        "This indicates the player is using a menu or executing unauthorized scripts.",
        eventName,
        playerName,
        source,
        identifier,
        #honeyPotTriggers[identifier],
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    -- Send via main logger
    exports.vs_logger:SendLog(
        "suspect",
        "🚨 HoneyPot Event Triggered",
        details,
        source,
        {
            ["Event Name"] = eventName,
            ["Trigger Count"] = tostring(#honeyPotTriggers[identifier]),
            ["Threat Level"] = "HIGH"
        }
    )
    
    -- Also trigger internal event for other systems to react
    TriggerEvent('vs_sentinel:honeyPotTriggered', {
        source = source,
        identifier = identifier,
        playerName = playerName,
        eventName = eventName,
        triggerCount = #honeyPotTriggers[identifier]
    })
end

-- Check Suspicious Patterns
function CheckSuspiciousPatterns(text)
    if not Config.Sentinel.patterns.enabled or not text then
        return 0, {}
    end
    
    local text_lower = string.lower(text)
    local matchCount = 0
    local matchedKeywords = {}
    
    -- Check all pattern categories
    for category, keywords in pairs(Config.Sentinel.patterns.keywords) do
        for _, keyword in ipairs(keywords) do
            local keyword_lower = string.lower(keyword)
            
            -- Check if keyword exists in text
            if string.find(text_lower, keyword_lower, 1, true) then
                matchCount = matchCount + 1
                table.insert(matchedKeywords, {
                    category = category,
                    keyword = keyword
                })
                
                if Config.Debug then
                    print(string.format("^3[vs_sentinel]^7 Suspicious keyword detected: %s (category: %s)", 
                        keyword, category))
                end
            end
        end
    end
    
    -- Check against threshold
    local sensitivity = Config.Sentinel.patterns.sensitivity
    local threshold = Config.Sentinel.patterns.thresholds[sensitivity] or 2
    
    if matchCount >= threshold then
        return matchCount, matchedKeywords
    end
    
    return 0, {}
end

-- Export pattern checking function
exports('CheckSuspiciousPatterns', CheckSuspiciousPatterns)

-- Handle pattern checking request
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

-- Handle pattern detection events
RegisterServerEvent('vs_sentinel:patternDetected')
AddEventHandler('vs_sentinel:patternDetected', function(data)
    local source = data.source
    local identifier = GetPlayerIdentifierByType(source, "license")
    
    -- Track suspicious activity
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
    
    -- Only send alert if multiple detections (avoid false positives)
    if playerData.detections >= 2 then
        local playerName = GetPlayerName(source)
        
        local details = string.format(
            "**Suspicious Pattern Detected**\n\n" ..
            "👤 **Player:** %s [%d]\n" ..
            "🔑 **Identifier:** %s\n" ..
            "📊 **Detection Count:** %d\n" ..
            "🎯 **Pattern Score:** %d\n" ..
            "📝 **Message Sample:** ```%s```\n" ..
            "⏰ **First Detection:** %s\n\n" ..
            "⚠️ **Status:** SUSPECT (Manual review recommended)",
            playerName,
            source,
            identifier,
            playerData.detections,
            data.score,
            string.sub(data.message, 1, 200),
            os.date("%Y-%m-%d %H:%M:%S", playerData.firstDetection)
        )
        
        -- Log as suspect (not confirmed cheat - avoiding false positives)
        exports.vs_logger:SendLog(
            "suspect",
            "⚠️ Suspicious Pattern Detected",
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

-- Handle suspicious activity logging
RegisterServerEvent('vs_sentinel:logSuspicious')
AddEventHandler('vs_sentinel:logSuspicious', function(data)
    local source = data.source
    local identifier = data.identifier
    local reason = data.reason
    local details = data.details
    
    local playerName = GetPlayerName(source) or "Unknown"
    
    local message = string.format(
        "**Suspicious Activity Detected**\n\n" ..
        "👤 **Player:** %s [%d]\n" ..
        "🔑 **Identifier:** %s\n" ..
        "⚠️ **Reason:** %s\n" ..
        "📝 **Details:** %s\n" ..
        "⏰ **Timestamp:** %s\n\n" ..
        "🔍 **Action Required:** Manual investigation recommended",
        playerName,
        source,
        identifier or "Unknown",
        reason,
        details,
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    exports.vs_logger:SendLog(
        "suspect",
        "🔍 Suspicious Activity",
        message,
        source,
        {
            ["Reason"] = reason,
            ["Threat Level"] = "MEDIUM"
        }
    )
end)

-- Get suspicious player statistics
function GetSuspiciousPlayerStats(identifier)
    return suspiciousPlayers[identifier]
end

exports('GetSuspiciousPlayerStats', GetSuspiciousPlayerStats)

-- Clear suspicious player data (for when investigating false positives)
RegisterServerEvent('vs_sentinel:clearPlayerData')
AddEventHandler('vs_sentinel:clearPlayerData', function(identifier)
    local source = source
    
    -- Verify admin permission
    local isAdmin = false
    if Config.UseBridge then
        local success, grade = pcall(function()
            return exports[Config.BridgeName]:GetPlayerGrade(source)
        end)
        isAdmin = success and grade and grade >= Config.MinAdminGrade
    end
    
    if not isAdmin then
        print(string.format("^1[vs_sentinel]^7 Unauthorized clearPlayerData attempt by source %d", source))
        return
    end
    
    if suspiciousPlayers[identifier] then
        suspiciousPlayers[identifier] = nil
        suspiciousPlayersCount = suspiciousPlayersCount - 1
        print(string.format("^2[vs_sentinel]^7 Cleared suspicious data for identifier: %s", identifier))
        
        exports.vs_logger:SendLog(
            "admin",
            "🗑️ Suspicious Data Cleared",
            string.format("Admin cleared suspicious player data for identifier: %s", identifier),
            source
        )
    end
end)

-- Periodic cleanup of old data
CreateThread(function()
    while not isResourceStopping and Config.Sentinel.enabled do
        Wait(Config.SentinelDataManagement.cleanupInterval)
        
        if isResourceStopping then break end
        
        local currentTime = os.time()
        
        -- Clean old honeypot triggers
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
        
        -- Clean old suspicious player data
        for identifier, data in pairs(suspiciousPlayers) do
            local shouldClean = (currentTime - data.firstDetection > Config.SentinelDataManagement.suspiciousRetention) 
                and (data.detections < Config.SentinelDataManagement.minDetectionsToKeep)
            
            if shouldClean then
                suspiciousPlayers[identifier] = nil
                suspiciousPlayersCount = suspiciousPlayersCount - 1
            end
        end
        
        if Config.Debug then
            print("^2[vs_sentinel]^7 Performed periodic data cleanup")
        end
    end
    
    if Config.Debug then
        print("^3[vs_sentinel]^7 Cleanup thread stopped")
    end
end)

-- Command to check suspicious players (admin only)
RegisterCommand('vs_suspicious', function(source, args, rawCommand)
    local isAdmin = false
    
    if Config.UseBridge then
        local success, grade = pcall(function()
            return exports[Config.BridgeName]:GetPlayerGrade(source)
        end)
        isAdmin = success and grade and grade >= Config.MinAdminGrade
    else
        isAdmin = true -- Allow if bridge is disabled
    end
    
    if not isAdmin then
        return
    end
    
    -- List all suspicious players
    local count = 0
    print("^3========== Suspicious Players Report ==========^7")
    
    for identifier, data in pairs(suspiciousPlayers) do
        count = count + 1
        print(string.format("^3[%d]^7 %s - Detections: %d, First: %s", 
            count, 
            identifier, 
            data.detections,
            os.date("%Y-%m-%d %H:%M:%S", data.firstDetection)
        ))
    end
    
    if count == 0 then
        print("^2No suspicious players tracked^7")
    end
    
    print("^3===============================================^7")
end, false)

-- Command to check honeypot triggers (admin only)
RegisterCommand('vs_honeypot', function(source, args, rawCommand)
    local isAdmin = false
    
    if Config.UseBridge then
        local success, grade = pcall(function()
            return exports[Config.BridgeName]:GetPlayerGrade(source)
        end)
        isAdmin = success and grade and grade >= Config.MinAdminGrade
    else
        isAdmin = true -- Allow if bridge is disabled
    end
    
    if not isAdmin then
        return
    end
    
    -- List all honeypot triggers
    local count = 0
    print("^3========== HoneyPot Triggers Report ==========^7")
    
    for identifier, triggers in pairs(honeyPotTriggers) do
        count = count + 1
        print(string.format("^3[%d]^7 %s - Triggers: %d", 
            count, 
            identifier, 
            #triggers
        ))
        
        for i, trigger in ipairs(triggers) do
            print(string.format("    ^1[%d]^7 %s at %s", 
                i,
                trigger.event,
                os.date("%H:%M:%S", trigger.timestamp)
            ))
        end
    end
    
    if count == 0 then
        print("^2No honeypot triggers recorded^7")
    end
    
    print("^3===============================================^7")
end, false)

-- Initialize Sentinel on resource start
CreateThread(function()
    Wait(2000) -- Wait for main system to load
    
    if not Config.Sentinel.enabled then
        print("^3[vs_sentinel]^7 Sentinel module: ^1DISABLED^7")
        return
    end
    
    print("^2========================================^7")
    print("^2[vs_sentinel]^7 Security Module")
    print("^2[vs_sentinel]^7 Anti-Cheat & Monitoring")
    print("^2========================================^7")
    
    InitializeHoneyPots()
    
    print("^2[vs_sentinel]^7 Pattern detection: ^2ACTIVE^7")
    print(string.format("^2[vs_sentinel]^7 Sensitivity: ^3%s^7", Config.Sentinel.patterns.sensitivity))
    print("^2[vs_sentinel]^7 Sentinel module ready!")
    print("^3[vs_sentinel]^7 Commands: ^2/vs_suspicious^7, ^2/vs_honeypot^7")
end)

-- Export sentinel status
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

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    isResourceStopping = true
    print("^3[vs_sentinel]^7 Sentinel module stopped")
end)

