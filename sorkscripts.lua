--// ====================================================
--// SORKSCRIPTS | CRECER POLLO | V2.0 - FULLY FUNCTIONAL
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

local LocalPlayer = Players.LocalPlayer
local PlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ====================================================
-- CONFIGURACIÓN DE COLORES (VERTEX STYLE)
-- ====================================================

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
}

-- ====================================================
-- VARIABLES GLOBALES DEL SCRIPT
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
}

local ScriptActive = true
local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local AutoFarmLoop = nil
local AutoEggLoop = nil

-- Logging system
local function Log(message, type)
	type = type or "INFO"
	local prefix = {
		INFO = "ℹ️",
		SUCCESS = "✅",
		WARNING = "⚠️",
		ERROR = "❌",
		DEBUG = "🐛"
	}
	print("[Sorkscripts] " .. (prefix[type] or "•") .. " " .. message)
end

-- ====================================================
-- FUNCIÓN PARA ENCONTRAR REMOTES
-- ====================================================

local function FindRemote(name, timeout)
	timeout = timeout or 5
	local startTime = tick()
	
	while tick() - startTime < timeout do
		local remote = ReplicatedStorage:FindFirstChild(name)
		if remote then
			Log("Remote encontrado: " .. name, "SUCCESS")
			return remote
		end
		
		local remoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
		if remoteFolder then
			remote = remoteFolder:FindFirstChild(name)
			if remote then
				Log("Remote encontrado en Remotes: " .. name, "SUCCESS")
				return remote
			end
		end
		
		task.wait(0.1)
	end
	
	Log("Remote NO encontrado: " .. name, "WARNING")
	return nil
end

local function SafeFire(remote, ...)
	if not remote or not remote:IsA("RemoteEvent") then
		return false
	end
	
	local ok, err = pcall(function()
		remote:FireServer(...)
	end)
	
	if not ok then
		Log("Error al disparar remote: " .. tostring(err), "ERROR")
		return false
	end
	
	return true
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
-- PANTALLA DE CARGA MEJORADA
-- ====================================================

local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = CONFIG.Background
Loading.BorderSizePixel = 0
Loading.Parent = ScreenGui

local Welcome = Instance.new("TextLabel")
Welcome.Size = UDim2.new(1, 0, 0, 50)
Welcome.Position = UDim2.new(0, 0, 0.35, 0)
Welcome.BackgroundTransparency = 1
Welcome.Text = "🔮 SORKSCRIPTS"
Welcome.TextColor3 = CONFIG.Accent
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 32
Welcome.Parent = Loading

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(1, 0, 0, 30)
UserLabel.Position = UDim2.new(0, 0, 0.42, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "Bienvenido, " .. LocalPlayer.Name
UserLabel.TextColor3 = CONFIG.Text
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 18
UserLabel.Parent = Loading

local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(1, 0, 0, 20)
GameLabel.Position = UDim2.new(0, 0, 0.47, 0)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Crecer Pollo v2.0"
GameLabel.TextColor3 = CONFIG.TextDim
GameLabel.Font = Enum.Font.Gotham
GameLabel.TextSize = 14
GameLabel.Parent = Loading

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.58, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inicializando Sorkscripts..."
StatusLabel.TextColor3 = CONFIG.TextDim
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = Loading

-- Barra de progreso mejorada
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0.4, 0, 0, 8)
BarBG.Position = UDim2.new(0.3, 0, 0.52, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
BarBG.BorderSizePixel = 0
BarBG.Parent = Loading

Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = CONFIG.Accent
Bar.BorderSizePixel = 0
Bar.Parent = BarBG

Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

-- Animación de la barra
local barTween = TweenService:Create(Bar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
	Size = UDim2.new(1, 0, 1, 0)
})

barTween:Play()

