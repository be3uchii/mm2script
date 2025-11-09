local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local monitoredGenerators = {}
local generatorHistory = {}
local lastStates = {}
local connectionCache = {}

local function findBestGenerators()
    local allGenerators = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and (
            string.lower(obj.Name):find("generator") or
            string.lower(obj.Name):find("gen") or
            string.lower(obj.Name):find("power") or
            string.lower(obj.Name):find("energy") or
            string.lower(obj.Name):find("engine")
        ) then
            table.insert(allGenerators, obj)
        end
    end
    
    return {allGenerators[1], allGenerators[2], allGenerators[3], allGenerators[4], allGenerators[5]}
end

local function createOptimizedBillboard(obj)
    if obj:FindFirstChild("GeneratorBillboard") then
        obj.GeneratorBillboard:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GeneratorBillboard"
    billboard.Size = UDim2.new(0, 450, 0, 500)
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
    textLabel.Size = UDim2.new(0.96, 0, 0.96, 0)
    textLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
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

local function getCompleteState(obj)
    local state = {}
    
    state.name = obj.Name
    state.className = obj.ClassName
    state.fullName = obj:GetFullName()
    state.archivable = obj.Archivable
    
    if obj:IsA("Model") then
        state.type = "Model"
        state.primaryPart = obj.PrimaryPart and obj.PrimaryPart.Name or "None"
        state.childrenCount = #obj:GetChildren()
        state.descendantsCount = #obj:GetDescendants()
        state.children = {}
        for _, child in pairs(obj:GetChildren()) do
            table.insert(state.children, {
                name = child.Name,
                className = child.ClassName,
                fullName = child:GetFullName()
            })
        end
    elseif obj:IsA("Part") then
        state.type = "Part"
        state.material = tostring(obj.Material)
        state.color = tostring(obj.BrickColor.Name)
        state.size = string.format("%.1f,%.1f,%.1f", obj.Size.X, obj.Size.Y, obj.Size.Z)
        state.position = string.format("%.1f,%.1f,%.1f", obj.Position.X, obj.Position.Y, obj.Position.Z)
        state.anchored = obj.Anchored
        state.canCollide = obj.CanCollide
        state.transparency = obj.Transparency
        state.reflectance = obj.Reflectance
    end
    
    state.values = {}
    state.sounds = {}
    state.lights = {}
    state.particles = {}
    state.scripts = {}
    
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("BoolValue") or child:IsA("IntValue") or child:IsA("ObjectValue") then
            state.values[child:GetFullName()] = {
                name = child.Name,
                value = child.Value,
                type = child.ClassName,
                fullName = child:GetFullName()
            }
        elseif child:IsA("Sound") then
            state.sounds[child:GetFullName()] = {
                name = child.Name,
                playing = child.Playing,
                soundId = child.SoundId,
                timePosition = child.TimePosition,
                volume = child.Volume,
                pitch = child.Pitch,
                looping = child.Looped,
                isLoaded = child.IsLoaded,
                isPaused = child.IsPaused
            }
        elseif child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
            state.lights[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                enabled = child.Enabled,
                brightness = child.Brightness,
                color = tostring(child.Color),
                range = child.Range
            }
        elseif child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") then
            state.particles[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                enabled = child.Enabled
            }
        elseif child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
            state.scripts[child:GetFullName()] = {
                name = child.Name,
                type = child.ClassName,
                disabled = child.Disabled
            }
        end
    end
    
    state.timestamp = os.time()
    return state
end

