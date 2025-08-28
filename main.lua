local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local savedPosition = nil
local noclipEnabled = false
local speed = 16

local function toggleNoclip(state)
    noclipEnabled = state
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and noclipEnabled then
        hrp.CFrame = hrp.CFrame + Vector3.new(0,3,0)
    end
end

local function setSpeed(value)
    speed = value
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speed
    end
end

RunService.Stepped:Connect(function()
    local char = player.Character
    if char and noclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Velocity.Magnitude < 0.1 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0,0.1,0)
            end
        end
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,160)
frame.Position = UDim2.new(0.5,-110,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0,10)
uiCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "🧠 GG HUB - Steal Mode"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function createToggle(name,posY,callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,0,30)
    container.Position = UDim2.new(0,10,0,posY)
    container.BackgroundTransparency = 1
    container.Name = name
    container.Parent = frame
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.7,0,1,0)
    text.Position = UDim2.new(0,0,0,0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = Enum.Font.Gotham
    text.TextSize = 14
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = container
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.25,0,0.6,0)
    toggleBtn.Position = UDim2.new(0.75,0,0.2,0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = container
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0.4,0,1,0)
    knob.Position = UDim2.new(0,0,0,0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = toggleBtn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
    local on = false
    toggleBtn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(knob,TweenInfo.new(0.2),{Position=on and UDim2.new(0.6,0,0,0) or UDim2.new(0,0,0,0)}):Play()
        callback(on)
    end)
end

createToggle("Speed Boost",35,function(enabled)
    setSpeed(enabled and 50 or 16)
end)

createToggle("Noclip",70,function(enabled)
    toggleNoclip(enabled)
end)

createToggle("Steal",105,function(_)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("brainrot") then
            hrp.CFrame = obj.CFrame + Vector3.new(0,3,0)
            if obj:FindFirstChild("TouchInterest") then
                obj.TouchInterest:Fire()
            end
            wait(0.5)
        end
    end
end)
