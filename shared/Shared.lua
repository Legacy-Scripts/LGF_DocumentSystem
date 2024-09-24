Shared = {}



function Shared.DebugData(...)
    if not Config.DebugEnabled then return end
    print("[^3DEBUG^7]" .. table.concat({ ... }, " "))
end
