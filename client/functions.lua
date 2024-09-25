UI = {}
local State = LocalPlayer.state
State.DocumentOpened = false
local camera

function UI.OpenToggleDocs(action, state, data)
    print(state)
    SetNuiFocusKeepInput(state)
    State.DocumentOpened = state
    SendNUIMessage({ action = action, visible = state, DocsData = data })
end

if not Config.EnableAutoClose then
    lib.addKeybind({
        name = 'close_document_press',
        description = 'press Backspace to close Document',
        defaultKey = Config.KeyCloseDocument,
        onReleased = function(self)
            UI.OpenToggleDocs("openDocument", false, {})
        end
    })
end


function UI.CamPhoto()
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0, 0.7, 0)
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1750, 1, 0)
    SetCamCoord(camera, coords.x, coords.y, coords.z + 0.65)
    SetCamFov(camera, 38.0)
    SetCamRot(camera, 0.0, 0.0, GetEntityHeading(cache.ped) + 180)
    PointCamAtPedBone(camera, cache.ped, 31086, 0.0, 0.0, 0.03, 1)

    local coords = GetCamCoord(camera)
    TaskLookAtCoord(cache.ped, coords.x, coords.y, coords.z, -1, 1, 1)
    SetCamUseShallowDofMode(camera, true)
    SetCamNearDof(camera, 0.5)
    SetCamFarDof(camera, 12.0)
    SetCamDofStrength(camera, 1.0)
    SetCamDofMaxNearInFocusDistance(camera, 1.0)
    CreateThread(function()
        repeat
            SetUseHiDof()
            Wait(0)
        until not DoesCamExist(camera)
    end)
end

function UI.CloseCam()
    RenderScriptCams(false, true, 1750, 1, 0)
    DestroyCam(camera, false)
    camera = nil
end

function UI.GetCam()
    return camera
end

RegisterNUICallback("LGF_DocumentSystem.GetDocumentAvailable", function(data, callback)
    callback(Config.AvailableDocuments)
end)

exports("GetStateDocumentUI", function()
    return State.DocumentOpened
end)

exports("OpenDocument", function(state, data)
    return UI.OpenToggleDocs("openDocument", state, data)
end)



