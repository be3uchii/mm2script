local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local enabled = false
local highlights = {}

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

Instance.new("UICorner", button)

local function createHighlight(obj, color)
    if not obj or not obj:IsDescendantOf(workspace) or highlights[obj] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineTransparency = 1
    highlight.FillTransparency = 0.6
    highlight.Adornee = obj
    highlight.Parent = game.Lighting
    highlights[obj] = highlight
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team then
            local teamName = player.Team.Name:lower()
            if teamName == "killer" or teamName == "survivors" then
                local character = player.Character
                if character and character:IsDescendantOf(workspace) then
                    createHighlight(character, teamName == "killer" and Color3.new(1, 0, 0) or Color3.new(0, 1, 0))
                end
            end
        end
    end
    
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name:lower():find("generator") and descendant:IsDescendantOf(workspace) then
            createHighlight(descendant, Color3.new(1, 0.5, 0))
        end
    end
end

local function clearAll()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    highlights = {}
end

local function toggleESP()
    enabled = not enabled
    button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(150, 0, 0)
    button.Text = enabled and "ON" or "OFF"
    
    clearAll()
    if enabled then
        updateESP()
    end
end

button.MouseButton1Click:Connect(toggleESP)

localPlayer.CharacterAdded:Connect(function()
    clearAll()
    screenGui:Destroy()
    
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
    
    Instance.new("UICorner", button)
    button.MouseButton1Click:Connect(toggleESP)
end)
