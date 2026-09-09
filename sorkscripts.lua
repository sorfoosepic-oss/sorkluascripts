--// Sorkscripts | Estilo Vertex (Oscuro)

--// Juego principal: Crecer Pollo

--// Compatible con Delta Mobile



local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local CoreGui = game:GetService("CoreGui")



local LocalPlayer = Players.LocalPlayer



-- Colores estilo Vertex (oscuro + acento morado suave)

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



-- Limpiar GUI anterior

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



-- =====================================================

-- PANTALLA DE CARGA

-- =====================================================

local Loading = Instance.new("Frame")

Loading.Size = UDim2.new(1, 0, 1, 0)

Loading.BackgroundColor3 = CONFIG.Background

Loading.BorderSizePixel = 0

Loading.Parent = ScreenGui



local Welcome = Instance.new("TextLabel")

Welcome.Size = UDim2.new(1, 0, 0, 40)

Welcome.Position = UDim2.new(0, 0, 0.36, 0)

Welcome.BackgroundTransparency = 1

Welcome.Text = "Bienvenido"

Welcome.TextColor3 = CONFIG.Accent

Welcome.Font = Enum.Font.GothamBold

Welcome.TextSize = 28

Welcome.Parent = Loading



local UserLabel = Instance.new("TextLabel")

UserLabel.Size = UDim2.new(1, 0, 0, 30)

UserLabel.Position = UDim2.new(0, 0, 0.42, 0)

UserLabel.BackgroundTransparency = 1

UserLabel.Text = LocalPlayer.Name

UserLabel.TextColor3 = CONFIG.Text

UserLabel.Font = Enum.Font.Gotham

UserLabel.TextSize = 18

UserLabel.Parent = Loading



local StatusLabel = Instance.new("TextLabel")

StatusLabel.Size = UDim2.new(1, 0, 0, 20)

StatusLabel.Position = UDim2.new(0, 0, 0.58, 0)

StatusLabel.BackgroundTransparency = 1

StatusLabel.Text = "Cargando Sorkscripts..."

StatusLabel.TextColor3 = CONFIG.TextDim

StatusLabel.Font = Enum.Font.Gotham

StatusLabel.TextSize = 14

StatusLabel.Parent = Loading



local BarBG = Instance.new("Frame")

BarBG.Size = UDim2.new(0.38, 0, 0, 7)

BarBG.Position = UDim2.new(0.31, 0, 0.52, 0)

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



local barTween = TweenService:Create(Bar, TweenInfo.new(2.1, Enum.EasingStyle.Quad), {

Size = UDim2.new(1, 0, 1, 0)

})

barTween:Play()



barTween.Completed:Connect(function()

StatusLabel.Text = "Listo!"

task.wait(0.4)


local fade = TweenInfo.new(0.5)

TweenService:Create(Loading, fade, {BackgroundTransparency = 1}):Play()

TweenService:Create(Welcome, fade, {TextTransparency = 1}):Play()

TweenService:Create(UserLabel, fade, {TextTransparency = 1}):Play()

TweenService:Create(StatusLabel, fade, {TextTransparency = 1}):Play()

TweenService:Create(BarBG, fade, {BackgroundTransparency = 1}):Play()

TweenService:Create(Bar, fade, {BackgroundTransparency = 1}):Play()


task.wait(0.6)

Loading:Destroy()

CreateGameSelector()

end)



-- =====================================================

-- SELECTOR DE JUEGOS

-- =====================================================

function CreateGameSelector()

local Selector = Instance.new("Frame")

Selector.Size = UDim2.new(0, 340, 0, 400)

Selector.Position = UDim2.new(0.5, -170, 0.5, -200)

Selector.BackgroundColor3 = CONFIG.Background

Selector.BorderSizePixel = 0

Selector.Parent = ScreenGui

Instance.new("UICorner", Selector).CornerRadius = UDim.new(0, 14)



