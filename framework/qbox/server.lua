local Qbox = exports['qb-core']:GetCoreObject()
if not Qbox then return end
local BRIDGE = {}

function BRIDGE.GetPlayerData(src)
    local PlayerData = exports.qbx_core:GetPlayer(src).PlayerData
    if PlayerData then
        return PlayerData
    else
        print(('No player data found for the provided source %s.'):format(src))
    end
end

function BRIDGE.GetPlayerName(src)
    local qboxPlayer = BRIDGE.GetPlayerData(src)
    if not qboxPlayer then return end
    return {
        Name = qboxPlayer.charinfo.firstname,
        Surname = qboxPlayer.charinfo.lastname
    }
end

function BRIDGE.GetSex(src)
    local qboxPlayer = BRIDGE.GetPlayerData(src)
    if qboxPlayer then
        return qboxPlayer.charinfo.gender
    end
end

function BRIDGE.GetDob(src)
    local qboxPlayer = BRIDGE.GetPlayerData(src)
    local Dob = qboxPlayer?.charinfo.birthdate
    if Dob then
        return Dob
    end
end

local function isPlayerAllowed(src)
    for k, v in pairs(Config.GiveCommand.AllowedGroup) do
        if v == true then
            if IsPlayerAceAllowed(src, k) then
                return k
            end
        end
    end
    return "user"
end

function BRIDGE.GetGroup(src)
    return isPlayerAllowed(src)
end

return BRIDGE
