local QBCore = exports['qb-core']:GetCoreObject()
local NitrousActivated = false
local NitrousBoost = 1.0
local VehicleNitrous = {}
local Fxs = {}
local purgeflowrate = 0.1
local nitroflowrate = 1.0

local function trim(value)
	if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('nitrous:GetNosLoadedVehs', function(vehs)
        VehicleNitrous = vehs
    end)
end)

RegisterNetEvent('qb-nitrous:client:LoadNitrous', function()
    local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if IsToggleModOn(veh, 18) then
        if not NitrousActivated then
            if IsInVehicle and not IsThisModelABike(GetEntityModel(GetVehiclePedIsIn(ped))) then
                if GetPedInVehicleSeat(veh, -1) == ped then
                    QBCore.Functions.Progressbar("security_pass", "Installing Nitrous..", 100, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "missheistdockssetup1clipboard@idle_a",
                            anim = "idle_a",
                            flags = 49,
                    }, {}, {}, function(status) -- Done
                        ClearPedTasks(PlayerPedId())
                        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nitrous'], "remove")
                        TriggerServerEvent("QBCore:Server:RemoveItem", 'nitrous', 1)
                        local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
                        local Plate = trim(GetVehicleNumberPlateText(CurrentVehicle))
                        TriggerServerEvent('nitrous:server:LoadNitrous', Plate)
                        TriggerServerEvent('nitrous:server:Update', {Plate, hasnitro, level})
                    end)
                else
                    QBCore.Functions.Notify("You cannot do that from this seat!", "error")
                end
            else
                QBCore.Functions.Notify('You\'re Not In A Car', 'error')
            end
        else
            QBCore.Functions.Notify('You Already Have NOS Active', 'error')
        end
    else
        QBCore.Functions.Notify('Vehicle need to have a Turbo to use NOS', 'error')
    end
end)

