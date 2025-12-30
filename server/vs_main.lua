--[[
    vs_logger - Logique Serveur Principale
    Author: Vitaswift | Version: 1.0.0
    
    Fonctionnalité de journalisation principale avec gestion de base de données Zero-SQL
]]

local rateLimitTracker = {}
local queryQueue = {}
local activeQueries = 0

-- Initialiser la base de données (approche Zero-SQL)
-- NOTE: Nécessite MySQL/MariaDB (utilise la syntaxe MySQL spécifique)
local function InitializeDatabase()
    if Config.Debug then
        VsLog('info', _L('db_initializing'))
    end
    
    -- Pour FiveM, nous utilisons l'approche Zero-SQL avec MySQL/MariaDB
    -- Nécessite oxmysql ou mysql-async
    -- Les tables sont créées automatiquement au premier démarrage (Zero-SQL)
    
    CreateThread(function()
        -- Créer la structure de la table logs (syntaxe MySQL/MariaDB)
        local createTableQuery = [[
            CREATE TABLE IF NOT EXISTS vs_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
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
        
        -- Exécuter la création de table avec oxmysql ou mysql-async
        -- Note: pcall capture seulement les erreurs Lua, pas les erreurs SQL
        -- Pour la production, considérer l'ajout de gestion callback/promise si nécessaire
        local success = pcall(function()
            if GetResourceState('oxmysql') == 'started' then
                exports.oxmysql:execute(createTableQuery)
            elseif GetResourceState('mysql-async') == 'started' then
                exports['mysql-async']:mysql_execute(createTableQuery)
            else
                VsLog('warning', _L('db_no_mysql'))
            end
        end)
        
        if success then
            if Config.Debug then
                VsLog('success', _L('db_initialized'))
            end
        else
            VsLog('error', _L('db_error'))
        end
    end)
    
    return true
end

-- Limiteur de taux
local function CheckRateLimit(source)
    if not Config.RateLimit.enabled then
        return true
    end
    
    local identifier = GetPlayerIdentifierByType(source, "license") or tostring(source)
    
    -- Vérifier la liste blanche
    for _, whitelisted in ipairs(Config.RateLimit.whitelist) do
        if identifier == whitelisted then
            return true
        end
    end
    
    local currentTime = os.time()
    
    -- Initialiser le suivi pour ce joueur
    if not rateLimitTracker[identifier] then
        rateLimitTracker[identifier] = {
            requests = {},
            violations = 0,
            cooldownUntil = 0
        }
    end
    
    local tracker = rateLimitTracker[identifier]
    
    -- Vérifier si en cooldown
    if tracker.cooldownUntil > currentTime then
        if Config.Debug then
            VsLog('warning', _L('ratelimit_cooldown', identifier))
        end
        return false
    end
    
    -- Nettoyer les anciennes requêtes (plus de 1 minute)
    local validRequests = {}
    for _, timestamp in ipairs(tracker.requests) do
        if currentTime - timestamp < 60 then
            table.insert(validRequests, timestamp)
        end
    end
    tracker.requests = validRequests
    
    -- Vérifier si la limite est dépassée
    if #tracker.requests >= Config.RateLimit.maxRequestsPerMinute then
        tracker.violations = tracker.violations + 1
        tracker.cooldownUntil = currentTime + Config.RateLimit.cooldownAfterLimit
        
        -- Envoyer une alerte de sécurité si le seuil est atteint
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
            VsLog('error', _L('ratelimit_exceeded', identifier, tracker.violations))
        end
        
        return false
    end
    
    -- Ajouter la requête actuelle
    table.insert(tracker.requests, currentTime)
    return true
end

-- Vérifier le grade du joueur via vs_bridge
local function VerifyPlayerGrade(source, requiredGrade)
    if not Config.UseBridge then
        return true -- Contourner si le bridge est désactivé
    end
    
    local success, grade = pcall(function()
        return exports[Config.BridgeName]:GetPlayerGrade(source)
    end)
    
    if not success then
        VsLog('error', _L('bridge_error'))
        return false
    end
    
    return grade and grade >= requiredGrade
end

-- Formater l'embed Discord
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

-- Envoyer au webhook Discord
local function SendToWebhook(webhookUrl, payload)
    if not webhookUrl or webhookUrl == "" then
        if Config.Debug then
            VsLog('warning', _L('webhook_not_configured'))
        end
        return
    end
    
    PerformHttpRequest(webhookUrl, function(statusCode, responseText, headers)
        if Config.Debug then
            if statusCode == 204 or statusCode == 200 then
                VsLog('success', _L('webhook_success'))
            else
                VsLog('error', _L('webhook_error', statusCode, responseText))
            end
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

-- Sauvegarder dans la base de données (Zero-SQL)
local function SaveToDatabase(logData)
    if activeQueries >= Config.Performance.maxConcurrentQueries then
        table.insert(queryQueue, logData)
        return
    end
    
    activeQueries = activeQueries + 1
    
    CreateThread(function()
        -- Insérer le log dans MySQL
        local success = pcall(function()
            local metadataJson = logData.metadata and json.encode(logData.metadata) or '{}'
            
            local query = [[
                INSERT INTO vs_logs 
                (timestamp, log_type, player_source, player_identifier, player_name, title, message, metadata) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ]]
            
            local params = {
                logData.timestamp,
                logData.log_type,
                logData.source,
                logData.identifier,
                logData.playerName,
                logData.title,
                logData.message,
                metadataJson
            }
            
            if GetResourceState('oxmysql') == 'started' then
                exports.oxmysql:execute(query, params)
            elseif GetResourceState('mysql-async') == 'started' then
                exports['mysql-async']:mysql_execute(query, params)
            end
        end)
        
        if Config.Debug then
            if success then
                VsLog('success', _L('db_saved', logData.log_type, logData.title))
            else
                VsLog('error', _L('db_save_failed', logData.log_type, logData.title))
            end
        end
        
        activeQueries = activeQueries - 1
        
        -- Traiter la file d'attente s'il y a des logs en attente
        if #queryQueue > 0 and activeQueries < Config.Performance.maxConcurrentQueries then
            local nextLog = table.remove(queryQueue, 1)
            SaveToDatabase(nextLog)
        end
    end)
end

-- Export principal: SendLog
function SendLog(logType, title, message, source, metadata)
    -- Valider le type de log
    local logConfig = Config.LogTypes[logType]
    if not logConfig then
        VsLog('error', _L('log_invalid_type', tostring(logType)))
        return false
    end
    
    if not logConfig.enabled then
        if Config.Debug then
            VsLog('warning', _L('log_disabled', logType))
        end
        return false
    end
    
    -- Vérifier la limitation de taux si une source est fournie
    if source then
        if not CheckRateLimit(source) then
            VsLog('error', _L('log_ratelimit', source))
            return false
        end
    end
    
    -- Vérification du grade pour les types de logs privilégiés
    if logConfig.requiresGrade and source then
        local hasPermission = VerifyPlayerGrade(source, logConfig.requiresGrade)
        
        if not hasPermission then
            -- Alerte de sécurité: tentative d'accès non autorisé
            TriggerEvent('vs_sentinel:logSuspicious', {
                source = source,
                identifier = GetPlayerIdentifierByType(source, "license"),
                reason = "Unauthorized log type access",
                details = string.format("Attempted to use log type '%s' without sufficient permissions (requires grade %d)", 
                    logType, logConfig.requiresGrade)
            })
            
            VsLog('error', _L('log_unauthorized', source, logType))
            return false
        end
    end
    
    -- Préparer les données du log
    local logData = {
        timestamp = os.time(),
        log_type = logType,
        title = title,
        message = message,
        source = source,
        color = logConfig.color or "info",
        metadata = metadata or {}
    }
    
    -- Ajouter les informations du joueur si une source est fournie
    if source then
        logData.playerName = GetPlayerName(source)
        logData.identifier = GetPlayerIdentifierByType(source, "license")
    end
    
    -- Vérifier les motifs suspects dans le message
    if Config.Sentinel.enabled and Config.Sentinel.patterns.enabled then
        -- Sera géré par le module vs_sentinel après la journalisation
        TriggerEvent('vs_sentinel:checkPatterns', {
            source = source,
            message = message,
            original_log_type = logType
        })
    end
    
    -- Sauvegarder dans la base de données
    if Config.Performance.asyncDatabase then
        SaveToDatabase(logData)
    end
    
    -- Envoyer au webhook Discord
    local webhookType = logConfig.webhook or "Standard"
    local embedPayload = FormatDiscordEmbed(logData, webhookType)
    
    if embedPayload then
        local webhookUrl = Config.Webhooks[webhookType].url
        SendToWebhook(webhookUrl, embedPayload)
    end
    
    return true
end

-- Exporter la fonction
exports('SendLog', SendLog)

-- Initialiser au démarrage de la ressource
CreateThread(function()
    Wait(1000) -- Attendre le chargement des autres ressources
    
    print("^2========================================^7")
    VsLog('success', _L('system_starting'))
    VsLog('info', _L('system_author', Config.Author))
    VsLog('info', _L('system_version', Config.Version))
    print("^2========================================^7")
    
    InitializeDatabase()
    
    -- Initialiser Sentinel
    if Config.Sentinel.enabled then
        VsLog('success', _L('sentinel_enabled'))
    end
    
    VsLog('success', _L('system_ready'))
end)

-- Nettoyage à l'arrêt de la ressource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Traiter la file d'attente restante avant l'arrêt
    if #queryQueue > 0 then
        VsLog('warning', _L('db_processing_queue', #queryQueue))
        
        -- Traiter tous les logs en file d'attente
        local processed = 0
        while #queryQueue > 0 and processed < 100 do -- Limiter à 100 par sécurité
            local logData = table.remove(queryQueue, 1)
            SaveToDatabase(logData)
            processed = processed + 1
            Wait(50) -- Petit délai entre les opérations
        end
        
        -- Attendre que les requêtes actives se terminent
        local waitTime = 0
        while activeQueries > 0 and waitTime < 5000 do
            Wait(100)
            waitTime = waitTime + 100
        end
        
        VsLog('success', _L('db_processed', processed))
    end
    
    VsLog('warning', _L('system_stopped'))
end)
