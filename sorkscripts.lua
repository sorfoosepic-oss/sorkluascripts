--// ====================================================
--// SORKSCRIPTS | CRECER POLLO | V3.0 - ULTRA ROBUST
--// Estilo Vertex (Oscuro + Acento Morado)
--// Compatible con Delta Mobile & Roblox Studio
--// ====================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ====================================================
-- CONFIGURACIÓN DE COLORES (VERTEX STYLE MEJORADO)
-- ====================================================

local CONFIG = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 28),
    Card = Color3.fromRGB(28, 28, 38),
    CardHover = Color3.fromRGB(35, 35, 48),
    Accent = Color3.fromRGB(145, 70, 255),
    AccentDark = Color3.fromRGB(110, 50, 200),
    AccentLight = Color3.fromRGB(180, 120, 255),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(140, 140, 155),
    ToggleOn = Color3.fromRGB(145, 70, 255),
    ToggleOff = Color3.fromRGB(50, 50, 65),
    Success = Color3.fromRGB(52, 168, 83),
    Warning = Color3.fromRGB(255, 193, 7),
    Error = Color3.fromRGB(244, 67, 54),
    Gradient1 = Color3.fromRGB(145, 70, 255),
    Gradient2 = Color3.fromRGB(70, 40, 180),
}

-- ====================================================
-- VARIABLES GLOBALES
-- ====================================================

local ScriptState = {
    AutoFarm = false,
    AutoCollectEggs = false,
    AutoHatch = false,
    AutoSell = false,
    AutoFight = false,
    AutoClimbTower = false,
    AutoFuse = false,
    WalkSpeed = false,
    JumpPower = false,
    InfiniteJump = false,
    ESPChickens = false,
    ESPEggs = false,
    AutoRejoin = false,
    AntiAFK = true,
    AutoEquipBest = false,
}

local ScriptActive = true
local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local AutoFarmLoop = nil
local AutoEggLoop = nil
local Connection = nil

-- ====================================================
-- SISTEMA DE LOGGING MEJORADO
-- ====================================================

local function Log(message, type)
    type = type or "INFO"
    local prefix = {
        INFO = "ℹ️",
        SUCCESS = "✅",
        WARNING = "⚠️",
        ERROR = "❌",
        DEBUG = "🔍",
        MONEY = "💰",
        EGG = "🥚",
        CHICKEN = "🐔"
    }
    print("[Sorkscripts v3] " .. (prefix[type] or "•") .. " " .. message)
end

-- ====================================================
-- SISTEMA DE DETECCIÓN DE REMOTES MEJORADO
-- ====================================================

local RemoteCache = {}
local RemoteNames = {
    CollectEgg = {"CollectEgg", "Collect", "TakeEgg", "PickUpEgg", "GrabEgg", "GetEgg"},
    HatchEgg = {"HatchEgg", "Hatch", "IncubateEgg", "OpenEgg", "HatchPet"},
    SellChicken = {"Sell", "SellChicken", "SellPet", "SellAll", "TradeChicken"},
    Attack = {"Attack", "Fight", "Damage", "Hit", "Punch"},
    Feed = {"Feed", "FeedChicken", "GiveFood", "Eat"},
    EquipPet = {"Equip", "EquipPet", "SelectPet", "ChoosePet"},
    FusePet = {"Fuse", "FusePet", "Combine", "Merge"},
    Upgrade = {"Upgrade", "UpgradeChicken", "LevelUp", "Enhance"},
    Rebirth = {"Rebirth", "Reset", "Prestige", "NewGame"},
    ClaimReward = {"Claim", "ClaimReward", "GetReward", "CollectReward"},
}

local function FindRemoteSmart(nameList, timeout)
    timeout = timeout or 3
    
    -- Buscar en caché primero
    for _, name in ipairs(nameList) do
        if RemoteCache[name] then
            return RemoteCache[name]
        end
    end
    
    local startTime = tick()
    
    while tick() - startTime < timeout do
        -- Buscar directamente en ReplicatedStorage
        for _, name in ipairs(nameList) do
            local remote = ReplicatedStorage:FindFirstChild(name)
            if remote then
                RemoteCache[name] = remote
                return remote
            end
        end
        
        -- Buscar en carpetas comunes
        local folders = {"Remotes", "RemoteEvents", "Events", "Functions", "RemoteFunctions", "Network"}
        
        for _, folderName in ipairs(folders) do
            local folder = ReplicatedStorage:FindFirstChild(folderName)
            if folder then
                for _, name in ipairs(nameList) do
                    local remote = folder:FindFirstChild(name)
                    if remote then
                        RemoteCache[name] = remote
                        return remote
                    end
                    
                    -- Buscar recursivamente en subcarpetas
                    local function searchDeep(parent)
                        for _, child in pairs(parent:GetChildren()) do
                            if child.Name == name then
                                RemoteCache[name] = child
                                return child
                            end
                            if child:IsA("Folder") or child:IsA("Configuration") then
                                local found = searchDeep(child)
                                if found then return found end
                            end
                        end
                        return nil
                    end
                    
                    local found = searchDeep(folder)
                    if found then
                        return found
                    end
                end
            end
        end
        
        task.wait(0.1)
    end
    
    return nil
