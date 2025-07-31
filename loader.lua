local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PlaceID = game.PlaceId

-- Arquivo de config
local CONFIG_FILE = "BrainrotHopConfig.json"
local VISITED_FILE = "BrainrotVisited.json"

-- Valores padrão
local config = {
    secretName = "SecretItem",
    hopEnabled = false
}

local visitedServers = {}

-- Leitura de config
if isfile(CONFIG_FILE) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if success then
        config = data
    end
end

-- Leitura de servidores visitados
if isfile(VISITED_FILE) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(VISITED_FILE))
    end)
    if success then
        visitedServers = data
    end
end

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "HopMenu"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 240)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function createLabel(text, posY)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -20, 0, 30)
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.Text = text
    return lbl
end

local function createButton(text, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = true
    return btn
end

local title = createLabel("Brainrot Hop Menu", 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local btnToggleHop = createButton("Hop Automático: " .. (config.hopEnabled and "ON" or "OFF"), 40)
local btnSetSecret = createButton("Definir Nome do Secret", 80)
local btnForceHop = createButton("Forçar Hop Agora", 120)
local btnSave = createButton("Salvar Configurações", 160)
local statusLabel = createLabel("Status: Esperando...", 200)

-- Salvar config
local function saveConfig()
    writefile(CONFIG_FILE, HttpService:JSONEncode(config))
    writefile(VISITED_FILE, HttpService:JSONEncode(visitedServers))
end

-- Pega servidores públicos
local function GetServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceID)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    return success and result or {data = {}, nextPageCursor = nil}
end

-- Verifica se há o item secreto
local function HasSecret()
    return workspace:FindFirstChild(config.secretName) ~= nil
end

-- Hop de servidor
local function HopToServer()
    local cursor = nil
    local servers = {}

    repeat
        local data = GetServers(cursor)
        cursor = data.nextPageCursor
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId and not visitedServers[server.id] then
                table.insert(servers, server.id)
            end
        end
    until #servers > 0 or not cursor

    if #servers == 0 then
        statusLabel.Text = "Status: Nenhum servidor válido!"
        return
    end

    local chosen = servers[math.random(1, #servers)]
    visitedServers[game.JobId] = true
    saveConfig()
    statusLabel.Text = "[Hop] Indo para: " .. chosen
    TeleportService:TeleportToPlaceInstance(PlaceID, chosen, player)
end

-- Eventos dos botões
btnToggleHop.MouseButton1Click:Connect(function()
    config.hopEnabled = not config.hopEnabled
    btnToggleHop.Text = "Hop Automático: " .. (config.hopEnabled and "ON" or "OFF")
    statusLabel.Text = "Status: Hop " .. (config.hopEnabled and "Ativado" or "Desativado")
end)

btnSetSecret.MouseButton1Click:Connect(function()
    statusLabel.Text = "Digite o nome no chat..."
    local conn
    conn = player.Chatted:Connect(function(msg)
        config.secretName = msg
        statusLabel.Text = "Secret definido: " .. msg
        conn:Disconnect()
    end)
end)

btnForceHop.MouseButton1Click:Connect(function()
    statusLabel.Text = "Forçando Hop..."
    HopToServer()
end)

btnSave.MouseButton1Click:Connect(function()
    saveConfig()
    statusLabel.Text = "Configurações salvas!"
end)

-- Loop do Hop automático
task.spawn(function()
    while true do
        task.wait(5)
        if config.hopEnabled then
            if not HasSecret() then
                statusLabel.Text = "[Hop] Secret não achado, pulando..."
                HopToServer()
                task.wait(10)
            else
                statusLabel.Text = "Secret encontrado! Aguardando..."
            end
        end
    end
end)
