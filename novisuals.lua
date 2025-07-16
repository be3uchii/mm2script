local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if not ReplicatedStorage:FindFirstChild("GlobalEffects") then
    Instance.new("RemoteEvent", ReplicatedStorage).Name = "GlobalEffects"
end
local RemoteEvent = ReplicatedStorage:WaitForChild("GlobalEffects")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMenu"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.15, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ULTIMATE MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 14
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local Tabs = {
    "Эмоции", "Эффекты", "Звуки", "Трансформации", "Особые"
}

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabButtons.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -80)
ContentFrame.Position = UDim2.new(0, 5, 0, 70)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = MainFrame

local CurrentAnimation
local CurrentEffects = {}

local EffectsLibrary = {
    Emotes = {
        ["Танец 1"] = 5917459365,
        ["Танец 2"] = 5918726674,
        ["Помахать"] = 3571296930,
        ["Грусть"] = 5917459366,
        ["Победа"] = 5917459367,
        ["Смех"] = 5917459368,
        ["Испуг"] = 5917459369,
        ["Злость"] = 5917459370,
        ["Усталость"] = 5917459371,
        ["Привет"] = 5917459372
    },
    Effects = {
        ["Огненный след"] = {
            Type = "ParticleTrail",
            Texture = "rbxassetid://242842629",
            Color = Color3.new(1, 0.3, 0),
            Size = 0.7,
            Lifetime = 1,
            Speed = 5
        },
        ["Ледяная аура"] = {
            Type = "ParticleAura",
            Texture = "rbxassetid://242842629",
            Color = Color3.new(0.3, 0.7, 1),
            Size = 0.6,
            Lifetime = 2,
            Speed = 3
        },
        ["Магические круги"] = {
            Type = "RingEffect",
            Color = Color3.new(0.8, 0, 1),
            Size = 5,
            Speed = 2
        },
        ["Электричество"] = {
            Type = "BeamEffect",
            Color = Color3.new(0, 1, 1),
            Width = 0.3,
            Speed = 10
        },
        ["Конфетти"] = {
            Type = "Confetti",
            Texture = "rbxassetid://242842629",
            Colors = {
                Color3.new(1, 0, 0),
                Color3.new(0, 1, 0),
                Color3.new(0, 0, 1),
                Color3.new(1, 1, 0)
            },
            Size = 0.5,
            Lifetime = 3,
            Speed = 7
        }
    },
    Sounds = {
        ["Эхо"] = 9045566035,
        ["Магия"] = 9045567124,
        ["Электро"] = 9045568456,
        ["Ветер"] = 9045569237,
        ["Огонь"] = 9045570123
    },
    Transformations = {
        ["Гигант"] = {Scale = 1.5},
        ["Карлик"] = {Scale = 0.7},
        ["Призрак"] = {Transparency = 0.7},
        ["Невидимка"] = {Transparency = 0.9}
    },
    Special = {
        ["Телепорт"] = {},
        ["Взрыв"] = {},
        ["Гравитация"] = {}
    }
}

local function ClearEffects()
    for _, effect in pairs(CurrentEffects) do
        if effect then
            effect:Destroy()
        end
    end
    CurrentEffects = {}
end

local function PlayEmote(emoteName)
    if CurrentAnimation then
        CurrentAnimation:Stop()
    end
    
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and EffectsLibrary.Emotes[emoteName] then
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://"..EffectsLibrary.Emotes[emoteName]
        CurrentAnimation = humanoid:LoadAnimation(animation)
        CurrentAnimation:Play()
        RemoteEvent:FireServer("PlayEmote", EffectsLibrary.Emotes[emoteName])
    end
end

local function CreateEffect(effectName)
    ClearEffects()
    
    local character = Player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local effectData = EffectsLibrary.Effects[effectName]
    if not effectData then return end
    
    if effectData.Type == "ParticleTrail" then
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = effectData.Texture
        emitter.Color = ColorSequence.new(effectData.Color)
        emitter.Size = NumberSequence.new(effectData.Size)
        emitter.Lifetime = NumberRange.new(effectData.Lifetime)
        emitter.Speed = NumberRange.new(effectData.Speed)
        emitter.LightEmission = 0.8
        emitter.Parent = rootPart
        table.insert(CurrentEffects, emitter)
        RemoteEvent:FireServer("CreateEffect", effectName)
        
    elseif effectData.Type == "ParticleAura" then
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = effectData.Texture
        emitter.Color = ColorSequence.new(effectData.Color)
        emitter.Size = NumberSequence.new(effectData.Size)
        emitter.Lifetime = NumberRange.new(effectData.Lifetime)
        emitter.Speed = NumberRange.new(effectData.Speed)
        emitter.Shape = Enum.ParticleEmitterShape.Sphere
        emitter.LightEmission = 0.8
        emitter.Parent = rootPart
        table.insert(CurrentEffects, emitter)
        RemoteEvent:FireServer("CreateEffect", effectName)
        
    elseif effectData.Type == "Confetti" then
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = effectData.Texture
        emitter.Color = ColorSequence.new(unpack(effectData.Colors))
        emitter.Size = NumberSequence.new(effectData.Size)
        emitter.Lifetime = NumberRange.new(effectData.Lifetime)
        emitter.Speed = NumberRange.new(effectData.Speed)
        emitter.Acceleration = Vector3.new(0, -15, 0)
        emitter.LightEmission = 0.6
        emitter.Parent = rootPart
        table.insert(CurrentEffects, emitter)
        RemoteEvent:FireServer("CreateEffect", effectName)
    end
end

local function PlaySound(soundName)
    local soundId = EffectsLibrary.Sounds[soundName]
    if not soundId then return end
    
    local character = Player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if head then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://"..soundId
        sound.Parent = head
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 10)
        RemoteEvent:FireServer("PlaySound", soundId)
    end
