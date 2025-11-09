local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local enabled = false
local killerPatterns = {killer = true}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 50, 0, 22)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
button.BackgroundTransparency = 0.3
button.Text = "OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 10
button.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = button

local highlights = {}
local espConnections = {}
local playerConnections = {}
local buttonCooldown = false

local function safeDestroy(object)
    if object and object.Parent then
        object:Destroy()
    end
end

local function stringContains(str, patterns)
    if type(str) ~= "string" then return false end
    local lowerStr = str:lower()
    for word in pairs(patterns) do
        if lowerStr:find(word, 1, true) then
            return true
        end
    end
    return false
end

local function isKiller(player)
    if not player or player == localPlayer then
        return false
    end
    
    return (player.Team and stringContains(player.Team.Name, killerPatterns))
end

local function createHighlight(obj, color)
    if not obj or not obj:IsDescendantOf(workspace) or highlights[obj] then 
        return 
    end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineTransparency = 1
    highlight.FillTransparency = 0.6
    highlight.Adornee = obj
    highlight.Parent = screenGui
    highlights[obj] = highlight
end

local function cleanupAllHighlights()
    for obj, highlight in pairs(highlights) do
        safeDestroy(highlight)
    end
    highlights = {}
end

local function updatePlayerESP()
    if not enabled then return end
    
    local players = Players:GetPlayers()
    for i = 1, #players do
        local player = players[i]
        if player ~= localPlayer then
            local character = player.Character
            if character and character:IsDescendantOf(workspace) then
                createHighlight(character, isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0))
            end
        end
    end
end

local generatorsAdded = false
local function addGeneratorESP()
    if generatorsAdded or not enabled then return end
    generatorsAdded = true
    
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local descendant = descendants[i]
        if descendant:IsA("Model") and stringContains(descendant.Name, {generator = true}) then
            if descendant:IsDescendantOf(workspace) then
                createHighlight(descendant, Color3.new(1, 0.5, 0))
            end
        end
    end
end

local function clearAll()
    cleanupAllHighlights()
    
    for player, connections in pairs(playerConnections) do
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
    end
    playerConnections = {}
    
    for player, connection in pairs(espConnections) do
        connection:Disconnect()
    end
    espConnections = {}
    
    generatorsAdded = false
    enabled = false
end

local function toggleESP()
    if buttonCooldown then return end
    buttonCooldown = true
    
    enabled = not enabled
    button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(150, 0, 0)
    button.Text = enabled and "ON" or "OFF"
    
    if enabled then
        updatePlayerESP()
        addGeneratorESP()
    else
        clearAll()
    end
    
    task.delay(0.5, function()
        buttonCooldown = false
    end)
end

local function cleanupPlayer(player)
    if playerConnections[player] then
        for _, connection in pairs(playerConnections[player]) do
            connection:Disconnect()
        end
        playerConnections[player] = nil
    end
    
    if espConnections[player] then
        espConnections[player]:Disconnect()
        espConnections[player] = nil
    end
    
    local character = player.Character
    if character and highlights[character] then
        safeDestroy(highlights[character])
        highlights[character] = nil
    end
end

local function setupPlayerConnections(player)
    if player == localPlayer then return end
    
    playerConnections[player] = {}
    
    espConnections[player] = player.CharacterAdded:Connect(function(character)
        if enabled then
            task.delay(1, updatePlayerESP)
        end
    end)
    
    table.insert(playerConnections[player], player.CharacterRemoving:Connect(function(character)
        if character and highlights[character] then
            safeDestroy(highlights[character])
            highlights[character] = nil
        end
    end))
    
    if player.Character and enabled then
        task.delay(0.5, updatePlayerESP)
    end
end

button.MouseButton1Click:Connect(toggleESP)

local frameCounter = 0
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    
    frameCounter += 1
    
    if frameCounter >= 180 then
        updatePlayerESP()
        frameCounter = 0
    end
end)

Players.PlayerAdded:Connect(function(player)
    task.delay(1, function()
        setupPlayerConnections(player)
    end)
end)

Players.PlayerRemoving:Connect(cleanupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    task.delay(0.5, function()
        setupPlayerConnections(player)
    end)
end

localPlayer.CharacterAdded:Connect(function()
    clearAll()
    safeDestroy(screenGui)
    
    task.wait(1)
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 22)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    button.BackgroundTransparency = 0.3
    button.Text = "OFF"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 10
    button.Parent = screenGui
    
    UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = button
    
    button.MouseButton1Click:Connect(toggleESP)
    
    for _, player in ipairs(Players:GetPlayers()) do
        task.delay(0.5, function()
            setupPlayerConnections(player)
        end)
    end
end)