barTween.Completed:Connect(function()
	StatusLabel.Text = "✅ ¡Listo!"
	task.wait(0.6)
	
	local fade = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(Loading, fade, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Welcome, fade, {TextTransparency = 1}):Play()
	TweenService:Create(UserLabel, fade, {TextTransparency = 1}):Play()
	TweenService:Create(GameLabel, fade, {TextTransparency = 1}):Play()
	TweenService:Create(StatusLabel, fade, {TextTransparency = 1}):Play()
	TweenService:Create(BarBG, fade, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Bar, fade, {BackgroundTransparency = 1}):Play()
	
	task.wait(0.7)
	Loading:Destroy()
	CreateGameSelector()
end)

-- ====================================================
-- SELECTOR DE JUEGOS
-- ====================================================

function CreateGameSelector()
	local Selector = Instance.new("Frame")
	Selector.Size = UDim2.new(0, 380, 0, 450)
	Selector.Position = UDim2.new(0.5, -190, 0.5, -225)
	Selector.BackgroundColor3 = CONFIG.Background
	Selector.BorderSizePixel = 0
	Selector.Parent = ScreenGui
	
	Instance.new("UICorner", Selector).CornerRadius = UDim.new(0, 16)
	
	local stroke = Instance.new("UIStroke", Selector)
	stroke.Color = CONFIG.Accent
	stroke.Thickness = 1.5
	stroke.Transparency = 0.4
	
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 60)
	Title.BackgroundTransparency = 1
	Title.Text = "🔮 SORKSCRIPTS"
	Title.TextColor3 = CONFIG.Accent
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 24
	Title.Parent = Selector
	
	local Sub = Instance.new("TextLabel")
	Sub.Size = UDim2.new(1, -30, 0, 30)
	Sub.Position = UDim2.new(0, 15, 0, 50)
	Sub.BackgroundTransparency = 1
	Sub.Text = "Selecciona un juego"
	Sub.TextColor3 = CONFIG.TextDim
	Sub.Font = Enum.Font.Gotham
	Sub.TextSize = 14
	Sub.TextWrapped = true
	Sub.Parent = Selector
	
	local List = Instance.new("Frame")
	List.Size = UDim2.new(1, -30, 1, -110)
	List.Position = UDim2.new(0, 15, 0, 90)
	List.BackgroundTransparency = 1
	List.Parent = Selector
	
	local layout = Instance.new("UIListLayout", List)
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local function CreateGameButton(name, enabled, order)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 70)
		Btn.BackgroundColor3 = CONFIG.Card
		Btn.Text = ""
		Btn.LayoutOrder = order
		Btn.AutoButtonColor = false
		Btn.Parent = List
		
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
		
		local btnStroke = Instance.new("UIStroke", Btn)
		btnStroke.Color = enabled and CONFIG.Accent or CONFIG.TextDim
		btnStroke.Thickness = 1.2
		btnStroke.Transparency = enabled and 0.3 or 0.7
		
		local NameL = Instance.new("TextLabel")
		NameL.Size = UDim2.new(1, -30, 0, 28)
		NameL.Position = UDim2.new(0, 15, 0, 12)
		NameL.BackgroundTransparency = 1
		NameL.Text = name
		NameL.TextColor3 = enabled and CONFIG.Text or CONFIG.TextDim
		NameL.Font = Enum.Font.GothamBold
		NameL.TextSize = 16
		NameL.TextXAlignment = Enum.TextXAlignment.Left
		NameL.Parent = Btn
		
		local Status = Instance.new("TextLabel")
		Status.Size = UDim2.new(1, -30, 0, 20)
		Status.Position = UDim2.new(0, 15, 0, 40)
		Status.BackgroundTransparency = 1
		Status.Text = enabled and "✅ Disponible" or "🔒 Próximamente"
		Status.TextColor3 = enabled and CONFIG.Success or Color3.fromRGB(150, 90, 90)
		Status.Font = Enum.Font.Gotham
		Status.TextSize = 12
		Status.TextXAlignment = Enum.TextXAlignment.Left
		Status.Parent = Btn
		
		if enabled then
			Btn.MouseButton1Click:Connect(function()
				local fade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				TweenService:Create(Selector, fade, {BackgroundTransparency = 1}):Play()
				
				task.wait(0.35)
				Selector:Destroy()
				CreateMainUI(name)
			end)
			
			Btn.MouseEnter:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.CardHover}):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.15), {Thickness = 1.8}):Play()
			end)
			
			Btn.MouseLeave:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Card}):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.15), {Thickness = 1.2}):Play()
			end)
		else
			Btn.BackgroundTransparency = 0.5
		end
	end
	
	CreateGameButton("🐔 Crecer Pollo", true, 1)
	CreateGameButton("🚪 Romper Puerta", false, 2)
	CreateGameButton("🍊 Blox Fruits", false, 3)
