QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function(source)
    local servico = false
    while true do
        local blipLoc = { x = -428.75, y = -1728.04, z = 18.87 }
        local pedLoc = GetEntityCoords(PlayerPedId())
        local distancia = #(vector3(pedLoc.x, pedLoc.y, pedLoc.z) - vector3(-428.75, -1728.04, 18.87))
        if (distancia <= 13) then
            DrawMarker(23, blipLoc.x, blipLoc.y, blipLoc.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 200, 0, 110,
                false, false, 2, false, nil, nil, false)
            if (distancia <= 7) then
                DrawText3D(blipLoc.x, blipLoc.y, 19.25, "Entrar em serviço ~g~[~w~E~g~]")
                if IsControlJustPressed(0, 38) and (distancia <= 5) then
                    if servico == true then
                        QBCore.Functions.Notify("Ja estas em serviço!", "error", 3000)
                    end
                    iniciarServico()
                end
            end
        end
        Wait(3)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        local textLength = string.len(text) / 370 -- Ajusta a largura do fundo dinamicamente

        -- Fundo preto semi-transparente
        DrawRect(_x, _y + 0.012, textLength + 0.015, 0.03, 0, 0, 0, 92) -- RGBA (preto com transparência)

        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function gerarBlip(type, text, locAlready)
    local ped = PlayerPedId()
    local randomIndex
    local randomLocation

    -- Tentar encontrar um local não usado
    repeat
        randomIndex = math.random(1, #COORDS)
        randomLocation = COORDS[randomIndex]
    until not locAlready[randomIndex]

    -- Marcar o local como usado
    locAlready[randomIndex] = true

    local randomLocVec3 = vector3(randomLocation.x, randomLocation.y, randomLocation.z)

    -- Criar o blip no mapa
    local blip = AddBlipForCoord(randomLocation.x, randomLocation.y, randomLocation.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Recolha de Lixo")
    EndTextCommandSetBlipName(blip)

    -- Espera até o jogador recolher o lixo
    while true do
        local pedCoords = GetEntityCoords(ped)
        local distance = #(pedCoords - randomLocVec3)

        if distance <= 13 then
            DrawText3D(randomLocation.x, randomLocation.y, randomLocation.z, text)
            DrawMarker(type, randomLocation.x, randomLocation.y, randomLocation.z,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
                0, 200, 0, 110, false, false, 2, false, nil, nil, false)

            if IsControlJustPressed(0, 38) and distance <= 4 then
                -- Iniciar animação
                TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, false)
                QBCore.Functions.Progressbar(
                    "apanhar_lixo",
                    "A apanhar lixo...",
                    7800,
                    false,
                    true,
                    { disableMovement = true, disableCombat = true },
                    nil,
                    nil,
                    nil,
                    function()
                        ClearPedTasks(ped)
                        QBCore.Functions.Notify("Lixo recolhido!", "success", 3000)

                        -- Dar item ao jogador
                        darItem("giveRandomItemToPlayer", 0, 0)

                        -- Apagar o blip antigo
                        RemoveBlip(blip)

                        return true -- Retorna sucesso
                    end,
                    function()
                        ClearPedTasks(ped)
                        QBCore.Functions.Notify("Ação cancelada!", "error", 3000)
                        return false -- Retorna falha para interromper o serviço
                    end
                )
                return true
            end
        end
        Wait(3)
    end
end

function darItem(nome, item, quantidade)
    local items = {
        "plastic",
        "metalscrap",
        "copper",
        "aluminum",
        "aluminumoxide",
        "iron",
        "ironoxide",
        "steel",
        "rubber",
        "glass"
    }
    local randomIndexItem = math.random(#items)
    local randomItem = items[randomIndexItem]
    local amount = math.random(3, 8)
    if item == 0 and quantidade == 0 then
        TriggerServerEvent(nome, randomItem, amount)
    end
    if item > 0 and quantidade > 0 then
        TriggerServerEvent(nome, item, quantidade)
    end
end

local servico = false

function iniciarServico()
    if not servico then
        servico = true
        QBCore.Functions.Notify("Entras-te em serviço com sucesso!", "success", 3000)
        QBCore.Functions.LoadModel(3039269212)

        -- Criar veículo do jogador
        local vehicle = CreateVehicle(3039269212, -433.21, -1705.66, 19.01, 248.74, false, false)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        local plate = QBCore.Functions.GetPlate(vehicle)
        TriggerEvent("vehiclekeys:client:SetOwner", plate)


        local locAlready = {}

        -- Iniciar o ciclo de 7 recolhas
        Citizen.CreateThread(function()
            for i = 1, 7 do
                local sucesso = gerarBlip(2, "Recolher Lixo ~g~[~w~E~g~]", locAlready)

                -- Se o jogador cancelou ou não conseguiu terminar, interrompe o loop
                if not sucesso then
                    break
                end

                -- Pequena pausa entre as recolhas
                Wait(8200)
            end

            -- Fim do serviço
            servico = false
            QBCore.Functions.Notify("Terminaste o serviço de recolha de lixo!", "success", 5000)
        end)
    end
end
