Lang = {}


function Lang:loadLocales()
    local localeFile = string.format('locales/%s.json', Config.Locales)
    local fileContent = LoadResourceFile("LGF_DocumentSystem", localeFile)

    if fileContent then
        local success, data = pcall(json.decode, fileContent)
        if success then
            self.translations = data
        else
            Shared.DebugData(string.format("Error decoding JSON from file '%s': %s", localeFile, data))
            self.translations = {}
        end
    else
        Shared.DebugData(string.format("Locale file not found: %s", localeFile))
        self.translations = {}
    end
end

function Lang:translate(key, ...)
    if self.translations and self.translations[key] then
        return string.format(self.translations[key], ...)
    else
        Shared.DebugData(string.format("Translation missing for key: %s", key))
        return key
    end
end

function Shared.GetLocale()
    return Lang.translations
end