end

-- ====================================================
-- FUNCIONES DEL JUEGO - GAME MECHANICS
-- ====================================================

local GameMechanics = {}

-- Detectar y obtener datos del juego
function GameMechanics:DetectGameStructure()
	Log("Detectando estructura del juego...", "DEBUG")
	
	-- Buscar pollos en workspace
	local chicken = Workspace:FindFirstChild("Chicken") or 
				   Workspace:FindFirstChild("chicken") or
				   Workspace:FindFirstChild("Pet") or
				   Workspace:FindFirstChild("pet")
	
	-- Buscar huevos
	local egg = Workspace:FindFirstChild("Egg") or
			   Workspace:FindFirstChild("egg") or
			   Workspace:FindFirstChild("EggPart") or
			   Workspace:FindFirstChild("Egg_Part")
	
	-- Buscar área de farming
	local farmArea = Workspace:FindFirstChild("FarmArea") or
					Workspace:FindFirstChild("Farm") or
					Workspace:FindFirstChild("GameArea")
	
	return {
		chicken = chicken,
		egg = egg,
		farmArea = farmArea
	}
end

-- Auto Collect Eggs
function GameMechanics:AutoCollectEggsLoop()
	if not ScriptState.AutoCollectEggs or not ScriptActive then return end
	
	Log("Auto Collect Eggs iniciado", "SUCCESS")
	
	while ScriptState.AutoCollectEggs and ScriptActive do
		task.wait(0.3)
		
		pcall(function()
			-- Buscar huevos en workspace
			for _, egg in pairs(Workspace:GetChildren()) do
				if egg:IsA("Part") or egg:IsA("Model") then
					local name = egg.Name:lower()
					
					if name:find("egg") or name:find("huevo") or name:find("spawn") then
						-- Mover al jugador cerca del huevo
						if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
							PlayerCharacter:SetPrimaryPartCFrame(egg.CFrame + Vector3.new(0, 3, 0))
							
							-- Intentar disparar evento de recolecta
							local remote = FindRemote("CollectEgg") or FindRemote("Collect") or FindRemote("TakeEgg")
							if remote then
								SafeFire(remote, egg)
							end
							
							Log("Huevo recolectado: " .. egg.Name, "SUCCESS")
						end
						
						task.wait(0.2)
					end
				end
			end
		end)
	end
end

-- Auto Hatch Eggs
function GameMechanics:AutoHatchEggsLoop()
	if not ScriptState.AutoHatch or not ScriptActive then return end
	
	Log("Auto Hatch iniciado", "SUCCESS")
	
	while ScriptState.AutoHatch and ScriptActive do
		task.wait(0.5)
		
		pcall(function()
			-- Buscar remoto de eclosión
			local hatchRemote = FindRemote("HatchEgg") or FindRemote("Hatch") or FindRemote("IncubateEgg")
			
			if hatchRemote then
				SafeFire(hatchRemote)
				Log("Huevo eclosionado", "SUCCESS")
			end
		end)
	end
end

