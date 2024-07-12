Config = {}

Config.Debug = false -- Set to true if you want debug prints 

Config.Garages = {
    ["police"] = { -- Job role
        {
            coords = vector3(2476.7, -1312.88, 48.87), -- Location of the garage
            spawnCoords = vector4(2485.71, -1308.96, 48.83, 182.87), -- Location to spawn the wagon
            storeCoords = vector3(2485.71, -1308.96, 48.83), -- Location to store the wagon
            wagons = {"policewagon01x", "policeWagongatling01x"} -- List of wagons available for purchase
        },
        {
            coords = vector3(-292.64, 826.18, 119.64), 
            spawnCoords = vector4(-300.19, 827.58, 119.78, 275.79), 
            storeCoords = vector3(-288.72, 828.1, 119.7), 
            wagons = {"policewagon01x", "policeWagongatling01x"} 
        },
    },
    ["doctor"] = { 
        {
            coords = vector3(2736.66, -1229.31, 50.27),
            spawnCoords = vector4(2740.09, -1230.0, 49.62, 176.33),
            storeCoords = vector3(2740.09, -1230.0, 49.62),
            wagons = {"wagondoc01x", "cart04"}
        },
        -- Add more garages if you want
    },
    -- Add more garages for different job roles
}

Config.WagonPrices = { -- Define prices for wagons. Add any wagon model here that you added above.
    ["wagondoc01x"] = 100,
    ["cart04"] = 100,
    ["policewagon01x"] = 100,
    ["policeWagongatling01x"] = 100,
}

Config.Locale = {
    notifyTitle = "Garage",
    buyWagon = "Buy Wagons",
    buyWagonSubtitle = "Select Wagon to Buy",
    retrieveWagon = "Retrieve Wagons",
    retrieveWagonSubtitle = "Select a wagon to retrieve",
    purchaseWagon = "Purchase new wagons",
    retrieveStored = "Retrieve stored wagons",
    wagonParkedSuccessTitle = "Success",
    wagonParkedSuccess = "Wagon parked successfully!",
    wagonParkedFailTitle = "Error",
    wagonParkedFail = "Failed to park the wagon!",
    buyWagonSuccess = "Wagon purchased successfully!",
    buyWagonFail = "Not Enough Money",
    noAccess = "You don't have access to this garage.",
    openGarage = "Open Garage",
    storeWagon = "Store Wagon",
}
