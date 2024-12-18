Functions = {}


function Functions.isPlayerNew(target)
    local identifier = LGF.Core:GetIdentifier(target)
    if not identifier then return false end
    local result = MySQL.scalar.await("SELECT COUNT(1) FROM lgf_logistic WHERE Player = ?", { identifier })
    return result == 0
end

function Functions.getPlayerLevel(target)
    local identifier = LGF.Core:GetIdentifier(target)
    if not identifier then return 0 end
    local level = MySQL.scalar.await("SELECT CurrentLevel FROM lgf_logistic WHERE Player = ?", { identifier })
    return level or 0
end

function Functions.updatePlayerLevel(target, newLevel, type)
    local NewLevelUpdated = 0

    local identifier = LGF.Core:GetIdentifier(target)
    local MyLevel = Functions.getPlayerLevel(target)

    if type == "add" then
        NewLevelUpdated = MyLevel + newLevel
    elseif type == "remove" then
        NewLevelUpdated = MyLevel - newLevel
    end

    if not identifier then
        return false, "Player identifier not found."
    end

    local affectedRows = MySQL.update.await("UPDATE lgf_logistic SET CurrentLevel = ? WHERE Player = ?",
        { NewLevelUpdated, identifier })

    return true, NewLevelUpdated
end

function Functions.updateTasksList(data, zoneName, isNew)
    data.date = os.date("%Y-%m-%d %H:%M:%S")

    if isNew then
        local id = MySQL.insert.await('INSERT INTO `lgf_alldeliveries` (ZoneName, AllDeliveries) VALUES (?, ?)', {
            zoneName, json.encode(data)
        })
    else
        local affectedRows = MySQL.update.await('UPDATE `lgf_alldeliveries` SET AllDeliveries = ? WHERE ZoneName = ?', {
            json.encode(data), zoneName
        })
    end
end

function Functions.getTasksListByZone(zoneName)
    if not zoneName then
        return nil, "Zone name is required."
    end

    local taskListRows = MySQL.query.await("SELECT AllDeliveries FROM lgf_alldeliveries WHERE ZoneName = ?", { zoneName })

    if taskListRows and #taskListRows > 0 then
        local taskList = {}

        for _, row in ipairs(taskListRows) do
            local task = json.decode(row.AllDeliveries)
            if task then
                table.insert(taskList, task)
            end
        end

        return taskList
    else
        return {}, "No task list found for the specified zone."
    end
end

function Functions.deletePendingTasks()
    local pendingCount = MySQL.scalar.await(
        "SELECT COUNT(*) FROM lgf_alldeliveries WHERE JSON_UNQUOTE(JSON_EXTRACT(AllDeliveries, '$.status')) = 'Pending'")

    if pendingCount > 0 then
        local affectedRows = MySQL.update.await( "DELETE FROM lgf_alldeliveries WHERE JSON_UNQUOTE(JSON_EXTRACT(AllDeliveries, '$.status')) = 'Pending'")
    end
end

function Functions.updateRewardRedeemed(target, levelRedeemed, itemName, type, quantity, props, spawnLocation)
    local identifier = LGF.Core:GetIdentifier(target)
    local stored = nil
    if not identifier then
        return false, "Player identifier not found."
    end

    if spawnLocation == "here" then
        stored = 0
    elseif spawnLocation == "garage" then
        stored = 1
    end

    local rewardRedeemedData = MySQL.scalar.await("SELECT reward_redeemed FROM lgf_logistic WHERE Player = ?",
        { identifier })
    local rewards = rewardRedeemedData and json.decode(rewardRedeemedData) or {}

    rewards[tostring(levelRedeemed)] = true

    local updatedRewardRedeemedJSON = json.encode(rewards)

    local affectedRows = MySQL.update.await("UPDATE lgf_logistic SET reward_redeemed = ? WHERE Player = ?", {
        updatedRewardRedeemedJSON, identifier
    })

    if type == "item" or type == "weapon" then
        Config.InventoryAddItem(target, itemName, quantity)
    elseif type == "vehicle" then
        LGF.Core:giveVehicle(target, props,stored)
    end

    return affectedRows > 0, updatedRewardRedeemedJSON
end

function Functions.isRewardRedeemed(target, levelToCheck)
    local identifier = LGF.Core:GetIdentifier(target)
    if not identifier then
        return false, "Player identifier not found."
    end

    local rewardRedeemedData = MySQL.scalar.await("SELECT reward_redeemed FROM lgf_logistic WHERE Player = ?", { identifier })
    if not rewardRedeemedData then
        return false
    end

    local rewards = json.decode(rewardRedeemedData)

    return rewards and rewards[tostring(levelToCheck)] == true
end

function Functions.clearRewardRedeemed(target)
    local identifier = LGF.Core:GetIdentifier(target)
    if not identifier then
        return false, "Player identifier not found."
    end

    local affectedRows = MySQL.update.await("UPDATE lgf_logistic SET reward_redeemed = ? WHERE Player = ?", {
        json.encode({}), identifier
    })

    if affectedRows > 0 then
        return true, "Rewards have been cleared."
    else
        return false, "Failed to clear rewards."
    end
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Functions.deletePendingTasks()
    end
end)

exports("updatePlayerLevel", Functions.updatePlayerLevel)
exports("getPlayerLevel", Functions.getPlayerLevel)
exports("getTasksListByZone", Functions.getTasksListByZone)
exports("clearRewardRedeemed", Functions.clearRewardRedeemed)
