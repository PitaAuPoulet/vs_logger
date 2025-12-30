--[[
    vs_logger - Sentinel Edition
    Author: Vitaswift | Version: 1.0.0
    
    Système de journalisation avancé avec surveillance de sécurité intégrée
    et capacités anti-cheat pour les serveurs FiveM.
]]

fx_version 'cerulean'
game 'gta5'

author 'Vitaswift'
description 'vs_logger - Système Avancé de Journalisation & Surveillance de Sécurité (Sentinel Edition)'
version '1.1.0'

-- Métadonnées Vitaswift
vs_metadata {
    prefix = 'vs_',
    category = 'logging',
    bridge_required = true,
    zero_sql = true
}

-- Configuration
shared_script 'config.lua'

-- Locales
shared_scripts {
    'shared/vs_locale.lua',
    'locales/fr.lua',
    'locales/en.lua'
}

-- Scripts Serveur
server_scripts {
    'server/vs_main.lua',
    'server/vs_sentinel.lua'
}

-- Dépendances
dependencies {
    'vs_bridge' -- Requis pour la vérification des grades
}

-- Exports
server_exports {
    'SendLog'
}

-- Désactiver certains natives pour la sécurité
disable_npc_spawn_blocking 'false'
