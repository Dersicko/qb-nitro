WIP its not Fully finished

Nitro Script with Purge System, Purge Flow Rate and Nitro Flow Rate with different power depends of Nitro Flow Rate and different size of purge depends of Purge Flow Rate

When nitro or purge finished give you empty bottle if you want to refill

BUG: Infinity nitro and sound for purge

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

Add item into shared/items.lua
```lua
['bottlenitrous'] 				 	 = {['name'] = 'bottlenitrous', 			  	  		['label'] = 'Bottle Nitrous', 					['weight'] = 1000, 		['type'] = 'item', 		['image'] = 'bottlenitrous.png', 				['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Empty bottle of nitrous. You have to Refil'},
```

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

Add into qb-garages/client/main.lua on line 408 under TriggerServerEvent('qb-garage:server:updateVehicle', 1, totalFuel, engineDamage, bodyDamage, plate, indexgarage)
```lua
TriggerEvent('nitrous:client:getNosLevel')
```
Have to Look Like this

```lua
local function enterVehicle(veh, indexgarage, type, garage)
    local plate = QBCore.Functions.GetPlate(veh)
    QBCore.Functions.TriggerCallback('qb-garage:server:checkOwnership', function(owned)
        if owned then
            local bodyDamage = math.ceil(GetVehicleBodyHealth(veh))
            local engineDamage = math.ceil(GetVehicleEngineHealth(veh))
            local totalFuel = exports['LegacyFuel']:GetFuel(veh)
            local vehProperties = QBCore.Functions.GetVehicleProperties(veh)
            TriggerServerEvent('qb-garage:server:updateVehicle', 1, totalFuel, engineDamage, bodyDamage, plate, indexgarage)
            TriggerEvent('nitrous:client:getNosLevel')
            CheckPlayers(veh, garage)
            if type == "house" then
                exports['qb-core']:DrawText(Lang:t("info.car_e"), 'left')
                InputOut = true
                InputIn = false
            end
            if plate then
                OutsideVehicles[plate] = nil
                TriggerServerEvent('qb-garages:server:UpdateOutsideVehicles', OutsideVehicles)
            end
            QBCore.Functions.Notify(Lang:t("success.vehicle_parked"), "primary", 4500)
        else
            QBCore.Functions.Notify(Lang:t("error.not_owned"), "error", 3500)
        end
    end, plate, type, indexgarage, PlayerGang.name)
end
```

import nitrous.sql into your DataBase

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

Big Thanks on Silent Man1C for helping me alot with saving in db
