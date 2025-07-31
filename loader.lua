local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

getgenv().Settings = getgenv().Settings or {
AutoSteal = true,
AutoHop = true,
BrainrotName = "Brainrot"
}

local function SaveSettings()
writefile("BrainrotSettings.json", HttpService:JSONEncode(getgenv().Settings))
end

local function LoadSettings()
if isfile("BrainrotSettings.json") then
local data = readfile("BrainrotSettings.json")
local loaded = HttpService:JSONDecode(data)
for k, v in pairs(loaded) do
getgenv().Settings[k] = v
end
end
end

LoadSettings()

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.02, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function CreateToggle(name, default, callback, posY)
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0, 200, 0, 25)
toggle.Position = UDim2.new(0, 10, 0, posY)
toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Text = name .. ": " .. (default and "ON" or "OFF")
local state = default
toggle.MouseButton1Click:Connect(function()
state = not state
toggle.Text = name .. ": " .. (state and "ON" or "OFF")
callback(state)
SaveSettings()
end)
end

CreateToggle("AutoSteal", getgenv().Settings.AutoSteal, function(v)
getgenv().Settings.AutoSteal = v
end, 10)

CreateToggle("AutoHop", getgenv().Settings.AutoHop, function(v)
getgenv().Settings.AutoHop = v
end, 40)

local dropdownLabel = Instance.new("TextLabel", frame)
dropdownLabel.Position = UDim2.new(0, 10, 0, 70)
dropdownLabel.Size = UDim2.new(0, 200, 0, 20)
dropdownLabel.Text = "Nome do Brainrot:"
dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownLabel.BackgroundTransparency = 1

local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(0, 200, 0, 25)
nameBox.Position = UDim2.new(0, 10, 0, 95)
nameBox.Text = getgenv().Settings.BrainrotName or "Brainrot"
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
nameBox.FocusLost:Connect(function()
getgenv().Settings.BrainrotName = nameBox.Text
SaveSettings()
end)local function Noclip()
for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
if v:IsA("BasePart") and v.CanCollide == true then
v.CanCollide = false
end
end
end

RunService.Stepped:Connect(function()
if getgenv().Settings.AutoSteal then
Noclip()
end
end)

local function CreateESP(part)
local box = Instance.new("BoxHandleAdornment")
box.Size = part.Size + Vector3.new(0.5, 0.5, 0.5)
box.Adornee = part
box.AlwaysOnTop = true
box.ZIndex = 5
box.Color3 = Color3.fromRGB(255, 0, 0)
box.Transparency = 0.5
box.Name = "ESPBrainrot"
box.Parent = part
end

local function TeleportTo(part)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character:MoveTo(part.Position + Vector3.new(0, 3, 0))
end
end

local function IsBrainrot(obj)
local name = obj.Name:lower()
return name:find("brainrot") or name:find(getgenv().Settings.BrainrotName:lower())
end

local function ScanAndSteal()
if not getgenv().Settings.AutoSteal then return end

local closest, distance = nil, math.huge  
for _, v in pairs(workspace:GetDescendants()) do  
    if v:IsA("BasePart") and IsBrainrot(v) and not v:FindFirstChild("ESPBrainrot") then  
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude  
        if dist < distance then  
            closest = v  
            distance = dist  
        end  
        CreateESP(v)  
    end  
end  

if closest then  
    TeleportTo(closest)  
    wait(0.5)  
    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, closest, 0)  
    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, closest, 1)  
    wait(0.2)  
end

end

task.spawn(function()
while task.wait(1) do
ScanAndSteal()
end
end)local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

local function Hop()
local servers = {}
local cursor = ""
local success, result = pcall(function()
return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=2&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")))
end)

if success and result and result.data then  
    for _, server in pairs(result.data) do  
        if server.playing < server.maxPlayers and server.id ~= game.JobId then  
            table.insert(servers, server.id)  
        end  
    end  
end  

if #servers > 0 then  
    TeleportService:TeleportToPlaceInstance(PlaceID, servers[math.random(1, #servers)], LocalPlayer)  
end

end

local function HasBrainrots()
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("BasePart") and IsBrainrot(v) then
return true
end
end
return false
end

task.spawn(function()
while task.wait(10) do
if getgenv().Settings.AutoHop and not HasBrainrots() then
Hop()
end
end
end)local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

getgenv().Settings = getgenv().Settings or {
AutoSteal = true,
AutoHop = true,
BrainrotName = "Secret",
}

local function SaveSettings()
if queue_on_teleport then
queue_on_teleport([[
getgenv().Settings = ]] .. HttpService:JSONEncode(getgenv().Settings) .. [[
]])
end
end

local function CreateToggle(name, default, callback)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 140, 0, 30)
button.Text = name .. ": " .. (default and "ON" or "OFF")
button.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextScaled = true
button.MouseButton1Click:Connect(function()
default = not default
getgenv().Settings[name] = default
button.Text = name .. ": " .. (default and "ON" or "OFF")
button.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
SaveSettings()
if callback then callback(default) end
end)
return button
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BrainrotMenu"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 160)
frame.Position = UDim2.new(0, 10, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local uilist = Instance.new("UIListLayout", frame)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
uilist.VerticalAlignment = Enum.VerticalAlignment.Center
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0, 5)

local stealToggle = CreateToggle("AutoSteal", getgenv().Settings.AutoSteal)
local hopToggle = CreateToggle("AutoHop", getgenv().Settings.AutoHop)

local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(0, 140, 0, 30)
nameBox.Text = getgenv().Settings.BrainrotName or "Secret"
nameBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
nameBox.TextColor3 = Color3.new(1, 1, 1)
nameBox.Font = Enum.Font.SourceSansBold
nameBox.TextScaled = true
nameBox.FocusLost:Connect(function()
getgenv().Settings.BrainrotName = nameBox.Text
SaveSettings()
end)

stealToggle.Parent = frame
hopToggle.Parent = frame
nameBox.Parent = frame

SaveSettings()

