local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local hitboxSettings = {
    Size = 4,
    Color = Color3.fromRGB(0, 0, 0),
    Transparency = 0.9
}

local hitboxCache = {}
local connections = {}

local function isValidCharacter(character)
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return hrp and humanoid and humanoid.Health > 0
end

local function updateHitbox(character)
    if not isValidCharacter(character) then
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return
    end

    local hrp = character.HumanoidRootPart
    
    if not hitboxCache[character] then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = hrp
        box.AlwaysOnTop = false
        box.ZIndex = 0
        box.Size = Vector3.new(hitboxSettings.Size * 1.5, hitboxSettings.Size * 1.8, hitboxSettings.Size * 1.5)
        box.Parent = hrp
        hitboxCache[character] = box
    end

    local box = hitboxCache[character]
    box.Size = Vector3.new(hitboxSettings.Size * 1.5, hitboxSettings.Size * 1.8, hitboxSettings.Size * 1.5)
    box.Transparency = hitboxSettings.Transparency
    box.Color3 = hitboxSettings.Color

    hrp.Size = Vector3.new(hitboxSettings.Size * 1.5, hitboxSettings.Size * 1.8, hitboxSettings.Size * 1.5)
    hrp.Transparency = 1
    hrp.CanCollide = false
end

local function processPlayer(player)
    if player == LocalPlayer then return end
    
    if player.Character then
        updateHitbox(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        updateHitbox(character)
    end)
    
    player.CharacterRemoving:Connect(function(character)
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
    end)
end

connections.RenderStep = RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            updateHitbox(player.Character)
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    processPlayer(player)
end

Players.PlayerAdded:Connect(processPlayer)
Players.PlayerRemoving:Connect(function(player)
    if player.Character and hitboxCache[player.Character] then
        hitboxCache[player.Character]:Destroy()
        hitboxCache[player.Character] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    for character, box in pairs(hitboxCache) do
        box:Destroy()
        hitboxCache[character] = nil
    end
end)
