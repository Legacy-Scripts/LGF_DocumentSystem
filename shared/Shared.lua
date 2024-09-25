Shared = {}



function Shared.DebugData(...)
    if not Config.DebugEnabled then return end
    print("[^3DEBUG^7]" .. table.concat({ ... }, " "))
end

function Shared.Notification(title, message, type, source)
    if not IsDuplicityVersion() then
        lib.notify({
            title = title,
            description = message,
            type = type
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = message,
            type = type
        })
    end
end
