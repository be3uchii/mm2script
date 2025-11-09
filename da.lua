local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local monitoredGenerators = {}
local generatorHistory = {}
local lastFullState = {}
local connectionCache = {}
local generatorStatus = {}

local function getUltimateState(obj)
    local state = {}
    
    state.basic = {
        name = obj.Name,
        className = obj.ClassName,
        fullName = obj:GetFullName(),
        parent = obj.Parent and obj.Parent.Name or "nil"
    }
    
    if obj:IsA("Model") then
        state.model = {
            primaryPart = obj.PrimaryPart and obj.PrimaryPart.Name or "nil",
            primaryPartClass = obj.PrimaryPart and obj.PrimaryPart.ClassName or "nil",
            childCount = #obj:GetChildren()
        }
    end
    
    if obj:IsA("Part") then
        state.part = {
            material = tostring(obj.Material),
            size = {X = obj.Size.X, Y = obj.Size.Y, Z = obj.Size.Z},
            position = {X = obj.Position.X, Y = obj.Position.Y, Z = obj.Position.Z},
            anchored = obj.Anchored,
            canCollide = obj.CanCollide,
            transparency = obj.Transparency,
            reflectance = obj.Reflectance,
            color = {R = obj.Color.R, G = obj.Color.G, B = obj.Color.B}
        }
    end
    
    state.children = {}
    for _, child in pairs(obj:GetChildren()) do
        state.children[child:GetFullName()] = {
            name = child.Name,
            className = child.ClassName,
            parent = child.Parent and child.Parent.Name or "nil"
        }
        
        if child:IsA("Part") then
            state.children[child:GetFullName()].partInfo = {
                material = tostring(child.Material),
                size = {X = child.Size.X, Y = child.Size.Y, Z = child.Size.Z},
                color = {R = child.Color.R, G = child.Color.G, B = child.Color.B}
            }
        end
    end
    
    state.values = {}
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("BoolValue") or 
           child:IsA("IntValue") or child:IsA("ObjectValue") then
            state.values[child:GetFullName()] = {
                name = child.Name,
                value = child.Value,
                type = child.ClassName,
                parent = child.Parent and child.Parent.Name or "nil"
            }
        end
    end
    
    state.sounds = {}
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("Sound") then
            state.sounds[child:GetFullName()] = {
                name = child.Name,
                soundId = child.SoundId,
                playing = child.Playing,
                timePosition = child.TimePosition,
                volume = child.Volume,
                pitch = child.Pitch,
                looping = child.Looped,
                isLoaded = child.IsLoaded
            }
        end
    end
    
    state.effects = {}
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") or 
           child:IsA("Sparkles") or child:IsA("Beam") then
            state.effects[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                enabled = child.Enabled
            }
        end
    end
    
    state.lights = {}
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
            state.lights[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                enabled = child.Enabled,
                brightness = child.Brightness,
                color = {R = child.Color.R, G = child.Color.G, B = child.Color.B}
            }
        end
    end
    
    state.guis = {}
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
            state.guis[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                enabled = child.Enabled,
                studsOffset = child.StudsOffset
            }
        end
    end
    
    state.scripts = {}
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
            state.scripts[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                disabled = child.Disabled
            }
        end
    end
    
    state.isGenerator = string.lower(obj.Name):find("generator") ~= nil or
                      string.lower(obj.Name):find("gen") ~= nil or
                      #state.values > 0 or
                      #state.sounds > 0
    
    return state
end

