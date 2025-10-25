local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local enabled = false

local cachedKillers = {}
local killerPatterns = {killer = true}
local generatorPatterns = {generator = true}

local screenGui = nil
local button = nil
local highlights = {}
local espConnections = {}
local buttonCooldown = false
local generatorsCache = nil

local function createGUI()
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
end

local function stringContains(str, patterns)
    if not str then return false end
    local lowerStr = str:lower()
    for word in pairs(patterns) do
        if lowerStr:find(word) then
            return true
        end
    end
    return false
end

local function cacheGenerators()
    if generatorsCache then
        return generatorsCache
    end
    
    generatorsCache = {}
    for _, descendant in workspace:GetDescendants() do
        if descendant:IsA("Model") and stringContains(descendant.Name, generatorPatterns) then
            table.insert(generatorsCache, descendant)
        end
    end
    return generatorsCache
end

local function isKiller(player)
    if cachedKillers[player] ~= nil then
        return cachedKillers[player]
    end
    if player == localPlayer then
        cachedKillers[player] = false
        return false
    end
    
    cachedKillers[player] = stringContains(player.Name, killerPatterns) or
                           stringContains(player.DisplayName, killerPatterns) or
                           (player.Team and stringContains(player.Team.Name, killerPatterns))
    return cachedKillers[player]
end

local function createHighlight(obj, color)
    if highlights[obj] or not obj or not obj.Parent then
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = screenGui
    highlights[obj] = highlight
    
    if obj:IsA("Model") then
        obj.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if highlights[obj] then
                    highlights[obj]:Destroy()
                    highlights[obj] = nil
                end
            end
        end)
    end
end

local function cleanupAllConnections()
    for player, connection in pairs(espConnections) do
        connection:Disconnect()
    end
    espConnections = {}
end

local function clearESP()
    cleanupAllConnections()
    
    for obj, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    highlights = {}
    cachedKillers = {}
end

local function updatePlayerESP()
    if not enabled then
        return
    end
    
    for _, player in Players:GetPlayers() do
        if player ~= localPlayer then
            local character = player.Character
            if character and character:IsDescendantOf(workspace) then
                createHighlight(character, isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0))
            end
        end
    end
end

local function addGeneratorESP()
    if not enabled then
        return
    end
    
    local generators = cacheGenerators()
    for _, generator in ipairs(generators) do
        if generator and generator:IsDescendantOf(workspace) then
            createHighlight(generator, Color3.new(1, 0.5, 0))
        end
    end
end

local function toggleESP()
    if buttonCooldown then
        return
    end
    buttonCooldown = true
    
    enabled = not enabled
    button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(150, 0, 0)
    button.Text = enabled and "ON" or "OFF"
    
    if enabled then
        cacheGenerators()
        updatePlayerESP()
        addGeneratorESP()
    else
        clearESP()
        generatorsCache = nil
    end
    
    task.wait(0.3)
    buttonCooldown = false
end

local function setupPlayerConnections(player)
    if player == localPlayer then
        return
    end
    
    local oldConnection = espConnections[player]
    if oldConnection then
        oldConnection:Disconnect()
    end
    
    espConnections[player] = player.CharacterAdded:Connect(function()
        if enabled then
            cachedKillers[player] = nil
            task.wait(1)
            updatePlayerESP()
        end
    end)
    
    if player.Character and enabled then
        task.wait(1)
        updatePlayerESP()
    end
end

local function cleanupPlayerConnections(player)
    local connection = espConnections[player]
    if connection then
        connection:Disconnect()
        espConnections[player] = nil
    end
end

createGUI()
button.MouseButton1Click:Connect(toggleESP)

local frameCounter = 0
RunService.Heartbeat:Connect(function()
    if not enabled then
        return
    end
    
    frameCounter += 1
    if frameCounter >= 30 then
        updatePlayerESP()
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
    generatorsCache = nil
    task.wait(1)
    createGUI()
    button.MouseButton1Click:Connect(toggleESP)
    enabled = false
end)
