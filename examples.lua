-- Author: Vitaswift | Version: 1.0.0
--[[
    vs_logger - Exemples d'Utilisation
    
    Ce fichier démontre comment utiliser vs_logger dans vos scripts FiveM.
    Copiez ces exemples dans vos scripts côté serveur.
]]

-- ============================================
-- EXEMPLES DE JOURNALISATION BASIQUE
-- ============================================

-- Exemple 1: Enregistrer une connexion de joueur
RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    
    exports.vs_logger:SendLog(
        'player',
        'Player Connecting',
        string.format('%s is connecting to the server', name),
        source
    )
end)

-- Example 2: Log a player action
RegisterCommand('myvehicle', function(source, args, rawCommand)
    local playerName = GetPlayerName(source)
    
    -- Your vehicle spawn logic here
    -- ...
    
    exports.vs_logger:SendLog(
        'player',
        'Vehicle Spawned',
        string.format('%s spawned a personal vehicle', playerName),
        source,
        {
            ['Vehicle Model'] = args[1] or 'default',
            ['Spawn Method'] = 'command'
        }
    )
end)

-- ============================================
-- ADMIN ACTION LOGGING
-- ============================================

-- Example 3: Log admin kick action
RegisterCommand('kick', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, ' ', 2)
    
    if not targetId then
        return
    end
    
    local adminName = GetPlayerName(source)
    local targetName = GetPlayerName(targetId)
    
    -- Your kick logic here
    -- DropPlayer(targetId, reason)
    
    exports.vs_logger:SendLog(
        'admin',
        'Player Kicked',
        string.format('%s kicked %s', adminName, targetName),
        source,
        {
            ['Target'] = string.format('%s [%d]', targetName, targetId),
            ['Reason'] = reason or 'No reason provided',
            ['Admin'] = adminName
        }
    )
end, false)

-- Example 4: Log admin ban action
RegisterServerEvent('myserver:banPlayer')
AddEventHandler('myserver:banPlayer', function(targetId, duration, reason)
    local source = source
    local adminName = GetPlayerName(source)
    local targetName = GetPlayerName(targetId)
    local identifier = GetPlayerIdentifier(targetId, 0)
    
    -- Your ban logic here
    -- ...
    
    exports.vs_logger:SendLog(
        'admin',
        'Player Banned',
        string.format('%s banned %s for %s hours', adminName, targetName, duration),
        source,
        {
            ['Target'] = string.format('%s [%d]', targetName, targetId),
            ['Identifier'] = identifier,
            ['Duration'] = string.format('%d hours', duration),
            ['Reason'] = reason,
            ['Admin'] = adminName
        }
    )
end)

-- ============================================
-- SECURITY LOGGING
-- ============================================

-- Example 5: Log suspicious economy transaction
RegisterServerEvent('myserver:giveMoney')
AddEventHandler('myserver:giveMoney', function(targetId, amount)
    local source = source
    
    -- Check for suspicious amount
    if amount > 100000 then
        exports.vs_logger:SendLog(
            'security',
            'Suspicious Money Transaction',
            string.format('Large money transfer attempted: $%d', amount),
            source,
            {
                ['Amount'] = string.format('$%d', amount),
                ['Target'] = string.format('Player %d', targetId),
                ['Source Player'] = GetPlayerName(source)
            }
        )
    end
    
    -- Your normal transaction logic here
    -- ...
end)

-- Example 6: Log unauthorized resource access
RegisterServerEvent('myserver:adminPanel')
AddEventHandler('myserver:adminPanel', function()
    local source = source
    
    -- Check if player is admin (example - adjust to your framework)
    local isAdmin = false -- Your admin check here
    
    if not isAdmin then
        exports.vs_logger:SendLog(
            'security',
            'Unauthorized Admin Panel Access',
            'Player attempted to access admin panel without permissions',
            source,
            {
                ['Attempted Action'] = 'Open Admin Panel',
                ['Player'] = GetPlayerName(source)
            }
        )
        return
    end
    
    -- Normal admin panel logic
    -- ...
end)

-- ============================================
-- SYSTEM LOGGING
-- ============================================

