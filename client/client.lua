local QBCore = exports["qb-core"]:GetCoreObject()
local pedSpawned = false
local ShopPed = {}

local spawncarcoords

local function openRentMenu(data)
    SendNUIMessage({
        action = "OPEN",
        data = data
    })
    SetNuiFocus(true, true)
end

RegisterNUICallback('rent', function(data)
    QBCore.Functions.TriggerCallback('nc-rentacar:rent', function(status)
        if status then
            print("You have enough money!")
            createCar(data)
        else
            print("You don't have enough money!")
        end
    end, data)
end)

function createCar(data)
    local playerPed = PlayerPedId()
    local coords    = spawncarcoords
    local vehicle   = GetHashKey(data.carName)
    RequestModel(vehicle)

    while not HasModelLoaded(vehicle) do
        Citizen.Wait(0)
    end

    local vehicle = CreateVehicle(vehicle, spawncarcoords, 90.0, true, false)

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleColours(vehicle, 12, 12)
    SetVehicleWindowTint(vehicle, 1)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(vehicleName)
    exports[Config.Fuel]:SetFuel(vehicle, 100)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
    TriggerServerEvent('nc-rentacar:createCar', QBCore.Functions.GetVehicleProperties(vehicle),data.carName,GetVehicleNumberPlateText(vehicle),data.carDay)
end


local function createBlips()
    if pedSpawned then return end

    for store in pairs(Config.Locations) do
        if Config.Locations[store]["showblip"] then
            local StoreBlip = AddBlipForCoord(Config.Locations[store]["coords"]["x"], Config.Locations[store]["coords"]["y"], Config.Locations[store]["coords"]["z"])
            SetBlipSprite(StoreBlip, Config.Locations[store]["blipsprite"])
            SetBlipScale(StoreBlip, Config.Locations[store]["blipscale"])
            SetBlipDisplay(StoreBlip, 4)
            SetBlipColour(StoreBlip, Config.Locations[store]["blipcolor"])
            SetBlipAsShortRange(StoreBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.Locations[store]["label"])
            EndTextCommandSetBlipName(StoreBlip)
        end
    end
end

local function createPeds()
    if pedSpawned then return end

    for k, v in pairs(Config.Locations) do
        local current = type(v["ped"]) == "number" and v["ped"] or joaat(v["ped"])

        RequestModel(current)
        while not HasModelLoaded(current) do
            Wait(0)
        end

        ShopPed[k] = CreatePed(0, current, v["coords"].x, v["coords"].y, v["coords"].z-1, v["coords"].w, false, false)
        TaskStartScenarioInPlace(ShopPed[k], v["scenario"], 0, true)
        FreezeEntityPosition(ShopPed[k], true)
        SetEntityInvincible(ShopPed[k], true)
        SetBlockingOfNonTemporaryEvents(ShopPed[k], true)

        exports['qb-target']:AddTargetEntity(ShopPed[k], {
            options = {
                {
                    label = v["targetLabel"],
                    icon = v["targetIcon"],
                    action = function()
                        spawncarcoords = v.carspawn,
                        openRentMenu(v.categorie)
                    end,
                }
            },
            distance = 2.0
        })
    end

    pedSpawned = true
end


local function deletePeds()
    if not pedSpawned then return end
    for _, v in pairs(ShopPed) do
        DeletePed(v)
    end
    pedSpawned = false
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createBlips()
    createPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deletePeds()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    createBlips()
    createPeds()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deletePeds()
end)


RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)