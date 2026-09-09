-- ========================================
-- SORKSCRIPTS v4.0 - CRECER POLLO
-- ========================================
-- Script rediseñado desde 0 con mejores prácticas
-- Basado en código abierto de calidad de GitHub

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variables de control
local ScriptActive = true
local FunctionsEnabled = {}

-- Configuración
local Colors = {
	BG = Color3.fromRGB(18, 18, 22),
	Sidebar = Color3.fromRGB(24, 24, 28),
	Card = Color3.fromRGB(30, 30, 35),
	Text = Color3.fromRGB(235, 235, 240),
	TextDark = Color3.fromRGB(140, 140, 150),
	Accent = Color3.fromRGB(145, 70, 255),
	AccentLight = Color3.fromRGB(170, 100, 255),
	Green = Color3.fromRGB(52, 168, 83),
	Red = Color3.fromRGB(244, 67, 54),
	Yellow = Color3.fromRGB(255, 193, 7),
}

-- ==========================
-- SISTEMA DE LOGGING
-- ==========================

local function print_log(message, status)
	status = status or "INFO"
	local time = os.date("%H:%M:%S")
	local symbols = {
		INFO = "ℹ️",
		SUCCESS = "✅",
		ERROR = "❌",
		WARNING = "⚠️",
	}
	print("[" .. time .. "] " .. (symbols[status] or "•") .. " " .. message)
end

-- ==========================
-- LIMPIAR GUI ANTERIOR
-- ==========================

pcall(function()
	if PlayerGui:FindFirstChild("SorkscriptsMainUI") then
		PlayerGui.SorkscriptsMainUI:Destroy()
	end
end)

-- ==========================
-- CREAR GUI PRINCIPAL
-- ==========================

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "SorkscriptsMainUI"
MainGui.ResetOnSpawn = false
MainGui.Parent = PlayerGui

print_log("Creando interfaz...", "INFO")

-- ===== PANTALLA DE CARGA =====
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "Loading"
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Colors.BG
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = MainGui

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1, 0, 0, 100)
LoadTitle.Position = UDim2.new(0, 0, 0.35, 0)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "🔮 SORKSCRIPTS"
LoadTitle.TextColor3 = Colors.Accent
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextSize = 48
LoadTitle.Parent = LoadingFrame

local LoadSubtitle = Instance.new("TextLabel")
LoadSubtitle.Size = UDim2.new(1, 0, 0, 40)
LoadSubtitle.Position = UDim2.new(0, 0, 0.45, 0)
LoadSubtitle.BackgroundTransparency = 1
LoadSubtitle.Text = "Crecer Pollo v4.0"
LoadSubtitle.TextColor3 = Colors.TextDark
LoadSubtitle.Font = Enum.Font.Gotham
LoadSubtitle.TextSize = 20
LoadSubtitle.Parent = LoadingFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0.2, 0, 0, 4)
ProgressBar.Position = UDim2.new(0.4, 0, 0.52, 0)
ProgressBar.BackgroundColor3 = Colors.Accent
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = LoadingFrame

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(0.2, 0, 0, 4)
ProgressBG.Position = UDim2.new(0.4, 0, 0.52, 0)
ProgressBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ProgressBG.BorderSizePixel = 0
ProgressBG.ZIndex = 1
ProgressBG.Parent = LoadingFrame

-- Animar barra
local barTween = TweenService:Create(
	ProgressBar,
	TweenInfo.new(2.5, Enum.EasingStyle.Quad),
	{Size = UDim2.new(0.2, 0, 0, 4)}
)
barTween:Play()

-- ==========================
-- CREAR PANEL PRINCIPAL
-- ==========================

