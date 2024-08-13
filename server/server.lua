local VORPcore = exports.vorp_core:GetCore()

-- MySQL setup
Citizen.CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS UntamedGarage (
            id INT AUTO_INCREMENT PRIMARY KEY,
            charidentifier VARCHAR(50) NOT NULL,
            job VARCHAR(50) NOT NULL,
            wagon VARCHAR(50) NOT NULL,
            is_taken BOOLEAN DEFAULT FALSE,
            last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
    ]])

    MySQL.Async.execute('UPDATE UntamedGarage SET is_taken = FALSE', {}, function(rowsChanged)
        if Config.Debug then print("All wagons marked as available.") end
    end)
end)

local function saveWagonToDB(charidentifier, job, wagon)
    MySQL.Async.execute('INSERT INTO UntamedGarage (charidentifier, job, wagon, last_used) VALUES (@charidentifier, @job, @wagon, CURRENT_TIMESTAMP)', {
        ['@charidentifier'] = charidentifier,
        ['@job'] = job,
        ['@wagon'] = wagon
    })
end

local function getSpecificWagonFromDB(job, wagon, cb)
    local query = 'SELECT * FROM UntamedGarage WHERE job = @job'
    local params = { ['@job'] = job }

    if wagon then
        query = query .. ' AND wagon = @wagon'
        params['@wagon'] = wagon
    end

    if Config.Debug then print("Fetching wagons for job: " .. tostring(job) .. " and wagon: " .. tostring(wagon)) end
    MySQL.Async.fetchAll(query, params, function(result)
        if Config.Debug then print("Query result: ", json.encode(result)) end
        cb(result)
    end)
end

local function markWagonAsTaken(id)
    MySQL.Async.execute('UPDATE UntamedGarage SET is_taken = TRUE, last_used = CURRENT_TIMESTAMP WHERE id = @id', {
        ['@id'] = id
    })
end

local function markWagonAsReturned(id)
    MySQL.Async.execute('UPDATE UntamedGarage SET is_taken = FALSE WHERE id = @id', {
        ['@id'] = id
    })
end

RegisterServerEvent("untamed_garage:wagonDestroyed")
AddEventHandler("untamed_garage:wagonDestroyed", function(wagon)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    local job = Character.job
    
    getSpecificWagonFromDB(job, wagon, function(result)
        for _, w in pairs(result) do
            if w.is_taken then
                markWagonAsReturned(w.id)
                break
            end
        end
    end)
end)

RegisterServerEvent("untamed_garage:buyWagon")
AddEventHandler("untamed_garage:buyWagon", function(wagon)
    local _source = source
    local User = VORPcore.getUser(_source)
    local Character = User.getUsedCharacter
    local job = Character.job
    local charidentifier = Character.charIdentifier
    local money = Character.money
    
    if Config.Debug then print("Attempting to buy wagon: " .. tostring(wagon) .. " for job: " .. tostring(job)) end
    if money >= Config.WagonPrices[wagon] then
        Character.removeCurrency(0, Config.WagonPrices[wagon])
        saveWagonToDB(charidentifier, job, wagon)
        VORPcore.NotifyLeft(_source, Config.Locale.notifyTitle, Config.Locale.buyWagonSuccess, 'generic_textures', 'tick', 5000, 'COLOR_GREEN')
    else
        VORPcore.NotifyLeft(_source, Config.Locale.notifyTitle, Config.Locale.buyWagonFail, 'generic_textures', 'cross', 5000, 'COLOR_RED')
    end
    
end)

RegisterServerEvent("untamed_garage:retrieveWagon")
AddEventHandler("untamed_garage:retrieveWagon", function(wagon, spawnCoords)
    local _source = source
    local User = VORPcore.getUser(_source)
    local Character = User.getUsedCharacter
    local job = Character.job

    if Config.Debug then print("Attempting to retrieve wagon: " .. tostring(wagon) .. " for job: " .. tostring(job)) end
    getSpecificWagonFromDB(job, wagon, function(result)
        local availableWagons = 0
        local wagonId = nil

        for _, w in pairs(result) do
            if not w.is_taken then
                availableWagons = availableWagons + 1
                wagonId = w.id
                break
            end
        end

        if availableWagons > 0 then
            markWagonAsTaken(wagonId)
            TriggerClientEvent('untamed_garage:spawnWagon', _source, wagon, spawnCoords)
        else
            VORPcore.NotifyLeft(_source, Config.Locale.notifyTitle, "No available wagon of this type.", 'generic_textures', 'cross', 5000, 'COLOR_RED')
        end
    end)
end)

RegisterNetEvent('untamed_garage:parkWagon')
AddEventHandler('untamed_garage:parkWagon', function(wagonModel, wagonNetId)
    local src = source
    local wagon = NetworkGetEntityFromNetworkId(wagonNetId)
    if DoesEntityExist(wagon) then
        DeleteEntity(wagon)
    end

    local user = VORPcore.getUser(src)
    local char = user.getUsedCharacter
    local job = char.job

    if Config.Debug then print("Updating database for parked wagon:", wagonModel, "by job:", job) end

    MySQL.Async.execute('UPDATE UntamedGarage SET is_taken = 0 WHERE wagon = @wagon AND job = @job AND is_taken = 1 LIMIT 1', {
        ['@wagon'] = wagonModel,
        ['@job'] = job
    }, function(rowsChanged)
        if rowsChanged > 0 then
            if Config.Debug then print("Database updated successfully for wagon:", wagonModel) end
            VORPcore.NotifyLeft(src, Config.Locale.wagonParkedSuccessTitle, Config.Locale.wagonParkedSuccess, "menu_textures", "tick", 4000, "COLOR_WHITE")
        else
            if Config.Debug then print("Failed to update database for wagon:", wagonModel) end
            VORPcore.NotifyLeft(src, Config.Locale.wagonParkedFailTitle, Config.Locale.wagonParkedFail, "menu_textures", "cross", 4000, "COLOR_WHITE")
        end
    end)
end)

RegisterNetEvent("untamed_garage:getStoredWagons")
AddEventHandler("untamed_garage:getStoredWagons", function(job, garageIndex)
    local _source = source
    local User = VORPcore.getUser(_source)
    local Character = User.getUsedCharacter
    local userJob = Character.job

    if Config.Debug then print("Getting stored wagons for job: " .. tostring(userJob)) end
    if userJob == job then
        getSpecificWagonFromDB(job, nil, function(result)
            TriggerClientEvent("untamed_garage:openRetrieveWagonMenu", _source, garageIndex, job, result)
        end)
    else
        VORPcore.NotifyLeft(_source, Config.Locale.notifyTitle, Config.Locale.noAccess, 'generic_textures', 'cross', 5000, 'COLOR_RED')
    end
end)

RegisterServerEvent("untamed_garage:requestSetupGarage")
AddEventHandler("untamed_garage:requestSetupGarage", function()
    local _source = source
    local User = VORPcore.getUser(_source)
    local Character = User.getUsedCharacter
    local playerJob = Character.job

    if Config.Debug then print("Setting up garage for job: " .. tostring(playerJob)) end
    local garages = Config.Garages[playerJob]
    if garages then
        TriggerClientEvent("untamed_garage:setupGarage", _source, garages, playerJob)
    end
end)