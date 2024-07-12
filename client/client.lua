local Menu = exports.vorp_menu:GetMenuData()
local VORPcore = exports.vorp_core:GetCore()

local garagePrompts = {}
local storePrompts = {}
local spawnedWagons = {}
local playerJob = nil

-- Prompts
function SetupPrompt(promptType, index)
    Citizen.CreateThread(function()
        local str = ""
        local prompt = nil
        if promptType == "garageMenu" then
            str = "Open Garage"
            prompt = PromptRegisterBegin()
            PromptSetControlAction(prompt, 0x8AAA0AD4) -- INPUT_CONTEXT (E key)
            str = CreateVarString(10, 'LITERAL_STRING', str)
            PromptSetText(prompt, str)
            PromptSetEnabled(prompt, false)
            PromptSetVisible(prompt, false)
            PromptSetHoldMode(prompt, true)
            PromptRegisterEnd(prompt)
            garagePrompts[index] = prompt
            if Config.Debug then
                print("Created garage menu prompt:", prompt)
            end
        elseif promptType == "storeWagon" then
            str = "Store Wagon"
            prompt = PromptRegisterBegin()
            PromptSetControlAction(prompt, 0x8AAA0AD4) -- INPUT_CONTEXT (E key)
            str = CreateVarString(10, 'LITERAL_STRING', str)
            PromptSetText(prompt, str)
            PromptSetEnabled(prompt, false)
            PromptSetVisible(prompt, false)
            PromptSetHoldMode(prompt, true)
            PromptRegisterEnd(prompt)
            storePrompts[index] = prompt
            if Config.Debug then
                print("Created store wagon prompt:", prompt)
            end
        end
    end)
end

function ShowPrompt(prompt)
    if prompt then
        PromptSetEnabled(prompt, true)
        PromptSetVisible(prompt, true)
    end
end

function HidePrompt(prompt)
    if prompt then
        PromptSetEnabled(prompt, false)
        PromptSetVisible(prompt, false)
    end
end

