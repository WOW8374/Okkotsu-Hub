--[[
    Okkotsu Hub (Universal Version) — UI v2
    Interface refeita: janela com sombra, gradientes, sidebar com ícones,
    cartão do jogador, toasts empilhados, sliders com knob, toggles animados,
    tela de key / loading / confirmação redesenhadas.
    Atalho: RightControl = minimizar / restaurar
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local VirtualUser      = game:GetService("VirtualUser")

local HUB_NAME = "Okkotsu Hub (Universal Version)"
local LP       = Players.LocalPlayer

local THEME = {
    Bg      = Color3.fromRGB(12, 12, 18),
    Panel   = Color3.fromRGB(22, 22, 32),
    Panel2  = Color3.fromRGB(32, 32, 46),
    Panel3  = Color3.fromRGB(42, 42, 60),
    Accent  = Color3.fromRGB(150, 100, 255),
    Accent2 = Color3.fromRGB(232, 108, 200),
    Text    = Color3.fromRGB(238, 238, 248),
    Sub     = Color3.fromRGB(135, 135, 158),
    Off     = Color3.fromRGB(52, 52, 72),
    Good    = Color3.fromRGB(90, 220, 130),
    Bad     = Color3.fromRGB(235, 75, 90),
}

----------------------------------------------------------------
-- Utilidades
----------------------------------------------------------------
local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end

local function stroke(o, color, thick, trans)
    return new("UIStroke", {
        Color = color or THEME.Accent, Thickness = thick or 1, Transparency = trans or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

local function gradient(o, c1, c2, rot)
    return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 0}, o)
end

local function tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function shadow(parent, z)
    return new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 56, 1, 56), BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = z or 1,
    }, parent)
end

local function hover(b, base, over, target)
    target = target or b
    b.MouseEnter:Connect(function() tween(target, 0.15, {BackgroundColor3 = over}) end)
    b.MouseLeave:Connect(function() tween(target, 0.15, {BackgroundColor3 = base}) end)
end

local function getHum() local c = LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart") end

local function getGuiParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then return ui end
    local core = game:GetService("CoreGui")
    if pcall(function() local t = Instance.new("Folder") t.Parent = core t:Destroy() end) then
        return core
    end
    return LP:WaitForChild("PlayerGui")
end

local parent = getGuiParent()
local old = parent:FindFirstChild("OkkotsuHub")
if old then old:Destroy() end
local oldBlur = Lighting:FindFirstChild("OkkBlur")
if oldBlur then oldBlur:Destroy() end

