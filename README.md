WIP its not Fully finished

Original Nitrous Script from qb-tunerchip with modifications

Purge System

Purge Flow Rate with different size of Purge Effect depends of Purge Flow Rate

When nitro or purge finished give you empty bottle which you can to refill

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

Add item into shared/items.lua
```lua
['emptynitrous'] 				 	 = {['name'] = 'emptynitrous', 			  	  		['label'] = 'Empty Bottle', 					['weight'] = 1000, 		['type'] = 'item', 		['image'] = 'emptynitrous.png', 				['unique'] = true, 	['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Empty bottle of nitrous. You have to Refil'},
```

Import nitrous.sql into your DataBase

Add image from inventory-image into your inventory script

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

Add into qb-garages/client/main.lua on line 408 under TriggerServerEvent('qb-garage:server:updateVehicle', 1, totalFuel, engineDamage, bodyDamage, plate, indexgarage)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
```lua
QBCore.Functions.TriggerCallback('qb-nitro:GetNosLoadedVehs', function(vehs) VehicleNitrous = vehs while VehicleNitrous == nil do Wait(100) end end)
```
Have to Look Like this
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
            QBCore.Functions.TriggerCallback('qb-nitro:GetNosLoadedVehs', function(vehs) VehicleNitrous = vehs while VehicleNitrous == nil do Wait(100) end end)
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

Big Thanks to NotReload for helping me alot with function for saving in DataBase
