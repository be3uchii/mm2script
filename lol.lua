local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local enabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 25)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.new(1, 0, 0)
button.Text = "OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 11
button.Parent = screenGui

local highlights = {}

local function isKiller(player)
    if player == localPlayer then return false end
    local name = string.lower(player.Name)
    local displayName = string.lower(player.DisplayName)
    local killerWords = {"killer", "hunter", "murder", "assassin", "jason", "maniac", "ghost", "slasher", "stalker", "abysswalker", "masked", "hidden"}
    for _, word in ipairs(killerWords) do
        if string.find(name, word) or string.find(displayName, word) then return true end
    end
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                local weaponWords = {"knife", "sword", "gun", "axe", "machete", "katana", "blade", "weapon"}
                for _, weapon in ipairs(weaponWords) do
                    if string.find(toolName, weapon) then return true end
                end
            end
        end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed > 20 then return true end
    end
    if player.Team then
        local teamName = string.lower(player.Team.Name)
        for _, word in ipairs(killerWords) do
            if string.find(teamName, word) then return true end
        end
    end
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

local function updateESP()
    if not enabled then return end
    
    local currentHighlights = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local color = isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
            createHighlight(player.Character, color)
            currentHighlights[player.Character] = true
        end
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if string.find(name, "generator") or string.find(name, "generation") then
            if obj:IsA("Model") or obj:IsA("Part") then
                createHighlight(obj, Color3.new(1, 0.5, 0))
                currentHighlights[obj] = true
            end
        end
    end
    
    for obj, highlight in pairs(highlights) do
        if not currentHighlights[obj] then
            highlight:Destroy()
            highlights[obj] = nil
        end
    end
end

local function clearESP()
    for obj, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    highlights = {}
end

local function toggleESP()
    enabled = not enabled
    if enabled then
        button.BackgroundColor3 = Color3.new(0, 1, 0)
        button.Text = "ON"
        updateESP()
    else
        button.BackgroundColor3 = Color3.new(1, 0, 0)
        button.Text = "OFF"
        clearESP()
    end
end

button.MouseButton1Click:Connect(toggleESP)

spawn(function()
    while true do
        if enabled then
            updateESP()
        end
        wait(1)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if enabled then 
            wait(0.5) 
            updateESP() 
        end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function()
            if enabled then 
                wait(0.5) 
                updateESP() 
            end
        end)
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    if enabled then
        local name = string.lower(descendant.Name)
        if string.find(name, "generator") or string.find(name, "generation") then
            if descendant:IsA("Model") or descendant:IsA("Part") then
                wait(0.3)
                updateESP()
            end
        end
    end
end)

workspace.DescendantRemoving:Connect(function(descendant)
    if highlights[descendant] then
        highlights[descendant]:Destroy()
        highlights[descendant] = nil
    end
end)

localPlayer.CharacterAdded:Connect(function()
    if screenGui then
        screenGui:Destroy()
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 25)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.new(1, 0, 0)
    button.Text = "OFF"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 11
    button.Parent = screenGui
    
    enabled = false
    clearESP()
    
    button.MouseButton1Click:Connect(toggleESP)
end)
