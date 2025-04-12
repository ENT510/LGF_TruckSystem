local VehicleTruck      = {}
local Peds              = {}
local Trailers          = {}

local Anim              = 'trevor_action'
local Dict              = 'anim@heists@fleeca_bank@scope_out@return_case'
local MessageSended     = false
local VehicleAttached   = false
local TrailerBlocked    = false
local isInAreatoDeposit = false
local MissionStarted    = false
local CoordsCached      = nil
local ConfirmedDialog   = false
local blipDecarga       = ''
local blipCaminhao      = ''
local blipCarga         = ''
local MarkerDecarga     = false
local loadload          = true
local dialogofinalizado = true
local pedInteracted     = false
local trailerHealth     = 1000

local function InstructButton()
    exports.LGF_Utility:interactionButton({
        Visible = true,
        Controls = {
            { key = "E", indexKey = 38, label = "Caminhão de depósito", description = "Pressione para guardar caminhão." },
        },
        Schema = {
            Styles = {
                Position  = "bottom",
                Animation = "slide-up",
            },
        },
    })
    if DoesBlipExist(blipCaminhao) then
        RemoveBlip(blipCaminhao)
    end
end

local function calculatePrice(data, distance)
    local distanceKM = distance
    local priceForDistance = data.pricexkm * distanceKM
    local roundedPrice = math.floor((priceForDistance + 50) / 100) * 100
    return roundedPrice
end

