local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "Steal a Brainrot 〢 Furtivo",
    Size = UDim2.fromOffset(520, 420),
})

local TabMain = Window:AddTab({Title = "Main"})
local TabSettings = Window:AddTab({Title = "Settings"})
local TabServer = Window:AddTab({Title = "ServerHop"})

local Config = {
    AutoStealEnabled = true,
    AutoHopEnabled = true,
    AutoHopSecretEnabled = true,
    AutoHopSecretDelay = 0.25,
    AutoHopSecretDistance = 10,
    SpeedBoost = 4,
    ServerHopEnabled = false,
    ServerHopDelay = 10,
}

local function getMyPlotName()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("YourBase", true).Enabled then
            return plot.Name
        end
    end
    return nil
end

local function teleportToBase()
    local plotName = getMyPlotName()
    if not plotName then return end
    local plot = workspace.Plots:FindFirstChild(plotName)
    if plot and plot:FindFirstChild("PlotBlock") and plot.PlotBlock:FindFirstChild("Main") then
        local mainPart = plot.PlotBlock.Main
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and mainPart then
            hrp.CFrame = mainPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local currentSpeed = 0
RunService.Heartbeat:Connect(function(dt)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character.Humanoid
        if currentSpeed > 0 and hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character:TranslateBy(hum.MoveDirection * currentSpeed * dt * 10)
        end
    end
end)

local function findNearestSecretBrainrot()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest = nil
    local dist = math.huge
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot.Name ~= getMyPlotName() then
            for _, d in pairs(plot:GetDescendants()) do
                if d.Name == "Rarity" and d:IsA("TextLabel") and d.Text == "Secret" then
                    local model = d.Parent.Parent
                    if model and model.PrimaryPart then
                        local distance = (model.PrimaryPart.Position - root.Position).Magnitude
                        if distance < dist then
                            dist = distance
                            closest = model
                        end
                    end
                end
            end
        end
    end
    return closest, dist
end

local AutoStealLoop
AutoStealLoop = task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoStealEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target, distance = findNearestSecretBrainrot()
            if target then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                hrp.CFrame = target.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.3)
                teleportToBase()
                task.wait(1)
            end
        end
    end
end)

local function autoHop()
    while true do
        task.wait(0.25)
        if Config.AutoHopEnabled and Config.AutoStealEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid.Jump = true
            end
        end
    end
end
task.spawn(autoHop)

local function autoHopNearSecret()
    while true do
        task.wait(Config.AutoHopSecretDelay)
        if Config.AutoStealEnabled and Config.AutoHopSecretEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.FloorMaterial ~= Enum.Material.Air then
                local secrets = {}
                for _, plot in pairs(workspace.Plots:GetChildren()) do
                    if plot.Name ~= getMyPlotName() then
                        for _, d in pairs(plot:GetDescendants()) do
                            if d.Name == "Rarity" and d:IsA("TextLabel") and d.Text == "Secret" then
                                local model = d.Parent.Parent
                                if model and model.PrimaryPart then
                                    table.insert(secrets, model)
                                end
                            end
                        end
                    end
                end
                local nearSecret = false
                for _, secretModel in pairs(secrets) do
                    local dist = (secretModel.PrimaryPart.Position - root.Position).Magnitude
                    if dist <= Config.AutoHopSecretDistance then
                        nearSecret = true
                        break
                    end
                end
                if nearSecret then
                    humanoid.Jump = true
                end
            end
        end
    end
end
task.spawn(autoHopNearSecret)

local function hasSecretBrainrot()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        for _, d in pairs(plot:GetDescendants()) do
            if d.Name == "Rarity" and d:IsA("TextLabel") and d.Text == "Secret" then
                return true
            end
        end
    end
    return false
end

local function serverHop()
    local cursor
    while Config.ServerHopEnabled do
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
        if cursor then
            url = url .. "&cursor=" .. cursor
        end

        local success, response = pcall(game.HttpGet, game, url)
        if not success then
            task.wait(Config.ServerHopDelay)
            continue
        end

        local data = HttpService:JSONDecode(response)
        cursor = data.nextPageCursor

        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                task.wait(Config.ServerHopDelay)
                return
            end
        end

        if not cursor then break end
    end
end

task.spawn(function()
    while true do
        task.wait(Config.ServerHopDelay)
        if Config.ServerHopEnabled then
            if not hasSecretBrainrot() then
                serverHop()
            end
        end
    end
end)

-- Menu

local autoStealToggle = TabMain:AddToggle({Title = "Auto Steal", Default = Config.AutoStealEnabled})
autoStealToggle:OnChanged(function(v) Config.AutoStealEnabled = v end)

local autoHopToggle = TabSettings:AddToggle({Title = "Auto Hop", Default = Config.AutoHopEnabled})
autoHopToggle:OnChanged(function(v) Config.AutoHopEnabled = v end)

local autoHopSecretToggle = TabSettings:AddToggle({Title = "Auto Hop perto dos Secrets", Default = Config.AutoHopSecretEnabled})
autoHopSecretToggle:OnChanged(function(v) Config.AutoHopSecretEnabled = v end)

local autoHopSecretDelaySlider = TabSettings:AddSlider("AutoHopSecretDelay", {Title = "Delay Auto Hop Secret (s)", Min = 0.1, Max = 1, Default = Config.AutoHopSecretDelay, Rounding = 2})
autoHopSecretDelaySlider:OnChanged(function(v) Config.AutoHopSecretDelay = v end)

local autoHopSecretDistSlider = TabSettings:AddSlider("AutoHopSecretDist", {Title = "Distância Auto Hop Secret", Min = 5, Max = 30, Default = Config.AutoHopSecretDistance, Rounding = 1})
autoHopSecretDistSlider:OnChanged(function(v) Config.AutoHopSecretDistance = v end)

local speedSlider = TabSettings:AddSlider("SpeedBoost", {Title = "Speed Boost", Min = 0, Max = 10, Default = Config.SpeedBoost, Rounding = 1})
speedSlider:OnChanged(function(v) currentSpeed = v end)

local serverHopToggle = TabServer:AddToggle({Title = "Auto Server Hop para Secrets", Default = Config.ServerHopEnabled})
serverHopToggle:OnChanged(function(v) Config.ServerHopEnabled = v end)

local serverHopDelaySlider = TabServer:AddSlider("ServerHopDelay", {Title = "Delay entre hops (s)", Min = 5, Max = 30, Default = Config.ServerHopDelay, Rounding = 1})
serverHopDelaySlider:OnChanged(function(v) Config.ServerHopDelay = v end)
