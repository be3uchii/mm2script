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
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPack = game:GetService("StarterPack")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local lower = string.lower
local byte = string.byte
local round = math.round
local running = coroutine.running
local resume = coroutine.resume
local status = coroutine.status
local yield = coroutine.yield
local create = coroutine.create
local close = coroutine.close
local OldDebugId = game.GetDebugId
local info = debug.info
local IsA = game.IsA
local tostring = tostring
local tonumber = tonumber
local delay = task.delay
local spawn = task.spawn
local clear = table.clear
local clone = table.clone

local get_thread_identity = (syn and syn.get_thread_identity) or getidentity or function() return 0 end
local set_thread_identity = (syn and syn.set_thread_identity) or setidentity or function() end
local islclosure = islclosure or function(f) return true end

local getinfo = debug.getinfo or function() return {} end
local getupvalues = debug.getupvalues or function() return {} end
local getconstants = debug.getconstants or function() return {} end

local getcustomasset = getsynasset or function() return "" end
local getcallingscript = getcallingscript or function() return nil end
local newcclosure = newcclosure or function(f) return f end
local clonefunction = clonefunction or function(f) return f end
local cloneref = cloneref or function(obj) return obj end
local request = syn and syn.request or http_request or request

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
        if info then
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
    logEverything("FUNCTION DUMP: " .. tostring(func) .. "\n" .. dump, "FUNCTION")
    return dump
end

local function getAllScriptsDeep()
    local scripts = {}
    
    local function scanDescendants(parent)
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("LocalScript") or child:IsA("ModuleScript") or child:IsA("Script") then
                table.insert(scripts, child)
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
            logEverything("STACK SCRIPT: Level " .. level .. " - " .. info.source, "SCRIPT")
        end
        
        level = level + 1
    end
    return nil
end

local function analyzeFunction(func)
    local data = {}
    
    data.info = debug.getinfo(func, "nfSlu")
    logEverything("FUNCTION INFO: " .. tostring(data.info.name) .. " - Source: " .. tostring(data.info.source), "FUNCTION")
    
    data.constants = {}
    local i = 1
    while true do
        local k, v = debug.getconstant(func, i)
        if not k then break end
        data.constants[i] = {k, v}
        logEverything("CONSTANT " .. i .. ": " .. tostring(k) .. " = " .. tostring(v), "FUNCTION")
        i = i + 1
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
                logEverything("LOCAL VAR: " .. tostring(name) .. " = " .. tostring(value) .. " (Level " .. level .. ")", "FUNCTION")
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
                logEverything("MODULE EXPORT: " .. moduleScript:GetFullName() .. "." .. tostring(k) .. " = " .. tostring(v), "SCRIPT")
            end
        else
            logEverything("MODULE VALUE: " .. moduleScript:GetFullName() .. " = " .. tostring(required), "SCRIPT")
        end
    end
    return required
end

