local sources = {
    "https://raw.githubusercontent.com/7yvta/miine/main/miine.lua",
    "https://raw.githubusercontent.com/7yvta/miine/refs/heads/main/miine.lua",
}

local function forceEnglish()
    local ok, env = pcall(function()
        return (getgenv and getgenv()) or _G
    end)
    if ok and type(env) == "table" then
        env.Language = "English"
        env.Lang = "English"
        env.SelectedLanguage = "English"
        env.Locale = "en"
        env.LocaleId = "en-us"
        env.UseEnglish = true
        env.AutoDetectLanguage = false
    end

    if type(shared) == "table" then
        shared.Language = "English"
        shared.Lang = "English"
        shared.SelectedLanguage = "English"
        shared.Locale = "en"
        shared.LocaleId = "en-us"
        shared.UseEnglish = true
        shared.AutoDetectLanguage = false
    end
end

local content
for _, url in ipairs(sources) do
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(result) == "string" and #result > 0 then
        content = result
        break
    end
end

if not content then
    error("Loader failed: could not fetch miine.lua")
end

local chunk, compileErr = loadstring(content)
if not chunk then
    error("Loader failed: compile error - " .. tostring(compileErr))
end

forceEnglish()
chunk()
