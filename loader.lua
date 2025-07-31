local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoStealBrainrot"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 130)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Text = "Auto Steal: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.TextColor3 = Color3.new(1, 1, 1)

local dropdown = Instance.new("TextBox", frame)
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.PlaceholderText = "Nome exato do Brainrot"
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1, 1, 1)

-- NoClip system
local noclipConn
local function SetNoClip(state)
	if state and not noclipConn then
		noclipConn = RunService.Stepped:Connect(function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	elseif not state and noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end

local function TeleportTo(pos)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(pos)
	end
end

local function GrabBrainrot(brain)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		firetouchinterest(root, brain, 0)
		wait(0.1)
		firetouchinterest(root, brain, 1)
	end
end

local function FindBrainrotByName(name)
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and string.lower(obj.Name) == string.lower(name) then
			return obj
		end
	end
end

local function AutoSteal(name)
	local brain = FindBrainrotByName(name)
	if brain then
		SetNoClip(true)
		wait(0.1)
		TeleportTo(brain.Position + Vector3.new(0, 2, 0))
		wait(0.2)
		GrabBrainrot(brain)
		wait(0.3)
		local base = Workspace:FindFirstChild("Base") or Workspace:FindFirstChildWhichIsA("SpawnLocation")
		if base then
			TeleportTo(base.Position + Vector3.new(0, 5, 0))
		end
		wait(0.5)
		SetNoClip(false)
	end
end

-- Toggle behavior
local enabled = false
toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggle.Text = enabled and "Auto Steal: ON" or "Auto Steal: OFF"
end)

-- Loop
task.spawn(function()
	while true do
		if enabled and dropdown.Text ~= "" then
			AutoSteal(dropdown.Text)
		end
		wait(2)
	end
end)