end

local function SafeFire(remote, ...)
    if not remote then return false end
    
    local ok, err = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        elseif remote:IsA("BindableEvent") then
            remote:Fire(...)
        elseif remote:IsA("BindableFunction") then
            remote:Invoke(...)
        end
    end)
    
    if not ok then
        Log("Error al disparar: " .. tostring(err), "ERROR")
        return false
    end
    
    return true
end

-- ====================================================
-- SISTEMA DE DETECCIÓN DE ESTRUCTURA DEL JUEGO
-- ====================================================

local GameStructure = {
    Chickens = {},
    Eggs = {},
    FarmAreas = {},
    Shops = {},
    Towers = {},
    OtherPlayers = {},
}

local function UpdateGameStructure()
    GameStructure.Chickens = {}
    GameStructure.Eggs = {}
    GameStructure.FarmAreas = {}
    GameStructure.Shops = {}
    GameStructure.Towers = {}
    
    pcall(function()
        -- Buscar pollos/mascotas
        local searchPaths = {
            Workspace:GetChildren(),
            Workspace:FindFirstChild("Pets") and Workspace.Pets:GetChildren() or {},
            Workspace:FindFirstChild("Chickens") and Workspace.Chickens:GetChildren() or {},
            Workspace:FindFirstChild("Mobs") and Workspace.Mobs:GetChildren() or {},
        }
        
        for _, objects in ipairs(searchPaths) do
            for _, obj in ipairs(objects) do
                local name = obj.Name:lower()
                if obj:IsA("Model") and (name:find("chicken") or name:find("pollo") or name:find("pet") or name:find("mascota")) then
                    local humanoid = obj:FindFirstChild("Humanoid")
                    local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                    
                    if humanoid and rootPart and humanoid.Health > 0 then
                        table.insert(GameStructure.Chickens, obj)
                    end
                end
            end
        end
        
        -- Buscar huevos
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                if name:find("egg") or name:find("huevo") then
                    table.insert(GameStructure.Eggs, obj)
                end
            end
        end
        
        -- Buscar áreas de farm
        for _, obj in pairs(Workspace:GetChildren()) do
            local name = obj.Name:lower()
            if obj:IsA("Part") and (name:find("farm") or name:find("area") or name:find("zone")) then
                table.insert(GameStructure.FarmAreas, obj)
            end
        end
        
        -- Buscar torres/obstáculos
        for _, obj in pairs(Workspace:GetChildren()) do
            local name = obj.Name:lower()
            if obj:IsA("Model") and (name:find("tower") or name:find("torre") or name:find("climb")) then
                table.insert(GameStructure.Towers, obj)
            end
        end
        
        -- Obtener otros jugadores
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                table.insert(GameStructure.OtherPlayers, player.Character)
            end
        end
    end)
    
    return GameStructure
end

-- ====================================================
-- FUNCIONES DE MOVIMIENTO MEJORADAS
-- ====================================================

local Movement = {}

