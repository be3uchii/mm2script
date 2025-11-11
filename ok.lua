if getgenv().SimpleSpyExecuted and type(getgenv().SimpleSpyShutdown) == "function" then
    getgenv().SimpleSpyShutdown()
end

local realconfigs = {
    logcheckcaller = false,
    autoblock = false,
    funcEnabled = true,
    advancedinfo = false,
    supersecretdevtoggle = false
}

local configs = newproxy(true)
local configsmetatable = getmetatable(configs)

configsmetatable.__index = function(self,index)
    return realconfigs[index]
end

local oth = syn and syn.oth
local unhook = oth and oth.unhook
local hook = oth and oth.hook

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

local function blankfunction(...)
    return ...
end

local get_thread_identity = (syn and syn.get_thread_identity) or getidentity or getthreadidentity
local set_thread_identity = (syn and syn.set_thread_identity) or setidentity
local islclosure = islclosure or is_l_closure
local threadfuncs = (get_thread_identity and set_thread_identity and true) or false

local getinfo = getinfo or blankfunction
local getupvalues = getupvalues or debug.getupvalues or blankfunction
local getconstants = getconstants or debug.getconstants or blankfunction

local getcustomasset = getsynasset or getcustomasset
local getcallingscript = getcallingscript or blankfunction
local newcclosure = newcclosure or blankfunction
local clonefunction = clonefunction or blankfunction
local cloneref = cloneref or blankfunction
local request = request or syn and syn.request
local makewritable = makewriteable or function(tbl)
    setreadonly(tbl,false)
end
local makereadonly = makereadonly or function(tbl)
    setreadonly(tbl,true)
end
local isreadonly = isreadonly or table.isfrozen

local setclipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set) or function(...)
    return ErrorPrompt("Attempted to set clipboard: "..(...),true)
end

local hookmetamethod = hookmetamethod or (makewriteable and makereadonly and getrawmetatable) and function(obj: object, metamethod: string, func: Function)
    local old = getrawmetatable(obj)

    if hookfunction then
        return hookfunction(old[metamethod],func)
    else
        local oldmetamethod = old[metamethod]
        makewriteable(old)
        old[metamethod] = func
        makereadonly(old)
        return oldmetamethod
    end
end

local function Create(instance, properties, children)
    local obj = Instance.new(instance)

    for i, v in next, properties or {} do
        obj[i] = v
        for _, child in next, children or {} do
            child.Parent = obj;
        end
    end
    return obj;
end

local function SafeGetService(service)
    return cloneref(game:GetService(service))
end

local function Search(logtable,tbl)
    table.insert(logtable,tbl)
    
    for i,v in tbl do
        if type(v) == "table" then
            return table.find(logtable,v) ~= nil or Search(v)
        end
    end
end

local function IsCyclicTable(tbl)
    local checkedtables = {}

    local function SearchTable(tbl)
        table.insert(checkedtables,tbl)
        
        for i,v in next, tbl do
            if type(v) == "table" then
                return table.find(checkedtables,v) and true or SearchTable(v)
            end
        end
    end

    return SearchTable(tbl)
end

local function deepclone(args: table, copies: table): table
    local copy = nil
    copies = copies or {}

    if type(args) == 'table' then
        if copies[args] then
            copy = copies[args]
        else
            copy = {}
            copies[args] = copy
            for i, v in next, args do
                copy[deepclone(i, copies)] = deepclone(v, copies)
            end
        end
    elseif typeof(args) == "Instance" then
        copy = cloneref(args)
    else
        copy = args
    end
    return copy
end

local function rawtostring(userdata)
    if type(userdata) == "table" or typeof(userdata) == "userdata" then
        local rawmetatable = getrawmetatable(userdata)
        local cachedstring = rawmetatable and rawget(rawmetatable, "__tostring")

        if cachedstring then
            local wasreadonly = isreadonly(rawmetatable)
            if wasreadonly then
                makewritable(rawmetatable)
            end
            rawset(rawmetatable, "__tostring", nil)
            local safestring = tostring(userdata)
            rawset(rawmetatable, "__tostring", cachedstring)
            if wasreadonly then
                makereadonly(rawmetatable)
            end
            return safestring
        end
    end
    return tostring(userdata)
end