local stroke = Instance.new("UIStroke", Selector)

stroke.Color = CONFIG.Accent

stroke.Thickness = 1.2

stroke.Transparency = 0.5



local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, 0, 0, 50)

Title.BackgroundTransparency = 1

Title.Text = "Sorkscripts"

Title.TextColor3 = CONFIG.Accent

Title.Font = Enum.Font.GothamBold

Title.TextSize = 22

Title.Parent = Selector



local Sub = Instance.new("TextLabel")

Sub.Size = UDim2.new(1, 0, 0, 22)

Sub.Position = UDim2.new(0, 0, 0, 40)

Sub.BackgroundTransparency = 1

Sub.Text = "Selecciona un juego"

Sub.TextColor3 = CONFIG.TextDim

Sub.Font = Enum.Font.Gotham

Sub.TextSize = 13

Sub.Parent = Selector



local List = Instance.new("Frame")

List.Size = UDim2.new(1, -30, 1, -85)

List.Position = UDim2.new(0, 15, 0, 75)

List.BackgroundTransparency = 1

List.Parent = Selector



local layout = Instance.new("UIListLayout", List)

layout.Padding = UDim.new(0, 10)



local function CreateGameButton(name, enabled, order)

local Btn = Instance.new("TextButton")

Btn.Size = UDim2.new(1, 0, 0, 65)

Btn.BackgroundColor3 = CONFIG.Card

Btn.Text = ""

Btn.LayoutOrder = order

Btn.AutoButtonColor = false

Btn.Parent = List

Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)



local NameL = Instance.new("TextLabel")

NameL.Size = UDim2.new(1, -20, 0, 26)

NameL.Position = UDim2.new(0, 15, 0, 10)

NameL.BackgroundTransparency = 1

NameL.Text = name

NameL.TextColor3 = enabled and CONFIG.Text or CONFIG.TextDim

NameL.Font = Enum.Font.GothamBold

NameL.TextSize = 16

NameL.TextXAlignment = Enum.TextXAlignment.Left

NameL.Parent = Btn



local Status = Instance.new("TextLabel")

Status.Size = UDim2.new(1, -20, 0, 18)

Status.Position = UDim2.new(0, 15, 0, 36)

Status.BackgroundTransparency = 1

Status.Text = enabled and "Disponible" or "Próximamente"

Status.TextColor3 = enabled and CONFIG.Accent or Color3.fromRGB(90, 90, 100)

Status.Font = Enum.Font.Gotham

Status.TextSize = 12

Status.TextXAlignment = Enum.TextXAlignment.Left

Status.Parent = Btn



if enabled then

Btn.MouseButton1Click:Connect(function()

TweenService:Create(Selector, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()

task.wait(0.32)

Selector:Destroy()

CreateMainUI(name)

end)

Btn.MouseEnter:Connect(function()

TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 45)}):Play()

end)

Btn.MouseLeave:Connect(function()

TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Card}):Play()

end)

else

Btn.BackgroundTransparency = 0.4

end

end



CreateGameButton("Crecer Pollo", true, 1)

CreateGameButton("Romper Puerta", false, 2)

CreateGameButton("Blox Fruits", false, 3)

end



-- =====================================================

-- UI PRINCIPAL (ESTILO VERTEX)

-- =====================================================

function CreateMainUI(gameName)

-- Headshot

local headshot = "rbxassetid://0"

pcall(function()

headshot = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)

end)



-- Bolita flotante

local Toggle = Instance.new("ImageButton")

Toggle.Size = UDim2.new(0, 54, 0, 54)

Toggle.Position = UDim2.new(0, 15, 0.42, 0)

Toggle.BackgroundColor3 = CONFIG.Card

Toggle.Image = headshot

Toggle.ScaleType = Enum.ScaleType.Crop

Toggle.Parent = ScreenGui

Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

local ts = Instance.new("UIStroke", Toggle)

