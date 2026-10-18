--[[
    Okkotsu Hub (Universal Version)
    GUI minimalista com animações, abas e botão de minimizar.
    Abas: Jogador | Movimento | Visual | Misc
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
    Bg     = Color3.fromRGB(16, 16, 22),
    Panel  = Color3.fromRGB(26, 26, 36),
    Panel2 = Color3.fromRGB(34, 34, 48),
    Accent = Color3.fromRGB(150, 100, 255),
    Text   = Color3.fromRGB(235, 235, 245),
    Sub    = Color3.fromRGB(140, 140, 160),
    Off    = Color3.fromRGB(60, 60, 78),
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

local function tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
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

local gui = new("ScreenGui", {
    Name = "OkkotsuHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, parent)

----------------------------------------------------------------
-- NOVO: Sistema de key (bloqueia todo o resto do script até validar)
----------------------------------------------------------------
do
    -- Jogadores com privilégio: entram sem key e sem prazo.
    -- Coloque o UserId (número da conta), um por linha, no formato:  [123456789] = true,
    local PRIVILEGED = {
         [4427424158] = true,
    }

    local VALID_KEY  = "GLOBAL_866328948"
    local EXPIRES_AT = 1792906284 -- 25/10/2026 02:31:24 (Brasília) = exatamente 1 semana depois

    if not PRIVILEGED[LP.UserId] then -- quem tem privilégio pula toda a tela de key

    local function nowTime()
        local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
        if ok and type(t) == "number" then return t end
        return os.time()
    end

    local keyFrame = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0), BackgroundColor3 = THEME.Bg, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 300,
    }, gui)
    corner(keyFrame, 12)
    new("UIStroke", {Color = THEME.Accent, Thickness = 1, Transparency = 0.4}, keyFrame)

    new("TextLabel", {
        Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
        Text = HUB_NAME, TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 15, ZIndex = 301,
    }, keyFrame)
    local info = new("TextLabel", {
        Position = UDim2.fromOffset(10, 42), Size = UDim2.new(1, -20, 0, 20), BackgroundTransparency = 1,
        Text = "Digite sua key para continuar", TextColor3 = THEME.Sub,
        Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 301,
    }, keyFrame)
    local input = new("TextBox", {
        Position = UDim2.fromOffset(20, 72), Size = UDim2.new(1, -40, 0, 34), BackgroundColor3 = THEME.Panel,
        Text = "", PlaceholderText = "Key", PlaceholderColor3 = THEME.Sub, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13, ClearTextOnFocus = false, ZIndex = 301,
    }, keyFrame)
    corner(input, 8)
    local confirm = new("TextButton", {
        Position = UDim2.fromOffset(20, 118), Size = UDim2.new(0.5, -26, 0, 32), BackgroundColor3 = THEME.Accent,
        Text = "Validar", TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        AutoButtonColor = false, ZIndex = 301,
    }, keyFrame)
    corner(confirm, 8)
    local cancel = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 118), Size = UDim2.new(0.5, -26, 0, 32),
        BackgroundColor3 = THEME.Panel2, Text = "Cancelar", TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, ZIndex = 301,
    }, keyFrame)
    corner(cancel, 8)
    local getKey = new("TextButton", {
        Position = UDim2.fromOffset(20, 160), Size = UDim2.new(1, -40, 0, 28), BackgroundColor3 = THEME.Panel,
        Text = "Pegar a key no Discord (copiar link)", TextColor3 = THEME.Accent,
        Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false, ZIndex = 301,
    }, keyFrame)
    corner(getKey, 8)
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

    tween(keyFrame, 0.35, {Size = UDim2.fromOffset(320, 204)}, Enum.EasingStyle.Back)

    local result = nil -- true = liberado | false = cancelado/expirado
    local function submit()
        if nowTime() >= EXPIRES_AT then
            info.Text = "Esta key expirou."
            info.TextColor3 = Color3.fromRGB(220, 70, 80)
            task.wait(1.5)
            result = false
            return
        end
        if input.Text:gsub("^%s+", ""):gsub("%s+$", "") == VALID_KEY then
            info.Text = "Key válida!"
            info.TextColor3 = Color3.fromRGB(90, 220, 130)
            task.wait(0.6)
            result = true
        else
            info.Text = "Key inválida"
            info.TextColor3 = Color3.fromRGB(220, 70, 80)
        end
    end
    confirm.MouseButton1Click:Connect(submit)
    input.FocusLost:Connect(function(enter) if enter then submit() end end)
    cancel.MouseButton1Click:Connect(function() result = false end)

    -- se a key já tiver expirado, avisa logo
    if nowTime() >= EXPIRES_AT then
        info.Text = "Esta key expirou."
        info.TextColor3 = Color3.fromRGB(220, 70, 80)
    end

    while result == nil and gui.Parent do task.wait(0.1) end

    if result ~= true then
        gui:Destroy()
        return
    end

    tween(keyFrame, 0.25, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.3)
    keyFrame:Destroy()

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
-- Notificação (toast)
----------------------------------------------------------------
local function notify(text)
    local t = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 40),
        Size = UDim2.fromOffset(260, 32),
        BackgroundColor3 = THEME.Panel,
        Text = text, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13,
        ZIndex = 50,
    }, gui)
    corner(t, 8)
    new("UIStroke", {Color = THEME.Accent, Thickness = 1, Transparency = 0.4}, t)
    tween(t, 0.35, {Position = UDim2.new(0.5, 0, 1, -24)}, Enum.EasingStyle.Back)
    task.delay(2, function()
        tween(t, 0.3, {Position = UDim2.new(0.5, 0, 1, 40)})
        task.wait(0.35)
        t:Destroy()
    end)
