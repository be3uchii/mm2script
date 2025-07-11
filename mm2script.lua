local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Settings = {
    Menu = {
        Open = true,
        Minimized = false,
        Position = UDim2.new(0.5, -175, 0.5, -200),
        Size = UDim2.new(0, 350, 0, 500),
        MinimizedSize = UDim2.new(0, 350, 0, 30),
        AccentColor = Color3.fromRGB(0, 150, 255)
    },
    
    ESP = {
        Enabled = false,
        BoxSize = 1,
        Tracers = false,
        AllPlayers = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Box = false,
            Tracer = false,
            Highlight = false,
            Outline = false
        },
        Murderer = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 0),
            Box = true,
            Tracer = true,
            Highlight = true,
            Outline = true
        },
        Sheriff = {
            Enabled = false,
            Color = Color3.fromRGB(0, 0, 255),
            Box = true,
            Tracer = true,
            Highlight = true,
            Outline = true
        },
        Innocent = {
            Enabled = false,
            Color = Color3.fromRGB(0, 255, 0),
            Box = false,
            Tracer = false,
            Highlight = false,
            Outline = false
        },
        Gun = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 0),
            Type = "Text"
        },
        Coins = {
            Enabled = false,
            Color = Color3.fromRGB(255, 215, 0)
        },
        Traps = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 255)
        }
    },
    
    Sheriff = {
        AutoShoot = {
            Enabled = false,
            Key = "C",
            Visible = true,
            Position = UDim2.new(0.8, -25, 0.7, -25),
            FOV = 70,
            Size = 1,
            Transparency = 0.5
        }
    },
    
    Murderer = {
        KillAura = {
            Enabled = false,
            Range = 30,
            AutoClick = true,
            AllPlayers = false,
            SheriffOnly = false,
            ExceptFriends = false,
            TargetName = ""
        }
    },
    
    Teleport = {
        SafePlace = false,
        ToMurderer = false,
        ToSheriff = false,
        ToGun = false,
        ToPlayer = {
            Enabled = false,
            Name = ""
        },
        Lobby = false,
        Map = false
    },
    
    Misc = {
        GrabGun = false,
        Run = false,
        Noclip = false,
        DoubleJump = false,
        NoBarriers = false,
        SpamEmote = false,
        FakeDead = false,
        TwoLive = false,
        Xray = {
            Enabled = false,
            Transparency = 30
        }
    },
    
    RolePlay = {
        NotifyRoles = false,
        ChatRoles = false,
        RoundTimer = false
    }
}

local GUI, AutoShootButton, MenuButton
local Sheriff, Murderer
local ESPCache = {}
local Connections = {}
local Teleporting = false
local LastKillAuraTime = 0

local function CreateESP(object, settings)
    if ESPCache[object] then return end
    
    local esp = {
        Highlight = nil,
        Box = nil,
        Tracer = nil,
        Outline = nil
    }
    
    if settings.Highlight then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight_"..object.Name
        highlight.Adornee = object
        highlight.FillColor = settings.Color
        highlight.OutlineColor = settings.Color
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = object
        esp.Highlight = highlight
    end
    
    if settings.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_Box_"..object.Name
        box.Adornee = object
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = object:IsA("BasePart") and object.Size * Settings.ESP.BoxSize or Vector3.new(2, 2, 2) * Settings.ESP.BoxSize
        box.Transparency = 0.5
        box.Color3 = settings.Color
        box.Parent = object
        esp.Box = box
    end
    
    if settings.Outline then
        local outline = Instance.new("SelectionBox")
        outline.Name = "ESP_Outline_"..object.Name
        outline.Adornee = object
        outline.LineThickness = 0.05
        outline.Color3 = settings.Color
        outline.Transparency = 0.5
        outline.Parent = object
        esp.Outline = outline
    end
    
    ESPCache[object] = esp
    
    object.AncestryChanged:Connect(function()
        if not object:IsDescendantOf(game) then
            RemoveESP(object)
        end
    end)
end

local function RemoveESP(object)
    if not ESPCache[object] then return end
    
    if ESPCache[object].Highlight then ESPCache[object].Highlight:Destroy() end
    if ESPCache[object].Box then ESPCache[object].Box:Destroy() end
    if ESPCache[object].Outline then ESPCache[object].Outline:Destroy() end
    if ESPCache[object].Tracer then ESPCache[object].Tracer:Remove() end
    
    ESPCache[object] = nil
end

local function UpdateESP()
    if not Settings.ESP.Enabled then
        for object,_ in pairs(ESPCache) do
            RemoveESP(object)
        end
        return
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                if player == Murderer then
                    if Settings.ESP.Murderer.Enabled then
                        CreateESP(rootPart, Settings.ESP.Murderer)
                    else
                        RemoveESP(rootPart)
                    end
                elseif player == Sheriff then
                    if Settings.ESP.Sheriff.Enabled then
                        CreateESP(rootPart, Settings.ESP.Sheriff)
                    else
                        RemoveESP(rootPart)
                    end
                elseif Settings.ESP.AllPlayers.Enabled then
                    CreateESP(rootPart, Settings.ESP.AllPlayers)
                elseif Settings.ESP.Innocent.Enabled then
                    CreateESP(rootPart, Settings.ESP.Innocent)
                else
                    RemoveESP(rootPart)
                end
            else
                RemoveESP(rootPart)
            end
        end
    end

    if Settings.ESP.Gun.Enabled then
        for _,gun in ipairs(workspace:GetChildren()) do
            if gun.Name == "GunDrop" or gun:IsA("Tool") then
                CreateESP(gun, {
                    Color = Settings.ESP.Gun.Color,
                    Highlight = true,
                    Box = Settings.ESP.Gun.Type == "Box",
                    Outline = false,
                    Tracer = false
                })
            end
        end
    end

    if Settings.ESP.Coins.Enabled then
        for _,coin in ipairs(workspace:GetChildren()) do
            if coin.Name:find("Coin") or coin.Name:find("Diamond") then
                CreateESP(coin, {
                    Color = Settings.ESP.Coins.Color,
                    Highlight = true,
                    Box = false,
                    Outline = false,
                    Tracer = false
                })
            end
        end
    end

    if Settings.ESP.Traps.Enabled then
        for _,trap in ipairs(workspace:GetChildren()) do
            if trap.Name:find("Trap") then
                CreateESP(trap, {
                    Color = Settings.ESP.Traps.Color,
                    Highlight = true,
                    Box = false,
                    Outline = false,
                    Tracer = false
                })
            end
        end
    end