local function detectAllChanges(oldState, newState)
    local changes = {}
    
    if oldState.name ~= newState.name then
        table.insert(changes, "NAME: " .. oldState.name .. " → " .. newState.name)
    end
    
    if oldState.className ~= newState.className then
        table.insert(changes, "CLASS: " .. oldState.className .. " → " .. newState.className)
    end
    
    if oldState.archivable ~= newState.archivable then
        table.insert(changes, "ARCHIVABLE: " .. tostring(oldState.archivable) .. " → " .. tostring(newState.archivable))
    end
    
    if oldState.type == "Model" and newState.type == "Model" then
        if oldState.primaryPart ~= newState.primaryPart then
            table.insert(changes, "PRIMARY: " .. oldState.primaryPart .. " → " .. newState.primaryPart)
        end
        if oldState.childrenCount ~= newState.childrenCount then
            table.insert(changes, "CHILDREN: " .. oldState.childrenCount .. " → " .. newState.childrenCount)
        end
        if oldState.descendantsCount ~= newState.descendantsCount then
            table.insert(changes, "DESCENDANTS: " .. oldState.descendantsCount .. " → " .. newState.descendantsCount)
        end
    end
    
    if oldState.type == "Part" and newState.type == "Part" then
        if oldState.material ~= newState.material then
            table.insert(changes, "MATERIAL: " .. oldState.material .. " → " .. newState.material)
        end
        if oldState.color ~= newState.color then
            table.insert(changes, "COLOR: " .. oldState.color .. " → " .. newState.color)
        end
        if oldState.size ~= newState.size then
            table.insert(changes, "SIZE: " .. oldState.size .. " → " .. newState.size)
        end
        if oldState.position ~= newState.position then
            table.insert(changes, "POSITION: " .. oldState.position .. " → " .. newState.position)
        end
        if oldState.anchored ~= newState.anchored then
            table.insert(changes, "ANCHORED: " .. tostring(oldState.anchored) .. " → " .. tostring(newState.anchored))
        end
        if oldState.transparency ~= newState.transparency then
            table.insert(changes, "TRANSPARENCY: " .. string.format("%.2f", oldState.transparency) .. " → " .. string.format("%.2f", newState.transparency))
        end
    end
    
    for key, newVal in pairs(newState.values) do
        local oldVal = oldState.values[key]
        if not oldVal then
            table.insert(changes, "NEW VALUE: " .. newVal.name .. " = " .. tostring(newVal.value))
        elseif oldVal.value ~= newVal.value then
            table.insert(changes, "VALUE: " .. newVal.name .. " " .. tostring(oldVal.value) .. " → " .. tostring(newVal.value))
        end
    end
    
    for key, oldVal in pairs(oldState.values) do
        if not newState.values[key] then
            table.insert(changes, "REMOVED VALUE: " .. oldVal.name)
        end
    end
    
    for key, newSound in pairs(newState.sounds) do
        local oldSound = oldState.sounds[key]
        if not oldSound then
            table.insert(changes, "NEW SOUND: " .. newSound.name .. " (" .. newSound.soundId .. ")")
        else
            if oldSound.playing ~= newSound.playing then
                table.insert(changes, "SOUND: " .. newSound.name .. " " .. (oldSound.playing and "STOPPED" or "STARTED"))
            end
            if oldSound.soundId ~= newSound.soundId then
                table.insert(changes, "SOUND ID: " .. newSound.name .. " " .. oldSound.soundId .. " → " .. newSound.soundId)
            end
            if oldSound.volume ~= newSound.volume then
                table.insert(changes, "SOUND VOLUME: " .. newSound.name .. " " .. string.format("%.1f", oldSound.volume) .. " → " .. string.format("%.1f", newSound.volume))
            end
        end
    end
    
    for key, newLight in pairs(newState.lights) do
        local oldLight = oldState.lights[key]
        if not oldLight then
            table.insert(changes, "NEW LIGHT: " .. newLight.name .. " [" .. newLight.type .. "]")
        else
            if oldLight.enabled ~= newLight.enabled then
                table.insert(changes, "LIGHT: " .. newLight.name .. " " .. (oldLight.enabled and "OFF" or "ON"))
            end
        end
    end
    
    for key, newParticle in pairs(newState.particles) do
        local oldParticle = oldState.particles[key]
        if not oldParticle then
            table.insert(changes, "NEW PARTICLE: " .. newParticle.name .. " [" .. newParticle.type .. "]")
        else
            if oldParticle.enabled ~= newParticle.enabled then
                table.insert(changes, "PARTICLE: " .. newParticle.name .. " " .. (oldParticle.enabled and "OFF" or "ON"))
            end
        end
    end
    
    for key, newScript in pairs(newState.scripts) do
        local oldScript = oldState.scripts[key]
        if not oldScript then
            table.insert(changes, "NEW SCRIPT: " .. newScript.name .. " [" .. newScript.type .. "]")
        else
            if oldScript.disabled ~= newScript.disabled then
                table.insert(changes, "SCRIPT: " .. newScript.name .. " " .. (oldScript.disabled and "ENABLED" or "DISABLED"))
            end
        end
    end
    
    if oldState.type == "Model" and newState.type == "Model" then
        local oldChildrenMap = {}
        local newChildrenMap = {}
        
        for _, child in ipairs(oldState.children) do
            oldChildrenMap[child.fullName] = child
        end
        for _, child in ipairs(newState.children) do
            newChildrenMap[child.fullName] = child
        end
        
        for key, newChild in pairs(newChildrenMap) do
            if not oldChildrenMap[key] then
                table.insert(changes, "NEW CHILD: " .. newChild.name .. " [" .. newChild.className .. "]")
            end
        end
        for key, oldChild in pairs(oldChildrenMap) do
            if not newChildrenMap[key] then
                table.insert(changes, "REMOVED CHILD: " .. oldChild.name .. " [" .. oldChild.className .. "]")
            end
        end
    end
    
    return changes
end

