local Players = game:GetService("Players")
local enabled = false
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.new(1, 0, 0)
button.Text = "OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 14
button.Parent = screenGui

local highlights = {}
local checkedObjects = {}

local function isKiller(player)
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
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0.3
    highlight.Parent = obj
    highlights[obj] = highlight
end

local function updateESP()
    if not enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local color = isKiller(player) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
            createHighlight(player.Character, color)
        end
    end
    
    if not checkedObjects.generators then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = string.lower(obj.Name)
            if string.find(name, "generator") or string.find(name, "generation") then
                if obj:IsA("Model") or obj:IsA("Part") then
                    createHighlight(obj, Color3.new(1, 0.5, 0))
                end
            end
        end
        checkedObjects.generators = true
    end
end

local function clearESP()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    highlights = {}
    checkedObjects = {}
end

local function toggleESP()
    enabled = not enabled
    if enabled then
        button.BackgroundColor3 = Color3.new(0, 1, 0)
        button.Text = "ON"
    else
        button.BackgroundColor3 = Color3.new(1, 0, 0)
        button.Text = "OFF"
        clearESP()
    end
end

button.MouseButton1Click:Connect(toggleESP)

spawn(function()
    while true do
        updateESP()
        wait(2)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if enabled then wait(1) updateESP() end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        if enabled then wait(1) updateESP() end
    end)
end