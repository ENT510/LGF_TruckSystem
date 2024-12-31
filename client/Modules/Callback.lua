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


local function InstructButton()
    exports.LGF_Utility:interactionButton({
        Visible = true,
        Controls = {
            { key = "E", indexKey = 38, label = "Deposit Truck", description = "Press To deposit Truck." },
        },
        Schema = {
            Styles = {
                Position  = "bottom",
                Animation = "slide-up",
            },
        },
    })
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
        Shared.Notification(LANG.CoreLang("alreadyStarted"), LANG.CoreLang("alreadyStartedDescription"), "top", "warning")
        resultCallback(false)
        return
    end

    if not (Functions.getPlayerData().CurrentLevel >= requiredLevel) then
        Shared.Notification(LANG.CoreLang("levelRequired"), 
            LANG.CoreLang("levelRequiredDescription"):format(requiredLevel), 
            "top", 
            "warning"
        )
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
    table.insert(VehicleTruck, createdVehicle)

    Config.AddVehicleKey(NetworkGetNetworkIdFromEntity(createdVehicle),GetVehicleNumberPlateText(createdVehicle))

    Shared.Notification(LANG.CoreLang("taskStarted"), LANG.CoreLang("taskStartedDescription"), "top-right", "info")


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

    local trailer = Functions.createVehicle("tanker", vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w))
    table.insert(Trailers, trailer)



    LoadingZone = lib.zones.box({
        coords = vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w),
        size = vector3(20, 7, 3),
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
                        else
                            Shared.Notification(LANG.CoreLang("trailerNotBlocked"),
                                LANG.CoreLang("trailerNotBlockedDescription"), "top-right", "error")
                        end
                    else
                        Shared.Notification(LANG.CoreLang("trailerNotAttached"),
                            LANG.CoreLang("trailerNotAttachedDescription"), "top-right", "error")
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
                        "top-right", "success")
                end
            end
        end,
        debug = true,
    })

    exports.ox_target:addLocalEntity(trailer, {
        {
            icon = 'fa-solid fa-bong',
            label = LANG.CoreLang("taskLoadTruck"),
            canInteract = function()
                return isInArea and VehicleAttached and not (GetVehiclePedIsIn(LGF.Player:Ped(), false ) ~= 0)
            end,
            onSelect = function(data)
                Functions.StartPlayerAnim(Anim, Dict, nil)
                TaskTurnPedToFaceEntity(LGF.Player:Ped(),trailer,-1)
                exports["LGF_Utility"]:CreateProgressBar({
                    message = ("Loading Truck for task"):format(SelectedTask.TaskName),
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
                            "top-right", "success")

                        exports.ox_target:removeLocalEntity(trailer)
                        local success, model = LGF:RequestEntityModel("s_m_m_trucker_01", 5000)

                        if not success then return end

                        PedCreated = CreatePed(0, model, FormattedCoords.x, FormattedCoords.y, FormattedCoords.z - 1, 0.0,
                            false, true)



                        table.insert(Peds, PedCreated)

                        FreezeEntityPosition(PedCreated, true)
                        SetBlockingOfNonTemporaryEvents(PedCreated, true)
                        SetEntityInvincible(PedCreated, true)

                        if not PedCreated or PedCreated == 0 then return nil end

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
                                label = 'Talk With Peppe',
                                onSelect = function(dataox)
                                    local deliveryNPC = Shared.getRandomDeliveryNPC(Functions.GetHashKeyStreet(
                                        BoxUnloadCoords))

                                    Nui.ShowNui("openDialog", {
                                        Visible = true,
                                        npcData = {
                                            npcName = deliveryNPC.name,
                                            dialogue = string.format("Hello, %s! %s", LGF.Core:GetName(),
                                                deliveryNPC.description),
                                            zoneName = Functions.GetHashKeyStreet(BoxUnloadCoords)
                                        },
                                    })

                                    Functions.startCamera(dataox.entity)

                                    while not ConfirmedDialog do Wait(100) end

                                    Functions.destroyCamera()

                                    Shared.Notification(LANG.CoreLang("confirmedDelivery"),
                                        LANG.CoreLang("confirmedDeliveryDescription"), "top", "success")

                                    SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })

                                    local unLoadingZone = lib.zones.box({
                                        coords = BoxUnloadCoords,
                                        size = vector3(10, 5, 3),
                                        rotation = 110,
                                        onEnter = function(self)
                                            isInAreatoUnload = true
                                        end,
                                        onExit = function(self)
                                            isInAreatoUnload = false
                                        end,
                                        debug = true,
                                    })


                                    FinalDistance = FinalDistance + #(FormattedCoords - BoxUnloadCoords)


                                    if DoesBlipExist(pedBlip) then
                                        RemoveBlip(pedBlip)
                                    end

                                    exports.ox_target:removeLocalEntity(PedCreated)

                                    local unloadBlip = Functions.createBlip({
                                        pos = BoxUnloadCoords,
                                        type = 477,
                                        scale = 0.8,
                                        color = 3,
                                        name = LANG.CoreLang("taskHeadToLoadVehicle"),
                                        setWaypoint = true
                                    })

                                    exports.ox_target:addLocalEntity(trailer, {
                                        {
                                            icon = 'fa-solid fa-bong',
                                            label = 'Unload Truck',
                                            canInteract = function()
                                                return isInAreatoUnload
                                            end,
                                            onSelect = function()
                                                if DoesEntityExist(trailer) and DoesEntityExist(createdVehicle) then
                                                    DetachVehicleFromTrailer(createdVehicle)
                                                    Shared.Notification(LANG.CoreLang("trailerUnloaded"),
                                                        LANG.CoreLang("trailerUnloadedDescription"), "top-right",
                                                        "success")
                                                    VehicleAttached = false
                                                    SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })
                                                    exports.ox_target:removeLocalEntity(trailer)
                                                    if DoesBlipExist(unloadBlip) then
                                                        RemoveBlip(unloadBlip)
                                                    end
                                                end


                                                unLoadingZone:remove()


                                                local depositBlip = Functions.createBlip({
                                                    pos = vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w),
                                                    type = 477,
                                                    scale = 0.8,
                                                    color = 3,
                                                    name = "ritorna al punto deposito",
                                                    setWaypoint = true
                                                })

                                                DepositZone = lib.zones.box({
                                                    coords = vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w),
                                                    size = vector3(10, 5, 3),
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
                                                                    TaskLeaveVehicle(LGF.Player:Ped(), createdVehicle, 1)
                                                                    NetworkFadeOutEntity(createdVehicle, true, false)
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


                                                                    SendNUIMessage({ action = "LGF_Truck.UpdateTask", data = true })
                                                                    Wait(1500)
                                                                    Nui.ShowNui("openTaskLogistic", { Visible = false })
                                                                    Shared.Notification(
                                                                        LANG.CoreLang("vehicleDeposited"),
                                                                        LANG.CoreLang("vehicleDepositedDescription"),
                                                                        "top-right", "success")
                                                                    MissionStarted = false
                                                                    TrailerBlocked = false
                                                                    MessageSended = false
                                                                    ConfirmedDialog = false
                                                                    FinalDistance = FinalDistance +
                                                                        #(BoxUnloadCoords - BoxCoords) +
                                                                        #(BoxCoords - vector4(BoxCoords.x, BoxCoords.y, BoxCoords.z, BoxCoords.w))
                                                                    local finalPrice = calculatePrice(dataForPrice,
                                                                        LGF.math:round(FinalDistance, 0) / 1000)

                                                                    TriggerServerEvent("LGF_TruckSystem.AddPlayerMoney", finalPrice, GetCurrentResourceName(), LGF.Player:Index())
                                                                    TriggerServerEvent( "LGF_TruckSystem.UpdatePlayerLevel", IncrementLevel,GetCurrentResourceName(), LGF.Player:Index())
                                                                    Config.RemoveVehicleKey(NetworkGetNetworkIdFromEntity(createdVehicle),GetVehicleNumberPlateText(createdVehicle))


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
                                                    debug = true,
                                                })
                                            end
                                        }
                                    })
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
        TriggerServerEvent("LGF_TruckSystem.UpdateRewardRedeemed", Level, RewardItem, Type, Quantity, VehicleProps, SpawnLocation)
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
