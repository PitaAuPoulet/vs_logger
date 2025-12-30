-- Author: Vitaswift | Version: 1.0.0
--[[
    vs_gatekeeper - Vitaswift Architecture Validation Tool
    
    Mission: Analyser la conformité du code avec les standards Vitaswift
    et appliquer un VETO si les règles fondamentales sont violées.
    
    Critères d'Acceptation (Zéro Tolérance):
    1. Standard de Nommage (Prefix vs_)
    2. Doctrine Zero-SQL
    3. Intégrité du Bridge (vs_bridge)
    4. Validation Sentinel (Sécurité)
    5. Signature d'Architecte
]]

local Gatekeeper = {}

-- Couleurs pour la sortie console
local COLOR = {
    RESET = "^7",
    GREEN = "^2",
    YELLOW = "^3",
    RED = "^1",
    BLUE = "^4",
    CYAN = "^5"
}

-- Résultats de validation
Gatekeeper.Results = {
    naming = { pass = false, issues = {} },
    zeroSQL = { pass = false, issues = {} },
    bridge = { pass = false, issues = {} },
    sentinel = { pass = false, issues = {} },
    signature = { pass = false, issues = {} }
}

-- 1. Vérifier le Standard de Nommage (Prefix vs_)
function Gatekeeper:CheckNamingStandard(files)
    print(COLOR.CYAN .. "[GATEKEEPER] Vérification du standard de nommage..." .. COLOR.RESET)
    
    local issues = {}
    local hasIssues = false
    
    for _, file in ipairs(files) do
        local filename = file:match("([^/]+)$")
        
        -- Ignorer les fichiers de configuration système
        if not filename:match("^%.") and 
           not filename:match("README") and 
           not filename:match("LICENSE") and
           not filename:match("%.gitignore") then
            
            -- Vérifier le préfixe vs_ pour les fichiers .lua
            if filename:match("%.lua$") and not filename:match("^vs_") then
                table.insert(issues, string.format("❌ Fichier '%s' ne commence pas par 'vs_'", filename))
                hasIssues = true
            end
        end
    end
    
    -- Vérifier les variables globales/exports dans le code
    -- (Cette partie nécessiterait l'analyse du contenu des fichiers)
    
    self.Results.naming.pass = not hasIssues
    self.Results.naming.issues = issues
    
    if hasIssues then
        print(COLOR.RED .. "❌ FAIL: Standard de nommage" .. COLOR.RESET)
        for _, issue in ipairs(issues) do
            print(COLOR.YELLOW .. "  " .. issue .. COLOR.RESET)
        end
    else
        print(COLOR.GREEN .. "✅ PASS: Standard de nommage" .. COLOR.RESET)
    end
    
    return not hasIssues
end

-- 2. Vérifier la Doctrine Zero-SQL
function Gatekeeper:CheckZeroSQL(projectPath)
    print(COLOR.CYAN .. "[GATEKEEPER] Vérification de la doctrine Zero-SQL..." .. COLOR.RESET)
    
    local issues = {}
    local hasIssues = false
    
    -- Vérifier l'absence de fichiers .sql
    local sqlFiles = io.popen("find " .. projectPath .. " -name '*.sql' 2>/dev/null")
    if sqlFiles then
        for file in sqlFiles:lines() do
            if not file:match("node_modules") and not file:match("%.git") then
                table.insert(issues, string.format("❌ Fichier SQL détecté: %s", file))
                hasIssues = true
            end
        end
        sqlFiles:close()
    end
    
    -- Vérifier la présence de l'auto-création de tables
    local autoCreateFound = false
    local mainFile = io.open(projectPath .. "/server/vs_main.lua", "r")
    if mainFile then
        local content = mainFile:read("*all")
        mainFile:close()
        
        if content:match("CREATE TABLE IF NOT EXISTS") or 
           content:match("InitializeDatabase") or
           content:match("AutoCreateTables") then
            autoCreateFound = true
        end
    end
    
    if not autoCreateFound then
        table.insert(issues, "❌ Pas d'auto-création de tables détectée dans le code")
        hasIssues = true
    end
    
    self.Results.zeroSQL.pass = not hasIssues
    self.Results.zeroSQL.issues = issues
    
    if hasIssues then
        print(COLOR.RED .. "❌ FAIL: Doctrine Zero-SQL" .. COLOR.RESET)
        for _, issue in ipairs(issues) do
            print(COLOR.YELLOW .. "  " .. issue .. COLOR.RESET)
        end
    else
        print(COLOR.GREEN .. "✅ PASS: Doctrine Zero-SQL" .. COLOR.RESET)
    end
    
    return not hasIssues
end

-- 3. Vérifier l'Intégrité du Bridge
function Gatekeeper:CheckBridgeIntegrity(projectPath)
    print(COLOR.CYAN .. "[GATEKEEPER] Vérification de l'intégrité du bridge..." .. COLOR.RESET)
    
    local issues = {}
    local hasIssues = false
    
    -- Vérifier la dépendance vs_bridge dans fxmanifest.lua
    local manifestFile = io.open(projectPath .. "/fxmanifest.lua", "r")
    if manifestFile then
        local content = manifestFile:read("*all")
        manifestFile:close()
        
        if not content:match("vs_bridge") then
            table.insert(issues, "❌ Dépendance 'vs_bridge' manquante dans fxmanifest.lua")
            hasIssues = true
        end
    end
    
    -- Vérifier l'absence de dépendances directes ESX/QBCore
    local serverFiles = io.popen("find " .. projectPath .. "/server -name '*.lua' 2>/dev/null")
    if serverFiles then
        for file in serverFiles:lines() do
            local f = io.open(file, "r")
            if f then
                local content = f:read("*all")
                f:close()
                
                -- Vérifier les imports directs de frameworks
                if content:match("ESX%.GetPlayerData") or 
                   content:match("QBCore%.Functions") or
                   content:match("exports%.es_extended") or
                   content:match("exports%['qb%-core'%]") then
                    table.insert(issues, string.format("❌ Dépendance directe ESX/QBCore détectée dans %s", file))
                    hasIssues = true
                end
            end
        end
        serverFiles:close()
    end
    
    self.Results.bridge.pass = not hasIssues
    self.Results.bridge.issues = issues
    
    if hasIssues then
        print(COLOR.RED .. "❌ FAIL: Intégrité du Bridge" .. COLOR.RESET)
        for _, issue in ipairs(issues) do
            print(COLOR.YELLOW .. "  " .. issue .. COLOR.RESET)
        end
    else
        print(COLOR.GREEN .. "✅ PASS: Intégrité du Bridge" .. COLOR.RESET)
    end
    
    return not hasIssues
end

-- 4. Vérifier la Validation Sentinel
function Gatekeeper:CheckSentinelValidation(projectPath)
    print(COLOR.CYAN .. "[GATEKEEPER] Vérification de la validation Sentinel..." .. COLOR.RESET)
    
    local issues = {}
    local hasIssues = false
    
    -- Vérifier la présence du module Sentinel
    local sentinelFile = io.open(projectPath .. "/server/vs_sentinel.lua", "r")
    if not sentinelFile then
        table.insert(issues, "❌ Module Sentinel manquant (vs_sentinel.lua)")
        hasIssues = true
    else
        local content = sentinelFile:read("*all")
        sentinelFile:close()
        
        -- Vérifier les fonctionnalités essentielles
        local requiredFeatures = {
            { pattern = "RegisterServerEvent", name = "Enregistrement d'événements serveur" },
            { pattern = "honeyPot", name = "HoneyPot events" },
            { pattern = "CheckSuspiciousPatterns", name = "Détection de patterns suspects" }
        }
        
        for _, feature in ipairs(requiredFeatures) do
            if not content:match(feature.pattern) then
                table.insert(issues, string.format("❌ Fonctionnalité manquante: %s", feature.name))
                hasIssues = true
            end
        end
    end
    
    -- Vérifier la validation server-side
    local mainFile = io.open(projectPath .. "/server/vs_main.lua", "r")
    if mainFile then
        local content = mainFile:read("*all")
        mainFile:close()
        
        -- Vérifier la présence de validation des grades/permissions
        if not content:match("VerifyPlayerGrade") and not content:match("requiresGrade") then
            table.insert(issues, "❌ Validation des permissions manquante")
            hasIssues = true
        end
    end
    
    self.Results.sentinel.pass = not hasIssues
    self.Results.sentinel.issues = issues
    
    if hasIssues then
        print(COLOR.RED .. "❌ FAIL: Validation Sentinel" .. COLOR.RESET)
        for _, issue in ipairs(issues) do
            print(COLOR.YELLOW .. "  " .. issue .. COLOR.RESET)
        end
    else
        print(COLOR.GREEN .. "✅ PASS: Validation Sentinel" .. COLOR.RESET)
    end
    
    return not hasIssues
end

-- 5. Vérifier la Signature d'Architecte
function Gatekeeper:CheckArchitectSignature(projectPath)
    print(COLOR.CYAN .. "[GATEKEEPER] Vérification de la signature d'architecte..." .. COLOR.RESET)
    
    local issues = {}
    local hasIssues = false
    
    -- Vérifier la signature dans tous les fichiers Lua
    local luaFiles = io.popen("find " .. projectPath .. " -name '*.lua' -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null")
    if luaFiles then
        for file in luaFiles:lines() do
            local f = io.open(file, "r")
            if f then
                local firstLines = ""
                for i = 1, 10 do
                    local line = f:read("*line")
                    if not line then break end
                    firstLines = firstLines .. line .. "\n"
                end
                f:close()
                
                -- Vérifier la présence de "Author: Vitaswift"
                if not firstLines:match("Author:%s*Vitaswift") then
                    local filename = file:match("([^/]+)$")
                    table.insert(issues, string.format("❌ Signature manquante dans %s", filename))
                    hasIssues = true
                end
            end
        end
        luaFiles:close()
    end
    
    self.Results.signature.pass = not hasIssues
    self.Results.signature.issues = issues
    
    if hasIssues then
        print(COLOR.RED .. "❌ FAIL: Signature d'Architecte" .. COLOR.RESET)
        for _, issue in ipairs(issues) do
            print(COLOR.YELLOW .. "  " .. issue .. COLOR.RESET)
        end
    else
        print(COLOR.GREEN .. "✅ PASS: Signature d'Architecte" .. COLOR.RESET)
    end
    
    return not hasIssues
end

-- Générer le rapport de conformité
function Gatekeeper:GenerateReport()
    print(COLOR.BLUE .. "\n========================================" .. COLOR.RESET)
    print(COLOR.BLUE .. "  RAPPORT DE CONFORMITÉ VITASWIFT" .. COLOR.RESET)
    print(COLOR.BLUE .. "========================================" .. COLOR.RESET)
    
    local criteria = {
        { name = "Standard de Nommage (vs_)", result = self.Results.naming },
        { name = "Doctrine Zero-SQL", result = self.Results.zeroSQL },
        { name = "Intégrité du Bridge", result = self.Results.bridge },
        { name = "Validation Sentinel", result = self.Results.sentinel },
        { name = "Signature d'Architecte", result = self.Results.signature }
    }
    
    local allPassed = true
    
    for i, criterion in ipairs(criteria) do
        local status = criterion.result.pass and "PASS" or "FAIL"
        local statusColor = criterion.result.pass and COLOR.GREEN or COLOR.RED
        local icon = criterion.result.pass and "✅" or "❌"
        
        print(string.format("%d. %s%s %s%s", i, statusColor, icon, criterion.name, COLOR.RESET))
        print(string.format("   Status: %s%s%s", statusColor, status, COLOR.RESET))
        
        if not criterion.result.pass then
            allPassed = false
            print(string.format("   Problèmes: %d", #criterion.result.issues))
        end
    end
    
    print(COLOR.BLUE .. "\n========================================" .. COLOR.RESET)
    print(COLOR.BLUE .. "  DÉCISION FINALE" .. COLOR.RESET)
    print(COLOR.BLUE .. "========================================" .. COLOR.RESET)
    
    if allPassed then
        print(COLOR.GREEN .. "✅ APPROUVÉ - Tous les critères sont respectés" .. COLOR.RESET)
        print(COLOR.GREEN .. "Le code est conforme aux standards Vitaswift." .. COLOR.RESET)
    else
        print(COLOR.RED .. "❌ VETO - Standards Vitaswift violés" .. COLOR.RESET)
        print(COLOR.RED .. "Cette Pull Request ne peut pas être acceptée." .. COLOR.RESET)
        print(COLOR.YELLOW .. "\nCorrections requises avant approbation." .. COLOR.RESET)
    end
    
    print(COLOR.BLUE .. "========================================\n" .. COLOR.RESET)
    
    return allPassed
end

-- Fonction principale d'audit
function Gatekeeper:Audit(projectPath)
    print(COLOR.BLUE .. "\n========================================" .. COLOR.RESET)
    print(COLOR.BLUE .. "  VITASWIFT ARCHITECTURE GATEKEEPER" .. COLOR.RESET)
    print(COLOR.BLUE .. "  Senior Security & Architecture Auditor" .. COLOR.RESET)
    print(COLOR.BLUE .. "========================================\n" .. COLOR.RESET)
    
    projectPath = projectPath or "."
    
    -- Collecter tous les fichiers Lua
    local files = {}
    local fileList = io.popen("find " .. projectPath .. " -name '*.lua' -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null")
    if fileList then
        for file in fileList:lines() do
            table.insert(files, file)
        end
        fileList:close()
    end
    
    -- Exécuter toutes les vérifications
    self:CheckNamingStandard(files)
    self:CheckZeroSQL(projectPath)
    self:CheckBridgeIntegrity(projectPath)
    self:CheckSentinelValidation(projectPath)
    self:CheckArchitectSignature(projectPath)
    
    -- Générer le rapport final
    local approved = self:GenerateReport()
    
    return approved
end

-- Export pour utilisation externe
if IsDuplicityVersion and IsDuplicityVersion() then
    -- Pour FiveM serveur
    exports('AuditProject', function()
        return Gatekeeper:Audit(GetResourcePath(GetCurrentResourceName()))
    end)
end

return Gatekeeper
