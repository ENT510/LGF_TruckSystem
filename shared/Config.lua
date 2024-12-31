Config = {}

-- Locale setting for the application
Config.Locales = 'en' -- Language setting; "en" or "it" or "fr"

-- Provider for notifications, "ox_lib" or "utility"
Config.ProviderNotification = "ox_lib" -- The library used for notifications

-- Item name used for cash in the game
Config.ItemCash = "money" -- Represents the cash item in the inventory system

-- Folder path for images used in the inventory UI
Config.ImageFolderInventory = "nui://ox_inventory/web/images" -- Location for inventory images

-- Allowed user groups for command access
Config.AllowedGroupsCommand = {
    ["admin"] = true,   -- Allows admin users to execute commands
    ["player"] = false, -- Regular players are not allowed to execute commands
    -- ["other"] = false,
}

-- Command definitions and their purposes
Config.Commands = {
    -- Clear all rewards redeemed from the player
    -- Usage: /clearReward [id] where id is the player's identifier
    clearReward = "clearReward",

    -- Update the level of the player
    -- Usage: /updateLevel [id] [level] [type]
    -- type can be "add" to increase the level or "remove" to decrease it
    updateLevel = "updateLevel",
}

-- Configuration for Truck Delivery Locations
-- Each zone contains:
-- 1. DataPed: Information about the pedestrian (NPC) including their position, model, and scenario (This is for Open the Logistic Menu).
-- 2. Tasks: A list of delivery tasks that players can undertake in the respective zone.
--    Each task includes:
--    - IndexTask: An identifier for the task.
--    - TaskName: A descriptive name for the task.
--    - VehicleModel: The model of the vehicle required for the task.
--    - VehicleHash: The hash identifier for the vehicle.
--    - PriceForKilometer: The payment per kilometer for completing the task.
--    - FuelStart: The initial fuel level of the vehicle.
--    - RequiredLevel: The player level required to undertake the task.
--    - LevelIncrease: The level gained upon completing the task.
--    - DeliveryLocation: Information about where to spawn the vehicle, load it, and the delivery and unload locations.
Config.TruckLocation = {
    ["zone1"] = {
        DataPed = {
            PedPosition = vec4(117.5898, 6372.5747, 31.3759, 301.6158), -- Position of the Pedestrian (Ped)
            PedModel = "a_m_m_business_01",                             -- Model of the Ped
            PedScenario = "world_human_leaning",                        -- Scenario for the Ped
        },
        Tasks = {
            {
                IndexTask = 1,                                                          -- Index of the task
                TaskName = "Task #1",                                                   -- Name of the task
                VehicleModel = "Hauler",                                                -- Model of the vehicle
                VehicleHash = "hauler",                                                 -- Hash of the vehicle
                PriceForKilometer = 500,                                                -- Price per kilometer for the task
                FuelStart = 100.0,                                                      -- Starting fuel for the vehicle
                RequiredLevel = 0,                                                      -- Level required to undertake the task
                LevelIncrease = 1,                                                      -- Level increase after completing the task
                DeliveryLocation = {
                    VehicleSpawnPosition = vec4(128.3049, 6373.8711, 31.2183, 38.6651), -- Spawn position for the truck
                    LoadVehicle = vec4(136.0019, 6358.3550, 31.0540, 29.7400),          -- Position where the player will load the vehicle with the trailer
                    DeliveryPoints = {                                                  -- Positions where the player needs to go to talk with the Ped
                        vec4(1198.4099, -2581.1172, 37.5394, 188.5729),
                        vec4(-754.2217, -2482.6394, 13.9859, 197.5421),
                        vec4(-438.9650, 5942.9922, 32.0252, 12.1194),
                        vec4(2370.4004, 4786.1733, 35.7414, 41.0047),
                    },
                    UnloadVehicle = {                                 -- Position to unload the vehicle (one random zone)
                        vec4(512.4810, -630.3847, 24.7512, 355.0930), -- Random unload position
                        --vec4(512.4810, -630.3847, 24.7512, 355.0930),
                        --vec4(512.4810, -630.3847, 24.7512, 355.0930),
                        --vec4(512.4810, -630.3847, 24.7512, 355.0930),
                        --vec4(512.4810, -630.3847, 24.7512, 355.0930),

                    },
                }
            },
            {
                IndexTask = 2,
                TaskName = "Task #2",
                VehicleModel = "Hauler",
                VehicleHash = "hauler",
                PriceForKilometer = 200,
                FuelStart = 100.0,
                RequiredLevel = 2,
                LevelIncrease = 1,
                DeliveryLocation = {
                    VehicleSpawnPosition = vec4(128.3049, 6373.8711, 31.2183, 38.6651),
                    LoadVehicle = vec4(136.0019, 6358.3550, 31.0540, 29.7400),
                    DeliveryPoints = {
                        vec4(-2569.8694, 2319.9949, 33.0600, 347.3557),
                    },
                    UnloadVehicle = {
                        vec4(-2534.2903, 2341.2783, 33.0599, 208.4719),
                    },
                }
            },
        }
    },

    ["zone2"] = {
        DataPed = {
            PedPosition = vec4(-710.6172, 5790.2041, 17.4652, 45.1464),
            PedModel = "a_m_m_business_01",
            PedScenario = "world_human_leaning",
        },
        Tasks = {
            {
                IndexTask = 1,
                TaskName = "Task #2",
                VehicleModel = "Packer",
                VehicleHash = "packer",
                PriceForKilometer = 450,
                FuelStart = 100.0,
                RequiredLevel = 3,
                LevelIncrease = 0.1,
                DeliveryLocation = {
                    VehicleSpawnPosition = vec4(-728.3266, 5812.3564, 17.3936, 253.5389),
                    LoadVehicle = vec4(-744.3272, 5819.6626, 17.4011, 241.8388),
                    DeliveryPoints = {
                        vec4(-165.7345, -1511.6049, 33.3601, 260.3518),
                    },
                    UnloadVehicle = {
                        vec4(978.8539, -3223.0366, 5.9006, 252.0064),
                    },
                }
            }
        },
    }
}




