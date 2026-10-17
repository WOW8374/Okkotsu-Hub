--[[
    Okkotsu Hub (Universal Version)
    Loading rápido + Abas: Música, X-Ray, Skin, Efeitos, Invisível
    Confirmação ao fechar (X ou botão Fechar)

    OBS: tudo aqui roda no CLIENTE. Em jogos com FilteringEnabled (padrão do Roblox),
    as mudanças só aparecem para você, a menos que o próprio jogo replique algo.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local HUB_NAME = "Okkotsu Hub (Universal Version)"
local GUI_NAME = "OkkotsuHub_Main"

local COLORS = {
	Background = Color3.fromRGB(16, 16, 22),
	Surface    = Color3.fromRGB(26, 26, 36),
	Stroke     = Color3.fromRGB(52, 52, 72),
	Text       = Color3.fromRGB(240, 240, 248),
	SubText    = Color3.fromRGB(150, 150, 170),
	Accent     = Color3.fromRGB(255, 170, 60),
	Accent2    = Color3.fromRGB(255, 96, 96),
	Danger     = Color3.fromRGB(235, 70, 80),
}

----------------------------------------------------------------
-- Utilidades
----------------------------------------------------------------
local connections = {}
local cleanupTasks = {}

local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

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

	return LocalPlayer:WaitForChild("PlayerGui")
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

local parent = getGuiParent()
local old = parent:FindFirstChild(GUI_NAME)
if old then
	old:Destroy()
end

----------------------------------------------------------------
-- ScreenGui
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

----------------------------------------------------------------
-- Janela principal
----------------------------------------------------------------
local main = create("CanvasGroup", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(480, 340),
	BackgroundColor3 = COLORS.Background,
	GroupTransparency = 1,
	Visible = false,
}, gui)
corner(main, 14)
create("UIStroke", { Color = COLORS.Stroke, Thickness = 1, Transparency = 0.2 }, main)
local scale = create("UIScale", { Scale = 0.88 }, main)

-- Barra superior
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

-- Barra de abas
local tabBar = create("Frame", {
	Name = "TabBar",
	Position = UDim2.fromOffset(16, 46),
	Size = UDim2.new(1, -32, 0, 28),
	BackgroundTransparency = 1,
}, main)

local tabUnderline = create("Frame", {
	Name = "Underline",
	Position = UDim2.fromOffset(0, 26),
	Size = UDim2.fromOffset(80, 2),
	BackgroundColor3 = COLORS.Accent,
	BorderSizePixel = 0,
}, tabBar)
corner(tabUnderline, 1)

-- Área de conteúdo
local content = create("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(16, 82),
	Size = UDim2.new(1, -32, 1, -138),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
}, main)

local statusLabel = create("TextLabel", {
	Name = "Status",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -28),
	Size = UDim2.new(1, -32, 0, 16),
	BackgroundTransparency = 1,
	Text = "Pronto.",
	TextColor3 = COLORS.SubText,
	TextSize = 11,
	Font = Enum.Font.Gotham,
}, main)

local function notify(text)
	statusLabel.Text = text
end

create("TextLabel", {
	Name = "Watermark",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -8),
	Size = UDim2.new(1, -20, 0, 14),
	BackgroundTransparency = 1,
	Text = HUB_NAME,
	TextColor3 = COLORS.Text,
	TextTransparency = 0.7,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
}, main)

----------------------------------------------------------------
-- Construtores de UI
----------------------------------------------------------------
local function makePage()
	local page = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = COLORS.Stroke,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, content)
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, page)
	create("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2) }, page)
	return page
end

local function makeLabel(page, text)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, page)
end

local function makeButton(page, text, callback)
	local b = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = COLORS.Surface,
		Text = text,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}, page)
	corner(b, 8)
	create("UIStroke", { Color = COLORS.Stroke, Thickness = 1 }, b)

	connect(b.MouseEnter, function()
		tween(b, 0.15, { BackgroundColor3 = COLORS.Stroke }, Enum.EasingStyle.Quad)
	end)
	connect(b.MouseLeave, function()
		tween(b, 0.15, { BackgroundColor3 = COLORS.Surface }, Enum.EasingStyle.Quad)
	end)
	connect(b.MouseButton1Click, callback)
	return b
