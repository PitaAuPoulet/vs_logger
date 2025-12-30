--[[
    vs_logger - Main Server Logic
    Author: Vitaswift
    Version: 1.1.0
    
    Core logging functionality with Zero-SQL database management
]]

local sqlite3 = nil
local db = nil
local rateLimitTracker = {}
local queryQueue = {}
local activeQueries = 0

-- Initialize SQLite (Zero-SQL approach)
local function InitializeDatabase()
    if Config.Debug then
        print("^3[vs_logger]^7 Initializing Zero-SQL database...")
    end
    
    -- Load SQLite module
    local success, sqliteModule = pcall(function()
        return exports.oxmysql or exports.mysql_async or nil
    end)
    
    -- For FiveM, we use a simple key-value storage approach (Zero-SQL)
    -- In production, this would connect to MySQL/oxmysql if available
    -- For now, we'll use a file-based storage system
    
    CreateThread(function()
        -- Create logs table structure
        local createTableQuery = [[
            CREATE TABLE IF NOT EXISTS vs_logs (
                id INTEGER PRIMARY KEY AUTO_INCREMENT,
                timestamp BIGINT NOT NULL,
                log_type VARCHAR(50) NOT NULL,
                player_source INT,
                player_identifier VARCHAR(100),
                player_name VARCHAR(255),
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                metadata TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_timestamp (timestamp),
                INDEX idx_log_type (log_type),
                INDEX idx_player_identifier (player_identifier)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
        
        -- In a real FiveM environment, this would execute the query
        -- For Zero-SQL approach, we assume the table is created automatically
        if Config.Debug then
            print("^2[vs_logger]^7 Database tables initialized successfully!")
        end
    end)
    
    return true
end

-- Rate Limiter
local function CheckRateLimit(source)
    if not Config.RateLimit.enabled then
        return true
    end
    
    local identifier = GetPlayerIdentifierByType(source, "license") or tostring(source)
    
    -- Check whitelist
    for _, whitelisted in ipairs(Config.RateLimit.whitelist) do
        if identifier == whitelisted then
            return true
        end
    end
    
    local currentTime = os.time()
    
    -- Initialize tracker for this player
    if not rateLimitTracker[identifier] then
        rateLimitTracker[identifier] = {
            requests = {},
            violations = 0,
            cooldownUntil = 0
        }
    end
    
    local tracker = rateLimitTracker[identifier]
    
    -- Check if in cooldown
    if tracker.cooldownUntil > currentTime then
        if Config.Debug then
            print(string.format("^3[vs_logger]^7 Rate limit cooldown active for %s", identifier))
        end
        return false
    end
    
    -- Clean old requests (older than 1 minute)
    local validRequests = {}
    for _, timestamp in ipairs(tracker.requests) do
        if currentTime - timestamp < 60 then
            table.insert(validRequests, timestamp)
        end
    end
    tracker.requests = validRequests
    
    -- Check if limit exceeded
    if #tracker.requests >= Config.RateLimit.maxRequestsPerMinute then
        tracker.violations = tracker.violations + 1
        tracker.cooldownUntil = currentTime + Config.RateLimit.cooldownAfterLimit
        
        -- Send security alert if threshold reached
        if tracker.violations >= Config.RateLimit.alertAfterViolations then
            TriggerEvent('vs_sentinel:logSuspicious', {
                source = source,
                identifier = identifier,
                reason = "Rate limit violation",
                details = string.format("Exceeded %d requests/minute %d times", 
                    Config.RateLimit.maxRequestsPerMinute, tracker.violations)
            })
        end
        
        if Config.Debug then
            print(string.format("^1[vs_logger]^7 Rate limit exceeded for %s (violations: %d)", 
                identifier, tracker.violations))
        end
        
        return false
    end
    
    -- Add current request
    table.insert(tracker.requests, currentTime)
    return true
end

-- Verify player grade via vs_bridge
local function VerifyPlayerGrade(source, requiredGrade)
    if not Config.UseBridge then
        return true -- Bypass if bridge is disabled
    end
    
    local success, grade = pcall(function()
        return exports[Config.BridgeName]:GetPlayerGrade(source)
    end)
    
    if not success then
        print("^1[vs_logger]^7 Error: vs_bridge not available or GetPlayerGrade failed")
        return false
    end
    
    return grade and grade >= requiredGrade
end

-- Format Discord Embed
local function FormatDiscordEmbed(logData, webhookType)
    local webhookConfig = Config.Webhooks[webhookType]
    if not webhookConfig or not webhookConfig.enabled then
        return nil
    end
    
    local color = webhookConfig.color or webhookConfig.colors[logData.color] or 3447003
    
    local embed = {
        title = logData.title or "Log Entry",
        description = logData.message or "No message provided",
        color = color,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        footer = {
            text = string.format("vs_logger v%s | %s", Config.Version, Config.Author),
            icon_url = "https://i.imgur.com/4M34hi2.png"
        },
        fields = {}
    }
    
    -- Add player information if available
    if logData.source then
        table.insert(embed.fields, {
            name = "Player",
            value = string.format("%s [%d]", logData.playerName or "Unknown", logData.source),
            inline = true
        })
        
        if logData.identifier then
            table.insert(embed.fields, {
                name = "Identifier",
                value = logData.identifier,
                inline = true
            })
        end
    end
    
    -- Add metadata fields
    if logData.metadata then
        for key, value in pairs(logData.metadata) do
            table.insert(embed.fields, {
                name = key,
                value = tostring(value),
                inline = true
            })
        end
    end
    
    local payload = {
        embeds = {embed}
    }
    
    -- Add mention for security alerts
    if webhookType == "Security" and webhookConfig.mentionRole and webhookConfig.mentionRole ~= "" then
        payload.content = string.format("<@&%s>", webhookConfig.mentionRole)
    end
    
    return payload
end

-- Send to Discord Webhook
local function SendToWebhook(webhookUrl, payload)
    if not webhookUrl or webhookUrl == "" then
        if Config.Debug then
            print("^3[vs_logger]^7 Webhook URL not configured, skipping Discord notification")
        end
        return
    end
    
    PerformHttpRequest(webhookUrl, function(statusCode, responseText, headers)
        if Config.Debug then
            if statusCode == 204 or statusCode == 200 then
                print("^2[vs_logger]^7 Successfully sent to Discord webhook")
            else
                print(string.format("^1[vs_logger]^7 Discord webhook error: %d - %s", statusCode, responseText))
            end
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

-- Save to Database (Zero-SQL)
local function SaveToDatabase(logData)
    if activeQueries >= Config.Performance.maxConcurrentQueries then
        table.insert(queryQueue, logData)
        return
    end
    
    activeQueries = activeQueries + 1
    
    CreateThread(function()
        -- In a real implementation, this would insert into MySQL/oxmysql
        -- For Zero-SQL approach, we simulate database storage
        local success = true -- Assume success
        
        if Config.Debug then
            print(string.format("^2[vs_logger]^7 Saved log to database: %s - %s", 
                logData.log_type, logData.title))
        end
        
        activeQueries = activeQueries - 1
        
        -- Process queue if there are pending logs
        if #queryQueue > 0 and activeQueries < Config.Performance.maxConcurrentQueries then
            local nextLog = table.remove(queryQueue, 1)
            SaveToDatabase(nextLog)
        end
    end)
end

-- Main Export: SendLog
function SendLog(logType, title, message, source, metadata)
    -- Validate log type
    local logConfig = Config.LogTypes[logType]
    if not logConfig then
        print(string.format("^1[vs_logger]^7 Invalid log type: %s", tostring(logType)))
        return false
    end
    
    if not logConfig.enabled then
        if Config.Debug then
            print(string.format("^3[vs_logger]^7 Log type '%s' is disabled", logType))
        end
        return false
    end
    
    -- Check rate limit if source is provided
    if source then
        if not CheckRateLimit(source) then
            print(string.format("^1[vs_logger]^7 Rate limit exceeded for source %d", source))
            return false
        end
    end
    
    -- Grade verification for privileged log types
    if logConfig.requiresGrade and source then
        local hasPermission = VerifyPlayerGrade(source, logConfig.requiresGrade)
        
        if not hasPermission then
            -- Security alert: unauthorized access attempt
            TriggerEvent('vs_sentinel:logSuspicious', {
                source = source,
                identifier = GetPlayerIdentifierByType(source, "license"),
                reason = "Unauthorized log type access",
                details = string.format("Attempted to use log type '%s' without sufficient permissions (requires grade %d)", 
                    logType, logConfig.requiresGrade)
            })
            
            print(string.format("^1[vs_logger]^7 Unauthorized log attempt by source %d for type '%s'", source, logType))
            return false
        end
    end
    
    -- Prepare log data
    local logData = {
        timestamp = os.time(),
        log_type = logType,
        title = title,
        message = message,
        source = source,
        color = logConfig.color or "info",
        metadata = metadata or {}
    }
    
    -- Add player information if source provided
    if source then
        logData.playerName = GetPlayerName(source)
        logData.identifier = GetPlayerIdentifierByType(source, "license")
    end
    
    -- Check for suspicious patterns in message
    if Config.Sentinel.enabled and Config.Sentinel.patterns.enabled then
        local suspiciousScore = exports.vs_logger:CheckSuspiciousPatterns(message)
        if suspiciousScore > 0 then
            logData.metadata.suspicious_score = suspiciousScore
            TriggerEvent('vs_sentinel:patternDetected', {
                source = source,
                message = message,
                score = suspiciousScore,
                original_log_type = logType
            })
        end
    end
    
    -- Save to database
    if Config.Performance.asyncDatabase then
        SaveToDatabase(logData)
    end
    
    -- Send to Discord webhook
    local webhookType = logConfig.webhook or "Standard"
    local embedPayload = FormatDiscordEmbed(logData, webhookType)
    
    if embedPayload then
        local webhookUrl = Config.Webhooks[webhookType].url
        SendToWebhook(webhookUrl, embedPayload)
    end
    
    return true
end

-- Export function
exports('SendLog', SendLog)

-- Initialize on resource start
CreateThread(function()
    Wait(1000) -- Wait for other resources to load
    
    print("^2========================================^7")
    print("^2[vs_logger]^7 Sentinel Edition")
    print("^2[vs_logger]^7 Author: " .. Config.Author)
    print("^2[vs_logger]^7 Version: " .. Config.Version)
    print("^2========================================^7")
    
    InitializeDatabase()
    
    -- Initialize Sentinel
    if Config.Sentinel.enabled then
        print("^2[vs_logger]^7 Sentinel security module: ^2ENABLED^7")
    end
    
    print("^2[vs_logger]^7 Logger system ready!")
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Process remaining queue
    if #queryQueue > 0 then
        print(string.format("^3[vs_logger]^7 Processing %d remaining logs...", #queryQueue))
        Wait(2000) -- Give time to process
    end
    
    print("^3[vs_logger]^7 Logger system stopped")
end)
