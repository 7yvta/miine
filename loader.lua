local sources = {
    "https://raw.githubusercontent.com/7yvta/miine/main/miine.lua",
    "https://raw.githubusercontent.com/7yvta/miine/refs/heads/main/miine.lua",
}

local function safeWait(seconds)
    if task and type(task.wait) == "function" then
        return task.wait(seconds)
    end
    return wait(seconds)
end

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

local function normalizeAscii(input)
    local normalized = tostring(input or "")
    normalized = normalized:gsub("[\128-\255]", "")
    normalized = normalized:gsub("[%p]", " ")
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:gsub("^%s+", "")
    normalized = normalized:gsub("%s+$", "")
    return normalized:lower()
end

local function translateText(input)
    if type(input) ~= "string" or input == "" then
        return input
    end

    local normalized = normalizeAscii(input)
    local exactMap = {
        ["chn cng c"] = "Select Tool",
        ["chon cong cu"] = "Select Tool",
        ["chn v kh"] = "Select Weapon",
        ["chon vu khi"] = "Select Weapon",
        ["chn mc tiu"] = "Select Target",
        ["chon muc tieu"] = "Select Target",
        ["ci t"] = "Settings",
        ["cai dat"] = "Settings",
        ["lm mi"] = "Refresh",
        ["lam moi"] = "Refresh",
        ["bt"] = "ON",
        ["bat"] = "ON",
        ["tt"] = "OFF",
        ["tat"] = "OFF",
        ["pilih"] = "Select",
        ["bahasa"] = "Language",
        ["misi"] = "Quest",
        ["mulai"] = "Start",
        ["berhenti"] = "Stop",
        ["aktif"] = "ON",
        ["nonaktif"] = "OFF",
    }

    if exactMap[normalized] then
        return exactMap[normalized]
    end

    if normalized:find("bn mun s dng", 1, true) or normalized:find("ban muon su dung", 1, true) then
        return "Select the tool you want to use"
    end

    if normalized:find("chn cng c", 1, true) or normalized:find("chon cong cu", 1, true) then
        return "Select Tool"
    end
    if normalized:find("chn v kh", 1, true) or normalized:find("chon vu khi", 1, true) then
        return "Select Weapon"
    end
    if normalized:find("chn mc tiu", 1, true) or normalized:find("chon muc tieu", 1, true) then
        return "Select Target"
    end

    local translated = input
    local simpleReplacements = {
        {"Pilih", "Select"},
        {"Bahasa", "Language"},
        {"Misi", "Quest"},
        {"Mulai", "Start"},
        {"Berhenti", "Stop"},
        {"Aktif", "ON"},
        {"Nonaktif", "OFF"},
    }
    for _, pair in ipairs(simpleReplacements) do
        translated = translated:gsub(pair[1], pair[2])
    end

    local lowered = translated:lower()
    if lowered:find("created by", 1, true) or lowered:find("made by", 1, true) or lowered:find("dev by", 1, true) then
        return "Created by 7yvta"
    end

    return translated
end

local function translateSourceContent(source)
    if type(source) ~= "string" or source == "" then
        return source
    end

    local replacements = {
        {"Chọn Công Cụ", "Select Tool"},
        {"Chọn công cụ bạn muốn sử dụng", "Select the tool you want to use"},
        {"Chọn công cụ bạn muốn sử dụng.", "Select the tool you want to use."},
        {"Chọn Vũ Khí", "Select Weapon"},
        {"Chọn Mục Tiêu", "Select Target"},
        {"Cài Đặt", "Settings"},
        {"Làm mới", "Refresh"},
        {"Pilih", "Select"},
        {"Bahasa", "Language"},
        {"Misi", "Quest"},
        {"Mulai", "Start"},
        {"Berhenti", "Stop"},
    }

    local patched = source
    for _, pair in ipairs(replacements) do
        patched = patched:gsub(pair[1], pair[2])
    end
    return patched
end

