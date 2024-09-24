local Qbox = exports['qb-core']:GetCoreObject()
if not Qbox then return end
local BRIDGE = {}


function BRIDGE.GetPlayerJob()
    local PlayerData = exports.qbx_core:GetPlayerData()
    if not PlayerData then return end
    local JobName = PlayerData.job.name
    if JobName then return JobName end
end

function BRIDGE.GetPlayerJobGrade()
    local PlayerData = exports.qbx_core:GetPlayerData()
    print(json.encode(PlayerData, { indent = true }))
    if not PlayerData then return end
    local JobGrade = PlayerData.job.grade
    if JobGrade then return JobGrade end
end

return BRIDGE
