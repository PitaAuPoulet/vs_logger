-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite

fx_version 'cerulean'
game 'gta5'

author 'Vitaswift'
description 'Advanced Logging System with Bridge Integration'
version '1.0.0'

-- Configuration et Shared
shared_scripts {
    'shared/config.lua',
    '@vs_bridge/shared/sh_loader.lua'
}

-- Scripts Serveur
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_database.lua',
    'server/sv_gatekeeper.lua',
    'server/sv_main.lua',
    'server/sv_test.lua'      -- La virgule ici est cruciale
}

-- Scripts Client
client_scripts {
    'client/cl_main.lua',
    'client/cl_utils.lua'
}

-- Exportations pour les autres scripts
exports {
    'LogAction',
    'LogSecurity'
}

lua54 'yes'