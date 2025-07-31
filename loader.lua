local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AutoStealMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 30)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 18
Toggle.Text = "Auto Steal: OFF"

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
		if LocalPlayer.Character then
			for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end

local function TeleportTo(pos)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
	end
end

local function GrabBrainrot(brainPart)
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root and brainPart then
		firetouchinterest(root, brainPart, 0)
		wait(0.1)
		firetouchinterest(root, brainPart, 1)
	end
end

local function FindBrainrot()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "brainrot") then
			return obj
		end
	end
	return nil
end

local function FindBase()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "base") then
			return obj
		end
	end
	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			return obj
		end
	end
	return nil
end

local AutoStealEnabled = false

Toggle.MouseButton1Click:Connect(function()
	AutoStealEnabled = not AutoStealEnabled
	Toggle.Text = "Auto Steal: " .. (AutoStealEnabled and "ON" or "OFF")
	if AutoStealEnabled then
		task.spawn(function()
			while AutoStealEnabled do
				local brain = FindBrainrot()
				if brain then
					SetNoClip(true)
					TeleportTo(brain.Position)
					wait(0.2)
					GrabBrainrot(brain)
					wait(0.3)
					local base = FindBase()
					if base then
						TeleportTo(base.Position + Vector3.new(0,5,0))
						wait(0.5)
					end
					SetNoClip(false)
					wait(2)
				else
					wait(1)
				end
			end
		end)
	end
end)