-- Function to add an item to a player's inventory
---@param target: The identifier of the target player (usually a player ID)
---@param item: The item hash or name that is to be added
---@param quantity: The amount of the item to be added

Config.InventoryAddItem = function(target, item, quantity)
    if GetResourceState("ox_inventory"):find("start") then
        exports.ox_inventory:AddItem(target, item, quantity)
    elseif GetResourceState("qb-inventory"):find("start") then
        exports['qb-inventory']:AddItem(target, item, quantity)
    end
end

Config.AddVehicleKey = function(netid, plate)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    if GetResourceState("wasabi_carlock"):find("start") then
        exports.wasabi_carlock:GiveKey(plate)
    elseif GetResourceState("qb-vehiclekeys"):find("start") then
        TriggerEvent("qb-vehiclekeys:client:AddKeys", plate)
    elseif GetResourceState("qbx_vehiclekeys"):find("start") then
        TriggerEvent("qb-vehiclekeys:client:AddKeys", plate)
    else
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    end
end

Config.RemoveVehicleKey = function(netid, plate)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    if GetResourceState("wasabi_carlock"):find("start") then
        exports.wasabi_carlock:RemoveKey(plate)
    elseif GetResourceState("qb-vehiclekeys"):find("start") then
        TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
    elseif GetResourceState("qbx_vehiclekeys"):find("start") then
        TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
    end
end



-- Configuration for reward items based on player levels
Config.RewardLevel = {
    [5] = {                 -- Level 5 rewards
        ItemHash = "money", -- Item hash for cash
        Quantity = 3000,    -- Amount of cash
        Props = "item",     -- Type of prop (can be item, weapon, or vehicle)
        Image = nil,        -- Optional image link for the item "url" or nil
        ItemLabel = "Cash"  -- Label for the item
    },
    [10] = {
        ItemHash = "WEAPON_PISTOL",
        Quantity = 1,
        Props = "weapon",
        Image = nil,
        ItemLabel = "Pistol"
    },
    [15] = {
        ItemHash = "WEAPON_BAT",
        Quantity = 1,
        Props = "weapon",
        Image = nil,
        ItemLabel = "Baseball Bat"
    },
    [20] = {
        ItemHash = "turismo3",
        Quantity = 1,
        Props = "vehicle",
        Image = nil,
        ItemLabel = "Turismo Car"
    },
    [25] = {
        ItemHash = "t20",
        Quantity = 1,
        Props = "vehicle",
        Image = nil,
        ItemLabel = "T20 Car"
    },
    [30] = {
        ItemHash = "black_money",
        Quantity = 1,
        Props = "item",
        Image = nil,
        ItemLabel = "Black Money"
    },
    [35] = {
        ItemHash = "WEAPON_ASSAULTRIFLE",
        Quantity = 1,
        Props = "weapon",
        Image = nil,
        ItemLabel = "Assault Rifle"
    },
    [40] = {
        ItemHash = "burger",
        Quantity = 10,
        Props = "item",
        Image = nil,
        ItemLabel = "Burger"
    },
    [45] = {
        ItemHash = "water",
        Quantity = 30,
        Props = "item",
        Image = nil,
        ItemLabel = "Water Bottles"
    },
    -- Add More Level
}

-- Random NPC names for delivery tasks
Config.RandomNPCName = {
    "Mark", "Luke", "John", -- Common names
    "Alexander", "Matthew", "Francis",
    "David", "George", "Anthony",
    "Stephen"
}

-- Random NPC descriptions for delivery tasks based on location
Config.RandomDescriptionNPC = {
    "You have a shipment of firewood ready for pickup at %s. Could you please grab it?", -- Placeholder %s will be replaced by the location
    "There's a package waiting for you at %s. Could you go and collect it?",
    "Great news! You need to deliver some supplies to %s. Make sure to get them there safely!",
    "Just a heads up! There's some cargo at %s that you need to pick up for your next delivery.",
    "Hi! We've scheduled a delivery for you at %s. Can you handle that for us?",
    "Your next task is to gather the goods from the location at %s. I trust you'll manage it well!",
    "Please swing by %s and collect the items from there. They are ready for you!",
    "You are required to pick up a package from %s. Thank you for your assistance!",
    "Hey! A shipment is ready for you at the drop-off point %s. Please take care of it!",
    "Could you please head over to %s? It's time to complete your delivery process!"
}
