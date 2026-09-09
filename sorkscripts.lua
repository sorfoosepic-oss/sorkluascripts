--// Sorkscripts | Autonomous Farm & Clean Unload Edition
--// Compatible con Executores Móviles (Delta, Fluxus, Hydrogen)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- PROTECCIÓN Y OCULTAMIENTO (BYPASS ANTI-KICK)
-- =====================================================
local function GenerateRandomName()
    local str = ""
    for i = 1, math.random(10, 16) do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end

local TargetParent = gethui and gethui() or game:GetService("CoreGui")

-- Destrucción limpia si se vuelve a ejecutar
for _, v in ipairs(TargetParent:GetChildren()) do
    if v:IsA("ScreenGui") and v:FindFirstChild("SorkMarker") then
        v:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GenerateRandomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

local Marker = Instance.new("IntValue")
Marker.Name = "SorkMarker"
Marker.Parent = ScreenGui

-- Configuración Estética
local CONFIG = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(24, 24, 28),
    Card = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(145, 70, 255),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(140, 140, 150),
    ToggleOn = Color3.fromRGB(145, 70, 255),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    Danger = Color3.fromRGB(220, 60, 60)
}

-- Estados Globales del Script
local ScriptRunning = true
local States = {
    AutoFuse = false,
    TargetEgg = "Huevo Común",
    AutoEgg = false,
    AutoTower = false,
    AutoReset = false,
    AutoFeeder = false,
    SafeSpeed = false,
    AntiAFK = true
}

-- Lista de Huevos Disponibles
local EggList = {"Huevo Común", "Huevo Raro", "Huevo Épico", "Huevo Mítico", "Huevo Legendario"}

-- Helper para Invocar Remotas Dinámicas
local function TryFireRemote(names, ...)
    local args = {...}
    pcall(function()
        for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                local objName = desc.Name:lower()
                for _, n in ipairs(names) do
                    if objName:find(n:lower()) then
                        if desc:IsA("RemoteEvent") then
                            desc:FireServer(unpack(args))
                        elseif desc:IsA("RemoteFunction") then
                            desc:InvokeServer(unpack(args))
                        end
                        return
                    end
                end
            end
        end
    end)
end

-- Movimiento Suave (Bypass Teleport Kick)
local function SmoothMoveTo(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 40 -- Velocidad segura de interpolación
        local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- =====================================================
-- INTERFAZ GRÁFICA PRINCIPAL
-- =====================================================
local headshot = "rbxassetid://0"
pcall(function()
    headshot = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)

-- Botón Flotante
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = GenerateRandomName()
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0.42, 0)
ToggleBtn.BackgroundColor3 = CONFIG.Card
ToggleBtn.Image = headshot
ToggleBtn.ScaleType = Enum.ScaleType.Crop
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local ts = Instance.new("UIStroke", ToggleBtn)
ts.Color = CONFIG.Accent
ts.Thickness = 2

-- Frame Principal
local Main = Instance.new("Frame")
Main.Name = GenerateRandomName()
Main.Size = UDim2.new(0, 480, 0, 350)
Main.Position = UDim2.new(0.5, -240, 0.5, -175)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(50, 50, 60)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = CONFIG.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 45)
Logo.BackgroundTransparency = 1
Logo.Text = "Sorkscripts"
Logo.TextColor3 = CONFIG.Accent
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 15
Logo.Parent = Sidebar

local CatList = Instance.new("Frame")
CatList.Size = UDim2.new(1, -12, 1, -50)
CatList.Position = UDim2.new(0, 6, 0, 45)
CatList.BackgroundTransparency = 1
CatList.Parent = Sidebar

local catLayout = Instance.new("UIListLayout", CatList)
catLayout.Padding = UDim.new(0, 5)

