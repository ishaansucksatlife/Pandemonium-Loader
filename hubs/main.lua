local repoOwner = "ishaansucksatlife"
local repoName = "Pandemonium-Loader"
local scriptsPath = "scripts"
local apiUrl = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName .. "/contents/" .. scriptsPath
local rawBase = "https://raw.githubusercontent.com/" .. repoOwner .. "/" .. repoName .. "/main/" .. scriptsPath .. "/"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PandemoniumHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

local function fetch(url)
    local success, result = pcall(game.HttpGet, game, url)
    if success then return result end
    return nil
end

local colors = {
    bg = Color3.fromRGB(8, 8, 20),
    card = Color3.fromRGB(12, 12, 28),
    accent = Color3.fromRGB(0, 255, 255),
    accentDark = Color3.fromRGB(0, 180, 180),
    text = Color3.fromRGB(200, 200, 255),
    textDim = Color3.fromRGB(120, 120, 160),
    error = Color3.fromRGB(255, 50, 100)
}

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
mainFrame.BackgroundColor3 = colors.bg
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local shadow = Instance.new("ImageLabel")
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = colors.accent
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0
shadow.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = colors.card
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PANDEMONIUM HUB"
titleLabel.TextColor3 = colors.accent
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = colors.card
closeBtn.Text = "X"
closeBtn.TextColor3 = colors.textDim
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 0, 35)
searchBox.Position = UDim2.new(0, 20, 0, 55)
searchBox.BackgroundColor3 = colors.card
searchBox.TextColor3 = colors.text
searchBox.PlaceholderText = "🔍 Search scripts..."
searchBox.PlaceholderColor3 = colors.textDim
searchBox.Text = ""
searchBox.TextSize = 16
searchBox.Font = Enum.Font.Gotham
searchBox.BorderSizePixel = 0
searchBox.ClipsDescendants = true
searchBox.Parent = mainFrame

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 35, 0, 35)
refreshBtn.Position = UDim2.new(1, -55, 0, 55)
refreshBtn.BackgroundColor3 = colors.card
refreshBtn.Text = "⟳"
refreshBtn.TextColor3 = colors.accent
refreshBtn.TextSize = 20
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.BorderSizePixel = 0
refreshBtn.Parent = mainFrame

local scriptContainer = Instance.new("ScrollingFrame")
scriptContainer.Size = UDim2.new(1, -20, 1, -120)
scriptContainer.Position = UDim2.new(0, 10, 0, 100)
scriptContainer.BackgroundTransparency = 1
scriptContainer.BorderSizePixel = 0
scriptContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptContainer.ScrollBarThickness = 6
scriptContainer.ScrollBarImageColor3 = colors.accent
scriptContainer.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scriptContainer

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(1, 0, 0, 40)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "Fetching script list from GitHub..."
loadingLabel.TextColor3 = colors.textDim
loadingLabel.TextSize = 16
loadingLabel.Font = Enum.Font.Gotham
loadingLabel.Visible = true
loadingLabel.Parent = scriptContainer

local noScriptsLabel = Instance.new("TextLabel")
noScriptsLabel.Size = UDim2.new(1, 0, 0, 40)
noScriptsLabel.BackgroundTransparency = 1
noScriptsLabel.Text = "⚠ No .lua scripts found in the /scripts/ folder"
noScriptsLabel.TextColor3 = colors.error
noScriptsLabel.TextSize = 14
noScriptsLabel.Font = Enum.Font.Gotham
noScriptsLabel.Visible = false
noScriptsLabel.Parent = scriptContainer

local currentButtons = {}

local function clearScriptButtons()
    for _, btn in ipairs(currentButtons) do
        btn:Destroy()
    end
    currentButtons = {}
end

local function createScriptButton(scriptName, fileName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = colors.card
    btn.Text = "▶  " .. scriptName
    btn.TextColor3 = colors.text
    btn.TextSize = 16
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    
    local hoverIn = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = colors.accentDark})
    local hoverOut = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = colors.card})
    btn.MouseEnter:Connect(function() hoverIn:Play() end)
    btn.MouseLeave:Connect(function() hoverOut:Play() end)
    
    btn.MouseButton1Click:Connect(function()
        local url = rawBase .. fileName
        local code = fetch(url)
        if code then
            local func, err = loadstring(code)
            if func then
                local ok, execErr = pcall(func)
                if ok then
                    notify("Pandemonium", "Loaded: " .. scriptName, 2)
                else
                    notify("Pandemonium", "Runtime error: " .. tostring(execErr), 4)
                end
            else
                notify("Pandemonium", "Syntax error: " .. tostring(err), 4)
            end
        else
            notify("Pandemonium", "Failed to fetch " .. scriptName, 3)
        end
    end)
    
    btn.Parent = scriptContainer
    table.insert(currentButtons, btn)
    return btn
end

local function rebuildScriptList(scriptFiles)
    clearScriptButtons()
    local searchText = searchBox.Text:lower()
    local anyVisible = false
    
    for _, fileInfo in ipairs(scriptFiles) do
        local name = fileInfo.name:gsub("%.lua$", "")
        if searchText == "" or name:lower():find(searchText) then
            createScriptButton(name, fileInfo.name)
            anyVisible = true
        end
    end
    
    loadingLabel.Visible = false
    noScriptsLabel.Visible = not anyVisible
    scriptContainer.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
end

local function fetchAndBuild()
    loadingLabel.Visible = true
    loadingLabel.Text = "Fetching script list from GitHub..."
    loadingLabel.TextColor3 = colors.textDim
    noScriptsLabel.Visible = false
    clearScriptButtons()
    
    local apiResponse = fetch(apiUrl)
    if not apiResponse then
        loadingLabel.Text = "⚠ Failed to reach GitHub API"
        loadingLabel.TextColor3 = colors.error
        notify("Pandemonium", "Cannot fetch script list. Check internet or repo visibility.", 5)
        return
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(apiResponse)
    end)
    
    if not success or type(data) ~= "table" then
        loadingLabel.Text = "⚠ Invalid API response"
        loadingLabel.TextColor3 = colors.error
        notify("Pandemonium", "GitHub API returned unexpected data.", 5)
        return
    end
    
    local luaFiles = {}
    for _, item in ipairs(data) do
        if item.type == "file" and item.name:sub(-4) == ".lua" then
            table.insert(luaFiles, { name = item.name, download_url = item.download_url })
        end
    end
    
    if #luaFiles == 0 then
        loadingLabel.Text = "No .lua scripts found"
        loadingLabel.TextColor3 = colors.error
        noScriptsLabel.Visible = true
        return
    end
    
    loadingLabel.Text = "Loading scripts..."
    rebuildScriptList(luaFiles)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if loadingLabel.Visible then return end
    local apiResponse = fetch(apiUrl)
    if apiResponse then
        local success, data = pcall(function()
            return HttpService:JSONDecode(apiResponse)
        end)
        if success and type(data) == "table" then
            local luaFiles = {}
            for _, item in ipairs(data) do
                if item.type == "file" and item.name:sub(-4) == ".lua" then
                    table.insert(luaFiles, { name = item.name, download_url = item.download_url })
                end
            end
            rebuildScriptList(luaFiles)
        end
    end
end)

refreshBtn.MouseButton1Click:Connect(function()
    fetchAndBuild()
end)

local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

fetchAndBuild()