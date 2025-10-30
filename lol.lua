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
local generatorsCached = false
local cachedGenerators = {}

local function stringContains(str, patterns)
    if not str then return false end
    local lowerStr = str:lower()
    for word in pairs(patterns) do
        if lowerStr:find(word) then return true end
    end
    return false
end

local function cacheGenerators()
    if generatorsCached then return cachedGenerators end
    cachedGenerators = {}
    for _, descendant in workspace:GetDescendants() do
        if descendant:IsA("Model") and stringContains(descendant.Name, generatorPatterns) then
            cachedGenerators[#cachedGenerators + 1] = descendant
        end
    end
    generatorsCached = true
    return cachedGenerators
end

local function isKiller(player)
    local cached = cachedKillers[player]
    if cached ~= nil then return cached end
    if player == localPlayer then
        cachedKillers[player] = false
        return false
    end
    
    local isKillerRole = stringContains(player.Name, killerPatterns) or
                        stringContains(player.DisplayName, killerPatterns) or
                        (player.Team and stringContains(player.Team.Name, killerPatterns))
    
    if isKillerRole then
        for _, otherPlayer in Players:GetPlayers() do
            if otherPlayer ~= player and cachedKillers[otherPlayer] then
                cachedKillers[player] = false
                return false
            end
        end
    end
    
    cachedKillers[player] = isKillerRole
    return isKillerRole
end

local function getPlayerColor(player)
    local username = player.Name
    
    if username == "natebyatakpoxui" or username == "natebyatakpoxuii" then
        if isKiller(player) then
            return Color3.new(1, 0, 0)
        else
            return Color3.new(1, 1, 0)
        end
    end
    
    if isKiller(player) then
        return Color3.new(1, 0, 0)
    else
        return Color3.new(0, 1, 0)
    end
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
    for _, player in Players:GetPlayers() do
        if player ~= localPlayer then
            local character = player.Character
            if character and character:IsDescendantOf(workspace) then
                createHighlight(character, getPlayerColor(player))
            end
        end
    end
end

local function addGeneratorESP()
    for _, generator in cacheGenerators() do
        if generator and generator:IsDescendantOf(workspace) then
            createHighlight(generator, Color3.new(1, 0.5, 0))
        end
    end
end

local function clearESP()
    for obj, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    highlights = {}
    cachedKillers = {}
end

local function toggleESP()
    if buttonCooldown then return end
    buttonCooldown = true
    enabled = not enabled
    button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(150, 0, 0)
    button.Text = enabled and "ON" or "OFF"
    if enabled then
        task.spawn(updatePlayerESP)
        task.spawn(addGeneratorESP)
    else
        task.spawn(clearESP)
        generatorsCached = false
        cachedGenerators = {}
    end
    task.wait(0.3)
    buttonCooldown = false
end

local function setupPlayerConnections(player)
    if player == localPlayer then return end
    espConnections[player] = player.CharacterAdded:Connect(function()
        if enabled then
            cachedKillers[player] = nil
            task.wait(0.5)
            task.spawn(updatePlayerESP)
        end
    end)
    if player.Character and enabled then
        task.spawn(updatePlayerESP)
    end
end

local function cleanupPlayerConnections(player)
    local connection = espConnections[player]
    if connection then
        connection:Disconnect()
        espConnections[player] = nil
    end
end

button.MouseButton1Click:Connect(toggleESP)

local frameCounter = 0
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    frameCounter = frameCounter + 1
    if frameCounter >= 30 then
        task.spawn(updatePlayerESP)
        frameCounter = 0
    end
end)

Players.PlayerAdded:Connect(setupPlayerConnections)
Players.PlayerRemoving:Connect(cleanupPlayerConnections)

for _, player in Players:GetPlayers() do
    setupPlayerConnections(player)
end

localPlayer.CharacterAdded:Connect(function()
    clearESP()
    screenGui:Destroy()
    task.wait(0.1)
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
    generatorsCached = false
    cachedGenerators = {}
    button.MouseButton1Click:Connect(toggleESP)
end)