-- Área Contenido
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -20)
ContentArea.Position = UDim2.new(0, 135, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Size = UDim2.new(1, -80, 0, 28)
ContentTitle.BackgroundTransparency = 1
ContentTitle.Text = "Automatización"
ContentTitle.TextColor3 = CONFIG.Text
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.TextSize = 16
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
ContentTitle.Parent = ContentArea

local categories = {"Automatización", "Huevos", "Ajustes"}
local contentFrames = {}

for _, name in ipairs(categories) do
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 1, -30)
    frame.Position = UDim2.new(0, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = CONFIG.Accent
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.Visible = (name == "Automatización")
    frame.Parent = ContentArea
    contentFrames[name] = frame

    local list = Instance.new("UIListLayout", frame)
    list.Padding = UDim.new(0, 6)
end

-- Componentes UI (Toggle / Selector / Button)
local function CreateToggle(parent, text, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 34)
    holder.BackgroundColor3 = CONFIG.Card
    holder.BorderSizePixel = 0
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -48, 0.5, -10)
    toggle.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
    toggle.Text = ""
    toggle.Parent = holder
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = default
    if callback then task.spawn(callback, state) end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
        if callback then task.spawn(callback, state) end
    end)
end

local function CreateSelector(parent, title, options, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 38)
    holder.BackgroundColor3 = CONFIG.Card
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = CONFIG.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0.7, 0)
    btn.Position = UDim2.new(0.52, 0, 0.15, 0)
    btn.BackgroundColor3 = CONFIG.Sidebar
    btn.Text = options[1]
    btn.TextColor3 = CONFIG.Accent
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = holder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local index = 1
    btn.MouseButton1Click:Connect(function()
        index = (index % #options) + 1
        btn.Text = options[index]
        if callback then callback(options[index]) end
    end)
end

-- =====================================================
-- OPCIONES DE LAS PESTAÑAS
-- =====================================================

-- Pestaña 1: Automatización
CreateToggle(contentFrames["Automatización"], "Auto Subir Torre (Paso a Paso)", false, function(v)
    States.AutoTower = v
end)

CreateToggle(contentFrames["Automatización"], "Auto Mejorar Comedores", false, function(v)
    States.AutoFeeder = v
end)

CreateToggle(contentFrames["Automatización"], "Auto Reset (Segun Nivel Torre)", false, function(v)
    States.AutoReset = v
end)

CreateToggle(contentFrames["Automatización"], "Auto Fusionar Pollos", false, function(v)
    States.AutoFuse = v
end)

-- Pestaña 2: Huevos
CreateSelector(contentFrames["Huevos"], "Seleccionar Huevo:", EggList, function(selected)
    States.TargetEgg = selected
end)

CreateToggle(contentFrames["Huevos"], "Auto Comprar / Abrir Huevo", false, function(v)
    States.AutoEgg = v
end)

-- Pestaña 3: Ajustes
CreateToggle(contentFrames["Ajustes"], "Velocidad Ligera (Safe CFrame)", false, function(v)
    States.SafeSpeed = v
end)

CreateToggle(contentFrames["Ajustes"], "Anti-AFK Pasivo", true, function(v)
    States.AntiAFK = v
end)

-- Navegación Sidebar
for _, name in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = (name == "Automatización") and Color3.fromRGB(40, 35, 55) or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = (name == "Automatización") and 0 or 1
    btn.Text = "  " .. name
    btn.TextColor3 = (name == "Automatización") and CONFIG.Text or CONFIG.TextDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = CatList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(CatList:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundTransparency = 1
                v.TextColor3 = CONFIG.TextDim
            end
        end
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
        btn.TextColor3 = CONFIG.Text

        for cName, frame in pairs(contentFrames) do
            frame.Visible = (cName == name)
        end
        ContentTitle.Text = name
    end)
end

-- CONTROLES SUPERIORES: MINIMIZAR Y CERRAR COMPLETAMENTE
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -58, 0, 8)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = CONFIG.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = Main
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local CloseScriptBtn = Instance.new("TextButton")
CloseScriptBtn.Size = UDim2.new(0, 24, 0, 24)
CloseScriptBtn.Position = UDim2.new(1, -30, 0, 8)
CloseScriptBtn.BackgroundColor3 = CONFIG.Danger
CloseScriptBtn.Text = "✕"
CloseScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseScriptBtn.Font = Enum.Font.GothamBold
CloseScriptBtn.TextSize = 12
CloseScriptBtn.Parent = Main
Instance.new("UICorner", CloseScriptBtn).CornerRadius = UDim.new(0, 5)