local dataForPrice = {}
local FinalDistance = nil
RegisterNUICallback("LGF_TruckSystem.startTask", function(data, resultCallback)
    dataForPrice = data
    local requiredLevel = data.requiredLevel
    local IncrementLevel = data.lvincrease

    if MissionStarted then
        Shared.Notification(LANG.CoreLang("alreadyStarted"), LANG.CoreLang("alreadyStartedDescription"), "center-left",
            "warning")
        resultCallback(false)
        return
    end

    if not (Functions.getPlayerData().CurrentLevel >= requiredLevel) then
        Shared.Notification(LANG.CoreLang("notRequired"), LANG.CoreLang("alreadyStartedDescription"), "center-left",
            "warning")
        return
    end

    local ZoneData = Config.TruckLocation[data.zoneName]

    if not ZoneData or not ZoneData.Tasks or not ZoneData.Tasks[data.indexTask] then
        resultCallback(false)
        return
    end

    local FormattedCoords = vector4(data.coords.x, data.coords.y, data.coords.z, data.coords.w)

    local SelectedTask = ZoneData.Tasks[data.indexTask]

    local vehicleSpawnPos = vector4(
        SelectedTask.DeliveryLocation.VehicleSpawnPosition.x,
        SelectedTask.DeliveryLocation.VehicleSpawnPosition.y,
        SelectedTask.DeliveryLocation.VehicleSpawnPosition.z,
        SelectedTask.DeliveryLocation.VehicleSpawnPosition.w
    )

    MissionStarted = true
    CoordsCached = vehicleSpawnPos

    local DataForTrigger = {
        task = SelectedTask.TaskName,
        vehicle = SelectedTask.VehicleModel,
        status = "Pending",
        driver = LGF.Core:GetName(),
    }

    TriggerServerEvent("LGF_TruckSystem.UpdateAllDelivery", DataForTrigger, data.zoneName, true)

    local createdVehicle = Functions.createVehicle(SelectedTask.VehicleHash, vehicleSpawnPos)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(createdVehicle))
    table.insert(VehicleTruck, createdVehicle)
    --  Rastreador do Caminhão
    blipCaminhao = Functions.BlipRastreador({
        truck = createdVehicle,
        type  = 477,
        color = 2,
        scale = 0.8,
        name  = LANG.CoreLang("caminhaoTracker"),
    })


    Config.AddVehicleKey(NetworkGetNetworkIdFromEntity(createdVehicle), GetVehicleNumberPlateText(createdVehicle))

    Shared.Notification(LANG.CoreLang("taskStarted"), LANG.CoreLang("taskStartedDescription"), "center-left", "info")


    Nui.ShowNui("openLogistic", {
        Visible = false,
        Tasks = Functions.getAllTasks(CurrentZone),
        PlayerData = Functions.getPlayerData(),
    })

    Wait(1000)

    Nui.ShowNui("openTaskLogistic", {
        Visible = true,
    })

    local BoxUnloadCoords = vector4(data.unloadCoords.x, data.unloadCoords.y, data.unloadCoords.z, data.unloadCoords.w)
    local BoxCoords = SelectedTask.DeliveryLocation.LoadVehicle
    local isInArea = false
    local isInAreatoUnload = false

    local trailer = Functions.createVehicle(SelectedTask.trailerHash,
        vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w))

    -- Add trailer health check thread
    CreateThread(function()
        while DoesEntityExist(trailer) and MissionStarted do
            local currentHealth = SetEntityHealth(trailer, trailerHealth.trailerHealth)

            -- Se a saúde atual for menor que a última saúde conhecida
            if currentHealth < trailerHealth then
                local damageAmount = trailerHealth - currentHealth
                local healthPercentage = math.floor((currentHealth / 1000) * 100)

                Shared.Notification(
                    LANG.CoreLang("trailerDamage"),
                    ("%s -%d | %s %d%%"):format(LANG.CoreLang("danocausado"), damageAmount, LANG.CoreLang("saude"),
                        healthPercentage),
                    "center-left",
                    "warning"
                )
            end

            trailerHealth = currentHealth

            if trailerHealth <= 0 then
                Shared.Notification(LANG.CoreLang("trailerDestroyed"), LANG.CoreLang("trailerDestroyedDescription"),
                    "center-left", "error")
                -- Clean up mission
                if DoesBlipExist(blipCarga) then
                    RemoveBlip(blipCarga)
                end
                if LoadingZone then
                    LoadingZone:remove()
                end
                --  Caso utilize sistema de Bombeiro é interessante deixar comentado essa linha
                --  um pouco de caos na cidade traz diversão
                -- if DoesEntityExist(trailer) then
                --     DeleteEntity(trailer)
                -- end

                --  Remove o veiculo do player para nao fazer nada que nao deveria de fazer  kkk
                if DoesEntityExist(createdVehicle) then
                    DeleteEntity(createdVehicle)
                end
                MissionStarted = false
                MarkerDecarga = false
                loadload = false
                MissionStarted = false
                TrailerBlocked = false
                MessageSended = false
                ConfirmedDialog = false
                Nui.ShowNui("openTaskLogistic", { Visible = false })
                break
            end
            Wait(500) -- Verifica a cada 100ms para ser mais responsivo
        end
    end)
    --[[] ]
    CreateThread(function()
        while DoesEntityExist(trailer) and MissionStarted do
            trailerHealth = SetEntityHealth(trailer, trailerHealth.trailerHealth)
            if trailerHealth <= 0 then
                Shared.Notification(LANG.CoreLang("trailerDestroyed"), LANG.CoreLang("trailerDestroyedDescription"),
                    "center-left", "error")
                -- Clean up mission
                if DoesBlipExist(blipCarga) then
                    RemoveBlip(blipCarga)
                end
                if LoadingZone then
                    LoadingZone:remove()
                end
                --  Caso utilize sistema de Bombeiro é interessante deixar comentado essa linha
                --  um pouco de caos na cidade traz diversão
                -- if DoesEntityExist(trailer) then
                --     DeleteEntity(trailer)
                -- end

                --  Remove o veiculo do player para nao fazer nada que nao deveria de fazer  kkk
                if DoesEntityExist(createdVehicle) then
                    DeleteEntity(createdVehicle)
                end
                MissionStarted = false
                MarkerDecarga = false
                loadload = false
                MissionStarted = false
                TrailerBlocked = false
                MessageSended = false
                ConfirmedDialog = false
                break
            end
            Wait(1000) -- Check every second
        end
    end)
    --[[]]

    --  Rastreador do Reboque
    blipCarga = Functions.BlipRastreador({
        truck = trailer,
        type  = 479,
        color = 1,
        scale = 0.8,
        name  = LANG.CoreLang("reboqueTracker"),
    })
    table.insert(Trailers, trailer)

    -- Adiciona o blip de carregamento
    -- blipDecarga = Functions.createBlip({
    --     pos = vector4(SelectedTask.DeliveryLocation.LoadCarga.x, SelectedTask.DeliveryLocation.LoadCarga.y, SelectedTask.DeliveryLocation.LoadCarga.z, SelectedTask.DeliveryLocation.LoadCarga.w),
    --     type = 478,
    --     scale = 0.5,
    --     color = 3,
    --     name = "Área de Carregamento de carga!",
    --     setWaypoint = true
    -- })

    -- Adicionar o Marker de carga
    CreateThread(function()
        loadload = true
        while MissionStarted and not MarkerDecarga and loadload do
            local playerPed = PlayerPedId()
            local veh = GetVehiclePedIsIn(playerPed, false)
            local coords = vector4(
                SelectedTask.DeliveryLocation.LoadCarga.x,
                SelectedTask.DeliveryLocation.LoadCarga.y,
                SelectedTask.DeliveryLocation.LoadCarga.z,
                SelectedTask.DeliveryLocation.LoadCarga.w
            )

            SetNewWaypoint(SelectedTask.DeliveryLocation.LoadCarga.x, SelectedTask.DeliveryLocation.LoadCarga.y)

            local distancia = #(GetEntityCoords(playerPed) - vector3(coords.x, coords.y, coords.z))
            local success, groundZ, normal = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z)
            if distancia <= 100.0 then
                local vehicleHeading = GetEntityHeading(veh)
                local trailerHeading = GetEntityHeading(trailer)

                if distancia <= 4.0 and
                    veh == createdVehicle and
                    math.abs(vehicleHeading - trailerHeading) <= 10 and
                    IsEntityAttachedToEntity(veh, trailer) then
                    local timer = 0
                    while timer < 3000 do                -- 3000ms = 3 segundos
                        DrawMarker(
                            30,                          -- Tipo do marker
                            coords.x, coords.y, groundZ, -- Posição
                            -coords.w, 0.0, 0.0,         -- Direção
                            90.0, 0.0, 0.0,              -- Rotação
                            4.0, 4.0, 15.0,              -- Escala
                            0, 255, 0, 100,              -- Cor verde
                            false, false, 2, false, nil, nil, false
                        )
                        timer = timer + 100
                        Wait(0)
                    end

                    MarkerDecarga = true
                else
                    DrawMarker(
                        30,                          -- Tipo do marker
                        coords.x, coords.y, groundZ, -- Posição
                        -coords.w, 0.0, 0.0,         -- Direção
                        90.0, 0.0, 0.0,              -- Rotação (usando heading da LoadCarga)
                        4.0, 4.0, 15.0,              -- Escala
                        255, 0, 0, 100,              -- Cor
                        false, false, 2, false, nil, nil, false
                    )
                end
            end
            Wait(0)
        end
        while MarkerDecarga do
            LoadingZone = lib.zones.box({
                coords = vector4(SelectedTask.DeliveryLocation.LoadCarga.x, SelectedTask.DeliveryLocation.LoadCarga.y,
                    SelectedTask.DeliveryLocation.LoadCarga.z, SelectedTask.DeliveryLocation.LoadCarga.w),
                size = vector3(10, 10, 10),
                rotation = GetEntityHeading(trailer) + 90,

                onEnter = function(self)
                    isInArea = true
                end,
                onExit = function(self)
                    isInArea = false
                    if DoesEntityExist(trailer) and DoesEntityExist(createdVehicle) then
                        local playerVehicle = GetVehiclePedIsUsing(LGF.Player:Ped())

                        if playerVehicle == createdVehicle then
                            if VehicleAttached then
                                if TrailerBlocked then
                                    LoadingZone:remove()
                                    loadload = false
                                    MarkerDecarga = false
                                else
                                    Shared.Notification(LANG.CoreLang("trailerNotBlocked"),
                                        LANG.CoreLang("trailerNotBlockedDescription"), "center-left", "error")
                                end
                            else
                                Shared.Notification(LANG.CoreLang("trailerNotAttached"),
                                    LANG.CoreLang("trailerNotAttachedDescription"), "center-left", "error")
                            end
                        end
                    end
                end,
                inside = function(self)
                    if MessageSended then return end

                    if DoesEntityExist(trailer) and DoesEntityExist(createdVehicle) then
                        if IsVehicleAttachedToTrailer(createdVehicle) then
                            SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })
                            MessageSended = true
                            VehicleAttached = true
                            Shared.Notification(LANG.CoreLang("trailerLoaded"), LANG.CoreLang("trailerLoadedDescription"),
                                "center-left", "success")
                        end
                    end
                end,
                debug = Config.DebugMode,
            })
            Wait(100000)
        end
    end)



    exports.ox_target:addLocalEntity(trailer, {
        {
            icon = 'fa-solid fa-bong',
            label = LANG.CoreLang("taskLoadTruck"),
            canInteract = function()
                return isInArea and VehicleAttached and not (GetVehiclePedIsIn(LGF.Player:Ped(), false) ~= 0)
            end,
            onSelect = function(data)
                Functions.StartPlayerAnim(Anim, Dict, nil)
                TaskTurnPedToFaceEntity(LGF.Player:Ped(), trailer, -1)
                exports["LGF_Utility"]:CreateProgressBar({
                    message = ("Carregando caminhão para tarefa"):format(SelectedTask.TaskName),
                    colorProgress = "rgba(54, 156, 129, 0.381)",
                    position = "bottom",
                    duration = 5000,
                    transition = "fade",
                    disableBind = false,
                    disableKeyBind = { 24, 32, 33, 34, 30, 31, 36, 21 },
                    onFinish = function()
                        if IsEntityPlayingAnim(LGF.Player:Ped(), Dict, Anim, 3) then
                            ClearPedTasks(LGF.Player:Ped())
                        end

                        SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })
                        TrailerBlocked = true

                        Shared.Notification(LANG.CoreLang("truckLocked"), LANG.CoreLang("truckLockedDescription"),
                            "center-left", "success")

                        exports.ox_target:removeLocalEntity(trailer)
                        
                        -- Verificar se a configuração do PED existe e usar um modelo padrão se não existir
                        local pedModel = "s_m_m_trucker_01" -- Modelo padrão de caminhoneiro
                        
                        if SelectedTask.DeliveryLocation.DeliveryPedConfig and SelectedTask.DeliveryLocation.DeliveryPedConfig.Pedmodel then
                            pedModel = SelectedTask.DeliveryLocation.DeliveryPedConfig.Pedmodel
                        else
                            print("Aviso: DeliveryPedConfig.Pedmodel não encontrado, usando modelo padrão")
                        end
                        
                        local success, model = LGF:RequestEntityModel(pedModel, 5000)
                        
                        --  remover o blip da area de carga
                        -- if DoesBlipExist(blipDecarga) then
                        --     RemoveBlip(blipDecarga)
                        -- end

                        if not success then return end

                        -- Substituir a criação estática do PED por uma versão que anda
                        PedCreated = CreatePed(0, model, FormattedCoords.x, FormattedCoords.y, FormattedCoords.z - 1, 0.0,
                            false, true)

                        -- Definir pontos de rota para o PED andar
                        local routePoints = {
                            vector3(FormattedCoords.x + 5.0, FormattedCoords.y, FormattedCoords.z - 1),
                            vector3(FormattedCoords.x, FormattedCoords.y + 5.0, FormattedCoords.z - 1),
                            vector3(FormattedCoords.x - 5.0, FormattedCoords.y, FormattedCoords.z - 1),
                            vector3(FormattedCoords.x, FormattedCoords.y - 5.0, FormattedCoords.z - 1),
                            vector3(FormattedCoords.x, FormattedCoords.y, FormattedCoords.z - 1)                 -- Voltar ao ponto inicial
                        }

                        -- Configurar o PED
                        table.insert(Peds, PedCreated)
                        SetEntityInvincible(PedCreated, true)
                        SetBlockingOfNonTemporaryEvents(PedCreated, true)

                        -- Thread para controlar o movimento do PED
                        CreateThread(function()
                            local currentPoint = 1
                            local isInScenario = false

                            while DoesEntityExist(PedCreated) and MissionStarted do
                                -- Se o jogador estiver próximo, parar de andar e olhar para ele
                                local playerCoords = GetEntityCoords(PlayerPedId())
                                local pedCoords = GetEntityCoords(PedCreated)
                                local distance = #(playerCoords - pedCoords)

                                if distance < 2.8 and dialogofinalizado then
                                    -- Apenas inicia o cenário se ainda não estiver nele
                                    if not isInScenario then
                                        ClearPedTasks(PedCreated)
                                        TaskTurnPedToFaceEntity(PedCreated, PlayerPedId(), -1)
                                        Wait(500) -- Pequena pausa para virar antes de iniciar o cenário
                                        TaskStartScenarioInPlace(PedCreated, SelectedTask.DeliveryLocation.DeliveryPedConfig.PedScenario, 0, true)
                                        isInScenario = true
                                        pedInteracted = true
                                    end
                                else
                                    -- Se o jogador se afastou e não finalizou o diálogo, voltar a andar
                                    if (distance > 2.8 and not pedInteracted) or (distance > 2.8 and dialogofinalizado) then
                                        if isInScenario then
                                            ClearPedTasks(PedCreated)
                                            isInScenario = false
                                        end
                                        
                                        -- Avançar para o próximo ponto da rota
                                        if currentPoint > #routePoints then
                                            currentPoint = 1 -- Reiniciar a rota
                                        end
                                        
                                        local targetPoint = routePoints[currentPoint]
                                        TaskGoStraightToCoord(PedCreated, targetPoint.x, targetPoint.y, targetPoint.z, 1.0, -1, 0.0, 0.0)
                                        currentPoint = currentPoint + 1
                                    end
                                end
                                
                                -- Se o diálogo foi finalizado e o jogador se afastou, resetar para permitir nova interação
                                if distance > 5.0 and not dialogofinalizado then
                                    dialogofinalizado = true
                                    pedInteracted = false
                                    isInScenario = false
                                    ClearPedTasks(PedCreated)
                                    
                                    -- Voltar a andar
                                    local targetPoint = routePoints[currentPoint]
                                    TaskGoStraightToCoord(PedCreated, targetPoint.x, targetPoint.y, targetPoint.z, 1.0, -1, 0.0, 0.0)
                                    currentPoint = currentPoint + 1
                                    if currentPoint > #routePoints then
                                        currentPoint = 1
                                    end
                                end
                                
                                Wait(2000)
                            end
                        end)

                        -- Remover a linha que congela a posição do PED
                        -- FreezeEntityPosition(PedCreated, true) -- Esta linha deve ser removida

                        -- Remover a linha que inicia o cenário imediatamente
                        -- TaskStartScenarioInPlace(PedCreated, "WORLD_HUMAN_CLIPBOARD", 0, true) -- Esta linha deve ser removida

                        if not PedCreated or PedCreated == 0 then return nil end

                        --  Blip do informante
                        local pedBlip = Functions.createBlip({
                            pos = FormattedCoords,
                            type = 477,
                            scale = 0.8,
                            color = 3,
                            name = LANG.CoreLang("taskHeadToDelivery"),
                            setWaypoint = true
                        })

                        FinalDistance = #(BoxCoords - FormattedCoords)

                        exports.ox_target:addLocalEntity(PedCreated, {
                            {
                                icon = 'fa-solid fa-bong',
                                label = 'Pedir Informações',
                                onSelect = function(dataox)
                                    --aqui fica os dialogos
                                    dialogofinalizado = false
                                    local deliveryNPC = Shared.getRandomDeliveryNPC(SelectedTask.IndexTask,
                                        Functions.GetHashKeyStreet(
                                            BoxUnloadCoords))

                                    Nui.ShowNui("openDialog", {
                                        Visible = true,
                                        npcData = {
                                            npcName = deliveryNPC.name,
                                            dialogue = string.format("Olá, %s! %s", LGF.Core:GetName(),
                                                deliveryNPC.description),
                                            zoneName = Functions.GetHashKeyStreet(BoxUnloadCoords)
                                        },
                                    })

                                    Functions.startCamera(dataox.entity)

                                    while not ConfirmedDialog do Wait(100) end

                                    Functions.destroyCamera()

                                    Shared.Notification(LANG.CoreLang("confirmedDelivery"),
                                        LANG.CoreLang("confirmedDeliveryDescription"), "center-left", "success")

                                    SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })

                                    local unLoadingZone = lib.zones.box({
                                        coords = BoxUnloadCoords,
                                        size = vector3(20, 20, 20),
                                        rotation = 110,
                                        onEnter = function(self)
                                            isInAreatoUnload = true
                                        end,
                                        onExit = function(self)
                                            isInAreatoUnload = false
                                        end,
                                        debug = Config.DebugMode,
                                    })


                                    FinalDistance = FinalDistance + #(FormattedCoords - BoxUnloadCoords)

                                    --  Apagar blip do informante
                                    if DoesBlipExist(pedBlip) then
                                        RemoveBlip(pedBlip)
                                        MarkerDecarga = false
                                        loadload = true
                                    end

                                    exports.ox_target:removeLocalEntity(PedCreated)

                                    --  Entrega da Carga
                                    local unloadBlip = Functions.createBlip({
                                        pos = BoxUnloadCoords,
                                        type = 479,
                                        scale = 0.8,
                                        color = 3,
                                        name = LANG.CoreLang("alreadyStarted"),
                                        setWaypoint = true
                                    })

                                    -- Adicionar o Markerde descarga
                                    CreateThread(function()
                                        --MarkerDecarga = false  -- Reset the marker state
                                        --loadload = true
                                        local finishgame = false
                                        while not MarkerDecarga and loadload do
                                            local playerPed = PlayerPedId()
                                            local veh = GetVehiclePedIsIn(playerPed, false)
                                            local coords = vector4(
                                                BoxUnloadCoords.x,
                                                BoxUnloadCoords.y,
                                                BoxUnloadCoords.z,
                                                BoxUnloadCoords.w
                                            )

                                            local distancia = #(GetEntityCoords(playerPed) - vector3(coords.x, coords.y, coords.z))
                                            local success, groundZ, normal = GetGroundZAndNormalFor_3dCoord(coords.x,
                                                coords.y, coords.z)


                                            if distancia <= 100.0 then
                                                local vehicleHeading = GetEntityHeading(veh)
                                                local trailerHeading = GetEntityHeading(trailer)

                                                if distancia <= 4.0 and
                                                    veh == createdVehicle and
                                                    math.abs(vehicleHeading - trailerHeading) <= 10 and
                                                    IsEntityAttachedToEntity(veh, trailer) then
                                                    local timer = 0
                                                    while timer < 3000 do                    -- 3000ms = 3 segundos
                                                        DrawMarker(
                                                            30,                              -- Tipo do marker
                                                            coords.x, coords.y, groundZ,     -- Posição
                                                            -coords.w, 0.0, 0.0,             -- Direção
                                                            90.0, 0.0, 0.0,                  -- Rotação
                                                            4.0, 4.0, 15.0,                  -- Escala
                                                            0, 255, 0, 100,                  -- Cor verde
                                                            false, false, 2, false, nil, nil, false
                                                        )
                                                        timer = timer + 100
                                                        Wait(0)
                                                    end
                                                    MarkerDecarga = true
                                                    loadload = false
                                                    finishgame = true
                                                else
                                                    DrawMarker(
                                                        30,                          -- Tipo do marker
                                                        coords.x, coords.y, groundZ, -- Posição
                                                        -coords.w, 0.0, 0.0,         -- Direção
                                                        90.0, 0.0, 0.0,              -- Rotação (usando heading da LoadCarga)
                                                        4.0, 4.0, 15.0,              -- Escala
                                                        255, 0, 0, 100,              -- Cor
                                                        false, false, 2, false, nil, nil, false
                                                    )
                                                end
                                            end
                                            Wait(0)
                                        end
                                        if finishgame then
                                            exports.ox_target:addLocalEntity(trailer, {
                                                {
                                                    icon = 'fa-solid fa-bong',
                                                    label = LANG.CoreLang("taskUnloadTruck"),
                                                    canInteract = function()
                                                        return isInAreatoUnload
                                                    end,
                                                    onSelect = function()
                                                        if DoesEntityExist(trailer) and DoesEntityExist(createdVehicle) then
                                                            DetachVehicleFromTrailer(createdVehicle)
                                                            Shared.Notification(LANG.CoreLang("trailerUnloaded"),
                                                                LANG.CoreLang("trailerUnloadedDescription"),
                                                                "center-left",
                                                                "success")
                                                            VehicleAttached = false
                                                            SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })
                                                            exports.ox_target:removeLocalEntity(trailer)

                                                            --  remover blip de entrega da carga
                                                            if DoesBlipExist(unloadBlip) then
                                                                RemoveBlip(unloadBlip)
                                                            end

                                                            --  remover blip de carga
                                                            if DoesBlipExist(blipCarga) then
                                                                RemoveBlip(blipCarga)
                                                            end
                                                        end


                                                        unLoadingZone:remove()



                                                        local depositBlip = Functions.createBlip({
                                                            pos = vehicleSpawnPos,
                                                            type = 473,
                                                            scale = 0.8,
                                                            color = 3,
                                                            name = LANG.CoreLang("garagetransportadora"),
                                                            setWaypoint = true
                                                        })

                                                        DepositZone = lib.zones.box({
                                                            coords = vehicleSpawnPos,
                                                            size = vector3(20, 20, 20),
                                                            rotation = 110,
                                                            onEnter = function(self)
                                                                isInAreatoDeposit = true

                                                                InstructButton()

                                                                if DoesBlipExist(depositBlip) then
                                                                    RemoveBlip(depositBlip)
                                                                end
                                                            end,
                                                            onExit = function(self)
                                                                isInAreatoDeposit = false
                                                                if exports.LGF_Utility:getStateInteraction() then
                                                                    exports.LGF_Utility:closeInteraction()
                                                                end
                                                            end,
                                                            inside = function(self)
                                                                if DoesEntityExist(trailer) and DoesEntityExist(createdVehicle) then
                                                                    if GetVehiclePedIsUsing(LGF.Player:Ped()) == createdVehicle then
                                                                        if IsControlJustReleased(0, 38) then
                                                                            if exports.LGF_Utility:getStateInteraction() then
                                                                                exports.LGF_Utility:closeInteraction()
                                                                            end
                                                                            TaskLeaveVehicle(LGF.Player:Ped(),
                                                                                createdVehicle, 1)
                                                                            NetworkFadeOutEntity(createdVehicle, true,
                                                                                false)
                                                                            Wait(1200)

                                                                            DeleteEntity(trailer)
                                                                            DeleteEntity(createdVehicle)
                                                                            DeleteEntity(PedCreated)

                                                                            for i, tra in ipairs(VehicleTruck) do
                                                                                if tra == trailer then
                                                                                    table.remove(VehicleTruck, i)
                                                                                    break
                                                                                end
                                                                            end

                                                                            DepositZone:remove()

                                                                            for i, vehicle in ipairs(Trailers) do
                                                                                if vehicle == createdVehicle then
                                                                                    table.remove(Trailers, i)
                                                                                    break
                                                                                end
                                                                            end


                                                                            for i, peds in ipairs(Peds) do
                                                                                if peds == PedCreated then
                                                                                    table.remove(Peds, i)
                                                                                    break
                                                                                end
                                                                            end


                                                                            SendNUIMessage({ action =
                                                                            "LGF_Truck.UpdateTask", data = true })
                                                                            Wait(1500)
                                                                            Nui.ShowNui("openTaskLogistic",
                                                                                { Visible = false })
                                                                            Shared.Notification(
                                                                                LANG.CoreLang("vehicleDeposited"),
                                                                                LANG.CoreLang(
                                                                                "vehicleDepositedDescription"),
                                                                                "center-left", "success")
                                                                            MissionStarted = false
                                                                            TrailerBlocked = false
                                                                            MessageSended = false
                                                                            ConfirmedDialog = false
                                                                            local descontos = 1000 - trailerHealth
                                                                            FinalDistance = FinalDistance +
                                                                                #(BoxUnloadCoords - BoxCoords) +
                                                                                #(BoxCoords - vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w))
                                                                            local finalPrice = calculatePrice(
                                                                                dataForPrice,
                                                                                LGF.math:round(FinalDistance, 0) /
                                                                                (1000 + descontos))

                                                                            TriggerServerEvent(
                                                                            "LGF_TruckSystem.AddPlayerMoney", finalPrice,
                                                                                GetCurrentResourceName(),
                                                                                LGF.Player:Index())
                                                                            TriggerServerEvent(
                                                                            "LGF_TruckSystem.UpdatePlayerLevel",
                                                                                IncrementLevel, GetCurrentResourceName(),
                                                                                LGF.Player:Index())
                                                                            Config.RemoveVehicleKey(
                                                                            NetworkGetNetworkIdFromEntity(createdVehicle),
                                                                                GetVehicleNumberPlateText(createdVehicle))
                                                                            exports["cw-rep"]:updateSkill("trucker", 1) --  skill

                                                                            local DataForTrigger2 = {
                                                                                task = SelectedTask.TaskName,
                                                                                vehicle = SelectedTask.VehicleModel,
                                                                                status = "Completed",
                                                                                driver = LGF.Core:GetName(),
                                                                            }
                                                                            TriggerServerEvent(
                                                                                "LGF_TruckSystem.UpdateAllDelivery",
                                                                                DataForTrigger2,
                                                                                dataForPrice.zoneName, false
                                                                            )
                                                                            CoordsCached = nil
                                                                            FinalDistance = nil
                                                                        end
                                                                    end
                                                                end
                                                            end,
                                                            debug = Config.DebugMode,
                                                        })
                                                    end
                                                }
                                            })
                                        end
                                    end)
                                end
                            }
                        })
                    end,
                })
            end
        }
    })

    resultCallback("ok")
