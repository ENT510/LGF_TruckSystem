RegisterNetEvent("LGF_TruckSystem.CreateAvatarAndLevel", function(invoker)
    local src = source
    local Player = LGF.Core:GetIdentifier(src)
    local Level = 0

    if invoker ~= "LGF_TruckSystem" then
        print(("Unauthorized attempt to trigger event from another invoker resource "))
        return
    end

    if src == 0 or not GetPlayerName(src) then
        print(("Invalid Source detected to trigger an event"))
        return
    end

    if not Player then return end
    MySQL.insert.await("INSERT INTO lgf_logistic (Player, CurrentLevel, reward_redeemed) VALUES (?, ?, ? )",
        { Player, Level, json.encode({}) })
end)

RegisterNetEvent("LGF_TruckSystem.AddPlayerMoney", function(price, invoker, targetExecutor)
    local src = source
    if not src then return end

    if invoker ~= "LGF_TruckSystem" then
        print(("Unauthorized attempt to trigger event from another invoker resource "))
        return
    end


    if not targetExecutor or targetExecutor == 0 then
        print(("Invalid target player execute event %s."):format("LGF_TruckSystem.AddPlayerMoney"))
        return
    end

    if src ~= targetExecutor then
        print("Executor and targetExecutor do not match.")
        return
    end

    Config.InventoryAddItem(src, Config.ItemCash, price)
end)

RegisterNetEvent("LGF_TruckSystem.UpdatePlayerLevel", function(lvl, invoker, targetExecutor)
    local target = source
    if not target then return end
    if invoker ~= "LGF_TruckSystem" then
        print(("Unauthorized attempt to trigger event from another invoker resource "))
        return
    end


    if not targetExecutor or targetExecutor == 0 then
        print(("Invalid target player execute event %s."):format("LGF_TruckSystem.UpdatePlayerLevel"))
        return
    end

    if target ~= targetExecutor then
        print("Executor and targetExecutor do not match.")
        return
    end

    Functions.updatePlayerLevel(target, lvl, "add")
end)

RegisterNetEvent("LGF_TruckSystem.UpdateAllDelivery", function(data, zoneName, new)
    if not data or not zoneName then return end
    if type(data) ~= "table" then return end

    Functions.updateTasksList(data, zoneName, new)
end)

RegisterNetEvent("LGF_TruckSystem.UpdateRewardRedeemed",
    function(levelRedeemed, RewardItem, type, quantity, props, spawnLocation)
        local target = source
        if not target or not levelRedeemed or not type then return end
        Functions.updateRewardRedeemed(target, levelRedeemed, RewardItem, type, quantity, props, spawnLocation)
    end)
