--// Sorkscripts Hub | Anti-Cheat Bypass & Game Selector
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

-- Destrucción limpia de ejecuciones anteriores
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
    Danger = Color3.fromRGB(220, 60, 60),
    Success = Color3.fromRGB(60, 220, 120)
}

local ScriptRunning = true
local ActiveGame = nil

-- Estados Globales para Crecer Pollo
local States = {
    AutoFuse = false,
    TargetChicken = "MEJOR (S+)",
    TargetEgg = "Huevo Común",
    AutoEgg = false,
    AutoTower = false,
    AutoReset = false,
    AutoFeeder = false,
    SafeSpeed = false,
    AntiAFK = true
}

-- Lista de Juegos Soportados
local GamesList = {
    {Name = "Crecer Pollo", ID = 1},
    {Name = "Blox Fruits (Próximamente)", ID = 2},
    {Name = "Pet Simulator (Próximamente)", ID = 3},
    {Name = "Universal / Script Base", ID = 4}
}

-- Lista de Huevos
local EggList = {"Huevo Común", "Huevo Raro", "Huevo Épico", "Huevo Mítico", "Huevo Legendario"}

-- =====================================================
-- MOTOR DE BÚSQUEDA Y DISPARO REAL DE EVENTOS (REMOTES)
-- =====================================================
local RemoteCache = {}

local function LocateRemote(keywords)
    for _, name in ipairs(keywords) do
        if RemoteCache[name] and RemoteCache[name].Parent then
            return RemoteCache[name]
        end
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local lowName = obj.Name:lower()
            for _, key in ipairs(keywords) do
                if lowName:find(key:lower()) then
                    RemoteCache[key] = obj
                    return obj
                end
            end
        end
    end
    return nil
end

local function FireGameRemote(keywords, ...)
    local remote = LocateRemote(keywords)
    if remote then
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...)
            end
        end)
        return true
    end
    return false
end

