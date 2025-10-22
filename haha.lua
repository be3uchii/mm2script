local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local hitboxSettings = {
    Size = 6,
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
            hitboxCache[character].Adornment:Destroy()
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
        box.Size = Vector3.new(hitboxSettings.Size, hitboxSettings.Size, hitboxSettings.Size)
        box.Color3 = hitboxSettings.Color
        box.Transparency = hitboxSettings.Transparency
        box.Parent = hrp
        
        hitboxCache[character] = {
            Adornment = box,
            OriginalSize = hrp.Size
        }
    end

    local hitboxData = hitboxCache[character]
    local box = hitboxData.Adornment
    local size = Vector3.new(hitboxSettings.Size, hitboxSettings.Size, hitboxSettings.Size)
    
    box.Size = size
    hrp.Size = size
    hrp.Transparency = 1
    hrp.CanCollide = false
end

local function cleanupCharacter(character)
    if hitboxCache[character] then
        local hitboxData = hitboxCache[character]
        hitboxData.Adornment:Destroy()
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = hitboxData.OriginalSize
            character.HumanoidRootPart.Transparency = 0
            character.HumanoidRootPart.CanCollide = true
        end
        hitboxCache[character] = nil
    end
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
        cleanupCharacter(character)
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
    if player.Character then
        cleanupCharacter(player.Character)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    for character in pairs(hitboxCache) do
        cleanupCharacter(character)
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        hitboxSettings.Size = hitboxSettings.Size == 4 and 10 or 4
    end
end)
