local Ox = require '@ox_core/lib/init'
if not Ox then return end
local BRIDGE = {}

function BRIDGE.GetPlayerName(src)
    local OxPlayer = Ox.GetPlayer(src)
    if not OxPlayer then return end
    return {
        Name = OxPlayer.get('firstName'),
        Surname = OxPlayer.get('lastName')
    }
end

function BRIDGE.GetSex(src)
    local OxPlayer = Ox.GetPlayer(src)
    if not OxPlayer then return end
    return OxPlayer.get('gender')
end

function BRIDGE.GetDob(src)
    local OxPlayer = Ox.GetPlayer(src)
    if not OxPlayer then return end
    local Dob = OxPlayer.get('dateOfBirth')
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

function BRIDGE.GetPlayerJob(src)
    local OxPlayer = Ox.GetPlayer(src)
    if not OxPlayer then return end
    local Job = OxPlayer.get('activeGroup')
    if Job then
    return Job
    end
end

function BRIDGE.GetGroup(src)
    return isPlayerAllowed(src)
end

return BRIDGE