end

----------------------------------------------------------------
-- Janela principal
----------------------------------------------------------------
local WIDTH, HEIGHT = 480, 310

local main = new("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(0, 0),
    BackgroundColor3 = THEME.Bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
corner(main, 12)
new("UIStroke", {Color = THEME.Accent, Thickness = 1, Transparency = 0.6}, main)

local uiScale = new("UIScale", {Scale = (workspace.CurrentCamera.ViewportSize.X < 650) and 0.78 or 1}, gui)

-- Barra superior
local top = new("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, main)
new("Frame", {Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(14, 15), BackgroundColor3 = THEME.Accent}, top)
corner(top:FindFirstChildOfClass("Frame"), 4)
new("TextLabel", {
    Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1, Text = HUB_NAME,
    TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local function topButton(text, xOffset, hoverColor)
    local b = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOffset, 0.5, 0),
        Size = UDim2.fromOffset(26, 26), BackgroundColor3 = THEME.Panel2,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 16,
        AutoButtonColor = false,
    }, top)
    corner(b, 7)
    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = hoverColor}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = THEME.Panel2}) end)
    return b
end
local btnMin   = topButton("–", -42, THEME.Accent)
local btnClose = topButton("×", -10, Color3.fromRGB(220, 70, 80))

-- Sidebar
local sidebar = new("ScrollingFrame", {
    Position = UDim2.fromOffset(0, 38), Size = UDim2.new(0, 120, 1, -38),
    BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
    ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, sidebar)

-- Área de conteúdo
local content = new("Frame", {
    Position = UDim2.fromOffset(128, 46), Size = UDim2.new(1, -136, 1, -54),
    BackgroundTransparency = 1,
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
            local d = (i.Position - startInput) / uiScale.Scale
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end
makeDraggable(top, main)

----------------------------------------------------------------
-- Componentes
----------------------------------------------------------------
local function Toggle(scroll, text, cb)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, scroll)
    corner(row, 8)
    new("TextLabel", {
        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), BackgroundTransparency = 1,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(38, 20), BackgroundColor3 = THEME.Off, Text = "", AutoButtonColor = false,
    }, row)
    corner(track, 10)
    local knob = new("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(1, 1, 1)}, track)
    corner(knob, 7)

    local state = false
    local function set(v)
        state = v
        tween(track, 0.2, {BackgroundColor3 = v and THEME.Accent or THEME.Off})
        tween(knob, 0.25, {Position = v and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)}, Enum.EasingStyle.Back)
        task.spawn(cb, v)
    end
    track.MouseButton1Click:Connect(function() set(not state) end)
    return set
end

local function Slider(scroll, text, min, max, default, cb)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, scroll)
    corner(row, 8)
    new("TextLabel", {
        Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -70, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local valueLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 4), Size = UDim2.fromOffset(50, 20),
        BackgroundTransparency = 1, Text = tostring(default), TextColor3 = THEME.Accent,
        Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local bar = new("Frame", {Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = THEME.Off, BorderSizePixel = 0}, row)
    corner(bar, 3)
    local startRel = (default - min) / (max - min)
    local fill = new("Frame", {Size = UDim2.fromScale(startRel, 1), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0}, bar)
    corner(fill, 3)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel + 0.5)
        tween(fill, 0.08, {Size = UDim2.fromScale(rel, 1)})
        valueLabel.Text = tostring(val)
        cb(val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function Button(scroll, text, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = THEME.Panel, Text = text,
        TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
    }, scroll)
    corner(b, 8)
    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = THEME.Panel2}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = THEME.Panel}) end)
    b.MouseButton1Click:Connect(function()
        tween(b, 0.08, {BackgroundColor3 = THEME.Accent})
        task.delay(0.1, function() tween(b, 0.25, {BackgroundColor3 = THEME.Panel}) end)
        task.spawn(cb)
    end)
    return b
