local Legacy = exports.LEGACYCORE:GetCoreData()
if not Legacy then return end
local BRIDGE = {}



function BRIDGE.GetPlayerJob()
    local promise, error = Legacy.DATA:GetPlayerMetadata("JobName")
    if not promise then
        print(error)
        return
    end

    return promise
end

function BRIDGE.GetPlayerJobGrade()
    local promise, error = Legacy.DATA:GetPlayerMetadata("JobGrade")
    if not promise then
        print(error)
        return
    end

    return promise
end

return BRIDGE