local nosupdated = false
local PurgeMode = false
local NitroMode = true
CreateThread(function()
    while true do
        local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
        local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
        if IsInVehicle then
            local Plate = trim(GetVehicleNumberPlateText(CurrentVehicle))
            if VehicleNitrous[Plate] ~= nil then
                if VehicleNitrous[Plate].hasnitro then
                    if NitroMode then
                        if IsControlJustPressed(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
                            SetEntityMaxSpeed(CurrentVehicle, 999.0)
                            NitrousActivated = true
                            CreateThread(function()
                                while NitrousActivated do
                                    if VehicleNitrous[Plate].level - 1 ~= 0 then
                                        if nitroflowrate == 1.0 then
                                            NitrousBoostNew = NitrousBoost + 1.0
                                            SetVehicleEnginePowerMultiplier(CurrentVehicle, NitrousBoostNew)
                                            SetVehicleEngineTorqueMultiplier(CurrentVehicle, NitrousBoostNew)
                                            TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 0.3))
                                            TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
                                        elseif nitroflowrate == 2.0 then
                                            NitrousBoostNew = NitrousBoost + 2.0
                                            SetVehicleEnginePowerMultiplier(CurrentVehicle, NitrousBoostNew)
                                            SetVehicleEngineTorqueMultiplier(CurrentVehicle, NitrousBoostNew)
                                            TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 0.7))
                                            TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
                                        elseif nitroflowrate == 3.0 then
                                            NitrousBoostNew = NitrousBoost + 3.0
                                            SetVehicleEnginePowerMultiplier(CurrentVehicle, NitrousBoostNew)
                                            SetVehicleEngineTorqueMultiplier(CurrentVehicle, NitrousBoostNew)
                                            TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 1.2))
                                            TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
                                        end
                                    else
                                        TriggerServerEvent('nitrous:server:UnloadNitrous', Plate)
                                        NitrousActivated = false
                                        SetVehicleBoostActive(CurrentVehicle, 0)
                                        SetVehicleEnginePowerMultiplier(CurrentVehicle, LastEngineMultiplier)
                                        SetVehicleEngineTorqueMultiplier(CurrentVehicle, 1.0)
                                        StopScreenEffect("RaceTurbo")
                                        for index,_ in pairs(Fxs) do
                                            StopParticleFxLooped(Fxs[index], 1)
                                            TriggerServerEvent('nitrous:server:StopSync', trim(GetVehicleNumberPlateText(CurrentVehicle)))
                                            Fxs[index] = nil
                                        end
                                    end
                                    Wait(200)
                                end
                            end)
                        elseif IsControlJustPressed(0, 121) and nitroflowrate <= 2 then
                            nitroflowrate = nitroflowrate + 1
                            QBCore.Functions.Notify('Nitro Flowrate: ' .. nitroflowrate--[[, 'inform', 5500]])
                        elseif IsControlJustPressed(0, 121) and nitroflowrate >= 2 then
                            QBCore.Functions.Notify('Nitro is on maximum Flowrate'--[[, 'inform', 5500]])
                        elseif IsControlJustPressed(0, 214) and nitroflowrate >= 2 then
                            nitroflowrate = nitroflowrate - 1
                            QBCore.Functions.Notify('Nitro Flowrate: ' .. nitroflowrate--[[, 'inform', 5500]])
                        elseif IsControlJustPressed(0, 214) and nitroflowrate <= 2 then
                            QBCore.Functions.Notify('Nitro is on minimum Flowrate'--[[, 'inform', 5500]])
                        end
                    elseif PurgeMode then
                        if IsControlPressed(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
                            if VehicleNitrous[Plate].level - 1 ~= 0 then
                                if purgeflowrate >= 0.1 or purgeflowrate <= 0.3 then
                                    TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 1.5))
                                    TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
                                    SetVehicleBoostActive(CurrentVehicle, 1) --Boost Sound
				                    SetVehicleNitroPurgeEnabled(CurrentVehicle, true)
                                    Wait(500)
                                elseif purgeflowrate >= 0.4 or purgeflowrate <= 0.7 then
                                    TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 2.5))
                                    TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
                                    SetVehicleBoostActive(CurrentVehicle, 1) --Boost Sound
                                    SetVehicleNitroPurgeEnabled(CurrentVehicle, true)
                                elseif purgeflowrate >= 0.8 or purgeflowrate <= 1.0 then
                                    TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 3.5))
                                    TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
                                    SetVehicleBoostActive(CurrentVehicle, 1) --Boost Sound
                                    SetVehicleNitroPurgeEnabled(CurrentVehicle, true)
                                end
                            else
                                TriggerServerEvent('nitrous:server:UnloadNitrous', Plate)
                                SetVehicleNitroPurgeEnabled(CurrentVehicle, false)
                                SetVehicleBoostActive(CurrentVehicle, false)
                            end
                            Wait(200)
                        elseif IsControlJustPressed(0, 121) and purgeflowrate <= 0.9 then
                            purgeflowrate = purgeflowrate + 0.1
                            QBCore.Functions.Notify('Purge Spray Flowrate: ' .. purgeflowrate--[[, 'inform', 5500]])
                        elseif IsControlJustPressed(0, 121) and purgeflowrate >= 0.9 then
                            QBCore.Functions.Notify('Purge Spray is on maximum Flowrate'--[[, 'inform', 5500]])
                        elseif IsControlJustPressed(0, 214) and purgeflowrate >= 0.2 then
                            purgeflowrate = purgeflowrate - 0.1
                            QBCore.Functions.Notify('Purge Spray Flowrate: ' .. purgeflowrate--[[, 'inform', 5500]])
                        elseif IsControlJustPressed(0, 214) and purgeflowrate <= 0.2 then
                            QBCore.Functions.Notify('Purge Spray is on minimum Flowrate'--[[, 'inform', 5500]])
                        else
                            SetVehicleNitroPurgeEnabled(CurrentVehicle, false)
                            TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, false)
                        end
                    end

                    if IsControlJustPressed(0, 21) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
                        if not PurgeMode and NitroMode then
                            PurgeMode = true
                            NitroMode = false
                            QBCore.Functions.Notify('Nitro Mode: Smoke Extraction'--[[, 'inform', 5500]])
                        elseif not NitroMode and PurgeMode then
                            NitroMode = true
                            PurgeMode = false
                            QBCore.Functions.Notify('Nitro Mode: Nitro'--[[, 'inform', 5500]])
                        end
                    end

                    if IsControlJustReleased(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
                        if NitrousActivated then
                            local veh = GetVehiclePedIsIn(PlayerPedId())
                            SetVehicleBoostActive(veh, 0)
                            SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
                            SetVehicleEngineTorqueMultiplier(veh, 1.0)
                            for index,_ in pairs(Fxs) do
                                StopParticleFxLooped(Fxs[index], 1)
                                TriggerServerEvent('nitrous:server:StopSync', trim(GetVehicleNumberPlateText(veh)))
                                Fxs[index] = nil
                            end
                            TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, false)
                            TriggerServerEvent('nitrous:server:Update', {Plate, hasnitro, level})
                            NitrousActivated = false
                        end
                    end
                else
                    TriggerServerEvent('nitrous:server:UnloadNitrous', Plate)
                    NitrousActivated = false
                    SetVehicleBoostActive(CurrentVehicle, 0)
                    SetVehicleEnginePowerMultiplier(CurrentVehicle, LastEngineMultiplier)
                    SetVehicleEngineTorqueMultiplier(CurrentVehicle, 1.0)
                    for index,_ in pairs(Fxs) do
                        StopParticleFxLooped(Fxs[index], 1)
                        TriggerServerEvent('nitrous:server:StopSync', trim(GetVehicleNumberPlateText(CurrentVehicle)))
                        Fxs[index] = nil
                    end
                end
            else
                if not nosupdated then
                    TriggerEvent('hud:client:UpdateNitrous', false, nil, false)
                    nosupdated = true
                end
            end
        else
            if nosupdated then
                nosupdated = true
            end
            Wait(1500)
        end
        Wait(3)
    end
