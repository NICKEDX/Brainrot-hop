local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"))()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "Steal a Brainrot",
    SubTitle = "Furtivo Exploit",
    TabWidth = 120,
    Size = UDim2.fromOffset(520, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "🌌" }),
    Server = Window:AddTab({ Title = "ServerHop", Icon = "🚪" }),
}

local Config = {
    AutoSteal = true,
    SpeedBoost = true,
    Noclip = true,
    AutoHop = true,
    ServerHopSecret = true,
    ServerHopDelay = 4,
}

local function GetMyBase()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("YourBase", true) and plot:FindFirstChild("YourBase", true).Enabled then
            return plot
        end
    end
end

local function TeleportTo(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = pos + Vector3.new(0, 3, 0) end
end

local function GetSecrets()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Part") and obj.Name:lower():find("brainrot") and obj.Name:lower():find("secret") then
            table.insert(targets, obj)
        end
    end
    return targets
end

local function GrabClosestSecret()
    local secrets = GetSecrets()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.sort(secrets, function(a, b)
            return (a:GetModelCFrame().Position - hrp.Position).Magnitude < (b:GetModelCFrame().Position - hrp.Position).Magnitude
        end)
        return secrets[1]
    end
end

local function AutoStealLoop()
    while task.wait(0.15) do
        if Config.AutoSteal then
            local target = GrabClosestSecret()
            if target then
                TeleportTo(target:GetModelCFrame())
                task.wait(0.3)
                TeleportTo(GetMyBase().PlotBlock.Main.CFrame)
            end
        end
    end
end

local function SpeedBoostLoop()
    RunService.Heartbeat:Connect(function(dt)
        if Config.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LocalPlayer.Character.Humanoid
            if hum.MoveDirection.Magnitude > 0 then
                LocalPlayer.Character:TranslateBy(hum.MoveDirection * 3 * dt * 10)
            end
        end
    end)
end

local function ServerHop()
    while Config.ServerHopSecret do
        if #GetSecrets() == 0 then
            local servers = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            local data = HttpService:JSONDecode(servers)
            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                    return
                end
            end
        end
        task.wait(Config.ServerHopDelay)
    end
end

Tabs.Main:AddToggle("AutoSteal", {Text = "Auto Steal Secret", Default = true}):OnChanged(function(v)
    Config.AutoSteal = v
end)

Tabs.Main:AddToggle("SpeedBoost", {Text = "Speed Boost", Default = true}):OnChanged(function(v)
    Config.SpeedBoost = v
end)

Tabs.Server:AddToggle("ServerHopSecret", {Text = "Auto Server Hop (Secret)", Default = true}):OnChanged(function(v)
    Config.ServerHopSecret = v
end)

Tabs.Server:AddSlider("Delay", {
    Text = "Delay entre ServerHops",
    Min = 2,
    Max = 15,
    Default = 4,
    Rounding = 1,
    Compact = false,
}):OnChanged(function(v)
    Config.ServerHopDelay = v
end)

task.spawn(AutoStealLoop)
task.spawn(SpeedBoostLoop)
task.spawn(ServerHop)
