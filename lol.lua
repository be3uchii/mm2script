local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local enabled = false

local cachedKillers = {}
local killerPatterns = {killer = true}
local generatorPatterns = {generator = true}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 25)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
button.BackgroundTransparency = 0.3
button.Text = "OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 11
button.Parent = screenGui

local highlights = {}
local espConnections = {}
local buttonCooldown = false

local function stringContains(str, patterns)
    if not str then return false end
    local lowerStr = string.lower(str)
    for word in pairs(patterns) do
        if string.find(lowerStr, word) then
            return true
        end
    end
    return false
end

local function cacheGenerators()
    local generators = {}
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and stringContains(descendant.Name, generatorPatterns) then
            table.insert(generators, descendant)
        end
    end
    return generators
end

local function isKiller(player)
    if cachedKillers[player] ~= nil then return cachedKillers[player] end
    if player == localPlayer then cachedKillers[player] = false return false end
    
    cachedKillers[player] = stringContains(player.Name, killerPatterns) or 
                           stringContains(player.DisplayName, killerPatterns) or
                           (player.Team and stringContains(player.Team.Name, killerPatterns))
    return cachedKillers[player]
end

local function createHighlight(obj, color)
    if highlights[obj] or not obj then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = screenGui
    highlights[obj] = highlight
end

local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character
            if character and character:IsDescendantOf(workspace) then
                local color = isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                createHighlight(character, color)
            end
        end
    end
end

local function addGeneratorESP()
    local generators = cacheGenerators()
    for _, generator in ipairs(generators) do
        if generator and generator:IsDescendantOf(workspace) then
            createHighlight(generator, Color3.new(1, 0.5, 0))
        end
    end
end

local function clearESP()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    table.clear(highlights)
    table.clear(cachedKillers)
end

local function toggleESP()
    if buttonCooldown then return end
    buttonCooldown = true
    
    enabled = not enabled
    if enabled then
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        button.Text = "ON"
        updatePlayerESP()
        addGeneratorESP()
    else
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        button.Text = "OFF"
        clearESP()
    end
    
    task.wait(0.3)
    buttonCooldown = false
end

local function setupPlayerConnections(player)
    if player == localPlayer then return end
    
    local function onCharacterAdded()
        if not enabled then return end
        cachedKillers[player] = nil
        task.delay(0.5, updatePlayerESP)
    end
    
    local characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    espConnections[player] = {characterAdded}
    
    if player.Character then
        task.spawn(onCharacterAdded)
    end
end

local function cleanupPlayerConnections(player)
    if espConnections[player] then
        for _, connection in ipairs(espConnections[player]) do
            connection:Disconnect()
        end
        espConnections[player] = nil
    end
end

button.MouseButton1Click:Connect(toggleESP)

local espUpdateConnection
local frameCounter = 0

local function startESPUpdates()
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
    end
    
    espUpdateConnection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        frameCounter = frameCounter + 1
        if frameCounter >= 3 then
            updatePlayerESP()
            frameCounter = 0
        end
    end)
end

local function stopESPUpdates()
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
        espUpdateConnection = nil
    end
end

Players.PlayerAdded:Connect(setupPlayerConnections)
Players.PlayerRemoving:Connect(function(player)
    cleanupPlayerConnections(player)
    cachedKillers[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        setupPlayerConnections(player)
    end
end

localPlayer.CharacterAdded:Connect(function()
    stopESPUpdates()
    clearESP()
    
    if screenGui then
        screenGui:Destroy()
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 25)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    button.BackgroundTransparency = 0.3
    button.Text = "OFF"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 11
    button.Parent = screenGui
    
    enabled = false
    button.MouseButton1Click:Connect(toggleESP)
end)
