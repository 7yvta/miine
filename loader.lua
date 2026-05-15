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

local function translateText(input)
    if type(input) ~= "string" or input == "" then
        return input
    end

    local exactTranslations = {
        ["Chọn Công Cụ"] = "Select Tool",
        ["Chọn công cụ bạn muốn sử dụng"] = "Select the tool you want to use",
        ["Chọn công cụ bạn muốn sử dụng."] = "Select the tool you want to use.",
        ["Chọn Vũ Khí"] = "Select Weapon",
        ["Chọn Mục Tiêu"] = "Select Target",
        ["Cài Đặt"] = "Settings",
        ["Làm mới"] = "Refresh",
        ["Bật"] = "ON",
        ["Tắt"] = "OFF",
    }

    local translated = exactTranslations[input] or input
    local replacements = {
        {"Chọn", "Select"},
        {"Công Cụ", "Tool"},
        {"công cụ", "tool"},
        {"bạn muốn sử dụng", "you want to use"},
        {"Pilih", "Select"},
        {"Bahasa", "Language"},
        {"Misi", "Quest"},
        {"Mulai", "Start"},
        {"Berhenti", "Stop"},
        {"Aktif", "ON"},
        {"Nonaktif", "OFF"},
    }

    for _, pair in ipairs(replacements) do
        translated = translated:gsub(pair[1], pair[2])
    end

    local lowered = translated:lower()
    if lowered:find("created by", 1, true) or lowered:find("made by", 1, true) or lowered:find("dev by", 1, true) then
        translated = "Created by 7yvta"
    end

    return translated
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
            root.DescendantAdded:Connect(function(newDescendant)
                patchObjectText(newDescendant)
            end)
        end)
    end

    local servicesToScan = {}
    pcall(function()
        table.insert(servicesToScan, game:GetService("CoreGui"))
    end)
    pcall(function()
        table.insert(servicesToScan, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    end)
    pcall(function()
        if gethui then
            table.insert(servicesToScan, gethui())
        end
    end)

    for _, root in ipairs(servicesToScan) do
        patchAllFrom(root)
    end
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

local chunk, compileErr = loadstring(content)
if not chunk then
    error("Loader failed: compile error - " .. tostring(compileErr))
end

forceEnglish()
chunk()
pcall(addCreatorTag)
pcall(patchVisibleUi)
