
# LGF Truck System
[ShowCase](https://www.youtube.com/watch?v=TRJ-EbyKmVs)


## Update Player Level xp
```lua
---@param target number 
---@param newLevel number  
---@param type string "add" or "remove"
---return boolean | string 
exports.LGF_TruckSystem:updatePlayerLevel(target, newLevel, type)
```

## Get Player Level xp
```lua
---@param target number 
exports.LGF_TruckSystem:getPlayerLevel(target)
```



### Sets the health level of the trailer trailerHealth = 1000,
```lua
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
```


### Configures the NPC both in the scenario to be created and the NPC model
### If a route group is going to Go-postal you can use the npc s_m_m_ups_01
### If you are going to use it for wood deliveries you can use s_m_y_construct_01

```lua
DeliveryPedConfig = {
    Pedmodel = "s_m_y_construct_01",                                                                             --  Modelo do PED
    PedScenario = "WORLD_HUMAN_CLIPBOARD",                                                                 --  Cenário do PED
},
```

### Each dialog is now route-based, so if you make deliveries to a lumberyard, the subjects can be defined by IndexTask.
```lua
Config.RandomDescription = {
    { 1, "Entrega esse gerador em %s. \nSegue o GPS." },
    { 1, "Ta carregado a com o gerador? \nEntão leva rápido em %s. \nMarquei em seu GPS." },
    { 1, "Você é o novato? Segue para %s. \nDeixarei instruções em seu GPS." },
    { 1, "Ta atrasado! Leve o gerador para %s. \nMarquei em seu GPS." },

    { 7, "Você tem que entregar esse trambolho para a empreenteira logo. Vá até %s. \nVou marcar em seu GPS." },
    { 7, "Oque é isso? uma furadeira gigante? \n kkk \nDeixa esse trambolho em %s. \nSegue o GPS." },

    { 8, "Você tem uma carga para entregar em uma das estações. Ela fica em %s. \nPreciso que seja rápido então ande logo." },
    { 8, "Você tem um container para largar em %s. \nVou marcar em seu GPS." },
    { 8, "Cara quem é você? Não importa, leva o mais rápodo possível esse container para %s. \nSegue seu GPS." },
    { 8, "Carga quente irmão pega a visão e fica na maciota. \nZoa mané só mais uma das entregas do Michael para %s. \nVou marcar em seu GPS." },

    { 9, "Você abasteceu o tanque do RON. \nAgora preciso que você leve até %s irei marcar em seu GPS para facilitar."},
    { 9, "Irmão voce esta atrasado, ja fez o abastecimento do tanque do RON? \nTrevor vai ficar boladão comigo vai logo cara. \n Vou marcar em seu GPS mais te adianto que fica em %s."},
    { 9, "Chego bem na hora. \nTem um carregamento fresquinho do RON. \nVou marcar em seu GPS mais te adianto que fica em %s."},
    { 9, "Você é o novato!? é cada tralha que me mandam pqp com ERVA DOCE! \nentrega fica em %s. \nAgora essa não sabe onde fica, em que mundo esses moleques vivem. \n Segue o GPS sabe fazer isso pelo menos?"},

    { 10, "Leva tronco todos dia. \nVocê vai longe assim, vai pra %s ou melhor pra pQp. \n kkk \nVou marcar em seu GPS." },
    { 10, "Você tem uma remessa de toras para levar. \nVai ficar em %s. \nVou marcar em seu GPS." },
    { 10, "Você gosta mesmo de levar toras grossas. \nFaz favor deixa em %s. \nPega visão ta no seu GPS." },
}
```