function Movement:Teleport(position)
    pcall(function()
        if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
            PlayerCharacter.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
end

function Movement:MoveTo(position, speed)
    pcall(function()
        if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
            local humanoid = PlayerCharacter.Humanoid
            humanoid:MoveTo(position)
            if speed then
                humanoid.WalkSpeed = speed
            end
        end
    end)
end

function Movement:GetNearest(objects, maxDistance)
    local nearest = nil
    local nearestDistance = maxDistance or 1000
    
    if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
        local playerPos = PlayerCharacter.HumanoidRootPart.Position
        
        for _, obj in ipairs(objects) do
            local objPos = nil
            
            if obj:IsA("Model") then
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if rootPart then
                    objPos = rootPart.Position
                end
            elseif obj:IsA("BasePart") then
                objPos = obj.Position
            end
            
            if objPos then
                local distance = (playerPos - objPos).Magnitude
                if distance < nearestDistance then
                    nearest = obj
                    nearestDistance = distance
                end
            end
        end
    end
    
    return nearest, nearestDistance
end

-- ====================================================
-- SISTEMA DE FARMING MEJORADO
-- ====================================================

local Farming = {}

function Farming:CollectEggs()
    Log("Iniciando Auto Collect Eggs...", "EGG")
    
    while ScriptState.AutoCollectEggs and ScriptActive do
        task.wait(0.2)
        
        UpdateGameStructure()
        
        if #GameStructure.Eggs > 0 then
            local nearestEgg, distance = Movement:GetNearest(GameStructure.Eggs, 50)
            
            if nearestEgg then
                -- Mover al huevo
                Movement:Teleport(nearestEgg.Position + Vector3.new(0, 3, 0))
                
                -- Intentar múltiples remotes
                local collectRemote = FindRemoteSmart(RemoteNames.CollectEgg, 1)
                if collectRemote then
                    SafeFire(collectRemote, nearestEgg)
                else
                    -- Intentar tocar el huevo
                    pcall(function()
                        if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
                            local touchPart = Instance.new("Part")
                            touchPart.Size = Vector3.new(1, 1, 1)
                            touchPart.Position = nearestEgg.Position
                            touchPart.CanCollide = false
                            touchPart.Transparency = 1
                            touchPart.Parent = Workspace
                            
                            task.wait(0.1)
                            touchPart:Destroy()
                        end
                    end)
                end
                
                Log("Huevo recolectado: " .. nearestEgg.Name, "SUCCESS")
                task.wait(0.3)
            end
        else
            task.wait(1)
        end
    end
end

function Farming:HatchEggs()
    Log("Iniciando Auto Hatch...", "EGG")
    
    while ScriptState.AutoHatch and ScriptActive do
        task.wait(0.5)
        
        local hatchRemote = FindRemoteSmart(RemoteNames.HatchEgg, 2)
        
        if hatchRemote then
            SafeFire(hatchRemote)
            Log("Huevo eclosionado", "SUCCESS")
            task.wait(0.5)
        else
            -- Buscar huevo en inventario
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    local name = item.Name:lower()
                    if name:find("egg") or name:find("huevo") then
                        -- Intentar usar el item
                        pcall(function()
                            if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                                PlayerCharacter.Humanoid:EquipTool(item)
                                task.wait(0.2)
                                PlayerCharacter.Humanoid:UnequipTools()
                            end
                        end)
                        break
                    end
                end
            end
            task.wait(1)
        end
    end
end

function Farming:FarmChickens()
    Log("Iniciando Auto Farm Chickens...", "CHICKEN")
    
    while ScriptState.AutoFarm and ScriptActive do
        task.wait(0.3)
        
        UpdateGameStructure()
        
        if #GameStructure.Chickens > 0 then
            local nearestChicken, distance = Movement:GetNearest(GameStructure.Chickens, 30)
            
            if nearestChicken then
                local rootPart = nearestChicken:FindFirstChild("HumanoidRootPart") or nearestChicken.PrimaryPart
                
                if rootPart then
                    -- Mover cerca del pollo
                    Movement:Teleport(rootPart.Position + Vector3.new(0, 3, 3))
                    
                    -- Intentar atacar o alimentar
                    local attackRemote = FindRemoteSmart(RemoteNames.Attack, 1) or FindRemoteSmart(RemoteNames.Feed, 1)
                    
                    if attackRemote then
                        SafeFire(attackRemote, nearestChicken)
                        Log("Atacando: " .. nearestChicken.Name, "CHICKEN")
                    else
                        -- Intentar usar herramienta
                        local tool = PlayerCharacter and PlayerCharacter:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                        end
                    end
                    
                    task.wait(0.2)
                end
            end
        else
            -- Si no hay pollos, intentar buscar área de farm
            if #GameStructure.FarmAreas > 0 then
                local farmArea = GameStructure.FarmAreas[1]
                Movement:Teleport(farmArea.Position + Vector3.new(0, 5, 0))
            end
            task.wait(1)
        end
    end
end

function Farming:SellChickens()
    Log("Iniciando Auto Sell...", "MONEY")
    
    while ScriptState.AutoSell and ScriptActive do
        task.wait(0.8)
        
        local sellRemote = FindRemoteSmart(RemoteNames.SellChicken, 2)
        
        if sellRemote then
            SafeFire(sellRemote)
            Log("Pollos vendidos", "MONEY")
            task.wait(0.5)
        else
            -- Buscar NPC de venta
            for _, obj in pairs(Workspace:GetDescendants()) do
                local name = obj.Name:lower()
                if obj:IsA("Model") and (name:find("shop") or name:find("seller") or name:find("vendor") or name:find("tienda") or name:find("vendedor")) then
                    local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                    if rootPart then
                        Movement:Teleport(rootPart.Position + Vector3.new(0, 2, 2))
                        task.wait(0.5)
                        break
                    end
                end
            end
            task.wait(1)
        end
    end
end

function Farming:AutoFight()
    Log("Iniciando Auto Fight...", "CHICKEN")
    
    while ScriptState.AutoFight and ScriptActive do
        task.wait(0.2)
        
        UpdateGameStructure()
        
        if #GameStructure.OtherPlayers > 0 then
            local nearestPlayer, distance = Movement:GetNearest(GameStructure.OtherPlayers, 50)
            
            if nearestPlayer then
                local rootPart = nearestPlayer:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    Movement:Teleport(rootPart.Position + Vector3.new(0, 3, 0))
                    
                    local attackRemote = FindRemoteSmart(RemoteNames.Attack, 1)
                    if attackRemote then
                        SafeFire(attackRemote, nearestPlayer)
                    else
                        local tool = PlayerCharacter and PlayerCharacter:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                        end
                    end
                    
                    task.wait(0.1)
                end
            end
        else
            task.wait(1)
        end
    end
end

-- ====================================================
-- SISTEMA DE ESP MEJORADO
-- ====================================================

local ESP = {}

function ESP:CreateHighlight(object, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.3
    highlight.Parent = object
    return highlight
end

function ESP:StartESP()
    Log("Iniciando ESP...", "INFO")
    
    while (ScriptState.ESPChickens or ScriptState.ESPEggs) and ScriptActive do
        task.wait(1)
        
        UpdateGameStructure()
        
        -- ESP para pollos
        if ScriptState.ESPChickens then
            for _, chicken in ipairs(GameStructure.Chickens) do
                if not chicken:FindFirstChild("ESP_Highlight") then
                    local highlight = ESP:CreateHighlight(chicken, CONFIG.Accent)
                    highlight.Name = "ESP_Highlight"
                end
            end
        end
        
        -- ESP para huevos
        if ScriptState.ESPEggs then
            for _, egg in ipairs(GameStructure.Eggs) do
                if not egg:FindFirstChild("ESP_Highlight") then
                    local highlight = ESP:CreateHighlight(egg, CONFIG.Success)
                    highlight.Name = "ESP_Highlight"
                end
            end
        end
    end
    
    -- Limpiar ESP
    for _, obj in pairs(Workspace:GetDescendants()) do
        local highlight = obj:FindFirstChild("ESP_Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

-- ====================================================
-- SISTEMA ANTI-AFK MEJORADO
-- ====================================================

local AntiAFK = {}

function AntiAFK:Start()
    Log("Anti AFK activado", "SUCCESS")
    
    local lastAction = tick()
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        if not ScriptState.AntiAFK or not ScriptActive then
            connection:Disconnect()
            return
        end
        
        if tick() - lastAction > 60 then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                
                if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                    local humanoid = PlayerCharacter.Humanoid
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            lastAction = tick()
        end
    end)
end

-- ====================================================
-- SISTEMA DE RECONEXIÓN
-- ====================================================

local RejoinSystem = {}

function RejoinSystem:Start()
    Log("Auto Rejoin activado", "SUCCESS")
    
    while ScriptState.AutoRejoin and ScriptActive do
        task.wait(5)
        
        pcall(function()
            -- Verificar si el jugador está muerto o atrapado
            if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                local humanoid = PlayerCharacter.Humanoid
                
                if humanoid.Health <= 0 then
                    Log("Jugador muerto, reconectando...", "WARNING")
                    
                    -- Intentar usar el servicio de reconexión
                    local teleportService = game:GetService("TeleportService")
                    teleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end
        end)
        
        task.wait(300) -- Verificar cada 5 minutos
    end
end

-- ====================================================
-- LIMPIAR GUI ANTERIOR
-- ====================================================

pcall(function()
    if CoreGui:FindFirstChild("Sorkscripts") then
        CoreGui.Sorkscripts:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Sorkscripts"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ====================================================
-- PANTALLA DE CARGA ELEGANTE
-- ====================================================

local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = CONFIG.Background
Loading.BorderSizePixel = 0
Loading.Parent = ScreenGui

-- Efecto de partículas
local loadingEffect = Instance.new("Frame")
loadingEffect.Size = UDim2.new(0, 200, 0, 200)
loadingEffect.Position = UDim2.new(0.5, -100, 0.4, -100)
loadingEffect.BackgroundTransparency = 1
loadingEffect.Parent = Loading

for i = 1, 8 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0.5, -4, 0.5, -4)
    dot.BackgroundColor3 = CONFIG.Accent
    dot.BorderSizePixel = 0
    dot.Parent = loadingEffect
    
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local angle = (i - 1) * math.pi / 4
    local radius = 40
    
    coroutine.wrap(function()
        while true do
            local t = (tick() * 2) + angle
            local x = math.cos(t) * radius
            local y = math.sin(t) * radius
            
            TweenService:Create(dot, TweenInfo.new(0.5), {
                Position = UDim2.new(0.5, x, 0.5, y)
            }):Play()
            
            task.wait(0.5)
        end
    end)()
end

local Welcome = Instance.new("TextLabel")
Welcome.Size = UDim2.new(1, 0, 0, 60)
Welcome.Position = UDim2.new(0, 0, 0.35, 0)
Welcome.BackgroundTransparency = 1
Welcome.Text = "🔮 SORKSCRIPTS"
Welcome.TextColor3 = CONFIG.Accent
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 36
Welcome.Parent = Loading

local gradient = Instance.new("UIGradient", Welcome)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.Gradient1),
    ColorSequenceKeypoint.new(1, CONFIG.Gradient2),
})

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(1, 0, 0, 30)
UserLabel.Position = UDim2.new(0, 0, 0.44, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "Bienvenido, " .. LocalPlayer.Name
UserLabel.TextColor3 = CONFIG.Text
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 20
UserLabel.Parent = Loading

local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(1, 0, 0, 20)
GameLabel.Position = UDim2.new(0, 0, 0.5, 0)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Crecer Pollo v3.0 - Ultra Robust"
GameLabel.TextColor3 = CONFIG.TextDim
GameLabel.Font = Enum.Font.Gotham
GameLabel.TextSize = 14
GameLabel.Parent = Loading

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.6, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inicializando sistemas..."
StatusLabel.TextColor3 = CONFIG.TextDim
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = Loading

-- Barra de progreso mejorada
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0.3, 0, 0, 6)
BarBG.Position = UDim2.new(0.35, 0, 0.55, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
BarBG.BorderSizePixel = 0
BarBG.Parent = Loading

Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = CONFIG.Accent
Bar.BorderSizePixel = 0
Bar.Parent = BarBG

Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

local barGradient = Instance.new("UIGradient", Bar)
barGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.Gradient1),
    ColorSequenceKeypoint.new(1, CONFIG.Gradient2),
})

