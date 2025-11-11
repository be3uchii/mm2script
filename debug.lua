local DebugService = {}

local logs = {}
local enabled = false

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")
local http = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local function logEverything(message, logType)
    if not enabled then return end
    
    local timestamp = os.date("%H:%M:%S")
    local color = Color3.new(1, 1, 1)
    
    if logType == "ERROR" then
        color = Color3.new(1, 0.3, 0.3)
    elseif logType == "WARNING" then
        color = Color3.new(1, 0.8, 0.3)
    elseif logType == "SUCCESS" then
        color = Color3.new(0.3, 1, 0.3)
    elseif logType == "INFO" then
        color = Color3.new(0.3, 0.7, 1)
    elseif logType == "HTTP" then
        color = Color3.new(0.8, 0.3, 1)
    elseif logType == "REMOTE" then
        color = Color3.new(1, 0.5, 0)
    elseif logType == "SCRIPT" then
        color = Color3.new(0.5, 1, 0.8)
    elseif logType == "FUNCTION" then
        color = Color3.new(1, 0.8, 0.3)
    elseif logType == "ANIMATION" then
        color = Color3.new(0.8, 0.6, 1)
    elseif logType == "EMOTE" then
        color = Color3.new(1, 0.6, 0.8)
    elseif logType == "DECOMPILE" then
        color = Color3.new(0.3, 1, 0.8)
    elseif logType == "BYTECODE" then
        color = Color3.new(0.8, 1, 0.3)
    elseif logType == "MEMORY" then
        color = Color3.new(1, 0.3, 0.8)
    elseif logType == "GLOBAL" then
        color = Color3.new(0.8, 0.8, 0.3)
    end
    
    table.insert(logs, {
        message = message,
        timestamp = timestamp,
        color = color
    })
    
    if DebugService.UpdateDisplay then
        DebugService:UpdateDisplay()
    end
    
    print("[" .. timestamp .. "] " .. message)
end

