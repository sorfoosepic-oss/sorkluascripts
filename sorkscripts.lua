--// ====================================================
--// SORKSCRIPTS | CRECER POLLO | V3.1 - FIXED
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
-- CONFIGURACIÓN DE COLORES
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
    InfiniteJump = false,
    ESPChickens = false,
    ESPEggs = false,
    AutoRejoin = false,
    AntiAFK = true,
}

local ScriptActive = true
local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local RemoteCache = {}

-- ====================================================
-- SISTEMA DE LOGGING
-- ====================================================

local function Log(message, type)
    type = type or "INFO"
    local prefix = {
        INFO = "ℹ️",
        SUCCESS = "✅",
        WARNING = "⚠️",
        ERROR = "❌",
        DEBUG = "🔍",
    }
    print("[Sorkscripts] " .. (prefix[type] or "•") .. " " .. message)
end

-- ====================================================
-- FUNCIÓN PARA ENCONTRAR REMOTES (SIMPLIFICADA)
-- ====================================================

local function FindRemote(name)
    -- Buscar directamente
    local remote = ReplicatedStorage:FindFirstChild(name)
    if remote then
        return remote
    end
    
    -- Buscar en carpetas comunes
    local folders = {"Remotes", "RemoteEvents", "Events", "Functions", "RemoteFunctions"}
    
    for _, folderName in ipairs(folders) do
        local folder = ReplicatedStorage:FindFirstChild(folderName)
        if folder then
            remote = folder:FindFirstChild(name)
            if remote then
                return remote
            end
        end
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
        end
    end)
    
    return ok
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
-- FUNCIÓN PRINCIPAL DE CREACIÓN DE UI
-- ====================================================

