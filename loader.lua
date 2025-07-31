-- Steal a Brainrot - Script furtivo completo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local BrainrotFolder = workspace:WaitForChild("Brainrots")

local configKey = "stealbrainrot_config"
local config = {
    AutoSteal = true,
    AutoEscape = true,
    AutoHop = false,
    ESPEnabled = true,
    SelectedBrainrot = nil,
}

local function SaveConfig()
    local json = HttpService:JSONEncode(config)
    if writefile then
        writefile(configKey..".json", json)
    end
end

local function LoadConfig()
    if isfile and isfile(configKey..".json") then
        local json = readfile(configKey..".json")
        config = HttpService:JSONDecode(json)
    end
end
LoadConfig()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealBrainrotGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 270, 0, 230)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Frame

local function createToggle(name, initial, callback)
    local btn = Instance.new("TextButton")
    btn.Text = name .. ": " .. (initial and "ON" or "OFF")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = initial and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(function()
        local val = not (btn.BackgroundColor3 == Color3.fromRGB(0, 170, 0))
        btn.BackgroundColor3 = val and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        btn.Text = name .. ": " .. (val and "ON" or "OFF")
        callback(val)
        SaveConfig()
    end)
    return btn
end

local toggles = {}
toggles.AutoSteal = createToggle("Auto Steal", config.AutoSteal, function(v) config.AutoSteal = v end)
toggles.AutoEscape = createToggle("Auto Escape", config.AutoEscape, function(v) config.AutoEscape = v end)
toggles.AutoHop = createToggle("Auto Hop", config.AutoHop, function(v) config.AutoHop = v end)
toggles.ESP = createToggle("ESP", config.ESPEnabled, function(v) config.ESPEnabled = v end)

local brainrotNames = {}
for _, br in pairs(BrainrotFolder:GetChildren()) do
    if br:IsA("Model") and br.Name then
        table.insert(brainrotNames, br.Name)
    end
end
table.sort(brainrotNames)
table.insert(brainrotNames, 1, "Todos")

local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Text = "Selecionar Brainrot:"
dropdownLabel.Size = UDim2.new(1, -10, 0, 20)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.TextColor3 = Color3.new(1,1,1)
dropdownLabel.Font = Enum.Font.SourceSansBold
dropdownLabel.TextSize = 18
dropdownLabel.Parent = Frame

local dropdown = Instance.new("TextButton")
dropdown.Text = config.SelectedBrainrot or "Todos"
dropdown.Size = UDim2.new(1, -10, 0, 30)
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.new(1,1,1)
dropdown.Parent = Frame

local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(1, -10, 0, 100)
dropdownList.Position = UDim2.new(0, 0, 0, 30)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownList.Visible = false
dropdownList.ClipsDescendants = true
dropdownList.Parent = Frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = dropdownList

for _, name in ipairs(brainrotNames) do
    local item = Instance.new("TextButton")
    item.Text = name
    item.Size = UDim2.new(1, 0, 0, 25)
    item.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    item.TextColor3 = Color3.new(1,1,1)
    item.Parent = dropdownList
    item.MouseButton1Click:Connect(function()
        dropdown.Text = name
        dropdownList.Visible = false
        config.SelectedBrainrot = (name == "Todos") and nil or name
        SaveConfig()
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)

local function GetActiveBrainrots()
    local active = {}
    for _, br in pairs(BrainrotFolder:GetChildren()) do
        if br:IsA("Model") and br:FindFirstChild("Collectible") and br.Collectible.Value == true then
            if config.SelectedBrainrot == nil or br.Name == config.SelectedBrainrot then
                table.insert(active, br)
            end
        end
    end
    return active
end

local function MoveTo(targetPosition)
    local dist = (HumanoidRootPart.Position - targetPosition).magnitude
    local tweenInfo = TweenInfo.new(dist / 24, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    tween.Completed:Wait()
end

local function CollectBrainrot(brainrot)
    local collectEvent = ReplicatedStorage:FindFirstChild("CollectBrainrot")
    if collectEvent then
        collectEvent:FireServer(brainrot)
    end
end

local function EscapeToBase()
    local basePosition = Vector3.new(0, 10, 0) -- ajuste para sua base
    MoveTo(basePosition)
end

local function MoveSideways(step)
    local rightVector = HumanoidRootPart.CFrame.RightVector
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + rightVector * step
end

local DETECTION_RADIUS = 30

local autoHopConnection
local autoHopEnabled = false
local function StartAutoHop()
    if autoHopConnection then autoHopConnection:Disconnect() end
    autoHopEnabled = true
    autoHopConnection = RunService.Heartbeat:Connect(function()
        if not autoHopEnabled then return end
        if Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            Humanoid.Jump = true
        end
        MoveSideways(0.5)
        local brainrots = GetActiveBrainrots()
        for _, br in pairs(brainrots) do
            if br.PrimaryPart and (br.PrimaryPart.Position - HumanoidRootPart.Position).magnitude <= DETECTION_RADIUS then
                MoveTo(br.PrimaryPart.Position)
                CollectBrainrot(br)
                if config.AutoEscape then EscapeToBase() end
                break
            end
        end
    end)
end

local function StopAutoHop()
    if autoHopConnection then
        autoHopConnection:Disconnect()
        autoHopConnection = nil
    end
    autoHopEnabled = false
end

-- Anti kick
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if tostring(self) == "Kick" or tostring(self) == "kick" then
        return wait(math.huge)
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function CreateESP()
    if not config.ESPEnabled then return end
    for _, br in pairs(GetActiveBrainrots()) do
        if not br:FindFirstChild("ESPBox") then
            local adornee = br:FindFirstChild("HumanoidRootPart") or br.PrimaryPart
            if adornee then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Adornee = adornee
                box.Color3 = Color3.new(1, 0, 0)
                box.AlwaysOnTop = true
                box.Size = Vector3.new(4,4,4)
                box.Transparency = 0.5
                box.Parent = br
            end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("ESPBox") then
            local adornee = plr.Character:FindFirstChild("HumanoidRootPart")
            if adornee then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Adornee = adornee
                box.Color3 = Color3.new(0, 0, 1)
                box.AlwaysOnTop = true
                box.Size = Vector3.new(2,5,2)
                box.Transparency = 0.5
                box.Parent = plr.Character
            end
        end
    end
end

-- Loop principal
spawn(function()
    while wait(1) do
        if config.AutoSteal then
            local brainrots = GetActiveBrainrots()
            if #brainrots > 0 then
                for _, br in pairs(brainrots) do
                    if br.PrimaryPart then
                        MoveTo(br.PrimaryPart.Position)
                        CollectBrainrot(br)
                        wait(0.5)
                        if config.AutoEscape then
                            EscapeToBase()
                        end
                        wait(2)
                    end
                end
            end
        end
        CreateESP()
    end
end)

-- Liga/desliga AutoHop via toggle e controla conexão
if config.AutoHop then
    StartAutoHop()
else
    StopAutoHop()
end
toggles.AutoHop.MouseButton1Click:Connect(function()
    local enabled = toggles.AutoHop.BackgroundColor3 == Color3.fromRGB(0,170,0)
    config.AutoHop = enabled
    SaveConfig()
    if enabled then StartAutoHop() else StopAutoHop() end
end)

queue_on_teleport([[
    -- Código para reexecutar script no teleport (copie seu script aqui para persistência)
]])

-- Script pronto para uso furtivo