local CoreGui = SafeGetService("CoreGui")
local Players = SafeGetService("Players")
local RunService = SafeGetService("RunService")
local UserInputService = SafeGetService("UserInputService")
local TweenService = SafeGetService("TweenService")
local TextService = SafeGetService("TextService")
local http = SafeGetService("HttpService")

-- UI Creation
local SimpleSpy = Create("ScreenGui",{
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local Background = Create("Frame",{
    Parent = SimpleSpy,
    BackgroundColor3 = Color3.fromRGB(37, 36, 38),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -200, 0.5, -150),
    Size = UDim2.new(0, 400, 0, 350),
    Active = true,
    Draggable = true,
    ZIndex = 1000
})

local TopBar = Create("Frame",{
    Parent = Background,
    BackgroundColor3 = Color3.fromRGB(47, 46, 48),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 25),
    ZIndex = 1001
})

local Title = Create("TextLabel",{
    Parent = TopBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 0),
    Size = UDim2.new(0, 100, 1, 0),
    Font = Enum.Font.SourceSansBold,
    Text = "SimpleSpy",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 1002
})

local ToggleButton = Create("TextButton",{
    Parent = TopBar,
    BackgroundColor3 = Color3.fromRGB(76, 175, 80),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 120, 0, 3),
    Size = UDim2.new(0, 70, 0, 19),
    Font = Enum.Font.SourceSans,
    Text = "ENABLED",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    ZIndex = 1002
})

local ClearButton = Create("TextButton",{
    Parent = TopBar,
    BackgroundColor3 = Color3.fromRGB(244, 67, 54),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 200, 0, 3),
    Size = UDim2.new(0, 50, 0, 19),
    Font = Enum.Font.SourceSans,
    Text = "CLEAR",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    ZIndex = 1002
})

local CloseButton = Create("TextButton",{
    Parent = TopBar,
    BackgroundColor3 = Color3.fromRGB(244, 67, 54),
    BorderSizePixel = 0,
    Position = UDim2.new(1, -25, 0, 3),
    Size = UDim2.new(0, 20, 0, 19),
    Font = Enum.Font.SourceSans,
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    ZIndex = 1002
})

local MainContainer = Create("Frame",{
    Parent = Background,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 25),
    Size = UDim2.new(1, 0, 1, -25),
    ZIndex = 1001
})

local LogList = Create("ScrollingFrame",{
    Parent = MainContainer,
    BackgroundColor3 = Color3.fromRGB(53, 52, 55),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0, 150, 1, 0),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ZIndex = 1001
})

local UIListLayout = Create("UIListLayout",{
    Parent = LogList,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2)
})

local RightPanel = Create("Frame",{
    Parent = MainContainer,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 150, 0, 0),
    Size = UDim2.new(1, -150, 1, 0),
    ZIndex = 1001
})

local CodeBox = Create("TextBox",{
    Parent = RightPanel,
    BackgroundColor3 = Color3.fromRGB(25, 25, 28),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 5, 0, 0),
    Size = UDim2.new(1, -10, 0.7, -5),
    ClearTextOnFocus = false,
    Font = Enum.Font.Code,
    MultiLine = true,
    Text = "Select a remote to view generated code",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 1002
})

local ToolButtons = Create("Frame",{
    Parent = RightPanel,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 5, 0.7, 5),
    Size = UDim2.new(1, -10, 0.3, -10),
    ZIndex = 1001
})

local UIGridLayout = Create("UIGridLayout",{
    Parent = ToolButtons,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    CellPadding = UDim2.new(0, 5, 0, 5),
    CellSize = UDim2.new(0.5, -5, 0, 25)
})

-- Variables
local logs = {}
local remoteLogs = {}
local layoutOrderNum = 999999999
local spyEnabled = true
local originalNamecall
local originalEvent
local originalFunction
local originalUnreliableEvent
local connectedRemotes = {}
local toggle = false
local scheduled = {}
local schedulerconnect
local DecompiledScripts = {}
local running_threads = {}
local blacklist = {}
local blocklist = {}
local history = {}
local excluding = {}
local generation = {}
local getnilrequired = false

-- Core Functions
local function logthread(thread: thread)
    table.insert(running_threads,thread)
end

local function ThreadIsNotDead(thread: thread): boolean
    return status(thread) ~= "dead"
end