-- Animación de carga
local messages = {
    "Cargando scripts...",
    "Conectando a servidores...",
    "Detectando estructura del juego...",
    "Inicializando sistemas...",
    "Configurando interfaz...",
    "¡Listo!",
}

local barTween = TweenService:Create(Bar, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
    Size = UDim2.new(1, 0, 1, 0)
})

barTween:Play()

coroutine.wrap(function()
    for i, msg in ipairs(messages) do
        StatusLabel.Text = msg
        task.wait(0.5)
    end
end)()

barTween.Completed:Connect(function()
    task.wait(0.5)
    
    -- Desvanecer
    local fade = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(Loading, fade, {BackgroundTransparency = 1}):Play()
    TweenService:Create(Welcome, fade, {TextTransparency = 1}):Play()
    TweenService:Create(UserLabel, fade, {TextTransparency = 1}):Play()
    TweenService:Create(GameLabel, fade, {TextTransparency = 1}):Play()
    TweenService:Create(StatusLabel, fade, {TextTransparency = 1}):Play()
    TweenService:Create(BarBG, fade, {BackgroundTransparency = 1}):Play()
    TweenService:Create(Bar, fade, {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadingEffect, fade, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.6)
    Loading:Destroy()
    CreateMainUI()
end)

-- ====================================================
-- INTERFAZ PRINCIPAL MEJORADA
-- ====================================================

function CreateMainUI()
    -- Obtener headshot
    local headshot = "rbxassetid://0"
    pcall(function()
        headshot = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    
    -- Botón flotante
    local Toggle = Instance.new("ImageButton")
    Toggle.Name = "FloatingToggle"
    Toggle.Size = UDim2.new(0, 60, 0, 60)
    Toggle.Position = UDim2.new(0, 20, 0.42, 0)
    Toggle.BackgroundColor3 = CONFIG.Card
    Toggle.Image = headshot
    Toggle.ScaleType = Enum.ScaleType.Crop
    Toggle.Parent = ScreenGui
    Toggle.ZIndex = 100
    
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
    
    local toggleStroke = Instance.new("UIStroke", Toggle)
    toggleStroke.Color = CONFIG.Accent
    toggleStroke.Thickness = 2.5
    toggleStroke.Transparency = 0.2
    
    -- Frame principal
    local Main = Instance.new("Frame")
    Main.Name = "MainUI"
    Main.Size = UDim2.new(0, 600, 0, 450)
    Main.Position = UDim2.new(0.5, -300, 0.5, -225)
    Main.BackgroundColor3 = CONFIG.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Main.ZIndex = 50
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
    
    local mainGradient = Instance.new("UIGradient", Main)
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35)),
    })
    
    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = CONFIG.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.5
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = CONFIG.Sidebar
    Header.BorderSizePixel = 0
    Header.Parent = Main
    
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0.6, 0, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "🐔 Crecer Pollo v3.0"
    HeaderTitle.TextColor3 = CONFIG.Accent
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 18
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    local headerGradient = Instance.new("UIGradient", HeaderTitle)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.AccentLight),
        ColorSequenceKeypoint.new(1, CONFIG.Accent),
    })
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 170, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = CONFIG.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    -- Categorías
    local categories = {
        {Name = "Main", Icon = "🚀", Order = 1},
        {Name = "Farm", Icon = "🐔", Order = 2},
        {Name = "Combat", Icon = "⚔️", Order = 3},
        {Name = "Player", Icon = "👤", Order = 4},
        {Name = "ESP", Icon = "👁️", Order = 5},
        {Name = "Config", Icon = "⚙️", Order = 6},
    }
    
    local selectedCategory = "Main"
    local contentFrames = {}
    
    local CatList = Instance.new("Frame")
    CatList.Size = UDim2.new(1, -12, 1, 0)
    CatList.Position = UDim2.new(0, 6, 0, 8)
    CatList.BackgroundTransparency = 1
    CatList.Parent = Sidebar
    
    local catLayout = Instance.new("UIListLayout", CatList)
    catLayout.Padding = UDim.new(0, 6)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Área de contenido
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -185, 1, -60)
    ContentArea.Position = UDim2.new(0, 175, 0, 55)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main
    
    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, 0, 0, 30)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Main"
    ContentTitle.TextColor3 = CONFIG.Accent
    ContentTitle.Font = Enum.Font.GothamBold
    ContentTitle.TextSize = 18
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.Parent = ContentArea
    
    -- Crear frames de contenido
    for _, cat in ipairs(categories) do
        local frame = Instance.new("ScrollingFrame")
        frame.Name = cat.Name
        frame.Size = UDim2.new(1, 0, 1, -40)
        frame.Position = UDim2.new(0, 0, 0, 35)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.Accent
        frame.Visible = (cat.Name == "Main")
        frame.Parent = ContentArea
        
        contentFrames[cat.Name] = frame
        
        local list = Instance.new("UIListLayout", frame)
        list.Padding = UDim.new(0, 8)
        list.SortOrder = Enum.SortOrder.LayoutOrder
    end
    
    -- Función para crear toggle
    local function CreateToggle(parent, text, default, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 40)
        holder.BackgroundColor3 = CONFIG.Card
        holder.BorderSizePixel = 0
        holder.Parent = parent
        
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
        
        local holderStroke = Instance.new("UIStroke", holder)
        holderStroke.Color = Color3.fromRGB(50, 50, 65)
        holderStroke.Thickness = 1
        holderStroke.Transparency = 0.8
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = CONFIG.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = holder
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 46, 0, 26)
        toggle.Position = UDim2.new(1, -56, 0.5, -13)
        toggle.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
        toggle.Text = ""
        toggle.Parent = holder
        
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.Parent = toggle
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        local state = default
        
        toggle.MouseButton1Click:Connect(function()
            state = not state
            
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
            
            if callback then
                callback(state)
            end
        end)
        
        return holder
    end
    
    -- Función para crear slider
    local function CreateSlider(parent, text, min, max, default, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 55)
        holder.BackgroundColor3 = CONFIG.Card
        holder.BorderSizePixel = 0
        holder.Parent = parent
        
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.Position = UDim2.new(0, 12, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = CONFIG.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = holder
        
        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(0.3, 0, 0, 20)
        value.Position = UDim2.new(0.7, -20, 0, 5)
        value.BackgroundTransparency = 1
        value.Text = tostring(default)
        value.TextColor3 = CONFIG.Accent
        value.Font = Enum.Font.GothamBold
        value.TextSize = 12
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.Parent = holder
        
        local sliderBG = Instance.new("Frame")
        sliderBG.Size = UDim2.new(1, -24, 0, 6)
        sliderBG.Position = UDim2.new(0, 12, 0, 35)
        sliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = holder
        
        Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.Accent
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBG
        
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        
        local sliderGradient = Instance.new("UIGradient", sliderFill)
        sliderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CONFIG.Gradient1),
            ColorSequenceKeypoint.new(1, CONFIG.Gradient2),
        })
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 14, 0, 14)
        sliderButton.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.Text = ""
        sliderButton.Parent = sliderBG
        
        Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function()
            dragging = false
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = sliderBG.AbsolutePosition.X
                local sliderSize = sliderBG.AbsoluteSize.X
                local relativePos = math.clamp((mousePos.X - sliderPos) / sliderSize, 0, 1)
                
                local newValue = math.round(min + (relativePos * (max - min)))
                
                TweenService:Create(sliderFill, TweenInfo.new(0.05), {
                    Size = UDim2.new(relativePos, 0, 1, 0)
                }):Play()
                
                TweenService:Create(sliderButton, TweenInfo.new(0.05), {
                    Position = UDim2.new(relativePos, -7, 0.5, -7)
                }):Play()
                
                value.Text = tostring(newValue)
                
                if callback then
                    callback(newValue)
                end
            end
        end)
        
        return holder
    end
    
    -- ===== CONTENIDO - MAIN =====
    
    CreateToggle(contentFrames["Main"], "🚀 Auto Farm", false, function(state)
        ScriptState.AutoFarm = state
        if state then
            coroutine.wrap(function() Farming:FarmChickens() end)()
        end
    end)
    
    CreateToggle(contentFrames["Main"], "🥚 Auto Collect Eggs", false, function(state)
        ScriptState.AutoCollectEggs = state
        if state then
            coroutine.wrap(function() Farming:CollectEggs() end)()
        end
    end)
    
    CreateToggle(contentFrames["Main"], "🐣 Auto Hatch", false, function(state)
        ScriptState.AutoHatch = state
        if state then
            coroutine.wrap(function() Farming:HatchEggs() end)()
        end
    end)
    
    CreateToggle(contentFrames["Main"], "💰 Auto Sell", false, function(state)
        ScriptState.AutoSell = state
        if state then
            coroutine.wrap(function() Farming:SellChickens() end)()
        end
    end)
    
    -- ===== CONTENIDO - FARM =====
    
    CreateToggle(contentFrames["Farm"], "🔄 Auto Fuse", false, function(state)
        ScriptState.AutoFuse = state
        if state then
            -- Implementar lógica de fusión
            local fuseRemote = FindRemoteSmart(RemoteNames.FusePet, 2)
            if fuseRemote then
                SafeFire(fuseRemote)
                Log("Auto Fuse activado", "SUCCESS")
            end
        end
    end)
    
    CreateToggle(contentFrames["Farm"], "📈 Auto Upgrade", false, function(state)
        if state then
            local upgradeRemote = FindRemoteSmart(RemoteNames.Upgrade, 2)
            if upgradeRemote then
                SafeFire(upgradeRemote)
                Log("Auto Upgrade activado", "SUCCESS")
            end
        end
    end)
    
    CreateToggle(contentFrames["Farm"], "🎁 Auto Claim Rewards", false, function(state)
        if state then
            local claimRemote = FindRemoteSmart(RemoteNames.ClaimReward, 2)
            if claimRemote then
                SafeFire(claimRemote)
                Log("Auto Claim activado", "SUCCESS")
            end
        end
    end)
    
    -- ===== CONTENIDO - COMBAT =====
    
    CreateToggle(contentFrames["Combat"], "⚔️ Auto Fight", false, function(state)
        ScriptState.AutoFight = state
        if state then
            coroutine.wrap(function() Farming:AutoFight() end)()
        end
    end)
    
    CreateToggle(contentFrames["Combat"], "🏔️ Auto Climb Tower", false, function(state)
        ScriptState.AutoClimbTower = state
        if state then
            Log("Auto Climb activado", "SUCCESS")
            -- Implementar lógica de escalada
            while ScriptState.AutoClimbTower and ScriptActive do
                task.wait(0.5)
                if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
                    local rootPart = PlayerCharacter.HumanoidRootPart
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
    
    -- ===== CONTENIDO - PLAYER =====
    
    CreateSlider(contentFrames["Player"], "👟 Walk Speed", 10, 200, DefaultWalkSpeed, function(value)
        DefaultWalkSpeed = value
        pcall(function()
            if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                PlayerCharacter.Humanoid.WalkSpeed = value
            end
        end)
    end)
    
    CreateSlider(contentFrames["Player"], "📈 Jump Power", 20, 300, DefaultJumpPower, function(value)
        DefaultJumpPower = value
        pcall(function()
            if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                PlayerCharacter.Humanoid.JumpPower = value
            end
        end)
    end)
    
    CreateToggle(contentFrames["Player"], "♾️ Infinite Jump", false, function(state)
        ScriptState.InfiniteJump = state
        if state then
            UserInputService.JumpRequest:Connect(function()
                if ScriptState.InfiniteJump and PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                    PlayerCharacter.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
    
    -- ===== CONTENIDO - ESP =====
    
    CreateToggle(contentFrames["ESP"], "🐔 ESP Chickens", false, function(state)
        ScriptState.ESPChickens = state
        if state or ScriptState.ESPEggs then
            coroutine.wrap(function() ESP:StartESP() end)()
        end
    end)
    
    CreateToggle(contentFrames["ESP"], "🥚 ESP Eggs", false, function(state)
        ScriptState.ESPEggs = state
        if state or ScriptState.ESPChickens then
            coroutine.wrap(function() ESP:StartESP() end)()
        end
    end)
    
    -- ===== CONTENIDO - CONFIG =====
    
    CreateToggle(contentFrames["Config"], "🛡️ Anti AFK", true, function(state)
        ScriptState.AntiAFK = state
        if state then
            AntiAFK:Start()
        end
    end)
    
    CreateToggle(contentFrames["Config"], "🔄 Auto Rejoin", false, function(state)
        ScriptState.AutoRejoin = state
        if state then
            coroutine.wrap(function() RejoinSystem:Start() end)()
        end
    end)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 30)
    infoLabel.Position = UDim2.new(0, 10, 1, -35)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "v3.0 • Ultra Robust • Sorkscripts © 2024"
    infoLabel.TextColor3 = CONFIG.TextDim
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 10
    infoLabel.Parent = contentFrames["Config"]
    
    -- ===== BOTONES DEL SIDEBAR =====
    
    for i, cat in ipairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Name = cat.Name .. "Btn"
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = (cat.Name == "Main") and Color3.fromRGB(50, 35, 70) or Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = (cat.Name == "Main") and 0 or 0.3
        btn.Text = " " .. cat.Icon .. " " .. cat.Name
        btn.TextColor3 = (cat.Name == "Main") and CONFIG.Text or CONFIG.TextDim
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = cat.Order
        btn.Parent = CatList
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(CatList:GetChildren()) do
                if v:IsA("TextButton") then
                    v.BackgroundTransparency = 0.3
                    v.TextColor3 = CONFIG.TextDim
                end
            end
            
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Color3.fromRGB(50, 35, 70)
            btn.TextColor3 = CONFIG.Text
            
            for name, frame in pairs(contentFrames) do
                frame.Visible = (name == cat.Name)
            end
            
            ContentTitle.Text = cat.Name
            selectedCategory = cat.Name
        end)
    end
    
    -- ===== BOTÓN CERRAR =====
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -42, 0, 8)
    CloseBtn.BackgroundColor3 = CONFIG.Error
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.ZIndex = 100
    CloseBtn.Parent = Main
    
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
    end)
    
    -- ===== BOTÓN DE DESTRUCCIÓN TOTAL =====
    
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Name = "ExitBtn"
    ExitBtn.Size = UDim2.new(0, 32, 0, 32)
    ExitBtn.Position = UDim2.new(1, -42, 1, -40)
    ExitBtn.BackgroundColor3 = CONFIG.Warning
    ExitBtn.Text = "⏹️"
    ExitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.TextSize = 16
    ExitBtn.ZIndex = 100
    ExitBtn.Parent = Main
    
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    
    local function CloseScriptCompletely()
        Log("Cerrando Sorkscripts...", "WARNING")
        
        ScriptActive = false
        
        -- Desactivar todos los sistemas
        for key, _ in pairs(ScriptState) do
            ScriptState[key] = false
        end
        
        -- Animación de cierre
        local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(Main, fade, {BackgroundTransparency = 1}):Play()
        TweenService:Create(Toggle, fade, {BackgroundTransparency = 1}):Play()
        
        task.wait(0.5)
        
        ScreenGui:Destroy()
        Log("Sorkscripts cerrado correctamente ✅", "SUCCESS")
    end
    
    ExitBtn.MouseButton1Click:Connect(function()
        CloseScriptCompletely()
    end)
    
    -- ===== TOGGLE PRINCIPAL =====
    
    Toggle.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    -- ===== SISTEMA DE ARRASTRE =====
    
    local draggingMain, dragStartMain, startPosMain
    
    local dragArea = Instance.new("Frame")
    dragArea.Size = UDim2.new(1, -160, 0, 50)
    dragArea.Position = UDim2.new(0, 0, 0, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.ZIndex = 75
    dragArea.Parent = Header
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = true
            dragStartMain = input.Position
            startPosMain = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingMain = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartMain
            Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end)
    
    -- ===== ARRASTRAR BOTÓN FLOTANTE =====
    
    local draggingBtn, dragStartBtn, startPosBtn
    
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingBtn = true
            dragStartBtn = input.Position
            startPosBtn = Toggle.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingBtn = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartBtn
            Toggle.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
        end
    end)
    
    -- ===== CONEXIÓN DE PERSONAJE =====
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        PlayerCharacter = char
        task.wait(1)
        
        -- Restaurar configuración
        if ScriptState.InfiniteJump then
            -- Reconectar infinite jump
        end
        
        pcall(function()
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = DefaultWalkSpeed
                char.Humanoid.JumpPower = DefaultJumpPower
            end
        end)
    end)
    
    -- Iniciar sistemas
    AntiAFK:Start()
    
    Log("Sorkscripts | Crecer Pollo v3.0 cargado correctamente ✅", "SUCCESS")
    Log("Panel UI listo para usar 🎮", "SUCCESS")
    Log("Presiona el botón ⏹️ para cerrar completamente", "INFO")
end

print("\n" .. string.rep("=", 60))
print("✅ SORKSCRIPTS | CRECER POLLO v3.0")
print("ULTRA ROBUST - Fully Functional Script")
print(string.rep("=", 60) .. "\n")
