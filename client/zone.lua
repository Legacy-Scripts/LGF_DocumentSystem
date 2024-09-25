local DocumentZone = lib.class('DocumentZone')
local ENTITYCREATED = {}

function DocumentZone:constructor(config, zoneName)
    self.openCoords = config.OpenCoords
    self.pedModel = config.PedModel
    self.usePed = config.UsePed
    self.radius = config.Radius
    self.typeDocument = config.TypeDocument
    self.OnlyJob = config.OnlyJob
    self.JobName = config.JobName
    self.MinJobGrade = config.MinJobGrade
    self.ZoneName = zoneName

    if self.usePed then
        self:setupPoint()
    else
        self:TargetZone()
    end
end

function DocumentZone:setupPoint()
    local point = lib.points.new({
        coords = self.openCoords,
        distance = self.radius,
    })

    local instance = self

    function point:onEnter()
        instance:spawnPed()
    end

    function point:onExit()
        if instance.ped then
            DeleteEntity(instance.ped)
            instance.ped = nil
            Shared.DebugData("Ped Deleted", instance.ped)
        end
    end
end

local function getDistanceBetweenCoords(coords1, coords2)
    return math.sqrt((coords1.x - coords2.x) ^ 2 + (coords1.y - coords2.y) ^ 2 + (coords1.z - coords2.z) ^ 2)
end



function DocumentZone:spawnPed()
    lib.requestModel(self.pedModel)

    lib.waitFor(function()
        return HasModelLoaded(self.pedModel)
    end)

    self.ped = CreatePed(0, self.pedModel, self.openCoords.x, self.openCoords.y, self.openCoords.z, self.openCoords.w,
        false, true)

    SetTimeout(500, function()
        SetModelAsNoLongerNeeded(self.pedModel)
        FreezeEntityPosition(self.ped, true)
        SetEntityInvincible(self.ped, true)
        SetBlockingOfNonTemporaryEvents(self.ped, true)
        table.insert(ENTITYCREATED, self.ped)

        exports.ox_target:addLocalEntity(self.ped, {
            {
                icon = 'fa-solid fa-id-card-clip',
                label = Lang:translate("request_document_label"),
                canInteract = function()
                    return not Config.DeathCheck()
                end,
                onSelect = function(data)
                    local PlayerJob = BRIDGE.GetPlayerJob()
                    local PlayerJoBGrade = BRIDGE.GetPlayerJobGrade()
                    print(PlayerJoBGrade, PlayerJob)
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local pedCoords = GetEntityCoords(self.ped)
                    local distance = getDistanceBetweenCoords(playerCoords, pedCoords)
                    local maxDistanceCheck = 4

                    if distance > maxDistanceCheck then
                        print("Probably Cheater.")
                        return
                    end

                    if self.OnlyJob then
                        if PlayerJob == self.JobName and tonumber(PlayerJoBGrade) >= tonumber(self.MinJobGrade) then
                            self:RegisterContext()
                        else
                            print(Lang:translate("insufficient_permissions"))
                        end
                    else
                        self:RegisterContext()
                    end
                end
            }
        })
    end)
end

function DocumentZone:TargetZone()
    exports.ox_target:addSphereZone({
        coords = self.openCoords,
        radius = self.radius,
        drawSprite = true,
        debug = true,
        options = {
            {
                icon = 'fa-solid fa-id-card-clip',
                label = Lang:translate("request_document_label"),
                onSelect = function(data)
                    self:RegisterContext()
                end
            }
        }
    })
end

function DocumentZone:StartPlayerCreateDocs(doctype)
    if Config.ProviderPhoto == "MugShotBase64" then
        local mug = exports["MugShotBase64"]:GetMugShotBase64(cache.ped, true)
        TriggerServerEvent("LGF_DocumentSystem.ObtainNewDocument", mug, doctype)
    elseif Config.ProviderPhoto == "screenshot-basic" then
        local webhook = lib.callback.await("LGF_DocumentSystem.GetWebhook", 200)
        if webhook == "" then
            print(Lang:translate("webhook_empty"))
            return
        end

        UI.CamPhoto()

        SetTimeout(2000, function()
            exports['screenshot-basic']:requestScreenshotUpload(webhook, 'files[]', function(res)
                local resp = json.decode(res)

                if resp and resp.attachments and resp.attachments[1] then
                    local screen = resp.attachments[1].url
                    TriggerServerEvent("LGF_DocumentSystem.ObtainNewDocument", screen, doctype)
                    Wait(1000)
                    UI.CloseCam()
         
                else
                    if UI.GetCam() then
                        UI.CloseCam()
                    end
                end
            end)
        end)
    end
end

function DocumentZone:HasDocumentOfType(typeDocument)
    local PlayerInventory = exports.ox_inventory:GetPlayerItems()

    for var, itemData in pairs(PlayerInventory) do
        local item = itemData
        if item.name == typeDocument then
            return true
        end
    end

    return false
end

exports("HasDocumentOfType", function(typeDocument)
    return DocumentZone:HasDocumentOfType(typeDocument)
end)

function DocumentZone:RegisterContext()
    local descriptionText = Lang:translate("request_document_type") .. " " .. self.ZoneName
    lib.registerContext({
        id = 'LGF_context_docs',
        title = self.ZoneName,
        options = {
            {
                title = Lang:translate("request_document_label"),
                icon = 'fa-solid fa-id-card-clip',
                description = descriptionText,
                onSelect = function()
                    if DocumentZone:HasDocumentOfType(self.typeDocument) then
                        Shared.Notification(Lang:translate("error_title"), Lang:translate("has_already"), "error", nil)
                    else
                        DocumentZone:StartPlayerCreateDocs(self.typeDocument)
                    end
                end
            }
        }
    })

    lib.showContext("LGF_context_docs")
end

for name, zoneConfig in pairs(Config.DocumentZone) do
    DocumentZone:new(zoneConfig, name)
end

RegisterNetEvent("LGF_DocumentSystem.CreateNearbyPhoto", function(doctype)
    DocumentZone:StartPlayerCreateDocs(doctype)
end)

AddEventHandler("onResourceStop", function(res)
    if not res == GetCurrentResourceName() then return end
    for _, entity in ipairs(ENTITYCREATED) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
            Shared.DebugData("Entity Deleted", entity)
        end
    end

    if DoesCamExist(UI.GetCam()) then
        UI.CloseCam()
    end

    ENTITYCREATED = {}
end)