local function clean()
    local max = getgenv().SIMPLESPYCONFIG_MaxRemotes or 300
    if #remoteLogs > max then
        for i = 100, #remoteLogs do
            local v = remoteLogs[i]
            if typeof(v[1]) == "RBXScriptConnection" then
                v[1]:Disconnect()
            end
            if typeof(v[2]) == "Instance" then
                v[2]:Destroy()
            end
        end
        local newLogs = {}
        for i = 1, 100 do
            table.insert(newLogs, remoteLogs[i])
        end
        remoteLogs = newLogs
    end
end

local function getPlayerFromInstance(instance)
    for _, v in next, Players:GetPlayers() do
        if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
            return v
        end
    end
end

local function getplayer(instance)
    for _, v in next, Players:GetPlayers() do
        if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
            return v
        end
    end
end

local function getScriptFromSrc(src)
    local realPath
    local runningTest
    local s, e
    local match = false
    if src:sub(1, 1) == "=" then
        realPath = game
        s = 2
    else
        runningTest = src:sub(2, e and e - 1 or -1)
        for _, v in next, getnilinstances() do
            if v.Name == runningTest then
                realPath = v
                break
            end
        end
        s = #runningTest + 1
    end
    if realPath then
        e = src:sub(s, -1):find("%.")
        local i = 0
        repeat
            i += 1
            if not e then
                runningTest = src:sub(s, -1)
                local test = realPath.FindFirstChild(realPath, runningTest)
                if test then
                    realPath = test
                end
                match = true
            else
                runningTest = src:sub(s, e)
                local test = realPath.FindFirstChild(realPath, runningTest)
                local yeOld = e
                if test then
                    realPath = test
                    s = e + 2
                    e = src:sub(e + 2, -1):find("%.")
                    e = e and e + yeOld or e
                else
                    e = src:sub(e + 2, -1):find("%.")
                    e = e and e + yeOld or e
                end
            end
        until match or i >= 50
    end
    return realPath
end

local function schedule(f, ...)
    table.insert(scheduled, {f, ...})
end

local function scheduleWait()
    local thread = running()
    schedule(function()
        resume(thread)
    end)
    yield()
end