end

local function FindRoles()
    Sheriff = nil
    Murderer = nil
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
            local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
            
            if knife then
                Murderer = player
            elseif gun then
                Sheriff = player
            end
        end
    end
end

local function AutoShoot()
    if not Settings.Sheriff.AutoShoot.Enabled or not AutoShootButton or not Sheriff or Sheriff ~= Player then return end
    if not Player.Character then return end
    
    local gun = Player.Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if not gun then return end
    
    if Murderer and Murderer.Character then
        local targetHRP = Murderer.Character:FindFirstChild("HumanoidRootPart")
        local localHRP = Player.Character:FindFirstChild("HumanoidRootPart")
        
        if targetHRP and localHRP then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                local distance = (mousePos - center).Magnitude
                
                if distance <= Settings.Sheriff.AutoShoot.FOV or not Settings.Sheriff.AimAssist.Enabled then
                    local args = {
                        [1] = targetHRP.Position,
                        [2] = gun:FindFirstChild("Handle") or gun
                    }
                    game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun"):FireServer(unpack(args))
                end
            end
        end
    end
end

local function KillAura()
    if not Settings.Murderer.KillAura.Enabled or not Murderer or Murderer ~= Player then return end
    if not Player.Character then return end
    
    local now = tick()
    if now - LastKillAuraTime < Settings.Murderer.KillAura.Cooldown then return end
    
    local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local knife = Player.Character:FindFirstChild("Knife") or Player.Backpack:FindFirstChild("Knife")
    if not knife then return end
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
                if distance <= Settings.Murderer.KillAura.Range then
                    if Settings.Murderer.KillAura.SheriffOnly and player ~= Sheriff then continue end
                    if Settings.Murderer.KillAura.ExceptFriends and player:IsFriendsWith(Player.UserId) then continue end
                    if Settings.Murderer.KillAura.TargetName ~= "" and player.Name ~= Settings.Murderer.KillAura.TargetName then continue end
                    
                    local args = {
                        [1] = player.Character:FindFirstChildOfClass("Humanoid"),
                        [2] = knife
                    }
                    game:GetService("ReplicatedStorage"):FindFirstChild("KnifeHit"):FireServer(unpack(args))
                    LastKillAuraTime = now
                    
                    if not Settings.Murderer.KillAura.AutoClick then break end
                end
            end
        end
    end
end

local function TeleportTo(target)
    if Teleporting then return end
    Teleporting = true
    
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if target == "SafePlace" then
        local safePlace = workspace:FindFirstChild("SafePlace")
        if safePlace then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            rootPart.CFrame = safePlace.CFrame + Vector3.new(0, 3, 0)
        end
    elseif target == "Murderer" and Murderer and Murderer.Character then
        local targetHRP = Murderer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            rootPart.CFrame = targetHRP.CFrame + (targetHRP.CFrame.LookVector * -3)
        end
    elseif target == "Sheriff" and Sheriff and Sheriff.Character then
        local targetHRP = Sheriff.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            rootPart.CFrame = targetHRP.CFrame + (targetHRP.CFrame.LookVector * -3)
        end
    elseif target == "Gun" then
        local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChildOfClass("Tool")
        if gun then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            rootPart.CFrame = gun:IsA("BasePart") and gun.CFrame or gun.Handle.CFrame
        end
    elseif target == "Lobby" then
        local lobby = workspace:FindFirstChild("Lobby")
        if lobby then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            rootPart.CFrame = lobby.CFrame + Vector3.new(0, 3, 0)
        end
    elseif target == "Map" then
        local map = workspace:FindFirstChild("Map")
        if map then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            rootPart.CFrame = map.CFrame + Vector3.new(0, 3, 0)
        end
    end
    
    wait(0.5)
    Teleporting = false
end

local function GrabGun()
    if not Settings.Misc.GrabGun then return end
    if not Player.Character then return end
    
    local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChildOfClass("Tool")
    if not gun then return end
    
    local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if gun:IsA("Tool") then
        gun.Parent = Player.Backpack
    else
        humanoidRootPart.CFrame = gun.CFrame
    end
end

local function ToggleNoclip()
    if not Settings.Misc.Noclip or not Player.Character then return end
    
    for _,part in ipairs(Player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not Settings.Misc.Noclip
        end
    end
end

local function DoubleJump()
    if not Settings.Misc.DoubleJump or not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

local function RemoveBarriers()
    if not Settings.Misc.NoBarriers then return end
    
    for _,part in ipairs(workspace:GetDescendants()) do
        if part.Name:find("Barrier") or part.Name:find("Wall") then
            part.CanCollide = false
            part.Transparency = 0.8
        end
    end
end

local function SpamEmote()
    if not Settings.Misc.SpamEmote then return end
    if not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid:LoadAnimation(Instance.new("Animation")):Play()
end

local function FakeDead()
    if not Settings.Misc.FakeDead then return end
    if not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.Health = 0
end

local function TwoLive()
    if not Settings.Misc.TwoLive then return end
    if not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.MaxHealth = 200
    humanoid.Health = 200
end

local function ToggleXray()
    if not Settings.Misc.Xray.Enabled then return end
    
    for _,part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(Player.Character) then
            part.LocalTransparencyModifier = Settings.Misc.Xray.Transparency / 100
        end
    end
end

local function NotifyRoles()
    if not Settings.RolePlay.NotifyRoles then return end
    
    if Murderer then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Murderer",
            Text = Murderer.Name,
            Duration = 5
        })
    end
    
    if Sheriff then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sheriff",
            Text = Sheriff.Name,
            Duration = 5
        })
    end
