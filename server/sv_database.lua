-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Zero-SQL System

CreateThread(function()
    if not Config.Database.AutoCreate then return end

    -- Schéma de la table vs_logs
    local sqlQuery = [[
        CREATE TABLE IF NOT EXISTS `]] .. Config.Database.TableName .. [[` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `identifier` VARCHAR(50) NOT NULL,
            `playerName` VARCHAR(100) DEFAULT 'Unknown',
            `category` VARCHAR(50) DEFAULT 'System',
            `action` TEXT NOT NULL,
            `metadata` LONGTEXT DEFAULT NULL,
            `ip_address` VARCHAR(45) DEFAULT NULL,
            `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]]

    MySQL.query(sqlQuery, {}, function(result)
        if result then
            print(("^2%s ^7Database structure validated: Table '%s' is ready."):format(Config.Prefix, Config.Database.TableName))
        end
    end)
end)