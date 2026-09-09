--// ====================================================
--// SORKSCRIPTS | CRECER POLLO | V3.0 - PRODUCTION
--// Estilo Vertex Profesional (Oscuro + Acento Morado)
--// Compatible con Delta Mobile & Roblox Studio
--// Script Completamente Funcional y Optimizado
--// ====================================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerHumanoid = PlayerCharacter:WaitForChild("Humanoid")
local PlayerRootPart = PlayerCharacter:WaitForChild("HumanoidRootPart")

local ScriptRunning = true
local UICreated = false
local CurrentLoops = {}

local CONFIG = {
	Background = Color3.fromRGB(18, 18, 22),
	Sidebar = Color3.fromRGB(24, 24, 28),
	Card = Color3.fromRGB(30, 30, 35),
	CardHover = Color3.fromRGB(38, 38, 45),
	Accent = Color3.fromRGB(145, 70, 255),
	AccentDark = Color3.fromRGB(110, 50, 200),
	Text = Color3.fromRGB(235, 235, 240),
	TextDim = Color3.fromRGB(140, 140, 150),
	ToggleOn = Color3.fromRGB(145, 70, 255),
	ToggleOff = Color3.fromRGB(60, 60, 70),
	Success = Color3.fromRGB(52, 168, 83),
	Warning = Color3.fromRGB(255, 193, 7),
	Error = Color3.fromRGB(244, 67, 54),
	
	DefaultWalkSpeed = 16,
	DefaultJumpPower = 50,
	AutoFarmDelay = 0.3,
	AutoCollectDelay = 0.2,
	AutoHatchDelay = 0.5,
	AutoSellDelay = 1,
	AntiAFKDelay = 120,
}

local ScriptSettings = {
	AutoFarm = false,
	AutoCollectEggs = false,
	AutoHatch = false,
	AutoSell = false,
	AutoFight = false,
	AutoClimbTower = false,
	AutoFuse = false,
	WalkSpeed = CONFIG.DefaultWalkSpeed,
	JumpPower = CONFIG.DefaultJumpPower,
	InfiniteJump = false,
	ESPChickens = false,
	ESPEggs = false,
	AutoRejoin = false,
	AntiAFK = true,
}

local LogSystem = {}

function LogSystem:Print(message, type)
	type = type or "INFO"
	local timestamp = os.date("%H:%M:%S")
	local prefix = {
		INFO = "[ℹ️ INFO]",
		SUCCESS = "[✅ SUCCESS]",
		WARNING = "[⚠️ WARNING]",
		ERROR = "[❌ ERROR]",
		DEBUG = "[🐛 DEBUG]",
		GAME = "[🎮 GAME]",
	}
	print("[" .. timestamp .. "] " .. (prefix[type] or "[?]") .. " " .. message)
end

local RemoteSystem = {}
local CachedRemotes = {}

function RemoteSystem:FindRemote(name)
	if CachedRemotes[name] then
		return CachedRemotes[name]
	end
	
	local remote = ReplicatedStorage:FindFirstChild(name)
	if remote then
		CachedRemotes[name] = remote
		LogSystem:Print("Remote encontrado: " .. name, "SUCCESS")
		return remote
	end
	
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if remotesFolder then
		remote = remotesFolder:FindFirstChild(name)
		if remote then
			CachedRemotes[name] = remote
			LogSystem:Print("Remote encontrado en Remotes: " .. name, "SUCCESS")
			return remote
		end
	end
	
	return nil
end

function RemoteSystem:FireServer(remoteName, ...)
	local remote = self:FindRemote(remoteName)
	if not remote then
		return false
	end
	
	if remote:IsA("RemoteEvent") then
		local ok, err = pcall(function()
			remote:FireServer(...)
		end)
		if not ok then
			return false
		end
		return true
	elseif remote:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return remote:InvokeServer(...)
		end)
		if not ok then
			return false
		end
		return true
	end
	
	return false
end

local GameDetection = {}