end

local function makeToggle(page, text, callback)
	local state = false
	local b
	b = makeButton(page, text .. ": OFF", function()
		state = not state
		b.Text = text .. (state and ": ON" or ": OFF")
		b.TextColor3 = state and COLORS.Accent or COLORS.Text
		callback(state)
	end)
	return b
end

local function makeInput(page, placeholder)
	local box = create("TextBox", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = COLORS.Surface,
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = COLORS.SubText,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
	}, page)
	corner(box, 8)
	create("UIStroke", { Color = COLORS.Stroke, Thickness = 1 }, box)
	return box
end

----------------------------------------------------------------
-- Abas
----------------------------------------------------------------
local TAB_NAMES = { "Música", "X-Ray", "Skin", "Efeitos", "Invisível" }
local TAB_WIDTH = 84
local pages, tabButtons = {}, {}

local function selectTab(index)
	for i, page in ipairs(pages) do
		page.Visible = (i == index)
		tabButtons[i].TextColor3 = (i == index) and COLORS.Accent or COLORS.SubText
	end
	tween(tabUnderline, 0.3, { Position = UDim2.fromOffset((index - 1) * TAB_WIDTH, 26) })
end

for i, name in ipairs(TAB_NAMES) do
	pages[i] = makePage()
	local btn = create("TextButton", {
		Position = UDim2.fromOffset((i - 1) * TAB_WIDTH, 0),
		Size = UDim2.fromOffset(80, 24),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = COLORS.SubText,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}, tabBar)
	tabButtons[i] = btn
	connect(btn.MouseButton1Click, function()
		selectTab(i)
	end)
end

----------------------------------------------------------------
-- 1) MÚSICA
----------------------------------------------------------------
do
	local page = pages[1]
	local sound = create("Sound", {
		Name = "OkkotsuMusic",
		Looped = true,
		Volume = 0.5,
	}, SoundService)

	table.insert(cleanupTasks, function()
		sound:Stop()
		sound:Destroy()
	end)

	makeLabel(page, "Cole o ID do áudio (número ou rbxassetid://). Toca localmente no seu cliente.")
	local box = makeInput(page, "ID do áudio...")

	makeButton(page, "▶  Tocar", function()
		local id = tostring(box.Text):match("%d+")
		if not id then
			notify("ID inválido.")
			return
		end
		sound:Stop()
		sound.SoundId = "rbxassetid://" .. id
		sound:Play()
		notify("Tocando: " .. id)
	end)

	makeButton(page, "■  Parar", function()
		sound:Stop()
		notify("Música parada.")
	end)

	makeButton(page, "Volume +", function()
		sound.Volume = math.clamp(sound.Volume + 0.1, 0, 1)
		notify(("Volume: %d%%"):format(math.floor(sound.Volume * 100 + 0.5)))
	end)

	makeButton(page, "Volume -", function()
		sound.Volume = math.clamp(sound.Volume - 0.1, 0, 1)
		notify(("Volume: %d%%"):format(math.floor(sound.Volume * 100 + 0.5)))
	end)
end