end

local function TextInput(scroll, placeholder)
    local box = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = THEME.Panel, Text = "",
        PlaceholderText = placeholder, PlaceholderColor3 = THEME.Sub, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13, ClearTextOnFocus = false,
    }, scroll)
    corner(box, 8)
    local stroke = new("UIStroke", {Color = THEME.Accent, Thickness = 1, Transparency = 1}, box)
    box.Focused:Connect(function() tween(stroke, 0.2, {Transparency = 0.2}) end)
    box.FocusLost:Connect(function() tween(stroke, 0.2, {Transparency = 1}) end)
    return box
end

-- Título de seção (para separar os grupos dentro de uma aba mesclada)
local function Section(scroll, text)
    return new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "▸ " .. text,
        TextColor3 = THEME.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, scroll)
end

----------------------------------------------------------------
-- Abas (todas com a marca d'água)
----------------------------------------------------------------
local pages, tabButtons = {}, {}
local currentTab

-- Abas mescladas: o nome antigo aponta para a aba que o recebe
local TAB_ALIAS = {
    ["Movimento"]  = "Jogador",
    ["Personagem"] = "Jogador",
    ["Câmera"]     = "Mundo",
    ["Jogadores"]  = "Visual",
    ["Utilidades"] = "Misc",
    ["Efeitos"]    = "Aparência",
}
-- Ordem das abas na barra lateral
local TAB_ORDER = {
    ["Jogador"] = 1, ["Teleporte"] = 2, ["Visual"] = 3, ["Mundo"] = 4,
    ["Aparência"] = 5, ["Música"] = 6, ["Misc"] = 7,
}

local function createTab(name)
    name = TAB_ALIAS[name] or name
    if pages[name] then
        return pages[name]:FindFirstChildOfClass("ScrollingFrame")
    end
    -- botão da sidebar
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = THEME.Panel2, BackgroundTransparency = 1,
        LayoutOrder = TAB_ORDER[name] or 99,
        Text = name, TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
    }, sidebar)
    corner(btn, 8)
    local indicator = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0,
    }, btn)
    corner(indicator, 2)

    -- página
    local page = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false}, content)
    local scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -22), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.Accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, page)
    local layout = new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
    new("UIPadding", {PaddingRight = UDim.new(0, 6)}, scroll)

    -- MARCA D'ÁGUA em todas as abas
    new("TextLabel", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, 0), Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1, Text = HUB_NAME, TextColor3 = THEME.Accent, TextTransparency = 0.55,
        Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    }, page)

    pages[name] = page
    tabButtons[name] = {btn = btn, indicator = indicator}

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
        tween(o.btn, 0.2, {BackgroundTransparency = 1, TextColor3 = THEME.Sub})
        tween(o.indicator, 0.2, {Size = UDim2.fromOffset(3, 0)})
        local oldPage = pages[currentTab]
        tween(oldPage, 0.15, {GroupTransparency = 1})
        task.delay(0.15, function() if currentTab ~= nil and pages[currentTab] ~= oldPage then oldPage.Visible = false end end)
    end
    currentTab = name
    local n = tabButtons[name]
    tween(n.btn, 0.2, {BackgroundTransparency = 0, TextColor3 = THEME.Text})
    tween(n.indicator, 0.25, {Size = UDim2.fromOffset(3, 18)}, Enum.EasingStyle.Back)
    local p = pages[name]
    p.Position = UDim2.fromOffset(0, 12)
    p.Visible = true
    tween(p, 0.3, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
end

----------------------------------------------------------------
-- Funcionalidades
----------------------------------------------------------------
-- Speed / Jump (aplicado continuamente para sobreviver a respawns)
connect(RunService.Heartbeat, function()
    local hum = getHum()
    if not hum then return end
    if S.speedOn then hum.WalkSpeed = S.speed end
    if S.jumpOn then
        hum.UseJumpPower = true
        hum.JumpPower = S.jump
    end
end)

-- Infinite Jump
connect(UIS.JumpRequest, function()
    if S.infJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Noclip
connect(RunService.Stepped, function()
    if S.noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- Fly (WASD / analógico + Espaço sobe, Ctrl desce; no celular, olhe pra cima/baixo)
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

-- View (espectar jogador)
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
        local old = espFolder:FindFirstChild(p.Name)
        if old then old:Destroy() end
        local h = new("Highlight", {
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

-- Fullbright
local origLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
}

-- Anti-AFK
connect(LP.Idled, function()
    if S.antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

----------------------------------------------------------------
-- Montagem das abas
----------------------------------------------------------------
-- Jogador
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

-- Movimento
local tMove = createTab("Movimento")
Section(tMove, "Movimento")
local setFly = Toggle(tMove, "Fly", function(v)
    S.fly = v
    if v then startFly() else stopFly() end
end)
Slider(tMove, "Velocidade do Fly", 10, 300, S.flySpeed, function(v) S.flySpeed = v end)
local setNoclip = Toggle(tMove, "Noclip", function(v) S.noclip = v end)

-- Visual
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

-- Misc
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


----------------------------------------------------------------
-- +50 OPÇÕES EXTRAS
----------------------------------------------------------------
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
-- ABA: Personagem (opções 1-10)
----------------------------------------------------------------
do
    local t = createTab("Personagem")
    Section(t, "Personagem")

    -- 1. Vida infinita (client)
    Toggle(t, "Vida infinita (client)", function(v)
        S.god = v
        if not v then
            local h = getHum()
            if h then h.MaxHealth = 100 h.Health = 100 end
        end
    end)
    -- 2. Auto-curar
    Toggle(t, "Auto-curar", function(v) S.autoheal = v end)
    -- 3. Auto-pular
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

    -- 4/5. Girar + velocidade do giro
    local spinSpeed = 10
    Toggle(t, "Girar personagem", function(v) S.spin = v end)
    Slider(t, "Velocidade do giro", 1, 50, spinSpeed, function(v) spinSpeed = v end)
    connect(RunService.RenderStepped, function()
        local r = getHRP()
        if S.spin and r then r.CFrame *= CFrame.Angles(0, math.rad(spinSpeed), 0) end
    end)

    -- 6. Congelar
    Toggle(t, "Congelar personagem", function(v)
        local r = getHRP()
        if r then r.Anchored = v end
    end)
    onCleanup(function() local r = getHRP() if r then r.Anchored = false end end)

    -- 7. Sprint com Shift
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

    -- 8. Dash
    Button(t, "Dash (impulso para frente)", function()
        local r = getHRP()
        if r then r.AssemblyLinearVelocity = r.CFrame.LookVector * 120 + Vector3.new(0, 20, 0) end
    end)

    -- 9. Sentar
    Button(t, "Sentar", function()
        local h = getHum()
        if h then h.Sit = true end
    end)

    -- 10. Remover animações
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
-- ABA: Teleporte (opções 11-18)
----------------------------------------------------------------
do
    local t = createTab("Teleporte")

    -- 11. Click TP
    Toggle(t, "Click TP (Ctrl + clique)", function(v) S.clickTP = v end)
    local mouse = LP:GetMouse()
    connect(mouse.Button1Down, function()
        if S.clickTP and UIS:IsKeyDown(Enum.KeyCode.LeftControl) and mouse.Hit then
            tpTo(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
        end
    end)

    -- 12. TP até jogador
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

    -- 13. TP jogador aleatório
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

    -- 14/15. Salvar e voltar posição
    local saved
    Button(t, "Salvar posição", function()
        local r = getHRP()
        if r then saved = r.CFrame notify("Posição salva") end
    end)
    Button(t, "Voltar à posição salva", function()
        if saved then tpTo(saved) else notify("Nenhuma posição salva") end
    end)

    -- 16. Spawn
    Button(t, "Ir ao spawn", function()
        local sp = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if sp then tpTo(sp.CFrame + Vector3.new(0, 4, 0)) else notify("Spawn não encontrado") end
    end)

    -- 17. Subir 50 studs
    Button(t, "Subir 50 studs", function()
        local r = getHRP()
        if r then r.CFrame += Vector3.new(0, 50, 0) end
    end)

    -- 18. TP por coordenadas
    local coordBox = TextInput(t, "Coordenadas: x, y, z")
    Button(t, "Teleportar para coordenadas", function()
        local x, y, z = coordBox.Text:match("(-?[%d%.]+)%s*,%s*(-?[%d%.]+)%s*,%s*(-?[%d%.]+)")
        if x then tpTo(CFrame.new(tonumber(x), tonumber(y), tonumber(z))) else notify("Formato: x, y, z") end
    end)
end

----------------------------------------------------------------
-- ABA: Mundo (opções 19-28)
----------------------------------------------------------------
do
    local t = createTab("Mundo")
    Section(t, "Mundo")

    -- 19. Hora do dia
    Slider(t, "Hora do dia", 0, 24, math.floor(Lighting.ClockTime), function(v) Lighting.ClockTime = v end)
    -- 20. Ciclo dia/noite
    Toggle(t, "Ciclo dia/noite", function(v) S.cycle = v end)
    connect(RunService.Heartbeat, function(dt)
        if S.cycle then Lighting.ClockTime = (Lighting.ClockTime + dt * 0.5) % 24 end
    end)
    -- 21. Brilho
    Slider(t, "Brilho", 0, 10, math.clamp(math.floor(Lighting.Brightness), 0, 10), function(v) Lighting.Brightness = v end)

    -- 22. Sem neblina
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

    -- 23. Sem sombras
    local origShadows = Lighting.GlobalShadows
    Toggle(t, "Sem sombras", function(v) Lighting.GlobalShadows = (not v) and origShadows or false end)

    -- 24. Remover pós-processamento
    Toggle(t, "Remover pós-processamento", function(v)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then e.Enabled = not v end
        end
    end)

    -- 25. X-Ray (OTIMIZADO: processa em lotes, sem travar, e acompanha peças novas)
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
            -- peças criadas depois também ficam transparentes
            xrayConn = workspace.DescendantAdded:Connect(function(d)
                if token == xrayToken and xrayValid(d) then
                    xrayParts[d] = true
                    d.LocalTransparencyModifier = 0.6
                end
            end)
            -- varredura em lotes (não congela o jogo)
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
            -- restauração também em lotes
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

    -- 26. Gráficos baixos
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

    -- 27/28. Gravidade
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

----------------------------------------------------------------
-- ABA: Câmera (opções 29-34)
----------------------------------------------------------------
do
    local t = createTab("Câmera")
    Section(t, "Câmera")

    -- 29. Zoom máximo
    Slider(t, "Zoom máximo", 20, 2000, math.clamp(math.floor(LP.CameraMaxZoomDistance), 20, 2000), function(v)
        LP.CameraMaxZoomDistance = v
    end)

    -- 30. Primeira pessoa forçada
    Toggle(t, "Primeira pessoa forçada", function(v)
        LP.CameraMode = v and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
    end)

    -- 31. Câmera sem oclusão
    Toggle(t, "Câmera atravessa paredes", function(v)
        LP.DevCameraOcclusionMode = v and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
    end)

    -- 32. Barras cinematográficas
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

    -- 33. Zoom (segurar Z)
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

    -- 34. Resetar câmera
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
-- ABA: Jogadores (opções 35-40)
----------------------------------------------------------------
do
    local t = createTab("Jogadores")
    Section(t, "Jogadores")

    -- 35. Nametags com distância
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

    -- 36. Ocultar nomes de outros jogadores
    Toggle(t, "Ocultar nomes dos outros", function(v)
        for _, p in ipairs(Players:GetPlayers()) do
            local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.DisplayDistanceType = v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end)

    -- 37. Info do servidor
    Button(t, "Info do servidor", function()
        notify(#Players:GetPlayers() .. "/" .. Players.MaxPlayers .. " jogadores no servidor")
    end)

    -- 38. Copiar JobId
    Button(t, "Copiar JobId", function() copy(game.JobId, "JobId") end)

    -- 39. Contador FPS / Ping
    local fpsLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(170, 20),
        BackgroundTransparency = 1, TextColor3 = THEME.Text, TextStrokeTransparency = 0.5,
        Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Visible = false,
    }, gui)
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
            fpsLabel.Text = string.format("FPS %d | Ping %dms", math.floor(frames / acc), ping)
            frames, acc = 0, 0
        end
    end)
    Toggle(t, "Contador FPS / Ping", function(v) fpsLabel.Visible = v end)

    -- 40. Esconder UI do Roblox
    Toggle(t, "Esconder UI do Roblox", function(v)
        pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not v) end)
    end)
    onCleanup(function()
        pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
    end)
end

----------------------------------------------------------------
-- ABA: Utilidades (opções 41-50)
----------------------------------------------------------------
do
    local t = createTab("Utilidades")
    Section(t, "Utilidades")

    -- 41/42. Executor de scripts
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

    -- 43. Server hop
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

    -- 44. Auto-clicker (ferramenta equipada)
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

    -- 45. Silenciar sons
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

    -- 46. Copiar PlaceId
    Button(t, "Copiar PlaceId", function() copy(tostring(game.PlaceId), "PlaceId") end)

    -- 47. Copiar posição
    Button(t, "Copiar posição atual", function()
        local r = getHRP()
        if r then
            local p = r.Position
            copy(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z), "Posição")
        end
    end)

    -- 48. Escala do hub
    Slider(t, "Escala do hub", 60, 120, math.floor(uiScale.Scale * 100 + 0.5), function(v)
        tween(uiScale, 0.15, {Scale = v / 100})
    end)

    -- 49. Atalhos de teclado
    Toggle(t, "Atalhos (F = Fly, N = Noclip)", function(v) S.hotkeys = v end)
    connect(UIS.InputBegan, function(i, gp)
        if gp or not S.hotkeys then return end
        if i.KeyCode == Enum.KeyCode.F then
            setFly(not S.fly)
        elseif i.KeyCode == Enum.KeyCode.N then
            setNoclip(not S.noclip)
        end
    end)

    -- 50. Restaurar padrões
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
-- NOVO - ABA: Música
-- Obs.: o Roblox só replica o som para os outros jogadores se o jogo
-- permitir (o servidor filtra o que o cliente cria). O som é colocado
-- no seu personagem com alcance enorme para ser ouvido por quem
-- estiver recebendo a réplica.
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Música")
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
-- NOVO - ABA: Efeitos (fogo azul/roxo/amarelo, brilho... + invisível)
-- Obs.: os efeitos são colocados no seu personagem; os outros jogadores
-- só os veem se o jogo replicar a mudança feita pelo cliente.
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

    -- Fogo arco-íris: troca a cor continuamente
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

    -- Reaplicar efeitos ao renascer
    connect(LP.CharacterAdded, function(c)
        c:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        for tag in pairs(active) do attach(tag) end
    end)

    -- Modo invisível
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
-- NOVO - ABA: Discord
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local DISCORD_LINK = "https://discord.gg/J9Z9N6qsEc"

    local t = createTab("Discord")
    Section(t, "Servidor do Discord")

    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, t)
    corner(row, 8)
    new("TextLabel", {
        Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1,
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
-- Minimizar / restaurar / fechar
----------------------------------------------------------------
local pill = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(0, 30),
    BackgroundColor3 = THEME.Bg, Text = "", AutoButtonColor = false, Visible = false, ClipsDescendants = true,
}, gui)
corner(pill, 15)
new("UIStroke", {Color = THEME.Accent, Thickness = 1, Transparency = 0.4}, pill)
new("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "◈  " .. HUB_NAME,
    TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 12,
}, pill)
makeDraggable(pill, pill)

