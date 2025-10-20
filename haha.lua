local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

setfpscap(120)

local hitboxSettings = {
    Size = 4,
    Color = Color3.fromRGB(0, 0, 0),
    Transparency = 0.9
}

local hitboxCache = {}
local connections = {}

local function clearHitboxes()
    for character, box in pairs(hitboxCache) do
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                character.HumanoidRootPart.Transparency = 1
                character.HumanoidRootPart.CanCollide = true
            end)
        end
        if box then
            pcall(function() box:Destroy() end)
        end
    end
    hitboxCache = {}
end

local function updateHitbox(character)
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        if hitboxCache[character] then
            pcall(function() hitboxCache[character]:Destroy() end)
            hitboxCache[character] = nil
        end
        return 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        if hitboxCache[character] then
            pcall(function() hitboxCache[character]:Destroy() end)
            hitboxCache[character] = nil
        end
        return 
    end
    
    if not hitboxCache[character] then
        pcall(function()
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "HitboxAdornment"
            box.Adornee = hrp
            box.AlwaysOnTop = false
            box.ZIndex = 0
            box.Transparency = hitboxSettings.Transparency
            box.Color3 = hitboxSettings.Color
            box.Size = Vector3.new(hitboxSettings.Size * 1.5, hitboxSettings.Size * 1.8, hitboxSettings.Size * 1.5)
            box.Parent = hrp
            
            hitboxCache[character] = box
        end)
    end
    
    pcall(function()
        hrp.Size = Vector3.new(hitboxSettings.Size * 1.5, hitboxSettings.Size * 1.8, hitboxSettings.Size * 1.5)
        hrp.Transparency = 1
        hrp.CanCollide = false
        
        local box = hitboxCache[character]
        if box then
            box.Size = Vector3.new(hitboxSettings.Size * 1.5, hitboxSettings.Size * 1.8, hitboxSettings.Size * 1.5)
            box.Transparency = hitboxSettings.Transparency
            box.Color3 = hitboxSettings.Color
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
    if player ~= LocalPlayer and player.Character then
        updateHitbox(player.Character)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        updateHitbox(character)
    end)
end)

game:GetService("StarterPlayer").PlayerAdded:Connect(function(player)
    if player.Character then
        updateHitbox(player.Character)
    end
end)