local function setupComprehensiveListeners(obj)
    local objId = obj:GetFullName()
    
    if connectionCache[objId] then
        for _, connection in pairs(connectionCache[objId]) do
            connection:Disconnect()
        end
    end
    
    connectionCache[objId] = {}
    
    local nameConn = obj:GetPropertyChangedSignal("Name"):Connect(function()
        monitoredGenerators[obj].needsUpdate = true
    end)
    table.insert(connectionCache[objId], nameConn)
    
    local archivableConn = obj:GetPropertyChangedSignal("Archivable"):Connect(function()
        monitoredGenerators[obj].needsUpdate = true
    end)
    table.insert(connectionCache[objId], archivableConn)
    
    if obj:IsA("Model") then
        local primaryConn = obj:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
            monitoredGenerators[obj].needsUpdate = true
        end)
        table.insert(connectionCache[objId], primaryConn)
    end
    
    if obj:IsA("Part") then
        local materialConn = obj:GetPropertyChangedSignal("Material"):Connect(function()
            monitoredGenerators[obj].needsUpdate = true
        end)
        local colorConn = obj:GetPropertyChangedSignal("Color"):Connect(function()
            monitoredGenerators[obj].needsUpdate = true
        end)
        local positionConn = obj:GetPropertyChangedSignal("Position"):Connect(function()
            monitoredGenerators[obj].needsUpdate = true
        end)
        local anchoredConn = obj:GetPropertyChangedSignal("Anchored"):Connect(function()
            monitoredGenerators[obj].needsUpdate = true
        end)
        local transparencyConn = obj:GetPropertyChangedSignal("Transparency"):Connect(function()
            monitoredGenerators[obj].needsUpdate = true
        end)
        table.insert(connectionCache[objId], materialConn)
        table.insert(connectionCache[objId], colorConn)
        table.insert(connectionCache[objId], positionConn)
        table.insert(connectionCache[objId], anchoredConn)
        table.insert(connectionCache[objId], transparencyConn)
    end
    
    for _, descendant in pairs(obj:GetDescendants()) do
        if descendant:IsA("StringValue") or descendant:IsA("NumberValue") or descendant:IsA("BoolValue") or descendant:IsA("IntValue") or descendant:IsA("ObjectValue") then
            local valueConn = descendant:GetPropertyChangedSignal("Value"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            table.insert(connectionCache[objId], valueConn)
        elseif descendant:IsA("Sound") then
            local playingConn = descendant:GetPropertyChangedSignal("Playing"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            local soundIdConn = descendant:GetPropertyChangedSignal("SoundId"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            local volumeConn = descendant:GetPropertyChangedSignal("Volume"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            table.insert(connectionCache[objId], playingConn)
            table.insert(connectionCache[objId], soundIdConn)
            table.insert(connectionCache[objId], volumeConn)
        elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") then
            local enabledConn = descendant:GetPropertyChangedSignal("Enabled"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            table.insert(connectionCache[objId], enabledConn)
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Smoke") then
            local enabledConn = descendant:GetPropertyChangedSignal("Enabled"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            table.insert(connectionCache[objId], enabledConn)
        elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
            local disabledConn = descendant:GetPropertyChangedSignal("Disabled"):Connect(function()
                monitoredGenerators[obj].needsUpdate = true
            end)
            table.insert(connectionCache[objId], disabledConn)
        end
    end
    
    local descendantAddedConn = obj.DescendantAdded:Connect(function(descendant)
        monitoredGenerators[obj].needsUpdate = true
        wait(0.3)
        setupComprehensiveListeners(obj)
    end)
    
    local descendantRemovingConn = obj.DescendantRemoving:Connect(function(descendant)
        monitoredGenerators[obj].needsUpdate = true
    end)
    
    local childAddedConn = obj.ChildAdded:Connect(function(child)
        monitoredGenerators[obj].needsUpdate = true
    end)
    
    local childRemovedConn = obj.ChildRemoved:Connect(function(child)
        monitoredGenerators[obj].needsUpdate = true
    end)
    
    table.insert(connectionCache[objId], descendantAddedConn)
    table.insert(connectionCache[objId], descendantRemovingConn)
    table.insert(connectionCache[objId], childAddedConn)
    table.insert(connectionCache[objId], childRemovedConn)
end

local function updateGeneratorDisplay(obj)
    if not monitoredGenerators[obj] then return end
    
    local currentState = getCompleteState(obj)
    local objId = obj:GetFullName()
    
    if not generatorHistory[objId] then
        generatorHistory[objId] = {}
    end
    
    if lastStates[objId] then
        local changes = detectAllChanges(lastStates[objId], currentState)
        for _, change in ipairs(changes) do
            table.insert(generatorHistory[objId], os.date("%H:%M:%S") .. " - " .. change)
            if #generatorHistory[objId] > 20 then
                table.remove(generatorHistory[objId], 1)
            end
        end
    end
    
    lastStates[objId] = currentState
    
    local info = "=== COMPLETE GENERATOR MONITOR ===\n"
    info = info .. "Name: " .. currentState.name .. "\n"
    info = info .. "Class: " .. currentState.className .. "\n"
    info = info .. "Type: " .. currentState.type .. "\n"
    info = info .. "Archivable: " .. tostring(currentState.archivable) .. "\n\n"
    
    if currentState.type == "Model" then
        info = info .. "Model Info:\n"
        info = info .. "Primary: " .. currentState.primaryPart .. "\n"
        info = info .. "Children: " .. currentState.childrenCount .. "\n"
        info = info .. "Descendants: " .. currentState.descendantsCount .. "\n"
    elseif currentState.type == "Part" then
        info = info .. "Part Info:\n"
        info = info .. "Material: " .. currentState.material .. "\n"
        info = info .. "Color: " .. currentState.color .. "\n"
        info = info .. "Size: " .. currentState.size .. "\n"
        info = info .. "Position: " .. currentState.position .. "\n"
        info = info .. "Anchored: " .. tostring(currentState.anchored) .. "\n"
        info = info .. "Transparency: " .. string.format("%.2f", currentState.transparency) .. "\n"
    end
    info = info .. "\n"
    
    info = info .. "=== VALUES (" .. #currentState.values .. ") ===\n"
    local valueCount = 0
    for _, value in pairs(currentState.values) do
        valueCount = valueCount + 1
        if valueCount <= 8 then
            info = info .. value.name .. ": " .. tostring(value.value) .. " [" .. value.type .. "]\n"
        end
    end
    if valueCount > 8 then
        info = info .. "... and " .. (valueCount - 8) .. " more\n"
    end
    info = info .. "\n"
    
    info = info .. "=== SOUNDS (" .. #currentState.sounds .. ") ===\n"
    for _, sound in pairs(currentState.sounds) do
        info = info .. sound.name .. ": " .. (sound.playing and "▶ PLAYING" or "■ STOPPED") .. "\n"
        info = info .. "  ID: " .. sound.soundId .. "\n"
        if sound.playing then
            info = info .. "  Pos: " .. string.format("%.1f", sound.timePosition) .. "s\n"
        end
        info = info .. "  Vol: " .. string.format("%.1f", sound.volume) .. " | Loop: " .. tostring(sound.looping) .. "\n"
    end
    if #currentState.sounds == 0 then
        info = info .. "No sounds\n"
    end
    info = info .. "\n"
    
    info = info .. "=== LIGHTS (" .. #currentState.lights .. ") ===\n"
    for _, light in pairs(currentState.lights) do
        info = info .. light.name .. " [" .. light.type .. "]: " .. tostring(light.enabled) .. "\n"
    end
    if #currentState.lights == 0 then
        info = info .. "No lights\n"
    end
    info = info .. "\n"
    
    info = info .. "=== RECENT CHANGES ===\n"
    if #generatorHistory[objId] > 0 then
        for i = math.max(1, #generatorHistory[objId] - 8), #generatorHistory[objId] do
            info = info .. "• " .. generatorHistory[objId][i] .. "\n"
        end
    else
        info = info .. "No changes detected\n"
    end
    
    info = info .. "\nUpdated: " .. os.date("%H:%M:%S")
    
    if monitoredGenerators[obj].billboard then
        monitoredGenerators[obj].billboard.Text = info
    end
    
    monitoredGenerators[obj].needsUpdate = false
end

local function initializeGenerator(obj)
    if not obj or monitoredGenerators[obj] then return end
    
    monitoredGenerators[obj] = {
        needsUpdate = true,
        billboard = createOptimizedBillboard(obj)
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
    
    setupComprehensiveListeners(obj)
    updateGeneratorDisplay(obj)
    
    print("Comprehensive monitoring: " .. obj:GetFullName())
end

local function initializeMonitoring()
    local bestGenerators = findBestGenerators()
    
    for _, generator in ipairs(bestGenerators) do
        if generator then
            initializeGenerator(generator)
        end
    end
end

initializeMonitoring()

RunService.Heartbeat:Connect(function()
    for generator, data in pairs(monitoredGenerators) do
        if data.needsUpdate and generator and generator.Parent then
            updateGeneratorDisplay(generator)
        end
    end
end)

game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
    wait(1)
    if descendant:IsA("Model") and string.lower(descendant.Name):find("generator") then
        local currentCount = 0
        for _ in pairs(monitoredGenerators) do currentCount = currentCount + 1 end
        
        if currentCount < 5 then
            initializeGenerator(descendant)
        end
    end
end)