local function taskscheduler()
    if not toggle then
        scheduled = {}
        return
    end
    if #scheduled > 300 + 100 then
        table.remove(scheduled, #scheduled)
    end
    if #scheduled > 0 then
        local currentf = scheduled[1]
        table.remove(scheduled, 1)
        if type(currentf) == "table" and type(currentf[1]) == "function" then
            pcall(unpack(currentf))
        end
    end
end

-- Serialization Functions
local CustomGeneration = {
    Vector3 = (function()
        local temp = {}
        for i,v in Vector3 do
            if type(v) == "vector" then
                temp[v] = `Vector3.{i}`
            end
        end
        return temp
    end)(),
    Vector2 = (function()
        local temp = {}
        for i,v in Vector2 do
            if type(v) == "userdata" then
                temp[v] = `Vector2.{i}`
            end
        end
        return temp
    end)(),
    CFrame = {
        [CFrame.identity] = "CFrame.identity"
    }
}

local number_table = {
    ["inf"] = "math.huge",
    ["-inf"] = "-math.huge",
    ["nan"] = "0/0"
}

local ufunctions = {
    TweenInfo = function(u)
        return `TweenInfo.new({u.Time}, {u.EasingStyle}, {u.EasingDirection}, {u.RepeatCount}, {u.Reverses}, {u.DelayTime})`
    end,
    Ray = function(u)
        local Vector3tostring = ufunctions["Vector3"]
        return `Ray.new({Vector3tostring(u.Origin)}, {Vector3tostring(u.Direction)})`
    end,
    BrickColor = function(u)
        return `BrickColor.new({u.Number})`
    end,
    NumberRange = function(u)
        return `NumberRange.new({u.Min}, {u.Max})`
    end,
    Region3 = function(u)
        local center = u.CFrame.Position
        local centersize = u.Size/2
        local Vector3tostring = ufunctions["Vector3"]
        return `Region3.new({Vector3tostring(center-centersize)}, {Vector3tostring(center+centersize)})`
    end,
    Faces = function(u)
        local faces = {}
        if u.Top then table.insert(faces, "Top") end
        if u.Bottom then table.insert(faces, "Enum.NormalId.Bottom") end
        if u.Left then table.insert(faces, "Enum.NormalId.Left") end
        if u.Right then table.insert(faces, "Enum.NormalId.Right") end
        if u.Back then table.insert(faces, "Enum.NormalId.Back") end
        if u.Front then table.insert(faces, "Enum.NormalId.Front") end
        return `Faces.new({table.concat(faces, ", ")})`
    end,
    EnumItem = function(u) return tostring(u) end,
    Enums = function(u) return "Enum" end,
    Enum = function(u) return `Enum.{u}` end,
    Vector3 = function(u) return CustomGeneration.Vector3[u] or `Vector3.new({u.X}, {u.Y}, {u.Z})` end,
    Vector2 = function(u) return CustomGeneration.Vector2[u] or `Vector2.new({u.X}, {u.Y})` end,
    CFrame = function(u) return CustomGeneration.CFrame[u] or `CFrame.new({table.concat({u:GetComponents()},", ")})` end,
    PathWaypoint = function(u) return `PathWaypoint.new({ufunctions["Vector3"](u.Position)}, {u.Action})` end,
    UDim = function(u) return `UDim.new({u.Scale}, {u.Offset})` end,
    UDim2 = function(u) return `UDim2.new({u.X.Scale}, {u.X.Offset}, {u.Y.Scale}, {u.Y.Offset})` end,
    Rect = function(u) local Vector2tostring = ufunctions["Vector2"] return `Rect.new({Vector2tostring(u.Min)}, {Vector2tostring(u.Max)})` end,
    Color3 = function(u) return `Color3.new({u.R}, {u.G}, {u.B})` end,
    RBXScriptSignal = function(u) return "nil" end,
    RBXScriptConnection = function(u) return "nil" end,
}

local function formatstr(s, indentation)
    if not indentation then indentation = 0 end
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\t", "\\t")
    return '"' .. s .. '"'
end

local function v2s(v, l, p, n, vtv, i, pt, path, tables, tI)
    local vtypeof = typeof(v)
    local vtype = type(v)
    
    if vtypeof == "string" then
        return formatstr(v)
    elseif vtypeof == "number" then
        local number = tostring(v)
        return number_table[number] or number
    elseif vtypeof == "boolean" then
        return tostring(v)
    elseif vtypeof == "Vector3" then
        return ufunctions.Vector3(v)
    elseif vtypeof == "Vector2" then
        return ufunctions.Vector2(v)
    elseif vtypeof == "CFrame" then
        return ufunctions.CFrame(v)
    elseif vtypeof == "Color3" then
        return ufunctions.Color3(v)
    elseif vtypeof == "UDim2" then
        return ufunctions.UDim2(v)
    elseif vtypeof == "UDim" then
        return ufunctions.UDim(v)
    elseif vtypeof == "BrickColor" then
        return ufunctions.BrickColor(v)
    elseif vtypeof == "Instance" then
        return i2p(v)
    elseif vtypeof == "table" then
        return t2s(v, l, p, n, vtv, i, pt, path, tables, tI)
    else
        return "nil"
    end
end

local function f2s(f)
    if configs.funcEnabled then
        local funcname = info(f,"n")
        if funcname and funcname:match("^[%a_]+[%w_]*$") then
            return `function {funcname}() end`
        end
    end
    return "function() end"
end

local function i2p(i)
    if i == game then
        return "game"
    end
    if i == workspace then
        return "workspace"
    end
    if i:IsA("Player") and i == Players.LocalPlayer then
        return 'game:GetService("Players").LocalPlayer'
    end
    
    local player = getplayer(i)
    local parent = i
    local out = ""
    
    if parent == nil then
        return "nil"
    end
    
    if player then
        while true do
            if parent and parent == player.Character then
                if player == Players.LocalPlayer then
                    return 'game:GetService("Players").LocalPlayer.Character' .. out
                else
                    return i2p(player) .. ".Character" .. out
                end
            else
                if parent.Name:match("[%a_]+[%w+]*") ~= parent.Name then
                    out = ':FindFirstChild(' .. formatstr(parent.Name) .. ')' .. out
                else
                    out = "." .. parent.Name .. out
                end
            end
            parent = parent.Parent
            if not parent then break end
        end
    elseif parent ~= game then
        while true do
            if parent and parent.Parent == game then
                if SafeGetService(parent.ClassName) then
                    if lower(parent.ClassName) == "workspace" then
                        return `workspace{out}`
                    else
                        return 'game:GetService("' .. parent.ClassName .. '")' .. out
                    end
                else
                    if parent.Name:match("[%a_]+[%w_]*") then
                        return "game." .. parent.Name .. out
                    else
                        return 'game:FindFirstChild(' .. formatstr(parent.Name) .. ')' .. out
                    end
                end
            elseif not parent.Parent then
                getnilrequired = true
                return 'getNil(' .. formatstr(parent.Name) .. ', "' .. parent.ClassName .. '")' .. out
            else
                if parent.Name:match("[%a_]+[%w_]*") ~= parent.Name then
                    out = ':WaitForChild(' .. formatstr(parent.Name) .. ')' .. out
                else
                    out = ':WaitForChild("' .. parent.Name .. '")'..out
                end
            end
            parent = parent.Parent
            if not parent then break end
        end
    else
        return "game"
    end
end

local function t2s(t, l, p, n, vtv, i, pt, path, tables, tI)
    if not tI then tI = {0} end
    if not path then path = "" end
    if not l then l = 0 tables = {} end
    if not p then p = t end
    
    for _, v in next, tables do
        if n and rawequal(v, t) then
            return "{}"
        end
    end
    table.insert(tables, t)
    
    local s = "{" 
    local size = 0
    l = l + 4
    
    for k, v in next, t do
        size = size + 1
        if size > 1000 then
            s = s .. ""
            break
        end
        
        if rawequal(k, t) then
            continue
        end
        
        local keyStr
        if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then
            keyStr = k
        else
            keyStr = "[" .. v2s(k, l, p, n, vtv, k, t, path, tables, tI) .. "]"
        end
        
        local valueStr = v2s(v, l, p, n, vtv, k, t, path, tables, tI)
        
        s = s .. "\n" .. string.rep(" ", l) .. keyStr .. " = " .. valueStr .. ","
    end
    
    if #s > 1 then
        s = s:sub(1, #s - 1)
    end
    
    if size > 0 then
        s = s .. "\n" .. string.rep(" ", l - 4)
    end
    
    return s .. "}"
end

local function genScript(remote, args)
    local gen = ""
    
    if getnilrequired then
        gen = "function getNil(name,class) for _,v in next, getnilinstances() do if v.ClassName==class and v.Name==name then return v;end end end\n\n"
    end
    
    if #args > 0 then
        gen = gen .. "local args = " .. v2s(args) .. "\n\n"
        if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
            gen = gen .. v2s(remote) .. ":FireServer(unpack(args))"
        elseif remote:IsA("RemoteFunction") then
            gen = gen .. v2s(remote) .. ":InvokeServer(unpack(args))"
        end
    else
        if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
            gen = gen .. v2s(remote) .. ":FireServer()"
        elseif remote:IsA("RemoteFunction") then
            gen = gen .. v2s(remote) .. ":InvokeServer()"
        end
    end
    
    return gen
end

-- UI Functions
local function updateLogCanvas()
    LogList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

local function clearLogs()
    for _, v in ipairs(remoteLogs) do
        if v[1] then v[1]:Disconnect() end
        if v[2] then v[2]:Destroy() end
    end
    logs = {}
    remoteLogs = {}
    CodeBox.Text = "Logs cleared"
    layoutOrderNum = 999999999
end

local function tablecheck(tabletocheck,instance,id)
    return tabletocheck[id] or tabletocheck[instance.Name]
end

local function createLogEntry(remoteName, remoteType, remote, args, callingScript, func)
    if configs.autoblock then
        local id = OldDebugId(remote)
        if excluding[id] then return end
        if not history[id] then history[id] = {badOccurances = 0, lastCall = tick()} end
        if tick() - history[id].lastCall < 1 then
            history[id].badOccurances += 1
            return
        else
            history[id].badOccurances = 0
        end
        if history[id].badOccurances > 3 then
            excluding[id] = true
            return
        end
        history[id].lastCall = tick()
    end

    local id = OldDebugId(remote)
    if tablecheck(blacklist,remote,id) then return end
    
    layoutOrderNum = layoutOrderNum - 1
    
    local LogEntry = Create("TextButton",{
        Parent = LogList,
        BackgroundColor3 = Color3.fromRGB(45, 45, 48),
        BorderSizePixel = 0,
        LayoutOrder = layoutOrderNum,
        Size = UDim2.new(0.95, 0, 0, 30),
        Font = Enum.Font.SourceSans,
        Text = remoteName .. " (" .. remoteType .. ")",
        TextColor3 = remoteType == "event" and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 255, 255),
        TextSize = 12,
        TextWrapped = true,
        ZIndex = 1002
    })
    
    local logData = {
        Name = remoteName,
        Remote = remote,
        Args = args,
        Type = remoteType,
        CallingScript = callingScript,
        Function = func,
        LogEntry = LogEntry,
        Blocked = tablecheck(blocklist,remote,id)
    }
    
    table.insert(logs, logData)
    
    local connection = LogEntry.MouseButton1Click:Connect(function()
        local script = genScript(remote, args)
        if logData.Blocked then
            script = "-- THIS REMOTE WAS BLOCKED FROM FIRING\n\n" .. script
        end
        CodeBox.Text = script
    end)
    
    table.insert(remoteLogs, {connection, LogEntry})
    clean()
    updateLogCanvas()
end

-- Remote Handling
local function remoteHandler(data)
    if (data.remote:IsA("RemoteEvent") or data.remote:IsA("UnreliableRemoteEvent")) and lower(data.method) == "fireserver" then
        createLogEntry(data.remote.Name, "event", data.remote, data.args, data.callingscript, data.infofunc)
    elseif data.remote:IsA("RemoteFunction") and lower(data.method) == "invokeserver" then
        createLogEntry(data.remote.Name, "function", data.remote, data.args, data.callingscript, data.infofunc)
    end
end

local function handleRemoteCall(remote, args, method, callingScript)
    if not spyEnabled then return end
    if not configs.logcheckcaller and checkcaller() then return end
    
    if not remote:IsA("RemoteEvent") and not remote:IsA("RemoteFunction") and not remote:IsA("UnreliableRemoteEvent") then
        return
    end
    
    local id = OldDebugId(remote)
    if tablecheck(blocklist,remote,id) then return end
    
    local remoteType = "event"
    if remote:IsA("RemoteFunction") then
        remoteType = "function"
    end
    
    if IsCyclicTable(args) then return end
    
    local clonedArgs = deepclone(args)
    
    local data = {
        method = method,
        remote = remote,
        args = clonedArgs,
        callingscript = callingScript,
        id = id
    }
    
    if configs.funcEnabled then
        data.infofunc = info(2,"f")
    end
    
    schedule(remoteHandler, data)
end

-- Hooking
local newNamecall = newcclosure(function(...)
    local method = getnamecallmethod()
    
    if method == "FireServer" or method == "InvokeServer" then
        local remote = ...
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("UnreliableRemoteEvent")) then
            local args = {select(2, ...)}
            local callingScript = getcallingscript()
            handleRemoteCall(remote, args, method, callingScript)
        end
    end
    
    return originalNamecall(...)
end)