ts.Color = CONFIG.Accent

ts.Thickness = 2.2



-- Frame principal

local Main = Instance.new("Frame")

Main.Name = "MainUI"

Main.Size = UDim2.new(0, 520, 0, 380)

Main.Position = UDim2.new(0.5, -260, 0.5, -190)

Main.BackgroundColor3 = CONFIG.Background

Main.BorderSizePixel = 0

Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)



local mainStroke = Instance.new("UIStroke", Main)

mainStroke.Color = Color3.fromRGB(50, 50, 60)

mainStroke.Thickness = 1



-- ========== SIDEBAR IZQUIERDA ==========

local Sidebar = Instance.new("Frame")

Sidebar.Size = UDim2.new(0, 150, 1, 0)

Sidebar.BackgroundColor3 = CONFIG.Sidebar

Sidebar.BorderSizePixel = 0

Sidebar.Parent = Main

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)



-- Logo / Título

local Logo = Instance.new("TextLabel")

Logo.Size = UDim2.new(1, 0, 0, 50)

Logo.BackgroundTransparency = 1

Logo.Text = "Sorkscripts"

Logo.TextColor3 = CONFIG.Accent

Logo.Font = Enum.Font.GothamBold

Logo.TextSize = 16

Logo.Parent = Sidebar



local Version = Instance.new("TextLabel")

Version.Size = UDim2.new(1, 0, 0, 18)

Version.Position = UDim2.new(0, 0, 0, 32)

Version.BackgroundTransparency = 1

Version.Text = "v0.1 • " .. gameName

Version.TextColor3 = CONFIG.TextDim

Version.Font = Enum.Font.Gotham

Version.TextSize = 11

Version.Parent = Sidebar



-- Categorías del sidebar

local categories = {

{Name = "Main", Icon = "⚔"},

{Name = "Farm", Icon = "🐔"},

{Name = "Player", Icon = "👤"},

{Name = "Visuals", Icon = "👁"},

{Name = "Settings", Icon = "⚙"},

}



local selectedCategory = "Main"

local contentFrames = {}



local CatList = Instance.new("Frame")

CatList.Size = UDim2.new(1, -16, 1, -70)

CatList.Position = UDim2.new(0, 8, 0, 60)

CatList.BackgroundTransparency = 1

CatList.Parent = Sidebar



local catLayout = Instance.new("UIListLayout", CatList)

catLayout.Padding = UDim.new(0, 6)



-- ========== ÁREA DE CONTENIDO ==========

local ContentArea = Instance.new("Frame")

ContentArea.Size = UDim2.new(1, -160, 1, -20)

ContentArea.Position = UDim2.new(0, 155, 0, 10)

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



-- Crear frames de contenido por categoría

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



-- Función para crear un toggle

local function CreateToggle(parent, text, default)

local holder = Instance.new("Frame")

holder.Size = UDim2.new(1, -10, 0, 36)

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

label.TextSize = 14

label.TextXAlignment = Enum.TextXAlignment.Left

label.Parent = holder



local toggle = Instance.new("TextButton")

toggle.Size = UDim2.new(0, 42, 0, 22)

toggle.Position = UDim2.new(1, -52, 0.5, -11)

toggle.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff

toggle.Text = ""

toggle.Parent = holder

Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)



local circle = Instance.new("Frame")

circle.Size = UDim2.new(0, 16, 0, 16)

circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

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

Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

}):Play()

end)



return holder

end



-- Contenido de ejemplo (Main)

CreateToggle(contentFrames["Main"], "Auto Farm", false)

CreateToggle(contentFrames["Main"], "Auto Collect Eggs", false)

CreateToggle(contentFrames["Main"], "Auto Hatch", false)

CreateToggle(contentFrames["Main"], "Auto Sell", false)



-- Farm

CreateToggle(contentFrames["Farm"], "Auto Fight (PIT)", false)

