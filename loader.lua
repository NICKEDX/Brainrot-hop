local Players = game:GetService("Players")
local Teleport = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local Workspace = game:GetService("Workspace")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SecretHopGUI"

local configFile = "SecretSettings_" .. tostring(LocalPlayer.UserId) .. ".json"

local config = {
	AutoHop = false
}

local function saveConfig()
	if isfile and writefile then
		writefile(configFile, HttpService:JSONEncode(config))
	end
end

local function loadConfig()
	if isfile and readfile and isfile(configFile) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(configFile))
		end)
		if success and type(data) == "table" then
			config = data
		end
	end
end

loadConfig()

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 70)
frame.Position = UDim2.new(0, 20, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Secret Hop Menu"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

local hopButton = Instance.new("TextButton", frame)
hopButton.Position = UDim2.new(0, 10, 0, 30)
hopButton.Size = UDim2.new(0, 160, 0, 30)
hopButton.BackgroundColor3 = config.AutoHop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
hopButton.TextColor3 = Color3.new(1, 1, 1)
hopButton.Font = Enum.Font.SourceSans
hopButton.TextSize = 16
hopButton.Text = config.AutoHop and "Auto-Hop: ON ✅" or "Auto-Hop: OFF ❌"

hopButton.MouseButton1Click:Connect(function()
	config.AutoHop = not config.AutoHop
	saveConfig()
	hopButton.Text = config.AutoHop and "Auto-Hop: ON ✅" or "Auto-Hop: OFF ❌"
	hopButton.BackgroundColor3 = config.AutoHop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- Lista de nomes secretos (padrões conhecidos)
local secretNames = {
   "La Vacca", "Tralaleritos", "Graipuss", "Madundung",
   "Nuclearo", "Sammyni", "Garama", "Spyderini"
}

-- Destaca qualquer Brainrot secreto encontrado
local function highlightModel(model)
	pcall(function()
		for _, obj in pairs(model:GetDescendants()) do
			if obj:IsA("BasePart") then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(255, 0, 255)  -- Cor rosa para destaque
				highlight.OutlineColor = Color3.new(1, 1, 1)  -- Contorno branco
				highlight.Adornee = obj
				highlight.Parent = obj
			end
		end
	end)
end

-- Verifica se é secreto
local function isSecret(brainrot)
	local name = brainrot.Name:lower()
	for _, word in ipairs(secretNames) do
		if name:find(word:lower()) then
			return true
		end
	end
	return false
end

-- Scan + teleport + highlight + auto-collect
local function scanConveyor()
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name:lower():find("brainrot") and v:FindFirstChildWhichIsA("HumanoidRootPart") then
			if isSecret(v) then
				highlightModel(v)  -- Destaca o Secret Brainrot
				task.wait(0.5)
				local hrp = v:FindFirstChild("HumanoidRootPart")
				if hrp then
					-- Teleporta para o Secret
					LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
					
					-- Auto-Coleta (se possível)
					local collectButton = v:FindFirstChild("CollectButton")  -- Substitua se necessário
					if collectButton then
						collectButton:Click()  -- Coleta automaticamente
					end
				end
				return true, v.Name
			end
		end
	end
	return false
end

-- Pegar servidores públicos
local function getServerList()
	local servers, cursor = {}, ""
	repeat
		local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100" .. (cursor ~= "" and "&cursor="..cursor or "")
		local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
		if success and response and response.data then
			for _, s in ipairs(response.data) do
				if s.playing < s.maxPlayers then
					table.insert(servers, s.id)
				end
			end
			cursor = response.nextPageCursor
		else
			break
		end
	until not cursor
	return servers
end

-- Trocar de servidor
local function hopServer()
	local list = getServerList()
	for _, id in ipairs(list) do
		if id ~= game.JobId then
			Teleport:TeleportToPlaceInstance(PlaceId, id)
			wait(5)
			break
		end
	end
end

-- Loop principal
task.spawn(function()
	while true do
		wait(3)
		if config.AutoHop then
			local found, name = scanConveyor()
			if found then
				print("🧠 Secret encontrado: "..name)
				config.AutoHop = false
				saveConfig()
				hopButton.Text = "Auto-Hop: OFF ❌"
				hopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
				break
			else
				print("Nenhum Secret. Hoppando...")
				hopServer()
			end
		end
	end
end)
