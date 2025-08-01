local Debris = game:GetService("Debris")
local HopDelay = 10
local lastGrab = 0

local function getSecretBrain()
	for _, plot in ipairs(Workspace:WaitForChild("Plots"):GetChildren()) do
		if plot:FindFirstChild("Brainrot") and plot:FindFirstChild("Rarity") then
			if plot.Rarity:IsA("TextLabel") and plot.Rarity.Text == "Secret" then
				return plot.Brainrot
			end
		end
	end
	return nil
end

local function tp(pos)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char:MoveTo(pos + Vector3.new(0, 3, 0))
	end
end

local function stealBrain(brain)
	if brain and brain.Parent then
		tp(brain.Position)
		fireproximityprompt(brain:FindFirstChildOfClass("ProximityPrompt"))
		lastGrab = tick()
	end
end

local function escapeToBase()
	local base = Workspace:FindFirstChild("Base")
	if base then
		tp(base.Position)
	end
end

task.spawn(function()
	while true do
		task.wait(0.2)
		if Flags.AutoSteal then
			local brain = getSecretBrain()
			if brain then
				stealBrain(brain)
				task.wait(0.5)
				escapeToBase()
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(HopDelay)
		if Flags.AutoHop then
			local has = getSecretBrain()
			if not has and tick() - lastGrab > HopDelay then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
			end
		end
	end
end)

local speedVal = 60
local keysDown = {}

Mouse.KeyDown:Connect(function(k)
	keysDown[k:lower()] = true
end)

Mouse.KeyUp:Connect(function(k)
	keysDown[k:lower()] = false
end)

RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if char and Flags.Speed then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local vel = Vector3.new()
			if keysDown["w"] then vel += root.CFrame.LookVector end
			if keysDown["s"] then vel -= root.CFrame.LookVector end
			if keysDown["a"] then vel -= root.CFrame.RightVector end
			if keysDown["d"] then vel += root.CFrame.RightVector end
			root.Velocity = vel.Unit * speedVal
		end
	end
	if char and Flags.Noclip then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				p.CanCollide = false
			end
		end
	end
end)local HttpService = game:GetService("HttpService")
local TPService = game:GetService("TeleportService")
local placeId = game.PlaceId

-- Configuração salva
local savedFlags = Flags

-- Caminho gravado
local RecordedPath = {}
local PathStartTime = 0
local Replaying = false

local function saveFlags()
    local flagsJson = HttpService:JSONEncode(savedFlags)
    local queue = [[
        getgenv().Flags = ]] .. flagsJson .. [[;
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NICKEDX/Brainrot-hop/refs/heads/main/loader.lua"))()
    ]]
    queue_on_teleport(queuelocal HttpService = game:GetService("HttpService")
local TPService = game:GetService("TeleportService")
local placeId = game.PlaceId
local savedFlags = Flags
local RecordedPath = {}
local PathStartTime = 0
local Replaying = false

local function saveFlags()
    local flagsJson = HttpService:JSONEncode(savedFlags)
    local queue = [[
        getgenv().Flags = ]] .. flagsJson .. [[;
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NICKEDX/Brainrot-hop/refs/heads/main/loader.lua"))()
    ]]
    queue_on_teleport(queue)
end

task.spawn(function()
	while true do
		saveFlags()
		task.wait(5)
	end
end)

local function recordPosition()
	if not Flags.AutoRecord then return end
	local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
	if pos then
		table.insert(RecordedPath, {pos = pos, time = tick() - PathStartTime})
	end
end

RunService.Heartbeat:Connect(function()
	if Flags.AutoRecord and not Replaying then
		recordPosition()
	end
end)

local function replayPath()
	if #RecordedPath == 0 then return end
	Replaying = true
	for _, step in ipairs(RecordedPath) do
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(step.pos)
			task.wait(0.05)
		end
	end
	Replaying = false
end

local function trollDrop()
	if not LocalPlayer.Character then return end
	local drop = Instance.new("Part")
	drop.Name = "Brainrot"
	drop.Size = Vector3.new(1,1,1)
	drop.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,3,0)
	drop.Anchored = false
	drop.Parent = workspace
	game.Debris:AddItem(drop, 5)
end

task.spawn(function()
	while task.wait(3) do
		if Flags.TrollDrop then
			trollDrop()
		end
	end
end)

LocalPlayer.Idled:Connect(function()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
end)
