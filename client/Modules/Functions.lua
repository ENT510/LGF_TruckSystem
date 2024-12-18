Functions = {}
local Cam

function calc_dist(vec1, vec2)
    local Coords = GetDistanceBetweenCoords(vec1.x, vec1.y, vec1.z, vec2.x, vec2.y, vec2.z, false)
    return Coords
end

function Functions.getAllTasks(zoneName)
    local TableToSend = {}
    if not Config.TruckLocation[zoneName] then return TableToSend end

    local zoneData = Config.TruckLocation[zoneName]

    for _, task in ipairs(zoneData.Tasks) do
        local deliveryPoints = task.DeliveryLocation.DeliveryPoints
        local randomDeliveryPoint = deliveryPoints[math.random(#deliveryPoints)]
        local loadVehiclePosition = task.DeliveryLocation.LoadVehicle
        local unloadPositions = task.DeliveryLocation.UnloadVehicle
        local randomUnloadPosition = unloadPositions[math.random(#unloadPositions)]
        local distanceInMetersToDelivery = #(loadVehiclePosition - randomDeliveryPoint)
        local distanceInMetersToUnload = #(randomDeliveryPoint - randomUnloadPosition)
        local distanceBackToLoad = #(randomUnloadPosition - loadVehiclePosition)
        local totalDistanceInKilometers = (distanceInMetersToDelivery + distanceInMetersToUnload + distanceBackToLoad) /
        1000
        local roundedDistance = LGF.math:round(totalDistanceInKilometers, 1)
        local stringDistance = ("%s KM"):format(roundedDistance)

        TableToSend[#TableToSend + 1] = {
            id             = task.IndexTask,
            requiredLvl    = task.RequiredLevel,
            task           = task.TaskName,
            vehicle        = task.VehicleModel,
            price          = task.PriceForKilometer,
            distance       = stringDistance,
            lvincrease     = task.LevelIncrease,
            img            = ("https://docs.fivem.net/vehicles/%s.webp"):format(task.VehicleHash),
            zoneName       = zoneName,
            coordsDelivery = randomDeliveryPoint,
            unloadCoords   = randomUnloadPosition
        }
    end

    return TableToSend
end

function Functions.getPlayerData()
    local PlayerData = {}
    local Level = LGF:TriggerServerCallback("LGF_TruckSystem.getPlayerLevel")
    PlayerData.CurrentLevel = Level
    PlayerData.PlayerName = LGF.Core:GetName()
    PlayerData.Avatar = "https://avatars.githubusercontent.com/u/145626625?v=4"
    return PlayerData
end

function Functions.createBlip(data)
    local blip = AddBlipForCoord(data.pos)
    SetBlipSprite(blip, data.type)
    SetBlipDisplay(blip, 6)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)
    if data.setWaypoint then
        SetNewWaypoint(data.pos.x, data.pos.y)
    end

    return blip
end

function Functions.createVehicle(vehicleModel, coords)
    local createdVehicle = LGF:CreateEntityVehicle({
        model = vehicleModel,
        position = coords,
        isNetworked = false,
        seatPed = false,
        seat = -1,
        freeze = false,
        onCreated = function(vehicle)
        end
    })

    return createdVehicle
end

function Functions.StartPlayerAnim(anim, dict, prop)
    local dict = lib.requestAnimDict(dict)

    local Ped = LGF.Player:Ped()
    local PlayerCoords = GetEntityCoords(Ped)
    TaskPlayAnim(Ped, dict, anim, 2.0, 2.0, -1, 51, 0, false, false, false)
    if prop == nil then return end
    local model = LGF:RequestEntityModel(prop, 3000)
    local props = CreateObject(model, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(props, Ped, GetPedBoneIndex(Ped, 28422), 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false,
        true, 1, true)
    return props
end

function Functions.GetHashKeyStreet(coords)
    local pos = coords
    local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
    local streetName1 = GetStreetNameFromHashKey(street1)
    local streetName2 = GetStreetNameFromHashKey(street2)
    return streetName1 .. (streetName2 ~= "" and streetName2 or "")
end

function Functions.startCamera(entity)
    local coords = GetOffsetFromEntityInWorldCoords(entity, 0, 1.2, 0)
    Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(Cam, true)
    RenderScriptCams(true, true, 1750, 1, 0)
    SetCamCoord(Cam, coords.x, coords.y, coords.z + 0.65)
    SetCamFov(Cam, 38.0)
    SetCamRot(Cam, 0.0, 0.0, GetEntityHeading(entity) + 180)
    PointCamAtPedBone(Cam, entity, 31086, 0.0, 0.0, 0.03, 1)

    local coords = GetCamCoord(Cam)
    TaskLookAtCoord(entity, coords.x, coords.y, coords.z, -1, 1, 1)
    SetCamUseShallowDofMode(Cam, true)
    SetCamNearDof(Cam, 0.5)
    SetCamFarDof(Cam, 12.0)
    SetCamDofStrength(Cam, 1.0)
    SetCamDofMaxNearInFocusDistance(Cam, 1.0)
    CreateThread(function()
        repeat
            SetUseHiDof()
            Wait(0)
        until not DoesCamExist(Cam)
    end)
end

function Functions.getCamHandler()
    return Cam
end

function Functions.destroyCamera()
    if Functions.getCamHandler() then
        RenderScriptCams(false, true, 1250, 1, 0)
        DestroyCam(Cam, false)
        Cam = nil
    end
end
local env = exports.LGF_Module:Enviroment()

local value = env:requireModule("client/Modules/Locations")
print(json.encode(value))
