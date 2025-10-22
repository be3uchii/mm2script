local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local enabled = false

local cachedKillers = {}
local killerWords = {"killer", "hunter", "murder", "assassin", "jason", "maniac", "ghost", "slasher", "stalker", "abysswalker", "masked", "hidden"}
local weaponWords = {"knife", "sword", "gun", "axe", "machete", "katana", "blade", "weapon"}
local generatorWords = {"generator", "generation"}

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
local cachedGenerators = {}
local killerPatterns = {}
local weaponPatterns = {}
local generatorPatterns = {}

for _, word in ipairs(killerWords) do
    killerPatterns[word] = true
end
for _, word in ipairs(weaponWords) do
    weaponPatterns[word] = true
end
for _, word in ipairs(generatorWords) do
    generatorPatterns[word] = true
end

local function safeCheck(callback)
    local success, result = pcall(callback)
    return success and result
end

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
    table.clear(cachedGenerators)
    safeCheck(function()
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if (descendant:IsA("Model") or descendant:IsA("Part")) and stringContains(descendant.Name, generatorPatterns) then
                table.insert(cachedGenerators, descendant)
            end
        end
    end)
end

local function isKiller(player)
    if cachedKillers[player] ~= nil then
        return cachedKillers[player]
    end
    
    if player == localPlayer then
        cachedKillers[player] = false
        return false
    end
    
    local result = safeCheck(function()
        if stringContains(player.Name, killerPatterns) or stringContains(player.DisplayName, killerPatterns) then
            return true
        end
        
        local character = player.Character
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and stringContains(tool.Name, weaponPatterns) then
                    return true
                end
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed > 20 then
                return true
            end
        end
        
        if player.Team and stringContains(player.Team.Name, killerPatterns) then
            return true
        end
        
        return false
    end)
    
    cachedKillers[player] = result or false
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
            local character = safeCheck(function() return player.Character end)
            if character and character:IsDescendantOf(workspace) then
                local color = isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                createHighlight(character, color)
            end
        end
    end
end

local function addGeneratorESP()
    for _, generator in ipairs(cachedGenerators) do
        if generator and generator:IsDescendantOf(workspace) then
            createHighlight(generator, Color3.new(1, 0.5, 0))
        end
    end
end

local function clearESP()
    for obj, highlight in pairs(highlights) do
        safeCheck(function()
            highlight:Destroy()
        end)
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
        cacheGenerators()
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
    
    local connections = {}
    
    local function onCharacterAdded(character)
        if not enabled then return end
        cachedKillers[player] = nil
        task.delay(0.5, function()
            if enabled then
                updatePlayerESP()
            end
        end)
    end
    
    local characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    table.insert(connections, characterAdded)
    
    if player.Character then
        task.spawn(onCharacterAdded, player.Character)
    end
    
    espConnections[player] = connections
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
        if frameCounter % 3 == 0 then
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

Players.PlayerAdded:Connect(function(player)
    setupPlayerConnections(player)
end)

Players.PlayerRemoving:Connect(function(player)
    cleanupPlayerConnections(player)
    cachedKillers[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        setupPlayerConnections(player)
    end
end

local descendantAddedConnection
local descendantRemovingConnection

local function setupWorkspaceConnections()
    if descendantAddedConnection then
        descendantAddedConnection:Disconnect()
    end
    if descendantRemovingConnection then
        descendantRemovingConnection:Disconnect()
    end
    
    descendantAddedConnection = workspace.DescendantAdded:Connect(function(descendant)
        if not enabled then return end
        
        if (descendant:IsA("Model") or descendant:IsA("Part")) and stringContains(descendant.Name, generatorPatterns) then
            table.insert(cachedGenerators, descendant)
            createHighlight(descendant, Color3.new(1, 0.5, 0))
        end
    end)
    
    descendantRemovingConnection = workspace.DescendantRemoving:Connect(function(descendant)
        if highlights[descendant] then
            safeCheck(function()
                highlights[descendant]:Destroy()
                highlights[descendant] = nil
            end)
        end
    end)
end

cacheGenerators()
setupWorkspaceConnections()

localPlayer.CharacterAdded:Connect(function()
    stopESPUpdates()
    clearESP()
    
    safeCheck(function()
        if screenGui then
            screenGui:Destroy()
        end
    end)
    
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
    cacheGenerators()
    setupWorkspaceConnections()
    
    if enabled then
        startESPUpdates()
    end
end)