local function detectUltimateChanges(oldState, newState)
    local changes = {}
    
    if oldState.basic.name ~= newState.basic.name then
        table.insert(changes, "📛 MODEL NAME: " .. oldState.basic.name .. " → " .. newState.basic.name)
    end
    
    if oldState.model and newState.model then
        if oldState.model.primaryPart ~= newState.model.primaryPart then
            table.insert(changes, "🎯 PRIMARY PART: " .. oldState.model.primaryPart .. " → " .. newState.model.primaryPart)
        end
        if oldState.model.childCount ~= newState.model.childCount then
            table.insert(changes, "👥 CHILD COUNT: " .. oldState.model.childCount .. " → " .. newState.model.childCount)
        end
    end
    
    if oldState.isGenerator ~= newState.isGenerator then
        table.insert(changes, "🔧 GENERATOR STATUS: " .. (oldState.isGenerator and "YES" or "NO") .. " → " .. (newState.isGenerator and "YES" or "NO"))
    end
    
    for childKey, newChild in pairs(newState.children) do
        local oldChild = oldState.children[childKey]
        if not oldChild then
            table.insert(changes, "🆕 CHILD ADDED: " .. newChild.name .. " [" .. newChild.className .. "]")
        elseif oldChild.name ~= newChild.name then
            table.insert(changes, "🔄 CHILD RENAMED: " .. oldChild.name .. " → " .. newChild.name)
        elseif oldChild.className ~= newChild.className then
            table.insert(changes, "🔄 CHILD TYPE: " .. newChild.name .. " " .. oldChild.className .. " → " .. newChild.className)
        end
    end
    
    for childKey, oldChild in pairs(oldState.children) do
        if not newState.children[childKey] then
            table.insert(changes, "🗑️ CHILD REMOVED: " .. oldChild.name .. " [" .. oldChild.className .. "]")
        end
    end
    
    for valueKey, newValue in pairs(newState.values) do
        local oldValue = oldState.values[valueKey]
        if not oldValue then
            table.insert(changes, "🆕 VALUE: " .. newValue.name .. " = " .. tostring(newValue.value))
        elseif oldValue.value ~= newValue.value then
            table.insert(changes, "🔄 VALUE: " .. newValue.name .. " " .. tostring(oldValue.value) .. " → " .. tostring(newValue.value))
        end
    end
    
    for valueKey, oldValue in pairs(oldState.values) do
        if not newState.values[valueKey] then
            table.insert(changes, "🗑️ VALUE REMOVED: " .. oldValue.name)
        end
    end
    
    for soundKey, newSound in pairs(newState.sounds) do
        local oldSound = oldState.sounds[soundKey]
        if not oldSound then
            table.insert(changes, "🎵 NEW SOUND: " .. newSound.name .. " (" .. newSound.soundId .. ")")
        else
            if oldSound.playing ~= newSound.playing then
                table.insert(changes, "🎵 SOUND: " .. newSound.name .. " " .. (oldSound.playing and "STOPPED" or "STARTED"))
            end
            if oldSound.soundId ~= newSound.soundId then
                table.insert(changes, "🎵 SOUND ID: " .. newSound.name .. " " .. oldSound.soundId .. " → " .. newSound.soundId)
            end
            if oldSound.volume ~= newSound.volume then
                table.insert(changes, "🎵 VOLUME: " .. newSound.name .. " " .. oldSound.volume .. " → " .. newSound.volume)
            end
        end
    end
    
    for effectKey, newEffect in pairs(newState.effects) do
        local oldEffect = oldState.effects[effectKey]
        if not oldEffect then
            table.insert(changes, "✨ NEW EFFECT: " .. newEffect.name .. " [" .. newEffect.type .. "]")
        elseif oldEffect.enabled ~= newEffect.enabled then
            table.insert(changes, "✨ EFFECT: " .. newEffect.name .. " " .. tostring(oldEffect.enabled) .. " → " .. tostring(newEffect.enabled))
        end
    end
    
    for lightKey, newLight in pairs(newState.lights) do
        local oldLight = oldState.lights[lightKey]
        if not oldLight then
            table.insert(changes, "💡 NEW LIGHT: " .. newLight.name .. " [" .. newLight.type .. "]")
        elseif oldLight.enabled ~= newLight.enabled then
            table.insert(changes, "💡 LIGHT: " .. newLight.name .. " " .. tostring(oldLight.enabled) .. " → " .. tostring(newLight.enabled))
        end
    end
    
    for guiKey, newGui in pairs(newState.guis) do
        local oldGui = oldState.guis[guiKey]
        if not oldGui then
            table.insert(changes, "📱 NEW GUI: " .. newGui.name .. " [" .. newGui.type .. "]")
        elseif oldGui.enabled ~= newGui.enabled then
            table.insert(changes, "📱 GUI: " .. newGui.name .. " " .. tostring(oldGui.enabled) .. " → " .. tostring(newGui.enabled))
        end
    end
    
    for scriptKey, newScript in pairs(newState.scripts) do
        local oldScript = oldState.scripts[scriptKey]
        if not oldScript then
            table.insert(changes, "📜 NEW SCRIPT: " .. newScript.name .. " [" .. newScript.type .. "]")
        elseif oldScript.disabled ~= newScript.disabled then
            table.insert(changes, "📜 SCRIPT: " .. newScript.name .. " " .. tostring(oldScript.disabled) .. " → " .. tostring(newScript.disabled))
        end
    end
    
    return changes
