local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local Config = {
    AutoStealEnabled = true,
    DelayBetweenSteals = 2,
}

if getgenv().AutoStealConfig then
    for k, v in pairs(getgenv().AutoStealConfig) do
        Config[k] = v
    end
end

local function saveConfig()
    local json = HttpService:JSONEncode(Config)
    if queue_on_teleport then
        queue_on_teleport([[
            local HttpService = game:GetService("HttpService")
            local Config = HttpService:JSONDecode(']] .. json .. [[')
            getgenv().AutoStealConfig = Config
        ]])
    end
end

local function getAvailableBrainrots()
    local brainrots = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("brainrot") then
            if obj.Parent and not obj.Parent:FindFirstChild("Owner") then
                table.insert(brainrots, obj)
            end
        end
    end
    return brainrots
end

local function teleportTo(part)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

local function returnToBase()
    local base = workspace:FindFirstChild("Base") or workspace:FindFirstChild("SpawnLocation")
    if base and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = base.CFrame + Vector3.new(0, 3, 0)
    end
end

spawn(function()
    while true do
        if Config.AutoStealEnabled then
            local brainrots = getAvailableBrainrots()
            if #brainrots > 0 then
                for _, brainrot in pairs(brainrots) do
                    if not Config.AutoStealEnabled then break end
                    if brainrot and brainrot.Parent then
                        teleportTo(brainrot)
                        wait(Config.DelayBetweenSteals)
                    end
                end
                returnToBase()
            else
                wait(1)
            end
        else
            wait(1)
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoStealGui"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 180, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Text = "AutoSteal: ON"
ToggleBtn.Parent = Frame

ToggleBtn.MouseButton1Click:Connect(function()
    Config.AutoStealEnabled = not Config.AutoStealEnabled
    ToggleBtn.Text = "AutoSteal: " .. (Config.AutoStealEnabled and "ON" or "OFF")
    saveConfig()
end)

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 180, 0, 20)
DelayLabel.Position = UDim2.new(0, 10, 0, 60)
DelayLabel.BackgroundTransparency = 1
DelayLabel.TextColor3 = Color3.new(1,1,1)
DelayLabel.Text = "Delay (s): "..tostring(Config.DelayBetweenSteals)
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = Frame

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(0, 180, 0, 30)
DelayInput.Position = UDim2.new(0, 10, 0, 80)
DelayInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
DelayInput.TextColor3 = Color3.new(1,1,1)
DelayInput.Text = tostring(Config.DelayBetweenSteals)
DelayInput.ClearTextOnFocus = false
DelayInput.Parent = Frame

DelayInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(DelayInput.Text)
        if val and val >= 0 then
            Config.DelayBetweenSteals = val
            DelayLabel.Text = "Delay (s): "..tostring(val)
            saveConfig()
        else
            DelayInput.Text = tostring(Config.DelayBetweenSteals)
        end
    end
end)