end)

----------PURGE--------------

local vehicles = {}
local particles = {}

function IsVehicleNitroPurgeEnabled(vehicle)
    return vehicles[vehicle] == true
end

function SetVehicleNitroPurgeEnabled(vehicle, enabled)
    if IsVehicleNitroPurgeEnabled(vehicle) == enabled then
      return
    end
  
    if enabled then
      local boneleft = GetEntityBoneIndexByName(vehicle, 'wheel_lf')
      local posleft = GetWorldPositionOfEntityBone(vehicle, boneleft)
      local offleft = GetOffsetFromEntityGivenWorldCoords(vehicle, posleft.x, posleft.y, posleft.z)
      local boneright = GetEntityBoneIndexByName(vehicle, 'wheel_rf')
      local posright = GetWorldPositionOfEntityBone(vehicle, boneright)
      local offright = GetOffsetFromEntityGivenWorldCoords(vehicle, posright.x, posright.y, posright.z)
      local ptfxs = {}
  
      for i=0,1 do
        local leftPurge = CreateVehiclePurgeSpray(vehicle, offleft.x - 0.1, offleft.y + 0.5, offleft.z + 0.05, 30.0, -50.0, 0.5, purgeflowrate)
        local rightPurge = CreateVehiclePurgeSpray(vehicle, offright.x + 0.1, offright.y + 0.5, offright.z + 0.05, 30.0, 50.0, 0.5, purgeflowrate)
  
        table.insert(ptfxs, leftPurge)
        table.insert(ptfxs, rightPurge)
      end
  
      vehicles[vehicle] = true
      particles[vehicle] = ptfxs
    else
      if particles[vehicle] and #particles[vehicle] > 0 then
        for _, particleId in ipairs(particles[vehicle]) do
          StopParticleFxLooped(particleId)
        end
      end
  
      vehicles[vehicle] = nil
      particles[vehicle] = nil
    end
end

function CreateVehiclePurgeSpray(vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale)
    UseParticleFxAssetNextCall('core')
    return StartParticleFxLoopedOnEntity('ent_sht_steam', vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, false, false, false)
  end

