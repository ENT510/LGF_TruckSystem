Config = Config or {}

-- Locale setting for the application
Config.Locales = 'en' -- Language setting; "en" or "it" or "fr"

-- Provider for notifications, "ox_lib" or "utility"
Config.ProviderNotification = "ox_lib" -- The library used for notifications

-- Item name used for cash in the game
Config.ItemCash = "money" -- Represents the cash item in the inventory system

-- Folder path for images used in the inventory UI
Config.ImageFolderInventory = "nui://ox_inventory/web/images" -- Location for inventory images

Config.DebugMode = false
-- Allowed user groups for command access
Config.AllowedGroupsCommand = {
    ["admin"] = true,   -- Allows admin users to execute commands
    ["player"] = false, -- Regular players are not allowed to execute commands
    -- ["other"] = false,
}

-- Command definitions and their purposes
Config.Commands = {
    -- Limpar todas as recompensas resgatadas do jogador
    -- Usage: /clearReward [id] where id is the player's identifier
    clearReward = "clearReward",

    -- Atualize o nível do jogador
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
            PedPosition = vec4(1202.7315673828, -3256.8989257813, 7.0617628097534, 355.94125366211), -- Position of the Pedestrian (Ped)
            PedModel = "a_m_m_business_01",                             -- Model of the Ped
            PedScenario = "world_human_leaning",                        -- Scenario for the Ped
        },
        Tasks = {
            --  Equipamento elétrico
            {
                IndexTask = 1,                                                                                              --  Índice da tarefa
                TaskName = "Entrega Elétrica",                                                                    --  Nome da tarefa
                VehicleModel = "Bobcat XL",                                                                                    --  Modelo do veículo
                VehicleHash = "bobcatxl",                                                                                     --  Hash do veículo
                trailerHash = "trailersmall",                                                                                --  Carga a ser rebocada
                trailerHealth = 1000,
                PriceForKilometer = 12,                                                                                     --  Preço por quilômetro para a tarefa
                FuelStart = 100.0,                                                                                          --  Iniciando combustível para o veículo
                RequiredLevel = 0,                                                                                          --  Nível necessário para realizar a tarefa
                LevelIncrease = 1,                                                                                          --  Aumento de nível após concluir a tarefa
                DeliveryLocation = {
                    --  Posição de nascimento do caminhão
                    VehicleSpawnPosition = vec4(1199.7944335938, -3241.5224609375, 6.161009311676, 0.011085667647421),
                    --  Posição onde o jogador carregará o veículo com o trailer
                    LoadVehicle = vec4(1194.8266601563, -3291.263671875, 5.1443257331848, 272.14721679688),
                    --  Zona de carregamento da carga
                    LoadCarga = vec4(1189.2723388672, -3312.4833984375, 5.2758469581604, 357.06188964844),                    
                    DeliveryPedConfig = {
                        Pedmodel = "s_m_y_construct_01",                                                                             --  Modelo do PED
                        PedScenario = "WORLD_HUMAN_CLIPBOARD",                                                                 --  Cenário do PED
                    },
                    DeliveryPoints = {
                        vec4(1222.5192871094, -3265.3371582031, 5.5015826225281, 43.099475860596),
                        vec4(1221.0584716797, -3267.6411132813, 5.5034785270691, 172.05993652344),
                        vec4(1225.6881103516, -3266.8796386719, 5.5034794807434, 279.96878051758),
                        vec4(1206.3642578125, -3260.5275878906, 5.5034785270691, 6.716748714447),
                        vec4(1202.9893798828, -3267.9406738281, 5.5018301010132, 36.371742248535)
                    },
                    UnloadVehicle = {                                                                                       --  Posição para descarregar o veículo (uma zona aleatória)
                        vec4(-429.93228149414, -2764.2495117188, 5.6385917663574, 183.67539978027),                                                       --  Posição aleatória de descarga
                        vec4(-71.225898742676, -2442.6613769531, 5.6333894729614, 56.170791625977),
                        vec4(490.18539428711, -2180.0510253906, 5.5517387390137, 331.28164672852),

                        vec4(1197.572265625, -2188.7048339844, 41.036743164063, 130.33142089844),
                        vec4(1358.0041503906, -2096.4311523438, 51.630996704102, 38.508979797363),
                        vec4(1598.2872314453, -1710.1453857422, 87.769981384277, 114.5475769043),
                        vec4(2499.5461425781, -437.05776977539, 92.637466430664, 180.84321594238),
                        vec4(2741.5537109375, 1473.5648193359, 30.423013687134, 165.09284973145),
                        vec4(1753.5113525391, 2598.7036132813, 45.211196899414, 357.7678527832),
                        vec4(869.15112304688, 2349.7392578125, 51.345485687256, 271.70056152344),
                        vec4(715.97747802734, 4172.3032226563, 40.354991912842, 285.17358398438),
                        vec4(-510.56512451172, 5262.4545898438, 80.224975585938, 157.02290344238),
                        vec4(-684.166015625, 5784.7885742188, 16.975208282471, 155.27012634277),
                        vec4(1431.3791503906, 6346.8901367188, 23.627975463867, 284.97937011719),
                        vec4(2220.1901855469, 5594.8461914063, 53.672504425049, 96.106506347656),
                        vec4(2490.6616210938, 4963.73046875, 44.32596206665, 310.26641845703),
                        vec4(2110.0859375, 4767.3505859375, 40.826164245605, 93.139106750488),
                    },
                }
            },
            --  Entregas de Material de contrução
            {
                IndexTask = 2,                                                                                              --  Índice da tarefa
                TaskName = "Entrega Construtora",                                                                    --  Nome da tarefa
                VehicleModel = "Packer",                                                                                    --  Modelo do veículo
                VehicleHash = "packer",                                                                                     --  Hash do veículo
                trailerHash = "armytrailer2",                                                                                --  Carga a ser rebocada
                trailerHealth = 600,                                                                                --  Carga a ser rebocada
                PriceForKilometer = 23,                                                                                     --  Preço por quilômetro para a tarefa
                FuelStart = 100.0,                                                                                          --  Iniciando combustível para o veículo
                RequiredLevel = 115,                                                                                          --  Nível necessário para realizar a tarefa
                LevelIncrease = 2,                                                                                          --  Aumento de nível após concluir a tarefa
                DeliveryLocation = {
                    --  Posição de nascimento do caminhão
                    VehicleSpawnPosition = vec4(1199.7944335938, -3241.5224609375, 6.161009311676, 0.011085667647421),
                    --  Posição onde o jogador carregará o veículo com o trailer
                    LoadVehicle = vec4(1245.6013183594, -3155.5466308594, 7.4638800621033, 270.97067260742),    -- vaga 1
                    --LoadVehicle = vec4(1246.7657470703, -3149.1994628906, 7.4470233917236, 269.61743164063),    -- vaga 2
                    --LoadVehicle = vec4(1246.69921875, -3141.8974609375, 7.4472270011902, 267.650390625),        -- vaga 3
                    --LoadVehicle = vec4(1246.6165771484, -3135.3461914063, 7.4507684707642, 270.66693115234),    -- vaga 4
                    --  Zona de carregamento da carga
                    LoadCarga = vec4(vector4(810.19744873047, -3198.6083984375, 5.9842891693115, 180.09448242188)),
                    DeliveryPedConfig = {
                        Pedmodel = "s_m_y_construct_01",                                                                             --  Modelo do PED
                        PedScenario = "WORLD_HUMAN_CLIPBOARD",                                                                 --  Cenário do PED
                    },
                    DeliveryPoints = {
                        vec4(1222.5192871094, -3265.3371582031, 5.5015826225281, 43.099475860596),
                        vec4(1221.0584716797, -3267.6411132813, 5.5034785270691, 172.05993652344),
                        vec4(1225.6881103516, -3266.8796386719, 5.5034794807434, 279.96878051758),
                        vec4(1206.3642578125, -3260.5275878906, 5.5034785270691, 6.716748714447),
                        vec4(1202.9893798828, -3267.9406738281, 5.5018301010132, 36.371742248535)
                    },
                    UnloadVehicle = {                                                                                       --  Posição para descarregar o veículo (uma zona aleatória)
                        vec4(870.41815185547, 2339.0014648438, 53.482566833496, 272.93930053711),                                                       --  Posição aleatória de descarga
                        vec4(2681.1279296875, 2807.2294921875, 42.244190216064, 4.4962577819824),
                        vec4(2953.5502929688, 2749.0798339844, 45.24878692627, 280.33776855469),
                        vec4(36.453556060791, -608.87463378906, 33.438701629639, 252.03591918945),
                        vec4(-1140.8363037109, -2218.8754882813, 15.004152297974, 331.7451171875),
                        vec4(-430.79763793945, -2713.576171875, 7.8103470802307, 225.57698059082),

                    },
                }
            },
            --  Entrega de carga para trem
            {
                IndexTask = 3,                                                                                              --  Índice da tarefa
                TaskName = "Entrega de Conteiners",                                                                    --  Nome da tarefa
                VehicleModel = "Hauler",                                                                                    --  Modelo do veículo
                VehicleHash = "hauler",                                                                                     --  Hash do veículo
                trailerHash = "docktrailer",                                                                                --  Carga a ser rebocada
                trailerHealth = 300,
                PriceForKilometer = 25,                                                                                     --  Preço por quilômetro para a tarefa
                FuelStart = 100.0,                                                                                          --  Iniciando combustível para o veículo
                RequiredLevel = 25,                                                                                          --  Nível necessário para realizar a tarefa
                LevelIncrease = 1,                                                                                        --  Aumento de nível após concluir a tarefa
                DeliveryLocation = {
                    VehicleSpawnPosition = vec4(1199.7944335938, -3241.5224609375, 6.161009311676, 0.011085667647421),      --  Posição de desova para o caminhão
                    LoadVehicle = vec4(188.21296691895, 6396.431640625, 31.588514328003, 303.22601318359),                  --  Posição onde o jogador carregará o veículo com o trailer
                    LoadCarga = vec4(76.51008605957, 6329.9970703125, 31.225772857666, 32.015926361084),                    --  Zona de carregamento da carga
                    DeliveryPedConfig = {
                        Pedmodel = "s_m_y_airworker",                                                                             --  Modelo do PED
                        PedScenario = "WORLD_HUMAN_CLIPBOARD",                                                                 --  Cenário do PED
                    },
                    DeliveryPoints = {
                        vec4(1222.5192871094, -3265.3371582031, 5.5015826225281, 43.099475860596),
                        vec4(1221.0584716797, -3267.6411132813, 5.5034785270691, 172.05993652344),
                        vec4(1225.6881103516, -3266.8796386719, 5.5034794807434, 279.96878051758),
                        vec4(1206.3642578125, -3260.5275878906, 5.5034785270691, 6.716748714447),
                        vec4(1202.9893798828, -3267.9406738281, 5.5018301010132, 36.371742248535)
                    },
                    UnloadVehicle = {
                        vec4(2663.3674316406, 1659.9058837891, 24.76561164856, 270.95700073242),    --  facil
                        vec4(693.88372802734, -834.86572265625, 24.452432632446, 182.5277557373),   --  facil
                        vec4(937.25457763672, -1244.2307128906, 25.794363021851, 37.149806976318),  --  facil
                        vec4(183.92822265625, -2213.5747070313, 6.1389942169189, 179.07792663574),  --  facil
                        vec4(243.99005126953, -2761.2526855469, 6.1882448196411, 272.22418212891),  --  facil
                        vec4(-1778.2564697266, 3096.8244628906, 32.992141723633, 239.11032104492),  --  facil
                        vec4(2351.6428222656, 3134.1818847656, 48.396255493164, 259.62921142578),   --  facil
                        vec4(2896.1435546875, 4380.9150390625, 50.527118682861, 292.87356567383),   --  facil
                        vec4(2703.3408203125, 2781.4865722656, 38.152969360352, 119.75021362305),   --  medio
                        vec4(869.31707763672, 2340.3979492188, 51.834407806396, 271.08114624023),   --  medio
                        vec4(2439.4494628906, -399.70791625977, 93.18286895752, 272.72235107422),   --  dificil
                    },
                }
            },
            --  Entregas de Combustível
            {
                IndexTask = 4,
                TaskName = "Entregas de Combustível",
                VehicleModel = "Hauler",
                VehicleHash = "hauler",
                trailerHash = "tanker",                                                 --  Carga a ser rebocada
                trailerHealth = 200,
                PriceForKilometer = 35,
                FuelStart = 100.0,
                RequiredLevel = 50,
                LevelIncrease = 1,
                DeliveryLocation = {
                    VehicleSpawnPosition = vec4(1199.7944335938, -3241.5224609375, 6.161009311676, 0.011085667647421),
                    LoadVehicle = vec4(944.81884765625, -3155.6450195313, 7.7309107780457, 179.35888671875),
                    LoadCarga = vec4(1289.9677734375, -3339.6560058594, 7.5943002700806, 89.78829956054688),                    --  Zona de carregamento da carga
                    DeliveryPedConfig = {
                        Pedmodel = "s_m_m_ups_01",                                                                             --  Modelo do PED
                        PedScenario = "WORLD_HUMAN_CLIPBOARD",                                                                 --  Cenário do PED
                    },
                    DeliveryPoints = {
                        vec4(1222.5192871094, -3265.3371582031, 5.5015826225281, 43.099475860596),
                        vec4(1221.0584716797, -3267.6411132813, 5.5034785270691, 172.05993652344),
                        vec4(1225.6881103516, -3266.8796386719, 5.5034794807434, 279.96878051758),
                        vec4(1206.3642578125, -3260.5275878906, 5.5034785270691, 6.716748714447),
                        vec4(1202.9893798828, -3267.9406738281, 5.5018301010132, 36.371742248535)
                    },
                    UnloadVehicle = {
                        vec4(171.67849731445, -1555.0415039063, 30.816736221313, 314.4384765625),
                        vec4(-75.320793151855, -1761.7224121094, 31.056129455566, 159.3410949707),
                        vec4(-545.42559814453, -1222.1756591797, 19.892431259155, 333.95269775391),                        
                        vec4(-706.89617919922, -934.97113037109, 20.61107635498, 358.85601806641),
                        vec4(260.16247558594, -1256.9604492188, 30.741090774536, 2.1182591915131),
                        vec4(807.36364746094, -1031.8184814453, 27.913940429688, 182.06709289551),
                        vec4(1203.4847412109, -1385.7624511719, 36.82442855835, 181.41917419434),
                        vec4(1176.9256591797, -315.5458984375, 70.77611541748, 279.51287841797),
                        vec4(632.90020751953, 267.72811889648, 104.68713378906, 0.0026846914552152),
                        vec4(-1411.6013183594, -279.08087158203, 47.935348510742, 131.23458862305),
                        vec4(-2100.6127929688, -318.27355957031, 14.622673988342, 350.3327331543),
                        vec4(-96.578430175781, 6397.0610351563, 33.052947998047, 42.636631011963),
                        vec4(199.32385253906, 6621.6372070313, 33.23397064209, 183.59658813477),
                        vec4(1716.8602294922, 6419.4829101563, 34.880645751953, 153.06329345703),
                        vec4(1695.6940917969, 4915.1655273438, 43.677429199219, 57.455280303955),
                        vec4(1986.2635498047, 3779.8488769531, 33.785034179688, 210.6156463623),
                        vec4(1770.1329345703, 3343.3225097656, 42.599685668945, 304.5217590332),
                        vec4(2683.8947753906, 3292.5756835938, 56.836608886719, 238.4296875),
                        vec4(1206.5216064453, 2657.43359375, 39.415451049805, 223.55883789063),
                        vec4(1056.1867675781, 2658.1264648438, 41.14587020874, 0.56644153594971),
                        vec4(268.61840820313, 2576.75, 46.646091461182, 91.378196716309),
                        vec4(64.148963928223, 2782.7104492188, 59.472877502441, 144.27587890625),
                        vec4(-2554.6967773438, 2346.509765625, 34.649612426758, 271.58282470703),
                        vec4(2527.7143554688, 2623.2648925781, 39.53458404541, 267.19909667969),
                        vec4(2553.3427734375, 419.99658203125, 110.04804992676, 314.12890625),
                        vec4(-1796.30859375, 806.02911376953, 140.10346984863, 43.778011322021),
                        vec4(-308.27856445313, -1466.8151855469, 32.133220672607, 209.70355224609),

                    },
                }
            },
            --  Entrega de Troncos
            {
                IndexTask = 5,                                                                                              --  Índice da tarefa
                TaskName = "Entrega Madeireira",                                                                    --  Nome da tarefa
                VehicleModel = "Longhorn",                                                                                    --  Modelo do veículo
                VehicleHash = "longhorn",                                                                                     --  Hash do veículo
                trailerHash = "trailerlogsh",                                                                                --  Carga a ser rebocada
                trailerHealth = 500,
                PriceForKilometer = 45,                                                                                     --  Preço por quilômetro para a tarefa
                FuelStart = 100.0,                                                                                          --  Iniciando combustível para o veículo
                RequiredLevel = 115,                                                                                          --  Nível necessário para realizar a tarefa
                LevelIncrease = 2,                                                                                          --  Aumento de nível após concluir a tarefa
                DeliveryLocation = {
                    --  Posição de nascimento do caminhão
                    VehicleSpawnPosition = vec4(1199.7944335938, -3241.5224609375, 6.161009311676, 0.011085667647421),
                    --  Posição onde o jogador carregará o veículo com o trailer
                    LoadVehicle = vec4(1147.8946533203, -3344.0886230469, 8.2008638381958, 269.43063354492),
                    --  Zona de carregamento da carga
                    LoadCarga = vec4(1216.4849853516, -2962.9545898438, 8.2522096633911, 183.07838439941),                    
                    DeliveryPedConfig = {
                        Pedmodel = "s_m_m_ups_01",                                                                             --  Modelo do PED
                        PedScenario = "WORLD_HUMAN_CLIPBOARD",                                                                 --  Cenário do PED
                    },
                    DeliveryPoints = {
                        vec4(1222.5192871094, -3265.3371582031, 5.5015826225281, 43.099475860596),
                        vec4(1221.0584716797, -3267.6411132813, 5.5034785270691, 172.05993652344),
                        vec4(1225.6881103516, -3266.8796386719, 5.5034794807434, 279.96878051758),
                        vec4(1206.3642578125, -3260.5275878906, 5.5034785270691, 6.716748714447),
                        vec4(1202.9893798828, -3267.9406738281, 5.5018301010132, 36.371742248535)
                    },
                    UnloadVehicle = {                                                                                       --  Posição para descarregar o veículo (uma zona aleatória)
                        vec4(512.4810, -630.3847, 24.7512, 355.0930),                                                       --  Posição aleatória de descarga
                        vec4(180.85014343262, -2212.1940917969, 5.9558839797974, 4.6638774871826),
                        vec4(244.18930053711, -2789.7651367188, 6.0002002716064, 184.66250610352),
                        vec4(1030.3225097656, -3210.2250976563, 5.8595771789551, 98.523345947266),
                        vec4(2667.5979003906, 1672.2795410156, 24.488092422485, 172.72282409668),

                    },
                }
            },
        }
    },
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
    local vehicle = NetworkGetEntityFromNetworkId(netid) -- Entity handle

    if GetResourceState("wasabi_carlock"):find("start") then
        exports.wasabi_carlock:GiveKey(plate)
    elseif GetResourceState("resource_name"):find("start") then

    end
