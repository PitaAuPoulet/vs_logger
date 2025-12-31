-- Author: Vitaswift | Part of: vs_logger
-- Standard: CodeArchitect Elite | Temporary Test Script

CreateThread(function()
    -- Attendre que le système soit initialisé
    Wait(2000)
    
    print(("^3%s ^7Running system diagnostics..."):format(Config.Prefix))

    -- 1. Test du Log Système (Serveur)
    exports.vs_logger:LogAction(0, "System", "Diagnostic de démarrage effectué", { status = "OK", version = "1.0.0" })

    -- 2. Commande de test pour tester le log Joueur + Bridge
    RegisterCommand("testlog", function(source, args, rawCommand)
        if source == 0 then 
            print("Cette commande doit être exécutée par un joueur.")
            return 
        end

        local testData = {
            reason = args[1] or "Aucune raison spécifiée",
            pos = GetEntityCoords(GetPlayerPed(source))
        }

        -- Appel de l'export
        exports.vs_logger:LogAction(source, "Admin", "Test manuel via commande /testlog", testData)
        
        TriggerClientEvent('chat:addMessage', source, {
            args = { Config.Prefix, "Le log de test a été envoyé. Vérifiez votre console et votre DB." }
        })
    end, true) -- 'true' signifie que seuls les admins (ACE) peuvent l'exécuter
end)