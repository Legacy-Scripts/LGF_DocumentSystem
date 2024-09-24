local DocumentZone = lib.class('DocumentZone')
local ENTITYCREATED = {}


function DocumentZone:constructor(config)
    self.openCoords = config.OpenCoords
    self.pedModel = config.PedModel
    self.usePed = config.UsePed
    self.radius = config.Radius
    self.typeDocument = config.TypeDocument
    self.OnlyJob = config.OnlyJob
    self.JobName = config.JobName
    self.MinJobGrade = config.MinJobGrade


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

    SetTimeout(700, function()
        SetModelAsNoLongerNeeded(self.pedModel)
        FreezeEntityPosition(self.ped, true)
        SetEntityInvincible(self.ped, true)
        SetBlockingOfNonTemporaryEvents(self.ped, true)
        table.insert(ENTITYCREATED, self.ped)

        exports.ox_target:addLocalEntity(self.ped, {
            {
                icon = 'fa-solid fa-id-card-clip',
                label = 'Request Document',
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
                            print("Insufficient permissions to request document.")
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
                label = 'Request Document',
                onSelect = function(data)
                    self:RegisterContext()
                end
            }
        }
    })
end

function DocumentZone:StartPlayerCreateDocs(doctype)
    local webhook = lib.callback.await("LGF_DocumentSystem.GetWebhook", 200)
    print(webhook)
    if webhook == "" then
        print("Webhook Is Empty")
        return
    end
    UI.CamPhoto()
    SetTimeout(2000, function()
        exports['screenshot-basic']:requestScreenshotUpload(webhook, 'files[]', function(res)
            local resp = json.decode(res)
            if resp and resp.attachments and resp.attachments[1] then
                local screen = resp.attachments[1].url
                local documentType = doctype
                TriggerServerEvent("LGF_DocumentSystem.ObtainNewDocument", screen, documentType)
                Wait(1000)
                UI.CloseCam()
            else
                if UI.GetCam() then
                    UI.CloseCam()
                end
            end
        end
        )
    end)
end

function DocumentZone:RegisterContext()
    local descriptionText = ("Request Document Type (%s)"):format(self.typeDocument)
    lib.registerContext({
        id = 'LGF_context_docs',
        title = 'Request Documentation',
        options = {
            {
                title = 'Request Document',
                icon = 'fa-solid fa-id-card-clip',
                description = descriptionText,
                onSelect = function()
                    print(self.typeDocument)
                    DocumentZone:StartPlayerCreateDocs(self.typeDocument)
                end
            }
        }
    })

    lib.showContext("LGF_context_docs")
end

for name, zoneConfig in pairs(Config.DocumentZone) do
    DocumentZone:new(zoneConfig)
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
