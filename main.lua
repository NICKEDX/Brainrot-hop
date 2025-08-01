local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local HopDelay = 10
local lastGrab = 0
local speedVal = 60

local Flags = {
    AutoSteal = true,
    AutoHop = true,
    Speed = true,
    Noclip = true,
    AutoRecord = true,
    TrollDrop = false,
}

local savedFlags = {}
for k,v in pairs(Flags) do savedFlags[k] = v end

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "BrainrotHackMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 250)
Frame.Position = UDim2.new(0, 10, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Visible = false

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function createToggle(name, flagKey, defaultValue)
    local toggleFrame = Instance.new("Frame", Frame)
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggleFrame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18

    local button = Instance.new("TextButton", toggleFrame)
    button.Size = UDim2.new(0.3, -10, 1, -6)
    button.Position = UDim2.new(0.7, 5, 0, 3)
    button.Text = defaultValue and "ON" or "OFF"
    button.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.AutoButtonColor = false

    button.MouseButton1Click:Connect(function()
        Flags[flagKey] = not Flags[flagKey]
        button.Text = Flags[flagKey] and "ON" or "OFF"
        button.BackgroundColor3 = Flags[flagKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end

createToggle("Auto Steal", "AutoSteal", Flags.AutoSteal)
createToggle("Auto Hop", "AutoHop", Flags.AutoHop)
createToggle("Speed Boost", "Speed", Flags.Speed)
createToggle("Noclip", "Noclip", Flags.Noclip)
createToggle("Auto Record", "AutoRecord", Flags.AutoRecord)
createToggle("Troll Drop", "TrollDrop", Flags.TrollDrop)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        Frame.Visible = not Frame.Visible
    end
end)

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
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function stealBrain(brain)
    if brain and brain.Parent then
        tp(brain.Position)
        local prompt = brain:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            lastGrab = tick()
        end
    end
end

local function escapeToBase()
    local base = Workspace:FindFirstChild("Base")
    if base then
        tp(base.Position)
    end
end

local function saveFlags()
    local flagsJson = HttpService:JSONEncode(Flags)
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

local RecordedPath = {}
local PathStartTime = tick()
local Replaying = false

local function recordPosition()
    if not Flags.AutoRecord then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
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
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(step.pos)
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
    Debris:AddItem(drop, 5)
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
    task.wait(1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

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
            if keysDown["w"] then vel = vel + root.CFrame.LookVector end
            if keysDown["s"] then vel = vel - root.CFrame.LookVector end
            if keysDown["a"] then vel = vel - root.CFrame.RightVector end
            if keysDown["d"] then vel = vel + root.CFrame.RightVector end
            if vel.Magnitude > 0 then
                root.Velocity = vel.Unit * speedVal
            else
                root.Velocity = Vector3.new(0,0,0)
            end
        end
    end
    if char and Flags.Noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
end)