----------------------------------------------------------------
-- 2) X-RAY (otimizado)
--  - usa LocalTransparencyModifier (não altera o Transparency real)
--  - processa em lotes para não travar
--  - ignora personagens, Terrain e partes já invisíveis
--  - novas partes são tratadas via DescendantAdded
----------------------------------------------------------------
do
	local page = pages[2]
	local XRAY_TRANSPARENCY = 0.65
	local BATCH = 200

	local xray = {
		on = false,
		token = 0,
		conn = nil,
		parts = setmetatable({}, { __mode = "k" }),
	}

	local function isCharacterPart(part)
		local model = part:FindFirstAncestorOfClass("Model")
		return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
	end

	local function apply(inst)
		if not inst:IsA("BasePart") or inst:IsA("Terrain") then
			return
		end
		if inst.Transparency >= 0.95 or xray.parts[inst] then
			return
		end
		if isCharacterPart(inst) then
			return
		end
		xray.parts[inst] = true
		inst.LocalTransparencyModifier = XRAY_TRANSPARENCY
	end

	local function setXray(state)
		xray.token += 1
		local token = xray.token

		if state then
			xray.on = true
			xray.conn = Workspace.DescendantAdded:Connect(function(d)
				if xray.on then
					apply(d)
				end
			end)
			task.spawn(function()
				local n = 0
				for _, d in ipairs(Workspace:GetDescendants()) do
					if xray.token ~= token then
						return
					end
					apply(d)
					n += 1
					if n % BATCH == 0 then
						task.wait()
					end
				end
				notify("X-Ray aplicado.")
			end)
		else
			xray.on = false
			if xray.conn then
				xray.conn:Disconnect()
				xray.conn = nil
			end
			task.spawn(function()
				local n = 0
				for part in pairs(xray.parts) do
					if xray.token ~= token then
						return
					end
					if part.Parent then
						part.LocalTransparencyModifier = 0
					end
					xray.parts[part] = nil
					n += 1
					if n % BATCH == 0 then
						task.wait()
					end
				end
				notify("X-Ray desligado.")
			end)
		end
	end

	table.insert(cleanupTasks, function()
		setXray(false)
	end)

	makeLabel(page, "Versão otimizada: aplica em lotes e só mexe no que é necessário.")
	makeToggle(page, "X-Ray", setXray)
end

----------------------------------------------------------------
-- 3) SKIN (copiar aparência de outro jogador)
----------------------------------------------------------------
do
	local page = pages[3]
	makeLabel(page, "Digite o Nick de um jogador do Roblox para copiar a aparência dele.")
	local box = makeInput(page, "Nick do jogador...")

	local function applyUserId(userId)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then
			notify("Personagem não encontrado.")
			return
		end

		local okDesc, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(userId)
		end)
		if not okDesc or not desc then
			notify("Não consegui obter a aparência.")
			return
		end

		local okApply = pcall(function()
			hum:ApplyDescription(desc)
		end)
		notify(okApply and "Aparência aplicada!" or "O jogo bloqueou a troca.")
	end

	makeButton(page, "Aplicar skin", function()
		local name = box.Text:gsub("%s+", "")
		if name == "" then
			notify("Digite um nick.")
			return
		end
		notify("Buscando...")
		task.spawn(function()
			local ok, userId = pcall(function()
				return Players:GetUserIdFromNameAsync(name)
			end)
			if not ok or not userId then
				notify("Jogador não encontrado.")
				return
			end
			applyUserId(userId)
		end)
	end)

	makeButton(page, "Restaurar minha skin", function()
		task.spawn(function()
			applyUserId(LocalPlayer.UserId)
		end)
	end)
end

----------------------------------------------------------------
-- 4) EFEITOS VISUAIS
----------------------------------------------------------------
local activeFx = {}

