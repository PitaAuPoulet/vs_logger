--[[
    vs_logger - Sentinel Edition
    Author: Vitaswift
    Version: 1.1.0
    
    Advanced logging system with built-in security monitoring
    and anti-cheat capabilities for FiveM servers.
]]

fx_version 'cerulean'
game 'gta5'

author 'Vitaswift'
description 'vs_logger - Advanced Logging & Security Monitoring System (Sentinel Edition)'
version '1.1.0'

-- Vitaswift Metadata
vs_metadata {
    prefix = 'vs_',
    category = 'logging',
    bridge_required = true,
    zero_sql = true
}

-- Configuration
shared_script 'config.lua'

-- Server Scripts
server_scripts {
    'server/vs_main.lua',
    'server/vs_sentinel.lua'
}

-- Dependencies
dependencies {
    'vs_bridge' -- Required for grade verification
}

-- Exports
server_exports {
    'SendLog'
}

-- Disable specific natives for security
disable_npc_spawn_blocking 'false'