end

local function Transform(transformationName)
    local transformData = EffectsLibrary.Transformations[transformationName]
    if not transformData then return end
    
    local character = Player.Character
    if not character then return end
    
    if transformData.Transparency then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = transformData.Transparency
            end
        end
    end
    
    if transformData.Scale then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * transformData.Scale
            end
        end
    end
    
    RemoteEvent:FireServer("Transform", transformationName)
end

local function SpecialAction(actionName)
    if actionName == "Телепорт" then
        local character = Player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
            RemoteEvent:FireServer("SpecialAction", "Телепорт")
        end
        
    elseif actionName == "Взрыв" then
        RemoteEvent:FireServer("SpecialAction", "Взрыв")
        
    elseif actionName == "Гравитация" then
        local character = Player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 100
                RemoteEvent:FireServer("SpecialAction", "Гравитация")
            end
        end
    end
end

local function CreateTabButtons()
    for i, tabName in ipairs(Tabs) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1/#Tabs, -2, 1, 0)
        button.Position = UDim2.new((i-1)/#Tabs, 0, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = tabName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.Parent = TabButtons
        
        button.MouseButton1Click:Connect(function()
            ContentFrame:ClearAllChildren()
            local yOffset = 5
            
            if tabName == "Эмоции" then
                for emoteName in pairs(EffectsLibrary.Emotes) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = emoteName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        PlayEmote(emoteName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            
            elseif tabName == "Эффекты" then
                for effectName in pairs(EffectsLibrary.Effects) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = effectName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        CreateEffect(effectName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            
            elseif tabName == "Звуки" then
                for soundName in pairs(EffectsLibrary.Sounds) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = soundName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        PlaySound(soundName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            
            elseif tabName == "Трансформации" then
                for transformName in pairs(EffectsLibrary.Transformations) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = transformName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        Transform(transformName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            
            elseif tabName == "Особые" then
                for actionName in pairs(EffectsLibrary.Special) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = actionName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        SpecialAction(actionName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            end
            
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
        end)
    end
end

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Size = UDim2.new(0, 350, 0, 30)
    ContentFrame.Visible = false
    TabButtons.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CreateTabButtons()
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

RemoteEvent.OnClientEvent:Connect(function(action, data, senderId)
    local sender = game:GetService("Players"):GetPlayerByUserId(senderId)
    if not sender or sender == Player then return end
    
    if action == "PlayEmote" and sender.Character then
        local humanoid = sender.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://"..data
            local track = humanoid:LoadAnimation(animation)
            track:Play()
        end
        
    elseif action == "CreateEffect" and sender.Character then
        local character = sender.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local effectData = EffectsLibrary.Effects[data]
        if not effectData then return end
        
        if effectData.Type == "ParticleTrail" then
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = effectData.Texture
            emitter.Color = ColorSequence.new(effectData.Color)
            emitter.Size = NumberSequence.new(effectData.Size)
            emitter.Lifetime = NumberRange.new(effectData.Lifetime)
            emitter.Speed = NumberRange.new(effectData.Speed)
            emitter.LightEmission = 0.8
            emitter.Parent = rootPart
            game:GetService("Debris"):AddItem(emitter, 10)
            
        elseif effectData.Type == "ParticleAura" then
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = effectData.Texture
            emitter.Color = ColorSequence.new(effectData.Color)
            emitter.Size = NumberSequence.new(effectData.Size)
            emitter.Lifetime = NumberRange.new(effectData.Lifetime)
            emitter.Speed = NumberRange.new(effectData.Speed)
            emitter.Shape = Enum.ParticleEmitterShape.Sphere
            emitter.LightEmission = 0.8
            emitter.Parent = rootPart
            game:GetService("Debris"):AddItem(emitter, 10)
            
        elseif effectData.Type == "Confetti" then
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = effectData.Texture
            emitter.Color = ColorSequence.new(unpack(effectData.Colors))
            emitter.Size = NumberSequence.new(effectData.Size)
            emitter.Lifetime = NumberRange.new(effectData.Lifetime)
            emitter.Speed = NumberRange.new(effectData.Speed)
            emitter.Acceleration = Vector3.new(0, -15, 0)
            emitter.LightEmission = 0.6
            emitter.Parent = rootPart
            game:GetService("Debris"):AddItem(emitter, 10)
        end
        
    elseif action == "PlaySound" and sender.Character then
        local head = sender.Character:FindFirstChild("Head")
        if head then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://"..data
            sound.Parent = head
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 10)
        end
        
    elseif action == "Transform" and sender.Character then
        local transformData = EffectsLibrary.Transformations[data]
        if not transformData then return end
        
        local character = sender.Character
        if transformData.Transparency then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = transformData.Transparency
                end
            end
        end
        
        if transformData.Scale then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * transformData.Scale
                end
            end
        end
        
    elseif action == "SpecialAction" then
        if data == "Телепорт" and sender.Character then
            local rootPart = sender.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
            end
            
        elseif data == "Взрыв" then
            local explosion = Instance.new("Explosion")
            explosion.Position = sender.Character.HumanoidRootPart.Position
            explosion.BlastPressure = 0
            explosion.BlastRadius = 10
            explosion.Visible = true
            explosion.Parent = workspace
            
        elseif data == "Гравитация" and sender.Character then
            local humanoid = sender.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 100
            end
        end
    end
end)

if game:GetService("RunService"):IsServer() then
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local RemoteEvent = ReplicatedStorage:WaitForChild("GlobalEffects")
    
    RemoteEvent.OnServerEvent:Connect(function(player, action, data)
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                RemoteEvent:FireClient(otherPlayer, action, data, player.UserId)
            end
        end
    end)
end