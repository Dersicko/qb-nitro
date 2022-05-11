local QBCore = exports['qb-core']:GetCoreObject()
local VehicleNitrous = {}

QBCore.Functions.CreateUseableItem("nitrous", function(source, item)
    TriggerClientEvent('qb-nitrous:client:LoadNitrous', source)
end)

RegisterNetEvent('nitrous:server:LoadNitrous', function(Plate)
    VehicleNitrous[Plate] = {
        hasnitro = true,
        level = 100,
    }
    TriggerClientEvent('nitrous:client:LoadNitrous', -1, Plate)
end)

RegisterNetEvent('nitrous:server:SyncFlames', function(netId)
    TriggerClientEvent('nitrous:client:SyncFlames', -1, netId, source)
end)

RegisterNetEvent('nitrous:server:UnloadNitrous', function(Plate)
    VehicleNitrous[Plate] = nil
    TriggerClientEvent('nitrous:client:UnloadNitrous', -1, Plate)
end)

RegisterNetEvent('nitrous:server:UpdateNitroLevel', function(Plate, level)
    VehicleNitrous[Plate].level = level
    TriggerClientEvent('nitrous:client:UpdateNitroLevel', -1, Plate, level)
    TriggerClientEvent('nitrous:client:UpdateNitrousLevel', -1, Plate, NitrousLevel)
end)

RegisterNetEvent('nitrous:server:StopSync', function(plate)
    TriggerClientEvent('nitrous:client:StopSync', -1, plate)
end)