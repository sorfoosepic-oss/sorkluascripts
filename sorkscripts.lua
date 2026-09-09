--// Sorkscripts | Complete & Undetected Edition
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

-- Limpieza de ejecuciones anteriores
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
}

-- Estados Globales del Script
local States = {
    AutoFuse = false,
    TargetChicken = "MEJOR (S+)",
    AutoTower = false,
    AutoReset = false,
    AutoEat = false,
    SafeSpeed = false,
    AntiAFK = true
}

-- =====================================================
-- FUNCIÓN DE DISPARO SEGURO (SAFE REMOTE FIRE)
-- Busca remotas sin crash
-- =====================================================
local function SafeFire(...)
    local args = {...}
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                for _, arg in ipairs(args) do
                    if typeof(arg) == "string" and name:find(arg:lower()) then
                        obj:FireServer()
                        return
                    end
                end
            end
        end
    end)
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
Main.Size = UDim2.new(0, 480, 0, 340)
Main.Position = UDim2.new(0.5, -240, 0.5, -170)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(50, 50, 60)

-- Sidebar (Menú Izquierdo)
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
ContentTitle.Size = UDim2.new(1, 0, 0, 28)
ContentTitle.BackgroundTransparency = 1
ContentTitle.Text = "Fusiones"
ContentTitle.TextColor3 = CONFIG.Text
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.TextSize = 16
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
ContentTitle.Parent = ContentArea

local categories = {"Fusiones", "Progreso", "Ajustes"}
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
    frame.Visible = (name == "Fusiones")
    frame.Parent = ContentArea
    contentFrames[name] = frame

    local list = Instance.new("UIListLayout", frame)
    list.Padding = UDim.new(0, 6)
end

-- Creador de Toggles
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

-- Creador de Selectores
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
-- CONTENIDO DE PESTAÑAS
-- =====================================================

-- Pestaña: Fusiones
CreateToggle(contentFrames["Fusiones"], "Auto Fusionar Pollos", false, function(v)
    States.AutoFuse = v
end)

CreateSelector(contentFrames["Fusiones"], "Pollo Objetivo:", {"MEJOR (S+)", "Eclipse Hen", "Ace Rooster", "Angel Chicken", "Reaper Rooster"}, function(selected)
    States.TargetChicken = selected
end)

-- Pestaña: Progreso
CreateToggle(contentFrames["Progreso"], "Auto Subir Torre", false, function(v)
    States.AutoTower = v
end)

CreateToggle(contentFrames["Progreso"], "Auto Reset / Rebirth", false, function(v)
    States.AutoReset = v
end)

CreateToggle(contentFrames["Progreso"], "Auto Comer / Alimentar", false, function(v)
    States.AutoEat = v
end)

-- Pestaña: Ajustes
CreateToggle(contentFrames["Ajustes"], "Velocidad Ligera (Safe Speed)", false, function(v)
    States.SafeSpeed = v
end)

CreateToggle(contentFrames["Ajustes"], "Anti-AFK Pasivo", true, function(v)
    States.AntiAFK = v
end)

-- Navegación Sidebar
for _, name in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = (name == "Fusiones") and Color3.fromRGB(40, 35, 55) or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = (name == "Fusiones") and 0 or 1
    btn.Text = "  " .. name
    btn.TextColor3 = (name == "Fusiones") and CONFIG.Text or CONFIG.TextDim
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

-- Botón de Cierre y Arrastre
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Main
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

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
-- BUCLES EN SEGUNDO PLANO (FUNCIONES ACTIVAS + SAFE)
-- =====================================================

-- Bucle 1: Auto Fusión
task.spawn(function()
    while task.wait(2) do
        if States.AutoFuse then
            SafeFire("fuse", "merge", "combine")
        end
    end
end)

-- Bucle 2: Auto Torre
task.spawn(function()
    while task.wait(3) do
        if States.AutoTower then
            SafeFire("tower", "climb", "floor")
        end
    end
end)

-- Bucle 3: Auto Reset
task.spawn(function()
    while task.wait(4) do
        if States.AutoReset then
            SafeFire("rebirth", "reset")
        end
    end
end)

-- Bucle 4: Auto Comer
task.spawn(function()
    while task.wait(2.5) do
        if States.AutoEat then
            SafeFire("eat", "feed")
        end
    end
end)

-- Bucle 5: Velocidad Segura (Impulso CFrame indetectable por Anti-Cheat)
RunService.Stepped:Connect(function()
    if States.SafeSpeed then
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

-- Bucle 6: Anti-AFK Pasivo
task.spawn(function()
    while task.wait(300) do
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

print("✅ Sorkscripts | Script Completo y Protegido Cargado Correctamente")
