-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite

fx_version 'cerulean'
game 'gta5'

shared_scripts {
    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_database.lua',
    'server/sv_webhooks.lua',   -- DOIT ÊTRE AVANT sv_gatekeeper
    'server/sv_gatekeeper.lua', -- Contient InternalLog
    'server/sv_main.lua'        -- Contient l'Export
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_utils.lua'
}

exports {
    'LogAction'
}

lua54 'yes'