CreateToggle(contentFrames["Farm"], "Auto Climb Tower", false)

CreateToggle(contentFrames["Farm"], "Auto Fuse", false)



-- Player

CreateToggle(contentFrames["Player"], "WalkSpeed", false)

CreateToggle(contentFrames["Player"], "JumpPower", false)

CreateToggle(contentFrames["Player"], "Infinite Jump", false)



-- Visuals

CreateToggle(contentFrames["Visuals"], "ESP Chickens", false)

CreateToggle(contentFrames["Visuals"], "ESP Eggs", false)



-- Settings

CreateToggle(contentFrames["Settings"], "Auto Rejoin", false)

CreateToggle(contentFrames["Settings"], "Anti AFK", true)



-- Botones del sidebar

for i, cat in ipairs(categories) do

local btn = Instance.new("TextButton")

btn.Size = UDim2.new(1, 0, 0, 36)

btn.BackgroundColor3 = (cat.Name == "Main") and Color3.fromRGB(40, 35, 55) or Color3.fromRGB(0, 0, 0)

btn.BackgroundTransparency = (cat.Name == "Main") and 0 or 1

btn.Text = " " .. cat.Icon .. " " .. cat.Name

btn.TextColor3 = (cat.Name == "Main") and CONFIG.Text or CONFIG.TextDim

btn.Font = Enum.Font.Gotham

btn.TextSize = 14

btn.TextXAlignment = Enum.TextXAlignment.Left

btn.Parent = CatList

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)



btn.MouseButton1Click:Connect(function()

-- Actualizar selección

for _, v in pairs(CatList:GetChildren()) do

if v:IsA("TextButton") then

v.BackgroundTransparency = 1

v.TextColor3 = CONFIG.TextDim

end

end

btn.BackgroundTransparency = 0

btn.BackgroundColor3 = Color3.fromRGB(40, 35, 55)

btn.TextColor3 = CONFIG.Text



-- Cambiar contenido

for name, frame in pairs(contentFrames) do

frame.Visible = (name == cat.Name)

end

ContentTitle.Text = cat.Name

selectedCategory = cat.Name

end)

end



-- Botón cerrar

local CloseBtn = Instance.new("TextButton")

CloseBtn.Size = UDim2.new(0, 28, 0, 28)

CloseBtn.Position = UDim2.new(1, -38, 0, 10)

CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 40)

CloseBtn.Text = "✕"

CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.TextSize = 14

CloseBtn.Parent = Main

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)



CloseBtn.MouseButton1Click:Connect(function()

Main.Visible = false

end)



-- Toggle bolita

Toggle.MouseButton1Click:Connect(function()

Main.Visible = not Main.Visible

end)



-- Arrastrar

local dragging, dragStart, startPos

local dragArea = Instance.new("Frame")

dragArea.Size = UDim2.new(1, -150, 0, 40)

dragArea.Position = UDim2.new(0, 150, 0, 0)

dragArea.BackgroundTransparency = 1

dragArea.Parent = Main



dragArea.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

dragging = true

dragStart = input.Position

startPos = Main.Position

input.Changed:Connect(function()

if input.UserInputState == Enum.UserInputState.End then dragging = false end

end)

end

end)



UserInputService.InputChanged:Connect(function(input)

if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then

local delta = input.Position - dragStart

Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

end

end)



-- Arrastrar bolita

local draggingBtn, dragStartBtn, startPosBtn

Toggle.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

draggingBtn = true

dragStartBtn = input.Position

startPosBtn = Toggle.Position

input.Changed:Connect(function()

if input.UserInputState == Enum.UserInputState.End then draggingBtn = false end

end)

end

end)



UserInputService.InputChanged:Connect(function(input)

if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then

local delta = input.Position - dragStartBtn

Toggle.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)

end

end)

end



print("✅ Sorkscripts | Crecer Pollo cargado")
