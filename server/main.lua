local GetFolder = require('framework.GetFramework'):new()
BRIDGE = GetFolder:getFrameworkObject(true)

local function loadIdCards()
    local content = LoadResourceFile(GetCurrentResourceName(), "id_cards.json")
    return content and json.decode(content) or {}
end

local function saveIdCards(idCards)
    SaveResourceFile(GetCurrentResourceName(), "id_cards.json", json.encode(idCards, { indent = true }), -1)
end

local function SendWebhook(webhook, title, message, color, imageUrl)
    if webhook == nil or webhook == "" then return end
    PerformHttpRequest(webhook, function(err, text, headers) end, "POST", json.encode({
        username = "Legacy Document System",
        embeds = {
            {
                ["title"] = title,
                ["description"] = message,
                ["color"] = color,
                ["footer"] = {
                    ["text"] = "Legacy Scripts • " .. os.date("%d-%m-%Y %H:%M:%S"),
                    ["icon_url"] =
                    "https://cdn.discordapp.com/attachments/1200838616679727195/1288560479660282030/fallback.png"
                },
                ["image"] = {
                    ["url"] = imageUrl
                },
            }
        }
    }), { ["Content-Type"] = "application/json" })
end



local function CreateNewCard(screen, doctype, playerid)
    if not screen then return end
    local PlayerID = playerid or source
    local TypeDocument = doctype
    local Screen = screen

    local playerData = BRIDGE.GetPlayerName(PlayerID)
    local PlayerName = playerData.Name
    local PlayerSurname = playerData.Surname
    local PlayerSex = BRIDGE.GetSex(PlayerID)
    local PlayerDob = BRIDGE.GetDob(PlayerID)
    local currentDate = os.date("%d-%m-%Y %H:%M")
    local expirationDate = os.date("%d-%m-%Y", os.time() + (365 * 24 * 60 * 60))

    local idCards = loadIdCards()
    local IdCard

    repeat
        IdCard = ("#%s"):format(lib.string.random("A0A0A0", 6))
    until not idCards[IdCard]

    idCards[IdCard] = {
        PlayerName = PlayerName,
        PlayerSurname = PlayerSurname,
        PlayerSex = PlayerSex,
        PlayerDob = PlayerDob,
        DateIssued = currentDate,
        Expiration = expirationDate
    }

    saveIdCards(idCards)

    local metadata = {
        description = ("Released: %s   \nOwner: %s %s"):format(currentDate, PlayerName, PlayerSurname),
        TypeDocument = TypeDocument,
        Screen = Screen,
        PlayerName = PlayerName,
        PlayerSurname = PlayerSurname,
        PlayerSex = PlayerSex,
        IdCard = IdCard,
        PlayerDob = PlayerDob,
        Expiration = expirationDate,
        Released = currentDate,
    }

    local Response = exports.ox_inventory:AddItem(PlayerID, TypeDocument, 1, metadata)
    if not Response then
        Shared.DebugData(("Error adding document to inventory %s"):format(Response))
    end


    local webhook = ServerConfig.WebhookRelease
    local discordMessage = ("Owner: **%s %s**\nID: **%s**\nType: **%s**\nIssued: **%s**\nExpires: **%s**"):format(
        PlayerName, PlayerSurname, IdCard, TypeDocument, currentDate, expirationDate
    )

    SendWebhook(webhook, "Document Created", discordMessage, 3066993, Screen)

    Shared.Notification(Lang:translate("success_title"), Lang:translate("document_created"), "success", playerid)
end



RegisterNetEvent("LGF_DocumentSystem.ObtainNewDocument", function(screen, doctype)
    local PlayerID = source
    if not screen or not doctype then return end
    CreateNewCard(screen, doctype, PlayerID)
end)


RegisterNetEvent("LGF_DocumentSystem.OpenDocsForNearby", function(data, id)
    if not id then return end
    if type(data) ~= "table" then return end
    TriggerClientEvent("LGF_DocumentSystem.OpenDocsForNearby.response", id, data)
end)


RegisterNetEvent("LGF_DocumentSystem.CreateDocument", function(docType, playerId)
    if not docType then return end
    if not playerId or type(playerId) ~= "number" or playerId <= 0 then return end
    TriggerClientEvent("LGF_DocumentSystem.CreateNearbyPhoto", playerId, docType)
end)

lib.callback.register("LGF_DocumentSystem.GetWebhook", function()
    return ServerConfig.Webhook
end)


lib.addCommand(Config.CommandMenu.Command, {
    help = Lang:translate("open_context_menu_help"),
}, function(source, args, raw)
    local PlayerJob = BRIDGE.GetPlayerJob(source)
    print(PlayerJob)
    if not Config.CommandMenu.AllowedJobs[PlayerJob] then
        return Shared.Notification(Lang:translate("error_title"), Lang:translate("unauthorized_open_context"), "error",
            source)
    end
    TriggerClientEvent("LGF_DocumentSystem.OpenContextMenuGiveCard", source)
end)

lib.addCommand(Config.GiveCommand.Command, {
    help = Lang:translate("create_document_help"),
    params = {
        {
            name = 'playerId',
            type = 'playerId',
            help = Lang:translate("target_player_help"),
        },
        {
            name = 'docType',
            type = 'string',
            help = Lang:translate("document_type_help"),
        },
    },

}, function(source, args, raw)
    local playerId = args.playerId
    local docType = args.docType
    local PlayerGroup = BRIDGE.GetGroup(source)

    if not Config.GiveCommand.AllowedGroup[PlayerGroup] then
        return Shared.Notification(Lang:translate("error_title"), Lang:translate("unauthorized_give_card"), "error",
            source)
    end

    TriggerEvent("LGF_DocumentSystem.CreateDocument", docType, playerId)
end)

exports("CreateDocument", function(docType, playerId)
    local success, result = pcall(function()
        return TriggerEvent("LGF_DocumentSystem.CreateDocument", docType, playerId)
    end)

    if not success then
        return false, ("Error in CreateDocument: %s"):format(result)
    end

    return result
end)


exports("GetAllCards", function()
    local Cards = loadIdCards()
    return Cards
end)


lib.versionCheck('Legacy-Scripts/LGF_DocumentSystem')
