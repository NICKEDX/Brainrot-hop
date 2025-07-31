local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

pcall(function()
	if LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("BrainrotGui") then
		LocalPlayer.PlayerGui.BrainrotGui:Destroy()
	end
end)

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "BrainrotGui"
gui.ResetOnSpawn = false

local config = {
	AutoSteal = true,
	AutoHop = true,
	AutoEscape = true,
	Noclip = true,
	Speed = true,
	ESP = true,
	TrollMode = false
}

local teleportData = HttpService:JSONEncode(config)
queue_on_teleport([[
	loadstring(game:HttpGet("https://raw.githubusercontent.com/NICKEDX/Brainrot-hop/refs/heads/main/loader.lua"))()
]])

task.spawn(function()
	local mt = getrawmetatable(game)
	local old = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = newcclosure(function(self, ...)
		local m = getnamecallmethod()
		if tostring(m) == "Kick" or tostring(self) == "Kick" then return end
		return old(self, ...)
	end)
end)

function GetAllBrainrots()
	local found = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
			table.insert(found, obj)
		end
	end
	return found
end

function TeleportTo(pos)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(pos)
	end
end

function Noclip(on)
	if on then
		RunService.Stepped:Connect(function()
			if LocalPlayer.Character then
				for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
					if v:IsA("BasePart") and v.CanCollide == true then
						v.CanCollide = false
					end
				end
			end
		end)
	end
end

function SpeedBoost()
	while config.Speed do
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 60
		end
		wait(0.5)
	end
end

function Collect(brain)
	if brain:FindFirstChild("TouchInterest") then
		firetouchinterest(LocalPlayer.Character.HumanoidRootPart, brain, 0)
		firetouchinterest(LocalPlayer.Character.HumanoidRootPart, brain, 1)
	end
end

function EscapeToBase()
	local base = Workspace:FindFirstChild("Base") or Workspace:FindFirstChild("Home")
	if base then
		TeleportTo(base.Position)
	end
end

function ESPBrainrots()
	for _, b in pairs(GetAllBrainrots()) do
		if not b:FindFirstChild("ESP") then
			local box = Instance.new("BillboardGui", b)
			box.Name = "ESP"
			box.Size = UDim2.new(0, 100, 0, 40)
			box.AlwaysOnTop = true
			local text = Instance.new("TextLabel", box)
			text.Size = UDim2.new(1,0,1,0)
			text.BackgroundTransparency = 1
			text.Text = "🧠 BRAINROT"
			text.TextColor3 = Color3.new(1, 0, 0)
			text.TextStrokeTransparency = 0
		end
	end
end

Noclip(config.Noclip)
task.spawn(SpeedBoost)

task.spawn(function()
	while task.wait(1) do
		if config.ESP then ESPBrainrots() end
	end
end)

task.spawn(function()
	while config.AutoSteal do
		local brains = GetAllBrainrots()
		for _, b in pairs(brains) do
			if b and b:FindFirstChild("PrimaryPart") then
				TeleportTo(b.PrimaryPart.Position + Vector3.new(0, 3, 0))
				wait(0.3)
				Collect(b)
				wait(0.5)
				if config.AutoEscape then EscapeToBase() end
				break
			end
		end
		wait(1)
	end
end)

task.spawn(function()
	while config.AutoHop do
		local brains = GetAllBrainrots()
		if #brains == 0 then
			TeleportService:Teleport(game.PlaceId)
		end
		wait(5)
	end
end)