local newFireServer = newcclosure(function(...)
    local remote = ...
    if remote and remote:IsA("RemoteEvent") then
        local args = {select(2, ...)}
        local callingScript = getcallingscript()
        handleRemoteCall(remote, args, "FireServer", callingScript)
    end
    return originalEvent(...)
end)

local newInvokeServer = newcclosure(function(...)
    local remote = ...
    if remote and remote:IsA("RemoteFunction") then
        local args = {select(2, ...)}
        local callingScript = getcallingscript()
        handleRemoteCall(remote, args, "InvokeServer", callingScript)
    end
    return originalFunction(...)
end)

local function toggleSpy()
    spyEnabled = not spyEnabled
    if spyEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        ToggleButton.Text = "ENABLED"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        ToggleButton.Text = "DISABLED"
    end
end

local function enableHooks()
    if not originalNamecall then
        originalNamecall = hookmetamethod(game, "__namecall", newNamecall)
        originalEvent = hookfunction(Instance.new("RemoteEvent").FireServer, newFireServer)
        originalFunction = hookfunction(Instance.new("RemoteFunction").InvokeServer, newInvokeServer)
        toggle = true
    end
end

local function disableHooks()
    if originalNamecall then
        hookmetamethod(game, "__namecall", originalNamecall)
        hookfunction(Instance.new("RemoteEvent").FireServer, originalEvent)
        hookfunction(Instance.new("RemoteFunction").InvokeServer, originalFunction)
        originalNamecall = nil
        toggle = false
    end
