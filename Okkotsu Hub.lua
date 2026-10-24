--[[
    Okkotsu Hub (Universal Version) — UI v2 (Halloween Edition 🎃)
    Interface refeita: janela com sombra, gradientes, sidebar com ícones,
    cartão do jogador, toasts empilhados, sliders com knob, toggles animados,
    tela de loading / confirmação redesenhadas.
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

-- Jogadores Verificados: recebem a Tag azul (efeito azul + etiqueta "Verificado").
-- Coloque o UserId (número da conta), um por linha, no formato:  [123456789] = true,
local VERIFIED = {
     [4427424158] = true,
     --[SEU_USERID_AQUI] = true,
}

local THEME = {
    Bg      = Color3.fromRGB(14, 9, 16),
    Panel   = Color3.fromRGB(26, 17, 26),
    Panel2  = Color3.fromRGB(38, 24, 36),
    Panel3  = Color3.fromRGB(54, 33, 46),
    Accent  = Color3.fromRGB(255, 122, 26),   -- laranja abóbora
    Accent2 = Color3.fromRGB(152, 72, 232),   -- roxo bruxa
    Text    = Color3.fromRGB(252, 238, 224),
    Sub     = Color3.fromRGB(168, 140, 152),
    Off     = Color3.fromRGB(68, 46, 62),
    Good    = Color3.fromRGB(130, 225, 70),   -- verde gosma
    Bad     = Color3.fromRGB(235, 70, 70),
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

----------------------------------------------------------------
-- Tradução PT <-> EN
-- Os textos do script são escritos em português. Todo texto que existir
-- no dicionário abaixo é traduzido automaticamente (e re-traduzido ao
-- trocar o idioma, sem precisar recarregar o hub).
----------------------------------------------------------------
local DICT = {
    -- janela / abas
    ["Halloween Edition  •  RightCtrl minimiza"] = "Halloween Edition  •  RightCtrl minimizes",
    ["Buscar"] = "Search", ["Jogador"] = "Player", ["Teleporte"] = "Teleport", ["Mundo"] = "World",
    ["Aparência"] = "Appearance", ["Música"] = "Music",
    -- seções
    ["Movimento"] = "Movement", ["Personagem"] = "Character", ["Câmera"] = "Camera", ["Jogadores"] = "Players",
    ["Utilidades"] = "Utilities", ["Efeitos e invisível"] = "Effects and invisibility",
    ["ESP avançado (ligue o ESP acima)"] = "Advanced ESP (turn on ESP above)",
    ["Lista de jogadores (toque para selecionar)"] = "Player list (tap to select)",
    ["Servidor do Discord"] = "Discord server", ["Buscar função"] = "Search function",
    ["Tag — jogadores verificados ficam azuis"] = "Tag — verified players turn blue",
    ["◈ Verificado"] = "◈ Verified",
    -- jogador
    ["Velocidade"] = "Walk speed", ["Super Pulo"] = "Super Jump", ["Força do pulo"] = "Jump power",
    ["Pulo infinito"] = "Infinite jump", ["Gravidade"] = "Gravity",
    ["Velocidade do Fly"] = "Fly speed",
    ["Vida infinita (client)"] = "Infinite health (client)", ["Auto-curar"] = "Auto-heal", ["Auto-pular"] = "Auto-jump",
    ["Girar personagem"] = "Spin character", ["Velocidade do giro"] = "Spin speed",
    ["Congelar personagem"] = "Freeze character", ["Sprint (segurar Shift)"] = "Sprint (hold Shift)",
    ["Dash (impulso para frente)"] = "Dash (forward boost)", ["Sentar"] = "Sit", ["Remover animações"] = "Remove animations",
    -- visual
    ["Nome do jogador (parcial)"] = "Player name (partial)", ["View (espectar)"] = "View (spectate)",
    ["ESP (destacar jogadores)"] = "ESP (highlight players)", ["Campo de visão (FOV)"] = "Field of view (FOV)",
    -- teleporte
    ["Click TP (Ctrl + clique)"] = "Click TP (Ctrl + click)", ["Teleportar até o jogador"] = "Teleport to player",
    ["TP para jogador aleatório"] = "TP to random player", ["Salvar posição"] = "Save position",
    ["Voltar à posição salva"] = "Return to saved position", ["Ir ao spawn"] = "Go to spawn",
    ["Subir 50 studs"] = "Go up 50 studs", ["Coordenadas: x, y, z"] = "Coordinates: x, y, z",
    ["Teleportar para coordenadas"] = "Teleport to coordinates",
    -- mundo
    ["Hora do dia"] = "Time of day", ["Ciclo dia/noite"] = "Day/night cycle", ["Brilho"] = "Brightness",
    ["Sem neblina"] = "No fog", ["Sem sombras"] = "No shadows", ["Remover pós-processamento"] = "Remove post-processing",
    ["X-Ray (paredes transparentes)"] = "X-Ray (transparent walls)", ["Gráficos baixos"] = "Low graphics",
    ["Gravidade da Lua"] = "Moon gravity", ["Gravidade normal"] = "Normal gravity",
    -- câmera
    ["Zoom máximo"] = "Max zoom", ["Primeira pessoa forçada"] = "Forced first person",
    ["Câmera atravessa paredes"] = "Camera through walls", ["Barras cinematográficas"] = "Cinematic bars",
    ["Zoom (segurar Z)"] = "Zoom (hold Z)", ["Resetar câmera"] = "Reset camera",
    -- jogadores
    ["Nametags com distância"] = "Nametags with distance", ["Ocultar nomes dos outros"] = "Hide names of others",
    ["Info do servidor"] = "Server info", ["Copiar JobId"] = "Copy JobId",
    ["Contador FPS / Ping"] = "FPS / Ping counter", ["Esconder UI do Roblox"] = "Hide Roblox UI",
    -- misc / utilidades
    ["Resetar personagem"] = "Reset character", ["Rejoin (reentrar no servidor)"] = "Rejoin (re-enter server)",
    ["Cole seu script Lua aqui"] = "Paste your Lua script here", ["Executar script"] = "Run script",
    ["Limpar caixa de script"] = "Clear script box", ["Auto-clicker (ferramenta)"] = "Auto-clicker (tool)",
    ["Silenciar sons do jogo"] = "Mute game sounds", ["Copiar PlaceId"] = "Copy PlaceId",
    ["Copiar posição atual"] = "Copy current position", ["Escala do hub"] = "Hub scale",
    ["Atalhos (F = Fly, N = Noclip)"] = "Hotkeys (F = Fly, N = Noclip)", ["Restaurar padrões"] = "Restore defaults",
    -- música
    ["ID da música (somente números)"] = "Music ID (numbers only)", ["Tocar música"] = "Play music",
    ["Pausar / Continuar"] = "Pause / Resume", ["Parar música"] = "Stop music", ["Velocidade (%)"] = "Speed (%)",
    ["Repetir (loop)"] = "Repeat (loop)", ["Tocar para todos (no personagem)"] = "Play for everyone (on character)",
    -- efeitos
    ["Fogo Azul"] = "Blue Fire", ["Fogo Roxo"] = "Purple Fire", ["Fogo Amarelo"] = "Yellow Fire",
    ["Fogo Arco-íris"] = "Rainbow Fire", ["Brilho dourado"] = "Golden glow", ["Faíscas roxas"] = "Purple sparks",
    ["Fumaça"] = "Smoke", ["Aura neon"] = "Neon aura", ["Modo invisível"] = "Invisible mode",
    -- esp
    ["ESP: mostrar nome"] = "ESP: show name", ["ESP: mostrar vida"] = "ESP: show health",
    ["ESP: mostrar distância"] = "ESP: show distance", ["ESP: cor por time"] = "ESP: team color",
    ["ESP: distância máxima"] = "ESP: max distance",
    -- lista de jogadores
    ["Selecionado: ninguém"] = "Selected: nobody", ["Selecionado: "] = "Selected: ",
    ["Teleportar até o selecionado"] = "Teleport to selected", ["Espectar o selecionado"] = "Spectate selected",
    ["Parar de espectar"] = "Stop spectating", ["Copiar nick do selecionado"] = "Copy selected nick",
    -- discord / busca
    ["Copiar link do Discord"] = "Copy Discord link", ["Entre na nossa comunidade:"] = "Join our community:",
    ["🔍  Digite o nome da função..."] = "🔍  Type the function name...", ["Nada encontrado"] = "Nothing found",
    -- fechar
    ["Fechar o script?"] = "Close the script?",
    ["Todas as funções serão desativadas e o hub será removido."] = "All features will be disabled and the hub will be removed.",
    ["Não"] = "No", ["Sim, fechar"] = "Yes, close",
    -- loading
    ["Carregando..."] = "Loading...", ["Carregando módulos..."] = "Loading modules...",
    ["Preparando interface..."] = "Preparing interface...", ["Aplicando tema..."] = "Applying theme...",
    ["Pronto!"] = "Done!",
    ["Invocando espíritos..."] = "Summoning spirits...",
    ["Acendendo as abóboras..."] = "Lighting the pumpkins...",
    ["Tecendo as teias..."] = "Weaving the webs...",
    ["Boo! Tudo pronto 🎃"] = "Boo! All set 🎃",
    -- anti-cheat
    ["Anti-Cheat — detector de cheaters"] = "Anti-Cheat — cheater detector",
    ["Detector de cheaters"] = "Cheater detector", ["Alertas de suspeitos"] = "Suspect alerts",
    ["Marcar suspeitos (ESP vermelho)"] = "Mark suspects (red ESP)",
    ["Tolerância de velocidade"] = "Speed tolerance", ["Limpar flags"] = "Clear flags",
    ["Copiar relatório"] = "Copy report", ["Relatório"] = "Report", ["Flags limpas"] = "Flags cleared",
    ["Nenhum suspeito"] = "No suspects", ["Suspeito"] = "Suspect",
    ["Velocidade anormal"] = "Abnormal speed", ["Voo"] = "Flying", ["Teleporte súbito"] = "Sudden teleport",
    ["Pulo anormal"] = "Abnormal jump", ["Monitorando: "] = "Monitoring: ",
    [" jogadores  |  Suspeitos: "] = " players  |  Suspects: ", [" é suspeito: "] = " is suspect: ",
    ["Detecção local: pode haver falso positivo (carros, teleports do jogo, lag)."] =
        "Local detection: false positives are possible (vehicles, game teleports, lag).",
    -- avisos (toasts)
    ["Jogador não encontrado"] = "Player not found", ["Vendo: "] = "Viewing: ",
    ["Nenhum jogador disponível"] = "No players available", ["Posição salva"] = "Position saved",
    ["Nenhuma posição salva"] = "No saved position", ["Spawn não encontrado"] = "Spawn not found",
    ["Formato: x, y, z"] = "Format: x, y, z", ["Gráficos reduzidos"] = "Graphics reduced",
    ["Área de transferência indisponível"] = "Clipboard unavailable", [" copiado"] = " copied",
    ["Texto"] = "Text", ["Posição"] = "Position", ["Link do Discord"] = "Discord link",
    ["loadstring indisponível aqui"] = "loadstring unavailable here", ["Caixa vazia"] = "Box is empty",
    ["Erro de sintaxe (veja o console)"] = "Syntax error (check the console)",
    ["Script executado"] = "Script executed", ["Erro ao executar"] = "Error while running",
    ["Procurando servidor..."] = "Searching for a server...", ["Falha ao buscar servidores"] = "Failed to fetch servers",
    ["Nenhum servidor disponível"] = "No server available", ["Valores restaurados"] = "Values restored",
    ["ID inválido"] = "Invalid ID", ["Tocando ID "] = "Playing ID ", ["Música parada"] = "Music stopped",
    ["Invisível ativado"] = "Invisible enabled", ["Invisível desativado"] = "Invisible disabled",
    ["Selecione um jogador na lista"] = "Select a player from the list",
    ["Jogador sem personagem"] = "Player has no character",
    [" jogadores no servidor"] = " players in the server", [" carregado"] = " loaded",
}
local PREFIXES = {"Vendo: ", "Tocando ID ", "Selecionado: "}
local SUFFIXES = {" copiado", " jogadores no servidor", " carregado"}

local function trEn(s)
    local d = DICT[s]
    if d then return d end
    if s:sub(1, 4) == "▸ " then return "▸ " .. trEn(s:sub(5)) end
    for _, p in ipairs(PREFIXES) do
        if #s > #p and s:sub(1, #p) == p then return DICT[p] .. s:sub(#p + 1) end
    end
    for _, x in ipairs(SUFFIXES) do
        if #s > #x and s:sub(-#x) == x then return trEn(s:sub(1, #s - #x)) .. DICT[x] end
    end
    return s
end

local lang = "pt"
do
    local saved
    pcall(function()
        if isfile and isfile("OkkotsuHub_lang.txt") then saved = readfile("OkkotsuHub_lang.txt") end
    end)
    if saved == "en" or saved == "pt" then
        lang = saved
    else
        pcall(function()
            if not tostring(LP.LocaleId):lower():find("^pt") then lang = "en" end
        end)
    end
end

local function T(s)
    if lang == "en" then return trEn(s) end
    return s
end

local I18N = setmetatable({}, {__mode = "k"}) -- [instância] = {Text = "original pt", ...}
local langHooks = {}                          -- funções extras chamadas ao trocar o idioma
local function setLang(l)
    lang = l
    for o, props in pairs(I18N) do
        for prop, pt in pairs(props) do
            pcall(function() o[prop] = T(pt) end)
        end
    end
    for _, h in ipairs(langHooks) do pcall(h) end
    pcall(function() if writefile then writefile("OkkotsuHub_lang.txt", l) end end)
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if props then
        for _, prop in ipairs({"Text", "PlaceholderText"}) do
            local v = props[prop]
            if type(v) == "string" and v ~= "" and trEn(v) ~= v then
                I18N[o] = I18N[o] or {}
                I18N[o][prop] = v
                if lang == "en" then o[prop] = trEn(v) end
            end
        end
    end
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

local function shadow(parent, z, color, trans)
    return new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 56, 1, 56), BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993", ImageColor3 = color or Color3.new(0, 0, 0), ImageTransparency = trans or 0.3,
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

local gui = new("ScreenGui", {
    Name = "OkkotsuHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, parent)

----------------------------------------------------------------
-- Imagens de Halloween (embutidas no script)
-- O script salva as imagens com writefile e carrega com getcustomasset.
-- Se o seu executor não suportar isso, a interface usa emojis no lugar.
-- Opcional: se preferir, envie as imagens ao Roblox e cole os IDs abaixo,
-- por exemplo:  web = "rbxassetid://123456789"
----------------------------------------------------------------
local IMG_IDS = { web = "", spider = "", pumpkin = "" }

local IMG_DATA = {
    web = [==[
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
]==],
    spider = [==[
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
]==],
    pumpkin = [==[
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
]==],
}

local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64MAP = {}
for i = 1, #B64CHARS do B64MAP[B64CHARS:byte(i)] = i - 1 end

local function b64decode(data)
    data = data:gsub("[^%w%+/=]", "")
    local out, n = {}, 0
    for i = 1, #data, 4 do
        local a, b, c, d = data:byte(i, i + 3)
        local v = (B64MAP[a] or 0) * 262144 + (B64MAP[b] or 0) * 4096 + (B64MAP[c] or 0) * 64 + (B64MAP[d] or 0)
        local b1, b2, b3 = math.floor(v / 65536) % 256, math.floor(v / 256) % 256, v % 256
        n += 1
        if c == 61 then
            out[n] = string.char(b1)
        elseif d == 61 then
            out[n] = string.char(b1, b2)
        else
            out[n] = string.char(b1, b2, b3)
        end
    end
    return table.concat(out)
end

local function loadAsset(name)
    if IMG_IDS[name] and IMG_IDS[name] ~= "" then return IMG_IDS[name] end
    local getAsset = getcustomasset or getsynasset
    if not (writefile and getAsset) then return "" end
    local ok, url = pcall(function()
        local path = "OkkotsuHub_" .. name .. ".png"
        writefile(path, b64decode(IMG_DATA[name]))
        return getAsset(path)
    end)
    if ok and type(url) == "string" then return url end
    return ""
end

local IMG = {
    web     = loadAsset("web"),
    spider  = loadAsset("spider"),
    pumpkin = loadAsset("pumpkin"),
}

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
    text = T(text)
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
shadow(root, 0, Color3.fromRGB(255, 110, 20), 0.62)

local main = new("Frame", {
    Name = "Main", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0, ClipsDescendants = true,
}, root)
corner(main, 16)
gradient(main, Color3.fromRGB(34, 16, 30), Color3.fromRGB(11, 7, 14), 90)
gradient(stroke(main, Color3.new(1, 1, 1), 1, 0.55), THEME.Accent, THEME.Accent2, 45)

-- Cabeçalho
local top = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, main)
gradient(top, Color3.fromRGB(64, 28, 14), Color3.fromRGB(36, 18, 50), 0)
local topLine = new("Frame", {
    AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, BackgroundTransparency = 0.35,
}, top)
gradient(topLine, THEME.Accent, THEME.Accent2, 0)

local logoBox
if IMG.pumpkin ~= "" then
    logoBox = new("ImageLabel", {
        Position = UDim2.fromOffset(9, 6), Size = UDim2.fromOffset(34, 34), BackgroundTransparency = 1,
        Image = IMG.pumpkin, ScaleType = Enum.ScaleType.Fit,
    }, top)
else
    logoBox = new("TextLabel", {
        Position = UDim2.fromOffset(9, 6), Size = UDim2.fromOffset(34, 34), BackgroundTransparency = 1,
        Text = "🎃", TextSize = 24, Font = Enum.Font.GothamBold,
    }, top)
end
new("TextLabel", {
    Position = UDim2.fromOffset(52, 6), Size = UDim2.new(1, -150, 0, 20), BackgroundTransparency = 1,
    Text = "Okkotsu Hub", TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)
new("TextLabel", {
    Position = UDim2.fromOffset(52, 24), Size = UDim2.new(1, -150, 0, 14), BackgroundTransparency = 1,
    Text = "Halloween Edition  •  RightCtrl minimiza", TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium,
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

-- Decoração de Halloween: teias nos cantos e aranha pendurada balançando
if IMG.web ~= "" then
    new("ImageLabel", {
        Name = "WebTL", Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(120, 120),
        BackgroundTransparency = 1, Image = IMG.web, ImageTransparency = 0.6, ZIndex = 5,
    }, main)
    new("ImageLabel", {
        Name = "WebBR", AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1),
        Size = UDim2.fromOffset(130, 130), Rotation = 180, BackgroundTransparency = 1,
        Image = IMG.web, ImageTransparency = 0.72, ZIndex = 5,
    }, main)
end
if IMG.spider ~= "" then
    local spider = new("ImageLabel", {
        Name = "Spider", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(1, -170, 0, -70),
        Size = UDim2.fromOffset(54, 75), BackgroundTransparency = 1, Image = IMG.spider, ZIndex = 6,
    }, main)
    tween(spider, 1.4, {Position = UDim2.new(1, -170, 0, -16)}, Enum.EasingStyle.Back)
    task.delay(1.5, function()
        if spider.Parent then
            TweenService:Create(
                spider, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {Position = UDim2.new(1, -170, 0, -6)}
            ):Play()
        end
    end)
end

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
    ["Aparência"] = 5, ["Música"] = 6, ["Misc"] = 7, ["Anti-Cheat"] = 8, ["Discord"] = 9,
}
local TAB_ICON = {
    ["Buscar"] = "🔍", ["Jogador"] = "🎃", ["Teleporte"] = "👻", ["Visual"] = "👁", ["Mundo"] = "🌙",
    ["Aparência"] = "✨", ["Música"] = "🦇", ["Misc"] = "⚙", ["Anti-Cheat"] = "💀", ["Discord"] = "💬",
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

Section(tMisc, "Idioma / Language")
Button(tMisc, "Português (PT-BR)", function()
    setLang("pt")
    notify("Idioma: Português")
end)
Button(tMisc, "English (EN)", function()
    setLang("en")
    notify("Language: English")
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
-- NOVO - Tag: jogadores verificados (VERIFIED) ficam azuis.
-- Quem estiver usando o hub vê os jogadores verificados com o efeito azul
-- (o efeito é local: roda no cliente de cada pessoa que tem o hub).
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Efeitos")
    Section(t, "Tag — jogadores verificados ficam azuis")

    local TAG_BLUE  = Color3.fromRGB(40, 130, 255)
    local TAG_LIGHT = Color3.fromRGB(150, 210, 255)
    local tagFolder = new("Folder", {Name = "VerifiedTags"}, gui)
    local tagOn = true
    local applied = {}

    local function clearTag(p)
        local o = applied[p]
        if o then
            for _, inst in ipairs(o) do inst:Destroy() end
            applied[p] = nil
        end
    end

    local function applyTag(p)
        clearTag(p)
        if not tagOn or not VERIFIED[p.UserId] then return end
        local char = p.Character
        if not char then return end
        local made = {}
        made[#made + 1] = new("Highlight", {
            Name = "OKK_Verified", Adornee = char, FillColor = TAG_BLUE, OutlineColor = TAG_LIGHT,
            FillTransparency = 0.3, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.Occluded,
        }, tagFolder)
        local head = char:FindFirstChild("Head")
        if head then
            local bb = new("BillboardGui", {
                Name = "OKK_VerifiedTag", Adornee = head, Size = UDim2.fromOffset(120, 22),
                StudsOffset = Vector3.new(0, 4.4, 0), AlwaysOnTop = true,
            }, tagFolder)
            new("TextLabel", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "◈ Verificado",
                TextColor3 = TAG_LIGHT, TextStrokeColor3 = TAG_BLUE, TextStrokeTransparency = 0.2,
                Font = Enum.Font.GothamBold, TextSize = 14,
            }, bb)
            made[#made + 1] = bb
        end
        applied[p] = made
    end

    local function watch(p)
        connect(p.CharacterAdded, function()
            task.wait(0.6)
            applyTag(p)
        end)
        task.defer(applyTag, p)
    end
    for _, p in ipairs(Players:GetPlayers()) do watch(p) end
    connect(Players.PlayerAdded, watch)
    connect(Players.PlayerRemoving, clearTag)

    local setTag = Toggle(t, "Tag", function(v)
        tagOn = v
        for _, p in ipairs(Players:GetPlayers()) do applyTag(p) end
    end)
    setTag(true)

    onCleanup(function()
        tagOn = false
        for p in pairs(applied) do clearTag(p) end
    end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na Tag: " .. tostring(__err))
    notify("Erro na Tag (F9)")
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
        status.Text = T(selected
            and ("Selecionado: " .. selected.DisplayName .. " (@" .. selected.Name .. ")")
            or "Selecionado: ninguém")
    end

    table.insert(langHooks, paint)

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
    local discordLbl = new("TextLabel", {
        Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -32, 1, 0), BackgroundTransparency = 1,
        Text = T("Entre na nossa comunidade:") .. "\n" .. DISCORD_LINK, TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    table.insert(langHooks, function()
        discordLbl.Text = T("Entre na nossa comunidade:") .. "\n" .. DISCORD_LINK
    end)

    Button(t, "Copiar link do Discord", function() copy(DISCORD_LINK, "Link do Discord") end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro na aba Discord: " .. tostring(__err))
    notify("Erro na aba Discord (F9)")
  end
end

----------------------------------------------------------------
-- NOVO - ABA: Anti-Cheat (detector de cheaters)
-- Monitora os OUTROS jogadores e marca quem se move de forma
-- impossível (velocidade, voo, teleporte, pulo). Roda no seu cliente,
-- então pode haver falso positivo (carros, teleports do jogo, lag).
----------------------------------------------------------------
do
  local __ok, __err = pcall(function()
    local t = createTab("Anti-Cheat")
    Section(t, "Anti-Cheat — detector de cheaters")

    local cfg = {on = true, alerts = true, mark = false, maxSpeed = 60}
    local data = {}               -- [player] = estado de monitoramento
    local STRIKES_TO_FLAG = 3     -- ocorrências dentro da janela para marcar
    local WINDOW   = 12           -- segundos que cada ocorrência conta
    local FLAG_TTL = 90           -- segundos até a marca expirar sem novas ocorrências
    local FLAG_NAMES = {
        speed = "Velocidade anormal", fly = "Voo",
        tp = "Teleporte súbito", jump = "Pulo anormal",
    }

    local setOn     = Toggle(t, "Detector de cheaters", function(v) cfg.on = v end)
    local setAlerts = Toggle(t, "Alertas de suspeitos", function(v) cfg.alerts = v end)
    Toggle(t, "Marcar suspeitos (ESP vermelho)", function(v) cfg.mark = v end)
    Slider(t, "Tolerância de velocidade", 30, 200, cfg.maxSpeed, function(v) cfg.maxSpeed = v end)
    setOn(true)
    setAlerts(true)

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, TextWrapped = true,
        Text = "Detecção local: pode haver falso positivo (carros, teleports do jogo, lag).",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, t)

    local header = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "",
        TextColor3 = THEME.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, t)

    local holder = new("Frame", {Size = UDim2.new(1, 0, 0, 150), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, t)
    corner(holder, 10)
    stroke(holder, Color3.new(1, 1, 1), 1, 0.93)
    local list = new("ScrollingFrame", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.Accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, holder)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, list)

    local marks = new("Folder", {Name = "SuspectMarks"}, gui)
    local rows = {}

    local function newState() return {hits = {}, flags = {}, air = 0, t = 0} end

    local function flagText(st)
        local out = {}
        for k in pairs(st.flags) do out[#out + 1] = T(FLAG_NAMES[k]) end
        table.sort(out)
        return table.concat(out, ", ")
    end

    local function strike(st, kind, now)
        st.hits[#st.hits + 1] = {t = now, k = kind}
    end

    -- Coleta uma amostra de movimento do jogador
    local function sample(p, st, now, rp)
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            st.pos, st.air = nil, 0
            return
        end
        if st.char ~= char then -- renasceu: ignora os primeiros segundos
            st.char, st.pos, st.air, st.grace = char, nil, 0, now + 3
        end
        local pos = hrp.Position
        if st.pos and now > (st.grace or 0) then
            local dt = now - st.t
            local seated = hum.Sit or hum.SeatPart ~= nil
            if dt > 0.05 and not seated then
                local d = pos - st.pos
                local total = d.Magnitude / dt
                local horiz = Vector3.new(d.X, 0, d.Z).Magnitude / dt
                if total > 350 then
                    strike(st, "tp", now)
                elseif horiz > cfg.maxSpeed then
                    strike(st, "speed", now)
                end

                local vy = hrp.AssemblyLinearVelocity.Y
                if vy > 110 then strike(st, "jump", now) end

                -- voo: no ar (sem chão por perto) e quase sem velocidade vertical
                local ground = workspace:Raycast(pos, Vector3.new(0, -8, 0), rp)
                if ground == nil and math.abs(vy) < 4 then
                    st.air += dt
                    if st.air > 2 then
                        strike(st, "fly", now)
                        st.air = 0
                    end
                else
                    st.air = 0
                end
            else
                st.air = 0
            end
        end
        st.pos, st.t = pos, now
    end

    -- Converte as ocorrências em marcas (flags) e avisa quando surge uma nova
    local function evaluate(p, st, now)
        local keep, counts = {}, {}
        for _, h in ipairs(st.hits) do
            if now - h.t <= WINDOW then
                keep[#keep + 1] = h
                counts[h.k] = (counts[h.k] or 0) + 1
            end
        end
        st.hits = keep
        for k, c in pairs(counts) do
            local need = (k == "tp") and 2 or STRIKES_TO_FLAG
            if c >= need then
                if not st.flags[k] and cfg.alerts then
                    notify(p.DisplayName .. T(" é suspeito: ") .. T(FLAG_NAMES[k]))
                end
                st.flags[k] = now
            end
        end
        for k, tt in pairs(st.flags) do
            if now - tt > FLAG_TTL then st.flags[k] = nil end
        end
    end

    local function ensureRow(p)
        if rows[p] then return rows[p] end
        local b = new("TextButton", {
            Size = UDim2.new(1, -6, 0, 28), BackgroundColor3 = THEME.Panel2, Text = "",
            TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 12,
            AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, list)
        corner(b, 8)
        new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8)}, b)
        b.MouseButton1Click:Connect(function()
            local st = data[p]
            local txt = (st and next(st.flags)) and flagText(st) or "Normal"
            notify(p.DisplayName .. ": " .. txt)
        end)
        rows[p] = b
        return b
    end

    local function removePlayer(p)
        data[p] = nil
        if rows[p] then rows[p]:Destroy() rows[p] = nil end
        local m = marks:FindFirstChild(p.Name)
        if m then m:Destroy() end
    end

    local function refreshUI()
        local total, sus = 0, 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                total += 1
                local st = data[p]
                local b = ensureRow(p)
                local flagged = st ~= nil and next(st.flags) ~= nil
                if flagged then sus += 1 end
                local txt
                if flagged then
                    txt = p.DisplayName .. "  •  ⚠ " .. T("Suspeito") .. ": " .. flagText(st)
                else
                    txt = p.DisplayName .. "  •  ✅ Normal"
                end
                if b.Text ~= txt then b.Text = txt end
                b.TextColor3 = flagged and THEME.Bad or THEME.Text
                b.LayoutOrder = flagged and 0 or 1

                local m = marks:FindFirstChild(p.Name)
                if flagged and cfg.mark and p.Character then
                    if not m or m.Adornee ~= p.Character then
                        if m then m:Destroy() end
                        new("Highlight", {
                            Name = p.Name, Adornee = p.Character, FillColor = Color3.fromRGB(255, 60, 60),
                            OutlineColor = Color3.new(1, 1, 1), FillTransparency = 0.5,
                            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                        }, marks)
                    end
                elseif m then
                    m:Destroy()
                end
            end
        end
        header.Text = T("Monitorando: ") .. total .. T(" jogadores  |  Suspeitos: ") .. sus
    end

    connect(Players.PlayerRemoving, removePlayer)

    task.spawn(function()
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        while gui.Parent do
            pcall(function()
                if cfg.on then
                    local now = os.clock()
                    local chars = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then chars[#chars + 1] = p.Character end
                    end
                    rp.FilterDescendantsInstances = chars
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP then
                            local st = data[p]
                            if not st then st = newState() data[p] = st end
                            sample(p, st, now, rp)
                            evaluate(p, st, now)
                        end
                    end
                end
                refreshUI()
            end)
            task.wait(0.25)
        end
    end)

    Button(t, "Limpar flags", function()
        for _, st in pairs(data) do
            st.hits, st.flags = {}, {}
        end
        notify("Flags limpas")
    end)

    Button(t, "Copiar relatório", function()
        local lines = {}
        for p, st in pairs(data) do
            if next(st.flags) then
                lines[#lines + 1] = string.format("%s (@%s): %s", p.DisplayName, p.Name, flagText(st))
            end
        end
        if #lines == 0 then return notify("Nenhum suspeito") end
        table.sort(lines)
        copy(table.concat(lines, "\n"), "Relatório")
    end)

    onCleanup(function()
        cfg.on = false
        marks:ClearAllChildren()
    end)
  end)
  if not __ok then
    warn("[Okkotsu Hub] erro no Anti-Cheat: " .. tostring(__err))
    notify("Erro no Anti-Cheat (F9)")
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
                results[#results + 1] = Button(t, item.text .. "   ›  " .. T(item.tab), function() goTo(item) end)
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
    table.insert(langHooks, refresh)
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
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "🎃  " .. HUB_NAME,
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
    gradient(overlay, Color3.fromRGB(40, 16, 30), Color3.fromRGB(8, 6, 10), 90)

    if IMG.web ~= "" then
        new("ImageLabel", {
            Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(220, 220), BackgroundTransparency = 1,
            Image = IMG.web, ImageTransparency = 0.65, ZIndex = 200,
        }, overlay)
        new("ImageLabel", {
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.fromOffset(220, 220),
            Rotation = 180, BackgroundTransparency = 1, Image = IMG.web, ImageTransparency = 0.7, ZIndex = 200,
        }, overlay)
    end

    local glow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34), Size = UDim2.fromOffset(120, 120),
        BackgroundColor3 = THEME.Accent, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 200,
    }, overlay)
    new("UICorner", {CornerRadius = UDim.new(0.5, 0)}, glow)
    TweenService:Create(
        glow, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = UDim2.fromOffset(180, 180), BackgroundTransparency = 0.92}
    ):Play()

    local logo
    if IMG.pumpkin ~= "" then
        logo = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34), Size = UDim2.fromOffset(96, 94),
            BackgroundTransparency = 1, Image = IMG.pumpkin, Rotation = -6, ZIndex = 201,
        }, overlay)
    else
        logo = new("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34), Size = UDim2.fromOffset(96, 94),
            BackgroundTransparency = 1, Text = "🎃", TextSize = 64, Font = Enum.Font.GothamBold, Rotation = -6, ZIndex = 201,
        }, overlay)
    end
    TweenService:Create(
        logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Rotation = 6}
    ):Play()

    local title = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.47),
        Size = UDim2.fromOffset(420, 30), BackgroundTransparency = 1, Text = "Okkotsu Hub",
        TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 26, ZIndex = 201,
    }, overlay)
    local sub = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.515),
        Size = UDim2.fromOffset(420, 18), BackgroundTransparency = 1, Text = "Halloween Edition 🎃",
        TextColor3 = THEME.Accent, Font = Enum.Font.GothamMedium, TextSize = 13, ZIndex = 201,
    }, overlay)
    local status = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58),
        Size = UDim2.fromOffset(300, 18), BackgroundTransparency = 1, Text = "Carregando...",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 201,
    }, overlay)
    local barBg = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.63),
        Size = UDim2.fromOffset(280, 6), BackgroundColor3 = THEME.Off, BorderSizePixel = 0, ZIndex = 201,
    }, overlay)
    corner(barBg, 3)
    local barFill = new("Frame", {
        Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 202,
    }, barBg)
    corner(barFill, 3)
    gradient(barFill, THEME.Accent, THEME.Accent2, 0)

    local steps = {"Invocando espíritos...", "Acendendo as abóboras...", "Tecendo as teias...", "Boo! Tudo pronto 🎃"}
    for i, s in ipairs(steps) do
        status.Text = T(s)
        tween(barFill, 0.25, {Size = UDim2.fromScale(i / #steps, 1)})
        task.wait(0.28)
    end

    tween(overlay, 0.4, {BackgroundTransparency = 1})
    for _, o in ipairs({title, sub, status}) do tween(o, 0.35, {TextTransparency = 1}) end
    if logo:IsA("ImageLabel") then
        tween(logo, 0.35, {ImageTransparency = 1})
    else
        tween(logo, 0.35, {TextTransparency = 1})
    end
    tween(glow, 0.35, {BackgroundTransparency = 1})
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
