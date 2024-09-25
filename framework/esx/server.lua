local ESX <const> = exports.es_extended:getSharedObject()
local BRIDGE = {}


function BRIDGE.GetPlayerData(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        return xPlayer
    else
        print(('No player data found for the provided source %s.'):format(src))
    end
end

function BRIDGE.GetPlayerName(src)
    local xPlayer = BRIDGE.GetPlayerData(src)
    if not xPlayer then return end
    return {
        Name = xPlayer.get("firstName"),
        Surname = xPlayer.get("lastName")
    }
end

function BRIDGE.GetSex(src)
    local Sex = BRIDGE.GetPlayerData(src).variables.sex
    if Sex then
        return Sex
    end
end

function BRIDGE.GetDob(src)
    local PlayerData = BRIDGE.GetPlayerData(src)
    local Dob = PlayerData?.variables.dateofbirth
    if Dob then
        return Dob
    end
end

function BRIDGE.GetPlayerJob(src)
    local PlayerData = BRIDGE.GetPlayerData(src)
    local Job = PlayerData?.job.name
    if Job then
        return Job
    end
end

function BRIDGE.GetGroup(src)
    local xPlayer = BRIDGE.GetPlayerData(src)
    return xPlayer.getGroup()
end

return BRIDGE
