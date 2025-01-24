local Ox = require '@ox_core/lib/init'
if not Ox then return end
local BRIDGE = {}


function BRIDGE.GetPlayerJob()
    local OxPlayer = Ox.GetPlayer()
    if not OxPlayer then return end
    local JobName = OxPlayer.get('activeGroup')
    if JobName then return JobName end
end

function BRIDGE.GetPlayerJobGrade()
    local OxPlayer = Ox.GetPlayer()
    if not OxPlayer then return end
    local activeGroup = OxPlayer.get('activeGroup')
    if not activeGroup then return end
    local JobGrade = OxPlayer.getGroup(activeGroup)
    if JobGrade then return JobGrade end
end

return BRIDGE
