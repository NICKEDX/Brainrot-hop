local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "SimpleMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(text, default, callback)
    local toggleFrame = Instance.new("Frame", Frame)
    toggleFrame.Size = UDim2.new(1, -10, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", toggleFrame)
    label.Text = text
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    
    local button = Instance.new("TextButton", toggleFrame)
    button.Size = UDim2.new(0.3, 0, 0.7, 0)
    button.Position = UDim2.new(0.65, 0, 0.15, 0)
    button.Text = default and "ON" or "OFF"
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    
    local enabled = default
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = enabled and "ON" or "OFF"
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
        callback(enabled)
    end)
    
    return toggleFrame
end

local Config = {
    AutoSteal = true,
    AutoHop = true,
}

createToggle("Auto Steal", Config.AutoSteal, function(value)
    Config.AutoSteal = value
end)

createToggle("Auto Hop (Secret)", Config.AutoHop, function(value)
    Config.AutoHop = value
end)

-- Função para teleporte e roubo simples
local function TeleportTo(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = pos + Vector3.new(0,3,0) end
end

local function GetSecrets()
    local secrets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("brainrot") and obj.Name:lower():find("secret") then
            table.insert(secrets, obj)
        end
    end
    return secrets
end

local function GrabClosestSecret()
    local secrets = GetSecrets()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.sort(secrets, function(a,b)
            return (a:GetModelCFrame().Position - hrp.Position).Magnitude < (b:GetModelCFrame().Position - hrp.Position).Magnitude
        end)
        return secrets[1]
    end
end

local function GetMyBase()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("YourBase", true) and plot:FindFirstChild("YourBase", true).Enabled then
            return plot
        end
    end
end

-- Auto Steal Loop
spawn(function()
    while true do
        wait(0.15)
        if Config.AutoSteal then
            local target = GrabClosestSecret()
            if target then
                TeleportTo(target:GetModelCFrame())
                wait(0.3)
                local base = GetMyBase()
                if base then
                    TeleportTo(base.PlotBlock.Main.CFrame)
                end
            end
        end
    end
end)

-- Auto Hop Loop (simples)
spawn(function()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    while true do
        wait(4)
        if Config.AutoHop then
            local secrets = GetSecrets()
            if #secrets == 0 then
                local success, servers = pcall(function()
                    local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
                    return HttpService:JSONDecode(res)
                end)
                if success and servers and servers.data then
                    for _, server in pairs(servers.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                            break
                        end
                    end
                end
            end
        end
    end
end)