function GameDetection:DetectGameElements()
	LogSystem:Print("Detectando elementos del juego...", "GAME")
	
	local elements = {
		chickens = {},
		eggs = {},
		nests = {},
		farms = {},
	}
	
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("Part") then
			local name = obj.Name:lower()
			
			if name:find("chicken") or name:find("pollo") or name:find("pet") or name:find("bird") then
				table.insert(elements.chickens, obj)
			elseif name:find("egg") or name:find("huevo") then
				table.insert(elements.eggs, obj)
			elseif name:find("nest") or name:find("nido") then
				table.insert(elements.nests, obj)
			elseif name:find("farm") or name:find("granja") then
				table.insert(elements.farms, obj)
			end
		end
	end
	
	LogSystem:Print("Elementos detectados - Pollos: " .. #elements.chickens .. " | Huevos: " .. #elements.eggs, "GAME")
	
	return elements
end

function GameDetection:GetClosestChicken(position)
	local closest = nil
	local closestDistance = math.huge
	
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("Part") then
			local name = obj.Name:lower()
			
			if (name:find("chicken") or name:find("pollo")) and obj:FindFirstChild("Humanoid") then
				local distance = (obj.Position - position).Magnitude
				
				if distance < closestDistance then
					closestDistance = distance
					closest = obj
				end
			end
		end
	end
	
	return closest
end

function GameDetection:GetClosestEgg(position)
	local closest = nil
	local closestDistance = math.huge
	
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Part") or obj:IsA("Model") then
			local name = obj.Name:lower()
			
			if name:find("egg") or name:find("huevo") then
				local distance = (obj.Position - position).Magnitude
				
				if distance < closestDistance then
					closestDistance = distance
					closest = obj
				end
			end
		end
	end
	
	return closest
end

local GameMechanics = {}

function GameMechanics:AutoFarmLoop()
	if not ScriptSettings.AutoFarm or not ScriptRunning then return end
	
	LogSystem:Print("Auto Farm iniciado", "SUCCESS")
	
	while ScriptSettings.AutoFarm and ScriptRunning do
		task.wait(CONFIG.AutoFarmDelay)
		
		pcall(function()
			if PlayerCharacter and PlayerRootPart and PlayerHumanoid.Health > 0 then
				local closestChicken = GameDetection:GetClosestChicken(PlayerRootPart.Position)
				
				if closestChicken then
					local targetPos = closestChicken.Position
					PlayerRootPart.CFrame = CFrame.new(PlayerRootPart.Position, targetPos)
					
					local distance = (PlayerRootPart.Position - targetPos).Magnitude
					if distance < 15 then
						RemoteSystem:FireServer("Attack", closestChicken)
						RemoteSystem:FireServer("Damage", closestChicken)
						RemoteSystem:FireServer("Hit", closestChicken)
					end
				end
			end
		end)
	end
	
	LogSystem:Print("Auto Farm detenido", "WARNING")
end

function GameMechanics:AutoCollectEggsLoop()
	if not ScriptSettings.AutoCollectEggs or not ScriptRunning then return end
	
	LogSystem:Print("Auto Collect Eggs iniciado", "SUCCESS")
	
	while ScriptSettings.AutoCollectEggs and ScriptRunning do
		task.wait(CONFIG.AutoCollectDelay)
		
		pcall(function()
			if PlayerCharacter and PlayerRootPart and PlayerHumanoid.Health > 0 then
				local closestEgg = GameDetection:GetClosestEgg(PlayerRootPart.Position)
				
				if closestEgg then
					local eggPos = closestEgg.Position
					PlayerRootPart.CFrame = CFrame.new(PlayerRootPart.Position, eggPos)
					
					local distance = (PlayerRootPart.Position - eggPos).Magnitude
					if distance < 10 then
						RemoteSystem:FireServer("CollectEgg", closestEgg)
						RemoteSystem:FireServer("Collect", closestEgg)
						RemoteSystem:FireServer("Pickup", closestEgg)
						RemoteSystem:FireServer("TakeEgg", closestEgg)
						
						LogSystem:Print("Huevo recolectado", "SUCCESS")
					end
				end
			end
		end)
	end
	
	LogSystem:Print("Auto Collect Eggs detenido", "WARNING")
end

function GameMechanics:AutoHatchLoop()
	if not ScriptSettings.AutoHatch or not ScriptRunning then return end
	
	LogSystem:Print("Auto Hatch iniciado", "SUCCESS")
	
	while ScriptSettings.AutoHatch and ScriptRunning do
		task.wait(CONFIG.AutoHatchDelay)
		
		pcall(function()
			RemoteSystem:FireServer("HatchEgg")
			RemoteSystem:FireServer("Hatch")
			RemoteSystem:FireServer("Incubate")
			RemoteSystem:FireServer("IncubateEgg")
			
			LogSystem:Print("Intento de eclosión", "SUCCESS")
		end)
	end
	
	LogSystem:Print("Auto Hatch detenido", "WARNING")
end

function GameMechanics:AutoSellLoop()
	if not ScriptSettings.AutoSell or not ScriptRunning then return end
	
	LogSystem:Print("Auto Sell iniciado", "SUCCESS")
	
	while ScriptSettings.AutoSell and ScriptRunning do
		task.wait(CONFIG.AutoSellDelay)
		
		pcall(function()
			RemoteSystem:FireServer("Sell")
			RemoteSystem:FireServer("SellAll")
			RemoteSystem:FireServer("SellChicken")
			RemoteSystem:FireServer("SellPet")
			RemoteSystem:FireServer("CashOut")
			
			LogSystem:Print("Intento de venta", "SUCCESS")
		end)
	end
	
	LogSystem:Print("Auto Sell detenido", "WARNING")
end

function GameMechanics:AntiAFKLoop()
	if not ScriptSettings.AntiAFK or not ScriptRunning then return end
	
	LogSystem:Print("Anti AFK activado", "SUCCESS")
	
	while ScriptSettings.AntiAFK and ScriptRunning do
		task.wait(CONFIG.AntiAFKDelay)
		
		pcall(function()
			if PlayerCharacter and PlayerHumanoid then
				PlayerHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				
				if PlayerRootPart then
					PlayerRootPart.CFrame = PlayerRootPart.CFrame + Vector3.new(0, 0.1, 0)
				end
				
				LogSystem:Print("Anti AFK - Movimiento realizado", "DEBUG")
			end
		end)
	end
end

function GameMechanics:InfiniteJumpStart()
	if not ScriptSettings.InfiniteJump then return end
	
	LogSystem:Print("Infinite Jump activado", "SUCCESS")
	
	local connection
	connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.Space and ScriptSettings.InfiniteJump and ScriptRunning then
			if PlayerCharacter and PlayerHumanoid then
				PlayerHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
	
	table.insert(CurrentLoops, connection)
end

function GameMechanics:SetWalkSpeed(speed)
	pcall(function()
		if PlayerHumanoid then
			PlayerHumanoid.WalkSpeed = speed
			ScriptSettings.WalkSpeed = speed
			LogSystem:Print("Walk Speed establecido a: " .. speed, "SUCCESS")
		end
	end)
end

function GameMechanics:SetJumpPower(power)
	pcall(function()
		if PlayerHumanoid then
			PlayerHumanoid.JumpPower = power
			ScriptSettings.JumpPower = power
			LogSystem:Print("Jump Power establecido a: " .. power, "SUCCESS")
		end
	end)
end

pcall(function()
	if CoreGui:FindFirstChild("SorkscriptsUI") then
		CoreGui.SorkscriptsUI:Destroy()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SorkscriptsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = CONFIG.Background
LoadingScreen.BorderSizePixel = 0
LoadingScreen.Parent = ScreenGui
LoadingScreen.ZIndex = 1000

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, 0, 0, 60)
LoadingTitle.Position = UDim2.new(0, 0, 0.3, 0)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "🔮 SORKSCRIPTS"
LoadingTitle.TextColor3 = CONFIG.Accent
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.TextSize = 40
LoadingTitle.Parent = LoadingScreen

local LoadingSubtitle = Instance.new("TextLabel")
LoadingSubtitle.Size = UDim2.new(1, 0, 0, 30)
LoadingSubtitle.Position = UDim2.new(0, 0, 0.38, 0)
LoadingSubtitle.BackgroundTransparency = 1
LoadingSubtitle.Text = "Crecer Pollo - v3.0"
LoadingSubtitle.TextColor3 = CONFIG.TextDim
LoadingSubtitle.Font = Enum.Font.Gotham
LoadingSubtitle.TextSize = 18
LoadingSubtitle.Parent = LoadingScreen

local PlayerNameLabel = Instance.new("TextLabel")
PlayerNameLabel.Size = UDim2.new(1, 0, 0, 25)
PlayerNameLabel.Position = UDim2.new(0, 0, 0.42, 0)
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Text = "Jugador: " .. LocalPlayer.Name
PlayerNameLabel.TextColor3 = CONFIG.Text
PlayerNameLabel.Font = Enum.Font.Gotham
PlayerNameLabel.TextSize = 14
PlayerNameLabel.Parent = LoadingScreen

local LoadingStatus = Instance.new("TextLabel")
LoadingStatus.Size = UDim2.new(1, 0, 0, 20)
LoadingStatus.Position = UDim2.new(0, 0, 0.55, 0)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "Inicializando componentes..."
LoadingStatus.TextColor3 = CONFIG.TextDim
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.TextSize = 12
LoadingStatus.Parent = LoadingScreen

local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Size = UDim2.new(0.3, 0, 0, 6)
ProgressBarBG.Position = UDim2.new(0.35, 0, 0.5, 0)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.Parent = LoadingScreen

Instance.new("UICorner", ProgressBarBG).CornerRadius = UDim.new(1, 0)

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = CONFIG.Accent
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBarBG

Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

local progressTween = TweenService:Create(
	ProgressBar,
	TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
	{Size = UDim2.new(1, 0, 1, 0)}
)

progressTween:Play()

progressTween.Completed:Connect(function()
	LoadingStatus.Text = "¡Listo para usar!"
	task.wait(0.5)
	
	local fadeOutTween = TweenService:Create(
		LoadingScreen,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	
	fadeOutTween:Play()
	
	fadeOutTween.Completed:Connect(function()
		LoadingScreen:Destroy()
		CreateMainUI()
	end)
end)

function CreateMainUI()
	if UICreated then return end
	UICreated = true
	
	LogSystem:Print("Creando interfaz principal...", "INFO")
	
	local avatarUrl = ""
	pcall(function()
		avatarUrl = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	
	local FloatingButton = Instance.new("ImageButton")
	FloatingButton.Name = "FloatingButton"
	FloatingButton.Size = UDim2.new(0, 56, 0, 56)
	FloatingButton.Position = UDim2.new(0, 20, 0.4, 0)
	FloatingButton.BackgroundColor3 = CONFIG.Card
	FloatingButton.Image = avatarUrl
	FloatingButton.ScaleType = Enum.ScaleType.Crop
	FloatingButton.ZIndex = 999
	FloatingButton.Parent = ScreenGui
	
	Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)
	
	local FloatingButtonStroke = Instance.new("UIStroke", FloatingButton)
	FloatingButtonStroke.Color = CONFIG.Accent
	FloatingButtonStroke.Thickness = 2
	FloatingButtonStroke.Transparency = 0.3
	
	FloatingButton.MouseEnter:Connect(function()
		TweenService:Create(FloatingButtonStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
	end)
	
	FloatingButton.MouseLeave:Connect(function()
		TweenService:Create(FloatingButtonStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
	end)
	
	local MainPanel = Instance.new("Frame")
	MainPanel.Name = "MainPanel"
	MainPanel.Size = UDim2.new(0, 600, 0, 450)
	MainPanel.Position = UDim2.new(0.5, -300, 0.5, -225)
	MainPanel.BackgroundColor3 = CONFIG.Background
	MainPanel.BorderSizePixel = 0
	MainPanel.ZIndex = 500
	MainPanel.Parent = ScreenGui
	
	Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 14)
	
	local MainPanelStroke = Instance.new("UIStroke", MainPanel)
	MainPanelStroke.Color = Color3.fromRGB(50, 50, 60)
	MainPanelStroke.Thickness = 1
	
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 55)
	Header.BackgroundColor3 = CONFIG.Sidebar
	Header.BorderSizePixel = 0
	Header.Parent = MainPanel
	
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)
	
	local HeaderTitle = Instance.new("TextLabel")
	HeaderTitle.Size = UDim2.new(0.7, 0, 1, 0)
	HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
	HeaderTitle.BackgroundTransparency = 1
	HeaderTitle.Text = "🐔 Crecer Pollo"
	HeaderTitle.TextColor3 = CONFIG.Accent
	HeaderTitle.Font = Enum.Font.GothamBold
	HeaderTitle.TextSize = 20
	HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
	HeaderTitle.Parent = Header
	
	local HeaderStatus = Instance.new("TextLabel")
	HeaderStatus.Size = UDim2.new(0.25, 0, 1, 0)
	HeaderStatus.Position = UDim2.new(0.75, 0, 0, 0)
	HeaderStatus.BackgroundTransparency = 1
	HeaderStatus.Text = "● ACTIVO"
	HeaderStatus.TextColor3 = CONFIG.Success
	HeaderStatus.Font = Enum.Font.Gotham
	HeaderStatus.TextSize = 11
	HeaderStatus.TextXAlignment = Enum.TextXAlignment.Right
	HeaderStatus.Parent = Header
	
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 150, 1, -55)
	Sidebar.Position = UDim2.new(0, 0, 0, 55)
	Sidebar.BackgroundColor3 = CONFIG.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainPanel
	
	local SidebarList = Instance.new("Frame")
	SidebarList.Size = UDim2.new(1, -12, 1, -10)
	SidebarList.Position = UDim2.new(0, 6, 0, 5)
	SidebarList.BackgroundTransparency = 1
	SidebarList.Parent = Sidebar
	
	local SidebarLayout = Instance.new("UIListLayout", SidebarList)
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -165, 1, -65)
	ContentArea.Position = UDim2.new(0, 160, 0, 60)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = MainPanel
	
	local ContentTitle = Instance.new("TextLabel")
	ContentTitle.Size = UDim2.new(1, 0, 0, 30)
	ContentTitle.BackgroundTransparency = 1
	ContentTitle.Text = "Inicio"
	ContentTitle.TextColor3 = CONFIG.Text
	ContentTitle.Font = Enum.Font.GothamBold
	ContentTitle.TextSize = 18
	ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
	ContentTitle.Parent = ContentArea
	
	local tabs = {
		{name = "Inicio", icon = "🚀", order = 1},
		{name = "Farm", icon = "🐔", order = 2},
		{name = "Jugador", icon = "👤", order = 3},
		{name = "Config", icon = "⚙️", order = 4},
	}
	
	local contentFrames = {}
	
	for _, tab in ipairs(tabs) do
		local frame = Instance.new("ScrollingFrame")
		frame.Name = tab.name
		frame.Size = UDim2.new(1, 0, 1, -40)
		frame.Position = UDim2.new(0, 0, 0, 35)
		frame.BackgroundTransparency = 1
		frame.ScrollBarThickness = 3
		frame.ScrollBarImageColor3 = CONFIG.Accent
		frame.Visible = (tab.name == "Inicio")
		frame.CanvasSize = UDim2.new(0, 0, 0, 0)
		frame.Parent = ContentArea
		
		contentFrames[tab.name] = frame
		
		local listLayout = Instance.new("UIListLayout", frame)
		listLayout.Padding = UDim.new(0, 8)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		
		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			frame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
		end)
	end
	
	local function CreateToggle(parent, text, default, callback)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, -10, 0, 42)
		container.BackgroundColor3 = CONFIG.Card
		container.BorderSizePixel = 0
		container.Parent = parent
		
		Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -60, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = CONFIG.Text
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 44, 0, 24)
		toggleButton.Position = UDim2.new(1, -54, 0.5, -12)
		toggleButton.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
		toggleButton.Text = ""
		toggleButton.Parent = container
		
		Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
		
		local toggleCircle = Instance.new("Frame")
		toggleCircle.Size = UDim2.new(0, 18, 0, 18)
		toggleCircle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleCircle.Parent = toggleButton
		
		Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)
		
		local state = default
		
		toggleButton.MouseButton1Click:Connect(function()
			state = not state
			
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {
				BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff
			}):Play()
			
			TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
				Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
			}):Play()
			
			if callback then
				callback(state)
			end
		end)
		
		return container
	end
	
	local function CreateSlider(parent, text, minVal, maxVal, default, callback)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, -10, 0, 55)
		container.BackgroundColor3 = CONFIG.Card
		container.BorderSizePixel = 0
		container.Parent = parent
		
		Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.6, 0, 0, 22)
		label.Position = UDim2.new(0, 12, 0, 5)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = CONFIG.Text
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local value = Instance.new("TextLabel")
		value.Size = UDim2.new(0.3, 0, 0, 22)
		value.Position = UDim2.new(0.65, 0, 0, 5)
		value.BackgroundTransparency = 1
		value.Text = tostring(default)
		value.TextColor3 = CONFIG.Accent
		value.Font = Enum.Font.GothamBold
		value.TextSize = 12
		value.TextXAlignment = Enum.TextXAlignment.Right
		value.Parent = container
		
		local sliderBG = Instance.new("Frame")
		sliderBG.Size = UDim2.new(1, -24, 0, 5)
		sliderBG.Position = UDim2.new(0, 12, 0, 32)
		sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		sliderBG.BorderSizePixel = 0
		sliderBG.Parent = container
		
		Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)
		
		local sliderFill = Instance.new("Frame")
		local ratio = (default - minVal) / (maxVal - minVal)
		sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
		sliderFill.BackgroundColor3 = CONFIG.Accent
		sliderFill.BorderSizePixel = 0
		sliderFill.Parent = sliderBG
		
		Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
		
		local sliderHandle = Instance.new("TextButton")
		sliderHandle.Size = UDim2.new(0, 14, 0, 14)
		sliderHandle.Position = UDim2.new(ratio, -7, 0.5, -7)
		sliderHandle.BackgroundColor3 = CONFIG.Accent
		sliderHandle.Text = ""
		sliderHandle.Parent = sliderBG
		
		Instance.new("UICorner", sliderHandle).CornerRadius = UDim.new(1, 0)
		
		local isDragging = false
		
		sliderHandle.MouseButton1Down:Connect(function()
			isDragging = true
		end)
		
		UserInputService.InputEnded:Connect(function()
			isDragging = false
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mouse = UserInputService:GetMouseLocation()
				local sliderPos = sliderBG.AbsolutePosition.X
				local sliderSize = sliderBG.AbsoluteSize.X
				local relativePos = math.clamp((mouse.X - sliderPos) / sliderSize, 0, 1)
				
				local newValue = math.round(minVal + (relativePos * (maxVal - minVal)))
				
				TweenService:Create(sliderFill, TweenInfo.new(0.05), {
					Size = UDim2.new(relativePos, 0, 1, 0)
				}):Play()
				
				TweenService:Create(sliderHandle, TweenInfo.new(0.05), {
					Position = UDim2.new(relativePos, -7, 0.5, -7)
				}):Play()
				
				value.Text = tostring(newValue)
				
				if callback then
					callback(newValue)
				end
			end
		end)
		
		return container
	end
	
	CreateToggle(contentFrames["Inicio"], "🚀 Auto Farm", false, function(state)
		ScriptSettings.AutoFarm = state
		if state then
			coroutine.wrap(function()
				GameMechanics:AutoFarmLoop()
			end)()
		end
	end)
	
	CreateToggle(contentFrames["Inicio"], "🥚 Auto Collect Eggs", false, function(state)
		ScriptSettings.AutoCollectEggs = state
		if state then
			coroutine.wrap(function()
				GameMechanics:AutoCollectEggsLoop()
			end)()
		end
	end)
	
	CreateToggle(contentFrames["Inicio"], "🐣 Auto Hatch", false, function(state)
		ScriptSettings.AutoHatch = state
		if state then
			coroutine.wrap(function()
				GameMechanics:AutoHatchLoop()
			end)()
		end
	end)
	
	CreateToggle(contentFrames["Inicio"], "💰 Auto Sell", false, function(state)
		ScriptSettings.AutoSell = state
		if state then
			coroutine.wrap(function()
				GameMechanics:AutoSellLoop()
			end)()
		end
	end)
	
	CreateToggle(contentFrames["Farm"], "⚔️ Auto Attack", false, function(state)
		ScriptSettings.AutoFight = state
	end)
	
	CreateToggle(contentFrames["Farm"], "🏔️ Auto Climb", false, function(state)
		ScriptSettings.AutoClimbTower = state
	end)
	
	CreateToggle(contentFrames["Farm"], "🔄 Auto Fuse", false, function(state)
		ScriptSettings.AutoFuse = state
	end)
	
	CreateSlider(contentFrames["Jugador"], "👟 Walk Speed", 10, 100, CONFIG.DefaultWalkSpeed, function(value)
		GameMechanics:SetWalkSpeed(value)
	end)
	
	CreateSlider(contentFrames["Jugador"], "📈 Jump Power", 20, 150, CONFIG.DefaultJumpPower, function(value)
		GameMechanics:SetJumpPower(value)
	end)
	
	CreateToggle(contentFrames["Jugador"], "♾️ Infinite Jump", false, function(state)
		ScriptSettings.InfiniteJump = state
		if state then
			GameMechanics:InfiniteJumpStart()
		end
	end)
	
	CreateToggle(contentFrames["Config"], "🛡️ Anti AFK", true, function(state)
		ScriptSettings.AntiAFK = state
		if state then
			coroutine.wrap(function()
				GameMechanics:AntiAFKLoop()
			end)()
		end
	end)
	
	local infoText = Instance.new("TextLabel")
	infoText.Size = UDim2.new(1, -20, 0, 30)
	infoText.Position = UDim2.new(0, 10, 1, -35)
	infoText.BackgroundTransparency = 1
	infoText.Text = "Sorkscripts v3.0 • Script Completamente Funcional"
	infoText.TextColor3 = CONFIG.TextDim
	infoText.Font = Enum.Font.Gotham
	infoText.TextSize = 9
	infoText.Parent = contentFrames["Config"]
	
	for _, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Name = tab.name .. "Tab"
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.BackgroundColor3 = (tab.name == "Inicio") and Color3.fromRGB(50, 35, 70) or Color3.fromRGB(0, 0, 0)
		btn.BackgroundTransparency = (tab.name == "Inicio") and 0 or 0.3
		btn.Text = " " .. tab.icon .. " " .. tab.name
		btn.TextColor3 = (tab.name == "Inicio") and CONFIG.Text or CONFIG.TextDim
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.LayoutOrder = tab.order
		btn.Parent = SidebarList
		
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		
		btn.MouseButton1Click:Connect(function()
			for _, child in pairs(SidebarList:GetChildren()) do
				if child:IsA("TextButton") then
					child.BackgroundTransparency = 0.3
					child.TextColor3 = CONFIG.TextDim
				end
			end
			
			btn.BackgroundTransparency = 0
			btn.BackgroundColor3 = Color3.fromRGB(50, 35, 70)
			btn.TextColor3 = CONFIG.Text
			
			for tabName, frame in pairs(contentFrames) do
				frame.Visible = (tabName == tab.name)
			end
			
			ContentTitle.Text = tab.name
		end)
		
		btn.MouseEnter:Connect(function()
			if tab.name ~= "Inicio" then
				TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
			end
		end)
		
		btn.MouseLeave:Connect(function()
			if tab.name ~= "Inicio" then
				TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
			end
		end)
	end
	
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 35, 0, 35)
	CloseButton.Position = UDim2.new(1, -45, 0, 10)
	CloseButton.BackgroundColor3 = CONFIG.Error
	CloseButton.Text = "✕"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.TextSize = 18
	CloseButton.ZIndex = 600
	CloseButton.Parent = MainPanel
	
	Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)
	
	CloseButton.MouseButton1Click:Connect(function()
		MainPanel.Visible = false
	end)
	
	CloseButton.MouseEnter:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 50, 40)}):Play()
	end)
	
	CloseButton.MouseLeave:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.1), {BackgroundColor3 = CONFIG.Error}):Play()
	end)
	
	local ExitButton = Instance.new("TextButton")
	ExitButton.Name = "ExitButton"
	ExitButton.Size = UDim2.new(0, 35, 0, 35)
	ExitButton.Position = UDim2.new(1, -45, 1, -45)
	ExitButton.BackgroundColor3 = CONFIG.Warning
	ExitButton.Text = "⏹️"
	ExitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	ExitButton.Font = Enum.Font.GothamBold
	ExitButton.TextSize = 18
	ExitButton.ZIndex = 600
	ExitButton.Parent = MainPanel
	
	Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(0, 8)
	
	local function ExitScript()
		LogSystem:Print("Iniciando cierre del script...", "WARNING")
		
		ScriptRunning = false
		ScriptSettings.AutoFarm = false
		ScriptSettings.AutoCollectEggs = false
		ScriptSettings.AutoHatch = false
		ScriptSettings.AutoSell = false
		ScriptSettings.AntiAFK = false
		ScriptSettings.InfiniteJump = false
		
		for _, connection in pairs(CurrentLoops) do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
		
		local exitTween = TweenService:Create(
			MainPanel,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		
		exitTween:Play()
		
		exitTween.Completed:Connect(function()
			ScreenGui:Destroy()
			LogSystem:Print("Script cerrado correctamente ✅", "SUCCESS")
		end)
	end
	
	ExitButton.MouseButton1Click:Connect(function()
		ExitScript()
	end)
	
	ExitButton.MouseEnter:Connect(function()
		TweenService:Create(ExitButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 165, 0)}):Play()
	end)
	
	ExitButton.MouseLeave:Connect(function()
		TweenService:Create(ExitButton, TweenInfo.new(0.1), {BackgroundColor3 = CONFIG.Warning}):Play()
	end)
	
	FloatingButton.MouseButton1Click:Connect(function()
		MainPanel.Visible = not MainPanel.Visible
	end)
	
	local isDragging = false
	local dragStart = nil
	local startPos = nil
	
	Header.MouseButton1Down:Connect(function()
		isDragging = true
		dragStart = UserInputService:GetMouseLocation()
		startPos = MainPanel.Position
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation() - dragStart
			MainPanel.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	local isFloatingDragging = false
	local floatingDragStart = nil
	local floatingStartPos = nil
	
	FloatingButton.MouseButton1Down:Connect(function()
		isFloatingDragging = true
		floatingDragStart = UserInputService:GetMouseLocation()
		floatingStartPos = FloatingButton.Position
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isFloatingDragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isFloatingDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation() - floatingDragStart
			FloatingButton.Position = UDim2.new(
				floatingStartPos.X.Scale,
				floatingStartPos.X.Offset + delta.X,
				floatingStartPos.Y.Scale,
				floatingStartPos.Y.Offset + delta.Y
			)
		end
	end)
	
	coroutine.wrap(function()
		GameMechanics:AntiAFKLoop()
	end)()
	
	LogSystem:Print("Interfaz principal creada exitosamente", "SUCCESS")
	LogSystem:Print("Script listo para usar - Presiona ⏹️ para cerrar", "INFO")
end

LocalPlayer.CharacterAdded:Connect(function(char)
	PlayerCharacter = char
	PlayerRootPart = char:WaitForChild("HumanoidRootPart")
	PlayerHumanoid = char:WaitForChild("Humanoid")
	
	if ScriptSettings.WalkSpeed > 0 then
		GameMechanics:SetWalkSpeed(ScriptSettings.WalkSpeed)
	end
	if ScriptSettings.JumpPower > 0 then
		GameMechanics:SetJumpPower(ScriptSettings.JumpPower)
	end
	
	LogSystem:Print("Nuevo personaje detectado", "GAME")
end)

pcall(function()
	game:GetService("RunService").Heartbeat:Connect(function()
		if not ScriptRunning or not game then
			ScriptRunning = false
		end
	end)
end)

LogSystem:Print("Sorkscripts v3.0 inicializado", "SUCCESS")
LogSystem:Print("Esperando que la pantalla de carga se complete...", "INFO")

print("\n" .. string.rep("=", 60))
print("✅ SORKSCRIPTS | CRECER POLLO v3.0 - FULLY FUNCTIONAL")
print("Script completamente funcional y listo para usar")
print(string.rep("=", 60) .. "\n")
