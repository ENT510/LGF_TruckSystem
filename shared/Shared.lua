Shared = {}
local Context = LGF:GetContext()

Shared.Notification = function(title, message, position, type, source)
    if Context == "client" then
        if Config.ProviderNotification == "ox_lib" and GetResourceState("ox_lib"):find("start") then
            lib.notify({
                title = title,
                description = message,
                type = type,
                duration = 5000,
                position = position or 'top',
            })
        elseif Config.ProviderNotification == "utility" and GetResourceState("LGF_Utility"):find("start") then
            TriggerEvent('LGF_Utility:SendNotification', {
                id = math.random(111111111, 3333333333),
                title = title,
                message = message,
                icon = type,
                duration = 5000,
                position = 'top-right',
            })
        end
    elseif Context == "server" then
        if Config.ProviderNotification == "ox_lib" and GetResourceState("ox_lib"):find("start") then
            TriggerClientEvent('ox_lib:notify', source, {
                title = title,
                description = message,
                type = type,
                duration = 5000,
                position = position or 'top-right',
            })
        elseif Config.ProviderNotification == "utility" and GetResourceState("LGF_Utility"):find("start") then
            LGF:TriggerClientEvent('LGF_Utility:SendNotification', source, {
                id = math.random(111111111, 3333333333),
                title = title,
                message = message,
                icon = type,
                duration = 5000,
                position = 'top-right',
            })
        end
    end
end

function Shared.getRandomDeliveryNPC(id, location)
    local randomIndexName = math.random(#Config.RandomNPCName)
    local dialogosId1 = {}
    for _, dialog in ipairs(Config.RandomDescription) do
        if dialog[1] == id then
            table.insert(dialogosId1, dialog[2])
        end
    end
    local randomDialog = dialogosId1[math.random(#dialogosId1)]

    return {
        name = Config.RandomNPCName[randomIndexName],
        description = string.format(randomDialog, location)
    }
end

--[[
function Shared.getRandomDeliveryNPC(id, location)

    local randomIndexName = math.random(#Config.RandomNPCName)
    if id == 1 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionTrem)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionTrem[randomIndexDescription], location)
        }
    elseif id == 2 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionGasolina)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionGasolina[randomIndexDescription], location)
        }
    elseif id == 3 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionMadeira)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionMadeira[randomIndexDescription], location)
        }
    elseif id == 4 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionVeiculos)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionVeiculos[randomIndexDescription], location)
        }
    elseif id == 5 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionNPC)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionNPC[randomIndexDescription], location)
        }
    elseif id == 6 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionNPC)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionNPC[randomIndexDescription], location)
        }
    elseif id == 7 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionNPC)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionNPC[randomIndexDescription], location)
        }
    elseif id == 8 then
        local randomIndexDescription = math.random(#Config.RandomDescriptionNPC)
        return {
            name = Config.RandomNPCName[randomIndexName],
            description = string.format(Config.RandomDescriptionNPC[randomIndexDescription], location)
        }
    end    
end
]]