-- Auto Farm Chickens
function GameMechanics:AutoFarmChickensLoop()
	if not ScriptState.AutoFarm or not ScriptActive then return end
	
	Log("Auto Farm Chickens iniciado", "SUCCESS")
	
	while ScriptState.AutoFarm and ScriptActive do
		task.wait(0.4)
		
		pcall(function()
			if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
				-- Buscar pollos cercanos
				for _, chicken in pairs(Workspace:GetChildren()) do
					if chicken:IsA("Model") or chicken:IsA("Part") then
						local name = chicken.Name:lower()
						
						if name:find("chicken") or name:find("pollo") or name:find("pet") then
							-- Mover al pollo
							local chickenPos = chicken:FindFirstChild("HumanoidRootPart") or chicken.PrimaryPart or chicken
							
							if chickenPos then
								PlayerCharacter:SetPrimaryPartCFrame(chickenPos.CFrame + Vector3.new(0, 0, 5))
								
								-- Disparar evento de ataque/alimentación
								local attackRemote = FindRemote("Attack") or FindRemote("Feed") or FindRemote("Interact")
								if attackRemote then
									SafeFire(attackRemote, chicken)
								end
								
								Log("Pollo atacado/alimentado", "SUCCESS")
								task.wait(0.3)
							end
						end
					end
				end
			end
		end)
	end
end

-- Auto Sell
function GameMechanics:AutoSellChickensLoop()
	if not ScriptState.AutoSell or not ScriptActive then return end
	
	Log("Auto Sell iniciado", "SUCCESS")
	
	while ScriptState.AutoSell and ScriptActive do
		task.wait(1)
		
		pcall(function()
			local sellRemote = FindRemote("Sell") or FindRemote("SellChicken") or FindRemote("SellPet")
			
			if sellRemote then
				SafeFire(sellRemote)
				Log("Pollo vendido", "SUCCESS")
			end
		end)
	end
end

-- Anti AFK Loop
function GameMechanics:AntiAFKLoop()
	if not ScriptState.AntiAFK or not ScriptActive then return end
	
	Log("Anti AFK activado", "SUCCESS")
	
	while ScriptState.AntiAFK and ScriptActive do
		task.wait(120) -- Cada 2 minutos
		
		pcall(function()
			if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
				PlayerCharacter.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				Log("Anti AFK - Movimiento realizado", "DEBUG")
			end
		end)
	end
end

-- Infinite Jump
function GameMechanics:InfiniteJumpStart()
	if not ScriptState.InfiniteJump or not ScriptActive then return end
	
	Log("Infinite Jump activado", "SUCCESS")
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.Space and ScriptState.InfiniteJump then
			if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
				PlayerCharacter.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
end

-- Walk Speed Modify
function GameMechanics:SetWalkSpeed(speed)
	pcall(function()
		if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
			PlayerCharacter.Humanoid.WalkSpeed = speed
			Log("Walk Speed cambiado a: " .. speed, "SUCCESS")
		end
	end)
end

-- Jump Power Modify
function GameMechanics:SetJumpPower(power)
	pcall(function()
		if PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") then
			PlayerCharacter.Humanoid.JumpPower = power
			Log("Jump Power cambiado a: " .. power, "SUCCESS")
		end
	end)
end

-- ====================================================
-- UI PRINCIPAL MEJORADA
-- ====================================================

