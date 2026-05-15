local sources = {
    "https://raw.githubusercontent.com/7yvta/miine/main/miine.lua",
    "https://raw.githubusercontent.com/7yvta/miine/refs/heads/main/miine.lua",
}

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

chunk()