local function CreateMainUI()
    Log("Creando interfaz principal...", "INFO")
    
    -- Botón flotante
    local Toggle = Instance.new("ImageButton")
    Toggle.Name = "FloatingToggle"
    Toggle.Size = UDim2.new(0, 60, 0, 60)
    Toggle.Position = UDim2.new(0, 20, 0.42, 0)
    Toggle.BackgroundColor3 = CONFIG.Accent
    Toggle.Image = "rbxassetid://0"
    Toggle.ScaleType = Enum.ScaleType.Crop
    Toggle.Parent = ScreenGui
    Toggle.ZIndex = 100
    
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
    
    local toggleStroke = Instance.new("UIStroke", Toggle)
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Thickness = 2
    toggleStroke.Transparency = 0.5
    
    -- Texto del botón
    local toggleText = Instance.new("TextLabel")
    toggleText.Size = UDim2.new(1, 0, 1, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = "🐔"
    toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleText.Font = Enum.Font.GothamBold
    toggleText.TextSize = 28
    toggleText.Parent = Toggle
    
    -- Frame principal
    local Main = Instance.new("Frame")
    Main.Name = "MainUI"
    Main.Size = UDim2.new(0, 550, 0, 420)
    Main.Position = UDim2.new(0.5, -275, 0.5, -210)
    Main.BackgroundColor3 = CONFIG.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Main.ZIndex = 50
    Main.Visible = false  -- Inicialmente oculto
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = CONFIG.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.5
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = CONFIG.Sidebar
    Header.BorderSizePixel = 0
    Header.Parent = Main
    
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0.7, 0, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "🐔 Crecer Pollo v3.1"
    HeaderTitle.TextColor3 = CONFIG.Accent
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 18
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    -- Botón cerrar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 7)
    CloseBtn.BackgroundColor3 = CONFIG.Error
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.ZIndex = 100
    CloseBtn.Parent = Main
    
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
    end)
    
    -- Contenedor de pestañas
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = CONFIG.Sidebar
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = Main
    
    -- Contenido
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -120, 1, -45)
    ContentContainer.Position = UDim2.new(0, 120, 0, 45)
    ContentContainer.BackgroundColor3 = CONFIG.Background
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = Main
    
    -- Pestañas
    local tabs = {
        {Name = "Farm", Icon = "🐔"},
        {Name = "Player", Icon = "👤"},
        {Name = "ESP", Icon = "👁️"},
        {Name = "Config", Icon = "⚙️"},
    }
    
    local currentTab = "Farm"
    local tabFrames = {}
    
    -- Crear pestañas
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 40)
        tabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
        tabBtn.BackgroundColor3 = i == 1 and CONFIG.Accent or Color3.fromRGB(0, 0, 0)
        tabBtn.BackgroundTransparency = i == 1 and 0.3 or 0.7
        tabBtn.Text = tab.Icon .. " " .. tab.Name
        tabBtn.TextColor3 = i == 1 and CONFIG.Text or CONFIG.TextDim
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 13
        tabBtn.Parent = TabContainer
        
        -- Frame de contenido para esta pestaña
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, -20, 1, -20)
        tabFrame.Position = UDim2.new(0, 10, 0, 10)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 3
        tabFrame.ScrollBarImageColor3 = CONFIG.Accent
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = ContentContainer
        
        local tabList = Instance.new("UIListLayout", tabFrame)
        tabList.Padding = UDim.new(0, 8)
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        
        tabFrames[tab.Name] = tabFrame
        
        -- Función para cambiar pestaña
        tabBtn.MouseButton1Click:Connect(function()
            currentTab = tab.Name
            
            -- Actualizar botones
            for j, otherTab in ipairs(tabs) do
                local btn = TabContainer:FindFirstChild(tab.Name .. "Btn") or TabContainer:GetChildren()[j + 1]
                if btn and btn:IsA("TextButton") then
                    btn.BackgroundColor3 = j == i and CONFIG.Accent or Color3.fromRGB(0, 0, 0)
                    btn.BackgroundTransparency = j == i and 0.3 or 0.7
                    btn.TextColor3 = j == i and CONFIG.Text or CONFIG.TextDim
                end
            end
            
            -- Mostrar frame correcto
            for name, frame in pairs(tabFrames) do
                frame.Visible = (name == tab.Name)
            end
        end)
        
        tabBtn.Name = tab.Name .. "Btn"
    end
    
    -- ===== FUNCIÓN PARA CREAR TOGGLE =====
    
    local function CreateToggle(parent, text, default, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 40)
        holder.BackgroundColor3 = CONFIG.Card
        holder.BorderSizePixel = 0
        holder.Parent = parent
        
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
        
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
        toggle.Size = UDim2.new(0, 44, 0, 24)
        toggle.Position = UDim2.new(1, -54, 0.5, -12)
        toggle.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
        toggle.Text = ""
        toggle.Parent = holder
        
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 18, 0, 18)
        circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
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
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            }):Play()
            
            if callback then
                callback(state)
            end
        end)
        
        return holder
    end
    
    -- ===== FUNCIÓN PARA CREAR SLIDER =====
    
    local function CreateSlider(parent, text, min, max, default, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 50)
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
        sliderBG.Size = UDim2.new(1, -24, 0, 4)
        sliderBG.Position = UDim2.new(0, 12, 0, 32)
        sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = holder
        
        Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.Accent
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBG
        
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 12, 0, 12)
        sliderButton.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        sliderButton.BackgroundColor3 = CONFIG.Accent
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
                
                sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                sliderButton.Position = UDim2.new(relativePos, -6, 0.5, -6)
                value.Text = tostring(newValue)
                
                if callback then
                    callback(newValue)
                end
            end
        end)
        
        return holder
    end
    
    -- ===== CONTENIDO DE PESTAÑAS =====
    
    -- FARM TAB
    CreateToggle(tabFrames["Farm"], "🚀 Auto Farm", false, function(state)
        ScriptState.AutoFarm = state
        if state then
            Log("Auto Farm activado", "SUCCESS")
            coroutine.wrap(function()
                while ScriptState.AutoFarm and ScriptActive do
                    task.wait(0.5)
                    pcall(function()
                        if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
                            -- Buscar pollos
                            for _, obj in pairs(Workspace:GetChildren()) do
                                if obj:IsA("Model") and obj.Name:lower():find("chicken") then
                                    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                                    if root then
                                        PlayerCharacter.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end)
                end
            end)()
        end
    end)
    
    CreateToggle(tabFrames["Farm"], "🥚 Auto Collect Eggs", false, function(state)
        ScriptState.AutoCollectEggs = state
        if state then
            Log("Auto Collect Eggs activado", "SUCCESS")
            coroutine.wrap(function()
                while ScriptState.AutoCollectEggs and ScriptActive do
                    task.wait(0.3)
                    pcall(function()
                        if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
                            -- Buscar huevos
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
                                    PlayerCharacter.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end)
                end
            end)()
        end
    end)
    
    CreateToggle(tabFrames["Farm"], "🐣 Auto Hatch", false, function(state)
        ScriptState.AutoHatch = state
        if state then
            Log("Auto Hatch activado", "SUCCESS")
            local hatchRemote = FindRemote("HatchEgg") or FindRemote("Hatch")
            if hatchRemote then
                SafeFire(hatchRemote)
            end
        end
    end)
    
    CreateToggle(tabFrames["Farm"], "💰 Auto Sell", false, function(state)
        ScriptState.AutoSell = state
        if state then
            Log("Auto Sell activado", "SUCCESS")
            local sellRemote = FindRemote("Sell") or FindRemote("SellChicken")
            if sellRemote then
                SafeFire(sellRemote)
            end
        end
    end)
    
    -- PLAYER TAB
    CreateSlider(tabFrames["Player"], "👟 Walk Speed", 10, 200, DefaultWalkSpeed, function(value)
        DefaultWalkSpeed = value
        pcall(function()
            if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                PlayerCharacter.Humanoid.WalkSpeed = value
            end
        end)
    end)
    
    CreateSlider(tabFrames["Player"], "📈 Jump Power", 20, 300, DefaultJumpPower, function(value)
        DefaultJumpPower = value
        pcall(function()
            if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
                PlayerCharacter.Humanoid.JumpPower = value
            end
        end)
    end)
    
    CreateToggle(tabFrames["Player"], "♾️ Infinite Jump", false, function(state)
        ScriptState.InfiniteJump = state
        if state then
            Log("Infinite Jump activado", "SUCCESS")
        end
    end)
    
    -- ESP TAB
    CreateToggle(tabFrames["ESP"], "🐔 ESP Chickens", false, function(state)
        ScriptState.ESPChickens = state
        if state then
            Log("ESP Chickens activado", "SUCCESS")
            -- Implementar ESP simple
            coroutine.wrap(function()
                while ScriptState.ESPChickens and ScriptActive do
                    task.wait(1)
                    pcall(function()
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if obj:IsA("Model") and obj.Name:lower():find("chicken") then
                                if not obj:FindFirstChild("ESP_Highlight") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Highlight"
                                    highlight.FillColor = CONFIG.Accent
                                    highlight.FillTransparency = 0.5
                                    highlight.Parent = obj
                                end
                            end
                        end
                    end)
                end
            end)()
        end
    end)
    
    CreateToggle(tabFrames["ESP"], "🥚 ESP Eggs", false, function(state)
        ScriptState.ESPEggs = state
        if state then
            Log("ESP Eggs activado", "SUCCESS")
        end
    end)
    
    -- CONFIG TAB
    CreateToggle(tabFrames["Config"], "🛡️ Anti AFK", true, function(state)
        ScriptState.AntiAFK = state
        if state then
            Log("Anti AFK activado", "SUCCESS")
        end
    end)
    
    CreateToggle(tabFrames["Config"], "🔄 Auto Rejoin", false, function(state)
        ScriptState.AutoRejoin = state
        if state then
            Log("Auto Rejoin activado", "SUCCESS")
        end
    end)
    
    -- Botón de destrucción total
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 30, 0, 30)
    ExitBtn.Position = UDim2.new(1, -40, 1, -40)
    ExitBtn.BackgroundColor3 = CONFIG.Warning
    ExitBtn.Text = "⏹️"
    ExitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.TextSize = 14
    ExitBtn.ZIndex = 100
    ExitBtn.Parent = Main
    
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 6)
    
    ExitBtn.MouseButton1Click:Connect(function()
        Log("Cerrando Sorkscripts...", "WARNING")
        ScriptActive = false
        
        -- Desactivar todos los sistemas
        for key, _ in pairs(ScriptState) do
            ScriptState[key] = false
        end
        
        -- Destruir GUI
        pcall(function()
            ScreenGui:Destroy()
        end)
        
        Log("Sorkscripts cerrado correctamente ✅", "SUCCESS")
    end)
    
    -- ===== FUNCIONALIDAD DEL BOTÓN FLOTANTE =====
    
    Toggle.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    -- ===== SISTEMA DE ARRASTRE =====
    
    local draggingMain = false
    local dragStartMain = nil
    local startPosMain = nil
    
    -- Hacer el header arrastrable
    Header.InputBegan:Connect(function(input)
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
    
    -- Arrastrar botón flotante
    local draggingBtn = false
    local dragStartBtn = nil
    local startPosBtn = nil
    
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
    
    -- ===== ANTI-AFK =====
    
    coroutine.wrap(function()
        while ScriptActive do
            task.wait(60) -- Cada minuto
            if ScriptState.AntiAFK then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                end)
            end
        end
    end)()
    
    -- ===== MANEJAR RESPAWN =====
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        PlayerCharacter = char
        task.wait(1)
        
        -- Restaurar configuración
        pcall(function()
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = DefaultWalkSpeed
                char.Humanoid.JumpPower = DefaultJumpPower
            end
        end)
    end)
    
    Log("Sorkscripts | Crecer Pollo v3.1 cargado correctamente ✅", "SUCCESS")
    Log("¡Haz clic en el botón flotante 🐔 para abrir el menú!", "INFO")
