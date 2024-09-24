local ESX = exports.es_extended:getSharedObject()
if not ESX then return end

local BRIDGE = {}

function BRIDGE.GetClientData()
    local xPlayer = ESX.GetPlayerData()
    if not xPlayer then return end
    return xPlayer
end

function BRIDGE.GetPlayerJob()
    local xPlayer = BRIDGE.GetClientData()
    if not xPlayer then return end
    local JobName = xPlayer.job.name
    if JobName then return JobName end
end

function BRIDGE.GetPlayerJobGrade()
    local xPlayer = BRIDGE.GetClientData()
    if not xPlayer then return end
    local JobGrade = xPlayer.job.grade
    if JobGrade then return JobGrade end
end

return BRIDGE