-- Example 7: Log resource start/stop
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'my_critical_resource' then
        exports.vs_logger:SendLog(
            'system',
            'Critical Resource Started',
            string.format('Resource %s has been started', resourceName),
            nil,
            {
                ['Resource'] = resourceName,
                ['Status'] = 'Started'
            }
        )
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'my_critical_resource' then
        exports.vs_logger:SendLog(
            'system',
            'Critical Resource Stopped',
            string.format('Resource %s has been stopped', resourceName),
            nil,
            {
                ['Resource'] = resourceName,
                ['Status'] = 'Stopped'
            }
        )
    end
end)

-- ============================================
-- PATTERN DETECTION USAGE
-- ============================================

-- Example 8: Check user input for suspicious content
RegisterServerEvent('myserver:sendMessage')
AddEventHandler('myserver:sendMessage', function(message)
    local source = source
    
    -- Check message for suspicious patterns
    local suspiciousScore = exports.vs_logger:CheckSuspiciousPatterns(message)
    
    if suspiciousScore > 0 then
        print(string.format('[SECURITY] Suspicious message detected from player %d (score: %d)', 
            source, suspiciousScore))
        
        -- Optionally block the message or take other action
        -- return
    end
    
    -- Continue with normal message handling
    -- ...
end)

-- ============================================
-- CUSTOM METADATA LOGGING
-- ============================================

-- Example 9: Log with rich metadata
RegisterServerEvent('myserver:purchaseItem')
AddEventHandler('myserver:purchaseItem', function(itemName, price, quantity)
    local source = source
    local playerName = GetPlayerName(source)
    
    exports.vs_logger:SendLog(
        'player',
        'Item Purchase',
        string.format('%s purchased %dx %s', playerName, quantity, itemName),
        source,
        {
            ['Item'] = itemName,
            ['Quantity'] = tostring(quantity),
            ['Price'] = string.format('$%d', price),
            ['Total Cost'] = string.format('$%d', price * quantity),
            ['Player Balance'] = '$1,234,567' -- Your balance check here
        }
    )
end)

-- ============================================
-- CHECKING SENTINEL STATUS
-- ============================================

-- Example 10: Get sentinel module status
RegisterCommand('checksentinel', function(source, args, rawCommand)
    local status = exports.vs_logger:GetSentinelStatus()
    
    print('=== Sentinel Status ===')
    print('Enabled: ' .. tostring(status.enabled))
    print('HoneyPot Events: ' .. status.honeyPotEvents)
    print('Suspicious Players: ' .. status.suspiciousPlayers)
    print('HoneyPot Triggers: ' .. status.honeyPotTriggers)
    print('Pattern Detection: ' .. tostring(status.patternDetection))
end, false)

-- ============================================
-- ERROR HANDLING
-- ============================================

-- Example 11: Proper error handling when using vs_logger
local function SafeLog(logType, title, message, source, metadata)
    local success, result = pcall(function()
        return exports.vs_logger:SendLog(logType, title, message, source, metadata)
    end)
    
    if not success then
        print('[ERROR] Failed to send log: ' .. tostring(result))
        return false
    end
    
    return result
end

-- Usage
RegisterServerEvent('myserver:myEvent')
AddEventHandler('myserver:myEvent', function()
    local source = source
    SafeLog('player', 'My Event', 'Event triggered', source)
end)

-- ============================================
-- INTEGRATION WITH EXISTING SYSTEMS
-- ============================================

-- Example 12: Integration with existing logging functions
local function MyOldLoggingFunction(message, source)
    -- Your old logging code
    print('[LOG] ' .. message)
    
    -- Add vs_logger for Discord notifications
    exports.vs_logger:SendLog(
        'system',
        'Legacy Log',
        message,
        source
    )
end

-- ============================================
-- BATCH LOGGING (for high-frequency events)
-- ============================================

-- Example 13: Batch logging for performance
local logQueue = {}
local lastFlush = 0

local function QueueLog(logType, title, message, source, metadata)
    table.insert(logQueue, {
        logType = logType,
        title = title,
        message = message,
        source = source,
        metadata = metadata
    })
end

CreateThread(function()
    while true do
        Wait(5000) -- Flush every 5 seconds
        
        if #logQueue > 0 then
            -- Send a summary log instead of individual logs
            local summary = string.format('Processed %d events', #logQueue)
            
            exports.vs_logger:SendLog(
                'system',
                'Event Batch Summary',
                summary,
                nil,
                {
                    ['Total Events'] = tostring(#logQueue),
                    ['Period'] = '5 seconds'
                }
            )
            
            logQueue = {} -- Clear queue
        end
    end
end)