local function decompileScript(script)
    if decompile then
        local success, result = pcall(decompile, script)
        if success then
            logEverything("DECOMPILED: " .. script:GetFullName() .. " (" .. #result .. " chars)", "DECOMPILE")
            return result
        end
    end
    return nil
end

local function getBytecode(func)
    if debug.getinfo then
        local info = debug.getinfo(func, "b")
        if info and info.bytecode then
            logEverything("BYTECODE: " .. tostring(func) .. " - " .. tostring(info.bytecode), "BYTECODE")
            return info.bytecode
        end
    end
    return nil
end

local function dumpFunctionMemory(func)
    local dump = ""
    local i = 1
    while true do
        local name, value = debug.getupvalue(func, i)
        if not name then break end
        dump = dump .. string.format("Upvalue %d: %s = %s\n", i, name, tostring(value))
        i = i + 1
    end
    
    if enabled and dump ~= "" then
        logEverything("FUNCTION MEMORY DUMP: " .. tostring(func) .. "\n" .. dump, "MEMORY")
    end
    return dump
end

local function getAllScriptsDeep()
    local scripts = {}
    
    local function scanDescendants(parent)
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("LocalScript") or child:IsA("ModuleScript") or child:IsA("Script") then
                table.insert(scripts, child)
                logEverything("SCRIPT FOUND: " .. child:GetFullName(), "SCRIPT")
            end
        end
    end
    
    scanDescendants(ReplicatedStorage)
    scanDescendants(ServerScriptService)
    scanDescendants(StarterPlayer)
    scanDescendants(StarterPack)
    scanDescendants(Lighting)
    scanDescendants(Workspace)
    scanDescendants(game)
    
    return scripts
end

local function getScriptFromStack()
    local level = 2
    while true do
        local info = debug.getinfo(level, "S")
        if not info then break end
        
        if info.source and info.source:find("@") then
            logEverything("STACK LEVEL " .. level .. ": " .. tostring(info.source), "SCRIPT")
        end
        
        level = level + 1
    end
    return nil
end

local function analyzeFunction(func)
    local data = {}
    
    if debug.getinfo then
        data.info = debug.getinfo(func, "nfSlu")
        logEverything("FUNCTION INFO: " .. tostring(data.info.name) .. " - Source: " .. tostring(data.info.source), "FUNCTION")
    end
    
    data.constants = {}
    if debug.getconstant then
        local i = 1
        while true do
            local k, v = debug.getconstant(func, i)
            if not k then break end
            data.constants[i] = {k, v}
            logEverything("CONSTANT " .. i .. ": " .. tostring(k) .. " = " .. tostring(v), "FUNCTION")
            i = i + 1
        end
    end
    
    data.upvalues = {}
    local j = 1
    while true do
        local name, value = debug.getupvalue(func, j)
        if not name then break end
        data.upvalues[j] = {name, value}
        logEverything("UPVALUE " .. j .. ": " .. tostring(name) .. " = " .. tostring(value), "FUNCTION")
        j = j + 1
    end
    
    if debug.getprotos then
        data.protos = debug.getprotos(func)
        logEverything("PROTOS COUNT: " .. tostring(#data.protos), "FUNCTION")
    end
    
    data.locals = {}
    local level = 2
    local k = 1
    while true do
        local name, value = debug.getlocal(level, k)
        if not name then break end
        if name ~= "(*temporary)" then
            data.locals[name] = value
            logEverything("LOCAL VAR: " .. tostring(name) .. " = " .. tostring(value), "FUNCTION")
        end
        k = k + 1
    end
    
    return data
end

local function analyzeFullCallStack()
    local stack = {}
    local level = 2
    
    while true do
        local info = debug.getinfo(level, "nfSlu")
        if not info then break end
        
        local stackFrame = {
            level = level,
            function = info.name,
            source = info.source,
            linedefined = info.linedefined,
            currentline = info.currentline,
            locals = {}
        }
        
        local i = 1
        while true do
            local name, value = debug.getlocal(level, i)
            if not name then break end
            if name ~= "(*temporary)" then
                stackFrame.locals[name] = value
                logEverything("STACK LOCAL: Level " .. level .. " - " .. tostring(name) .. " = " .. tostring(value), "FUNCTION")
            end
            i = i + 1
        end
        
        table.insert(stack, stackFrame)
        level = level + 1
    end
    
    return stack
end

local function getModuleContent(moduleScript)
    local success, required = pcall(require, moduleScript)
    if success then
        if type(required) == "table" then
            for k, v in pairs(required) do
                logEverything("MODULE EXPORT: " .. moduleScript:GetFullName() .. " - " .. tostring(k) .. " = " .. tostring(v), "SCRIPT")
            end
        else
            logEverything("MODULE VALUE: " .. moduleScript:GetFullName() .. " = " .. tostring(required), "SCRIPT")
        end
    end
    return required
end

local function findHiddenRemotes()
    if getnilinstances then
        for _, instance in pairs(getnilinstances()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                logEverything("HIDDEN REMOTE: " .. instance.Name .. " (" .. instance.ClassName .. ")", "REMOTE")
            end
        end
    end
end

local function findRemotesInRegistry()
    if debug.getregistry then
        local registry = debug.getregistry()
        for _, value in pairs(registry) do
            if typeof(value) == "Instance" then
                if value:IsA("RemoteEvent") or value:IsA("RemoteFunction") then
                    logEverything("REGISTRY REMOTE: " .. value:GetFullName(), "REMOTE")
                end
            end
        end
    end
end

local function getAllGlobals()
    local globals = {}
    
    for name, value in pairs(_G) do
        globals[name] = value
        logEverything("GLOBAL _G: " .. tostring(name) .. " = " .. tostring(value), "GLOBAL")
    end
    
    if getgenv then
        for name, value in pairs(getgenv()) do
            globals[name] = value
            logEverything("GLOBAL GENV: " .. tostring(name) .. " = " .. tostring(value), "GLOBAL")
        end
    end
    
    if shared then
        for name, value in pairs(shared) do
            globals[name] = value
            logEverything("GLOBAL SHARED: " .. tostring(name) .. " = " .. tostring(value), "GLOBAL")
        end
    end
    
    return globals
end

local function hookAllRemotes()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local oldFireServer = obj.FireServer
            obj.FireServer = function(self, ...)
                local args = {...}
                logEverything("REMOTE EVENT: " .. obj:GetFullName() .. " FireServer - Args: " .. tostring(#args), "REMOTE")
                for i, arg in ipairs(args) do
                    logEverything("ARG " .. i .. ": " .. tostring(arg), "REMOTE")
                end
                getScriptFromStack()
                analyzeFullCallStack()
                return oldFireServer(self, ...)
            end
        elseif obj:IsA("RemoteFunction") then
            local oldInvokeServer = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                local args = {...}
                logEverything("REMOTE FUNCTION: " .. obj:GetFullName() .. " InvokeServer - Args: " .. tostring(#args), "REMOTE")
                for i, arg in ipairs(args) do
                    logEverything("ARG " .. i .. ": " .. tostring(arg), "REMOTE")
                end
                getScriptFromStack()
                analyzeFullCallStack()
                return oldInvokeServer(self, ...)
            end
        end
    end
end

local function hookNamecall()
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        mt.__namecall = function(...)
            local method = getnamecallmethod()
            local self = ...
            local args = {...}
            
            if enabled then
                logEverything("NAMECALL: " .. tostring(method) .. " on " .. tostring(self) .. " (" .. self.ClassName .. ") - Args: " .. tostring(#args), "FUNCTION")
                if method == "FireServer" or method == "InvokeServer" then
                    getScriptFromStack()
                    analyzeFullCallStack()
                end
            end
            
            return oldNamecall(...)
        end
    end
end

local function hookIndex()
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
        mt.__index = function(self, key)
            local value = oldIndex(self, key)
            
            if enabled then
                logEverything("PROPERTY GET: " .. tostring(self) .. "." .. tostring(key) .. " = " .. tostring(value), "INFO")
            end
            
            return value
        end
    end
end

local function hookNewindex()
    local mt = getrawmetatable(game)
    if mt then
        local oldNewindex = mt.__newindex
        mt.__newindex = function(self, key, value)
            if enabled then
                logEverything("PROPERTY SET: " .. tostring(self) .. "." .. tostring(key) .. " = " .. tostring(value), "INFO")
            end
            
            return oldNewindex(self, key, value)
        end
    end
end

local function hookHTTP()
    local oldGetAsync = http.GetAsync
    http.GetAsync = function(self, url, ...)
        if enabled then
            logEverything("HTTP GET: " .. tostring(url), "HTTP")
        end
        return oldGetAsync(self, url, ...)
    end
    
    local oldPostAsync = http.PostAsync
    http.PostAsync = function(self, url, data, ...)
        if enabled then
            logEverything("HTTP POST: " .. tostring(url) .. " - Data: " .. tostring(data), "HTTP")
        end
        return oldPostAsync(self, url, data, ...)
    end
end

local function monitorAllChanges()
    game.DescendantAdded:Connect(function(obj)
        if enabled then
            logEverything("OBJECT ADDED: " .. obj:GetFullName() .. " (" .. obj.ClassName .. ")", "INFO")
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                decompileScript(obj)
            end
        end
    end)
    
    game.DescendantRemoving:Connect(function(obj)
        if enabled then
            logEverything("OBJECT REMOVED: " .. obj:GetFullName() .. " (" .. obj.ClassName .. ")", "WARNING")
        end
    end)
    
    game.Changed:Connect(function(property)
        if enabled then
            logEverything("GAME PROPERTY CHANGED: " .. tostring(property), "INFO")
        end
    end)
end

local function hookTaskFunctions()
    local oldSpawn = task.spawn
    task.spawn = function(func, ...)
        if enabled then
            logEverything("TASK SPAWN: " .. tostring(func), "FUNCTION")
            getBytecode(func)
            dumpFunctionMemory(func)
            analyzeFunction(func)
        end
        return oldSpawn(func, ...)
    end
    
    local oldDelay = task.delay
    task.delay = function(time, func, ...)
        if enabled then
            logEverything("TASK DELAY: " .. tostring(time) .. "s - " .. tostring(func), "FUNCTION")
            getBytecode(func)
            dumpFunctionMemory(func)
            analyzeFunction(func)
        end
        return oldDelay(time, func, ...)
    end
end

local function hookCoroutine()
    local oldCreate = coroutine.create
    coroutine.create = function(func)
        if enabled then
            logEverything("COROUTINE CREATE: " .. tostring(func), "FUNCTION")
            getBytecode(func)
            dumpFunctionMemory(func)
            analyzeFunction(func)
        end
        return oldCreate(func)
    end
    
    local oldResume = coroutine.resume
    coroutine.resume = function(thread, ...)
        if enabled then
            logEverything("COROUTINE RESUME: " .. tostring(thread), "FUNCTION")
        end
        return oldResume(thread, ...)
    end
end

local function hookUserInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if enabled then
            logEverything("INPUT BEGAN: " .. input.KeyCode.Name .. " - UserInputType: " .. input.UserInputType.Name .. " - GameProcessed: " .. tostring(gameProcessed), "INFO")
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if enabled then
            logEverything("INPUT ENDED: " .. input.KeyCode.Name .. " - UserInputType: " .. input.UserInputType.Name .. " - GameProcessed: " .. tostring(gameProcessed), "INFO")
        end
    end)
end

local function hookHumanoid()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AnimationPlayed:Connect(function(animationTrack)
                    if enabled then
                        logEverything("ANIMATION PLAYED: " .. animationTrack.Animation.Name .. " - Player: " .. player.Name, "ANIMATION")
                    end
                end)
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            wait(1)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AnimationPlayed:Connect(function(animationTrack)
                    if enabled then
                        logEverything("ANIMATION PLAYED: " .. animationTrack.Animation.Name .. " - Player: " .. player.Name, "ANIMATION")
                    end
                end)
            end
        end)
    end)
end

local function createDebugGUI(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugLogger"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.4, 0, 0.6, 0)
    frame.Position = UDim2.new(0.6, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -60)
    scrollFrame.Position = UDim2.new(0, 0, 0, 40)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = frame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollFrame
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    header.Text = "Debug Logger - " .. player.Name
    header.TextColor3 = Color3.new(1, 1, 1)
    header.TextSize = 18
    header.Font = Enum.Font.GothamBold
    header.Parent = frame
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 60)
    buttonFrame.Position = UDim2.new(0, 0, 1, -60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = frame
    
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0, 80, 0, 30)
    clearButton.Position = UDim2.new(0, 10, 0, 15)
    clearButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    clearButton.Text = "Clear Logs"
    clearButton.TextColor3 = Color3.new(1, 1, 1)
    clearButton.TextSize = 14
    clearButton.Parent = buttonFrame
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0, 80, 0, 30)
    copyButton.Position = UDim2.new(0, 100, 0, 15)
    copyButton.BackgroundColor3 = Color3.new(0.2, 0.5, 0.8)
    copyButton.Text = "Copy All"
    copyButton.TextColor3 = Color3.new(1, 1, 1)
    copyButton.TextSize = 14
    copyButton.Parent = buttonFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 80, 0, 30)
    toggleButton.Position = UDim2.new(1, -90, 0, 15)
    toggleButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    toggleButton.Text = "Enable"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextSize = 14
    toggleButton.Parent = buttonFrame
    
    local function updateLogDisplay()
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        for i, logEntry in ipairs(logs) do
            local logLabel = Instance.new("TextLabel")
            logLabel.Size = UDim2.new(1, -10, 0, 20)
            logLabel.Position = UDim2.new(0, 5, 0, (i-1)*25)
            logLabel.BackgroundTransparency = 1
            logLabel.Text = "[" .. logEntry.timestamp .. "] " .. logEntry.message
            logLabel.TextColor3 = logEntry.color
            logLabel.TextSize = 12
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.Font = Enum.Font.Gotham
            logLabel.TextWrapped = false
            logLabel.Parent = scrollFrame
        end
    end
    
    clearButton.MouseButton1Click:Connect(function()
        logs = {}
        updateLogDisplay()
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        local allLogs = ""
        for _, logEntry in ipairs(logs) do
            allLogs = allLogs .. "[" .. logEntry.timestamp .. "] " .. logEntry.message .. "\n"
        end
        setclipboard(allLogs)
    end)
    
    toggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggleButton.Text = enabled and "Disable" or "Enable"
        toggleButton.BackgroundColor3 = enabled and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.6, 0.2, 0.2)
        logEverything("Debug logging " .. (enabled and "enabled" or "disabled"), enabled and "SUCCESS" or "WARNING")
        
        if enabled then
            getAllScriptsDeep()
            findHiddenRemotes()
            findRemotesInRegistry()
            getAllGlobals()
        end
    end)
    
    DebugService.UpdateDisplay = updateLogDisplay
    updateLogDisplay()
    
    return screenGui
end

function DebugService:Initialize()
    if RunService:IsClient() then
        local player = Players.LocalPlayer
        createDebugGUI(player)
        logEverything("Debug system initialized for " .. player.Name, "SUCCESS")
    else
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                createDebugGUI(player)
            end)
        end)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                createDebugGUI(player)
            end
        end
        
        logEverything("Debug system initialized on server", "SUCCESS")
    end
    
    hookAllRemotes()
    hookNamecall()
    hookIndex()
    hookNewindex()
    hookHTTP()
    monitorAllChanges()
    hookTaskFunctions()
    hookCoroutine()
    hookUserInput()
    hookHumanoid()
    
    logEverything("All monitoring systems activated - Ready to log everything", "SUCCESS")
end

getgenv().DebugService = DebugService

DebugService:Initialize()

return DebugService