local gui = new("ScreenGui", {
    Name = "OkkotsuHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, parent)

-- Blur de fundo (usado na tela de key)
local blur
local function setBlur(size)
    if not blur then blur = new("BlurEffect", {Name = "OkkBlur", Size = 0}, Lighting) end
    tween(blur, 0.5, {Size = size})
end
local function clearBlur()
    if blur then
        local b = blur
        blur = nil
        tween(b, 0.4, {Size = 0})
        task.delay(0.45, function() b:Destroy() end)
    end
end

----------------------------------------------------------------
-- Sistema de key (bloqueia o resto do script até validar)
----------------------------------------------------------------
do
    -- Jogadores com privilégio: entram sem key e sem prazo.
    -- Coloque o UserId (número da conta), um por linha, no formato:  [123456789] = true,
    local PRIVILEGED = {
         [4427424158] = true,
    }

    local VALID_KEY  = "GLOBAL_866328948"
    local EXPIRES_AT = 1792906284 -- 25/10/2026 02:31:24 (Brasília) = exatamente 1 semana depois

    if not PRIVILEGED[LP.UserId] then

    local function nowTime()
        local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
        if ok and type(t) == "number" then return t end
        return os.time()
    end

    setBlur(18)

    local kwrap = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 300,
    }, gui)
    shadow(kwrap, 300)
    local card = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Bg, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 301,
    }, kwrap)
    corner(card, 16)
    gradient(stroke(card, Color3.new(1, 1, 1), 1, 0.4), THEME.Accent, THEME.Accent2, 45)
    gradient(card, Color3.fromRGB(20, 17, 32), Color3.fromRGB(11, 11, 17), 90)

    local banner = new("Frame", {Size = UDim2.new(1, 0, 0, 84), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, BorderSizePixel = 0}, card)
    gradient(banner, THEME.Accent, THEME.Accent2, 25)
    local logo = new("TextLabel", {
        Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "◈", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 26,
    }, card)
    corner(logo, 12)
    gradient(logo, THEME.Accent, THEME.Accent2, 45)
    new("TextLabel", {
        Position = UDim2.fromOffset(76, 20), Size = UDim2.new(1, -90, 0, 24), BackgroundTransparency = 1,
        Text = "Okkotsu Hub", TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    new("TextLabel", {
        Position = UDim2.fromOffset(76, 44), Size = UDim2.new(1, -90, 0, 18), BackgroundTransparency = 1,
        Text = "Universal Version  •  Verificação de key", TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    local info = new("TextLabel", {
        Position = UDim2.fromOffset(20, 98), Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1,
        Text = "Digite sua key para continuar", TextColor3 = THEME.Sub,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local input = new("TextBox", {
        Position = UDim2.fromOffset(20, 122), Size = UDim2.new(1, -40, 0, 38), BackgroundColor3 = THEME.Panel,
        Text = "", PlaceholderText = "🔑  Cole sua key aqui", PlaceholderColor3 = THEME.Sub, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    corner(input, 10)
    new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, input)
    local inStroke = stroke(input, THEME.Accent, 1, 1)
    input.Focused:Connect(function() tween(inStroke, 0.2, {Transparency = 0.2}) end)
    input.FocusLost:Connect(function() tween(inStroke, 0.2, {Transparency = 1}) end)

    local confirm = new("TextButton", {
        Position = UDim2.fromOffset(20, 172), Size = UDim2.new(0.5, -26, 0, 36), BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "Validar", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
    }, card)
    corner(confirm, 10)
    gradient(confirm, THEME.Accent, THEME.Accent2, 20)
    confirm.MouseEnter:Connect(function() tween(confirm, 0.15, {BackgroundTransparency = 0.12}) end)
    confirm.MouseLeave:Connect(function() tween(confirm, 0.15, {BackgroundTransparency = 0}) end)
    local cancel = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 172), Size = UDim2.new(0.5, -26, 0, 36),
        BackgroundColor3 = THEME.Panel2, Text = "Cancelar", TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
    }, card)
    corner(cancel, 10)
    hover(cancel, THEME.Panel2, THEME.Panel3)

    local getKey = new("TextButton", {
        Position = UDim2.fromOffset(20, 220), Size = UDim2.new(1, -40, 0, 32), BackgroundColor3 = THEME.Panel,
        Text = "💬  Pegar a key no Discord (copiar link)", TextColor3 = THEME.Accent,
        Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false,
    }, card)
    corner(getKey, 10)
    hover(getKey, THEME.Panel, THEME.Panel2)
    getKey.MouseButton1Click:Connect(function()
        local fn = setclipboard or toclipboard
        if fn then
            pcall(fn, "https://discord.gg/J9Z9N6qsEc")
            info.Text = "Link copiado! A key está no chat do Discord"
            info.TextColor3 = THEME.Sub
        else
            info.Text = "https://discord.gg/J9Z9N6qsEc"
            info.TextColor3 = THEME.Sub
        end
    end)

    tween(kwrap, 0.45, {Size = UDim2.fromOffset(360, 272)}, Enum.EasingStyle.Back)

    local function shake()
        for _, dx in ipairs({9, -9, 6, -6, 0}) do
            tween(kwrap, 0.05, {Position = UDim2.new(0.5, dx, 0.5, 0)})
            task.wait(0.05)
        end
    end

    local result = nil -- true = liberado | false = cancelado/expirado
    local function submit()
        if nowTime() >= EXPIRES_AT then
            info.Text = "Esta key expirou."
            info.TextColor3 = THEME.Bad
            shake()
            task.wait(1.2)
            result = false
            return
        end
        if input.Text:gsub("^%s+", ""):gsub("%s+$", "") == VALID_KEY then
            info.Text = "Key válida!"
            info.TextColor3 = THEME.Good
            task.wait(0.6)
            result = true
        else
            info.Text = "Key inválida"
            info.TextColor3 = THEME.Bad
            shake()
        end
    end
    confirm.MouseButton1Click:Connect(submit)
    input.FocusLost:Connect(function(enter) if enter then submit() end end)
    cancel.MouseButton1Click:Connect(function() result = false end)

    if nowTime() >= EXPIRES_AT then
        info.Text = "Esta key expirou."
        info.TextColor3 = THEME.Bad
    end

    while result == nil and gui.Parent do task.wait(0.1) end

    if result ~= true then
        clearBlur()
        gui:Destroy()
        return
    end

    tween(kwrap, 0.3, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.35)
    kwrap:Destroy()

    end -- fim da checagem de privilégio
end

----------------------------------------------------------------
-- Estado
----------------------------------------------------------------
local S = {
    speedOn = false, speed = 50,
    jumpOn = false,  jump = 100,
    infJump = false,
    fly = false, flySpeed = 60,
    noclip = false,
    esp = false,
    fullbright = false,
    fov = 70,
    antiAfk = false,
}

----------------------------------------------------------------
-- Notificações (toasts empilhados no canto superior direito)
----------------------------------------------------------------
local toastHolder = new("Frame", {
    Name = "Toasts", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16),
    Size = UDim2.fromOffset(270, 420), BackgroundTransparency = 1, ZIndex = 100,
}, gui)
new("UIListLayout", {
    Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
}, toastHolder)
local toastN = 0

local function notify(text)
    toastN += 1
    local wrap = new("Frame", {Size = UDim2.fromOffset(260, 44), BackgroundTransparency = 1, LayoutOrder = toastN}, toastHolder)
    local card = new("Frame", {
        Position = UDim2.fromOffset(290, 0), Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, wrap)
    corner(card, 10)
    stroke(card, THEME.Accent, 1, 0.6)
    local bar = new("Frame", {Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, card)
    gradient(bar, THEME.Accent, THEME.Accent2, 90)
    new("TextLabel", {
        Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -24, 1, -3), BackgroundTransparency = 1,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)
    local prog = new("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, card)
    gradient(prog, THEME.Accent, THEME.Accent2, 0)
    tween(card, 0.4, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back)
    tween(prog, 2.4, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
    task.delay(2.5, function()
        tween(card, 0.3, {Position = UDim2.fromOffset(290, 0)})
        task.wait(0.35)
        wrap:Destroy()
    end)
end

----------------------------------------------------------------
-- Janela principal
----------------------------------------------------------------
local WIDTH, HEIGHT = 620, 390
local vp = workspace.CurrentCamera.ViewportSize

local root = new("Frame", {
    Name = "Root", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
}, gui)
local uiScale = new("UIScale", {
    Scale = math.clamp(math.min(vp.X / (WIDTH + 30), vp.Y / (HEIGHT + 30)), 0.5, 1),
}, root)
shadow(root, 0)

local main = new("Frame", {
    Name = "Main", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0, ClipsDescendants = true,
}, root)
corner(main, 16)
gradient(main, Color3.fromRGB(19, 16, 30), Color3.fromRGB(10, 10, 16), 90)
gradient(stroke(main, Color3.new(1, 1, 1), 1, 0.55), THEME.Accent, THEME.Accent2, 45)

-- Cabeçalho
local top = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, main)
gradient(top, Color3.fromRGB(28, 24, 44), Color3.fromRGB(20, 20, 30), 0)
local topLine = new("Frame", {
    AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, BackgroundTransparency = 0.35,
}, top)
gradient(topLine, THEME.Accent, THEME.Accent2, 0)

local logoBox = new("TextLabel", {
    Position = UDim2.fromOffset(12, 8), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.new(1, 1, 1),
    Text = "◈", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 17,
}, top)
corner(logoBox, 9)
gradient(logoBox, THEME.Accent, THEME.Accent2, 45)
new("TextLabel", {
    Position = UDim2.fromOffset(52, 6), Size = UDim2.new(1, -150, 0, 20), BackgroundTransparency = 1,
    Text = "Okkotsu Hub", TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)
new("TextLabel", {
    Position = UDim2.fromOffset(52, 24), Size = UDim2.new(1, -150, 0, 14), BackgroundTransparency = 1,
    Text = "Universal Version  •  RightCtrl minimiza", TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local function topButton(text, xOffset, hoverColor)
    local b = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOffset, 0.5, 0),
        Size = UDim2.fromOffset(28, 28), BackgroundColor3 = THEME.Panel2,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 16,
        AutoButtonColor = false,
    }, top)
    corner(b, 8)
    hover(b, THEME.Panel2, hoverColor)
    return b
end
local btnMin   = topButton("–", -46, THEME.Accent)
local btnClose = topButton("×", -12, THEME.Bad)

-- Sidebar
local sidebar = new("Frame", {
    Position = UDim2.fromOffset(0, 46), Size = UDim2.new(0, 150, 1, -46),
    BackgroundColor3 = THEME.Panel, BackgroundTransparency = 0.25, BorderSizePixel = 0,
}, main)
new("Frame", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.92, BorderSizePixel = 0,
}, sidebar)

local tabList = new("ScrollingFrame", {
    Size = UDim2.new(1, -1, 1, -62), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, sidebar)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, tabList)
new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, tabList)

-- Cartão do jogador
local userCard = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8), Size = UDim2.new(1, -16, 0, 44),
    BackgroundColor3 = THEME.Panel2, BorderSizePixel = 0,
}, sidebar)
corner(userCard, 10)
stroke(userCard, Color3.new(1, 1, 1), 1, 0.92)
local avatar = new("ImageLabel", {
    Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = THEME.Off, Image = "",
}, userCard)
corner(avatar, 16)
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if ok and img then avatar.Image = img end
end)
new("TextLabel", {
    Position = UDim2.fromOffset(44, 6), Size = UDim2.new(1, -50, 0, 18), BackgroundTransparency = 1,
    Text = LP.DisplayName, TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, userCard)
new("TextLabel", {
    Position = UDim2.fromOffset(44, 23), Size = UDim2.new(1, -50, 0, 14), BackgroundTransparency = 1,
    Text = "@" .. LP.Name, TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, userCard)

-- Área de conteúdo
local content = new("Frame", {
    Position = UDim2.fromOffset(162, 56), Size = UDim2.new(1, -174, 1, -66), BackgroundTransparency = 1,
}, main)

----------------------------------------------------------------
-- Arrastar
----------------------------------------------------------------
local function makeDraggable(handle, target)
    local dragging, startInput, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end
makeDraggable(top, root)

----------------------------------------------------------------
-- Componentes
----------------------------------------------------------------
local function rowBase(scroll, h)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, scroll)
    corner(row, 10)
    local st = stroke(row, Color3.new(1, 1, 1), 1, 0.93)
    return row, st
end

local function Toggle(scroll, text, cb)
    local row, st = rowBase(scroll, 40)
    new("TextLabel", {
        Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local accentBar = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, row)
    corner(accentBar, 2)
    gradient(accentBar, THEME.Accent, THEME.Accent2, 90)
    local track = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 22), BackgroundColor3 = THEME.Off, BorderSizePixel = 0,
    }, row)
    corner(track, 11)
    local knob = new("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, track)
    corner(knob, 8)
    local hit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 2}, row)
    hit.MouseEnter:Connect(function() tween(row, 0.15, {BackgroundColor3 = THEME.Panel2}) end)
    hit.MouseLeave:Connect(function() tween(row, 0.15, {BackgroundColor3 = THEME.Panel}) end)

    local state = false
    local function set(v)
        state = v
        tween(track, 0.2, {BackgroundColor3 = v and THEME.Accent or THEME.Off})
        tween(knob, 0.25, {Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)}, Enum.EasingStyle.Back)
        tween(accentBar, 0.25, {Size = UDim2.fromOffset(3, v and 20 or 0)})
        tween(st, 0.25, {Color = v and THEME.Accent or Color3.new(1, 1, 1), Transparency = v and 0.55 or 0.93})
        task.spawn(cb, v)
    end
    hit.MouseButton1Click:Connect(function() set(not state) end)
    return set
end

local function Slider(scroll, text, min, max, default, cb)
    local row = rowBase(scroll, 56)
    new("TextLabel", {
        Position = UDim2.fromOffset(16, 6), Size = UDim2.new(1, -90, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local valueLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6), Size = UDim2.fromOffset(52, 20),
        BackgroundColor3 = THEME.Panel2, Text = tostring(default), TextColor3 = THEME.Accent,
        Font = Enum.Font.GothamBold, TextSize = 12,
    }, row)
    corner(valueLabel, 6)
    local bar = new("Frame", {Position = UDim2.new(0, 16, 0, 38), Size = UDim2.new(1, -32, 0, 6), BackgroundColor3 = THEME.Off, BorderSizePixel = 0}, row)
    corner(bar, 3)
    local startRel = math.clamp((default - min) / (max - min), 0, 1)
    local fill = new("Frame", {Size = UDim2.fromScale(startRel, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, bar)
    corner(fill, 3)
    gradient(fill, THEME.Accent, THEME.Accent2, 0)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(startRel, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, bar)
    corner(knob, 7)
    stroke(knob, THEME.Accent, 2, 0)
    local hit = new("TextButton", {
        Position = UDim2.fromOffset(10, 28), Size = UDim2.new(1, -20, 0, 26), BackgroundTransparency = 1, Text = "",
    }, row)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel + 0.5)
        tween(fill, 0.06, {Size = UDim2.fromScale(rel, 1)})
        tween(knob, 0.06, {Position = UDim2.new(rel, 0, 0.5, 0)})
        valueLabel.Text = tostring(val)
        cb(val)
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            tween(knob, 0.15, {Size = UDim2.fromOffset(18, 18)}, Enum.EasingStyle.Back)
            update(i.Position.X)
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            tween(knob, 0.2, {Size = UDim2.fromOffset(14, 14)})
        end
    end)