do
	local page = pages[4]

	local EFFECTS = {
		{ name = "Fogo Azul",    kind = "Fire", c1 = Color3.fromRGB(0, 140, 255),  c2 = Color3.fromRGB(0, 230, 255) },
		{ name = "Fogo Roxo",    kind = "Fire", c1 = Color3.fromRGB(150, 60, 255), c2 = Color3.fromRGB(225, 130, 255) },
		{ name = "Fogo Amarelo", kind = "Fire", c1 = Color3.fromRGB(255, 210, 40), c2 = Color3.fromRGB(255, 120, 20) },
		{ name = "Brilho",       kind = "Glow", c1 = Color3.fromRGB(255, 255, 200) },
		{ name = "Aura",         kind = "Aura", c1 = Color3.fromRGB(255, 170, 60), c2 = Color3.fromRGB(255, 96, 96) },
	}

	local function removeFx(char, def)
		if not char then
			return
		end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		for _, child in ipairs(root:GetChildren()) do
			if child.Name == "OkkotsuFX_" .. def.name then
				child:Destroy()
			end
		end
	end

	local function addFx(char, def)
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		removeFx(char, def)
		local tag = "OkkotsuFX_" .. def.name

		if def.kind == "Fire" then
			create("Fire", {
				Name = tag,
				Color = def.c1,
				SecondaryColor = def.c2,
				Heat = 9,
				Size = 7,
			}, root)
		elseif def.kind == "Glow" then
			create("PointLight", {
				Name = tag,
				Color = def.c1,
				Brightness = 3,
				Range = 16,
			}, root)
			create("Sparkles", {
				Name = tag,
				SparkleColor = def.c1,
			}, root)
		elseif def.kind == "Aura" then
			create("ParticleEmitter", {
				Name = tag,
				Color = ColorSequence.new(def.c1, def.c2),
				Rate = 30,
				Lifetime = NumberRange.new(0.8, 1.4),
				Speed = NumberRange.new(1, 3),
				SpreadAngle = Vector2.new(180, 180),
				Size = NumberSequence.new(0.6, 0),
				Transparency = NumberSequence.new(0.2, 1),
				LightEmission = 1,
			}, root)
		end
	end

	for _, def in ipairs(EFFECTS) do
		makeToggle(page, def.name, function(state)
			activeFx[def.name] = state or nil
			if state then
				addFx(LocalPlayer.Character, def)
			else
				removeFx(LocalPlayer.Character, def)
			end
		end)
	end

	-- reaplica ao renascer
	connect(LocalPlayer.CharacterAdded, function(char)
		char:WaitForChild("HumanoidRootPart", 10)
		for _, def in ipairs(EFFECTS) do
			if activeFx[def.name] then
				addFx(char, def)
			end
		end
	end)

	table.insert(cleanupTasks, function()
		for _, def in ipairs(EFFECTS) do
			removeFx(LocalPlayer.Character, def)
		end
	end)
end

----------------------------------------------------------------
-- 5) MODO INVISÍVEL
----------------------------------------------------------------
local invis = { on = false, saved = {} }

local function setCharInvisible(char, state)
	if not char then
		return
	end

	for _, d in ipairs(char:GetDescendants()) do
		if (d:IsA("BasePart") and d.Name ~= "HumanoidRootPart") or d:IsA("Decal") then
			if state then
				if invis.saved[d] == nil then
					invis.saved[d] = d.Transparency
				end
				d.Transparency = 1
			else
				local original = invis.saved[d]
				if original ~= nil then
					d.Transparency = original
				end
				invis.saved[d] = nil
			end
		end
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = state
			and Enum.HumanoidDisplayDistanceType.None
			or Enum.HumanoidDisplayDistanceType.Viewer
	end
end

do
	local page = pages[5]
	makeLabel(page, "Deixa seu personagem invisível. Ao renascer, o modo é reaplicado.")

	makeToggle(page, "Invisível", function(state)
		invis.on = state
		setCharInvisible(LocalPlayer.Character, state)
		notify(state and "Você está invisível." or "Você está visível.")
	end)

	connect(LocalPlayer.CharacterAdded, function(char)
		if invis.on then
			char:WaitForChild("HumanoidRootPart", 10)
			task.wait(0.6)
			setCharInvisible(char, true)
		end
	end)

	table.insert(cleanupTasks, function()
		setCharInvisible(LocalPlayer.Character, false)
	end)
end

----------------------------------------------------------------
-- Confirmação ao fechar
----------------------------------------------------------------
local confirm = create("Frame", {
	Name = "Confirm",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Visible = false,
	Active = true,
	ZIndex = 50,
}, main)
corner(confirm, 14)

local panel = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(300, 130),
	BackgroundColor3 = COLORS.Surface,
	ZIndex = 51,
}, confirm)
corner(panel, 12)
create("UIStroke", { Color = COLORS.Stroke, Thickness = 1 }, panel)
local panelScale = create("UIScale", { Scale = 0.9 }, panel)

create("TextLabel", {
	Position = UDim2.fromOffset(0, 16),
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	Text = "Fechar o script?",
	TextColor3 = COLORS.Text,
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	ZIndex = 52,
}, panel)

create("TextLabel", {
	Position = UDim2.fromOffset(16, 44),
	Size = UDim2.new(1, -32, 0, 30),
	BackgroundTransparency = 1,
	Text = "Todos os efeitos, música e modos serão desativados.",
	TextColor3 = COLORS.SubText,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	ZIndex = 52,
}, panel)

