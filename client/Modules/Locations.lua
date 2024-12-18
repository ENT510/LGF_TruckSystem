PedMeta = {}
PedMeta.__index = PedMeta

function PedMeta:new(model, position, scenario, blipInfo)
    local ped = {}
    setmetatable(ped, self)
    ped.model = model
    ped.position = position
    ped.scenario = scenario
    ped.pedHandle = nil
    ped.blipHandle = nil
    ped.blipInfo = blipInfo
    return ped
end

function PedMeta:spawn()
    local success, model = LGF:RequestEntityModel(self.model, 5000)
    if not success then return end

    self.pedHandle = CreatePed(0, self.model, self.position.x, self.position.y, self.position.z - 1, self.position.w,
        false, true)

    FreezeEntityPosition(self.pedHandle, true)
    SetBlockingOfNonTemporaryEvents(self.pedHandle, true)
    SetEntityInvincible(self.pedHandle, true)

    if not self.pedHandle or self.pedHandle == 0 then return nil end

    if self.scenario and self.scenario ~= "" then
        TaskStartScenarioInPlace(self.pedHandle, self.scenario, 0, true)
    end


    return self.pedHandle
end

function PedMeta:delete()
    if self.pedHandle then
        DeleteEntity(self.pedHandle)
        self.pedHandle = nil
    end
end




for zoneName, zoneData in pairs(Config.TruckLocation) do
    local pedData = zoneData.DataPed

    if pedData and pedData.PedModel and pedData.PedPosition then
        local ped = PedMeta:new(
            pedData.PedModel,
            pedData.PedPosition,
            pedData.PedScenario
        )

        local pedBlip = Functions.createBlip({
            pos = pedData.PedPosition,
            type = 477,
            scale = 0.8,
            color = 3,
            name = "Start Truck Delivery",
            setWaypoint = false
        })

        local point = lib.points.new({
            coords = vector3(pedData.PedPosition.x, pedData.PedPosition.y, pedData.PedPosition.z),
            distance = 20.0,
        })

        function point:onEnter()
            if not ped.pedHandle then
                self.ped = ped:spawn()
                if self.ped then
                    exports.ox_target:addLocalEntity(self.ped, {
                        {
                            icon = 'fa-solid fa-bong',
                            label = LANG.CoreLang("openLogistic"),
                            onSelect = function(data)
                                local playerCoords = GetEntityCoords(PlayerPedId())


                                if #(playerCoords - GetEntityCoords(self.ped)) > 3.0 then
                                    return
                                end

                                local isNew = LGF:TriggerServerCallback("LGF_TruckSystem.isNewPlayer") 

                                if isNew then
                                    TriggerServerEvent("LGF_TruckSystem.CreateAvatarAndLevel", GetCurrentResourceName())
                                end

                                Nui.ShowNui("openLogistic", {
                                    Visible = true,
                                    Tasks = Functions.getAllTasks(zoneName),
                                    PlayerData = Functions.getPlayerData(),
                                })
                                CurrentZone = zoneName
                            end,
                        }
                    })
                end
            end
        end

        function point:onExit()
            ped:delete()
        end
    end
end



return PedMeta