end

local function Button(scroll, text, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.Panel, Text = text,
        TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, scroll)
    corner(b, 10)
    local st = stroke(b, Color3.new(1, 1, 1), 1, 0.93)
    new("UIPadding", {PaddingLeft = UDim.new(0, 16)}, b)
    local arrow = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0), Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1, Text = "›", TextColor3 = THEME.Sub, Font = Enum.Font.GothamBold, TextSize = 18,
    }, b)
    b.MouseEnter:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = THEME.Panel2})
        tween(st, 0.15, {Color = THEME.Accent, Transparency = 0.6})
        tween(arrow, 0.15, {TextColor3 = THEME.Accent})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = THEME.Panel})
        tween(st, 0.15, {Color = Color3.new(1, 1, 1), Transparency = 0.93})
        tween(arrow, 0.15, {TextColor3 = THEME.Sub})
    end)
    b.MouseButton1Click:Connect(function()
        tween(b, 0.08, {BackgroundColor3 = THEME.Accent})
        task.delay(0.1, function() tween(b, 0.3, {BackgroundColor3 = THEME.Panel2}) end)
        task.spawn(cb)
    end)
    return b
end

local function TextInput(scroll, placeholder)
    local box = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.Panel, Text = "",
        PlaceholderText = placeholder, PlaceholderColor3 = THEME.Sub, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13, ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, scroll)
    corner(box, 10)
    new("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12)}, box)
    local st = stroke(box, Color3.new(1, 1, 1), 1, 0.93)
    box.Focused:Connect(function() tween(st, 0.2, {Color = THEME.Accent, Transparency = 0.2}) end)
    box.FocusLost:Connect(function() tween(st, 0.2, {Color = Color3.new(1, 1, 1), Transparency = 0.93}) end)
    return box
end

local function Section(scroll, text)
    local l = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "▸ " .. text,
        TextColor3 = THEME.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, scroll)
    new("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.93, BorderSizePixel = 0,
    }, l)
    return l
end

----------------------------------------------------------------
-- Abas
----------------------------------------------------------------
local pages, tabButtons = {}, {}
local currentTab
local selectTab

local TAB_ALIAS = {
    ["Movimento"]  = "Jogador",
    ["Personagem"] = "Jogador",
    ["Câmera"]     = "Mundo",
    ["Jogadores"]  = "Visual",
    ["Utilidades"] = "Misc",
    ["Efeitos"]    = "Aparência",
}
local TAB_ORDER = {
    ["Jogador"] = 1, ["Teleporte"] = 2, ["Visual"] = 3, ["Mundo"] = 4,
    ["Aparência"] = 5, ["Música"] = 6, ["Misc"] = 7, ["Discord"] = 8,
}
local TAB_ICON = {
    ["Buscar"] = "🔍", ["Jogador"] = "🏃", ["Teleporte"] = "📍", ["Visual"] = "👁", ["Mundo"] = "🌍",
    ["Aparência"] = "✨", ["Música"] = "🎵", ["Misc"] = "⚙", ["Discord"] = "💬",
}

local function createTab(name)
    name = TAB_ALIAS[name] or name
    if pages[name] then
        return pages[name]:FindFirstChildOfClass("ScrollingFrame")
    end
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = THEME.Panel3, BackgroundTransparency = 1,
        LayoutOrder = TAB_ORDER[name] or 99, Text = "", AutoButtonColor = false,
    }, tabList)
    corner(btn, 9)
    local icon = new("TextLabel", {
        Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(22, 34), BackgroundTransparency = 1,
        Text = TAB_ICON[name] or "•", TextSize = 14, Font = Enum.Font.GothamMedium, TextColor3 = THEME.Sub,
    }, btn)
    local label = new("TextLabel", {
        Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, btn)
    local indicator = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, btn)
    corner(indicator, 2)
    gradient(indicator, THEME.Accent, THEME.Accent2, 90)

    local page = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false}, content)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = name,
        TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left,
    }, page)
    local scroll = new("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 1, -54), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.Accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, page)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
    new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6)}, scroll)

    -- Marca d'água
    new("TextLabel", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, 0), Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1, Text = HUB_NAME, TextColor3 = THEME.Accent, TextTransparency = 0.55,
        Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    }, page)

    pages[name] = page
    tabButtons[name] = {btn = btn, indicator = indicator, label = label, icon = icon}

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then tween(btn, 0.15, {BackgroundTransparency = 0.6}) end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then tween(btn, 0.15, {BackgroundTransparency = 1}) end
    end)
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    return scroll
end