end

local function shutdown()
    disableHooks()
    if schedulerconnect then schedulerconnect:Disconnect() end
    for _, v in pairs(remoteLogs) do if v[1] then v[1]:Disconnect() end end
    for i,v in next, running_threads do if ThreadIsNotDead(v) then close(v) end end
    SimpleSpy:Destroy()
    getgenv().SimpleSpyExecuted = false
end

-- Tool Buttons
local function createToolButton(text, callback)
    local button = Create("TextButton",{
        BackgroundColor3 = Color3.fromRGB(66, 66, 66),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Parent = ToolButtons,
        ZIndex = 1002
    })
    
    button.MouseButton1Click:Connect(function()
        logthread(running())
        callback()
    end)
    return button
end

createToolButton("COPY CODE", function() 
    setclipboard(CodeBox.Text) 
end)

createToolButton("RUN CODE", function()
    local func, err = loadstring(CodeBox.Text)
    if func then
        local success, result = pcall(func)
        if not success then
            CodeBox.Text = "Error: " .. tostring(result)
        end
    else
        CodeBox.Text = "Load error: " .. tostring(err)
    end
end)

createToolButton("DECOMPILE", function()
    if decompile then
        for _, log in ipairs(logs) do
            if log.CallingScript and log.CallingScript:IsA("LocalScript") then
                if not DecompiledScripts[log.CallingScript] then
                    local success, decompiled = pcall(decompile, log.CallingScript)
                    if success then
                        DecompiledScripts[log.CallingScript] = decompiled
                    end
                end
                CodeBox.Text = DecompiledScripts[log.CallingScript] or "Decompilation failed"
                return
            end
        end
        CodeBox.Text = "No decompilable script found"
    else
        CodeBox.Text = "Decompile function not available"
    end
end)