end

local function createGeneratorDisplay(obj)
    if obj:FindFirstChild("GeneratorBillboard") then
        obj.GeneratorBillboard:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GeneratorBillboard"
    billboard.Size = UDim2.new(0, 500, 0, 400)
    billboard.StudsOffset = Vector3.new(0, 12, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 2000
    billboard.Adornee = obj
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "InfoText"
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(0.95, 0, 0.95, 0)
    textLabel.Position = UDim2.new(0.025, 0, 0.025, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = false
    textLabel.TextWrapped = true
    textLabel.Font = Enum.Font.RobotoMono
    textLabel.TextSize = 8
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = frame
    
    billboard.Parent = obj
    return textLabel
end

local function setupPropertyWatchers(obj)
    local objId = obj:GetFullName()
    
    if connectionCache[objId] then
        for _, conn in pairs(connectionCache[objId]) do
            conn:Disconnect()
        end
    end
    
    connectionCache[objId] = {}
    
    local function markChanged()
        if monitoredGenerators[obj] then
            monitoredGenerators[obj].changed = true
        end
    end
    
    local conn1 = obj:GetPropertyChangedSignal("Name"):Connect(markChanged)
    table.insert(connectionCache[objId], conn1)
    
    if obj:IsA("Model") then
        local conn2 = obj:GetPropertyChangedSignal("PrimaryPart"):Connect(markChanged)
        table.insert(connectionCache[objId], conn2)
    end
    
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("BoolValue") or child:IsA("IntValue") then
            local conn = child:GetPropertyChangedSignal("Value"):Connect(markChanged)
            table.insert(connectionCache[objId], conn)
        elseif child:IsA("Sound") then
            local conn1 = child:GetPropertyChangedSignal("Playing"):Connect(markChanged)
            local conn2 = child:GetPropertyChangedSignal("SoundId"):Connect(markChanged)
            local conn3 = child:GetPropertyChangedSignal("Volume"):Connect(markChanged)
            table.insert(connectionCache[objId], conn1)
            table.insert(connectionCache[objId], conn2)
            table.insert(connectionCache[objId], conn3)
        elseif child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") then
            local conn = child:GetPropertyChangedSignal("Enabled"):Connect(markChanged)
            table.insert(connectionCache[objId], conn)
        elseif child:IsA("PointLight") or child:IsA("SpotLight") then
            local conn = child:GetPropertyChangedSignal("Enabled"):Connect(markChanged)
            table.insert(connectionCache[objId], conn)
        elseif child:IsA("BillboardGui") then
            local conn = child:GetPropertyChangedSignal("Enabled"):Connect(markChanged)
            table.insert(connectionCache[objId], conn)
        end
        
        local connName = child:GetPropertyChangedSignal("Name"):Connect(markChanged)
        table.insert(connectionCache[objId], connName)
    end
    
    local descAdded = obj.DescendantAdded:Connect(function(descendant)
        markChanged()
        wait(0.3)
        setupPropertyWatchers(obj)
    end)
    
    local descRemoved = obj.DescendantRemoving:Connect(function(descendant)
        markChanged()
    end)
    
    table.insert(connectionCache[objId], descAdded)
    table.insert(connectionCache[objId], descRemoved)
    
    local childAdded = obj.ChildAdded:Connect(function(child)
        markChanged()
        wait(0.3)
        setupPropertyWatchers(obj)
    end)
    
    local childRemoved = obj.ChildRemoved:Connect(function(child)
        markChanged()
    end)
    
    table.insert(connectionCache[objId], childAdded)
    table.insert(connectionCache[objId], childRemoved)
end

local function updateGeneratorInfo(obj)
    if not monitoredGenerators[obj] or not obj.Parent then return end
    
    local currentState = getUltimateState(obj)
    local objId = obj:GetFullName()
    
    if not generatorHistory[objId] then
        generatorHistory[objId] = {}
        lastFullState[objId] = currentState
        generatorStatus[objId] = {
            isGenerator = currentState.isGenerator,
            removed = false
        }
    end
    
    local changes = detectUltimateChanges(lastFullState[objId], currentState)
    
    if not currentState.isGenerator and generatorStatus[objId].isGenerator then
        table.insert(changes, "🚫 GENERATOR REMOVED: This object is no longer a generator")
        generatorStatus[objId].removed = true
    elseif currentState.isGenerator and not generatorStatus[objId].isGenerator then
        table.insert(changes, "✅ GENERATOR RESTORED: This object is now a generator")
        generatorStatus[objId].removed = false
    end
    
    generatorStatus[objId].isGenerator = currentState.isGenerator
    
    for _, change in ipairs(changes) do
        table.insert(generatorHistory[objId], os.date("%H:%M:%S") .. " - " .. change)
        if #generatorHistory[objId] > 20 then
            table.remove(generatorHistory[objId], 1)
        end
    end
    
    lastFullState[objId] = getUltimateState(obj)
    
    local info = "=== ULTIMATE GENERATOR TRACKER ===\n"
    info = info .. "📛 Name: " .. currentState.basic.name .. "\n"
    info = info .. "🔧 Type: " .. obj.ClassName .. "\n"
    info = info .. "📍 Path: " .. currentState.basic.fullName .. "\n"
    info = info .. "📊 Generator: " .. (currentState.isGenerator and "YES" or "NO") .. "\n"
    info = info .. "🗑️ Removed: " .. (generatorStatus[objId].removed and "YES" or "NO") .. "\n"
    
    if currentState.model then
        info = info .. "🎯 Primary: " .. currentState.model.primaryPart .. "\n"
        info = info .. "👥 Children: " .. currentState.model.childCount .. "\n"
    end
    
    info = info .. "\n=== COMPONENTS ===\n"
    info = info .. "🔊 Sounds: " .. #currentState.sounds .. "\n"
    info = info .. "✨ Effects: " .. #currentState.effects .. "\n"
    info = info .. "💡 Lights: " .. #currentState.lights .. "\n"
    info = info .. "📱 GUIs: " .. #currentState.guis .. "\n"
    info = info .. "📜 Scripts: " .. #currentState.scripts .. "\n"
    info = info .. "📊 Values: " .. #currentState.values .. "\n"
    
    info = info .. "\n=== REAL-TIME CHANGES ===\n"
    if #generatorHistory[objId] > 0 then
        for i = math.max(1, #generatorHistory[objId] - 12), #generatorHistory[objId] do
            info = info .. generatorHistory[objId][i] .. "\n"
        end
    else
        info = info .. "No changes detected\n"
    end
    
    info = info .. "\nLast scan: " .. os.date("%H:%M:%S")
    
    if monitoredGenerators[obj].billboard then
        monitoredGenerators[obj].billboard.Text = info
    end
    
    monitoredGenerators[obj].changed = false
end

local function findTopGenerators()
    local generators = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.lower(obj.Name):find("generator") or string.lower(obj.Name):find("gen")) then
            table.insert(generators, obj)
        end
    end
    
    table.sort(generators, function(a, b)
        return #a:GetDescendants() > #b:GetDescendants()
    end)
    
    return {generators[1], generators[2], generators[3]}
end

local function initializeGenerator(obj)
    if not obj or monitoredGenerators[obj] then return end
    
    monitoredGenerators[obj] = {
        changed = true,
        billboard = createGeneratorDisplay(obj)
    }
    
    if not obj:FindFirstChildWhichIsA("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "GeneratorHighlight"
        highlight.FillColor = Color3.fromRGB(255, 165, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 140, 0)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = obj
        highlight.Parent = obj
    end
    
    setupPropertyWatchers(obj)
    updateGeneratorInfo(obj)
    
    print("🔧 Tracking: " .. obj:GetFullName())
end

local function startMonitoring()
    local topGens = findTopGenerators()
    
    for _, gen in ipairs(topGens) do
        if gen then
            initializeGenerator(gen)
        end
    end
end

startMonitoring()

RunService.Heartbeat:Connect(function()
    for obj, data in pairs(monitoredGenerators) do
        if not obj.Parent then
            monitoredGenerators[obj] = nil
        elseif data.changed then
            updateGeneratorInfo(obj)
        end
    end
end)

game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
    wait(1)
    if descendant:IsA("Model") and string.lower(descendant.Name):find("generator") then
        local count = 0
        for _ in pairs(monitoredGenerators) do count = count + 1 end
        
        if count < 3 then
            initializeGenerator(descendant)
        end
    end
end)

while true do
    for obj, data in pairs(monitoredGenerators) do
        if obj and obj.Parent then
            data.changed = true
        else
            monitoredGenerators[obj] = nil
        end
    end
    wait(2)
end