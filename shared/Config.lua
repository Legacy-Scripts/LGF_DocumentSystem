Config                  = {}
Config.DebugEnabled     = true
Config.Locales          = GetConvar("LGF_DocumentSystem:GetLocales", "en")
Config.ProviderPhoto    = (GetResourceState("screenshot-basic"):find("start") and "screenshot-basic" or "MugShotBase64")

Config.EnableAutoClose  = true
Config.AutoCloseTime    = 3700
Config.KeyCloseDocument = "BACK"


Lang:loadLocales()



-- [[ICON IS IMPORTED IN web/Components/Icon.tsx]]
Config.AvailableDocuments = {
    {
        type = "license_id", -- Document type (item Name)
        title = "ID Card",   -- Title of the document
        icon = "IconUser",   -- Representative icon for the document
        bgColor = "#003054", -- Background color (Dark Gray)
        job = false,         -- false or table: if table (e.g., {"police"}), document is shown only for allowed jobs in the context menu
    },
    {
        type = "license_car",
        title = "Drive Card",
        icon = "IconCar",
        bgColor = "#212529",
        job = false,
    },
    {
        type = "license_weapon",
        title = "Weapon License",
        icon = "IconShield",
        bgColor = "#540000",
        job = { "police" },
    },
    {
        type = "license_boat",
        title = "License Boat",
        icon = "IconSpeedboat",
        bgColor = "#11174d",
        job = false,
    },
    -- Add more documents here
}

Config.DocumentZone = {
    ["License ID"] = {
        UsePed       = true,
        OpenCoords   = vector4(-614.8059, -682.4809, 36.2871, 0.5474),
        PedModel     = "a_m_m_business_01",
        Radius       = 50,
        TypeDocument = "license_boat", -- Required same name for the item
        OnlyJob      = false,
        JobName      = "police",
        MinJobGrade  = 2,
    },
    -- zone_name = {                       -- Identifier name of the zone
    --     UsePed       = true,            -- Boolean: if set to `true`, a ped (NPC) will be used in the zone otherwise only a sphere zone
    --     OpenCoords   = vector4(x,y,z,h),-- Coordinates of the zone in vector format (x, y, z, [heading for ped])
    --     PedModel     = "model_name",    -- String: the model of the ped to be used (e.g., "a_m_m_business_01")
    --     Radius       = 50,              -- Radius in which the zone is active (in distance units/meters)
    --     TypeDocument = "license_name",  -- String: the name of the required document (must match the item name)
    --     OnlyJob      = false,           -- Boolean: if set to `true`, only a specific job can interact with the zone
    --     JobName      = "job_name",      -- String: the name of the job that can interact (used only if OnlyJob = true)
    --     MinJobGrade  = 2,               -- Number: minimum job grade required to interact with the zone
    -- }
}


Config.CommandMenu = {
    Command = "documents",
    AllowedJobs = { ["police"] = true, ["unemployed"] = true }
}

Config.GiveCommand = {
    Command = "givecard",
    AllowedGroup = { ["admin"] = true, ["player"] = true }
}

Config.DeathCheck = function()
    local isDead = false
    local ResourceName = "ars_ambulancejob"
    local RESOURCESTATE = GetResourceState(ResourceName)
    if RESOURCESTATE:find("start") then
        isDead = LocalPlayer.state.dead
    else
        isDead = IsEntityDead(cache.ped)
    end

    return isDead
end