local function installPropertyHook()
    local ok = false
    pcall(function()
        if type(hookmetamethod) ~= "function" or type(newcclosure) ~= "function" then
            return
        end

        local previous
        previous = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
            if type(key) == "string" and type(value) == "string" then
                local lowered = key:lower()
                if lowered == "text" or lowered == "placeholdertext" then
                    value = translateText(value)
                end
            end
            return previous(self, key, value)
        end))
        ok = true
    end)
    return ok
end

local function patchVisibleUi()
    local function patchObjectText(object)
        if not object then
            return
        end
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            pcall(function()
                local current = object.Text
                local updated = translateText(current)
                if updated ~= current then
                    object.Text = updated
                end
            end)

            pcall(function()
                local placeholder = object.PlaceholderText
                if type(placeholder) == "string" and placeholder ~= "" then
                    local updated = translateText(placeholder)
                    if updated ~= placeholder then
                        object.PlaceholderText = updated
                    end
                end
            end)

            pcall(function()
                if object:GetAttribute("YvtaLangHook") then
                    return
                end
                object:SetAttribute("YvtaLangHook", true)
                object:GetPropertyChangedSignal("Text"):Connect(function()
                    pcall(function()
                        local latest = object.Text
                        local patched = translateText(latest)
                        if patched ~= latest then
                            object.Text = patched
                        end
                    end)
                end)
            end)

            pcall(function()
                if object:GetAttribute("YvtaPlaceholderHook") then
                    return
                end
                object:SetAttribute("YvtaPlaceholderHook", true)
                object:GetPropertyChangedSignal("PlaceholderText"):Connect(function()
                    pcall(function()
                        local latest = object.PlaceholderText
                        local patched = translateText(latest)
                        if patched ~= latest then
                            object.PlaceholderText = patched
                        end
                    end)
                end)
            end)
        end
    end

    local function patchAllFrom(root)
        if not root then
            return
        end
        for _, descendant in ipairs(root:GetDescendants()) do
            patchObjectText(descendant)
        end
        pcall(function()
            if root:GetAttribute("YvtaDescendantHook") then
                return
            end
            root:SetAttribute("YvtaDescendantHook", true)
            root.DescendantAdded:Connect(function(newDescendant)
                patchObjectText(newDescendant)
            end)
        end)
    end

    local roots = {}
    pcall(function()
        table.insert(roots, game:GetService("CoreGui"))
    end)
    pcall(function()
        table.insert(roots, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    end)
    pcall(function()
        if gethui then
            table.insert(roots, gethui())
        end
    end)

    for _, root in ipairs(roots) do
        patchAllFrom(root)
    end

    pcall(function()
        if task and type(task.spawn) == "function" then
            task.spawn(function()
                for _ = 1, 240 do
                    for _, root in ipairs(roots) do
                        patchAllFrom(root)
                    end
                    safeWait(1)
                end
            end)
        else
            spawn(function()
                for _ = 1, 240 do
                    for _, root in ipairs(roots) do
                        patchAllFrom(root)
                    end
                    safeWait(1)
                end
            end)
        end
    end)
end

local function addCreatorTag()
    local parentGui
    pcall(function()
        if gethui then
            parentGui = gethui()
        end
    end)
    if not parentGui then
        pcall(function()
            parentGui = game:GetService("CoreGui")
        end)
    end
    if not parentGui then
        return
    end

    local existing = parentGui:FindFirstChild("YvtaCreatorTag")
    if existing then
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YvtaCreatorTag"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local label = Instance.new("TextLabel")
    label.Name = "CreatorText"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 220, 0, 24)
    label.Position = UDim2.new(1, -230, 0, 8)
    label.Text = "Created by 7yvta"
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.ZIndex = 1000
    label.Parent = screenGui

    screenGui.Parent = parentGui
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

content = translateSourceContent(content)

local chunk, compileErr = loadstring(content)
if not chunk then
    error("Loader failed: compile error - " .. tostring(compileErr))
end

forceEnglish()
pcall(installPropertyHook)
chunk()
pcall(addCreatorTag)
pcall(patchVisibleUi)
