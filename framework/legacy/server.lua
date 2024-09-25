local Legacy = exports.LEGACYCORE:GetCoreData()
if not Legacy then return end
local BRIDGE = {}

function BRIDGE.GetPlayerData(src)
    local LegacyPlayer = Legacy.DATA:GetPlayerDataBySlot(src)
    if not LegacyPlayer then return end
    return LegacyPlayer
end

function BRIDGE.GetPlayerName(src)
    local playerName = Legacy.DATA:GetName(src)

    if playerName then
        local firstName, lastName = playerName:match("([^%s]+)%s+(.+)")
        return {
            Name = firstName,
            Surname = lastName
        }
    end

    return {
        Name = "",
        Surname = ""
    }
end

function BRIDGE.GetSex(src)
    local Sex = Legacy.DATA:GetGender(src)
    if Sex then
        return Sex
    end
end

function BRIDGE.GetDob(src)
    local PlayerData = BRIDGE.GetPlayerData(src)
    local Dob = PlayerData?.dob
    if Dob then
        return Dob
    end
end

function BRIDGE.GetPlayerJob(src)
    local PlayerData = BRIDGE.GetPlayerData(src)
    local Dob = PlayerData?.JobName
    if Dob then
        return Dob
    end
end

function BRIDGE.GetGroup(src)
    return Legacy.DATA:GetPlayerGroup(src)
end

return BRIDGE