createToolButton("GET SCRIPT", function()
    for _, log in ipairs(logs) do
        if log.CallingScript then
            CodeBox.Text = v2s(log.CallingScript)
            return
        end
    end
    CodeBox.Text = "No calling script found"
end)

createToolButton("FUNCTION INFO", function()
    for _, log in ipairs(logs) do
        if log.Function then
            local info = {
                Name = log.Name,
                Type = log.Type,
                Remote = v2s(log.Remote),
                CallingScript = log.CallingScript and v2s(log.CallingScript) or "Unknown",
                ArgsCount = #log.Args,
                Blocked = log.Blocked
            }
            CodeBox.Text = "Function Info:\n" .. v2s(info)
            return
        end
    end
    CodeBox.Text = "No function info available"
end)

createToolButton("CLEAR LOGS", clearLogs)

createToolButton("EXCLUDE", function()
    for _, log in ipairs(logs) do
        if log.Remote then
            blacklist[OldDebugId(log.Remote)] = true
            CodeBox.Text = "Remote excluded from logging"
            return
        end
    end
end)

-- Event Connections
ToggleButton.MouseButton1Click:Connect(toggleSpy)
ClearButton.MouseButton1Click:Connect(clearLogs)
CloseButton.MouseButton1Click:Connect(shutdown)

-- Input handling to prevent conflict with game
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = UserInputService:GetMouseLocation()
        local backgroundPos = Background.AbsolutePosition
        local backgroundSize = Background.AbsoluteSize
        
        if mousePos.X >= backgroundPos.X and mousePos.X <= backgroundPos.X + backgroundSize.X and
           mousePos.Y >= backgroundPos.Y and mousePos.Y <= backgroundPos.Y + backgroundSize.Y then
            -- Click is inside SimpleSpy UI, don't pass to game
            -- This prevents conflict with game controls
        end
    end
end)

-- Initialize
if not getgenv().SimpleSpyExecuted then
    getgenv().SimpleSpyShutdown = shutdown
    enableHooks()
    schedulerconnect = RunService.Heartbeat:Connect(taskscheduler)
    SimpleSpy.Parent = CoreGui
    getgenv().SimpleSpyExecuted = true
    getgenv().getNil = function(name,class)
        for _,v in next, getnilinstances() do
            if v.ClassName == class and v.Name == name then return v end
        end
    end
    
    -- Initialize generation table
    local lp = Players.LocalPlayer
    if lp then
        generation = {
            [OldDebugId(lp)] = 'game:GetService("Players").LocalPlayer',
            [OldDebugId(game)] = "game",
            [OldDebugId(workspace)] = "workspace"
        }
    end
else
    SimpleSpy:Destroy()
    return
end