end

local function ChatRoles()
    if not Settings.RolePlay.ChatRoles then return end
    
    if Murderer then
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Murderer: "..Murderer.Name)
    end
    
    if Sheriff then
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Sheriff: "..Sheriff.Name)
    end
end

local function UpdateRoundTimer()
    if not Settings.RolePlay.RoundTimer then return end
    
    local timer = workspace:FindFirstChild("RoundTimer")
    if timer then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Round Timer",
            Text = tostring(timer.Value),
            Duration = 1
        })
    end
end

local function CreateToggle(parent, name, setting, yOffset)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name.."Toggle"
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.Position = UDim2.new(0, 5, 0, yOffset)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 100, 0, 25)
    toggleButton.Position = UDim2.new(1, -105, 0, 0)
    toggleButton.BackgroundColor3 = setting and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = setting and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 14
    toggleButton.Parent = toggleFrame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 180, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    toggleButton.MouseButton1Click:Connect(function()
        setting = not setting
        toggleButton.BackgroundColor3 = setting and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.Text = setting and "ON" or "OFF"
    end)

    return toggleFrame, toggleButton
end

local function CreateSlider(parent, name, setting, min, max, yOffset)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name.."Slider"
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.Position = UDim2.new(0, 5, 0, yOffset)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "SliderLabel"
    sliderLabel.Size = UDim2.new(1, 0, 0, 25)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name..": "..tostring(setting)
    sliderLabel.TextColor3 = Color3.new(1, 1, 1)
    sliderLabel.Font = Enum.Font.SourceSansBold
    sliderLabel.TextSize = 16
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBox = Instance.new("TextBox")
    sliderBox.Name = "SliderBox"
    sliderBox.Size = UDim2.new(0, 100, 0, 25)
    sliderBox.Position = UDim2.new(1, -105, 0, 0)
    sliderBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBox.BorderSizePixel = 0
    sliderBox.Text = tostring(setting)
    sliderBox.TextColor3 = Color3.new(1, 1, 1)
    sliderBox.Font = Enum.Font.SourceSans
    sliderBox.TextSize = 14
    sliderBox.Parent = sliderFrame

    sliderBox.FocusLost:Connect(function()
        local num = tonumber(sliderBox.Text)
        if num then
            setting = math.clamp(num, min, max)
            sliderBox.Text = tostring(setting)
            sliderLabel.Text = name..": "..tostring(setting)
        else
            sliderBox.Text = tostring(setting)
        end
    end)

    return sliderFrame
end

