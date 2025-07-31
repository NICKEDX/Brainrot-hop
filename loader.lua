-- STEAL A BRAINROT - HACK COMPLETO, FURTIVO, COM GUI E FUNÇÕES AVANÇADAS

-- SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotHackUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local scrolling = Instance.new("ScrollingFrame", frame)
scrolling.Size = UDim2.new(1, 0, 1, 0)
scrolling.CanvasSize = UDim2.new(0, 0, 3, 0)
scrolling.ScrollBarThickness = 6
scrolling.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", scrolling)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- FUNÇÕES DE GUI
function createButton(text, callback)
	local button = Instance.new("TextButton", scrolling)
	button.Size = UDim2.new(1, -12, 0, 32)
	button.Position = UDim2.new(0, 6, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.BorderSizePixel = 0
	button.AutoButtonColor = true

	button.MouseButton1Click:Connect(function()
		pcall(callback)
	end)

	return button
end

function createLabel(text)
	local label = Instance.new("TextLabel", scrolling)
	label.Size = UDim2.new(1, -12, 0, 24)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BorderSizePixel = 0
	label.LayoutOrder = 0
	return label
end

function createNotification(text, duration)
	local msg = Instance.new("TextLabel", gui)
	msg.Size = UDim2.new(0, 300, 0, 30)
	msg.Position = UDim2.new(0.5, -150, 0, 10)
	msg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	msg.BorderSizePixel = 0
	msg.TextColor3 = Color3.new(1, 1, 1)
	msg.Font = Enum.Font.GothamBold
	msg.TextSize = 14
	msg.Text = text
	msg.AnchorPoint = Vector2.new(0.5, 0)
	msg.BackgroundTransparency = 0.2
	game:GetService("Debris"):AddItem(msg, duration or 3)
end

-- CONFIG
_G.BrainrotSettings = {
	HopEnabled = true,
	SecretName = nil,
	Noclip = false,
	SpeedBoost = true,
	AutoScanSecrets = true,
	AutoGrab = true,
	AutoEscape = true,
	ESP = true,
	AntiKick = true,
	TrollMode = false,
}

-- Noclip
RunService.Stepped:Connect(function()
	if _G.BrainrotSettings.Noclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(11)
	end
end)

createButton("🚪 Toggle Noclip", function()
	_G.BrainrotSettings.Noclip = not _G.BrainrotSettings.Noclip
	createNotification("Noclip: " .. tostring(_G.BrainrotSettings.Noclip), 2)
end)

-- SpeedBoost
local speedBoosting = false
createButton("⚡ Ativar Speed Boost", function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = 30
		speedBoosting = true
		createNotification("Speed Boost ativado!", 2)
	end
end)

createButton("🧍‍♂️ Desativar Speed Boost", function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = 16
		speedBoosting = false
		createNotification("Speed Boost desativado.", 2)
	end
end)

-- Secret Scanner
function scanSecrets()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Tool") and obj.Name:lower():find("secret") then
			createNotification("🔍 Secret encontrado: " .. obj.Name, 2)
			if _G.BrainrotSettings.AutoGrab and LocalPlayer.Character and obj:FindFirstChild("Handle") then
				pcall(function()
					firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Handle, 0)
					firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Handle, 1)
				end)
			end
		end
	end
end

createButton("🔎 Escanear Secrets", scanSecrets)

-- AutoScan Loop
task.spawn(function()
	while true do
		if _G.BrainrotSettings.AutoScanSecrets then
			scanSecrets()
		end
		task.wait(5)
	end
end)

-- ESCAPE
function escapeBrainrot()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Part") and v.Name:lower():find("escape") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
			createNotification("🚪 Escape usado!", 2)
			break
		end
	end
end

createButton("🏃 Auto Escape", escapeBrainrot)

-- ESP
function createESP(part, text)
	local billboard = Instance.new("BillboardGui", part)
	billboard.Adornee = part
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 0)
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
end

task.spawn(function()
	while true do
		if _G.BrainrotSettings.ESP then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Tool") and obj:FindFirstChild("Handle") and not obj:FindFirstChild("ESP") then
					createESP(obj.Handle, obj.Name)
					local tag = Instance.new("BoolValue", obj)
					tag.Name = "ESP"
				end
			end
		end
		task.wait(2)
	end
end)

-- Caminho
local recordedPath = {}
local recording = false

function startRecording()
	recordedPath = {}
	recording = true
	createNotification("📼 Gravando caminho...", 3)
	while recording do
		local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if pos then
			table.insert(recordedPath, pos.Position)
		end
		task.wait(1)
	end
end

function stopRecording()
	recording = false
	createNotification("⏹️ Gravação encerrada.", 3)
end

function replayPath()
	if #recordedPath == 0 then
		createNotification("⚠️ Nenhum caminho gravado!", 3)
		return
	end
	createNotification("🔁 Repetindo caminho...", 3)
	for _, pos in ipairs(recordedPath) do
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(pos)
			task.wait(0.4)
		end
	end
end

createButton("🎬 Iniciar Gravação Caminho", startRecording)
createButton("⏹️ Parar Gravação", stopRecording)
createButton("🔁 Repetir Caminho", replayPath)

-- Contador de Secrets
local secretCountLabel = createLabel("Secrets coletados: 0")
local collectedSecrets = {}

function updateSecretCounter()
	local count = 0
	for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if obj:IsA("Tool") and obj.Name:lower():find("secret") then
			if not collectedSecrets[obj.Name] then
				collectedSecrets[obj.Name] = true
				count = count + 1
			end
		end
	end
	secretCountLabel.Text = "Secrets coletados: " .. tostring(count)
end

RunService.RenderStepped:Connect(updateSecretCounter)

-- Ajuste Scroll automático
function fixGuiScroll()
	local absSize = UIListLayout.AbsoluteContentSize
	scrolling.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 20)
end

scrolling.ChildAdded:Connect(fixGuiScroll)
scrolling.ChildRemoved:Connect(fixGuiScroll)

-- Aviso final
createNotification("✅ Script completo carregado com sucesso!", 4)