local minimized = false
local function setMinimized(v)
    minimized = v
    if v then
        tween(main, 0.35, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.35, function() if minimized then main.Visible = false end end)
        pill.Visible = true
        tween(pill, 0.4, {Size = UDim2.fromOffset(230, 30)}, Enum.EasingStyle.Back)
    else
        tween(pill, 0.25, {Size = UDim2.fromOffset(0, 30)})
        task.delay(0.25, function() if not minimized then pill.Visible = false end end)
        main.Visible = true
        tween(main, 0.45, {Size = UDim2.fromOffset(WIDTH, HEIGHT)}, Enum.EasingStyle.Back)
    end
end
btnMin.MouseButton1Click:Connect(function() setMinimized(true) end)
pill.MouseButton1Click:Connect(function() setMinimized(false) end)
connect(UIS.InputBegan, function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightControl then setMinimized(not minimized) end
end)

-- (o corpo abaixo é o fechamento original; agora só roda depois da confirmação)
local function doClose()
    tween(main, 0.3, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.32)
    for _, f in ipairs(cleanups) do pcall(f) end
    stopFly()
    S.noclip, S.speedOn, S.jumpOn, S.infJump = false, false, false, false
    local h = getHum()
    if h then h.WalkSpeed, h.JumpPower = 16, 50 workspace.CurrentCamera.CameraSubject = h end
    if S.fullbright then for k, val in pairs(origLight) do Lighting[k] = val end end
    for _, c in ipairs(connections) do c:Disconnect() end
    gui:Destroy()