local function CreateButton(parent, name, yOffset, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = name.."Button"
    buttonFrame.Size = UDim2.new(1, -10, 0, 30)
    buttonFrame.Position = UDim2.new(0, 5, 0, yOffset)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = parent

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Settings.Menu.AccentColor
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = buttonFrame

    button.MouseButton1Click:Connect(callback)

    return buttonFrame
end

local function CreateInput(parent, name, yOffset, callback)
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = name.."Input"
    inputFrame.Size = UDim2.new(1, -10, 0, 50)
    inputFrame.Position = UDim2.new(0, 5, 0, yOffset)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 180, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = inputFrame

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(0, 150, 0, 25)
    inputBox.Position = UDim2.new(1, -155, 0, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 14
    inputBox.Parent = inputFrame

    inputBox.FocusLost:Connect(function()
        callback(inputBox.Text)
    end)

    return inputFrame
end

local function CreateInfoFrame(parent, text, yOffset)
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, -10, 0, 80)
    infoFrame.Position = UDim2.new(0, 5, 0, yOffset)
    infoFrame.BackgroundTransparency = 1
    infoFrame.Parent = parent

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.Position = UDim2.new(0, 0, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = text
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 14
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = infoFrame

    return infoFrame
end

local function CreateGUI()
    GUI = Instance.new("ScreenGui")
    GUI.Name = "XHubMM2"
    GUI.ResetOnSpawn = false
    GUI.Parent = Player.PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Settings.Menu.Open and (Settings.Menu.Minimized and Settings.Menu.MinimizedSize or Settings.Menu.Size)
    MainFrame.Position = Settings.Menu.Position
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.BorderSizePixel = 0
    Title.Text = "Xhub : Murder Mystery 2 : v6.3"
    Title.TextColor3 = Settings.Menu.AccentColor
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = MainFrame

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = Settings.Menu.Minimized and "+" or "-"
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = MainFrame

    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 0, 30)
    TabButtons.Position = UDim2.new(0, 0, 0, 30)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Visible = not Settings.Menu.Minimized
    TabButtons.Parent = MainFrame

    local ESPTab = Instance.new("TextButton")
    ESPTab.Name = "ESPTab"
    ESPTab.Size = UDim2.new(0.25, -2, 1, 0)
    ESPTab.Position = UDim2.new(0, 0, 0, 0)
    ESPTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPTab.BorderSizePixel = 0
    ESPTab.Text = "ESP"
    ESPTab.TextColor3 = Color3.new(1, 1, 1)
    ESPTab.Font = Enum.Font.SourceSansBold
    ESPTab.TextSize = 14
    ESPTab.Parent = TabButtons

    local CombatTab = Instance.new("TextButton")
    CombatTab.Name = "CombatTab"
    CombatTab.Size = UDim2.new(0.25, -2, 1, 0)
    CombatTab.Position = UDim2.new(0.25, 0, 0, 0)
    CombatTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CombatTab.BorderSizePixel = 0
    CombatTab.Text = "Combat"
    CombatTab.TextColor3 = Color3.new(1, 1, 1)
    CombatTab.Font = Enum.Font.SourceSansBold
    CombatTab.TextSize = 14
    CombatTab.Parent = TabButtons

    local TeleportTab = Instance.new("TextButton")
    TeleportTab.Name = "TeleportTab"
    TeleportTab.Size = UDim2.new(0.25, -2, 1, 0)
    TeleportTab.Position = UDim2.new(0.5, 0, 0, 0)
    TeleportTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TeleportTab.BorderSizePixel = 0
    TeleportTab.Text = "Teleport"
    TeleportTab.TextColor3 = Color3.new(1, 1, 1)
    TeleportTab.Font = Enum.Font.SourceSansBold
    TeleportTab.TextSize = 14
    TeleportTab.Parent = TabButtons

    local MiscTab = Instance.new("TextButton")
    MiscTab.Name = "MiscTab"
    MiscTab.Size = UDim2.new(0.25, -2, 1, 0)
    MiscTab.Position = UDim2.new(0.75, 0, 0, 0)
    MiscTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MiscTab.BorderSizePixel = 0
    MiscTab.Text = "Misc"
    MiscTab.TextColor3 = Color3.new(1, 1, 1)
    MiscTab.Font = Enum.Font.SourceSansBold
    MiscTab.TextSize = 14
    MiscTab.Parent = TabButtons

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -70)
    TabContainer.Position = UDim2.new(0, 5, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Visible = not Settings.Menu.Minimized
    TabContainer.Parent = MainFrame

    local ESPContainer = Instance.new("ScrollingFrame")
    ESPContainer.Name = "ESPContainer"
    ESPContainer.Size = UDim2.new(1, 0, 1, 0)
    ESPContainer.BackgroundTransparency = 1
    ESPContainer.ScrollBarThickness = 5
    ESPContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
    ESPContainer.Visible = true
    ESPContainer.Parent = TabContainer

    local CombatContainer = Instance.new("ScrollingFrame")
    CombatContainer.Name = "CombatContainer"
    CombatContainer.Size = UDim2.new(1, 0, 1, 0)
    CombatContainer.BackgroundTransparency = 1
    CombatContainer.ScrollBarThickness = 5
    CombatContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
    CombatContainer.Visible = false
    CombatContainer.Parent = TabContainer

    local TeleportContainer = Instance.new("ScrollingFrame")
    TeleportContainer.Name = "TeleportContainer"
    TeleportContainer.Size = UDim2.new(1, 0, 1, 0)
    TeleportContainer.BackgroundTransparency = 1
    TeleportContainer.ScrollBarThickness = 5
    TeleportContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
    TeleportContainer.Visible = false
    TeleportContainer.Parent = TabContainer

    local MiscContainer = Instance.new("ScrollingFrame")
    MiscContainer.Name = "MiscContainer"
    MiscContainer.Size = UDim2.new(1, 0, 1, 0)
    MiscContainer.BackgroundTransparency = 1
    MiscContainer.ScrollBarThickness = 5
    MiscContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
    MiscContainer.Visible = false
    MiscContainer.Parent = TabContainer

    local yOffset = 0
    CreateToggle(ESPContainer, "ESP", Settings.ESP.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local espNameHeader = Instance.new("TextLabel")
    espNameHeader.Name = "ESPNameHeader"
    espNameHeader.Size = UDim2.new(1, -10, 0, 20)
    espNameHeader.Position = UDim2.new(0, 5, 0, yOffset)
    espNameHeader.BackgroundTransparency = 1
    espNameHeader.Text = "ESP / Name"
    espNameHeader.TextColor3 = Settings.Menu.AccentColor
    espNameHeader.Font = Enum.Font.SourceSansBold
    espNameHeader.TextSize = 16
    espNameHeader.TextXAlignment = Enum.TextXAlignment.Left
    espNameHeader.Parent = ESPContainer
    yOffset = yOffset + 25
    
    CreateToggle(ESPContainer, "ESP All Players", Settings.ESP.AllPlayers.Enabled, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Murderer", Settings.ESP.Murderer.Enabled, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Sheriff", Settings.ESP.Sheriff.Enabled, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Innocent", Settings.ESP.Innocent.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local espHighlightHeader = Instance.new("TextLabel")
    espHighlightHeader.Name = "ESPHighlightHeader"
    espHighlightHeader.Size = UDim2.new(1, -10, 0, 20)
    espHighlightHeader.Position = UDim2.new(0, 5, 0, yOffset)
    espHighlightHeader.BackgroundTransparency = 1
    espHighlightHeader.Text = "ESP / Highlights"
    espHighlightHeader.TextColor3 = Settings.Menu.AccentColor
    espHighlightHeader.Font = Enum.Font.SourceSansBold
    espHighlightHeader.TextSize = 16
    espHighlightHeader.TextXAlignment = Enum.TextXAlignment.Left
    espHighlightHeader.Parent = ESPContainer
    yOffset = yOffset + 25
    
    CreateToggle(ESPContainer, "ESP All Players", Settings.ESP.AllPlayers.Highlight, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Murderer", Settings.ESP.Murderer.Highlight, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Sheriff", Settings.ESP.Sheriff.Highlight, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Innocent", Settings.ESP.Innocent.Highlight, yOffset)
    yOffset = yOffset + 35
    
    local espOutlineHeader = Instance.new("TextLabel")
    espOutlineHeader.Name = "ESPOutlineHeader"
    espOutlineHeader.Size = UDim2.new(1, -10, 0, 20)
    espOutlineHeader.Position = UDim2.new(0, 5, 0, yOffset)
    espOutlineHeader.BackgroundTransparency = 1
    espOutlineHeader.Text = "ESP / Outline"
    espOutlineHeader.TextColor3 = Settings.Menu.AccentColor
    espOutlineHeader.Font = Enum.Font.SourceSansBold
    espOutlineHeader.TextSize = 16
    espOutlineHeader.TextXAlignment = Enum.TextXAlignment.Left
    espOutlineHeader.Parent = ESPContainer
    yOffset = yOffset + 25
    
    CreateToggle(ESPContainer, "ESP All Players", Settings.ESP.AllPlayers.Outline, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Murderer", Settings.ESP.Murderer.Outline, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Sheriff", Settings.ESP.Sheriff.Outline, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Innocent", Settings.ESP.Innocent.Outline, yOffset)
    yOffset = yOffset + 35
    
    local espTracerHeader = Instance.new("TextLabel")
    espTracerHeader.Name = "ESPTracerHeader"
    espTracerHeader.Size = UDim2.new(1, -10, 0, 20)
    espTracerHeader.Position = UDim2.new(0, 5, 0, yOffset)
    espTracerHeader.BackgroundTransparency = 1
    espTracerHeader.Text = "ESP / Tracer & Box"
    espTracerHeader.TextColor3 = Settings.Menu.AccentColor
    espTracerHeader.Font = Enum.Font.SourceSansBold
    espTracerHeader.TextSize = 16
    espTracerHeader.TextXAlignment = Enum.TextXAlignment.Left
    espTracerHeader.Parent = ESPContainer
    yOffset = yOffset + 25
    
    CreateToggle(ESPContainer, "ESP Tracer All Players", Settings.ESP.AllPlayers.Tracer, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Tracer Murderer", Settings.ESP.Murderer.Tracer, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Tracer Sheriff", Settings.ESP.Sheriff.Tracer, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Tracer Innocent", Settings.ESP.Innocent.Tracer, yOffset)
    yOffset = yOffset + 35
    
    local espBoxHeader = Instance.new("TextLabel")
    espBoxHeader.Name = "ESPBoxHeader"
    espBoxHeader.Size = UDim2.new(1, -10, 0, 20)
    espBoxHeader.Position = UDim2.new(0, 5, 0, yOffset)
    espBoxHeader.BackgroundTransparency = 1
    espBoxHeader.Text = "ESP / Box"
    espBoxHeader.TextColor3 = Settings.Menu.AccentColor
    espBoxHeader.Font = Enum.Font.SourceSansBold
    espBoxHeader.TextSize = 16
    espBoxHeader.TextXAlignment = Enum.TextXAlignment.Left
    espBoxHeader.Parent = ESPContainer
    yOffset = yOffset + 25
    
    CreateToggle(ESPContainer, "ESP Box All Players", Settings.ESP.AllPlayers.Box, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Box Murderer", Settings.ESP.Murderer.Box, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Box Sheriff", Settings.ESP.Sheriff.Box, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Box Innocent", Settings.ESP.Innocent.Box, yOffset)
    yOffset = yOffset + 35
    
    local espRoundsHeader = Instance.new("TextLabel")
    espRoundsHeader.Name = "ESPRoundsHeader"
    espRoundsHeader.Size = UDim2.new(1, -10, 0, 20)
    espRoundsHeader.Position = UDim2.new(0, 5, 0, yOffset)
    espRoundsHeader.BackgroundTransparency = 1
    espRoundsHeader.Text = "ESP / Rounds"
    espRoundsHeader.TextColor3 = Settings.Menu.AccentColor
    espRoundsHeader.Font = Enum.Font.SourceSansBold
    espRoundsHeader.TextSize = 16
    espRoundsHeader.TextXAlignment = Enum.TextXAlignment.Left
    espRoundsHeader.Parent = ESPContainer
    yOffset = yOffset + 25
    
    CreateToggle(ESPContainer, "ESP Gun", Settings.ESP.Gun.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local gunTypeFrame = Instance.new("Frame")
    gunTypeFrame.Name = "GunTypeFrame"
    gunTypeFrame.Size = UDim2.new(1, -10, 0, 30)
    gunTypeFrame.Position = UDim2.new(0, 5, 0, yOffset)
    gunTypeFrame.BackgroundTransparency = 1
    gunTypeFrame.Parent = ESPContainer
    
    local gunTypeLabel = Instance.new("TextLabel")
    gunTypeLabel.Name = "GunTypeLabel"
    gunTypeLabel.Size = UDim2.new(0, 180, 0, 25)
    gunTypeLabel.Position = UDim2.new(0, 0, 0, 0)
    gunTypeLabel.BackgroundTransparency = 1
    gunTypeLabel.Text = "ESP Gun Type"
    gunTypeLabel.TextColor3 = Color3.new(1, 1, 1)
    gunTypeLabel.Font = Enum.Font.SourceSansBold
    gunTypeLabel.TextSize = 16
    gunTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    gunTypeLabel.Parent = gunTypeFrame
    
    local gunTypeButton = Instance.new("TextButton")
    gunTypeButton.Name = "GunTypeButton"
    gunTypeButton.Size = UDim2.new(0, 100, 0, 25)
    gunTypeButton.Position = UDim2.new(1, -105, 0, 0)
    gunTypeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    gunTypeButton.BorderSizePixel = 0
    gunTypeButton.Text = Settings.ESP.Gun.Type
    gunTypeButton.TextColor3 = Color3.new(1, 1, 1)
    gunTypeButton.Font = Enum.Font.SourceSans
    gunTypeButton.TextSize = 14
    gunTypeButton.Parent = gunTypeFrame
    
    gunTypeButton.MouseButton1Click:Connect(function()
        Settings.ESP.Gun.Type = Settings.ESP.Gun.Type == "Text" and "Box" or "Text"
        gunTypeButton.Text = Settings.ESP.Gun.Type
    end)
    
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Traps", Settings.ESP.Traps.Enabled, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "ESP Coins", Settings.ESP.Coins.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local espBoxSizeSlider = CreateSlider(ESPContainer, "ESP Box Size", Settings.ESP.BoxSize, 0.5, 3, yOffset)
    yOffset = yOffset + 55

    yOffset = 0
    local murdererHeader = Instance.new("TextLabel")
    murdererHeader.Name = "MurdererHeader"
    murdererHeader.Size = UDim2.new(1, -10, 0, 20)
    murdererHeader.Position = UDim2.new(0, 5, 0, yOffset)
    murdererHeader.BackgroundTransparency = 1
    murdererHeader.Text = "Murderer"
    murdererHeader.TextColor3 = Settings.Menu.AccentColor
    murdererHeader.Font = Enum.Font.SourceSansBold
    murdererHeader.TextSize = 16
    murdererHeader.TextXAlignment = Enum.TextXAlignment.Left
    murdererHeader.Parent = CombatContainer
    yOffset = yOffset + 25
    
    CreateButton(CombatContainer, "Kill all", yOffset, function()
        if Murderer and Murderer == Player then
            for _,player in ipairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local args = {
                            [1] = humanoid,
                            [2] = Player.Character:FindFirstChild("Knife") or Player.Backpack:FindFirstChild("Knife")
                        }
                        game:GetService("ReplicatedStorage"):FindFirstChild("KnifeHit"):FireServer(unpack(args))
                    end
                end
            end
        end
    end)
    yOffset = yOffset + 35
    
    CreateButton(CombatContainer, "Kill Sheriff", yOffset, function()
        if Murderer and Murderer == Player and Sheriff and Sheriff.Character then
            local humanoid = Sheriff.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local args = {
                    [1] = humanoid,
                    [2] = Player.Character:FindFirstChild("Knife") or Player.Backpack:FindFirstChild("Knife")
                }
                game:GetService("ReplicatedStorage"):FindFirstChild("KnifeHit"):FireServer(unpack(args))
            end
        end
    end)
    yOffset = yOffset + 35
    
    CreateInput(CombatContainer, "Enter Name for kill", yOffset, function(text)
        Settings.Murderer.KillAura.TargetName = text
    end)
    yOffset = yOffset + 55
    
    CreateToggle(CombatContainer, "Kill All Except Friends", Settings.Murderer.KillAura.ExceptFriends, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(CombatContainer, "Kill Aura", Settings.Murderer.KillAura.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local killAuraRangeSlider = CreateSlider(CombatContainer, "Kill Aura Range", Settings.Murderer.KillAura.Range, 5, 30, yOffset)
    yOffset = yOffset + 55
    
    CreateToggle(CombatContainer, "Auto Click", Settings.Murderer.KillAura.AutoClick, yOffset)
    yOffset = yOffset + 35
    
    local sheriffHeader = Instance.new("TextLabel")
    sheriffHeader.Name = "SheriffHeader"
    sheriffHeader.Size = UDim2.new(1, -10, 0, 20)
    sheriffHeader.Position = UDim2.new(0, 5, 0, yOffset)
    sheriffHeader.BackgroundTransparency = 1
    sheriffHeader.Text = "Sheriff"
    sheriffHeader.TextColor3 = Settings.Menu.AccentColor
    sheriffHeader.Font = Enum.Font.SourceSansBold
    sheriffHeader.TextSize = 16
    sheriffHeader.TextXAlignment = Enum.TextXAlignment.Left
    sheriffHeader.Parent = CombatContainer
    yOffset = yOffset + 25
    
    CreateToggle(CombatContainer, "Shoot Murderer", Settings.Sheriff.AutoShoot.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local shootFOVSlider = CreateSlider(CombatContainer, "Shoot FOV", Settings.Sheriff.AutoShoot.FOV, 10, 200, yOffset)
    yOffset = yOffset + 55
    
    local sizeButtonSlider = CreateSlider(CombatContainer, "Size Button", Settings.Sheriff.AutoShoot.Size, 0.5, 2, yOffset)
    yOffset = yOffset + 55
    
    local transparencyButtonSlider = CreateSlider(CombatContainer, "Transparency Button", Settings.Sheriff.AutoShoot.Transparency, 0, 1, yOffset)
    yOffset = yOffset + 55
    
    local innocentHeader = Instance.new("TextLabel")
    innocentHeader.Name = "InnocentHeader"
    innocentHeader.Size = UDim2.new(1, -10, 0, 20)
    innocentHeader.Position = UDim2.new(0, 5, 0, yOffset)
    innocentHeader.BackgroundTransparency = 1
    innocentHeader.Text = "Innocent"
    innocentHeader.TextColor3 = Settings.Menu.AccentColor
    innocentHeader.Font = Enum.Font.SourceSansBold
    innocentHeader.TextSize = 16
    innocentHeader.TextXAlignment = Enum.TextXAlignment.Left
    innocentHeader.Parent = CombatContainer
    yOffset = yOffset + 25
    
    CreateToggle(CombatContainer, "GunDrop", Settings.Misc.GrabGun, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(CombatContainer, "Fake Dead", Settings.Misc.FakeDead, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(CombatContainer, "Two Live", Settings.Misc.TwoLive, yOffset)
    yOffset = yOffset + 35

    yOffset = 0
    CreateButton(TeleportContainer, "Safe Place", yOffset, function()
        TeleportTo("SafePlace")
    end)
    yOffset = yOffset + 35
    
    CreateButton(TeleportContainer, "Murderer", yOffset, function()
        TeleportTo("Murderer")
    end)
    yOffset = yOffset + 35
    
    CreateButton(TeleportContainer, "Sheriff", yOffset, function()
        TeleportTo("Sheriff")
    end)
    yOffset = yOffset + 35
    
    CreateButton(TeleportContainer, "GunDrop", yOffset, function()
        TeleportTo("Gun")
    end)
    yOffset = yOffset + 35
    
    CreateInput(TeleportContainer, "Player Name", yOffset, function(text)
        Settings.Teleport.ToPlayer.Name = text
    end)
    yOffset = yOffset + 55
    
    CreateButton(TeleportContainer, "Teleport To Player", yOffset, function()
        if Settings.Teleport.ToPlayer.Name ~= "" then
            local target = Players:FindFirstChild(Settings.Teleport.ToPlayer.Name)
            if target and target.Character then
                local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    TeleportTo(humanoidRootPart)
                end
            end
        end
    end)
    yOffset = yOffset + 35
    
    CreateButton(TeleportContainer, "Teleport To closest Player", yOffset, function()
        local closestPlayer, closestDistance = nil, math.huge
        local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        
        if localRoot then
            for _,player in ipairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (localRoot.Position - targetRoot.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
            
            if closestPlayer then
                TeleportTo(closestPlayer.Character.HumanoidRootPart)
            end
        end
    end)
    yOffset = yOffset + 35

    yOffset = 0
    local rolePlayHeader = Instance.new("TextLabel")
    rolePlayHeader.Name = "RolePlayHeader"
    rolePlayHeader.Size = UDim2.new(1, -10, 0, 20)
    rolePlayHeader.Position = UDim2.new(0, 5, 0, yOffset)
    rolePlayHeader.BackgroundTransparency = 1
    rolePlayHeader.Text = "RolePlay"
    rolePlayHeader.TextColor3 = Settings.Menu.AccentColor
    rolePlayHeader.Font = Enum.Font.SourceSansBold
    rolePlayHeader.TextSize = 16
    rolePlayHeader.TextXAlignment = Enum.TextXAlignment.Left
    rolePlayHeader.Parent = MiscContainer
    yOffset = yOffset + 25
    
    CreateToggle(MiscContainer, "Notify Murderer & Sheriff", Settings.RolePlay.NotifyRoles, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "Send Murderer & Sheriff in chat", Settings.RolePlay.ChatRoles, yOffset)
    yOffset = yOffset + 35
    
    local roundSpecialHeader = Instance.new("TextLabel")
    roundSpecialHeader.Name = "RoundSpecialHeader"
    roundSpecialHeader.Size = UDim2.new(1, -10, 0, 20)
    roundSpecialHeader.Position = UDim2.new(0, 5, 0, yOffset)
    roundSpecialHeader.BackgroundTransparency = 1
    roundSpecialHeader.Text = "Round Special"
    roundSpecialHeader.TextColor3 = Settings.Menu.AccentColor
    roundSpecialHeader.Font = Enum.Font.SourceSansBold
    roundSpecialHeader.TextSize = 16
    roundSpecialHeader.TextXAlignment = Enum.TextXAlignment.Left
    roundSpecialHeader.Parent = MiscContainer
    yOffset = yOffset + 25
    
    CreateToggle(MiscContainer, "Auto Spam Emote", Settings.Misc.SpamEmote, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "Remove Barriers", Settings.Misc.NoBarriers, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "Round Timer", Settings.RolePlay.RoundTimer, yOffset)
    yOffset = yOffset + 35
    
    local xrayHeader = Instance.new("TextLabel")
    xrayHeader.Name = "XrayHeader"
    xrayHeader.Size = UDim2.new(1, -10, 0, 20)
    xrayHeader.Position = UDim2.new(0, 5, 0, yOffset)
    xrayHeader.BackgroundTransparency = 1
    xrayHeader.Text = "Xray"
    xrayHeader.TextColor3 = Settings.Menu.AccentColor
    xrayHeader.Font = Enum.Font.SourceSansBold
    xrayHeader.TextSize = 16
    xrayHeader.TextXAlignment = Enum.TextXAlignment.Left
    xrayHeader.Parent = MiscContainer
    yOffset = yOffset + 25
    
    CreateToggle(MiscContainer, "Xray", Settings.Misc.Xray.Enabled, yOffset)
    yOffset = yOffset + 35
    
    local xrayTransparencySlider = CreateSlider(MiscContainer, "Xray Transparency", Settings.Misc.Xray.Transparency, 0, 100, yOffset)
    yOffset = yOffset + 55
    
    local miniButtonsHeader = Instance.new("TextLabel")
    miniButtonsHeader.Name = "MiniButtonsHeader"
    miniButtonsHeader.Size = UDim2.new(1, -10, 0, 20)
    miniButtonsHeader.Position = UDim2.new(0, 5, 0, yOffset)
    miniButtonsHeader.BackgroundTransparency = 1
    miniButtonsHeader.Text = "Mini Buttons"
    miniButtonsHeader.TextColor3 = Settings.Menu.AccentColor
    miniButtonsHeader.Font = Enum.Font.SourceSansBold
    miniButtonsHeader.TextSize = 16
    miniButtonsHeader.TextXAlignment = Enum.TextXAlignment.Left
    miniButtonsHeader.Parent = MiscContainer
    yOffset = yOffset + 25
    
    CreateToggle(MiscContainer, "Grab Gun Button", Settings.Misc.GrabGun, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "Run Button", Settings.Misc.Run, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "Noclip Button", Settings.Misc.Noclip, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "TP Lobby Button", Settings.Teleport.Lobby, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "TP Map Button", Settings.Teleport.Map, yOffset)
    yOffset = yOffset + 35
    
    CreateToggle(MiscContainer, "Double Jump Button", Settings.Misc.DoubleJump, yOffset)
    yOffset = yOffset + 35
    
    local infoHeader = Instance.new("TextLabel")
    infoHeader.Name = "InfoHeader"
    infoHeader.Size = UDim2.new(1, -10, 0, 20)
    infoHeader.Position = UDim2.new(0, 5, 0, yOffset)
    infoHeader.BackgroundTransparency = 1
    infoHeader.Text = "About Functions"
    infoHeader.TextColor3 = Settings.Menu.AccentColor
    infoHeader.Font = Enum.Font.SourceSansBold
    infoHeader.TextSize = 16
    infoHeader.TextXAlignment = Enum.TextXAlignment.Left
    infoHeader.Parent = MiscContainer
    yOffset = yOffset + 25
    
    CreateInfoFrame(MiscContainer, "ESP - Shows players through walls\nCombat - Combat features for roles\nTeleport - Teleport to locations\nMisc - Various useful functions", yOffset)
    yOffset = yOffset + 90

    AutoShootButton = Instance.new("TextButton")
    AutoShootButton.Name = "AutoShootButton"
    AutoShootButton.Size = UDim2.new(0, 50 * Settings.Sheriff.AutoShoot.Size, 0, 50 * Settings.Sheriff.AutoShoot.Size)
    AutoShootButton.Position = Settings.Sheriff.AutoShoot.Position
    AutoShootButton.BackgroundColor3 = Settings.Menu.AccentColor
    AutoShootButton.BackgroundTransparency = Settings.Sheriff.AutoShoot.Transparency
    AutoShootButton.BorderSizePixel = 0
    AutoShootButton.Text = Settings.Sheriff.AutoShoot.Key
    AutoShootButton.TextColor3 = Color3.new(1, 1, 1)
    AutoShootButton.Font = Enum.Font.SourceSansBold
    AutoShootButton.TextSize = 20
    AutoShootButton.Visible = Settings.Sheriff.AutoShoot.Enabled and Settings.Sheriff.AutoShoot.Visible
    AutoShootButton.Active = true
    AutoShootButton.Draggable = true
    AutoShootButton.Parent = GUI

    local shootCorner = Instance.new("UICorner")
    shootCorner.CornerRadius = UDim.new(0.5, 0)
    shootCorner.Parent = AutoShootButton

    MenuButton = Instance.new("TextButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 40, 0, 40)
    MenuButton.Position = UDim2.new(0, 10, 0, 10)
    MenuButton.BackgroundColor3 = Settings.Menu.AccentColor
    MenuButton.Text = "M"
    MenuButton.TextColor3 = Color3.new(1, 1, 1)
    MenuButton.Font = Enum.Font.SourceSansBold
    MenuButton.TextSize = 20
    MenuButton.Parent = GUI

    CloseButton.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        Settings.Menu.Minimized = not Settings.Menu.Minimized
        MainFrame.Size = Settings.Menu.Minimized and Settings.Menu.MinimizedSize or Settings.Menu.Size
        MinimizeButton.Text = Settings.Menu.Minimized and "+" or "-"
        TabButtons.Visible = not Settings.Menu.Minimized
        TabContainer.Visible = not Settings.Menu.Minimized
    end)

    ESPTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = true
        CombatContainer.Visible = false
        TeleportContainer.Visible = false
        MiscContainer.Visible = false
    end)

    CombatTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = false
        CombatContainer.Visible = true
        TeleportContainer.Visible = false
        MiscContainer.Visible = false
        AutoShootButton.Visible = Settings.Sheriff.AutoShoot.Enabled and Settings.Sheriff.AutoShoot.Visible
    end)

    TeleportTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = false
        CombatContainer.Visible = false
        TeleportContainer.Visible = true
        MiscContainer.Visible = false
    end)

    MiscTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = false
        CombatContainer.Visible = false
        TeleportContainer.Visible = false
        MiscContainer.Visible = true
    end)

    MenuButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    AutoShootButton.MouseButton1Down:Connect(function()
        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Settings.Sheriff.AutoShoot.Enabled do
            AutoShoot()
            wait(0.1)
        end
    end)

    AutoShootButton.Changed:Connect(function(prop)
        if prop == "Position" then
            Settings.Sheriff.AutoShoot.Position = AutoShootButton.Position
        end
    end)
end

local function MainLoop()
    FindRoles()
    UpdateESP()
    
    if Settings.Sheriff.AutoShoot.Enabled and Player == Sheriff then
        AutoShootButton.Visible = Settings.Sheriff.AutoShoot.Visible
        AutoShootButton.Size = UDim2.new(0, 50 * Settings.Sheriff.AutoShoot.Size, 0, 50 * Settings.Sheriff.AutoShoot.Size)
        AutoShootButton.BackgroundTransparency = Settings.Sheriff.AutoShoot.Transparency
    else
        AutoShootButton.Visible = false
    end
    
    if Settings.Murderer.KillAura.Enabled and Player == Murderer then
        KillAura()
    end
    
    if Settings.Teleport.SafePlace then
        TeleportTo("SafePlace")
        Settings.Teleport.SafePlace = false
    end
    
    if Settings.Teleport.ToMurderer then
        TeleportTo("Murderer")
        Settings.Teleport.ToMurderer = false
    end
    
    if Settings.Teleport.ToSheriff then
        TeleportTo("Sheriff")
        Settings.Teleport.ToSheriff = false
    end
    
    if Settings.Teleport.ToGun then
        TeleportTo("Gun")
        Settings.Teleport.ToGun = false
    end
    
    if Settings.Teleport.Lobby then
        TeleportTo("Lobby")
        Settings.Teleport.Lobby = false
    end
    
    if Settings.Teleport.Map then
        TeleportTo("Map")
        Settings.Teleport.Map = false
    end
    
    if Settings.Misc.GrabGun then
        GrabGun()
        Settings.Misc.GrabGun = false
    end
    
    if Settings.Misc.Noclip then
        ToggleNoclip()
    end
    
    if Settings.Misc.DoubleJump then
        DoubleJump()
        Settings.Misc.DoubleJump = false
    end
    
    if Settings.Misc.NoBarriers then
        RemoveBarriers()
    end
    
    if Settings.Misc.SpamEmote then
        SpamEmote()
    end
    
    if Settings.Misc.FakeDead then
        FakeDead()
        Settings.Misc.FakeDead = false
    end
    
    if Settings.Misc.TwoLive then
        TwoLive()
        Settings.Misc.TwoLive = false
    end
    
    if Settings.Misc.Xray.Enabled then
        ToggleXray()
    end
    
    if Settings.RolePlay.NotifyRoles then
        NotifyRoles()
        Settings.RolePlay.NotifyRoles = false
    end
    
    if Settings.RolePlay.ChatRoles then
        ChatRoles()
        Settings.RolePlay.ChatRoles = false
    end
    
    if Settings.RolePlay.RoundTimer then
        UpdateRoundTimer()
    end
end

CreateGUI()

table.insert(Connections, Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        UpdateESP()
    end)
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    if player == Sheriff then Sheriff = nil end
    if player == Murderer then Murderer = nil end
    UpdateESP()
end))

table.insert(Connections, workspace.ChildAdded:Connect(function(child)
    if child.Name:find("Coin") or child.Name:find("Diamond") or child.Name == "GunDrop" or child:IsA("Tool") or child.Name:find("Trap") then
        UpdateESP()
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(MainLoop))

Player.CharacterRemoving:Connect(function()
    for _, conn in ipairs(Connections) do
        conn:Disconnect()
    end
    
    for object, esp in pairs(ESPCache) do
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Box then esp.Box:Destroy() end
        if esp.Outline then esp.Outline:Destroy() end
        if esp.Tracer then esp.Tracer:Remove() end
    end
    
    if GUI then
        GUI:Destroy()
    end
end)
