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
local lastUpdate = 0

local function stringContains(str, words)
    if not str then return false end
    local lowerStr = str:lower()
    for _, word in ipairs(words) do
        if lowerStr:find(word) then
            return true
        end
    end
    return false
end

local function isKiller(player)
    if cachedKillers[player] ~= nil then
        return cachedKillers[player]
    end
    
    if player == localPlayer then
        cachedKillers[player] = false
        return false
    end
    
    if stringContains(player.Name, killerWords) or stringContains(player.DisplayName, killerWords) then
        cachedKillers[player] = true
        return true
    end
    
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and stringContains(tool.Name, weaponWords) then
                cachedKillers[player] = true
                return true
            end
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed > 20 then
            cachedKillers[player] = true
            return true
        end
    end
    
    if player.Team and stringContains(player.Team.Name, killerWords) then
        cachedKillers[player] = true
        return true
    end
    
    cachedKillers[player] = false
    return false
end

local function createHighlight(obj, color)
    if highlights[obj] then return end
    
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

local function updatePlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:IsDescendantOf(workspace) then
            local color = isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
            createHighlight(player.Character, color)
        end
    end
end

local function updateGenerators()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if (descendant:IsA("Model") or descendant:IsA("Part")) and stringContains(descendant.Name, generatorWords) then
            createHighlight(descendant, Color3.new(1, 0.5, 0))
        end
    end
end

local function clearESP()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    highlights = {}
    cachedKillers = {}
end

local function toggleESP()
    enabled = not enabled
    
    if enabled then
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        button.Text = "ON"
        updatePlayers()
        updateGenerators()
    else
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        button.Text = "OFF"
        clearESP()
    end
end

button.MouseButton1Click:Connect(toggleESP)

RunService.Heartbeat:Connect(function()
    if not enabled then return end
    
    local now = tick()
    if now - lastUpdate > 0.1 then
        updatePlayers()
        lastUpdate = now
    end
end)

workspace.DescendantRemoving:Connect(function(descendant)
    if highlights[descendant] then
        highlights[descendant]:Destroy()
        highlights[descendant] = nil
    end
end)

Players.PlayerRemoving:Connect(function(player)
    cachedKillers[player] = nil
end)