local function openBuyWagonMenu(garageIndex, job)
    Menu.CloseAll()

    local buyElements = {}
    for _, wagon in pairs(Config.Garages[job][garageIndex].wagons) do
        table.insert(buyElements, {label = wagon .. " - $" .. Config.WagonPrices[wagon], value = wagon, desc = "Buy " .. wagon})
    end

    Menu.Open("default", GetCurrentResourceName(), "untamed_menu_BuyWagon", {
        title = Config.Locale.buyWagon,
        subtext = Config.Locale.buyWagonSubtitle,
        align = "top-right",
        elements = buyElements
    },
    function(data, menu)
        if data.current.value then
            TriggerServerEvent("untamed_garage:buyWagon", data.current.value)
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

local function openGarageMenu(garageIndex, job)
    Menu.CloseAll()

    local MenuElements = {
        {label = Config.Locale.buyWagon, value = "buy", desc = Config.Locale.purchaseWagon},
        {label = Config.Locale.retrieveWagon, value = "retrieve", desc = Config.Locale.retrieveStored}
    }

    Menu.Open("default", GetCurrentResourceName(), "untamed_menu_OpenGarage", {
        title = "Garage",
        subtext = "Select an option",
        align = "top-right",
        elements = MenuElements
    },
    function(data, menu)
        if data.current.value == "buy" then
            openBuyWagonMenu(garageIndex, job)
        elseif data.current.value == "retrieve" then
            TriggerServerEvent("untamed_garage:getStoredWagons", job, garageIndex)
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent("untamed_garage:openRetrieveWagonMenu")
AddEventHandler("untamed_garage:openRetrieveWagonMenu", function(garageIndex, job, wagons)
    Menu.CloseAll()

    local retrieveElements = {}
    local wagonCounts = {}

    for _, wagon in pairs(wagons) do
        if not wagon.is_taken then
            if not wagonCounts[wagon.wagon] then
                wagonCounts[wagon.wagon] = 1
            else
                wagonCounts[wagon.wagon] = wagonCounts[wagon.wagon] + 1
            end
        end
    end

    for wagon, count in pairs(wagonCounts) do
        table.insert(retrieveElements, {label = wagon .. " (" .. count .. ")", value = wagon, desc = "Retrieve " .. wagon})
    end

    Menu.Open("default", GetCurrentResourceName(), "untamed_menu_RetrieveWagon", {
        title = Config.Locale.retrieveWagon,
        subtext = Config.Locale.retrieveWagonSubtitle,
        align = "top-right",
        elements = retrieveElements
    },
    function(data, menu)
        if data.current.value then
            TriggerServerEvent("untamed_garage:retrieveWagon", data.current.value, Config.Garages[job][garageIndex].spawnCoords)
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent("untamed_garage:setupGarage")
AddEventHandler("untamed_garage:setupGarage", function(garages, job)
    playerJob = job
    for i, garage in pairs(garages) do
        SetupPrompt("garageMenu", i)
        SetupPrompt("storeWagon", i)

        Citizen.CreateThread(function()
            while true do
                local playerCoords = GetEntityCoords(PlayerPedId())
                for i, garage in pairs(Config.Garages[playerJob] or {}) do
                    if Vdist2(playerCoords, garage.coords) < 2.0 then
                        ShowPrompt(garagePrompts[i])
                        if PromptHasHoldModeCompleted(garagePrompts[i]) then
                            openGarageMenu(i, playerJob)
                            Wait(500)
                        end
                    else
                        HidePrompt(garagePrompts[i])
                    end
        
                    if Vdist2(playerCoords, garage.storeCoords) < 2.0 then
                        local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        for idx, v in ipairs(spawnedWagons) do
                            if playerVehicle == v.wagon then
                                ShowPrompt(storePrompts[i])
                                if PromptHasHoldModeCompleted(storePrompts[i]) then
                                    TriggerServerEvent("untamed_garage:parkWagon", v.model, VehToNet(v.wagon))
                                    table.remove(spawnedWagons, idx)
                                    Wait(500)
                                    break
                                end
                            else
                                HidePrompt(storePrompts[i])
                            end
                        end
                    else
                        HidePrompt(storePrompts[i])
                    end
                end
        
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNetEvent('untamed_garage:spawnWagon')
AddEventHandler('untamed_garage:spawnWagon', function(wagonModel, spawnCoords)
    if Config.Debug then print("Spawning wagon: " .. wagonModel) end
    local model = GetHashKey(wagonModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    local wagon = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    SetVehicleOnGroundProperly(wagon)
    SetModelAsNoLongerNeeded(model)

    table.insert(spawnedWagons, {wagon = wagon, model = wagonModel})
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if DoesEntityExist(wagon) and (IsEntityDead(wagon) or not IsVehicleDriveable(wagon, false)) then
                TriggerServerEvent('untamed_garage:wagonDestroyed', wagonModel)
                DeleteVehicle(wagon)
                break
            end
        end
    end)
end)


Citizen.CreateThread(function()
    TriggerServerEvent("untamed_garage:requestSetupGarage")
end)

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    TriggerServerEvent("untamed_garage:requestSetupGarage")
end)

RegisterNetEvent('vorp:playerJobChange')
AddEventHandler('vorp:playerJobChange', function(job)
    playerJob = job
    TriggerServerEvent("untamed_garage:requestSetupGarage")
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        HidePrompt()
        for _, v in pairs(spawnedWagons) do
            if DoesEntityExist(v.wagon) then
                DeleteVehicle(v.wagon)
            end
        end
        for _, prompt in pairs(garagePrompts) do
            if prompt then
                HidePrompt(prompt)
                PromptDelete(prompt)
            end
        end
        for _, prompt in pairs(storePrompts) do
            if prompt then
                HidePrompt(prompt)
                PromptDelete(prompt)
            end
        end
    end
end)