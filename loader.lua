local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PlaceID = game.PlaceId

local SECRET_INDICATOR_NAME = "SecretItem"
local hopEnabled = false

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "HopMenu"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 200)
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

local btnToggleHop = createButton("Ativar Hop Automático: OFF", 40)
local btnSetSecret = createButton("Definir Nome do Secret", 80)
local btnForceHop = createButton("Forçar Hop Agora", 120)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Esperando..."
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 160)
statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 14

-- Função para pegar servidores públicos
local function GetServers(cursor)
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceID)
	if cursor then
		url = url .. "&cursor=" .. cursor
	end
	local response = game:HttpGet(url)
	return HttpService:JSONDecode(response)
end

-- Verifica se o "secret" está no workspace
local function HasSecret()
	return workspace:FindFirstChild(SECRET_INDICATOR_NAME) ~= nil
end

-- Faz o hop para outro servidor
local function HopToServer()
	local cursor = nil
	local servers = {}

	repeat
		local data = GetServers(cursor)
		cursor = data.nextPageCursor
		for _, server in ipairs(data.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end
	until #servers > 0 or not cursor

	if #servers == 0 then
		warn("Nenhum servidor disponível!")
		statusLabel.Text = "Status: Nenhum servidor encontrado."
		return
	end

	local randomServer = servers[math.random(1, #servers)]
	statusLabel.Text = "[Hop] Indo para o servidor: " .. randomServer
	TeleportService:TeleportToPlaceInstance(PlaceID, randomServer, player)
end

-- Botões
btnToggleHop.MouseButton1Click:Connect(function()
	hopEnabled = not hopEnabled
	btnToggleHop.Text = "Ativar Hop Automático: " .. (hopEnabled and "ON" or "OFF")
	statusLabel.Text = "Status: Hop Automático " .. (hopEnabled and "Ativado" or "Desativado")
end)

btnSetSecret.MouseButton1Click:Connect(function()
	statusLabel.Text = "Digite o nome do Secret no chat..."
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

-- Loop automático
task.spawn(function()
	while true do
		task.wait(5)
		if hopEnabled and not HasSecret() then
			statusLabel.Text = "[Hop] Secret não encontrado, trocando..."
			HopToServer()
			task.wait(10)
		elseif hopEnabled then
			statusLabel.Text = "[Hop] Secret encontrado!"
		end
	end
end)local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PlaceID = game.PlaceId

local SECRET_INDICATOR_NAME = "SecretItem"
local hopEnabled = false

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "HopMenu"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 200)
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

local btnToggleHop = createButton("Ativar Hop Automático: OFF", 40)
local btnSetSecret = createButton("Definir Nome do Secret", 80)
local btnForceHop = createButton("Forçar Hop Agora", 120)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Esperando..."
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 160)
statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 14

-- Função para pegar servidores públicos
local function GetServers(cursor)
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceID)
	if cursor then
		url = url .. "&cursor=" .. cursor
	end
	local response = game:HttpGet(url)
	return HttpService:JSONDecode(response)
end

-- Verifica se o "secret" está no workspace
local function HasSecret()
	return workspace:FindFirstChild(SECRET_INDICATOR_NAME) ~= nil
end

-- Faz o hop para outro servidor
local function HopToServer()
	local cursor = nil
	local servers = {}

	repeat
		local data = GetServers(cursor)
		cursor = data.nextPageCursor
		for _, server in ipairs(data.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end
	until #servers > 0 or not cursor

	if #servers == 0 then
		warn("Nenhum servidor disponível!")
		statusLabel.Text = "Status: Nenhum servidor encontrado."
		return
	end

	local randomServer = servers[math.random(1, #servers)]
	statusLabel.Text = "[Hop] Indo para o servidor: " .. randomServer
	TeleportService:TeleportToPlaceInstance(PlaceID, randomServer, player)
end

-- Botões
btnToggleHop.MouseButton1Click:Connect(function()
	hopEnabled = not hopEnabled
	btnToggleHop.Text = "Ativar Hop Automático: " .. (hopEnabled and "ON" or "OFF")
	statusLabel.Text = "Status: Hop Automático " .. (hopEnabled and "Ativado" or "Desativado")
end)

btnSetSecret.MouseButton1Click:Connect(function()
	statusLabel.Text = "Digite o nome do Secret no chat..."
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

-- Loop automático
task.spawn(function()
	while true do
		task.wait(5)
		if hopEnabled and not HasSecret() then
			statusLabel.Text = "[Hop] Secret não encontrado, trocando..."
			HopToServer()
			task.wait(10)
		elseif hopEnabled then
			statusLabel.Text = "[Hop] Secret encontrado!"
		end
	end
end)