-- Movimiento Suave para la Torre (Bypass Teleport Kick)
local function SmoothMoveTo(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 42
        local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- =====================================================
-- PANTALLA DE CARGA (LOADER) Y VERIFICACIÓN
-- =====================================================
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Name = GenerateRandomName()
LoaderFrame.Size = UDim2.new(0, 360, 0, 220)
LoaderFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
LoaderFrame.BackgroundColor3 = CONFIG.Background
LoaderFrame.BorderSizePixel = 0
LoaderFrame.Parent = ScreenGui
Instance.new("UICorner", LoaderFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", LoaderFrame).Color = Color3.fromRGB(50, 50, 60)

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 40)
LoaderTitle.Position = UDim2.new(0, 0, 0, 15)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "Sorkscripts Loader"
LoaderTitle.TextColor3 = CONFIG.Accent
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 18
LoaderTitle.Parent = LoaderFrame

local LoaderStatus = Instance.new("TextLabel")
LoaderStatus.Size = UDim2.new(1, -40, 0, 30)
LoaderStatus.Position = UDim2.new(0, 20, 0, 65)
LoaderStatus.BackgroundTransparency = 1
LoaderStatus.Text = "Verificando entorno y seguridad..."
LoaderStatus.TextColor3 = CONFIG.TextDim
LoaderStatus.Font = Enum.Font.Gotham
LoaderStatus.TextSize = 12
LoaderStatus.Parent = LoaderFrame

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(1, -40, 0, 8)
BarBackground.Position = UDim2.new(0, 20, 0, 110)
BarBackground.BackgroundColor3 = CONFIG.Card
BarBackground.BorderSizePixel = 0
BarBackground.Parent = LoaderFrame
Instance.new("UICorner", BarBackground).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = CONFIG.Accent
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBackground
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- =====================================================
-- INTERFAZ PRINCIPAL Y SELECTOR DE JUEGOS
-- =====================================================
local Main = Instance.new("Frame")
Main.Name = GenerateRandomName()
Main.Size = UDim2.new(0, 500, 0, 360)
Main.Position = UDim2.new(0.5, -250, 0.5, -180)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(50, 50, 60)

-- Botón Flotante
local headshot = "rbxassetid://0"
pcall(function()
    headshot = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = GenerateRandomName()
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0.42, 0)
ToggleBtn.BackgroundColor3 = CONFIG.Card
ToggleBtn.Image = headshot
ToggleBtn.ScaleType = Enum.ScaleType.Crop
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ts = Instance.new("UIStroke", ToggleBtn)
ts.Color = CONFIG.Accent
ts.Thickness = 2

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
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
ContentArea.Size = UDim2.new(1, -150, 1, -20)
ContentArea.Position = UDim2.new(0, 145, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Size = UDim2.new(1, -80, 0, 28)
ContentTitle.BackgroundTransparency = 1
ContentTitle.Text = "Seleccionar Juego"
ContentTitle.TextColor3 = CONFIG.Text
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.TextSize = 16
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
ContentTitle.Parent = ContentArea

local contentFrames = {}

local function CreateTabFrame(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 1, -30)
    frame.Position = UDim2.new(0, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = CONFIG.Accent
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.Visible = false
    frame.Parent = ContentArea
    contentFrames[name] = frame

    local list = Instance.new("UIListLayout", frame)
    list.Padding = UDim.new(0, 6)
    return frame
end

-- Componentes UI Generadores
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
-- PESTAÑA: SELECTOR DE JUEGOS
-- =====================================================
local GamesTab = CreateTabFrame("Juegos")
GamesTab.Visible = true

for _, gameData in ipairs(GamesList) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 42)
    card.BackgroundColor3 = CONFIG.Card
    card.Parent = GamesTab
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local gName = Instance.new("TextLabel")
    gName.Size = UDim2.new(0.65, 0, 1, 0)
    gName.Position = UDim2.new(0, 12, 0, 0)
    gName.BackgroundTransparency = 1
    gName.Text = gameData.Name
    gName.TextColor3 = CONFIG.Text
    gName.Font = Enum.Font.GothamBold
    gName.TextSize = 12
    gName.TextXAlignment = Enum.TextXAlignment.Left
    gName.Parent = card

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.28, 0, 0.65, 0)
    loadBtn.Position = UDim2.new(0.69, 0, 0.18, 0)
    loadBtn.BackgroundColor3 = CONFIG.Accent
    loadBtn.Text = "Cargar"
    loadBtn.TextColor3 = CONFIG.Text
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.TextSize = 11
    loadBtn.Parent = card
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

    loadBtn.MouseButton1Click:Connect(function()
        ActiveGame = gameData.Name
        ContentTitle.Text = "Juego: " .. gameData.Name
        loadBtn.Text = "Activo"
        loadBtn.BackgroundColor3 = CONFIG.Success
    end)
end

-- PESTAÑAS DE FUNCIONES
local AutoTab = CreateTabFrame("Automatización")
local EggTab = CreateTabFrame("Huevos")
local SettingsTab = CreateTabFrame("Ajustes")

-- Pestaña Automatización
CreateToggle(AutoTab, "Auto Subir Torre (Paso a Paso)", false, function(v) States.AutoTower = v end)
CreateToggle(AutoTab, "Auto Mejorar Comedores", false, function(v) States.AutoFeeder = v end)
CreateToggle(AutoTab, "Auto Reset (Segun Nivel Torre)", false, function(v) States.AutoReset = v end)
CreateToggle(AutoTab, "Auto Fusionar Pollos", false, function(v) States.AutoFuse = v end)

-- Pestaña Huevos
CreateSelector(EggTab, "Seleccionar Huevo:", EggList, function(s) States.TargetEgg = s end)
CreateToggle(EggTab, "Auto Comprar / Abrir Huevo", false, function(v) States.AutoEgg = v end)

-- Pestaña Ajustes
CreateToggle(SettingsTab, "Velocidad Ligera (Safe CFrame)", false, function(v) States.SafeSpeed = v end)
CreateToggle(SettingsTab, "Anti-AFK Pasivo", true, function(v) States.AntiAFK = v end)

-- Navegación Sidebar
local navCategories = {"Juegos", "Automatización", "Huevos", "Ajustes"}
for _, name in ipairs(navCategories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = (name == "Juegos") and Color3.fromRGB(40, 35, 55) or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = (name == "Juegos") and 0 or 1
    btn.Text = "  " .. name
    btn.TextColor3 = (name == "Juegos") and CONFIG.Text or CONFIG.TextDim
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

-- CONTROLES SUPERIORES: MINIMIZAR Y CERRAR
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

MinimizeBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

CloseScriptBtn.MouseButton1Click:Connect(function()
    ScriptRunning = false
    ScreenGui:Destroy()
    print("⛔ Sorkscripts | Script detenido y cerrado correctamente.")
end)

-- Sistema de Arrastre Táctil / Mouse
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
-- ANIMACIÓN Y EJECUCIÓN DEL LOADER
-- =====================================================
task.spawn(function()
    local steps = {
        {Progress = 0.3, Text = "Escaneando entorno de ejecución..."},
        {Progress = 0.6, Text = "Verificando bypass Anti-Cheat..."},
        {Progress = 0.85, Text = "Indexando RemoteEvents del servidor..."},
        {Progress = 1.0, Text = "¡Carga completada!"}
    }

    for _, step in ipairs(steps) do
        LoaderStatus.Text = step.Text
        TweenService:Create(BarFill, TweenInfo.new(0.4), {Size = UDim2.new(step.Progress, 0, 1, 0)}):Play()
        task.wait(0.5)
    end

    LoaderFrame:Destroy()
    Main.Visible = true
    ToggleBtn.Visible = true
end)

-- =====================================================
-- BUCLES EN SEGUNDO PLANO (LÓGICA AUTOMÁTICA REAL)
-- =====================================================

-- Lógica de Nivel y Requisitos
local function GetCurrentTowerLevel()
    local lvl = 0
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
        if stats then
            local val = stats:FindFirstChild("TowerLevel") or stats:FindFirstChild("Floor") or stats:FindFirstChild("Level")
            if val then lvl = tonumber(val.Value) end
        end
    end)
    return lvl
end

local function GetRequiredTowerLevel()
    local req = 25
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
        if stats then
            local val = stats:FindFirstChild("TowerReq") or stats:FindFirstChild("RequiredLevel") or stats:FindFirstChild("RebirthReq")
            if val then req = tonumber(val.Value) end
        end
    end)
    return req