function selectTab(name)
    if currentTab == name then return end
    if currentTab then
        local o = tabButtons[currentTab]
        tween(o.btn, 0.2, {BackgroundTransparency = 1})
        tween(o.label, 0.2, {TextColor3 = THEME.Sub})
        tween(o.icon, 0.2, {TextColor3 = THEME.Sub})
        tween(o.indicator, 0.2, {Size = UDim2.fromOffset(3, 0)})
        local oldPage = pages[currentTab]
        tween(oldPage, 0.15, {GroupTransparency = 1})
        task.delay(0.15, function() if currentTab ~= nil and pages[currentTab] ~= oldPage then oldPage.Visible = false end end)
    end
    currentTab = name
    local n = tabButtons[name]
    tween(n.btn, 0.2, {BackgroundTransparency = 0.35})
    tween(n.label, 0.2, {TextColor3 = THEME.Text})
    tween(n.icon, 0.2, {TextColor3 = THEME.Text})
    tween(n.indicator, 0.25, {Size = UDim2.fromOffset(3, 18)}, Enum.EasingStyle.Back)
    local p = pages[name]
    p.Position = UDim2.fromOffset(0, 14)
    p.Visible = true
    tween(p, 0.3, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
end

----------------------------------------------------------------
-- Funcionalidades
----------------------------------------------------------------
connect(RunService.Heartbeat, function()
    local hum = getHum()
    if not hum then return end
    if S.speedOn then hum.WalkSpeed = S.speed end
    if S.jumpOn then
        hum.UseJumpPower = true
        hum.JumpPower = S.jump
    end
end)

connect(UIS.JumpRequest, function()
    if S.infJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

connect(RunService.Stepped, function()
    if S.noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- Fly (WASD / analógico + Espaço sobe, Ctrl desce)
local flyConn, bv, bg
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
end
local function startFly()
    stopFly()
    local hrp, hum = getHRP(), getHum()
    if not hrp or not hum then return end
    bv = new("BodyVelocity", {MaxForce = Vector3.one * 1e9, Velocity = Vector3.zero}, hrp)
    bg = new("BodyGyro", {MaxTorque = Vector3.one * 1e9, P = 9e4}, hrp)
    hum.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        local r, h = getHRP(), getHum()
        if not r or not h or not bv or not bg then return end
        local cf = workspace.CurrentCamera.CFrame
        local move = cf:VectorToObjectSpace(h.MoveDirection)
        local vel = cf.RightVector * move.X + cf.LookVector * (-move.Z)
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then vel -= Vector3.yAxis end
        bv.Velocity = vel * S.flySpeed
        bg.CFrame = cf
    end)
end
connect(LP.CharacterAdded, function()
    if S.fly then task.wait(1) startFly() end
end)

local function findPlayer(txt)
    txt = txt:lower()
    if txt == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and (p.Name:lower():sub(1, #txt) == txt or p.DisplayName:lower():sub(1, #txt) == txt) then
            return p
        end
    end
end

-- ESP
local espFolder = new("Folder", {Name = "ESP"}, gui)
local function addESP(p)
    if p == LP then return end
    local function apply(char)
        if not char then return end
        local o = espFolder:FindFirstChild(p.Name)
        if o then o:Destroy() end
        new("Highlight", {
            Name = p.Name, Adornee = char, FillColor = THEME.Accent, OutlineColor = Color3.new(1, 1, 1),
            FillTransparency = 0.6, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Enabled = S.esp,
        }, espFolder)
    end
    apply(p.Character)
    connect(p.CharacterAdded, apply)
end
for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
connect(Players.PlayerAdded, addESP)
connect(Players.PlayerRemoving, function(p)
    local h = espFolder:FindFirstChild(p.Name)
    if h then h:Destroy() end
end)

local origLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
}

connect(LP.Idled, function()
    if S.antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local cleanups = {}
local function onCleanup(f) table.insert(cleanups, f) end
local function cam() return workspace.CurrentCamera end
local DEFAULT_GRAVITY = workspace.Gravity

local function copy(text, label)
    local fn = setclipboard or toclipboard
    if fn then
        pcall(fn, text)
        notify((label or "Texto") .. " copiado")
    else
        notify("Área de transferência indisponível")
    end
end

local function tpTo(cf)
    local r = getHRP()
    if r then r.CFrame = cf end
end

----------------------------------------------------------------
-- Aba: Jogador (Jogador + Movimento + Personagem)
----------------------------------------------------------------
local tPlayer = createTab("Jogador")
Section(tPlayer, "Jogador")
local setSpeed = Toggle(tPlayer, "Speed", function(v) S.speedOn = v
    if not v then local h = getHum() if h then h.WalkSpeed = 16 end end
end)
Slider(tPlayer, "Velocidade", 16, 300, S.speed, function(v) S.speed = v end)
local setJump = Toggle(tPlayer, "Super Pulo", function(v) S.jumpOn = v
    if not v then local h = getHum() if h then h.JumpPower = 50 end end
end)
Slider(tPlayer, "Força do pulo", 50, 400, S.jump, function(v) S.jump = v end)
Toggle(tPlayer, "Pulo infinito", function(v) S.infJump = v end)
Slider(tPlayer, "Gravidade", 0, 300, math.floor(workspace.Gravity), function(v) workspace.Gravity = v end)

local tMove = createTab("Movimento")
Section(tMove, "Movimento")
local setFly = Toggle(tMove, "Fly", function(v)
    S.fly = v
    if v then startFly() else stopFly() end
end)
Slider(tMove, "Velocidade do Fly", 10, 300, S.flySpeed, function(v) S.flySpeed = v end)
local setNoclip = Toggle(tMove, "Noclip", function(v) S.noclip = v end)

do
    local t = createTab("Personagem")
    Section(t, "Personagem")

    Toggle(t, "Vida infinita (client)", function(v)
        S.god = v
        if not v then
            local h = getHum()
            if h then h.MaxHealth = 100 h.Health = 100 end
        end
    end)
    Toggle(t, "Auto-curar", function(v) S.autoheal = v end)
    Toggle(t, "Auto-pular", function(v) S.autojump = v end)
    connect(RunService.Heartbeat, function()
        local h = getHum()
        if not h then return end
        if S.god then
            h.MaxHealth = math.huge
            h.Health = math.huge
        elseif S.autoheal and h.Health < h.MaxHealth then
            h.Health = h.MaxHealth
        end
        if S.autojump and h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
    end)

    local spinSpeed = 10
    Toggle(t, "Girar personagem", function(v) S.spin = v end)
    Slider(t, "Velocidade do giro", 1, 50, spinSpeed, function(v) spinSpeed = v end)
    connect(RunService.RenderStepped, function()
        local r = getHRP()
        if S.spin and r then r.CFrame *= CFrame.Angles(0, math.rad(spinSpeed), 0) end
    end)

    Toggle(t, "Congelar personagem", function(v)
        local r = getHRP()
        if r then r.Anchored = v end
    end)
    onCleanup(function() local r = getHRP() if r then r.Anchored = false end end)

    Toggle(t, "Sprint (segurar Shift)", function(v) S.sprint = v end)
    local wasSprint = false
    connect(RunService.Heartbeat, function()
        local h = getHum()
        if not h then return end
        local active = S.sprint and UIS:IsKeyDown(Enum.KeyCode.LeftShift)
        if active then
            h.WalkSpeed = math.max(S.speedOn and S.speed or 16, 40)
            wasSprint = true
        elseif wasSprint then
            wasSprint = false
            if not S.speedOn then h.WalkSpeed = 16 end
        end
    end)

    Button(t, "Dash (impulso para frente)", function()
        local r = getHRP()
        if r then r.AssemblyLinearVelocity = r.CFrame.LookVector * 120 + Vector3.new(0, 20, 0) end
    end)
    Button(t, "Sentar", function()
        local h = getHum()
        if h then h.Sit = true end
    end)
    Toggle(t, "Remover animações", function(v)
        local c = LP.Character
        local a = c and c:FindFirstChild("Animate")
        if a then a.Disabled = v end
        if v then
            local h = getHum()
            local an = h and h:FindFirstChildOfClass("Animator")
            if an then for _, tr in ipairs(an:GetPlayingAnimationTracks()) do tr:Stop() end end
        end
    end)
    onCleanup(function()
        local c = LP.Character
        local a = c and c:FindFirstChild("Animate")
        if a then a.Disabled = false end
    end)
end

----------------------------------------------------------------
-- Aba: Visual
----------------------------------------------------------------
local tVisual = createTab("Visual")
Section(tVisual, "Visual")
local viewBox = TextInput(tVisual, "Nome do jogador (parcial)")
Toggle(tVisual, "View (espectar)", function(v)
    if v then
        local target = findPlayer(viewBox.Text)
        local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            notify("Vendo: " .. target.DisplayName)
        else
            notify("Jogador não encontrado")
        end
    else
        local hum = getHum()
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end
end)
Toggle(tVisual, "ESP (destacar jogadores)", function(v)
    S.esp = v
    for _, h in ipairs(espFolder:GetChildren()) do h.Enabled = v end
end)
Toggle(tVisual, "Fullbright", function(v)
    S.fullbright = v
    if v then
        Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 2, 14, false
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    else
        for k, val in pairs(origLight) do Lighting[k] = val end
    end
end)
Slider(tVisual, "Campo de visão (FOV)", 30, 120, S.fov, function(v)
    S.fov = v
    workspace.CurrentCamera.FieldOfView = v
end)

----------------------------------------------------------------
-- Aba: Teleporte
----------------------------------------------------------------
do
    local t = createTab("Teleporte")
    Section(t, "Teleporte")

    Toggle(t, "Click TP (Ctrl + clique)", function(v) S.clickTP = v end)
    local mouse = LP:GetMouse()
    connect(mouse.Button1Down, function()
        if S.clickTP and UIS:IsKeyDown(Enum.KeyCode.LeftControl) and mouse.Hit then
            tpTo(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
        end
    end)

    local tpBox = TextInput(t, "Nome do jogador (parcial)")
    Button(t, "Teleportar até o jogador", function()
        local p = findPlayer(tpBox.Text)
        local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            tpTo(r.CFrame * CFrame.new(0, 0, 3))
            notify("TP: " .. p.DisplayName)
        else
            notify("Jogador não encontrado")
        end
    end)

    Button(t, "TP para jogador aleatório", function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(list, p)
            end
        end
        if #list == 0 then return notify("Nenhum jogador disponível") end
        local p = list[math.random(#list)]
        tpTo(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        notify("TP: " .. p.DisplayName)
    end)

    local saved
    Button(t, "Salvar posição", function()
        local r = getHRP()
        if r then saved = r.CFrame notify("Posição salva") end
    end)
    Button(t, "Voltar à posição salva", function()
        if saved then tpTo(saved) else notify("Nenhuma posição salva") end
    end)

    Button(t, "Ir ao spawn", function()
        local sp = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if sp then tpTo(sp.CFrame + Vector3.new(0, 4, 0)) else notify("Spawn não encontrado") end
    end)

    Button(t, "Subir 50 studs", function()
        local r = getHRP()
        if r then r.CFrame += Vector3.new(0, 50, 0) end
    end)

    local coordBox = TextInput(t, "Coordenadas: x, y, z")
    Button(t, "Teleportar para coordenadas", function()
        local x, y, z = coordBox.Text:match("(-?[%d%.]+)%s*,%s*(-?[%d%.]+)%s*,%s*(-?[%d%.]+)")
        if x then tpTo(CFrame.new(tonumber(x), tonumber(y), tonumber(z))) else notify("Formato: x, y, z") end
    end)
end

----------------------------------------------------------------
-- Aba: Mundo (+ Câmera)
----------------------------------------------------------------
do
    local t = createTab("Mundo")
    Section(t, "Mundo")

    Slider(t, "Hora do dia", 0, 24, math.floor(Lighting.ClockTime), function(v) Lighting.ClockTime = v end)
    Toggle(t, "Ciclo dia/noite", function(v) S.cycle = v end)
    connect(RunService.Heartbeat, function(dt)
        if S.cycle then Lighting.ClockTime = (Lighting.ClockTime + dt * 0.5) % 24 end
    end)
    Slider(t, "Brilho", 0, 10, math.clamp(math.floor(Lighting.Brightness), 0, 10), function(v) Lighting.Brightness = v end)

    local origFog = {Lighting.FogStart, Lighting.FogEnd}
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    local origDensity = atm and atm.Density
    Toggle(t, "Sem neblina", function(v)
        if v then
            Lighting.FogStart, Lighting.FogEnd = 1e6, 1e6
            if atm then atm.Density = 0 end
        else
            Lighting.FogStart, Lighting.FogEnd = origFog[1], origFog[2]
            if atm then atm.Density = origDensity end
        end
    end)

    local origShadows = Lighting.GlobalShadows
    Toggle(t, "Sem sombras", function(v) Lighting.GlobalShadows = (not v) and origShadows or false end)

    Toggle(t, "Remover pós-processamento", function(v)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then e.Enabled = not v end
        end
    end)

    -- X-Ray (processa em lotes e acompanha peças novas)
    local xrayParts, xrayConn, xrayToken = {}, nil, 0
    local function xrayValid(p)
        if not p:IsA("BasePart") or p:IsA("Terrain") then return false end
        if p.Transparency >= 1 then return false end
        local char = LP.Character
        if char and p:IsDescendantOf(char) then return false end
        local par = p.Parent
        if par and par:FindFirstChildOfClass("Humanoid") then return false end
        return true
    end
    Toggle(t, "X-Ray (paredes transparentes)", function(v)
        xrayToken += 1
        local token = xrayToken
        if xrayConn then xrayConn:Disconnect() xrayConn = nil end
        if v then
            xrayConn = workspace.DescendantAdded:Connect(function(d)
                if token == xrayToken and xrayValid(d) then
                    xrayParts[d] = true
                    d.LocalTransparencyModifier = 0.6
                end
            end)
            task.spawn(function()
                local all = workspace:GetDescendants()
                for i = 1, #all do
                    if token ~= xrayToken then return end
                    local p = all[i]
                    if not xrayParts[p] and xrayValid(p) then
                        xrayParts[p] = true
                        p.LocalTransparencyModifier = 0.6
                    end
                    if i % 300 == 0 then task.wait() end
                end
            end)
        else
            local list = {}
            for p in pairs(xrayParts) do list[#list + 1] = p end
            xrayParts = {}
            task.spawn(function()
                for i = 1, #list do
                    if token ~= xrayToken then return end
                    local p = list[i]
                    if p.Parent then p.LocalTransparencyModifier = 0 end
                    if i % 300 == 0 then task.wait() end
                end
            end)
        end
    end)
    onCleanup(function()
        xrayToken += 1
        if xrayConn then xrayConn:Disconnect() xrayConn = nil end
        for p in pairs(xrayParts) do
            if p.Parent then p.LocalTransparencyModifier = 0 end
        end
        xrayParts = {}
    end)

    Button(t, "Gráficos baixos", function()
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p:IsA("Terrain") then
                p.Material = Enum.Material.SmoothPlastic
                p.CastShadow = false
            elseif p:IsA("Decal") or p:IsA("Texture") then
                p.Transparency = 1
            elseif p:IsA("ParticleEmitter") or p:IsA("Trail") then
                p.Enabled = false
            end
        end
        notify("Gráficos reduzidos")
    end)

    Button(t, "Gravidade da Lua", function() workspace.Gravity = 40 end)
    Button(t, "Gravidade normal", function() workspace.Gravity = DEFAULT_GRAVITY end)

    onCleanup(function()
        Lighting.FogStart, Lighting.FogEnd = origFog[1], origFog[2]
        Lighting.GlobalShadows = origShadows
        if atm then atm.Density = origDensity end
        workspace.Gravity = DEFAULT_GRAVITY
        S.cycle = false
    end)
end

do
    local t = createTab("Câmera")
    Section(t, "Câmera")

    Slider(t, "Zoom máximo", 20, 2000, math.clamp(math.floor(LP.CameraMaxZoomDistance), 20, 2000), function(v)
        LP.CameraMaxZoomDistance = v
    end)
    Toggle(t, "Primeira pessoa forçada", function(v)
        LP.CameraMode = v and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
    end)
    Toggle(t, "Câmera atravessa paredes", function(v)
        LP.DevCameraOcclusionMode = v and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
    end)

    local barTop = new("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 0}, gui)
    local barBot = new("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 0,
    }, gui)
    Toggle(t, "Barras cinematográficas", function(v)
        local h = v and 70 or 0
        tween(barTop, 0.5, {Size = UDim2.new(1, 0, 0, h)})
        tween(barBot, 0.5, {Size = UDim2.new(1, 0, 0, h)})
    end)

    Toggle(t, "Zoom (segurar Z)", function(v) S.zoomKey = v end)
    local zoomed = false
    connect(RunService.RenderStepped, function()
        local want = S.zoomKey and UIS:GetFocusedTextBox() == nil and UIS:IsKeyDown(Enum.KeyCode.Z)
        if want and not zoomed then
            zoomed = true
            tween(cam(), 0.25, {FieldOfView = 20})
        elseif not want and zoomed then
            zoomed = false
            tween(cam(), 0.25, {FieldOfView = S.fov})
        end
    end)

    Button(t, "Resetar câmera", function()
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = 128
        LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        S.fov = 70
        cam().FieldOfView = 70
        cam().CameraType = Enum.CameraType.Custom
        local h = getHum()
        if h then cam().CameraSubject = h end
    end)

    onCleanup(function()
        LP.CameraMode = Enum.CameraMode.Classic
        LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        cam().FieldOfView = 70
    end)
end

----------------------------------------------------------------
-- Aba: Visual (+ Jogadores)
----------------------------------------------------------------
do
    local t = createTab("Jogadores")
    Section(t, "Jogadores")

    local tagFolder = new("Folder", {Name = "Tags"}, gui)
    local tags, tagsOn = {}, false
    local function ensureTag(p)
        if p == LP or tags[p] then return end
        local bb = new("BillboardGui", {
            Size = UDim2.fromOffset(170, 24), StudsOffset = Vector3.new(0, 2.5, 0),
            AlwaysOnTop = true, Enabled = false,
        }, tagFolder)
        new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1),
            TextStrokeTransparency = 0.4, Font = Enum.Font.GothamBold, TextSize = 13,
        }, bb)
        tags[p] = bb
    end
    for _, p in ipairs(Players:GetPlayers()) do ensureTag(p) end
    connect(Players.PlayerAdded, ensureTag)
    connect(Players.PlayerRemoving, function(p)
        if tags[p] then tags[p]:Destroy() tags[p] = nil end
    end)
    Toggle(t, "Nametags com distância", function(v)
        tagsOn = v
        for _, bb in pairs(tags) do bb.Enabled = v end
    end)
    task.spawn(function()
        while gui.Parent do
            if tagsOn then
                local r = getHRP()
                for p, bb in pairs(tags) do
                    local head = p.Character and p.Character:FindFirstChild("Head")
                    bb.Adornee = head
                    bb.Enabled = head ~= nil
                    local lbl = bb:FindFirstChildOfClass("TextLabel")
                    if head and r and lbl then
                        lbl.Text = string.format("%s [%dm]", p.DisplayName, math.floor((head.Position - r.Position).Magnitude))
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    Toggle(t, "Ocultar nomes dos outros", function(v)
        for _, p in ipairs(Players:GetPlayers()) do
            local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.DisplayDistanceType = v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end)

    Button(t, "Info do servidor", function()
        notify(#Players:GetPlayers() .. "/" .. Players.MaxPlayers .. " jogadores no servidor")
    end)
    Button(t, "Copiar JobId", function() copy(game.JobId, "JobId") end)

    local fpsLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 12, 0, 12), Size = UDim2.fromOffset(170, 24),
        BackgroundColor3 = THEME.Bg, BackgroundTransparency = 0.25, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold, TextSize = 12, Visible = false, ZIndex = 90,
    }, gui)
    corner(fpsLabel, 8)
    stroke(fpsLabel, THEME.Accent, 1, 0.6)
    local frames, acc = 0, 0
    connect(RunService.RenderStepped, function(dt)
        if not fpsLabel.Visible then return end
        frames += 1
        acc += dt
        if acc >= 0.5 then
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            fpsLabel.Text = string.format("FPS %d  |  Ping %dms", math.floor(frames / acc), ping)
            frames, acc = 0, 0
        end
    end)
    Toggle(t, "Contador FPS / Ping", function(v) fpsLabel.Visible = v end)

    Toggle(t, "Esconder UI do Roblox", function(v)
        pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not v) end)
    end)
    onCleanup(function()
        pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
    end)
end

----------------------------------------------------------------
-- Aba: Misc (+ Utilidades)
----------------------------------------------------------------
local tMisc = createTab("Misc")
Section(tMisc, "Misc")
Toggle(tMisc, "Anti-AFK", function(v) S.antiAfk = v end)
Button(tMisc, "Resetar personagem", function()
    local h = getHum()
    if h then h.Health = 0 end
end)
Button(tMisc, "Rejoin (reentrar no servidor)", function()
    TeleportService:Teleport(game.PlaceId, LP)
end)

do
    local t = createTab("Utilidades")
    Section(t, "Utilidades")

    local box = TextInput(t, "Cole seu script Lua aqui")
    Button(t, "Executar script", function()
        local compile = loadstring
        if not compile then return notify("loadstring indisponível aqui") end
        if box.Text == "" then return notify("Caixa vazia") end
        local f, err = compile(box.Text)
        if not f then
            warn("[Okkotsu Hub] " .. tostring(err))
            return notify("Erro de sintaxe (veja o console)")
        end
        local ok, e = pcall(f)
        if not ok then warn("[Okkotsu Hub] " .. tostring(e)) end
        notify(ok and "Script executado" or "Erro ao executar")
    end)
    Button(t, "Limpar caixa de script", function() box.Text = "" end)

    Button(t, "Server hop", function()
        notify("Procurando servidor...")
        local ok, result = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
            return game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
        end)
        if not ok or type(result) ~= "table" or not result.data then
            return notify("Falha ao buscar servidores")
        end
        for _, s in ipairs(result.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                return
            end
        end
        notify("Nenhum servidor disponível")
    end)

    Toggle(t, "Auto-clicker (ferramenta)", function(v) S.autoclick = v end)
    task.spawn(function()
        while gui.Parent do
            if S.autoclick then
                local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
            task.wait(0.1)
        end
    end)

    local muted = {}
    Toggle(t, "Silenciar sons do jogo", function(v)
        if v then
            for _, s in ipairs(game:GetDescendants()) do
                if s:IsA("Sound") then muted[s] = s.Volume s.Volume = 0 end
            end
        else
            for s, vol in pairs(muted) do
                if s.Parent then s.Volume = vol end
            end
            table.clear(muted)
        end
    end)
    onCleanup(function()
        for s, vol in pairs(muted) do if s.Parent then s.Volume = vol end end
    end)

    Button(t, "Copiar PlaceId", function() copy(tostring(game.PlaceId), "PlaceId") end)
    Button(t, "Copiar posição atual", function()
        local r = getHRP()
        if r then
            local p = r.Position
            copy(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z), "Posição")
        end
    end)

    Slider(t, "Escala do hub", 50, 120, math.floor(uiScale.Scale * 100 + 0.5), function(v)
        tween(uiScale, 0.15, {Scale = v / 100})
    end)

    Toggle(t, "Atalhos (F = Fly, N = Noclip)", function(v) S.hotkeys = v end)
    connect(UIS.InputBegan, function(i, gp)
        if gp or not S.hotkeys then return end
        if i.KeyCode == Enum.KeyCode.F then
            setFly(not S.fly)
        elseif i.KeyCode == Enum.KeyCode.N then
            setNoclip(not S.noclip)
        end
    end)

    Button(t, "Restaurar padrões", function()
        setSpeed(false)
        setJump(false)
        workspace.Gravity = DEFAULT_GRAVITY
        S.fov = 70
        cam().FieldOfView = 70
        for k, val in pairs(origLight) do Lighting[k] = val end
        notify("Valores restaurados")
    end)
end

----------------------------------------------------------------
-- Aba: Música
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Música")
    Section(t, "Música")
    local SoundService = game:GetService("SoundService")

    local sound = new("Sound", {
        Name = "OkkMusic", Volume = 1, Looped = false,
        RollOffMode = Enum.RollOffMode.Linear,
        RollOffMinDistance = 10000, RollOffMaxDistance = 10000,
    }, SoundService)

    local shareMode = true
    local function reparent()
        local r = getHRP()
        if shareMode and r then
            sound.Parent = r
        else
            sound.Parent = SoundService
        end
    end

    local idBox = TextInput(t, "ID da música (somente números)")

    Button(t, "Tocar música", function()
        local id = idBox.Text:match("%d+")
        if not id then return notify("ID inválido") end
        reparent()
        sound:Stop()
        sound.SoundId = "rbxassetid://" .. id
        sound:Play()
        notify("Tocando ID " .. id)
    end)
    Button(t, "Pausar / Continuar", function()
        if sound.IsPaused then sound:Resume() else sound:Pause() end
    end)
    Button(t, "Parar música", function()
        sound:Stop()
        notify("Música parada")
    end)

    Slider(t, "Volume", 0, 100, 50, function(v) sound.Volume = v / 50 end)
    Slider(t, "Velocidade (%)", 50, 200, 100, function(v) sound.PlaybackSpeed = v / 100 end)
    Toggle(t, "Repetir (loop)", function(v) sound.Looped = v end)
    local setShare = Toggle(t, "Tocar para todos (no personagem)", function(v)
        shareMode = v
        reparent()
    end)
    setShare(true)

    connect(LP.CharacterAdded, function(c)
        c:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.3)
        reparent()
    end)

    onCleanup(function() sound:Destroy() end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na aba Música: " .. tostring(__err))
    notify("Erro na aba Música (F9)")
  end
end

----------------------------------------------------------------
-- Aba: Aparência (Efeitos + invisível)
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Efeitos")
    Section(t, "Efeitos e invisível")
    local active = {}

    local function detach(tag)
        local c = LP.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d.Name == "OKK_" .. tag then d:Destroy() end
        end
    end

    local function attach(tag)
        local build = active[tag]
        local r = getHRP()
        if not build or not r then return end
        detach(tag)
        for _, inst in ipairs(build()) do
            inst.Name = "OKK_" .. tag
            inst.Parent = r
        end
    end

    local function effectToggle(label, tag, build)
        Toggle(t, label, function(v)
            if v then
                active[tag] = build
                attach(tag)
            else
                active[tag] = nil
                detach(tag)
            end
        end)
    end

    local function fireBuilder(c1, c2)
        return function()
            return {new("Fire", {Color = c1, SecondaryColor = c2, Size = 9, Heat = 10})}
        end
    end

    effectToggle("Fogo Azul", "FogoAzul",
        fireBuilder(Color3.fromRGB(0, 110, 255), Color3.fromRGB(0, 220, 255)))
    effectToggle("Fogo Roxo", "FogoRoxo",
        fireBuilder(Color3.fromRGB(150, 0, 255), Color3.fromRGB(230, 120, 255)))
    effectToggle("Fogo Amarelo", "FogoAmarelo",
        fireBuilder(Color3.fromRGB(255, 225, 0), Color3.fromRGB(255, 140, 0)))
    effectToggle("Fogo Arco-íris", "Rainbow",
        fireBuilder(Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 160, 0)))

    effectToggle("Brilho dourado", "Brilho", function()
        local c = Color3.fromRGB(255, 235, 150)
        return {
            new("PointLight", {Color = c, Brightness = 4, Range = 24}),
            new("Sparkles", {SparkleColor = c}),
        }
    end)
    effectToggle("Faíscas roxas", "Faiscas", function()
        return {new("Sparkles", {SparkleColor = Color3.fromRGB(170, 90, 255)})}
    end)
    effectToggle("Fumaça", "Fumaca", function()
        return {new("Smoke", {Color = Color3.fromRGB(150, 150, 160), Size = 6, Opacity = 0.4, RiseVelocity = 3})}
    end)
    effectToggle("Aura neon", "Aura", function()
        return {new("Highlight", {
            Adornee = LP.Character, FillColor = THEME.Accent, OutlineColor = Color3.new(1, 1, 1),
            FillTransparency = 0.5, DepthMode = Enum.HighlightDepthMode.Occluded,
        })}
    end)

    connect(RunService.Heartbeat, function()
        if not active.Rainbow then return end
        local c = LP.Character
        local f = c and c:FindFirstChild("OKK_Rainbow", true)
        if f then
            local h = (tick() % 4) / 4
            f.Color = Color3.fromHSV(h, 1, 1)
            f.SecondaryColor = Color3.fromHSV((h + 0.15) % 1, 1, 1)
        end
    end)

    connect(LP.CharacterAdded, function(c)
        c:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        for tag in pairs(active) do attach(tag) end
    end)

    local invisOn = false
    local savedTransp = setmetatable({}, {__mode = "k"})
    local function applyInvis(on)
        local c = LP.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if (d:IsA("BasePart") and d.Name ~= "HumanoidRootPart") or d:IsA("Decal") then
                if on then
                    if savedTransp[d] == nil then savedTransp[d] = d.Transparency end
                    d.Transparency = 1
                elseif savedTransp[d] ~= nil then
                    d.Transparency = savedTransp[d]
                    savedTransp[d] = nil
                end
            end
        end
        local h = getHum()
        if h then
            h.DisplayDistanceType = on and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
        end
    end
    Toggle(t, "Modo invisível", function(v)
        invisOn = v
        applyInvis(v)
        notify(v and "Invisível ativado" or "Invisível desativado")
    end)
    task.spawn(function()
        while gui.Parent do
            if invisOn then applyInvis(true) end
            task.wait(0.5)
        end
    end)

    onCleanup(function()
        invisOn = false
        applyInvis(false)
        for tag in pairs(active) do detach(tag) end
    end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na aba Efeitos: " .. tostring(__err))
    notify("Erro na aba Efeitos (F9)")
  end
end

----------------------------------------------------------------
-- ESP avançado (aba Visual)
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Visual")
    Section(t, "ESP avançado (ligue o ESP acima)")

    local opt = {name = true, health = true, dist = true, team = false, maxDist = 1000}
    local setName   = Toggle(t, "ESP: mostrar nome", function(v) opt.name = v end)
    local setHealth = Toggle(t, "ESP: mostrar vida", function(v) opt.health = v end)
    local setDist   = Toggle(t, "ESP: mostrar distância", function(v) opt.dist = v end)
    Toggle(t, "ESP: cor por time", function(v) opt.team = v end)
    Slider(t, "ESP: distância máxima", 50, 5000, opt.maxDist, function(v) opt.maxDist = v end)
    setName(true) setHealth(true) setDist(true)

    local infoFolder = new("Folder", {Name = "ESPInfo"}, gui)
    local info = {}

    local function esc(str)
        return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end

    local function ensure(p)
        if p == LP or info[p] then return end
        local bb = new("BillboardGui", {
            Size = UDim2.fromOffset(220, 44), StudsOffset = Vector3.new(0, 3.2, 0),
            AlwaysOnTop = true, Enabled = false,
        }, infoFolder)
        local lbl = new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, RichText = true,
            TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.4,
            Font = Enum.Font.GothamBold, TextSize = 13,
        }, bb)
        info[p] = {bb = bb, lbl = lbl}
    end
    for _, p in ipairs(Players:GetPlayers()) do ensure(p) end
    connect(Players.PlayerAdded, ensure)
    connect(Players.PlayerRemoving, function(p)
        if info[p] then info[p].bb:Destroy() info[p] = nil end
    end)

    local acc = 0
    connect(RunService.Heartbeat, function(dt)
        acc += dt
        if acc < 0.1 then return end
        acc = 0
        local root = getHRP()
        for p, d in pairs(info) do
            local char = p.Character
            local head = char and char:FindFirstChild("Head")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local dist = (hrp and root) and (hrp.Position - root.Position).Magnitude or 0
            local inRange = S.esp and head ~= nil and hum ~= nil and dist <= opt.maxDist

            local h = espFolder:FindFirstChild(p.Name)
            if h then
                h.Enabled = inRange
                h.FillColor = opt.team and p.TeamColor.Color or THEME.Accent
            end

            d.bb.Adornee = head
            d.bb.Enabled = inRange and (opt.name or opt.health or opt.dist)
            if inRange then
                local lines = {}
                if opt.name then
                    local col = opt.team and p.TeamColor.Color or Color3.new(1, 1, 1)
                    lines[#lines + 1] = string.format('<font color="#%s">%s</font>', col:ToHex(), esc(p.DisplayName))
                end
                local second = {}
                if opt.health then
                    local hp, mx = hum.Health, hum.MaxHealth
                    local inf = (hp ~= hp) or hp == math.huge or mx == math.huge
                    local ratio = (not inf and mx > 0) and math.clamp(hp / mx, 0, 1) or 1
                    local txt = inf and "∞" or string.format("%d/%d", math.floor(hp), math.floor(mx))
                    second[#second + 1] = string.format('<font color="#%s">HP %s</font>', Color3.fromHSV(ratio * 0.33, 1, 1):ToHex(), txt)
                end
                if opt.dist then
                    second[#second + 1] = string.format("%dm", math.floor(dist))
                end
                if #second > 0 then lines[#lines + 1] = table.concat(second, "  |  ") end
                d.lbl.Text = table.concat(lines, "\n")
            end
        end
    end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro no ESP avançado: " .. tostring(__err))
    notify("Erro no ESP avançado (F9)")
  end
end

----------------------------------------------------------------
-- Lista de jogadores clicável (aba Teleporte)
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Teleporte")
    Section(t, "Lista de jogadores (toque para selecionar)")

    local selected = nil
    local rows = {}

    local holder = new("Frame", {Size = UDim2.new(1, 0, 0, 150), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, t)
    corner(holder, 10)
    stroke(holder, Color3.new(1, 1, 1), 1, 0.93)
    local list = new("ScrollingFrame", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.Accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, holder)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.Name}, list)

    local status = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Selecionado: ninguém",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, t)

    local function paint()
        for p, b in pairs(rows) do
            tween(b, 0.15, {BackgroundColor3 = (p == selected) and THEME.Accent or THEME.Panel2})
        end
        status.Text = selected
            and ("Selecionado: " .. selected.DisplayName .. " (@" .. selected.Name .. ")")
            or "Selecionado: ninguém"
    end

    local function addRow(p)
        if p == LP or rows[p] then return end
        local b = new("TextButton", {
            Name = p.DisplayName:lower() .. p.Name:lower(),
            Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = THEME.Panel2,
            Text = p.DisplayName .. "  (@" .. p.Name .. ")", TextColor3 = THEME.Text,
            Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false,
        }, list)
        corner(b, 8)
        b.MouseButton1Click:Connect(function()
            selected = p
            viewBox.Text = p.Name
            paint()
        end)
        rows[p] = b
    end
    local function removeRow(p)
        if rows[p] then rows[p]:Destroy() rows[p] = nil end
        if selected == p then selected = nil end
        paint()
    end
    for _, p in ipairs(Players:GetPlayers()) do addRow(p) end
    connect(Players.PlayerAdded, addRow)
    connect(Players.PlayerRemoving, removeRow)

    local function need()
        if not selected then notify("Selecione um jogador na lista") end
        return selected
    end

    Button(t, "Teleportar até o selecionado", function()
        local p = need()
        if not p then return end
        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            tpTo(r.CFrame * CFrame.new(0, 0, 3))
            notify("TP: " .. p.DisplayName)
        else
            notify("Jogador sem personagem")
        end
    end)
    Button(t, "Espectar o selecionado", function()
        local p = need()
        if not p then return end
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            notify("Vendo: " .. p.DisplayName)
        else
            notify("Jogador sem personagem")
        end
    end)
    Button(t, "Parar de espectar", function()
        local h = getHum()
        if h then workspace.CurrentCamera.CameraSubject = h end
    end)
    Button(t, "Copiar nick do selecionado", function()
        local p = need()
        if p then copy(p.Name, "Nick") end
    end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na lista de jogadores: " .. tostring(__err))
    notify("Erro na lista de jogadores (F9)")
  end
end

----------------------------------------------------------------
-- Aba: Discord
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local DISCORD_LINK = "https://discord.gg/J9Z9N6qsEc"

    local t = createTab("Discord")
    Section(t, "Servidor do Discord")

    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, t)
    corner(row, 10)
    gradient(stroke(row, Color3.new(1, 1, 1), 1, 0.5), THEME.Accent, THEME.Accent2, 45)
    new("TextLabel", {
        Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -32, 1, 0), BackgroundTransparency = 1,
        Text = "Entre na nossa comunidade:\n" .. DISCORD_LINK, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    Button(t, "Copiar link do Discord", function() copy(DISCORD_LINK, "Link do Discord") end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na aba Discord: " .. tostring(__err))
    notify("Erro na aba Discord (F9)")
  end
end

----------------------------------------------------------------
-- Aba: Buscar (primeira da barra lateral)
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    TAB_ORDER["Buscar"] = 0
    local t = createTab("Buscar")
    Section(t, "Buscar função")

    local ACC = {
        ["á"]="a", ["à"]="a", ["â"]="a", ["ã"]="a", ["Á"]="a", ["Ã"]="a",
        ["é"]="e", ["ê"]="e", ["É"]="e", ["í"]="i", ["Í"]="i",
        ["ó"]="o", ["ô"]="o", ["õ"]="o", ["Ó"]="o", ["ú"]="u", ["Ú"]="u", ["ç"]="c", ["Ç"]="c",
    }
    local function norm(str)
        local r = str:gsub(utf8.charpattern, function(c) return ACC[c] or c end)
        return r:lower()
    end

    local function labelOf(o)
        if o:IsA("TextButton") then return o.Text end
        if o:IsA("TextBox") then return o.PlaceholderText end
        if o:IsA("Frame") then
            local l = o:FindFirstChildOfClass("TextLabel")
            if l then return l.Text end
        end
        return nil
    end

    local function buildIndex()
        local names = {}
        for n in pairs(pages) do
            if n ~= "Buscar" then names[#names + 1] = n end
        end
        table.sort(names, function(a, b) return (TAB_ORDER[a] or 99) < (TAB_ORDER[b] or 99) end)
        local idx = {}
        for _, n in ipairs(names) do
            local sc = pages[n]:FindFirstChildOfClass("ScrollingFrame")
            if sc then
                for _, ch in ipairs(sc:GetChildren()) do
                    local txt = labelOf(ch)
                    if txt and txt ~= "" then
                        local first = (txt:gsub("\n.*", ""))
                        idx[#idx + 1] = {tab = n, row = ch, text = first, key = norm(first)}
                    end
                end
            end
        end
        return idx
    end

    local box = TextInput(t, "🔍  Digite o nome da função...")
    local results = {}

    local function flash(row)
        local orig = row.BackgroundColor3
        tween(row, 0.15, {BackgroundColor3 = THEME.Accent})
        task.delay(0.5, function()
            if row.Parent then tween(row, 0.4, {BackgroundColor3 = orig}) end
        end)
    end

    local function goTo(item)
        selectTab(item.tab)
        task.wait(0.4)
        local sc = pages[item.tab]:FindFirstChildOfClass("ScrollingFrame")
        if sc and item.row.Parent then
            local y = (item.row.AbsolutePosition.Y - sc.AbsolutePosition.Y) / uiScale.Scale + sc.CanvasPosition.Y
            sc.CanvasPosition = Vector2.new(0, math.max(0, y - 6))
            flash(item.row)
        end
    end

    local function refresh()
        for _, b in ipairs(results) do b:Destroy() end
        results = {}
        local q = norm(box.Text):gsub("^%s+", ""):gsub("%s+$", "")
        if q == "" then return end
        local shown = 0
        for _, item in ipairs(buildIndex()) do
            if item.key:find(q, 1, true) then
                shown += 1
                if shown > 15 then break end
                results[#results + 1] = Button(t, item.text .. "   ›  " .. item.tab, function() goTo(item) end)
            end
        end
        if shown == 0 then
            results[#results + 1] = new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Nada encontrado",
                TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12,
            }, t)
        end
    end
    box:GetPropertyChangedSignal("Text"):Connect(refresh)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na busca: " .. tostring(__err))
    notify("Erro na busca (F9)")
  end
end

----------------------------------------------------------------
-- Minimizar / restaurar / fechar
----------------------------------------------------------------
local pill = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(0, 34),
    BackgroundColor3 = THEME.Bg, Text = "", AutoButtonColor = false, Visible = false, ClipsDescendants = true,
}, gui)
corner(pill, 17)
gradient(stroke(pill, Color3.new(1, 1, 1), 1, 0.35), THEME.Accent, THEME.Accent2, 0)
new("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "◈  " .. HUB_NAME,
    TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 12,
}, pill)
makeDraggable(pill, pill)

local minimized = false
local function setMinimized(v)
    minimized = v
    if v then
        tween(root, 0.35, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.35, function() if minimized then root.Visible = false end end)
        pill.Visible = true
        tween(pill, 0.4, {Size = UDim2.fromOffset(250, 34)}, Enum.EasingStyle.Back)
    else
        tween(pill, 0.25, {Size = UDim2.fromOffset(0, 34)})
        task.delay(0.25, function() if not minimized then pill.Visible = false end end)
        root.Visible = true
        tween(root, 0.45, {Size = UDim2.fromOffset(WIDTH, HEIGHT)}, Enum.EasingStyle.Back)
    end
end
btnMin.MouseButton1Click:Connect(function() setMinimized(true) end)
pill.MouseButton1Click:Connect(function() setMinimized(false) end)
connect(UIS.InputBegan, function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightControl then setMinimized(not minimized) end
end)

local function doClose()
    tween(root, 0.3, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.32)
    for _, f in ipairs(cleanups) do pcall(f) end
    stopFly()
    S.noclip, S.speedOn, S.jumpOn, S.infJump = false, false, false, false
    local h = getHum()
    if h then h.WalkSpeed, h.JumpPower = 16, 50 workspace.CurrentCamera.CameraSubject = h end
    if S.fullbright then for k, val in pairs(origLight) do Lighting[k] = val end end
    for _, c in ipairs(connections) do c:Disconnect() end
    clearBlur()
    gui:Destroy()
end

-- Confirmação ao clicar no "X"
local confirmOpen = false
local function askClose()
    if confirmOpen then return end
    confirmOpen = true

    local dim = new("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 150,
    }, gui)
    tween(dim, 0.25, {BackgroundTransparency = 0.5})

    local wrap = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 151,
    }, dim)
    shadow(wrap, 151)
    local box = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 152,
    }, wrap)
    corner(box, 14)
    gradient(stroke(box, Color3.new(1, 1, 1), 1, 0.4), THEME.Accent, THEME.Accent2, 45)

    local warnIcon = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = THEME.Bad, BackgroundTransparency = 0.8, Text = "⏻", TextColor3 = THEME.Bad,
        Font = Enum.Font.GothamBold, TextSize = 18,
    }, box)
    corner(warnIcon, 17)
    new("TextLabel", {
        Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Text = "Fechar o script?", TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 16,
    }, box)
    new("TextLabel", {
        Position = UDim2.fromOffset(14, 78), Size = UDim2.new(1, -28, 0, 34), BackgroundTransparency = 1,
        Text = "Todas as funções serão desativadas e o hub será removido.",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true,
    }, box)

    local function closeDialog()
        tween(wrap, 0.2, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tween(dim, 0.25, {BackgroundTransparency = 1})
        task.delay(0.28, function() dim:Destroy() confirmOpen = false end)
    end

    local function dialogButton(text, x, color, cb)
        local b = new("TextButton", {
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(x, 0, 1, -14), Size = UDim2.fromOffset(120, 32),
            BackgroundColor3 = color, Text = text, TextColor3 = THEME.Text,
            Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
        }, box)
        corner(b, 10)
        b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
        b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
        b.MouseButton1Click:Connect(cb)
    end
    dialogButton("Não", 0.28, THEME.Panel3, closeDialog)
    dialogButton("Sim, fechar", 0.72, THEME.Bad, function()
        dim:Destroy()
        confirmOpen = false
        doClose()
    end)

    tween(wrap, 0.3, {Size = UDim2.fromOffset(310, 176)}, Enum.EasingStyle.Back)
end
btnClose.MouseButton1Click:Connect(askClose)

----------------------------------------------------------------
-- Tela de loading
----------------------------------------------------------------
do
    local overlay = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Bg, BorderSizePixel = 0, ZIndex = 200,
    }, gui)
    gradient(overlay, Color3.fromRGB(22, 17, 38), Color3.fromRGB(9, 9, 14), 90)

    local logo = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.38), Size = UDim2.fromOffset(64, 64),
        BackgroundColor3 = Color3.new(1, 1, 1), Text = "◈", TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 36, ZIndex = 201,
    }, overlay)
    corner(logo, 18)
    local logoGrad = gradient(logo, THEME.Accent, THEME.Accent2, 0)
    tween(logoGrad, 1.6, {Rotation = 360}, Enum.EasingStyle.Linear)

    local title = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.49),
        Size = UDim2.fromOffset(420, 30), BackgroundTransparency = 1, Text = "Okkotsu Hub",
        TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 26, ZIndex = 201,
    }, overlay)
    local sub = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.535),
        Size = UDim2.fromOffset(420, 18), BackgroundTransparency = 1, Text = "Universal Version",
        TextColor3 = THEME.Accent, Font = Enum.Font.GothamMedium, TextSize = 13, ZIndex = 201,
    }, overlay)
    local status = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.6),
        Size = UDim2.fromOffset(300, 18), BackgroundTransparency = 1, Text = "Carregando...",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 201,
    }, overlay)
    local barBg = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.65),
        Size = UDim2.fromOffset(280, 6), BackgroundColor3 = THEME.Off, BorderSizePixel = 0, ZIndex = 201,
    }, overlay)
    corner(barBg, 3)
    local barFill = new("Frame", {
        Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 202,
    }, barBg)
    corner(barFill, 3)
    gradient(barFill, THEME.Accent, THEME.Accent2, 0)

    local steps = {"Carregando módulos...", "Preparando interface...", "Aplicando tema...", "Pronto!"}
    for i, s in ipairs(steps) do
        status.Text = s
        tween(barFill, 0.25, {Size = UDim2.fromScale(i / #steps, 1)})
        task.wait(0.28)
    end

    clearBlur()
    tween(overlay, 0.4, {BackgroundTransparency = 1})
    for _, o in ipairs({title, sub, status, logo}) do tween(o, 0.35, {TextTransparency = 1}) end
    tween(logo, 0.35, {BackgroundTransparency = 1})
    tween(barBg, 0.35, {BackgroundTransparency = 1})
    tween(barFill, 0.35, {BackgroundTransparency = 1})
    task.wait(0.45)
    overlay:Destroy()
end

----------------------------------------------------------------
-- Animação de abertura
----------------------------------------------------------------
selectTab("Jogador")
tween(root, 0.55, {Size = UDim2.fromOffset(WIDTH, HEIGHT)}, Enum.EasingStyle.Back)
task.delay(0.6, function() notify(HUB_NAME .. " carregado") end)