end)


RegisterNUICallback("LGF_TruckSystem.ConfirmDialogDelivery", function(data, resultCallback)
    ConfirmedDialog = data.state
    Nui.ShowNui("openDialog", {
        Visible = false,
        npcData = {}
    })
    resultCallback(true)
end)

RegisterNUICallback("LGF_TruckSystem.GetInformationTasks", function(body, resultCallback)
    resultCallback({
        { Description = LANG.CoreLang("taskLoadTruck") },
        { Description = LANG.CoreLang("taskBlockTruck") },
        { Description = LANG.CoreLang("taskHeadToDelivery") },
        { Description = LANG.CoreLang("taskUnloadTruck") },
        { Description = LANG.CoreLang("taskReturnPickup") },
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, vehicle in ipairs(VehicleTruck) do
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end
        for _, ped in ipairs(Peds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        for _, trailer in ipairs(Trailers) do
            if DoesEntityExist(trailer) then
                DeleteEntity(trailer)
            end
        end

        if IsEntityPlayingAnim(LGF.Player:Ped(), Dict, Anim, 3) then
            ClearPedTasks(LGF.Player:Ped())
        end
        if MissionStarted then
            SetEntityCoords(LGF.Player:Ped(), CoordsCached?.x, CoordsCached?.y, CoordsCached?.z, false, true, true)
        end
        if exports.LGF_Utility:getStateInteraction() then
            exports.LGF_Utility:closeInteraction()
        end
    end
end)


RegisterNUICallback("LGF_TruckSystem.getTasksListByZone", function(body, resultCallback)
    local TaskListZone = LGF:TriggerServerCallback("LGF_TruckSystem.getTasksListByZone", CurrentZone)
    resultCallback(TaskListZone)
end)



RegisterNUICallback("LGF_TruckSystem.getRewardItems", function(body, resultCallback)
    local TableToSend = {}
    local addedItemHashes = {}


    for level, reward in pairs(Config.RewardLevel) do
        local ItemHash = reward.ItemHash
        local quantity = reward.Quantity
        local itemName = reward.ItemLabel
        local image

        local ItemRedemed = LGF:TriggerServerCallback("LGF_TruckSystem.isRewardRedeemed", level) or false

        if not addedItemHashes[ItemHash] then
            if reward.Props == "item" or reward.Props == "weapon" then
                image = reward.image or ("%s/%s.png"):format(Config.ImageFolderInventory, ItemHash)
            elseif reward.Props == "vehicle" then
                image = reward.image or ("https://docs.fivem.net/vehicles/%s.webp"):format(ItemHash)
            else
                image = nil
            end

            TableToSend[#TableToSend + 1] = {
                level = level,
                itemName = itemName,
                quantity = quantity,
                image = image,
                itemHash = ItemHash,
                props = reward.Props,
                itemLabel = reward.ItemLabel,
                redeemed = ItemRedemed
            }

            addedItemHashes[ItemHash] = true
        end
    end

    table.sort(TableToSend, function(a, b)
        return a.level < b.level
    end)

    resultCallback(TableToSend)
end)



RegisterNUICallback("LGF_TruckSystem.rewardRedeemed", function(body, resultCallback)
    local Level = body.Level
    local Type = body.Type
    local RewardItem = body.RewardItem
    local Quantity = body.Quantity
    local SpawnLocation = body.SpawnLocation
    local coords = vec3(LGF.Player:Coords().x + 3.0, LGF.Player:Coords().y, LGF.Player:Coords().z)

    if Type == "vehicle" then
        local createdVehicle = Functions.createVehicle(RewardItem, coords)
        local VehicleProps = lib.getVehicleProperties(createdVehicle)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(createdVehicle))
        TriggerServerEvent("LGF_TruckSystem.UpdateRewardRedeemed", Level, RewardItem, Type, Quantity, VehicleProps,
            SpawnLocation)
        Nui.ShowNui("openLogistic", {
            Visible = false,
            Tasks = Functions.getAllTasks(CurrentZone),
            PlayerData = Functions.getPlayerData(),
        })
        SendNUIMessage({ action = "updateParent" })
        if SpawnLocation == "here" then
            TaskWarpPedIntoVehicle(LGF.Player:Ped(), createdVehicle, -1)
        elseif SpawnLocation == "garage" then
            SetEntityVisible(createdVehicle, false, false)
            SetTimeout(2000, function()
                if DoesEntityExist(createdVehicle) then
                    DeleteEntity(createdVehicle)
                end
            end)
        end
    else
        TriggerServerEvent("LGF_TruckSystem.UpdateRewardRedeemed", Level, RewardItem, Type, Quantity)
    end

    resultCallback(true)
end)