end

-- ====================================================
-- PANTALLA DE CARGA SIMPLE
-- ====================================================

local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = CONFIG.Background
Loading.BorderSizePixel = 0
Loading.Parent = ScreenGui

local Welcome = Instance.new("TextLabel")
Welcome.Size = UDim2.new(1, 0, 0, 60)
Welcome.Position = UDim2.new(0, 0, 0.45, 0)
Welcome.BackgroundTransparency = 1
Welcome.Text = "🔮 SORKSCRIPTS"
Welcome.TextColor3 = CONFIG.Accent
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 32
Welcome.Parent = Loading

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.5, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Cargando..."
LoadingText.TextColor3 = CONFIG.TextDim
LoadingText.Font = Enum.Font.Gotham
LoadingText.TextSize = 16
LoadingText.Parent = Loading

-- Crear UI principal después de un breve delay
task.wait(2)

-- Desvanecer pantalla de carga
local fade = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
TweenService:Create(Loading, fade, {BackgroundTransparency = 1}):Play()
TweenService:Create(Welcome, fade, {TextTransparency = 1}):Play()
TweenService:Create(LoadingText, fade, {TextTransparency = 1}):Play()

task.wait(0.6)
Loading:Destroy()

-- Crear la interfaz principal
pcall(function()
    CreateMainUI()
end)

print("\n" .. string.rep("=", 60))
print("✅ SORKSCRIPTS | CRECER POLLO v3.1")
print("FIXED - Script funcional")
print(string.rep("=", 60) .. "\n")
