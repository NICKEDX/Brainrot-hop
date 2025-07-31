local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local PlaceID = game.PlaceId
local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local SETTINGS_KEY = "BrainrotHopSettings"
local SECRET_INDICATOR_NAME = "SecretItem"
local hopEnabled = false
local checkAllSecrets = false

-- CARREGAR CONFIG
pcall(function()
    local data = HttpService:JSONDecode(player:FindFirstChild("PlayerGui"):FindFirstChild(SETTINGS_KEY) and player.PlayerGui[SETTINGS_KEY].Value or "{}")
    if data.secret then SECRET_INDICATOR_NAME = data.secret end
    if data.hop then hopEnabled = true end
    if data.allSecrets then checkAllSecrets = true end
end)

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "HopMenu"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Brainrot Hop Menu"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

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

local btnToggleHop = createButton("Ativar Hop Automático: " .. (hopEnabled and "ON" or "OFF"), 40)
local btnSetSecret = createButton("Definir Nome do Secret", 80)
local btnForceHop = createButton("Forçar Hop Agora", 120)
local btnSave = createButton("Salvar Configurações", 160)
local btnAllSecrets = createButton("Verificar Todos os Secrets: " .. (checkAllSecrets and "ON" or "OFF"), 200)
local btnBoost = createButton("Boost de Velocidade", 240)
local btnNoclip = createButton("Atravessar Paredes: OFF", 280)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Esperando..."
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 320)
statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 14

-- Salvar Configurações
local function SaveSettings()
    local config = {
        secret = SECRET_INDICATOR_NAME,
        hop = hopEnabled,
        allSecrets = checkAllSecrets
    }
    local valueObj = Instance.new("StringValue")
    valueObj.Name = SETTINGS_KEY
    valueObj.Value = HttpService:JSONEncode(config)
    valueObj.Parent = player.PlayerGui
    statusLabel.Text = "Configurações salvas!"
end

-- Verifica se há secret
local function HasSecret()
    if checkAllSecrets then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.lower(obj.Name):find("secret") then
                return true
            end
        end
        return false
    else
        return workspace:FindFirstChild(SECRET_INDICATOR_NAME) ~= nil
    end
end

-- Pegar servidores
local function GetServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceID)
    if cursor then url = url .. "&cursor=" .. cursor end
    local response = game:HttpGet(url)
    return HttpService:JSONDecode(response)
end

-- Hop de servidor
local function HopToServer()
    local cursor = nil
    local servers = {}
    repeat
        local data = GetServers(cursor)
        cursor = data.nextPageCursor
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    until #servers > 0 or not cursor

    if #servers == 0 then
        warn("Nenhum servidor disponível!")
        statusLabel.Text = "Status: Nenhum servidor disponível!"
        return
    end

    local randomServer = servers[math.random(1, #servers)]
    statusLabel.Text = "[Hop] Indo para o servidor: " .. randomServer
    TeleportService:TeleportToPlaceInstance(PlaceID, randomServer, player)
end

-- BOTÕES
btnToggleHop.MouseButton1Click:Connect(function()
    hopEnabled = not hopEnabled
    btnToggleHop.Text = "Ativar Hop Automático: " .. (hopEnabled and "ON" or "OFF")
    statusLabel.Text = "Status: Hop " .. (hopEnabled and "Ativado" or "Desativado")
end)

btnSetSecret.MouseButton1Click:Connect(function()
    statusLabel.Text = "Digite o nome do Secret no chat!"
    local connection
    connection = player.Chatted:Connect(function(msg)
        SECRET_INDICATOR_NAME = msg
        statusLabel.Text = "Nome do Secret definido para: " .. msg
        connection:Disconnect()
    end)
end)

btnForceHop.MouseButton1Click:Connect(function()
    statusLabel.Text = "Forçando Hop..."
    HopToServer()
end)

btnSave.MouseButton1Click:Connect(SaveSettings)

btnAllSecrets.MouseButton1Click:Connect(function()
    checkAllSecrets = not checkAllSecrets
    btnAllSecrets.Text = "Verificar Todos os Secrets: " .. (checkAllSecrets and "ON" or "OFF")
end)

-- BOOST de velocidade com Brainrot
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool and tool.Name == "Brainrot" then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 50
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)

-- NOCLIP
local noclip = false
btnNoclip.MouseButton1Click:Connect(function()
    noclip = not noclip
    btnNoclip.Text = "Atravessar Paredes: " .. (noclip and "ON" or "OFF")
    statusLabel.Text = "NoClip " .. (noclip and "ativado" or "desativado")
end)

RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- LOOP automático
spawn(function()
    while true do
        wait(5)
        if hopEnabled and not HasSecret() then
            statusLabel.Text = "[Hop] Nenhum secret encontrado, pulando..."
            HopToServer()
            wait(10)
        elseif hopEnabled then
            statusLabel.Text = "Secret encontrado! Fique atento."
        end
    end
end)
