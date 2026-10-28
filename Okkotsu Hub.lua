--[[
    Okkotsu Hub (Universal Version) — UI v3 (Purple Edition 💜)
    Interface roxa: janela com sombra, gradientes, sidebar com ícones PNG,
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
     [8565124596] = true,
}

local THEME = {
    Bg      = Color3.fromRGB(12, 8, 22),
    Panel   = Color3.fromRGB(24, 16, 40),
    Panel2  = Color3.fromRGB(36, 24, 60),
    Panel3  = Color3.fromRGB(54, 36, 88),
    Accent  = Color3.fromRGB(160, 96, 255),   -- roxo principal
    Accent2 = Color3.fromRGB(104, 56, 220),   -- roxo profundo
    Text    = Color3.fromRGB(242, 234, 255),
    Sub     = Color3.fromRGB(160, 146, 196),
    Off     = Color3.fromRGB(60, 46, 90),
    Good    = Color3.fromRGB(190, 150, 255),
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
    ["Universal Version  •  RightCtrl minimiza"] = "Universal Version  •  RightCtrl minimizes",
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
    ["Digite o nome da função..."] = "Type the function name...", ["Nada encontrado"] = "Nothing found",
    -- fechar
    ["Fechar o script?"] = "Close the script?",
    ["Todas as funções serão desativadas e o hub será removido."] = "All features will be disabled and the hub will be removed.",
    ["Não"] = "No", ["Sim, fechar"] = "Yes, close",
    -- loading
    ["Carregando..."] = "Loading...", ["Carregando módulos..."] = "Loading modules...",
    ["Preparando interface..."] = "Preparing interface...", ["Aplicando tema..."] = "Applying theme...",
    ["Pronto!"] = "Done!",
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
-- Imagens (embutidas no script)
-- O script salva as imagens com writefile e carrega com getcustomasset.
-- Se o seu executor não suportar isso, a interface usa texto no lugar.
-- Opcional: se preferir, envie as imagens ao Roblox e cole os IDs abaixo,
-- por exemplo:  yuta = "rbxassetid://123456789"
--
--   yuta    = foto do Yuta (logo)         glass  = brilho de vidro (fundo)
--   frame   = moldura de vidro do logo    ring   = anel girando (loading)
--   discord / warn / sliders / user / eye / walk / search / shine / gear / play
--           = ícones das abas             check  = marca do toggle
--   chev    = seta dos botões / minimizar
----------------------------------------------------------------
local IMG_IDS = {}

local IMG_DATA = {
    yuta = [==[
iVBORw0KGgoAAAANSUhEUgAAAMAAAADACAAAAAB3tzPbAABCc0lEQVR42tW9d5xdV3Uvvtbae59y+1SNRjMa9d5sucodd0rABkxPgARIwi8FAvlBEvgFUklC
CEl4hLwQSKgBYowx2MYd27hXWc2SrD7S9HLbKXuv9fvj3FGxLSPJfuFxPxpppHt15qyz+neVjfB/+YsUCgjA4S8EQQAQVm29A/0l/L+dAMQWAXCYAAAAzC9c
srC/y0ON8n83AXL0/R1+3OKd/vp+33dxqlZNOfileeHhP8mzziuWPK1eOzWO8Ev0UgQgAm50y+OPbm+WK7qhQH55OIDiAAPfGO1sOrTrJwNXYfdk8ktz+8oC
di0a6CyXSzlyzah+8NmhXyLxQYFw/rJF3YEJwiAMCEFpW0eUXxLhYQjWrp/rG6OUMj6h8gmN0fqXRAFEgoWnL81p7RsQAeQ0pxVpZP0LFIiT+XC4ZGmfV7Oq
oJUSRCESARCiXxgBQsf6qBe/cUJxACilK5faGD2FgIgoCEgIAISoflHmXDsB9fPYQIikUQRck8JAgNDzCYG0MmRIe0rpXwwBCD3/sDSZjoXkiJbCCy0iecYB
KhCe2H5QlwIm3ycC0kohChhx7hfEAYqXf/Sqq/s3N4zgjJHXyEeHOxlVBhJmASCZ3DZY6vdZIQJpjxOHipQX/qJEiH8KF3VvuPihYb+lCQhoFDJoOlpRXOJm
AmmiyWeG2ysaSBvt5yqd7WXjpnf8ohwZAb//jzG37yN3GHaHHzciW0aQo6IbhJm/IIELz7m0VwuSxeb08N4DQ5PBL8wTo7Jv+4wHyV/+i8b0SPZiFFjr+EWt
LAI56F2pGtXqZDUGKPStOm/N/xABSPz8OyKdXPG57jj3H5+seumRN5VngFzTyXGyGwcAQJ1dfYuXLphbObD7f4QAEgFQzycBTbL8n9dPtf3093f49ug3ydOx
4xe3Xogocu0V+c7ZRZl86q5Zr/4fUuIz1u52oFDwGPfqH/rxwLrqgqv3b1b6iFdDsQkf30EIsHfBADx3x1e+8MzV7+z+H4rE2v7ga28PAUgTzjxJpbUJSH90
8NDQyCc9CBSe6MUIOs9cADD3k9unB/f/jyntZTff97FFAABKKa2UAgDwcrkArnhs6kD1+8vB8+hEs3wNACv+9KGh/fsPHlQv78mSnKgS7/ye+o0PnNtJSYIA
SFSYd6YeSrUfbrq1d21j8RvSJxLvRHJDBAAhUh99U96SQn5ZSqzci+jmcV7aSfEDvz3/0N4pCyJo2rvbJm/57s9qXjmx7/5QT+Ld9elHQLmfl1EKaBZA5RZ9
cZ4EhPyyAprc+y9SAOYEWa8Bej+5wzYmq7VGs9mYHq+62n0fXWn8rtza/5yo1/b8eUcWY744C7O3Qg2glPLycO4Te/cMHjqk4NR5QMnyT58mB5sCJ6SAjHrq
nu/X5nfGzcSlLBpjGLjqjeeVppL91z9QmN11yQU3NI8bn4pA2Lvmstec2zM5LSpNKzsOXkUgqOjUUzLBZ9ZeceGrZtVGWUDjzyeCSU3efWNjYZ+XAhKCkjQK
V73mjRet7t3+nZt31ddPPGjci7vt1Yv71p511sp2W1h32ew9tcvcUP4ZvCQVh2sODZ8yBdqe/a8qH0xtvPP+bTEAKJCfl6SgsjDruredoesWSAmACOiAXG14
17bJzt1/L+5FoSxauq5LxeIFoW+Cufy1fR/76ddHvC+9YZjwIxPfmzrlxJ7ks2+uKxPi5I7HHnpmvwUADfLSak3kpHjp2y7tkDh1CIjELKSMQajhe7/jJS+S
eBIwdK5d7UX5YuADts+/+Ym/3fNv3+n7SRCrayuDh05ZDVAO/EpBk3P+3HNe/6ZXryhDI2YBUHT8SwqTJFu/96NdqlTOBYGvHJIisUkUc77/23Ls9defGeaV
swKq8dye7kWeJeMFGF+Qv+XKq5f9cP/bmvgXu+947mQ5cOTzxJ95T2QQkAWVMen0wWeeenr7IQYAImB50ZhyxbuGnhwbHsFZyxdVOtrmn53ZdgAQW3rXN3PR
Uckyli5fOJLaqQMHxhkAVl09P8Ew8MOwb+PEpfmd7//D1+M1jwzKqeux4oEfdhAhCgE7QeVpaY7u3vzE5r2jx4lCgfQZn7qsOVifmGxIUK60z5IZAsAW73q1
lzqWmSQABc7ckDiQaHxk/5ADc94bitViRfv59nrouvb+5P0YNk9e8AuNw7el3Od/tWEAEbMfKSykPe2q4zufeHLbvmkABSyAdJR6E8OVnziPY6MBgK09nLUI
g3/lfUHMjCKAACiA3HeWhzpVxo0/sweg983rXSWncjlPGAvUUPYUBP+Ppg4eAbob1zpCJEBERCSlEGyc6LYlF1zzlrdc1T06JqBQRIBmJE+Itn9910BfOhkl
qXUAiNkXiMvrGwKX3TwAioDg9BZd4tA5rqzpn6xWH00v7GRjSECZJDmFpB6l9CfVh9XMzeDBq3otESIgYhZroVKELokT07Hk6uvWNvZZmXWZH0Uyk8ELaH78
67sHFoWpOxrYQSS38IfDirPbBxlQTRIF+tXFJFAGac65PcO1ZzdvmB1pJHGW+RQIIFnxLvz+EV+Q9l4SK2yhIoiIhISEqEiBi5vB+uuubB8a/p1/e+OqnUOg
W7LN4NtHv/50eV6REoHDiApCUhm+I28FAEHKwdRp001knN52TgXCMBeKW3h+Yf/eO1cvqyMw29Slp8KByy+p3DahDtetpt+M2CIgu3+EjAxCUgqjtP/KNy//
wr2/ctEbSjsmRauZiNLnp7/9k6muOb5O+TCggtj/X4mAAKDgunjHmUMpCVV3nqclCHM5Pwkuuogfv6FvfRNAnE35VMLp61YXdj2pZuJAHL1yXqIIgBARCAFk
JqpABETSNsqd/e7ad0orL3jz/NH9LNpTRASAgd79k2/+rJrrzvkkzokAYTr7gY2hFRBAO3JW88DqfSiiJvddFGPR5IvtZdtx5dm7v+lf0HQpM58KAd57Bji5
CY7YoYGLG7qldZkaHAkQCQWQSJpwzjl37V7gX/i28yuN0dSRNppEMAjtppv+67aNozqoBL4CZmf4Bp8FAZDSPasPem2jiAKj0xc2Pb8QeEa76bmvKfyDXDQU
sU2Tk3bCxD3fGkjHXjc2Y1OIL/h+ohXMhMKIx4QxM3SyF3wrekddlWDqqXse3HQoBpiBCTlxWOpbumjN0vacB+TWb/Rc5sycykUbHool7NsOb3ndaDGnEUlR
An1bPvIHr3tOC8tJE6DcmV9Xqf/un84kHyiFewasAcIXJeBw5ApSuHHquhhY50iGdj323BN7JqYZUIeBb5SzjVSCck93e6Xy3ac8BskUGdwSf6Pmd+iv0B+t
rrUpi6g0prp/7FPvXrufRE4aXhfo9RwGZ/z0CE5ee3JxIjPP/4hBeV4AIVh/7eMNTwiqQuVzzoVkeujAnqGRsVotdqTCQvuscq5SyYfd696ghFs6DXrPAuPk
xm+VPv/Ff+piQgTHxgvHCp/+UmcxhpMvcCD0G1ZwBvARobr3TScUjGBjXQyIYgC4JkjF9pUAAJymDlFr05I1173qae+I33Y7RfTUP/9V25/+w+cPJqRAJNHg
jRRf973fqIOctBIret3pFiG8vnFYVISuywzOEQk6kt0c/Q2mOON2SRFymsRJmlhQRhO4OE6SJE2SqLT73pw7mufAavfKC5d+NXfOqAeEzoqk6UT7oR3zppp0
0iIU9AGSm7USZmhn2D7onyike2yeq7RWikCcY0BSWhEAEF8eKnVMmUNU8oPqGZ/78t6KA2ZmF8cpTJ4xOhmdAgFhuyBJeMbhZytUfTZwhx+6CMhRkZvMgDkz
rxkeHPsClzohP18oFINo5RxLmF0KEFFIpfq+8fHz/+Qb3VnQ61KrfE0XNp3VJ60CxaITVLIe3BEleOwaeVn4DLPJAdjxydGqjbtWdK+5KbDHJim6fse7tryu
ds9Fe5WIY2Ymx2l68gQABYFDwWRheQoBWrjMRgtCgggggnAkmj/aih6tEni0hKOTAjQeuH/z9Jz+/p7uXBlxzffzM/8lu6ZY+vHbcpuv/fa2zggRUBJ0zI7d
yZtRF3hCiLZ3/pMoXgIA2Hlo62j+FJMiFKY8PPmNW+Nll120MA8gziawVjPSYTEkFnDevvsvfXbw/I3d6NLUxrGNU1CoTsEPeCgCKPlVT5J7+y0HEfniu/fv
WZfMyLu0YuHs6R7LAnyh7GDePfBPP1n1e1f2gUR1QBTAZGWlQUcVOcihCNx+od/010dxI4qTNIosGzR5ddJKDKF2CEB6LYBccjoQwsA5bp85FVxJUi7om95y
2XP/eeev99TqESpFiEgYPK+BQCm0+OQhA9H01MTkdHW6HrHyEE2ucPKFbq0ESMAuQGdW7f8RMdDVN+xUx0j8EQt1lGN+nmsQcaoYfe8rD/EffyhsMBkBzMJo
MVtG81H2vxGEAIRE1MTT505JnCRJklomhQp1sZI/eQIQGADRLus5uGL2uWGkoH4u7Ec5STvETMXqt/99k13w169qVvWx9zGe1lVmRlVLMBEEHjurZtklVoA0
klI6V2xrP4VWA9YghLbSc3AZLjztZwTNRb3PCaAgyozcypEQqKUOeDSDQMQG7l++vi2U8z43MK0NHHWfCABq+TYUUMJMhAwoCAJPjcMUIRASEKPRQc5z9ZPW
AYqtCAJwbhHMpfyVQGDD08aZnh/zvXREmOYm3/iHh0L/w9+YXTUvwKXirm92xRnJzAyZZ6TBz1c7IIkdGU9rUoGfK9oanYLTyZ6UmQcdnr1YO1Bw2mBNSfaY
8Wg8+SiI6mjwScTmD73lkTnDK6//iG0gO85e0vLZUF895+y3SgpACNaJZO/R439+M8+ZXfQIgIJSe5993DMnL0J25lYGoJ3i5aueBA1LIdbHOC052oS+CEpd
vPV9TLU//W0cyReOInkGF22c4+E5uR+OkAJAzi7lgEz043uWr1/YphSnzk08WV2da5wsAULNKCcASFKBHnbFC58EShfkkwJjKxeXIwJ9lEfGI4ZJ9HDus4fy
r/qzFdO5rqHN49ioWRYH0ZrzbPYpfZaDTfL6B7aloBQIECMCWQaqP/qornil9gFV7loxF+r65POBRiTcKknPciq9+J9ZJe09ETgh4FYaBZlDQhJ8EeMkfP/g
nb3/3ztUXe6/o31lGMw2igjJFl3rw0G/o2jSO2vxzsEpCwAOAHT7+dObx4iQbd+q1QOhj24S8OQ9MdbrgAII4Ld1shed1r/H2MLsSCxl1QEGFCQAFEWcgRTH
XsDm7/rxlsv+dnX1wEM3y7suNSACLAgI0mIAJEZLHe2Ed9r6er0B+d5lW27fM3z32z5cnWRngvYAE9u0BCKnkJE1JpT1AEiCBWWLaedZe8IUSk0BrUijOMeE
DECo2OqE1dHZfRYjy005+Gb7tnvvfPa63wuqESBTjsAmgCCZuWVFniUCsl6hPV8pBXL2+oM7n/zSrb+yJOcUjPglQPKYwaUnHws1JpQFERGzLj+BNl3z3UKQ
n2P8yaHJkUPDh8ZqzMACpLpeVVgzV0V4rKETl398g39++zd+tFH+8dL6lGYIdLT12UbH+Y6Mh5wggGcwkDg0AUIaTTamizlRvSuvczsOPCZaJFlwbsLgxEl6
8gRAupuElQh45yXOy5cvAb1/y6YH3e7JqefVPL/1qtLCs66dJjnSMw8g1Fy4rfSuz31zSv3LReOGOAfPPTY0a+6iigcwtT9SCxyC70GoTD4fGOBmgz0/CJAn
dGXdWQIkDNiUTDbxFJr+1NNNcIgYzV9S8Ka2P30z/PFHWz5O4QyCIoCIcvfKvV9Xv1LTzwdXt157w9eGwk9fMKbSAj7xLC+7OB19fHz/yFbv9O6VCwDBM1gI
GrnA85G1bkrihT4hupoiBYKoFDAIIOiT1wH2hsbaqei5Rn33Y49sHLHUuToYmC71efzF/Zhh5SKYZZXP/Ak/vq5bAAUP13Vc6WsrN/1ZWP+NayZFVZ69r9k3
+qX7nss8QN7vHWNA8BQGRQgCzyghkqZLnNIkZDKrKoKIQIKn1HaJUVwYfXJyONLTudf86uwu+du/8rHBHc99bKLgRFo2RQRA0P3kG8XU0tHtwRLsearnH3Wy
8oONuGvq49/oT7bUAUCXOst5b+js97gUQYgorCQm9AHAAwGXNnToE9HhSFYAEUn4FAjgdvPd/Qv6l/VWAsXOpvDGOE798IY/3Z1r1gAog9pRUAjCVX/1obn1
4KgkR5x3exuMLtv42cpE980f2wT7ADS6tmWFgmHSTRspQJegpmI18I0IK19RzTURladEiJkQyYmgYncqZlS5VYeCD5dRXBQBAgJuiGx77Uv/sUNmrfCb9bGp
egpaAIBIp3t/42vXrqke1UEg4e6hd/+/c+rnXBoHH/0c+CkAW9LTKy9RVBvfMgJaACVCRF3SPrKwQ41cixIrBQJkAaYs3REBcaB/TuwvL2iZ0otO93naECnK
3m2Y8sa/vrP4xivWdnsunh7d9fTD2yZZK0QIbxv+85sa50/6R2Wkt5+tJnpG31vZ+tt3EcQAqMTvVO6twC4Z/+8fva5Jwpagz5bFgE1IQEwRqnbSppUAGRBE
BISJQYR/DgfkhTRIaYnlnKewFdwIl9N//Uf1W29aApFlCHL96984vvWm/x5SISvsefa3/vGx2mvGD1OgajtlWyDXnv+z+7crtAAgrlS+6u2ummfh3g2bSAly
TNCYZViEkJHBeVpNNSactIdCzJrFOWARQHrJ1mM0/X5Dju0JItX/5tCYVk0Jkb22ez/wk7d/5pp8NXIAIDaNE2/gisuTjXGJtOSrN752ZPdZ9RbyyOET9y97
sOMdb6gfOv1fWRhILnr1E+/96NoFPpJyahdNjPeye/QsdfsyT3kKkLQxvgm8tJFahpxmAAJmEAYCsEgv1Z1zze9vkDZ1TK6CMrvChC0s3UFH9Xd/6+zbPtF5
qIYAgISEwPHEcP/f/+CCaS/wqSIfagx+q41nWPp427K3f+rSlC7aNDaLABCmtq3+/f5EAACUrtNTAw6cVXVVIGO0IiKlFGJxVoVro0MjTgmgsAizs8L0EiKk
3HmXNA1sMPdMEB9FVZfnsqfPzhTrX/3esh8tnBpCz9MSp04EdU4BYBqdd/Z/fU4CWz3n8q9c5r732oQAALyD1VctLDbrCPDdXPcB4xw+7b/Tc14jBBSASd0u
kc+g9zSMU0KIAEyCSMXu2mg1BezyXJajMQPJS3hi5M4rE22wv6vyw7GjKIB2YiIEkIIZvO3Rni/MnTqIIdZ2jE1PDtl6I6rW8sVi55x5bV2/vuyP6x3NhVfI
1888p5Uqm7G1V9VqQLb4+O2n+cu2Lt9XDfw7bn3Lw1OXMwomg6/B719rnE+7eyKHAKjEZr6RiqWJasM67jIuw19BHDp8CQIumBUrzPWaRW/8RuMIA1R3VpQX
tfHB2oIP9k4fQtF7fyZUVRMHDh44VG9V/td+oDd31j/9UdS50Ez//i13rDGCABQvWBwrAAH9d+dGZ79jnbx973Dlwt5//+6/AIrTW/xoWylMUx82L6xbUGCE
FaAAI+pSbqIeW8AKAlhmS6KJj0sActf5mx68xisWVLT8yuuPgGSQn0ktd5+2JqwOi/PLQGrrzi2DjZkKAhHwzrarRqZWfvav9nfMfevdb5Xf+fcmIgBoERTg
0k2ybs8HZ3/lXdHFiwv1T2/7zEJBYXPv6jvOWlP3x9P62BmDRhtFjJilH45y5YlmLXVsK8Rs43pkQq2PT4Cc5/33/uqKkvKUu+DZZ1pCJCieABAAwq9wtSES
hEP/ffNjBwAAFAAwiENfC0+/Z/6KenXxpz5hvObOd3/Z/OSqmp5JltkMf/uah97aU317/5/fkGDh8i+sYBLrP2Hnz35ALYHx9NkiT4VaK43iGFGYgUzHVLPR
AHFpRaVJrd40Th8XG0XuOufx/Wbz3oUMucS9Zkd8uONKU9bqiNPCUlRbv/XtvQCgRLJhEQDgwPiSG/6tO0jV5/1xLbn3o7d5lSevmillA4j/zNL2wrLYRBfc
OjiOs9uBCcRM3R1+I7j3PSqN6NEFw0riVGsljgUZmTy/0hslk7XUJo08xc2I04Z33BEUkg2rrx8FjJv9fQLclmynlmtQrxkQTxEiIOfzP/vEn9w5pY3nZ3C+
YgAkvu71fiodz0y8taaS7p7mWZN3m6V3XJw/DJiLVJrTC1YwacuV7u4wBUKGxhfb9z/RdeFpiTf4hF6xn2zCzib1RpSKAwAh0WKtjRKOYmutiNLOHa/QLfCq
5BYngvG27gEG6N86qaRFQD/7ihDFBps+/CfPxF5QyFnUlgEAl9WcOr1yxR9csGpquHJrxyVN41ip/x6YLB8KVkWtH6ZMlJ8Tb547y4CITa14KAjJ15Z9/5LX
nLHIWbP3m9e6UWCbxlG91mikQsAALBCCY04i56wOCY1COW6lHtc/txWBwMSP8VKyxeJj0uLA1f0ZB7z2+q//RHlhMfRnXf2x7XuVIJg/e6C29JO/tqo9P/9C
3jjvB6tXRgpMbf5D/bXw8VcnBAgg3r6d8+Op3vLNe0w+0NoYlTDapls29oNla1OXSu7BjdftEEjSJImjJElRG5SslBCgKBen7NDLGUSB4wZzUn8OUAQxrN+w
531hsmbOvswStVqdhPbedr269OEyycqrXzU//48IIOB+F/v/6BoEgUj/P+7Hv/1PS3sTTLt/1N6ATrNpaUwAAFz4z+lznjjHO1c9fXe+2ykYii7paertNw79
8fyRUmQQq+fub3pJwtbaLGITAmRhAq/LjOiJet06USEI2eOVWRHm76yhLBNooBrcsxYqQ9sJANDgVXPBECJuid758d4fdKx5/4cuKTWChx8JgZE4d+nHDaQE
mEZnbMyfRvNT8Lc81OMOXvufldWxQgDk/DqVPNZe2dh++coOJcZ1bggjs/WG5a/LVwsRhBBswoLllC2LEIiQ8gyQOCUIOgxEJE6dZS9ARnVcAhYM1mXlyrTj
IDpzqGOVTh7OdACumMeeQoRFZ5Qbwd63fOhsLwbl9Xw16DQNVl0Xrd/+8EJkESba2tM9h0EPdaf7Ln6Ct16ZhRPogu7C7JuiN3Uk0PbMxrFxb14K1jttVpzm
m1EnYvgwVmJgztBuBFHGeCJABITka0FpNm3CniF8CU+sMP+2+9aPPIEgaJX0F6eyNCJt1ejrdeS2zxlsGI3YPPMTn+xf0XD5HP/lbZ/1YxREW9lx9RkpYbJS
buyzm/qefXZhQggAyLH0/8HWaZ8g3nCWC2xTQEwMQImdLb6Y4fksqFJAVAIM4lLracsCwiKc71YGR2tJameVXwKZC3Jy7cDDqzeCAENnoma1VYEBARLKEl5l
Kd+cbFMGCUDV/6T62anl/vTen3pfvDwGEYftNxXzUSgCfHDHe/98jln53BIBafXlJLIsEQQF5GImEQGJlJ92sTFWY14ROwARRgJBYBBSCCLCzNavGE0Ha9Ym
tu34GVn+wjVXuLXFLm2RK7OQiov2KD6MIAsjuW8su/p7bW8ZV4KA0PibV/3bU7Vg7jve29tEAFtofG7RhnsXk0Uw33jX9f7yg7Ouv+roWD0ibNWUrCgnSuXB
GucrCGC8AOQciAMEIBZhR4jonBMW59gUSbmD1WbKXDouAXyxR/mVScKI0tP22OLK1Q9GJCA80QLO08J1b29/9593XzKhFQC56lVX1WOvAGlNiwuDR2/dwJs/
3rTkil8+c+jZy0Y6tvY1qNXNInS4qYJIlDCzCLMnPmk1fvdkGKlUWEiEAQiJBRBEOAP9RCgnSdSoORY+bkLDYrXCYBeTwMDBL2zm1VckBgF4fOYTUfiZ/73r
47d+s81LWYCoWqW8rk/HYP3Crv918xX2rnfVLdriA6NXzPr9XDK1eMrwi8wFIBltfN/3fD/IGX+P3dRj0ZFjx+yYlNJaKc5GobQf5sLQ12QKlc5OUx06sJ+O
W8nTPoGhJgCAuil9OrVvmSOEghMsksFW8apfe9+DH9/7yZ3lnEtFGeWSFLRfyG/65+vXf+IHOxbs9VCC5378/kZ7z5Ozc/snfZ6Jh6TFAcyqOojaeJ7nYfEA
T8GeEZMk1tk0Ta0TECfOxnG90UjFC7zA97VRJl9qa9O14f0vkZEhhE9WQwCBjSO4dbJzzts+56dIY6kSEUBmO1y55gsX/cq2b7VdssKHNMEcgcjII1tgde+i
fzjfHFzZIIH6e/P1tn+f/9ybX//J59cKGFsEMCCAUvv9aOhcW7wnlCSyNk2tExMggxALJFYVwBkPnKSOLeTaIjtcO36vhDVItOuBBSCA+0gasUlee+fTPkAt
KgEgiXNR03VHn/jyFUvzP76lc2BJd7qjOV4Z/eHcDTigR65avPWsmADTpdIsPtXo7tvdfmVNHduF5qestU0MoIhI48Hq1VvXumCzrdSbcRLHUZRYEyjhVOcL
HiCkJlWG2QlzkqqwHEdjteM5Mlm8BgGH7+nalbG9cnkFSj13olLmqhIqBOQ0jsawozath3bkXH1Tc/boLRsnJHfmmkB7QdDW6M6iJ8sIt51792/+77cvTAjx
SOFb7Xqyz69t3d+RYcK0a+TMSOXCTROXP5ivxs1mfXpqYmK6Wp8aG5uKSBuVNUmliWOwaWyRkJP4uByICBC82mRQBxCSjpC9xrmvuSFPzbFeAQQGlzQbg+Hb
D903fHFcb3+fmYgvZxvbeDTII0tq0lYEDhRd9y9vfnjgsuoxozbI/bmDQ1H/vC0rcowMsnwlPF3MJ3LhvqRRSxvVWrXaTEB7JKKomDdolLADcQKkQAT8Ntds
HpeAhiUUigZbWp5HC2Lf8/io1xzRrlWqaDbS56TzTVuDVar2mdjpV+dTRAq0Q6U0HS5Turbb23PX/2EN4dhOZzUysqDfu3tezhFaEk7umzsvoeVqrDYx0qxW
p6qRiKA2hdD3kzigFAVRmEkpMR5Y1NicPi4B43EoSU/lYCs9GAdJwnjeO/7e2HHloDUXlUJ46GDX8nSPz7MxV2k0lEEvIN+jrMchA/e8Q09c968fsmhNoo+u
mMm8dWAn1xcSSqNy7NVurK13QqnB5v699Xq9noLRzEnBhD66ZoAI2hAoIlIEQIkl0zV9XGQuPqcEUmw+leFyOJGuqThllz85ZBac4zQBiqRxNdGq7A6likx3
h18bb7JBv1QuhtocAXQlvGnNrdf0xZSiM0danhDAb275ztL2FCi63e+evGX26ihPwN7Gmyb3TkzXIvQDAlLF9mJADKQA2AmQECILWEYgdVxoEeP5C63iRdPb
QSkAwW0PF1Y6KffcjZVXiSZAEOZG3eKgKsejg/v2DY6l+XIlKHS2lUJDeGRADZPFydw1dQUxOb9V4Wz54/1b+tZNOk/84NlCYf6igxOuy7L30K2TI7FjHXjG
KB20VwKF5IUhgEsdgqC41KaW2SUIxyUAxs/VTOqM0mCVRQHo8XuCc6xdeGhb+VV+1rNHjpPxKL9vgtpnVdpyHWU/yBc72iuh1oqOajpA0za7oQFiVKoVzGVf
rnuLHh1vN4C7J2c1d8zx2ipanH//nbVUMAzDwCgTVDqLBskrFQMFlklpBSwutalLnXPquCKEE5PrUEBWXrSuszEBmhEfWrsg9hY+ULu0XRABkABzZac6vJri
hgbQhbbOjvaSZzQhHt2fJZASxWDBWH1Uc68Ltw+vmTvgAfDcZeXpcsHPU6Kd/80nI4GwnA+M0V65q2RQVD4faHRWgjDQitilcWKdE3qJvRJq16GVHmsb9p1+
8ez9U4IKJl8tPEfduWFBohEBUSN7bfmg2N7VXsyVu7tnd7e35TytEI4lAAgBYkxFW5LGzOCi6JHHry1FmhEwTbmt5Ky/VcrWv3FLimFbKTDGBPn2oocMXhBq
AFE6DH0lwNalLAIo9vgEiNr77OI2pzWzv/qS4r46y+BV3WKXPxJsiBQCgKDWImiITNDWPbujvbOtEBijCCl7zsf0KkYmTYOYvYYwZQbKbFwF13dUss4EsOyC
/T+5AMX9r3Hwy0VfG+3lSkUfklS8QAOS0mHOVwCOlBAREb30/IAeebTcr5wxyoZnXVDGxf1r5jAX2p66ULI6GKLxdBAUK+3tbZVypS3vG62plbIc3WWGANII
nFMNEyQmzSBldD2ljXO8SmskGCU4+HR53nDl4Nd9zBdCj5QXFAsBusiZgq/JM6jDUBMJIChS2mg63JxwnFEHJxe+tT8ln4i90HrgfALM3XNGm1OEAAQgLnWW
EUlrg0jqmBGII2osCLGfVHUUVmqeMzqbsBL2Jgbnhw5BAF1u51QyuLyz667fXDtmPSJRXpDztEsSyZc9zwc2fuAhijjnhBmt2NrISzZ/o9Y7HjUDfqqUh5YE
AiRS6ULimRZiRDLKeJ4X+IaUPhzr4PO7LBGNVUw+m8hgS0kQiAt3zg8zFgTPDp9966rFyrup5ApzbS7MFwp5X6Fov1Cq5EIjbIynAVATAipC7RmwL929jhjU
HtzcOZdZoVJKASEm2mYWKBu8QiRjlDGkskkgbPXaHNukiyDgYuCHejvCafKO1Cyfap4ekQCI2Xlo4cbiuRGor/7lpU/wEikWS56nCPywXOmo5D0EIVIoAqQZ
WBSS1urnrecRUd6Be4cWtKWESAQo4V312ZEPh90RocqmrWcGmWaM/PMIAFA64QM37dw1u8KHP2hvu7JlchmXbStNdFLw9ONvCC/fPLIk9ckgC/ilcqXgkYBY
UpocIwowkFKglHrpISACAAFfbXlw1oIEkLLE9UfL7UM9xK2bFIBsY9HzukOPJQAQUCjwVqxzyXISL2urEX93bnHSipnCpCuqLW7k/2XVuiZevHfroimC1LLo
vE+cOHGpKI2pY8dIkpXjiH/OAETWvCHB9E+TFRCDgHPNys49p/9Hc02j1dc6I+2t7pEjDDjSbHb4O0HrL1rm2Ow2BhAAbbFV3gNAgOCOcwmbf/OhNgfJObv2
9lY5dQJGSxLHbK0FUuTYOlEELust+jmTfIfHZLV6fO/qMLU2SWy986aVe2+8yEvUzOgeIGDWgQHHSNGxtIAAAnIci4r/9aKZkMJs27Q0zSqe+cdxxXTlhrue
TdamlGx4wOamrCU0ITlrHTsmUuAcMBG2xrtQTmwUUQT8nU8GShiYm2ZqS//16swoG1yQw0qbSdwRjggc6449kyACoit+buJ1LahdvC19HQ5BQLD58AUpysfX
9fx3fUOCbv2NA02H2niaxDlIGVEjOBEBVIQirBTaEyJABEC84Z/99P6HHt+ya3i4eJ83+NSKvphmzM5RRgcwc8DPlyUAPHCo1ySIrnLTxIb+VraAdnaHQxAB
9rdW+qPSD25fWz/tx4U1EZeK9y6d9lXgoTA7QSClNDoRJlQELATi2P78hudMGwmUa03ukpEuN3r63/rG054iJEKg7PnjESN0dBSBAELT11f9Sxc7Dp/+wSdS
RjwKYQERcKV7cisPznl955w09O//+2VNyv9lAJPKoLA4B8oYz9dOrANCYzQ7EWS2JyRCKIBgmYCICMVKtaH3l9dFpKR1fzPDrFmvKL6QAAR9zkXtd9YWWvud
39R8TKCRxS1TD511z7zbr1/bECfFW67SAiuu726CADNbJ0BKG20842lSQiBJYm0an9A068w8TjbdIwCCwrTj9A4hIMwiN0ABoBcRnsO/U9rsPrtTcjt2XFFX
L5iFEG9j967FHb/XowRsMzf23BWRay/fPruKAiLsJIMlTKGU02KFhW2SpHF6ogS8sJdbV8fOQ0IgnHEHR5t/fBFHBuQiD1ywxEN84aQf8r6liz9738JIa7H1
7kdnr4jtouDursBZARFQGoGMl/e1a0YJs23W45QBTnm7Deu9nctTopYGtDC2w030x8RCLelCJAAwRQdHK36G22J9cEVl18fnMxI7gGbXLRd3xXZZ+BB2FFVk
ldYKjReEmmtjU/WoPj01XbOkTnDPHL64bdp1dlEUCh1xwXJ4OwA+X4yOXMMdUYCZQFqEpdvmPvXcLKdQBIRV8KMLOtN0+Yb4wGDaXYi11vlSMVRufN/gxPT0
5MjYZKJzRk6AA9luwxdLF6anz2VERKJWX9RRUXRLk48aRpHn+fejR7FEAKPwnr8fsFm8huDy9L2eRdgI15w7n7bv7QVSuaIn8cj+wfFGszY5MRXpfNHgCVgh
FD9IXowJrHbNWZaajIDnm93DIxsILzZV+XyQF5xl+97JbouKhEFAXHHOnaq/yHXsXXX56FglRnZpfWJotGmtS2rTDSx3FNFOn5AjK/UmyYsudtx9VpEJSM1E
1y1hEZkxTHJsWna8oNEyxm1/d7cfFVhnLadEAn2DO5tdJUzqwTMjhUSSZrVaixgRAclirr0jgMbkCVmhul4bDssLF/moyYnznadwBkM5Im2tjPiYzOx4BBDD
RKyDRz/WFxwKjCPkrLEVXIjTjz/TXlH1zy+ZdEkaRc2YSdAEhkyxUjaxjesnpsT1wRVr9icv2A4r6rnOVU2VGSIBQAE6RvplZixIZl7Zdywi7ABREN2mkt4b
hM3f3ZdX3qEKCwgDg4AKi80dcOYiCD7fKEwnURKlqWUEBAzzlVKpVMyZRuPEzCjyLnMxHYQXMAG3ntllNQKRHB4kntlSgoenkvD5Bk2EPD8fWgsA2A5SVsVP
Pzx7uKh5rC3r+0XEktscvO2983zzxUcXjtg4TdPEpkSAJTNdbyBEB0YaJjjh5W7c9tr6bVVC9zz2n/Y3vgo9nzQCENCRmALxaBQxo09agSvp6tjU/vi8LgsI
4CX14h2/vSje1WbUvs5ONlqhKsp45ztfrWuFh78wcfooxS6rbAVExUGz7LS5JZ+r4488MnXC02vKwUVrn3jAAh1TqdP2Hb9XDwNfaSLJ1mLMECD0/K5TsagJ
ACj6wU60sX3HGU0A5M1dbdWraovs2Fh/ygfmg/JNzk50vfVN+clC+s3r6eLtKNY5BmHUhXDHlde1p0kKhNpr3nri43cIMnCNu30LgD5qbxAS/MWljbyvDdHh
4WaSGX3GI2NALMrXru58ELC1fMEzULMAgu7prvm/9+VSf3tjZ5cxw9yjlTvov+cD3VUub/7axfE3Fx0A5RyzE0HVvfuj5084JARgsZg/mflBYv/icwYf2Nls
hcsiAEDQ9U8DLvQ0kSLIdnu0mmKP2Hlg8Tyc2rNrDNettASorBNERSACMtl+z5tCNgvMwaTDqcE2boy86h9WN5ple8OeNy/41SJNsULrmEVcz4Pv/MhBPzPO
wgIntRxG0O4cWnrO0pLmRGYyI9DTm88tpXg4sG7J/+FAXFgc5IKJjXc9MNK19oxumw2FZb2zgkJxWHvXmMdJUqYoB3E1iic+8uW2CVXZ9O3+d3Xcc/vcYYsA
zAJic+kd7xlo1a6yHPzkJjiRXO7c9e3cqI5PDo+PVi0AQBid9qnexPO0IiJCJDiCraOIsAkbmzbW583vz2PiBEgA2JOZEHU4HPnMdz0Sgb5ykow3yzj14U9U
uTJ1c/Tanpr+YK7WFIXAzMC27dFNv/VXdT3zAxhOdk0eIkPHupVziyTg4tqBvXsHxwVg4afXNsHXGkkfmf0HBAB2ujh2/6b2Mxf6LnGiEAEd+8VJ1JLV0/eM
7vt1A8TA+Uo9DcrV5vv+NPa9xx9ev8FVK1+7qf2QylbOACTeEzu80n+d1tSIBALAeAp7/lDAm7tyxewCkgl915zYvWfX1sb73t4OqSKtsttXCMAEwFAYuX3f
ggtmxU0mFBCwokJv+KvPfMmIAIqk+uHfHgYGFKfLJeVNNK/8q/Zw38OFi4s1CJ/7SN8BK6yzhQ2Rd9+wF1/2pUKiM2jzlAgARAbwB1atWVRCAt8EHtSfvlsW
r1jWpq0lTZkxlazv/Yb7L72iVE0ABRwzaqNqO27+r1l/t84RALA0in/3t4YFBCqdvrjG5PIPv1bdOP7q/qZTEnwork6lKYPnayJo6O1bFKXv+mtwasZhnto2
BQQB0AvWLJ3b124glnwpHNq8capz2cpuiZlUK89E0dWbXtMz5QBYkJBcdHD7k09sn3rHJ8oNBcTgErX9jTVGEZrTJix2z9LuvzjrP8zb01iBK/zbLZ370oRT
0X5oNNQSvs+isu/5U900rSWLp7oOAgmEAYKexatOX1pMLRTKanTL5uGuVcs6XOQUESIIMpZqCYEYP54eGt6+dc+uhnazfuuNLtUEIixN7/23aUsCAyUmhj1t
C/0ratFfVFGBKzzxu30TNnZiQVEhp6DZyG3eQ4J8zZ/MqVsyL5KangwTkAg5BfDnvf7C/jym4JfM5LaNB9pWL+1wCbcKSY5QxBv8xoFnRppWhWVsnvPBlY3M
VTiJw+98xFhB6ZnlkOmQXZzrao59v5ISiI5+faQJSgSYUZXyBFFTokdEkNzyD15SSFsJ7am/EImIQFKeveqcs+aXOeGg4I1tfWq8Y9mSjjRmQsoiUX/PNVMl
IqNxqvvd13pNzHaoiHXjbxgFRikPpAQwNbow31Z67i+vmDIAkv/YT23NaEQUAAp9SeuNyB1MBIAYz3zN2X0+u5ez8XVmKRgpsqnuXn3xhgHfxsYzZnLXs8Ol
VYv8NBLMzH7ws08dLBI05PIPLK4KMQCBcJpUPvodbQG8+RqIJ0bnFkvhwT98+6QBcKX/+F/5YSQipQBZJI2bURSn2SpKAobeVaeftqD88gjI1pkhEZFw2Lt2
w1kDtbQTWavq1k2Ts5bO85MICAFc4dl/fCjRi3/tUsj20TAyJKi/8rdkBbEvL5gedL2VsHbgz35zwqC4wpMf8KeFtNaKkBv1RiNOrRNoLfxAQgvQtuqyl7c4
GwEpW80GpDWq3MCFc8f82Yvn5BBl6OktSd+SuUGSsqAN+LEdvWeX6y2es3AajvzDd0gEsLMsGnbne4rx8FWnv7HABCL6Vzdx6gUmJIJGdbreTEQAtJfLDyU8
g8IyeC+XgBYFiKh0kA9Ucvon4+27pH3ZQFmr9OD2Ldy+pC8XRU5USJIk2Z4IB0403v93WxQ4gFy3GBks9pixjt95571zZzGCrfzrp4oN0UFoxDam65FlAFRe
uW12/4Hbjmpu5Ze7ujxb7JeVS7RXnH/2FQMmhIkdOycKS5Z0GOZD27ZNdq/qDdI4VYgEyILOiac3f/XmSDkB0N0KGrVyX6Pxhg93x7efXxBkPfn6CU4ZW2ug
nKCgzhXbuufMDenhH1l+aczqJDhASKRAHIvfvXjNWSu6KQIEk1O1vdsOFhct6lCQjm3ePtWxvC8fR0CAzKy8eMeNPxz2nQMB6nAN9ntyg/M+dnU13PXsq1Ml
afs//U2xahObOnGMAkRBrlLu6Kx0+JzO+dq9R7Kql0UAEiEIOzTtfctPXzKnTbHTGgBRWAemsWvHwdziJW2EPLpp++ishQtCF6fgm4n7bn5k3INIABAC4WKp
NJW89Xc6q4VDD13U5hAgfcc2bsaxdQCAonRQbO9oL+bDwKOkmTvwb0cwnpdlhQQAVKFz3qKFC3raPAdAmhS1yq/CKvCaz23a37Z2oIzKjmx6erB71aKi3X3X
HdsiT9I4gyC9fDkvw6s+tqFBasvQ2ZUUgAu3fDCtJc4BCpD2c7m2tvZizkdjCJIEm190r4AIIUi+o2vuvIG+7pCQBY3WSmG2uTOzscKU82rPbhnvXjK3qNDt
feSZKbfxuVqobZq25LhczqvRwnt/zU+C/du6T6OEQFzwzpspcQgC5BVK5XKxEBqtlNYAYhPE/11HefkcKJy3qqczzBtSqA0qpZUmmkG5CCEDiVgH3vT2HfXi
goGCoeTAE/fct6uJAbQ29OdmeY30ig8uaZjx7by6N2ICTtp+/BawIoDKL1TaKqWcJiRDiApFbOLavr7/5ROAkn/fcuuZnO95WhMopUkpwqyfLasdZ0kfiwmo
umfrZOf83iKiDD91x13bAcAwg54t9XUfuCQV2DK5ZIGkhCCJmX7dRsVCXr5YLJSLeYUEGlAhEAqzc+33HdHilyFCMue9A0lQ8DyjNYlSmrTOoqOZmn1W+VAg
IBToyV27p9oX9JqU9dTjdzy0IwEACHp/8y1hvTC0cfYaL9vg4FTt/TdrS2Gh3F4paj8LhihLohGE2YbpV+JXQIRQZv/asiTMa6OUViobO1WKgFrtQq3lowQo
AMLap+ldO+PeBRXrDI7vevD+HUnfhrctaXrwzG3vWJC0cAya+ti3wtgUuirltsAoBCcAokBUBtUIOyrc8gzKyzejxKW3bGA/MFob0koRaUJSSIgyU7ZpTf21
Kt3k8fCzQ8HCXi9NPYrHks72CPKDu8t7LtdZm6CY3cM/+/IezC+qVMphVk91IpzhfiAAwE68Az+agaZezgEKQtETtfmhZVCt8pK0dgplIC5wa5vT4eV/nLj8
/AVmz/apsEgJldspCZP7D60dmO402e4Ds2fXKnwfPRbP7s2XPKU0iqAIiLPOWWsdO8ecFoaqLZz25R0iQrRzW2cPW1QZQJCVFDkjBLORrVa3PguwCIhNoHvB
7PqOfWk+QGfM0EN7XlduDPUpAQTRg1vPrU0su2zhPYdWFjxPKyBhscDixLGz7JxzzlmT7n9FCBCgiUdq/XkLQpJNuAAwCDMLO8fMLMwzoHrGBZQk9XoGcsO7
J2IZ32xX5jpMPDIHEZD1+NOnq01L/Gj92h8mK0Uzo01tatk5Z9la51y2DgqSvfJKEAAgxNuf8WZDelh0WMRJ1iPvhB2zCENWNppZ2QwusaW5XXbi4OTcZf6h
cr4+2gcigs2nluUe6et1VF89/yuLO60TZ5M0denM/UM2rOKcGozgFSEARNTko3s6uzmRlFkYWFgY2IlzkrHAsbBkrMh+CSKBC7s6CgNdFiaLuenqHEER2Vlu
f6R3fgqA9fXTd589bSWN09Q5YceWrXNWBJjZMQ7X8JUhAECIBh8Y7apIygLCnImSCDNYJ8zsWIBZRBwLMxIpTa4+9Mw9TwTtSsn+zmBQehwJRMZ7YP48iwyA
yRn3gWcxSa1lsU4cs5tZF8bsqNo6D/SVONKOUSe3P3De+Qv9JDZaKaVa7QdCmZChbkUYSCD1tF4dGdr33Ej5nIsWe4g18dxkO4gT0bWvjoU9mkkAXel9354d
Q2qdOMm0yomAICEhO9e1N37FCABxoOo/uWf5Bes6XMogjEKEhCwKBEWjuNTauNGoTU1PTzea0UQ9WHHtmbPAspKRoh5vLEkFGIdvfaD0Hbchwy+bpz+xF9A5
FmR2jlu72pCzbk+vEKO8UgSAgEOdPvlk3/qVnaGvSaNWAuKEoziK4+pUtd6M6lEaxcCYyxWWnHn6XD9pKkBuVvvsnllhiihDQxc9MDl955JZVomw+Kv3sEMG
yQxaxgkAIAd4ZB/DK3YqoljQsH//D3LaM8ozhsBxGqfWsmVLLTQZOIaw7+x1S7sxSZUCEDdC4V7qs4Iwva+3a9795YmhTmEUZrew4wCozDoLc1baRMnaYoAN
vIIcyLhgkRAaxyTMWalAaVIALk7Fm7vq7NW9IaYKRRwJNsY7RyYWOEa0+zBMu5KmrrETFEFum7Vvxqs4dixOAFgQAR2y+Fk09IqeSylH4FZEIJLsh4IixZy6
YNbC1SvmlzQ5ICZwJOBGMBqdbVyi4cDmuQkU0iSKnBNEYFbdYrNamLBzrYOtUbIeTw5M+ooTMMOK7DdGzFbiMzejsNy7aOH87oIHDoEQhAEcwfhIOFQoj9zj
XdHYGaRDXV6jiZMpACCwo34vZQRxzjG7bJt5iwUITNmBL/+HTgbNeuiyeE6FlTnz5vX3FkgzMiECC2XvxvubtlB68Hv73joxuSA9tNsPwoapxZTVz6JyV5VA
RNhZxyxZtNhqNGTlwf9BAhiAAXSQq3T3dPd0duSIkCEiAlHMhFl8lx4azJuJG+/iC1eN5Spp/LOdbSu21Jv1QBGiiDN9eywKs7WWHQsI8OHz2Kzy4KWWAhy3
d4jl5x8Mi6SDYlulo7O9WMiHhoCbmhRoZBJkBiIgYXETm5uTY/fun73u0tKoj2bW4n8fM6NQq6FRmXcpqATFWXbM4ly236yFKjNlx2GcFAF+sahtvRGnPy9V
W3R+UCwZDVqJbaaklHIiCEROBIDEAYJz0V33Y3WodNa60+bU0ENRSy/4fIpy35o5JUEAcOiTQ3HsXGaGRORI50sGu59MLISVWR35sFgqhqY1OIHH41Ok2/Ni
bZqtawVhYREQBAEGdCLCjTS97Zu7JnNnXXHx2jLUXQlZqCvZBrifF4fIICxucmcTxDp2ws5ZOxNnZRE61/hkCEBq7wqByNk4SmMHSpMct8aW7Ns2ootGrFAr
RWMRFmbHIk6ss5E0b/lyre+y1523tB0d1CWHIEydw/sQd5QHTJYZTW6vQ2pZnDCnNrv9ma4dgLo9GRHCUpEcNZOo0UgFUNjkgqgey4s3ZWJ94zO9y5Z1S4pO
KWVJsSKnFDlCECFX2/aTp7r6z19X1pwgxI3AiQKmnmsP7NX25nU5jYCpELrEkUjrVKfMjhICMIJkyNgJExD4ScpJHLlMiT2VTFRmmXi81kIIn7cLDQEOHHhg
8ZI57UpIIxlSRIoIkZ2KJ7c8tElfcIaZ7VsCgfpEkrNayIla8IavVPHgtgFtCJmFk1QYxDl2AMKZVyMARLH2pDyxwqa17CRrH/BndXjJxMhzle7F0pisNyLJ
Dvw7xpshNp56qmPBkp5CShhprTQQIXC8/enth3KXLKt0q2a1HAvUx2tdGAUAII5O33sjul0xA6F1QtaCauV6AIiZACEytzLuEyZAIuHDDZO5vi5Pmb54bN/O
oKN7FnBzfGTSPd+8igDB2NhT3QMDPaG2SFoDuNqBR7cmet15c4NaEriqmLS6bduCwlSBCFCc+BfsfRzrTUpQxei0igWIXSuUBhAGECBkUO6kRIiPRAlYmlNW
IA68uf1TB0ZH2ruLlc5Fk0MHa/J8UWJATPbvf7irp6eU95lt/dDe/ameffr6MjvVTLlm6eDDjzWe2HbGSjICKI47rhrdm1YNaWfBagQQ55wTd7jjSyRrwzs5
Ao4Cpcu9JQUIDGyp1BZPjQwGxcDLL503eWAkfRE2IKSDg2B8Lc5aJ5BfesZcz6F1jcQp2P7oEKjak9QROhICUTxw2Teb1YKXEItFAATnmDN4prWdBAFAWsfI
nPzK2mJXCAiOUJC4idTWkTTixEVKt7dFw0NT/Hw2ZI1yaQoARASzz1pcUFaQ62PjjWTfTkEA3VmqR0xEgk68ZRcODxULqJ2NrYiImzkvRzJfJtnhE/aUCMCw
I6Bs2QkggxfXi6AKJYAkdlX05/VNHxppvoCEmW5qsZXVKyvETsQljZ076vUEiRFpdqeNEVEROOH8+s2H2nyyHDVT66SVyrRgpwy7AQS2p4RKeJW8wuxKDGLi
jVxx6JpK+2HoU5Ky1z27BE2GF7ZSoUhuyTlLNCtxaZrIUw9MNh2CIGLb6TkvT07YOnDsNI1LQM5F1YNjNrv/DJHJvlgAgTk9FR1QeU/ECSA5Rw5Hd8riyNT2
THSuCLUfFFzcTJq6Z1bz0GDjhTGfmbukO2hqHSNBUn32QUczZmFpxRobaVBAICBUmRgpYOASG8VOXMuL8Uw4lCGurVVTJ0sAxGI1KSJgl0yOSXddpg8mMDhr
NiKS8cIkiproL+obPTDxPKMkfrvUWFsUiMYG90/MrNEkHlgshKmkRIAEwFa17T/kl7RI1BCQ1qbx7MAvAWntJT4lAtIppREJFSK7OEadDEVV9CmtOQAFQhT6
+aQRxf7A7Il9o+7oLlOsbywWc4FIXJueYphxfMhdp/mpkpRRZVmcAPjheJ5Cm0xHIoScAUyOZwDww3+eNAEinB4NTmvXpE7f0yoXe8KkQDEa7TWbzSjf2z1y
YCQ9EisJRNHIkXYjntGM4pp2ZrTsKJGs3xdSLEyNhqjieoMwOy0mW/DIKCKtlcSvAKwiwqyAjG98iECLBhAkFpUzqlEDM7trYmikCvjCitzhsAOlsHoOWKs4
AUERBMUADMZMFVTAkipERBIg4GyhclaDOHzRlwmvuzSOatXpWl20zhYpCgOwaE8lCSoqds3KpZG8mE1q/UvH6vmGnSMEduycWOdYHLObFh/SoYlsMW2WCgqA
yIxKt2To1AlAIm08P8gXQk9r42XpgYDLrLUySaSUYNA1O4+pPXY4eqZVQwV9y2cb4sQRAafTdWwVFJyTek1rrk+4ViPGzJI7mXFnzKcuQqQUKW2IVLZyhkih
WBAQR4SIggSoclOTFaNAgnm944cONWfMqiqGSgF4hll7xa5QAzvnFLJEY5NzKohIKMpBbmra16VyeuTA3+zOmY+Ky06GABQUJERNWmuPsoM+iVAYhR2QdiIu
m+tGYgRQ+fGJDrQKQHcUu4dH6i2rme/Oa62QENF4ihyIOJeCdbXB0SAkJCRwDAFNFX3MaUvCCAItJIPh2HNWTlSEUBFpzw+CMAyMUQgZPIFZbAJweM6PW4Ul
YSacSv2sWoxhpehJDADoYg4Co4jI00aJc8ycOhAbDe2uhiVizK4i8aTvucmqwFFjHzN1qqM90wlJu9Jaa60JEIWFZ5J1nOGrzBglYZasEMcikk6iQUAnKBBU
CkXFTsDVJi0JIpBCK1bYWefA2sk9YzYsGQZ2LMxip12Op6cYOPuJGRHPP21XndD9EyEhHM6MQAAZCKW1hBtmdsYLMLM4dtZZJ1Zcs15UAMyAQhSU2isljAHT
6SYqJi0sWd1UnNho7EAquhJmKACLtdW4AFOTqbSKO5n6Pv/u/n+rZNCC6RssxgAAAABJRU5ErkJggg==
]==],
    glass = [==[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACPklEQVR42u2ZQWsTURSFvzO+amprtaZqBWmXrgqiO/8/7hTBlTsVpRZNojG1NsnMdeEdnAYN
I0JJ5t0PHiQEhjnnnnvfm4logZkVkir/vAFsA3u+bgCbQALE5WDAHDgDvgGffU0kzRbveRmtb9jMesABsA/cBirgOzADSl+XyRVfG8B1oACGwEfgnaQfbS6i
luIfAofAljs+9goYq4E8gTueyFPgraTX/2WAme0AR0AfmAAjr7waaxWwxiqAXW/TAfBK0ri1AWYmSWZm94EnwNQvNPPIrQOlt0YfuAo8l3Rca/urAQ3xD4BH
HvWv/zovVigVADe9NV5Ker9oQrrgxi/x9zz2Q+/3wn+u1syAumAjn1dHZjaTdLIsAdvAUx8iX1y8sd7Ii3fLh/gzSZMLBphZPdAe+5YyoJv0fet+AZgkS42+
P/Qt5NMaxr0tQ+AOcCDpjZkpufhrfsAZ+9RXRw0oXeO+mR1LOq+H4J5vcYOFCdpFxsBd1/whmVnyg8PEHSroNpVr3TWzkwT0/GFm5JUv6T6nXvRe8q1h5isX
Kte7lbz6Z155ZWKAuebN5GfmaeMhJxcDpsBG/RJjnmEC5rUBlX+pMjSgSl75qvE8ndMgLGsDyg4ff5eeDFOj/y0z8QbMU6P/czNAiwbk1gJFbUCVaQKqP+0C
ubVAmXMC1EyAZWgAzQTkakDVbAHlJh4oZGZF42CQ2wwgZRr93wX3/wTydCBj7UEQBEEQBEEQBEEQBEEQBEEQBEEQBEFW/AQQj/QNhtYHIwAAAABJRU5ErkJg
gg==
]==],
    frame = [==[
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
]==],
    ring = [==[
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
]==],
    discord = [==[
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
]==],
    warn = [==[
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
]==],
    sliders = [==[
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
]==],
    user = [==[
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
A3kwueo6Z1+kAAAAAElFTkSuQmCC
]==],
    eye = [==[
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
]==],
    walk = [==[
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
]==],
    search = [==[
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
JsvYyv+hee+Zck83nAAAAABJRU5ErkJggg==
]==],
    shine = [==[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAACm0lEQVR42u2bzU4bQRCEba9RyIGQB+PAIUI28Q+8cXJIRBQFEil5hrD+2S+XXqUynpgDuzPL
zLSEvAiJoae6q7raZjQqUaJEiRIvM4AxMM41+UqeJ7klP7HXM+Ast5Kv7PkK+Ah8AC7an2dR9sAS2PM3vgMnqSM/tecFsAEa4NEu4kE5IeWyvwa2hvrOXjfA
u2TJUJKfW/KNJd/Y9+sckp9ZuSvy2SQ/F8Jrkd9I8tPk2F8Ibwb8lrJvL+HWHYZS7nlFvk4WeUfq2p5v5BL2OSG/OdbzuSSv5X+TMuGp1NUeqbvJoeyvHZbP
TuoePVJXkM8J+eykbuZIHUlLnWfIqR3kG5W6lP28T+oU+exm+21XhKeWeDD2WJJ//4Sfr555TrslfgWctpU3lOSXhrYrdauOkJ9Khf0EfgCXUSvBWWDWniHn
2cg7xLoWVQH4CryN8s6RU/a9+Xk5Zy2X2172N+A86AUcWV3rkNOJ1Mk5KzlnJxUwD94Cofy8wy3HVCV68p37eQf5rSTdRBujQ/l5SX7pGaO1vaqQfR/E1Tls
v5fLPRimkvPzHklV5Jsoe4OAyPukbmdVsI2yKwzh501ST44MUwyB8Hrz83LO6gmpq0IlHsTPO+csnWGqidLzIf28M+S4FfaPh4ghdX37eR1ydo7U7WKx/cQh
vL78vCJfe4acdczkrzzvz9c9+PlbZ8jZ2zmLGFI3tq9z4LMkfTB29kB4KnWrKLtC5wI+yR8UYsg5qLBYW522BS5swXAvn8bqaof3Pz+/HNSW2NCedOGz5ff4
VGWjPT+U5DtfNwOnwC8hurYChoV8H9xir69tg4uw/iL4kBP5Ei6BO+CL7PCqUU5hH3d/E3yHlyq3vMh2yPZfXkqUKFGiRIn48QdgAM/elzK7jwAAAABJRU5E
rkJggg==
]==],
    gear = [==[
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
]==],
    check = [==[
iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAABjUlEQVR42u2YQU7DMBBF44RyBxacALFAhUalIHGFLhCckkqImyB2rEjVcgKIaNPHZipGFmkC
RGEs+W/GSav2j+clHjtJoqKioqKiApazbhBwSZJkclk55whmdsV8mAL2JA6BO2AGHMm91Lr5TOIIeOFLj8CB6eoo82dAIcbXQCnjS/09a+b3JZ4DCzFcASsZ
P5mtgIeNnvlKxgvgyrp5jU2lzM+BkckH2MNmqcyvZVwAuUnuW2DzCkx0oqFik0VsgsMGSIGsy6e+N2x8012UsXdsgEPgQq18aQjYOIlj4Fkt39PfJtHr20a1
sPfy46WKN/LZwDI22wQeVJm3f/ahksjMYFOD0LCm3O/AdVMS/7pIqSTympkrgds6nEwsUsrERErtz+C3OJnqbTwz8yacTPY2ylQjTmZ7m5Y4TYETVSlbLXEL
nN68Pay9lngHTlob0y3xDpw23swHsZPSr8qVOvoozO6kGnBCTtFy0+ZVEgOJp9I7zYDjnzZ85k6P+z50ch0lEeb5fVRUVNSf9QlLbWPjhV1meQAAAABJRU5E
rkJggg==
]==],
    play = [==[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADt0lEQVR42u2bS2gUQRCGezYRQmLiIS8fJzGCIlERX4gBL14Sz6IoBEEPHox6Er2I4sHHTUUE
9aKGoILiJYJgDgoKIoh6MSSIYh6Ij+AD8trdz0sPFG3PbhJnd2emt2DJJjRh6p/6q/6urlaqbGUrW1gGpICU8447BYTheBPQZADhJdl5T/9cDdwF+vWnB9go
1lUk9s0DrcAw/9oUcB5o9MFKFC3E27+jHZ4AMsA0MCmAeA/sktEQe1oI56uAUSCrnc0Kx6f1x7f7QGsiaCEAqAH+CCeHgf3AW4MKGf39B3AKqI11tcgDQA1Q
DZwGfuu/Z4xoeAN0xDYacgAwAiwW69YCvQG0yALdwLLYAZEHgGad8SvF+r3AoAGEny++AUd952ORJPMBIMueKJcNwEVdLQDSBi2eA9tiUS1mCoBYL6NhC9Bn
RENagHIVWBhp7TBbAIQzFeL3g4aAmhK0+KyriRfJaJgLALZEBywFrgsqmLR4AmyOHC3+B4AAILYDrwJoMQGcAxoiQ4swADCFEFALHAe+C+0wJf73ILAnEtEQ
FgAB0bACeJBDUj8suaQOG4CAJLlTb61tkvoXcBJYUBJJXQgAbE0UoB44A4yLJClp8RpoLzotCglAAC3WA49zSOqbQEvRaFEMAExa6O+dwMcA7TAKHPZFV0Gj
oVgABNCiCbgsyqS503wGtNlUaGwBCEiSW4GnAdphUkvq5oJoh1IAEECLFHAI+CLygYyGD8A+Wwc7tgDkkNS3xHOYkroXWB7ac0UBgAAg2nNI6iFgZSiRECUA
LJK6CjgB/BS08LVDdyiiKWoABPQdWvRhTVZHQQYYAOrl87l3kGlYZRKc8EPa87w0UK2UOqKUOqaUqlNKoZTKKqXmKaVeKqXGgJTnedmkJEEZ9h16f5D8JGgp
g7eFLE5uGTSEUAXQ5YQQskjhNmeksLEZWgRccWIzZNH9ncAnJ7bDRrhvcKYhYmmJnRUDF8ltiTndFDUcX+VMW9zYxdXpg5ExJw5GjLe+I8c+flJPmyXjaMwi
YW+IUmaGe19iDkctNb1Lr7dNjQzp4/FUpByfKwCz6OamgWvAktD1eykAMGp6M3DJqOky3F8kZkTGMiRlSljbkFRl5B2fIQByTG4d8MilMTl/UHK+nuoYd21Q
chg4ALxzZVS2Cvg6i2Hp1bF96zlAuJdnXL4f2B2L7D6XVrS+LTIScGHign+FJnEXJowoWKNPYQb0BYkeYFNiwn0mIAix02jb7SXanL42lwuIspWtbJG3v/hU
p9okHVw4AAAAAElFTkSuQmCC
]==],
    chev = [==[
iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAABbElEQVR42u2YQU7DMBBF47SVYA+XgB2cgwWiag8AF4AT9EhwDLgAbGEHR2iUPDYTaRSSxjZN
4kjzJSuupXTen5k6cbPMZDKZTCZTuwAHuLnCL9rmc4HP5XoCnOq1ObTMUuaPwCfwBTzJ2jLZlmrA7/irXbImOuD3QCljn6yJDvgCqBqjSM7EAXgEmsY8HROe
8FVjnoYJD/hSrjcy9Nq0JgLgt+qebRImQuGBFbBKwkQA/KaGV/fWJjaTmPCAr7rgJzfRA18qmHUXfIuJcdrJM/MlcNcHP0kl6tfgnsx7w0eaWMTC50PAR7ZT
Hpv5B/ViFt02kZWoY94HV0Jl/02yURwr854mShX3NbgKqgLPjWwcFf5AO+mYL1EVkB3oAniXL/oGbuvdYYAHZb3brYEfifkBXApL8O/AqXPtFXA29AFdVf4c
uFbnafevnajr85B/CPjGdJ6VcFmW4ZxjrDfesWOaTCaTyWQymUzh+gX4qxMOFD/jFQAAAABJRU5ErkJggg==
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

local IMG = {}
for name in pairs(IMG_DATA) do IMG[name] = loadAsset(name) end
-- propriedade de cor certa para ImageLabel (ImageColor3) ou TextLabel (TextColor3)
local function colorProp(o) return o:IsA("ImageLabel") and "ImageColor3" or "TextColor3" end

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
shadow(root, 0, Color3.fromRGB(130, 70, 255), 0.62)

local main = new("Frame", {
    Name = "Main", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0, ClipsDescendants = true,
}, root)
corner(main, 16)
gradient(main, Color3.fromRGB(32, 18, 58), Color3.fromRGB(10, 6, 22), 90)
gradient(stroke(main, Color3.new(1, 1, 1), 1, 0.55), THEME.Accent, THEME.Accent2, 45)

-- Brilho de vidro (PNG) por trás do conteúdo
if IMG.glass ~= "" then
    new("ImageLabel", {
        Name = "Glass", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Image = IMG.glass, ImageColor3 = THEME.Accent, ImageTransparency = 0.82, ZIndex = 0,
    }, main)
end

-- Cabeçalho
local top = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, main)
gradient(top, Color3.fromRGB(70, 36, 130), Color3.fromRGB(38, 20, 76), 0)
local topLine = new("Frame", {
    AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, BackgroundTransparency = 0.35,
}, top)
gradient(topLine, THEME.Accent, THEME.Accent2, 0)

-- Logo: foto do Yuta
local logoBox
if IMG.yuta ~= "" then
    logoBox = new("ImageLabel", {
        Position = UDim2.fromOffset(9, 6), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = THEME.Panel2,
        Image = IMG.yuta, ScaleType = Enum.ScaleType.Crop,
    }, top)
    corner(logoBox, 10)
    if IMG.frame ~= "" then
        new("ImageLabel", {
            Position = UDim2.fromOffset(6, 3), Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1,
            Image = IMG.frame, ImageColor3 = THEME.Accent, ZIndex = 3,
        }, top)
    else
        stroke(logoBox, THEME.Accent, 1.5, 0.2)
    end
else
    logoBox = new("TextLabel", {
        Position = UDim2.fromOffset(9, 6), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = THEME.Accent2,
        Text = "O", TextColor3 = THEME.Text, TextSize = 18, Font = Enum.Font.GothamBold,
    }, top)
    corner(logoBox, 10)
end
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
if IMG.chev ~= "" then
    btnMin.Text = ""
    new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1, Image = IMG.chev, ImageColor3 = THEME.Text, Rotation = 180, ZIndex = 2,
        Active = false,
    }, btnMin)
end

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
    local check
    if IMG.check ~= "" then
        check = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1, Image = IMG.check, ImageColor3 = THEME.Accent2, ImageTransparency = 1,
        }, knob)
    end
    local hit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 2}, row)
    hit.MouseEnter:Connect(function() tween(row, 0.15, {BackgroundColor3 = THEME.Panel2}) end)
    hit.MouseLeave:Connect(function() tween(row, 0.15, {BackgroundColor3 = THEME.Panel}) end)

    local state = false
    local function set(v)
        state = v
        tween(track, 0.2, {BackgroundColor3 = v and THEME.Accent or THEME.Off})
        tween(knob, 0.25, {Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)}, Enum.EasingStyle.Back)
        if check then tween(check, 0.2, {ImageTransparency = v and 0 or 1}) end
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
    local arrow
    if IMG.chev ~= "" then
        arrow = new("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1, Image = IMG.chev, ImageColor3 = THEME.Sub, Rotation = 90,
        }, b)
    else
        arrow = new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0), Size = UDim2.fromOffset(20, 20),
            BackgroundTransparency = 1, Text = "›", TextColor3 = THEME.Sub, Font = Enum.Font.GothamBold, TextSize = 18,
        }, b)
    end
    local cp = colorProp(arrow)
    b.MouseEnter:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = THEME.Panel2})
        tween(st, 0.15, {Color = THEME.Accent, Transparency = 0.6})
        tween(arrow, 0.15, {[cp] = THEME.Accent})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = THEME.Panel})
        tween(st, 0.15, {Color = Color3.new(1, 1, 1), Transparency = 0.93})
        tween(arrow, 0.15, {[cp] = THEME.Sub})
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
-- cada aba usa um dos PNGs enviados (chaves de IMG)
local TAB_ICON = {
    ["Buscar"] = "search", ["Jogador"] = "user", ["Teleporte"] = "walk", ["Visual"] = "eye", ["Mundo"] = "sliders",
    ["Aparência"] = "shine", ["Música"] = "play", ["Misc"] = "gear", ["Anti-Cheat"] = "warn", ["Discord"] = "discord",
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
    local iconKey = TAB_ICON[name]
    local icon
    if iconKey and IMG[iconKey] and IMG[iconKey] ~= "" then
        icon = new("ImageLabel", {
            Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1,
            Image = IMG[iconKey], ImageColor3 = THEME.Sub, ScaleType = Enum.ScaleType.Fit,
        }, btn)
    else
        icon = new("TextLabel", {
            Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(22, 34), BackgroundTransparency = 1,
            Text = "•", TextSize = 14, Font = Enum.Font.GothamMedium, TextColor3 = THEME.Sub,
        }, btn)
    end
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
        tween(o.icon, 0.2, {[colorProp(o.icon)] = THEME.Sub})
        tween(o.indicator, 0.2, {Size = UDim2.fromOffset(3, 0)})
        local oldPage = pages[currentTab]
        tween(oldPage, 0.15, {GroupTransparency = 1})
        task.delay(0.15, function() if currentTab ~= nil and pages[currentTab] ~= oldPage then oldPage.Visible = false end end)
    end
    currentTab = name
    local n = tabButtons[name]
    tween(n.btn, 0.2, {BackgroundTransparency = 0.35})
    tween(n.label, 0.2, {TextColor3 = THEME.Text})
    tween(n.icon, 0.2, {[colorProp(n.icon)] = THEME.Text})
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
-- Tag: jogadores verificados (VERIFIED) ficam azuis.
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
    local textX = 16
    if IMG.discord ~= "" then
        new("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(40, 30),
            BackgroundTransparency = 1, Image = IMG.discord, ImageColor3 = THEME.Accent, ScaleType = Enum.ScaleType.Fit,
        }, row)
        textX = 68
    end
    local discordLbl = new("TextLabel", {
        Position = UDim2.fromOffset(textX, 0), Size = UDim2.new(1, -(textX + 16), 1, 0), BackgroundTransparency = 1,
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
-- ABA: Anti-Cheat (detector de cheaters)
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

    local box = TextInput(t, "Digite o nome da função...")
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
local pillTextX = 0
if IMG.yuta ~= "" then
    local pi = new("ImageLabel", {
        Position = UDim2.fromOffset(5, 5), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = THEME.Panel2,
        Image = IMG.yuta, ScaleType = Enum.ScaleType.Crop,
    }, pill)
    corner(pi, 12)
    pillTextX = 30
end
new("TextLabel", {
    Position = UDim2.fromOffset(pillTextX, 0), Size = UDim2.new(1, -pillTextX, 1, 0), BackgroundTransparency = 1,
    Text = HUB_NAME, TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 12,
}, pill)
makeDraggable(pill, pill)

local minimized = false
local function setMinimized(v)
    minimized = v
    if v then
        tween(root, 0.35, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.35, function() if minimized then root.Visible = false end end)
        pill.Visible = true
        tween(pill, 0.4, {Size = UDim2.fromOffset(260, 34)}, Enum.EasingStyle.Back)
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
    shadow(wrap, 151, Color3.fromRGB(130, 70, 255), 0.6)
    local box = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 152,
    }, wrap)
    corner(box, 14)
    gradient(stroke(box, Color3.new(1, 1, 1), 1, 0.4), THEME.Accent, THEME.Accent2, 45)

    local warnIcon = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = THEME.Bad, BackgroundTransparency = 0.8,
    }, box)
    corner(warnIcon, 17)
    if IMG.warn ~= "" then
        new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1, Image = IMG.warn, ImageColor3 = THEME.Bad, ScaleType = Enum.ScaleType.Fit,
        }, warnIcon)
    else
        new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "!", TextColor3 = THEME.Bad,
            Font = Enum.Font.GothamBold, TextSize = 18,
        }, warnIcon)
    end
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
    gradient(overlay, Color3.fromRGB(36, 18, 70), Color3.fromRGB(8, 6, 16), 90)

    -- anel de vidro girando (PNG) atrás do logo
    local ring
    if IMG.ring ~= "" then
        ring = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34), Size = UDim2.fromOffset(190, 190),
            BackgroundTransparency = 1, Image = IMG.ring, ImageColor3 = THEME.Accent, ZIndex = 200,
        }, overlay)
        TweenService:Create(
            ring, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {Rotation = 360}
        ):Play()
    end

    -- logo: foto do Yuta
    local logo
    if IMG.yuta ~= "" then
        logo = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34), Size = UDim2.fromOffset(104, 104),
            BackgroundColor3 = THEME.Panel2, Image = IMG.yuta, ScaleType = Enum.ScaleType.Crop, ZIndex = 201,
        }, overlay)
        new("UICorner", {CornerRadius = UDim.new(0.5, 0)}, logo)
        stroke(logo, THEME.Accent, 2, 0.1)
    else
        logo = new("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34), Size = UDim2.fromOffset(104, 104),
            BackgroundColor3 = THEME.Accent2, Text = "O", TextColor3 = THEME.Text, TextSize = 52,
            Font = Enum.Font.GothamBold, ZIndex = 201,
        }, overlay)
        new("UICorner", {CornerRadius = UDim.new(0.5, 0)}, logo)
    end
    local logoPulse = TweenService:Create(
        logo, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = UDim2.fromOffset(112, 112)}
    )
    logoPulse:Play()

    local title = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(420, 30), BackgroundTransparency = 1, Text = "Okkotsu Hub",
        TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 26, ZIndex = 201,
    }, overlay)
    local sub = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.545),
        Size = UDim2.fromOffset(420, 18), BackgroundTransparency = 1, Text = "Universal Version",
        TextColor3 = THEME.Accent, Font = Enum.Font.GothamMedium, TextSize = 13, ZIndex = 201,
    }, overlay)
    local status = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.61),
        Size = UDim2.fromOffset(300, 18), BackgroundTransparency = 1, Text = "Carregando...",
        TextColor3 = THEME.Sub, Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 201,
    }, overlay)
    local barBg = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.66),
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
        status.Text = T(s)
        tween(barFill, 0.25, {Size = UDim2.fromScale(i / #steps, 1)})
        task.wait(0.28)
    end

    logoPulse:Cancel()
    tween(overlay, 0.4, {BackgroundTransparency = 1})
    for _, o in ipairs({title, sub, status}) do tween(o, 0.35, {TextTransparency = 1}) end
    if logo:IsA("ImageLabel") then
        tween(logo, 0.35, {ImageTransparency = 1, BackgroundTransparency = 1})
    else
        tween(logo, 0.35, {TextTransparency = 1, BackgroundTransparency = 1})
    end
    local logoStroke = logo:FindFirstChildOfClass("UIStroke")
    if logoStroke then tween(logoStroke, 0.35, {Transparency = 1}) end
    if ring then tween(ring, 0.35, {ImageTransparency = 1}) end
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
