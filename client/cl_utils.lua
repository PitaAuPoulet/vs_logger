-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Client Utilities

Utils = {}

--- Récupère la position actuelle du joueur formatée pour les logs
--- @return table {x, y, z}
function Utils.GetPlayerCoords()
    local coords = GetEntityCoords(PlayerPedId())
    return {
        x = math.floor(coords.x * 100) / 100,
        y = math.floor(coords.y * 100) / 100,
        z = math.floor(coords.z * 100) / 100
    }
end

-- Exemple d'utilisation automatique : log de connexion client
-- (Peut être désactivé ou déplacé selon les besoins)
RegisterNetEvent('vs_bridge:playerLoaded', function()
    local coords = Utils.GetPlayerCoords()
    SendLogToServer("System", "Player Loaded at location", { coords = coords })
end)