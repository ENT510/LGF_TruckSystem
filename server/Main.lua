RegisterNetEvent("LGF_TruckSystem.CreateAvatarAndLevel", function()
    local src = source
    local Player = LGF.Core:GetIdentifier(src)
    local Level = 0
    if not src or not Player then return end
    MySQL.insert.await("INSERT INTO lgf_logistic (Player, CurrentLevel, reward_redeemed) VALUES (?, ?, ? )", { Player, Level, json.encode({}) })
end)

RegisterNetEvent("LGF_TruckSystem.AddPlayerMoney", function(price)
    local src = source
    if not src then return end
    Config.InventoryAddItem(src, Config.ItemCash, price)
end)

RegisterNetEvent("LGF_TruckSystem.UpdatePlayerLevel", function(lvl)
    local target = source
    if not target then return end
    Functions.updatePlayerLevel(target, lvl, "add")
end)

RegisterNetEvent("LGF_TruckSystem.UpdateAllDelivery", function(data, zoneName, new)
    if not data or not zoneName then return end
    Functions.updateTasksList(data, zoneName, new)
end)

RegisterNetEvent("LGF_TruckSystem.UpdateRewardRedeemed", function(levelRedeemed, RewardItem, type, quantity, props,spawnLocation)
    local target = source
    if not target or not levelRedeemed or not type then return end
    Functions.updateRewardRedeemed(target, levelRedeemed, RewardItem, type, quantity, props,spawnLocation)
end)