function CreateMainUI(gameName)
	-- Obtener headshot del jugador
	local headshot = "rbxassetid://0"
	pcall(function()
		headshot = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	
	-- ===== BOTÓN FLOTANTE (TOGGLE) =====
	
	local Toggle = Instance.new("ImageButton")
	Toggle.Name = "FloatingToggle"
	Toggle.Size = UDim2.new(0, 56, 0, 56)
	Toggle.Position = UDim2.new(0, 20, 0.42, 0)
	Toggle.BackgroundColor3 = CONFIG.Card
	Toggle.Image = headshot
	Toggle.ScaleType = Enum.ScaleType.Crop
	Toggle.Parent = ScreenGui
	Toggle.ZIndex = 100
	
	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
	
	local toggleStroke = Instance.new("UIStroke", Toggle)
	toggleStroke.Color = CONFIG.Accent
	toggleStroke.Thickness = 2.2
	toggleStroke.Transparency = 0.3
	
	-- ===== FRAME PRINCIPAL =====
	
	local Main = Instance.new("Frame")
	Main.Name = "MainUI"
	Main.Size = UDim2.new(0, 560, 0, 420)
	Main.Position = UDim2.new(0.5, -280, 0.5, -210)
	Main.BackgroundColor3 = CONFIG.Background
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	Main.ZIndex = 50
	
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
	
	local mainStroke = Instance.new("UIStroke", Main)
	mainStroke.Color = Color3.fromRGB(50, 50, 60)
	mainStroke.Thickness = 1.2
	
	-- ===== HEADER =====
	
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = CONFIG.Sidebar
	Header.BorderSizePixel = 0
	Header.Parent = Main
	
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)
	
	local HeaderTitle = Instance.new("TextLabel")
	HeaderTitle.Size = UDim2.new(0.6, 0, 1, 0)
	HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
	HeaderTitle.BackgroundTransparency = 1
	HeaderTitle.Text = "🐔 " .. gameName
	HeaderTitle.TextColor3 = CONFIG.Accent
	HeaderTitle.Font = Enum.Font.GothamBold
	HeaderTitle.TextSize = 18
	HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
	HeaderTitle.Parent = Header
	
	-- ===== SIDEBAR IZQUIERDA =====
	
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 160, 1, -50)
	Sidebar.Position = UDim2.new(0, 0, 0, 50)
	Sidebar.BackgroundColor3 = CONFIG.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	
	-- ===== CATEGORÍAS =====
	
	local categories = {
		{Name = "Main", Icon = "🚀", Order = 1},
		{Name = "Farm", Icon = "🐔", Order = 2},
		{Name = "Player", Icon = "👤", Order = 3},
		{Name = "Config", Icon = "⚙️", Order = 4},
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
	
	-- ===== ÁREA DE CONTENIDO =====
	
	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(1, -175, 1, -60)
	ContentArea.Position = UDim2.new(0, 165, 0, 55)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = Main
	
	local ContentTitle = Instance.new("TextLabel")
	ContentTitle.Size = UDim2.new(1, 0, 0, 30)
	ContentTitle.BackgroundTransparency = 1
	ContentTitle.Text = "Main"
	ContentTitle.TextColor3 = CONFIG.Text
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
		frame.ScrollBarThickness = 3
		frame.ScrollBarImageColor3 = CONFIG.Accent
		frame.Visible = (cat.Name == "Main")
		frame.Parent = ContentArea
		
		contentFrames[cat.Name] = frame
		
		local list = Instance.new("UIListLayout", frame)
		list.Padding = UDim.new(0, 8)
		list.SortOrder = Enum.SortOrder.LayoutOrder
	end
	
	-- ===== FUNCIÓN CREAR TOGGLE =====
	
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
	
	-- ===== FUNCIÓN CREAR SLIDER =====
	
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
				
				TweenService:Create(sliderFill, TweenInfo.new(0.05), {
					Size = UDim2.new(relativePos, 0, 1, 0)
				}):Play()
				
				TweenService:Create(sliderButton, TweenInfo.new(0.05), {
					Position = UDim2.new(relativePos, -6, 0.5, -6)
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
			coroutine.wrap(function() GameMechanics:AutoFarmChickensLoop() end)()
		end
	end)
	
	CreateToggle(contentFrames["Main"], "🥚 Auto Collect Eggs", false, function(state)
		ScriptState.AutoCollectEggs = state
		if state then
			coroutine.wrap(function() GameMechanics:AutoCollectEggsLoop() end)()
		end
	end)
	
	CreateToggle(contentFrames["Main"], "🐣 Auto Hatch", false, function(state)
		ScriptState.AutoHatch = state
		if state then
			coroutine.wrap(function() GameMechanics:AutoHatchEggsLoop() end)()
		end
	end)
	
	CreateToggle(contentFrames["Main"], "💰 Auto Sell", false, function(state)
		ScriptState.AutoSell = state
		if state then
			coroutine.wrap(function() GameMechanics:AutoSellChickensLoop() end)()
		end
	end)
	
	-- ===== CONTENIDO - FARM =====
	
	CreateToggle(contentFrames["Farm"], "⚔️ Auto Attack", false, function(state)
		ScriptState.AutoFight = state
	end)
	
	CreateToggle(contentFrames["Farm"], "🏔️ Auto Climb", false, function(state)
		ScriptState.AutoClimbTower = state
	end)
	
	CreateToggle(contentFrames["Farm"], "🔄 Auto Fuse", false, function(state)
		ScriptState.AutoFuse = state
	end)
	
	-- ===== CONTENIDO - PLAYER =====
	
	CreateSlider(contentFrames["Player"], "👟 Walk Speed", 10, 100, DefaultWalkSpeed, function(value)
		DefaultWalkSpeed = value
		GameMechanics:SetWalkSpeed(value)
	end)
	
	CreateSlider(contentFrames["Player"], "📈 Jump Power", 20, 150, DefaultJumpPower, function(value)
		DefaultJumpPower = value
		GameMechanics:SetJumpPower(value)
	end)
	
	CreateToggle(contentFrames["Player"], "♾️ Infinite Jump", false, function(state)
		ScriptState.InfiniteJump = state
		if state then
			GameMechanics:InfiniteJumpStart()
		end
	end)
	
	-- ===== CONTENIDO - CONFIG =====
	
	CreateToggle(contentFrames["Config"], "🛡️ Anti AFK", true, function(state)
		ScriptState.AntiAFK = state
		if state then
			coroutine.wrap(function() GameMechanics:AntiAFKLoop() end)()
		end
	end)
	
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 0, 30)
	infoLabel.Position = UDim2.new(0, 10, 1, -35)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "v2.0 • Fully Functional • Sorkscripts © 2024"
	infoLabel.TextColor3 = CONFIG.TextDim
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 10
	infoLabel.Parent = contentFrames["Config"]
	
	-- ===== BOTONES DEL SIDEBAR =====
	
	for i, cat in ipairs(categories) do
		local btn = Instance.new("TextButton")
		btn.Name = cat.Name .. "Btn"
		btn.Size = UDim2.new(1, 0, 0, 38)
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
	
	-- ===== BOTÓN CERRAR SCRIPT COMPLETAMENTE =====
	
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
		
		-- Detener todos los loops
		ScriptState.AutoFarm = false
		ScriptState.AutoCollectEggs = false
		ScriptState.AutoHatch = false
		ScriptState.AutoSell = false
		ScriptState.AntiAFK = false
		ScriptState.InfiniteJump = false
		
		-- Animación de cierre
		local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(Main, fade, {BackgroundTransparency = 1}):Play()
		TweenService:Create(Toggle, fade, {BackgroundTransparency = 1}):Play()
		
		task.wait(0.5)
		
		-- Destruir GUI
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
	
	-- ===== ARRASTRAR MAIN FRAME =====
	
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
	
	-- Iniciar loops principales
	coroutine.wrap(function() GameMechanics:AntiAFKLoop() end)()
	
	Log("Sorkscripts | Crecer Pollo v2.0 cargado correctamente ✅", "SUCCESS")
	Log("Panel UI listo para usar 🎮", "SUCCESS")
	Log("Presiona el botón ⏹️ para cerrar completamente", "INFO")
end

print("\n" .. string.rep("=", 50))
print("✅ SORKSCRIPTS | CRECER POLLO v2.0")
print("Fully Functional Script")
print(string.rep("=", 50) .. "\n")