local function findHiddenRemotes()
    local hidden = {}
    if getnilinstances then
        for _, instance in pairs(getnilinstances()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                table.insert(hidden, instance)
                logEverything("HIDDEN REMOTE: " .. instance.Name .. " (" .. instance.ClassName .. ")", "REMOTE")
            end
        end
    end
    return hidden
end

local function findRemotesInRegistry()
    local remotes = {}
    if debug.getregistry then
        local registry = debug.getregistry()
        for _, value in pairs(registry) do
            if typeof(value) == "Instance" then
                if value:IsA("RemoteEvent") or value:IsA("RemoteFunction") then
                    table.insert(remotes, value)
                    logEverything("REGISTRY REMOTE: " .. value:GetFullName(), "REMOTE")
                end
            end
        end
    end
    return remotes
end

local function getAllGlobals()
    local globals = {}
    
    for name, value in pairs(_G) do
        globals[name] = value
        logEverything("GLOBAL _G: " .. tostring(name) .. " = " .. tostring(value), "INFO")
    end
    
    if getgenv then
        for name, value in pairs(getgenv()) do
            globals[name] = value
            logEverything("GLOBAL GENV: " .. tostring(name) .. " = " .. tostring(value), "INFO")
        end
    end
    
    if shared then
        for name, value in pairs(shared) do
            globals[name] = value
            logEverything("GLOBAL SHARED: " .. tostring(name) .. " = " .. tostring(value), "INFO")
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
                local callingScript = getcallingscript()
                
                logEverything("REMOTE EVENT: " .. obj:GetFullName() .. " FireServer - Args: " .. tostring(#args), "REMOTE")
                for i, arg in ipairs(args) do
                    logEverything("REMOTE ARG " .. i .. ": " .. tostring(arg), "REMOTE")
                end
                
                if callingScript then
                    logEverything("REMOTE CALLER: " .. tostring(callingScript), "REMOTE")
                    decompileScript(callingScript)
                end
                
                analyzeFullCallStack()
                return oldFireServer(self, ...)
            end
        elseif obj:IsA("RemoteFunction") then
            local oldInvokeServer = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                local args = {...}
                local callingScript = getcallingscript()
                
                logEverything("REMOTE FUNCTION: " .. obj:GetFullName() .. " InvokeServer - Args: " .. tostring(#args), "REMOTE")
                for i, arg in ipairs(args) do
                    logEverything("REMOTE ARG " .. i .. ": " .. tostring(arg), "REMOTE")
                end
                
                if callingScript then
                    logEverything("REMOTE CALLER: " .. tostring(callingScript), "REMOTE")
                    decompileScript(callingScript)
                end
                
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
                analyzeFullCallStack()
            end
            
            return oldNamecall(...)
        end
    end
end

local function hookInstanceCreation()
    local oldInstanceNew = Instance.new
    Instance.new = function(className, parent)
        local instance = oldInstanceNew(className, parent)
        
        if enabled then
            logEverything("INSTANCE CREATED: " .. className .. " -> " .. tostring(parent), "INFO")
        end
        
        return instance
    end
end

local function continuousMonitoring()
    while true do
        if enabled then
            getAllScriptsDeep()
            findHiddenRemotes()
            findRemotesInRegistry()
            getAllGlobals()
            
            for _, script in pairs(getAllScriptsDeep()) do
                decompileScript(script)
                getModuleContent(script)
            end
        end
        wait(5)
    end
end

local function createDebugGUI(player)
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        playerGui = player:WaitForChild("PlayerGui")
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugLogger"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, 0, 0.7, 0)
    frame.Position = UDim2.new(0.5, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -100)
    scrollFrame.Position = UDim2.new(0, 5, 0, 40)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    scrollFrame.Parent = frame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 2)
    uiListLayout.Parent = scrollFrame
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    header.Text = "DEBUG LOGGER - " .. player.Name
    header.TextColor3 = Color3.new(1, 1, 1)
    header.TextSize = 16
    header.Font = Enum.Font.GothamBold
    header.Parent = frame
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.Position = UDim2.new(0, 0, 1, -50)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = frame
    
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0, 100, 0, 30)
    clearButton.Position = UDim2.new(0, 10, 0, 10)
    clearButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    clearButton.Text = "Clear Logs"
    clearButton.TextColor3 = Color3.new(1, 1, 1)
    clearButton.TextSize = 14
    clearButton.Parent = buttonFrame
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0, 100, 0, 30)
    copyButton.Position = UDim2.new(0, 120, 0, 10)
    copyButton.BackgroundColor3 = Color3.new(0.2, 0.5, 0.8)
    copyButton.Text = "Copy All"
    copyButton.TextColor3 = Color3.new(1, 1, 1)
    copyButton.TextSize = 14
    copyButton.Parent = buttonFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 100, 0, 30)
    toggleButton.Position = UDim2.new(1, -110, 0, 10)
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
            logLabel.Size = UDim2.new(1, 0, 0, 20)
            logLabel.BackgroundTransparency = 1
            logLabel.Text = "[" .. logEntry.timestamp .. "] " .. logEntry.message
            logLabel.TextColor3 = logEntry.color
            logLabel.TextSize = 12
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.Font = Enum.Font.Gotham
            logLabel.TextWrapped = true
            logLabel.AutomaticSize = Enum.AutomaticSize.Y
            logLabel.Parent = scrollFrame
        end
        
        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.AbsoluteCanvasSize.Y)
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
    end)
    
    DebugService.UpdateDisplay = updateLogDisplay
    updateLogDisplay()
    
    return screenGui
end

function DebugService:Initialize()
    if RunService:IsClient() then
        local player = Players.LocalPlayer
        if player then
            createDebugGUI(player)
            logEverything("Debug system initialized for " .. player.Name, "SUCCESS")
        end
    else
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                wait(1)
                createDebugGUI(player)
            end)
            if player.Character then
                createDebugGUI(player)
            end
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
    hookInstanceCreation()
    
    spawn(continuousMonitoring)
    
    logEverything("ALL MONITORING SYSTEMS ACTIVATED - LOGGING EVERYTHING", "SUCCESS")
end

getgenv().DebugService = DebugService

spawn(function()
    wait(2)
    DebugService:Initialize()
end)

return DebugService