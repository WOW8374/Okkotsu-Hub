--[[
    Okkotsu Hub (Universal Version)
    Tela de aviso: "Estamos em manutenção"
    Layout minimalista + animações suaves
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local HUB_NAME = "Okkotsu Hub (Universal Version)"
local GUI_NAME = "OkkotsuHub_Maintenance"

-- Paleta
local COLORS = {
	Background = Color3.fromRGB(18, 12, 30),
	Surface    = Color3.fromRGB(32, 22, 52),
	Stroke     = Color3.fromRGB(78, 52, 128),
	Text       = Color3.fromRGB(244, 240, 255),
	SubText    = Color3.fromRGB(168, 152, 204),
	Accent     = Color3.fromRGB(150, 90, 255),
	Accent2    = Color3.fromRGB(205, 120, 255),
	Danger     = Color3.fromRGB(140, 60, 230),
}

----------------------------------------------------------------
-- Utilidades
----------------------------------------------------------------
local function getGuiParent()
	local ok, ui = pcall(function()
		return gethui and gethui()
	end)
	if ok and ui then
		return ui
	end

	local okCore, core = pcall(function()
		return game:GetService("CoreGui")
	end)
	if okCore and core then
		return core
	end

	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function create(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function tween(obj, time, props, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

-- Remove versão antiga, se existir
local parent = getGuiParent()
local old = parent:FindFirstChild(GUI_NAME)
if old then
	old:Destroy()
end

----------------------------------------------------------------
-- ScreenGui + Janela principal
----------------------------------------------------------------
local gui = create("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
}, nil)

pcall(function()
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
	end
end)
gui.Parent = parent

local main = create("CanvasGroup", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(440, 300),
	BackgroundColor3 = COLORS.Background,
	GroupTransparency = 1,
}, gui)
corner(main, 14)
create("UIStroke", {
	Color = COLORS.Stroke,
	Thickness = 1,
	Transparency = 0.2,
}, main)

local scale = create("UIScale", { Scale = 0.88 }, main)

----------------------------------------------------------------
-- Barra superior
----------------------------------------------------------------
local topbar = create("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundTransparency = 1,
}, main)

local accentDot = create("Frame", {
	Size = UDim2.fromOffset(8, 8),
	Position = UDim2.fromOffset(16, 16),
	BackgroundColor3 = COLORS.Accent,
}, topbar)
corner(accentDot, 4)

create("TextLabel", {
	Name = "Title",
	Position = UDim2.fromOffset(32, 0),
	Size = UDim2.new(1, -80, 1, 0),
	BackgroundTransparency = 1,
	Text = "Okkotsu Hub",
	TextColor3 = COLORS.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topbar)

local closeX = create("TextButton", {
	Name = "CloseX",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = COLORS.Surface,
	BackgroundTransparency = 1,
	Text = "✕",
	TextColor3 = COLORS.SubText,
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
}, topbar)
corner(closeX, 8)

create("Frame", {
	Name = "Divider",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = COLORS.Stroke,
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
}, topbar)

----------------------------------------------------------------
-- Aba (apenas "Aviso")
----------------------------------------------------------------
local tabBar = create("Frame", {
	Name = "TabBar",
	Position = UDim2.fromOffset(16, 46),
	Size = UDim2.new(1, -32, 0, 26),
	BackgroundTransparency = 1,
}, main)

local tabLabel = create("TextLabel", {
	Name = "TabAviso",
	Size = UDim2.fromOffset(60, 24),
	BackgroundTransparency = 1,
	Text = "Aviso",
	TextColor3 = COLORS.Accent,
	TextSize = 13,
	Font = Enum.Font.GothamMedium,
	TextTransparency = 1,
}, tabBar)

local tabUnderline = create("Frame", {
	Name = "Underline",
	Position = UDim2.fromOffset(0, 24),
	Size = UDim2.fromOffset(0, 2),
	BackgroundColor3 = COLORS.Accent,
	BorderSizePixel = 0,
}, tabBar)
corner(tabUnderline, 1)

----------------------------------------------------------------
-- Conteúdo da aba
----------------------------------------------------------------
-- Anel giratório
local ring = create("Frame", {
	Name = "Ring",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 88),
	Size = UDim2.fromOffset(50, 50),
	BackgroundTransparency = 1,
}, main)
corner(ring, 25)

local ringStroke = create("UIStroke", {
	Color = Color3.new(1, 1, 1),
	Thickness = 3,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, ring)

local ringGradient = create("UIGradient", {
	Color = ColorSequence.new(COLORS.Accent, COLORS.Accent2),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.55, 0.15),
		NumberSequenceKeypoint.new(0.56, 1),
		NumberSequenceKeypoint.new(1, 1),
	}),
}, ringStroke)

local bang = create("TextLabel", {
	Name = "Bang",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "!",
	TextColor3 = COLORS.Accent,
	TextSize = 24,
	Font = Enum.Font.GothamBold,
}, ring)

local title = create("TextLabel", {
	Name = "Headline",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 150),
	Size = UDim2.new(1, -40, 0, 28),
	BackgroundTransparency = 1,
	Text = "Estamos em manutenção",
	TextColor3 = COLORS.Text,
	TextSize = 21,
	Font = Enum.Font.GothamBold,
	TextTransparency = 1,
}, main)

local subtitle = create("TextLabel", {
	Name = "Description",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 182),
	Size = UDim2.new(1, -80, 0, 34),
	BackgroundTransparency = 1,
	Text = "O hub está temporariamente indisponível enquanto fazemos melhorias. Volte em breve!",
	TextColor3 = COLORS.SubText,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	TextTransparency = 1,
}, main)

