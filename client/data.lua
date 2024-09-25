local GetFolder    = require('framework.GetFramework'):new()
BRIDGE             = GetFolder:getFrameworkObject(false)
local SHOWCARDTIME = Config.AutoCloseTime


function StartAnim(dict, anim, prop)
    lib.requestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end

    local EntityCoords = cache.coords
    local Entity = cache.ped

    CARDPROP = CreateObject(joaat(prop), EntityCoords.x, EntityCoords.y, EntityCoords.z + 0.2, true, true, true)
    SetEntityCollision(CARDPROP, true, true)
    TaskPlayAnim(cache.ped, dict, anim, 3.0, -1, -1, 50, -1, false, false, false)
    AttachEntityToEntity(CARDPROP, Entity, GetPedBoneIndex(Entity, 57005), 0.1000, 0.0200, -0.0300, -90.000, 170.000, 78.999, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(CARDPROP)

    SetTimeout(SHOWCARDTIME, function()
        ClearPedTasks(Entity)
        DeleteEntity(CARDPROP)
        RemoveAnimDict(dict)
    end)
end

exports('manageDocument', function(data, slot)
    exports.ox_inventory:useItem(data, function(itemData)
        if exports["LGF_DocumentSystem"]:GetStateDocumentUI() then
            print(Lang:translate("ui_already_opened"))
            return
        end

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

        if #nearbyPlayers == 0 then
            UI.OpenToggleDocs("openDocument", true, playerData)
            StartAnim('paper_1_rcm_alt1-9', 'player_one_dual-9', "prop_franklin_dl")
            return
        end

        local options = { { label = Lang:translate("option_me", GetPlayerName(cache.playerId), cache.serverId), value = "me" } }

        for _, nearbyPlayer in ipairs(nearbyPlayers) do
            local PlayerID = tostring(GetPlayerServerId(nearbyPlayer.id))
            table.insert(options, {
                label = Lang:translate("option_nearby_player", GetPlayerName(nearbyPlayer.id), PlayerID),
                value = PlayerID,
            })
        end


        local input = lib.inputDialog(Lang:translate("select_players_title"), {
            {
                type = 'multi-select',
                label = Lang:translate("nearby_players_label"),
                options = options,
                required = false,
                description = Lang:translate("nearby_players_description"),
            }
        })

        if not input then return end

        for _, playerId in ipairs(input[1]) do
            if playerId == "me" then
                UI.OpenToggleDocs("openDocument", true, playerData)
                StartAnim('paper_1_rcm_alt1-9', 'player_one_dual-9', "prop_franklin_dl")
            else
                TriggerServerEvent("LGF_DocumentSystem.OpenDocsForNearby", playerData, tonumber(playerId))
            end
        end
    end)


    if Config.EnableAutoClose then
        SetTimeout(SHOWCARDTIME, function()
            UI.OpenToggleDocs("openDocument", false, {})
        end)
    end
end)


RegisterNetEvent("LGF_DocumentSystem.OpenDocsForNearby.response", function(data)
    assert(data and type(data) == "table", "Data is either nil or not a table")
    UI.OpenToggleDocs("openDocument", true, data)
    if Config.EnableAutoClose then
        SetTimeout(SHOWCARDTIME, function()
            UI.OpenToggleDocs("openDocument", false, {})
        end)
    end
end)


local function showDocumentOptions()
    lib.registerContext({
        id = 'create_document',
        title = Lang:translate("document_options_title"),
        options = {
            {
                title = Lang:translate("create_new_document_title"),
                description = Lang:translate("create_new_document_description"),
                icon = 'plus',
                disabled = false,
                onSelect = createNewDocument
            },
        }
    })
    lib.showContext('create_document')
end

local function InputState(documentOptions, playerOptions)
    local input = lib.inputDialog(Lang:translate("dialog_title"), {
        {
            type = 'select',
            label = Lang:translate("document_type_label"),
            options = documentOptions,
            required = true,
            description = Lang:translate("document_type_description"),
            icon = 'file-alt'
        },
        {
            type = 'select',
            label = Lang:translate("select_nearby_player_label"),
            options = playerOptions,
            required = true,
            description = Lang:translate("select_nearby_player_description"),
            icon = 'users'
        },
    })
    if not input then return end
    local docType = input[1]
    local playerId = input[2]
    TriggerServerEvent("LGF_DocumentSystem.CreateDocument", docType, playerId)
end

function createNewDocument()
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, true)
    local playerOptions = {}
    local PlayerJob = BRIDGE.GetPlayerJob()

    for _, nearbyPlayer in ipairs(nearbyPlayers) do
        local playerId = GetPlayerServerId(nearbyPlayer.id)
        table.insert(playerOptions, {
            label = GetPlayerName(nearbyPlayer.id),
            value = playerId
        })
    end

    local documentOptions = {}
    for i = 1, #Config.AvailableDocuments do
        local document = Config.AvailableDocuments[i]

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
