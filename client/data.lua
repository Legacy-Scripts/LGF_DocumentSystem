local GetFolder = require('framework.GetFramework'):new()
BRIDGE = GetFolder:getFrameworkObject(false)


exports('manageDocument', function(data, slot)
    exports.ox_inventory:useItem(data, function(itemData)
        if exports["LGF_DocumentSystem"]:GetStateDocumentUI() then print("UI is Already Opened") return end

        local playerData = {
            Name = itemData.metadata.PlayerName,
            Surname = itemData.metadata.PlayerSurname,
            Sex = itemData.metadata.PlayerSex,
            Dob = itemData.metadata.PlayerDob,
            Avatar = itemData.metadata.Screen,
            IdCard = itemData.metadata.IdCard,
            Expiration = itemData.metadata.Expiration,
            TypeDocs = itemData.metadata.TypeDocument,
            Released = itemData.metadata.Released,
        }

        local playerCoords = cache.coords
        local nearbyPlayers = lib.getNearbyPlayers(playerCoords, 5.0, false)

        if #nearbyPlayers == 0 then  UI.OpenToggleDocs("openDocument", true, playerData) return   end

        local options = { { label = (" Name %s | ID %s"):format(GetPlayerName(cache.playerId), cache.serverId), value = "me", } }

        for _, nearbyPlayer in ipairs(nearbyPlayers) do
            local PlayerID = tostring(GetPlayerServerId(nearbyPlayer.id))

            table.insert(options, {
                label = (" Name %s | ID %s"):format(GetPlayerName(nearbyPlayer.id), PlayerID),
                value = PlayerID,
            })
        end

        local input = lib.inputDialog('Select Players', {
            {
                type = 'multi-select',
                label = 'Nearby Players',
                options = options,
                required = false,
                description = 'Select the players to you want to open the documents.'
            }
        })

        if not input then return end

        for _, playerId in ipairs(input[1]) do
            if playerId == "me" then
                UI.OpenToggleDocs("openDocument", true, playerData)
            else
                TriggerServerEvent("LGF_DocumentSystem.OpenDocsForNearby", playerData, tonumber(playerId))
            end
        end
    end)
    SetTimeout(5000, function()
        UI.OpenToggleDocs("openDocument", false, {})
    end)
end)

RegisterNetEvent("LGF_DocumentSystem.OpenDocsForNearby.response", function(data)
    assert(data and type(data) == "table", "Data is either nil or not a table")
    UI.OpenToggleDocs("openDocument", true, data)
    SetTimeout(5000, function()
        UI.OpenToggleDocs("openDocument", false, {})
    end)
end)



local function showDocumentOptions()
    lib.registerContext({
        id = 'create_document',
        title = 'Document Options',
        options = {
            {
                title = 'Create New Document',
                description = 'Create a new document for a nearby player.',
                icon = 'plus',
                disabled = false,
                onSelect = createNewDocument
            },
        }
    })
    lib.showContext('create_document')
end

local function InputState(documentOptions, playerOptions)
    local input = lib.inputDialog('Dialog title', {
        {
            type = 'select',
            label = 'Document Type',
            options = documentOptions,
            required = true,
            description = 'Select the type of document.',
            icon = 'file-alt'
        },
        {
            type = 'select',
            label = 'Select Nearby Player',
            options = playerOptions,
            required = true,
            description = 'Choose a player for the document.',
            icon = 'users'
        },
    })
    if not input then return end
    local docType = input[1]
    local playerId = input[2]
    TriggerServerEvent("LGF_DocumentSystem.CreateDocument", docType, playerId)
end

function createNewDocument()
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), 5.0, true)
    local playerOptions = {}
    local PlayerJob = BRIDGE.GetPlayerJob()


    for _, nearbyPlayer in ipairs(nearbyPlayers) do
        local playerId = GetPlayerServerId(nearbyPlayer.id)
        table.insert(playerOptions, {
            label = ("Name: %s | ID: %s"):format(GetPlayerName(nearbyPlayer.id), playerId),
            value = playerId
        })
    end

    local documentOptions = {}
    for i = 1, #Config.AvailableDocuments do
        local document = Config.AvailableDocuments[i]

        print(PlayerJob)
        if not document.job or (type(document.job) == "table" and table.includes(document.job, PlayerJob)) then
            table.insert(documentOptions, {
                label = document.title,
                value = document.type,
                icon = document.icon
            })
        end
    end

    InputState(documentOptions, playerOptions)
end

function table.includes(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

RegisterNetEvent("LGF_DocumentSystem.OpenContextMenuGiveCard", function()
    showDocumentOptions()
end)
