QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("giveRandomItemToPlayer")
AddEventHandler("giveRandomItemToPlayer", function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('QBCore:Notify', src, "Recebeste " .. amount .. "x " .. item, "success")
    else
        print("Erro: Jogador não encontrado!")
    end
end)