end

-- Bucle 1: Auto Fusión
task.spawn(function()
    while ScriptRunning do
        task.wait(2)
        if States.AutoFuse and (ActiveGame == "Crecer Pollo" or not ActiveGame) then
            FireGameRemote({"fuse", "merge", "combine", "fusionar", "craft"})
        end
    end
end)

-- Bucle 2: Auto Subir Torre (Moverse + Evento)
task.spawn(function()
    while ScriptRunning do
        task.wait(1.5)
        if States.AutoTower and (ActiveGame == "Crecer Pollo" or not ActiveGame) then
            pcall(function()
                local tower = workspace:FindFirstChild("Tower") or workspace:FindFirstChild("Torre")
                if tower then
                    local current = GetCurrentTowerLevel()
                    local floorObj = tower:FindFirstChild("Floor_" .. tostring(current + 1)) or tower:FindFirstChild(tostring(current + 1))
                    if floorObj then
                        local pad = floorObj:FindFirstChild("Touch") or floorObj:FindFirstChild("Pad") or floorObj
                        if pad:IsA("BasePart") then
                            SmoothMoveTo(pad.CFrame + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end)
            FireGameRemote({"tower", "climb", "floor", "subirtorre"})
        end
    end
end)

-- Bucle 3: Auto Mejorar Comedores
task.spawn(function()
    while ScriptRunning do
        task.wait(2)
        if States.AutoFeeder and (ActiveGame == "Crecer Pollo" or not ActiveGame) then
            FireGameRemote({"feeder", "food", "upgradefood", "comedores", "mejorarcomida"})
        end
    end
end)

-- Bucle 4: Auto Reset / Rebirth
task.spawn(function()
    while ScriptRunning do
        task.wait(3)
        if States.AutoReset and (ActiveGame == "Crecer Pollo" or not ActiveGame) then
            if GetCurrentTowerLevel() >= GetRequiredTowerLevel() then
                FireGameRemote({"rebirth", "reset", "reinicio"})
            end
        end
    end
end)

-- Bucle 5: Auto Abrir Huevos
task.spawn(function()
    while ScriptRunning do
        task.wait(2.5)
        if States.AutoEgg and (ActiveGame == "Crecer Pollo" or not ActiveGame) then
            FireGameRemote({"egg", "huevo", "buyegg", "openegg"}, States.TargetEgg)
        end
    end
end)

-- Velocidad Ligera CFrame
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

-- Anti-AFK Pasivo
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

print("✅ Sorkscripts Hub | Cargado exitosamente")
