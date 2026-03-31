local repoOwner = "ishaansucksatlife"
local repoName = "Pandemonium-Loader"
local scriptsPath = "scripts"
local apiUrl = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName .. "/contents/" .. scriptsPath
local rawBase = "https://raw.githubusercontent.com/" .. repoOwner .. "/" .. repoName .. "/main/" .. scriptsPath .. "/"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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

-- Colors
local colors = {
    bg = Color3.fromRGB(8, 8, 20),
    card = Color3.fromRGB(12, 12, 28),
    accent = Color3.fromRGB(0, 255, 255),
    accentDark = Color3.fromRGB(0, 180, 180),
    text = Color3.fromRGB(200, 200, 255),
    textDim = Color3.fromRGB(120, 120, 160),
    error = Color3.fromRGB(255, 50, 100),
    border = Color3.fromRGB(0, 200, 200)
}

-- Main resizable frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 550, 0, 650)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -325)
mainFrame.BackgroundColor3 = colors.bg
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = colors.border
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Glow shadow
local shadow = Instance.new("ImageLabel")
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = colors.accent
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0
shadow.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = colors.card
titleBar.BorderSizePixel = 1
titleBar.BorderColor3 = colors.border
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PANDEMONIUM HUB"
titleLabel.TextColor3 = colors.accent
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -85, 0, 5)
minimizeBtn.BackgroundColor3 = colors.card
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = colors.text
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 1
minimizeBtn.BorderColor3 = colors.border
minimizeBtn.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = colors.card
closeBtn.Text = "✕"
closeBtn.TextColor3 = colors.textDim
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 1
closeBtn.BorderColor3 = colors.border
closeBtn.Parent = titleBar

-- Search bar
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 0, 40)
searchBox.Position = UDim2.new(0, 20, 0, 60)
searchBox.BackgroundColor3 = colors.card
searchBox.TextColor3 = colors.text
searchBox.PlaceholderText = "🔍 Search scripts..."
searchBox.PlaceholderColor3 = colors.textDim
searchBox.Text = ""
searchBox.TextSize = 16
searchBox.Font = Enum.Font.Gotham
searchBox.BorderSizePixel = 1
searchBox.BorderColor3 = colors.border
searchBox.Parent = mainFrame

-- Reload button (decal)
local reloadBtn = Instance.new("ImageButton")
reloadBtn.Size = UDim2.new(0, 40, 0, 40)
reloadBtn.Position = UDim2.new(1, -55, 0, 60)
reloadBtn.BackgroundColor3 = colors.card
reloadBtn.Image = "rbxassetid://94269559571205"
reloadBtn.ScaleType = Enum.ScaleType.Fit
reloadBtn.BorderSizePixel = 1
reloadBtn.BorderColor3 = colors.border
reloadBtn.Parent = mainFrame

-- Scripts container (scrolling frame)
local scriptContainer = Instance.new("ScrollingFrame")
scriptContainer.Size = UDim2.new(1, -20, 1, -130)
scriptContainer.Position = UDim2.new(0, 10, 0, 115)
scriptContainer.BackgroundColor3 = colors.card
scriptContainer.BackgroundTransparency = 0.3
scriptContainer.BorderSizePixel = 1
scriptContainer.BorderColor3 = colors.border
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

-- Resize handle (bottom-right corner)
local resizeHandle = Instance.new("Frame")
resizeHandle.Size = UDim2.new(0, 15, 0, 15)
resizeHandle.Position = UDim2.new(1, -15, 1, -15)
resizeHandle.BackgroundColor3 = colors.accent
resizeHandle.BorderSizePixel = 0
resizeHandle.Parent = mainFrame

-- Minimized state variables
local minimized = false
local minimizedIcon = nil
local originalSize = mainFrame.Size
local originalPos = mainFrame.Position

-- Create minimized floating icon
local function createMinimizedIcon()
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 20, 0, 100)
    icon.BackgroundColor3 = colors.card
    icon.BorderSizePixel = 2
    icon.BorderColor3 = colors.accent
    icon.Image = "rbxassetid://94269559571205"
    icon.ScaleType = Enum.ScaleType.Fit
    icon.BackgroundTransparency = 0.2
    icon.Parent = screenGui
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0, 20)
    iconLabel.Position = UDim2.new(0, 0, 1, -20)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "Pandemonium"
    iconLabel.TextColor3 = colors.accent
    iconLabel.TextSize = 10
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = icon
    
    -- Make icon draggable
    local dragging = false
    local dragStart, startPos
    icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = icon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    icon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            icon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    icon.MouseButton1Click:Connect(function()
        -- Restore main window
        minimized = false
        mainFrame.Visible = true
        mainFrame.Size = originalSize
        mainFrame.Position = originalPos
        icon:Destroy()
        minimizedIcon = nil
    end)
    
    return icon
end

-- Minimize action
minimizeBtn.MouseButton1Click:Connect(function()
    if minimized then return end
    minimized = true
    originalSize = mainFrame.Size
    originalPos = mainFrame.Position
    mainFrame.Visible = false
    minimizedIcon = createMinimizedIcon()
end)

-- Close action
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Resize logic
local resizing = false
local startMousePos, startSize

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        startMousePos = input.Position
        startSize = mainFrame.Size
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startMousePos
        local newWidth = math.clamp(startSize.X.Offset + delta.X, 400, 900)
        local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 400, 800)
        mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        -- Adjust container sizes
        scriptContainer.Size = UDim2.new(1, -20, 1, -130)
        searchBox.Size = UDim2.new(1, -40, 0, 40)
        reloadBtn.Position = UDim2.new(1, -55, 0, 60)
    end
end)

-- Draggable title bar
local dragging = false
local dragStart, startPos

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

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Script button management
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
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.border
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

reloadBtn.MouseButton1Click:Connect(function()
    fetchAndBuild()
end)

fetchAndBuild()