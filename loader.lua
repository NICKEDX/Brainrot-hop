--[[ CONFIG ]]--
local SECRET_NAMES = {"Brainrot", "Brain Rot", "RotBrain"}
local SPEED_BOOST = 60 -- Velocidade com Brainrot
local NORMAL_SPEED = 16
local AUTO_HOP_INTERVAL = 5
local brainrotEquipped = false
local visitedServers = {}

--[[ SERVIÇOS ]]--
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--[[ GUI INICIAL ]]--
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.Name = "BrainrotHub"
gui.ResetOnSpawn = false

local scrollingFrame = Instance.new("ScrollingFrame", gui)
scrollingFrame.Size = UDim2.new(0, 300, 0, 300)
scrollingFrame.Position = UDim2.new(0, 10, 0, 10)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Active = true
scrollingFrame.Draggable = true

local layout = Instance.new("UIListLayout", scrollingFrame)
layout.Padding = UDim.new(0, 4)

function makeButton(text, callback)
	local btn = Instance.new("TextButton", scrollingFrame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Text = text
	btn.AutoButtonColor = true
	btn.MouseButton1Click:Connect(callback)
	return btn
end

--[[ CONFIGURAÇÕES SALVAS ]]--
local function saveConfig(name, value)
	if isfile and writefile then
		local path = "brainrot_config.json"
		local cfg = {}
		if isfile(path) then
			cfg = HttpService:JSONDecode(readfile(path))
		end
		cfg[name] = value
		writefile(path, HttpService:JSONEncode(cfg))
	end
end

local function loadConfig()
	if isfile and readfile and isfile("brainrot_config.json") then
		return HttpService:JSONDecode(readfile("brainrot_config.json"))
	end
	return {}
end

local config = loadConfig()
local autoHop = config.autoHop or false
local noclipEnabled = false
local verifyAllSecrets = config.verifyAllSecrets or false

--[[ AUTO HOP INTELIGENTE ]]--
local function getServers(cursor)
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
	if cursor then url = url .. "&cursor=" .. cursor end
	local response = game:HttpGet(url)
	return HttpService:JSONDecode(response)
end

local function hop()
	local cursor, servers = nil, {}
	repeat
		local data = getServers(cursor)
		cursor = data.nextPageCursor
		for _, s in ipairs(data.data) do
			if s.id ~= game.JobId and s.playing < s.maxPlayers and not visitedServers[s.id] then
				table.insert(servers, s.id)
			end
		end
	until #servers > 0 or not cursor

	if #servers > 0 then
		local chosen = servers[math.random(1, #servers)]
		visitedServers[chosen] = true
		TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen, LocalPlayer)
	end
end

--[[ VERIFICADOR DE SECRETS ]]--
local function findBrainrot()
	for _, name in pairs(SECRET_NAMES) do
		local found = workspace:FindFirstChild(name, true)
		if found and found:IsA("Tool") then
			return found
		end
	end
	return nil
end

--[[ SPEED BOOST ]]--
RunService.RenderStepped:Connect(function()
	local tool = Character:FindFirstChildOfClass("Tool")
	if tool and table.find(SECRET_NAMES, tool.Name) then
		Humanoid.WalkSpeed = SPEED_BOOST
	else
		Humanoid.WalkSpeed = NORMAL_SPEED
	end
end)

--[[ NOCLIP INTELIGENTE ]]--
RunService.Stepped:Connect(function()
	if noclipEnabled then
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				v.CanCollide = false
			end
		end
	end
end)

--[[ ROUBO AUTOMÁTICO ]]--
local function autoSteal()
	local item = findBrainrot()
	if item and item:IsDescendantOf(workspace) then
		HumanoidRootPart.CFrame = item.Handle.CFrame + Vector3.new(0, 3, 0)
		wait(0.3)
		firetouchinterest(item.Handle, HumanoidRootPart, 0)
		wait(0.1)
		firetouchinterest(item.Handle, HumanoidRootPart, 1)
	end
end

--[[ BOTÕES UI ]]--
makeButton("✅ Hop Automático: " .. (autoHop and "ON" or "OFF"), function(btn)
	autoHop = not autoHop
	btn.Text = "✅ Hop Automático: " .. (autoHop and "ON" or "OFF")
	saveConfig("autoHop", autoHop)
end)

makeButton("🔍 Verificar Todos os Secrets: " .. (verifyAllSecrets and "ON" or "OFF"), function(btn)
	verifyAllSecrets = not verifyAllSecrets
	btn.Text = "🔍 Verificar Todos os Secrets: " .. (verifyAllSecrets and "ON" or "OFF")
	saveConfig("verifyAllSecrets", verifyAllSecrets)
end)

makeButton("⚡ Boost de Velocidade Ativo", function()
	-- Já automático com tool na mão
end)

makeButton("🧱 Ativar Noclip: OFF", function(btn)
	noclipEnabled = not noclipEnabled
	btn.Text = "🧱 Ativar Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)

makeButton("📥 Forçar Hop Agora", hop)
makeButton("🤖 Ativar Auto-Roubo", autoSteal)

--[[ LOOP AUTO HOP ]]--
spawn(function()
	while true do
		wait(AUTO_HOP_INTERVAL)
		if autoHop then
			local item = findBrainrot()
			if not item then
				hop()
			end
		end
	end
end)