local function confirmButton(text, x, color)
	local b = create("TextButton", {
		Position = UDim2.new(0, x, 1, -42),
		Size = UDim2.fromOffset(124, 30),
		BackgroundColor3 = color,
		Text = text,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		ZIndex = 52,
	}, panel)
	corner(b, 8)
	return b
end

local yesBtn = confirmButton("Sim, fechar", 16, COLORS.Danger)
local noBtn = confirmButton("Não", 160, COLORS.Stroke)

local function showConfirm()
	confirm.Visible = true
	panelScale.Scale = 0.9
	tween(confirm, 0.25, { BackgroundTransparency = 0.4 }, Enum.EasingStyle.Quad)
	tween(panelScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
end

local function hideConfirm()
	local t = tween(confirm, 0.2, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
	tween(panelScale, 0.2, { Scale = 0.9 }, Enum.EasingStyle.Quad)
	t.Completed:Wait()
	confirm.Visible = false
end

local closing = false
local function closeHub()
	if closing then
		return
	end
	closing = true

	for _, fn in ipairs(cleanupTasks) do
		pcall(fn)
	end

	tween(scale, 0.35, { Scale = 0.88 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local t = tween(main, 0.35, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	t.Completed:Wait()

	for _, c in ipairs(connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	gui:Destroy()
end

connect(yesBtn.MouseButton1Click, closeHub)
connect(noBtn.MouseButton1Click, function()
	task.spawn(hideConfirm)
end)

connect(closeX.MouseButton1Click, showConfirm)

connect(closeX.MouseEnter, function()
	tween(closeX, 0.18, {
		BackgroundTransparency = 0,
		BackgroundColor3 = COLORS.Danger,
		TextColor3 = Color3.new(1, 1, 1),
	}, Enum.EasingStyle.Quad)
end)
connect(closeX.MouseLeave, function()
	tween(closeX, 0.18, { BackgroundTransparency = 1, TextColor3 = COLORS.SubText }, Enum.EasingStyle.Quad)
end)

-- Ponto de destaque pulsando
TweenService:Create(
	accentDot,
	TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ BackgroundTransparency = 0.6 }
):Play()

----------------------------------------------------------------
-- Arrastar a janela
----------------------------------------------------------------
do
	local dragging, dragStart, startPos

	connect(topbar.InputBegan, function(input)
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

	connect(UserInputService.InputChanged, function(input)
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

----------------------------------------------------------------
-- Tela de loading (rápida)
----------------------------------------------------------------
local function playLoading(onDone)
	local loader = create("CanvasGroup", {
		Name = "Loader",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 120),
		BackgroundColor3 = COLORS.Background,
		GroupTransparency = 1,
	}, gui)
	corner(loader, 14)
	create("UIStroke", { Color = COLORS.Stroke, Thickness = 1, Transparency = 0.2 }, loader)

	create("TextLabel", {
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = "Okkotsu Hub",
		TextColor3 = COLORS.Text,
		TextSize = 20,
		Font = Enum.Font.GothamBold,
	}, loader)

	local loadText = create("TextLabel", {
		Position = UDim2.fromOffset(0, 50),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = "Carregando...",
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		Font = Enum.Font.Gotham,
	}, loader)

	local track = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 82),
		Size = UDim2.new(1, -60, 0, 6),
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
	}, loader)
	corner(track, 3)

	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 3)
	create("UIGradient", { Color = ColorSequence.new(COLORS.Accent, COLORS.Accent2) }, fill)

	tween(loader, 0.25, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)

	task.spawn(function()
		local steps = {
			{ 0.35, "Carregando módulos..." },
			{ 0.7, "Preparando interface..." },
			{ 1, "Pronto!" },
		}
		for _, step in ipairs(steps) do
			tween(fill, 0.3, { Size = UDim2.fromScale(step[1], 1) }, Enum.EasingStyle.Quad)
			loadText.Text = step[2]
			task.wait(0.35)
		end
		local t = tween(loader, 0.25, { GroupTransparency = 1 }, Enum.EasingStyle.Quad)
		t.Completed:Wait()
		loader:Destroy()
		onDone()
	end)
end

local function playIntro()
	main.Visible = true
	selectTab(1)
	tween(main, 0.45, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)
	tween(scale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)
end

playLoading(playIntro)