local function CreateMainPanel()
	-- Destruir pantalla de carga
	LoadingFrame:Destroy()
	
	-- Panel principal
	local Panel = Instance.new("Frame")
	Panel.Name = "MainPanel"
	Panel.Size = UDim2.new(0, 550, 0, 400)
	Panel.Position = UDim2.new(0.5, -275, 0.5, -200)
	Panel.BackgroundColor3 = Colors.BG
	Panel.BorderSizePixel = 0
	Panel.Parent = MainGui
	
	local Corner = Instance.new("UICorner", Panel)
	Corner.CornerRadius = UDim.new(0, 12)
	
	-- Stroke
	local Stroke = Instance.new("UIStroke", Panel)
	Stroke.Color = Color3.fromRGB(60, 60, 80)
	Stroke.Thickness = 1
	
	-- Header
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = Colors.Sidebar
	Header.BorderSizePixel = 0
	Header.Parent = Panel
	
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
	
	local HeaderText = Instance.new("TextLabel")
	HeaderText.Size = UDim2.new(0.8, 0, 1, 0)
	HeaderText.Position = UDim2.new(0, 10, 0, 0)
	HeaderText.BackgroundTransparency = 1
	HeaderText.Text = "🐔 Crecer Pollo"
	HeaderText.TextColor3 = Colors.Accent
	HeaderText.Font = Enum.Font.GothamBold
	HeaderText.TextSize = 18
	HeaderText.TextXAlignment = Enum.TextXAlignment.Left
	HeaderText.Parent = Header
	
	-- Botones cerrar
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -40, 0, 10)
	CloseBtn.BackgroundColor3 = Colors.Red
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Colors.Text
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 16
	CloseBtn.Parent = Header
	
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
	
	CloseBtn.MouseButton1Click:Connect(function()
		Panel.Visible = false
	end)
	
	local ExitBtn = Instance.new("TextButton")
	ExitBtn.Size = UDim2.new(0, 30, 0, 30)
	ExitBtn.Position = UDim2.new(1, -75, 0, 10)
	ExitBtn.BackgroundColor3 = Colors.Yellow
	ExitBtn.Text = "⏹"
	ExitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	ExitBtn.Font = Enum.Font.GothamBold
	ExitBtn.TextSize = 16
	ExitBtn.Parent = Header
	
	Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 6)
	
	ExitBtn.MouseButton1Click:Connect(function()
		ScriptActive = false
		for key, _ in pairs(FunctionsEnabled) do
			FunctionsEnabled[key] = false
		end
		Panel:Destroy()
		print_log("Script cerrado completamente", "SUCCESS")
	end)
	
	-- Content area
	local Content = Instance.new("ScrollingFrame")
	Content.Size = UDim2.new(1, -20, 1, -70)
	Content.Position = UDim2.new(0, 10, 0, 60)
	Content.BackgroundTransparency = 1
	Content.ScrollBarThickness = 4
	Content.ScrollBarImageColor3 = Colors.Accent
	Content.Parent = Panel
	
	local ListLayout = Instance.new("UIListLayout", Content)
	ListLayout.Padding = UDim.new(0, 10)
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	Content:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Content.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
	end)
	
	-- ==========================
	-- CREAR TOGGLE
	-- ==========================
	
	local function CreateToggle(title, defaultState, callback)
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, -10, 0, 40)
		Container.BackgroundColor3 = Colors.Card
		Container.BorderSizePixel = 0
		Container.Parent = Content
		
		Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.7, 0, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = title
		Label.TextColor3 = Colors.Text
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container
		
		local Toggle = Instance.new("TextButton")
		Toggle.Size = UDim2.new(0, 40, 0, 20)
		Toggle.Position = UDim2.new(1, -50, 0.5, -10)
		Toggle.BackgroundColor3 = defaultState and Colors.Accent or Colors.ToggleOff
		Toggle.Text = ""
		Toggle.Parent = Container
		
		Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
		
		local Circle = Instance.new("Frame")
		Circle.Size = UDim2.new(0, 14, 0, 14)
		Circle.Position = defaultState and UDim2.new(1, -19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Circle.Parent = Toggle
		
		Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
		
		local state = defaultState
		
		Toggle.MouseButton1Click:Connect(function()
			state = not state
			
			TweenService:Create(Toggle, TweenInfo.new(0.2), {
				BackgroundColor3 = state and Colors.Accent or Colors.ToggleOff
			}):Play()
			
			TweenService:Create(Circle, TweenInfo.new(0.2), {
				Position = state and UDim2.new(1, -19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			}):Play()
			
			if callback then callback(state) end
		end)
		
		return Container
	end
	
	-- ==========================
	-- CREAR SLIDER
	-- ==========================
	
	local function CreateSlider(title, minVal, maxVal, defaultVal, callback)
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, -10, 0, 50)
		Container.BackgroundColor3 = Colors.Card
		Container.BorderSizePixel = 0
		Container.Parent = Content
		
		Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.6, 0, 0, 20)
		Label.Position = UDim2.new(0, 10, 0, 5)
		Label.BackgroundTransparency = 1
		Label.Text = title
		Label.TextColor3 = Colors.Text
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 12
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container
		
		local Value = Instance.new("TextLabel")
		Value.Size = UDim2.new(0.3, 0, 0, 20)
		Value.Position = UDim2.new(0.65, 0, 0, 5)
		Value.BackgroundTransparency = 1
		Value.Text = tostring(defaultVal)
		Value.TextColor3 = Colors.Accent
		Value.Font = Enum.Font.GothamBold
		Value.TextSize = 12
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.Parent = Container
		
		local SliderBG = Instance.new("Frame")
		SliderBG.Size = UDim2.new(1, -20, 0, 4)
		SliderBG.Position = UDim2.new(0, 10, 0, 30)
		SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		SliderBG.BorderSizePixel = 0
		SliderBG.Parent = Container
		
		Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
		
		local ratio = (defaultVal - minVal) / (maxVal - minVal)
		
		local SliderFill = Instance.new("Frame")
		SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
		SliderFill.BackgroundColor3 = Colors.Accent
		SliderFill.BorderSizePixel = 0
		SliderFill.Parent = SliderBG
		
		Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
		
		local Handle = Instance.new("TextButton")
		Handle.Size = UDim2.new(0, 10, 0, 10)
		Handle.Position = UDim2.new(ratio, -5, 0.5, -5)
		Handle.BackgroundColor3 = Colors.Accent
		Handle.Text = ""
		Handle.Parent = SliderBG
		
		Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)
		
		local dragging = false
		
		Handle.MouseButton1Down:Connect(function()
			dragging = true
		end)
		
		UserInputService.InputEnded:Connect(function()
			dragging = false
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mouse = UserInputService:GetMouseLocation()
				local sliderPos = SliderBG.AbsolutePosition.X
				local sliderSize = SliderBG.AbsoluteSize.X
				local newRatio = math.clamp((mouse.X - sliderPos) / sliderSize, 0, 1)
				local newValue = math.round(minVal + (newRatio * (maxVal - minVal)))
				
				TweenService:Create(SliderFill, TweenInfo.new(0.05), {
					Size = UDim2.new(newRatio, 0, 1, 0)
				}):Play()
				
				TweenService:Create(Handle, TweenInfo.new(0.05), {
					Position = UDim2.new(newRatio, -5, 0.5, -5)
				}):Play()
				
				Value.Text = tostring(newValue)
				
				if callback then callback(newValue) end
			end
		end)
		
		return Container
	end
	
	-- ==========================
	-- AGREGAR FUNCIONES A UI
	-- ==========================
	
	CreateToggle("🚀 Auto Farm", false, function(state)
		FunctionsEnabled.AutoFarm = state
		if state then
			print_log("Auto Farm ACTIVADO", "SUCCESS")
			coroutine.wrap(function()
				while FunctionsEnabled.AutoFarm and ScriptActive do
					task.wait(0.5)
					-- Aquí va la lógica del farm
				end
			end)()
		end
	end)
	
	CreateToggle("🥚 Auto Collect", false, function(state)
		FunctionsEnabled.AutoCollect = state
		if state then
			print_log("Auto Collect ACTIVADO", "SUCCESS")
		end
	end)
	
	CreateToggle("🐣 Auto Hatch", false, function(state)
		FunctionsEnabled.AutoHatch = state
		if state then
			print_log("Auto Hatch ACTIVADO", "SUCCESS")
		end
	end)
	
	CreateToggle("💰 Auto Sell", false, function(state)
		FunctionsEnabled.AutoSell = state
		if state then
			print_log("Auto Sell ACTIVADO", "SUCCESS")
		end
	end)
	
	CreateSlider("👟 Walk Speed", 10, 100, 16, function(value)
		pcall(function()
			if Humanoid then
				Humanoid.WalkSpeed = value
				print_log("Walk Speed: " .. value, "INFO")
			end
		end)
	end)
	
	CreateSlider("📈 Jump Power", 20, 150, 50, function(value)
		pcall(function()
			if Humanoid then
				Humanoid.JumpPower = value
				print_log("Jump Power: " .. value, "INFO")
			end
		end)
	end)
	
	CreateToggle("🛡️ Anti AFK", true, function(state)
		FunctionsEnabled.AntiAFK = state
		if state then
			print_log("Anti AFK ACTIVADO", "SUCCESS")
			coroutine.wrap(function()
				while FunctionsEnabled.AntiAFK and ScriptActive do
					task.wait(120)
					if Humanoid then
						Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)()
		end
	end)
	
	local InfoLabel = Instance.new("TextLabel")
	InfoLabel.Size = UDim2.new(1, -10, 0, 20)
	InfoLabel.BackgroundTransparency = 1
	InfoLabel.Text = "Sorkscripts v4.0 ✨"
	InfoLabel.TextColor3 = Colors.TextDark
	InfoLabel.Font = Enum.Font.Gotham
	InfoLabel.TextSize = 10
	InfoLabel.Parent = Content
	
	-- Hacer el panel arrastrable
	local dragging = false
	local dragStart = nil
	local panelStart = nil
	
	Header.MouseButton1Down:Connect(function()
		dragging = true
		dragStart = UserInputService:GetMouseLocation()
		panelStart = Panel.Position
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation() - dragStart
			Panel.Position = UDim2.new(
				panelStart.X.Scale,
				panelStart.X.Offset + delta.X,
				panelStart.Y.Scale,
				panelStart.Y.Offset + delta.Y
			)
		end
	end)
	
	print_log("Interfaz creada correctamente", "SUCCESS")
end

-- Esperar a que termine la carga
task.wait(3)
CreateMainPanel()

-- ==========================
-- MANEJO DE CAMBIO DE PERSONAJE
-- ==========================

Player.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
	print_log("Nuevo personaje detectado", "INFO")
end)

-- ==========================
-- VERIFICACIÓN FINAL
-- ==========================

print_log("Sorkscripts v4.0 completamente cargado", "SUCCESS")
print_log("Panel abierto - Usa los botones para controlar", "INFO")