end
Config.RemoveVehicleKey = function(netid, plate)
    local vehicle = NetworkGetEntityFromNetworkId(netid) -- Entity handle

    if GetResourceState("wasabi_carlock"):find("start") then
        exports.wasabi_carlock:RemoveKey(plate)
    elseif GetResourceState("resource_name"):find("start") then

    end
end
-- Configuration for reward items based on player levels
Config.RewardLevel = {
    
    [2] = {
        ItemHash = "water",
        Quantity = 3,
        Props = "item",
        Image = nil,
        ItemLabel = "Garrafas de água"
    },
    [3] = {
        ItemHash = "burger",
        Quantity = 1,
        Props = "item",
        Image = nil,
        ItemLabel = "Hambúrguer"
    },
    [4] = {
        ItemHash = "water",
        Quantity = 10,
        Props = "item",
        Image = nil,
        ItemLabel = "Garrafas de água"
    },
    [5] = {
        ItemHash = "burger",
        Quantity = 3,
        Props = "item",
        Image = nil,
        ItemLabel = "Hambúrguer"
    },
    [25] = {                    -- Level 5 rewards
        ItemHash = "money",     -- Item hash for cash
        Quantity = 400,         -- Amount of cash
        Props = "item",         -- Type of prop (can be item, weapon, or vehicle)
        Image = nil,            -- Optional image link for the item "url" or nil
        ItemLabel = "Dinheiro"  -- Label for the item
    },
    [90] = {
        ItemHash = "WEAPON_BAT",
        Quantity = 1,
        Props = "weapon",
        Image = nil,
        ItemLabel = "Bastão de Baseball "
    },
    -- Add More Level
}
-- Random NPC names for delivery tasks
Config.RandomNPCName = {
    "Marcos", "Lucas", "Jonata", -- Common names
    "Alexandre", "Matheus", "Francisco",
    "David", "Gregório", "Antônio",
    "Samuel"
}
-- Random NPC descriptions for delivery tasks based on location
Config.RandomDescription = {
    { 1, "Entrega esse gerador em %s. \nSegue o GPS." },
    { 1, "Ta carregado a com o gerador? \nEntão leva rápido em %s. \nMarquei em seu GPS." },
    { 1, "Você é o novato? Segue para %s. \nDeixarei instruções em seu GPS." },
    { 1, "Ta atrasado! Leve o gerador para %s. \nMarquei em seu GPS." },

    { 2, "Você tem que entregar esse trambolho para a empreenteira logo. Vá até %s. \nVou marcar em seu GPS." },
    { 2, "Oque é isso? uma furadeira gigante? \n kkk \nDeixa esse trambolho em %s. \nSegue o GPS." },

    { 3, "Você tem uma carga para entregar em uma das estações. Ela fica em %s. \nPreciso que seja rápido então ande logo." },
    { 3, "Você tem um container para largar em %s. \nVou marcar em seu GPS." },
    { 3, "Cara quem é você? Não importa, leva o mais rápodo possível esse container para %s. \nSegue seu GPS." },
    { 3, "Carga quente irmão pega a visão e fica na maciota. \nZoa mané só mais uma das entregas do Michael para %s. \nVou marcar em seu GPS." },

    { 4, "Você abasteceu o tanque do RON. \nAgora preciso que você leve até %s irei marcar em seu GPS para facilitar."},
    { 4, "Irmão voce esta atrasado, ja fez o abastecimento do tanque do RON? \nTrevor vai ficar boladão comigo vai logo cara. \n Vou marcar em seu GPS mais te adianto que fica em %s."},
    { 4, "Chego bem na hora. \nTem um carregamento fresquinho do RON. \nVou marcar em seu GPS mais te adianto que fica em %s."},
    { 4, "Você é o novato!? é cada tralha que me mandam pqp com ERVA DOCE! \nentrega fica em %s. \nAgora essa não sabe onde fica, em que mundo esses moleques vivem. \n Segue o GPS sabe fazer isso pelo menos?"},

    { 5, "Leva tronco todos dia. \nVocê vai longe assim, vai pra %s ou melhor pra pQp. \n kkk \nVou marcar em seu GPS." },
    { 5, "Você tem uma remessa de toras para levar. \nVai ficar em %s. \nVou marcar em seu GPS." },
    { 5, "Você gosta mesmo de levar toras grossas. \nFaz favor deixa em %s. \nPega visão ta no seu GPS." },
}