end

-- NOVO: aviso de confirmação ao clicar no "X"
local confirmOpen = false
local function askClose()
    if confirmOpen then return end
    confirmOpen = true

    local inv = 1 / uiScale.Scale
    local dim = new("TextButton", {
        Size = UDim2.fromScale(inv, inv), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 150,
    }, gui)
    tween(dim, 0.25, {BackgroundTransparency = 0.45})

    local box = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5 * inv, 0.5 * inv),
        Size = UDim2.fromOffset(0, 0), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 151,
    }, dim)
    corner(box, 12)
    new("UIStroke", {Color = THEME.Accent, Thickness = 1, Transparency = 0.4}, box)

    new("TextLabel", {
        Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Text = "Fechar o script?", TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 16,
        ZIndex = 152,
    }, box)
    new("TextLabel", {
        Position = UDim2.fromOffset(10, 44), Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1,
        Text = "Todas as funções serão desativadas e o hub será removido.",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true,
        ZIndex = 152,
    }, box)

    local function closeDialog()
        tween(box, 0.2, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tween(dim, 0.25, {BackgroundTransparency = 1})
        task.delay(0.28, function() dim:Destroy() confirmOpen = false end)
    end

    local function dialogButton(text, x, color, cb)
        local b = new("TextButton", {
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(x, 0, 1, -14), Size = UDim2.fromOffset(110, 30),
            BackgroundColor3 = color, Text = text, TextColor3 = THEME.Text,
            Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, ZIndex = 152,
        }, box)
        corner(b, 8)
        b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
        b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
        b.MouseButton1Click:Connect(cb)
    end
    dialogButton("Não", 0.3, THEME.Panel2, closeDialog)
    dialogButton("Sim, fechar", 0.7, Color3.fromRGB(220, 70, 80), function()
        dim:Destroy()
        confirmOpen = false
        doClose()
    end)

    tween(box, 0.3, {Size = UDim2.fromOffset(300, 130)}, Enum.EasingStyle.Back)
end
btnClose.MouseButton1Click:Connect(askClose)

----------------------------------------------------------------
-- NOVO: Tela de loading (rápida)
----------------------------------------------------------------
do
    local inv = 1 / uiScale.Scale
    local overlay = new("Frame", {
        Size = UDim2.fromScale(inv, inv), BackgroundColor3 = THEME.Bg, BorderSizePixel = 0, ZIndex = 200,
    }, gui)

    local title = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.44),
        Size = UDim2.fromOffset(420, 30), BackgroundTransparency = 1, Text = HUB_NAME,
        TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 22, ZIndex = 201,
    }, overlay)
    local status = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(300, 20), BackgroundTransparency = 1, Text = "Carregando...",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 13, ZIndex = 201,
    }, overlay)
    local barBg = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58),
        Size = UDim2.fromOffset(260, 6), BackgroundColor3 = THEME.Off, BorderSizePixel = 0, ZIndex = 201,
    }, overlay)
    corner(barBg, 3)
    local barFill = new("Frame", {
        Size = UDim2.fromScale(0, 1), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, ZIndex = 202,
    }, barBg)
    corner(barFill, 3)

    local steps = {"Carregando módulos...", "Preparando interface...", "Aplicando tema...", "Pronto!"}
    for i, s in ipairs(steps) do
        status.Text = s
        tween(barFill, 0.25, {Size = UDim2.fromScale(i / #steps, 1)})
        task.wait(0.28)
    end

    tween(overlay, 0.35, {BackgroundTransparency = 1})
    tween(title, 0.35, {TextTransparency = 1})
    tween(status, 0.35, {TextTransparency = 1})
    tween(barBg, 0.35, {BackgroundTransparency = 1})
    tween(barFill, 0.35, {BackgroundTransparency = 1})
    task.wait(0.4)
    overlay:Destroy()
end

----------------------------------------------------------------
-- Animação de abertura
----------------------------------------------------------------
selectTab("Jogador")
tween(main, 0.55, {Size = UDim2.fromOffset(WIDTH, HEIGHT)}, Enum.EasingStyle.Back)
task.delay(0.6, function() notify(HUB_NAME .. " carregado") end)