p_flame_location = {
	"exhaust",
	"exhaust_2",
	"exhaust_3",
	"exhaust_4",
	"exhaust_5",
	"exhaust_6",
	"exhaust_7",
	"exhaust_8",
	"exhaust_9",
	"exhaust_10",
	"exhaust_11",
	"exhaust_12",
	"exhaust_13",
	"exhaust_14",
	"exhaust_15",
	"exhaust_16",
}

ParticleDict = "veh_xs_vehicle_mods"
ParticleFx = "veh_nitrous"
ParticleSize = 1.3

CreateThread(function()
    while true do
        if NitrousActivated then
            local veh = GetVehiclePedIsIn(PlayerPedId())
            if veh ~= 0 then
                TriggerServerEvent('nitrous:server:SyncFlames', VehToNet(veh))
                for _,bones in pairs(p_flame_location) do
                    if GetEntityBoneIndexByName(veh, bones) ~= -1 then
                        if Fxs[bones] == nil then
                            RequestNamedPtfxAsset(ParticleDict)
                            while not HasNamedPtfxAssetLoaded(ParticleDict) do
                                Wait(0)
                            end
                            SetPtfxAssetNextCall(ParticleDict)
                            UseParticleFxAssetNextCall(ParticleDict)
                            Fxs[bones] = StartParticleFxLoopedOnEntityBone(ParticleFx, veh, 0.0, -0.02, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(veh, bones), ParticleSize, 0.0, 0.0, 0.0)
                        end
                    end
                end
            end
        end
        Wait(20)
    end
end)

local NOSPFX = {}

RegisterNetEvent('nitrous:client:SyncFlames', function(netid, nosid)
    local veh = NetToVeh(netid)
    if veh ~= 0 then
        local myid = GetPlayerServerId(PlayerId())
        if NOSPFX[trim(GetVehicleNumberPlateText(veh))] == nil then
            NOSPFX[trim(GetVehicleNumberPlateText(veh))] = {}
        end
        if myid ~= nosid then
            for _,bones in pairs(p_flame_location) do
                if NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones] == nil then
                    NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones] = {}
                end
                if GetEntityBoneIndexByName(veh, bones) ~= -1 then
                    if NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones].pfx == nil then
                        RequestNamedPtfxAsset(ParticleDict)
                        while not HasNamedPtfxAssetLoaded(ParticleDict) do
                            Wait(0)
                        end
                        SetPtfxAssetNextCall(ParticleDict)
                        UseParticleFxAssetNextCall(ParticleDict)
                        NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones].pfx = StartParticleFxLoopedOnEntityBone(ParticleFx, veh, 0.0, -0.05, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(veh, bones), ParticleSize, 0.0, 0.0, 0.0)

                    end
                end
            end
        end
    end
end)

RegisterNetEvent('nitrous:client:StopSync', function(plate)
    if NOSPFX[plate] then
        for k, v in pairs(NOSPFX[plate]) do
            StopParticleFxLooped(v.pfx, 1)
            NOSPFX[plate][k].pfx = nil
        end
    end
end)

RegisterNetEvent('nitrous:client:UpdateNitroLevel', function(Plate, level)
    VehicleNitrous[Plate].level = level
end)

RegisterNetEvent('nitrous:client:LoadNitrous', function(Plate)
    VehicleNitrous[Plate] = {
        hasnitro = true,
        level = 100,
    }
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = trim(GetVehicleNumberPlateText(CurrentVehicle))
    if CPlate == Plate then
        TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, false)
    end
end)

RegisterNetEvent('nitrous:client:UnloadNitrous', function(Plate)
    VehicleNitrous[Plate] = nil
    TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['emptynitrous'], "add")
    TriggerServerEvent("QBCore:Server:AddItem", 'emptynitrous', 1)
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = trim(GetVehicleNumberPlateText(CurrentVehicle))
    if CPlate == Plate then
        NitrousActivated = false
        TriggerEvent('hud:client:UpdateNitrous', false, nil, false)
    end
end)