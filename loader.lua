--[[
    Pandemonium Loader
    Obfuscated entry point – avoids static detection.
]]

local function d(s) return (s:gsub('..', function(c) return string.char(tonumber(c, 16)) end)) end

local r = string.char(math.random(97,122)) .. string.char(math.random(97,122)) .. tostring(math.random(1000,9999))

local _G = getfenv and getfenv() or getrenv and getrenv() or _G
local _R = _G

local function g(u)
    local b = _R.game:HttpGet(u)
    return b
end

local u1 = d("68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f69736861616e7375636b7361746c6966652f50616e64656d6f6e69756d2d4c6f616465722f6d61696e2f")
local u2 = d("687562732f6d61696e2e6c7561")
local fullUrl = u1 .. u2

local success, hub = pcall(function()
    return loadstring(g(fullUrl))
end)

if success and hub then
    local execSuccess, err = pcall(hub)
    if not execSuccess then
        _R.warn("Pandemonium: " .. tostring(err))
        _R.game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Pandemonium",
            Text = "Execution error. See console.",
            Duration = 3
        })
    end
else
    _R.warn("Pandemonium: Failed to fetch hub.")
    _R.game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Pandemonium Error",
        Text = "Loader failed. Check your internet or executor.",
        Duration = 4
    })
end