-- Minimizar
MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Apagar y Destruir el Script Por Completo
CloseScriptBtn.MouseButton1Click:Connect(function()
    ScriptRunning = false
    ScreenGui:Destroy()
    print("⛔ Sorkscripts | Script apagado y removido de la memoria.")
end)

-- Arrastre Táctil / Mouse
local function EnableDrag(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

EnableDrag(Main)
EnableDrag(ToggleBtn)

-- =====================================================
-- LÓGICA AUTÓNOMA (FARM + TORRE + COMEDORES + RESET)
-- =====================================================

-- Obtenedor de Requisito de Torre
local function GetRequiredTowerLevel()
    local reqLevel = 25
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
        if stats then
            local req = stats:FindFirstChild("TowerReq") or stats:FindFirstChild("RequiredLevel") or stats:FindFirstChild("RebirthReq")
            if req then
                reqLevel = tonumber(req.Value)
            end
        end
    end)
    return reqLevel
end

-- Obtenedor de Nivel de Torre Actual
local function GetCurrentTowerLevel()
    local currentLevel = 0
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
        if stats then
            local lvl = stats:FindFirstChild("TowerLevel") or stats:FindFirstChild("Floor") or stats:FindFirstChild("Level")
            if lvl then
                currentLevel = tonumber(lvl.Value)
            end
        end
    end)
    return currentLevel
end

-- Bucle 1: Auto Subir Torre por Marcadores y Remotas Seguras
task.spawn(function()
    while ScriptRunning do
        task.wait(1.5)
        if States.AutoTower then
            pcall(function()
                local towerFolder = workspace:FindFirstChild("Tower") or workspace:FindFirstChild("Torre") or workspace:FindFirstChild("TowerFloors")
                if towerFolder then
                    local current = GetCurrentTowerLevel()
                    local nextFloor = towerFolder:FindFirstChild("Floor_" .. tostring(current + 1)) or towerFolder:FindFirstChild(tostring(current + 1))
                    if nextFloor then
                        local pad = nextFloor:FindFirstChild("Touch") or nextFloor:FindFirstChild("Pad") or nextFloor:FindFirstChild("PrimaryPart") or nextFloor
                        if pad:IsA("BasePart") then
                            SmoothMoveTo(pad.CFrame + Vector3.new(0, 3, 0))
                        end
                    end
                end
                TryFireRemote({"tower", "climb", "floor", "subirtorre"})
            end)
        end
    end
end)

-- Bucle 2: Auto Mejorar Comedores
task.spawn(function()
    while ScriptRunning do
        task.wait(2)
        if States.AutoFeeder then
            TryFireRemote({"feeder", "food", "upgradefood", "upgradefeeder", "comedores", "mejorarcomida"})
        end
    end
end)

-- Bucle 3: Auto Reset (Evalúa si se alcanzó el nivel objetivo requerido)
task.spawn(function()
    while ScriptRunning do
        task.wait(3)
        if States.AutoReset then
            local current = GetCurrentTowerLevel()
            local required = GetRequiredTowerLevel()
            if current >= required then
                TryFireRemote({"rebirth", "reset", "reinicio"})
            end
        end
    end
end)

-- Bucle 4: Auto Comprar/Abrir Huevo Seleccionado
task.spawn(function()
    while ScriptRunning do
        task.wait(2.5)
        if States.AutoEgg then
            TryFireRemote({"egg", "huevo", "buyegg", "openegg"}, States.TargetEgg)
        end
    end
end)

-- Bucle 5: Auto Fusionar Pollos
task.spawn(function()
    while ScriptRunning do
        task.wait(3)
        if States.AutoFuse then
            TryFireRemote({"fuse", "merge", "combine", "fusionar"})
        end
    end
end)

-- Impulso de Velocidad CFrame Segura
RunService.Stepped:Connect(function()
    if ScriptRunning and States.SafeSpeed then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                if char.Humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * 0.4)
                end
            end
        end)
    end
end)

-- Anti-AFK Pasivo de Cámara
task.spawn(function()
    while ScriptRunning do
        task.wait(300)
        if States.AntiAFK then
            pcall(function()
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
                end
            end)
        end
    end
end)

print("✅ Sorkscripts | Autonomous Farm Loaded")