-- Botão Fechar
local closeBtn = create("TextButton", {
	Name = "CloseButton",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 226),
	Size = UDim2.fromOffset(120, 30),
	BackgroundColor3 = COLORS.Surface,
	BackgroundTransparency = 1,
	Text = "Fechar",
	TextColor3 = COLORS.Text,
	TextSize = 13,
	Font = Enum.Font.GothamMedium,
	TextTransparency = 1,
	AutoButtonColor = false,
}, main)
corner(closeBtn, 8)
local closeBtnStroke = create("UIStroke", {
	Color = COLORS.Stroke,
	Thickness = 1,
	Transparency = 1,
}, closeBtn)
local closeBtnScale = create("UIScale", { Scale = 1 }, closeBtn)

----------------------------------------------------------------
-- Marca d'água (aparece em todas as abas)
----------------------------------------------------------------
local watermark = create("TextLabel", {
	Name = "Watermark",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -10),
	Size = UDim2.new(1, -20, 0, 14),
	BackgroundTransparency = 1,
	Text = HUB_NAME,
	TextColor3 = COLORS.Text,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextTransparency = 1,
	ZIndex = 0,
}, main)

----------------------------------------------------------------
-- Animações
----------------------------------------------------------------
local function bindButtonHover(button, hoverColor, hoverText)
	local baseText = button.TextColor3

	button.MouseEnter:Connect(function()
		tween(button, 0.18, { BackgroundTransparency = 0, BackgroundColor3 = hoverColor }, Enum.EasingStyle.Quad)
		if hoverText then
			tween(button, 0.18, { TextColor3 = hoverText }, Enum.EasingStyle.Quad)
		end
	end)

	button.MouseLeave:Connect(function()
		tween(button, 0.18, { TextColor3 = baseText }, Enum.EasingStyle.Quad)
	end)
end

-- Hover do botão X
closeX.MouseEnter:Connect(function()
	tween(closeX, 0.18, { BackgroundTransparency = 0, BackgroundColor3 = COLORS.Danger, TextColor3 = Color3.new(1, 1, 1) }, Enum.EasingStyle.Quad)
end)
closeX.MouseLeave:Connect(function()
	tween(closeX, 0.18, { BackgroundTransparency = 1, TextColor3 = COLORS.SubText }, Enum.EasingStyle.Quad)
end)

-- Hover do botão Fechar
closeBtn.MouseEnter:Connect(function()
	tween(closeBtn, 0.18, { BackgroundColor3 = COLORS.Stroke }, Enum.EasingStyle.Quad)
	tween(closeBtnStroke, 0.18, { Color = COLORS.Accent }, Enum.EasingStyle.Quad)
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn, 0.18, { BackgroundColor3 = COLORS.Surface }, Enum.EasingStyle.Quad)
	tween(closeBtnStroke, 0.18, { Color = COLORS.Stroke }, Enum.EasingStyle.Quad)
end)

-- Efeito de clique (afunda e volta)
closeBtn.MouseButton1Down:Connect(function()
	tween(closeBtnScale, 0.1, { Scale = 0.94 }, Enum.EasingStyle.Quad)
end)
closeBtn.MouseButton1Up:Connect(function()
	tween(closeBtnScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
end)

-- Anel girando em loop
TweenService:Create(
	ringGradient,
	TweenInfo.new(1.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{ Rotation = 360 }
):Play()

-- "!" pulsando suavemente
TweenService:Create(
	bang,
	TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ TextTransparency = 0.45 }
):Play()

-- Ponto de destaque pulsando
TweenService:Create(
	accentDot,
	TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ BackgroundTransparency = 0.6 }
):Play()

-- Entrada (abertura)
local function playIntro()
	tween(main, 0.45, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)
	tween(scale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)

	task.delay(0.15, function()
		tween(tabLabel, 0.4, { TextTransparency = 0 })
		tween(tabUnderline, 0.5, { Size = UDim2.fromOffset(60, 2) })
	end)

	task.delay(0.25, function()
		title.Position = UDim2.new(0.5, 0, 0, 160)
		tween(title, 0.5, { TextTransparency = 0, Position = UDim2.new(0.5, 0, 0, 150) })
	end)

	task.delay(0.35, function()
		subtitle.Position = UDim2.new(0.5, 0, 0, 192)
		tween(subtitle, 0.5, { TextTransparency = 0, Position = UDim2.new(0.5, 0, 0, 182) })
	end)

	task.delay(0.45, function()
		closeBtn.Position = UDim2.new(0.5, 0, 0, 236)
		tween(closeBtn, 0.5, {
			BackgroundTransparency = 0,
			TextTransparency = 0,
			Position = UDim2.new(0.5, 0, 0, 226),
		})
		tween(closeBtnStroke, 0.5, { Transparency = 0 })
	end)

	task.delay(0.55, function()
		tween(watermark, 0.6, { TextTransparency = 0.7 })
	end)
end

-- Saída (fechar)
local closing = false
local function closeHub()
	if closing then
		return
	end
	closing = true

	tween(scale, 0.35, { Scale = 0.88 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local t = tween(main, 0.35, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	t.Completed:Wait()
	gui:Destroy()
end

closeX.MouseButton1Click:Connect(closeHub)
closeBtn.MouseButton1Click:Connect(closeHub)

----------------------------------------------------------------
-- Arrastar a janela pela barra superior
----------------------------------------------------------------
do
	local dragging, dragStart, startPos

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			tween(main, 0.08, {
				Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				),
			}, Enum.EasingStyle.Quad)
		end
	end)
end

playIntro()
