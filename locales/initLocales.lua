Locales = {}
_G.LANG = {}

function LANG.CoreLang(key)
    local locale = Locales[LANG.GetCurrentLocale()]
    return locale and locale[key] or ('[Translation missing for "%s"]'):format(key)
end

function LANG.GetCurrentLocale()
    return Config.Locales
end

function LANG.LoadLocales()
    local language = LANG.GetCurrentLocale()

    local file = LoadResourceFile(GetCurrentResourceName(), ("locales/Lang/%s.lua"):format(language))
 
    if not file then
        print(string.format("[^4WARNING^7] Language [^4%s^7] not found in locales/lang/.", language))
        file = LoadResourceFile(GetCurrentResourceName(), "locales/Lang/en.lua")
    else
        print(string.format("[^2INFO^7] Loaded language [^2%s^7]", language))
    end

    assert(load(file))()
end

Citizen.CreateThreadNow(function()
    LANG.LoadLocales()
end)
