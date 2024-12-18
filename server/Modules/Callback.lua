LGF:RegisterServerCallback("LGF_TruckSystem.isNewPlayer", function(source)
    return Functions.isPlayerNew(source)
end)


LGF:RegisterServerCallback("LGF_TruckSystem.getPlayerLevel", function(source)
    return Functions.getPlayerLevel(source)
end)

LGF:RegisterServerCallback("LGF_TruckSystem.getTasksListByZone", function(source, zoneName)
    return Functions.getTasksListByZone(zoneName)
end)


LGF:RegisterServerCallback("LGF_TruckSystem.isRewardRedeemed", function(source, levelToCheck)
    local isRedeemed = Functions.isRewardRedeemed(source, levelToCheck)
    if isRedeemed == nil then
        return false
    end

    return isRedeemed
end)
