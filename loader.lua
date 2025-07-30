local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local PlaceID = game.PlaceId
local player = Players.LocalPlayer

local SECRET_INDICATOR_NAME = "SecretItem"
local hopEnabled = false

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "HopMenu"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Brainrot Hop Menu"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local function createButton(text, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = true
    return btn
end

local btnToggleHop = createButton("Ativar Hop Automático: OFF", 40)
local btnSetSecret = createButton("Definir Nome do Secret", 80)
local btnForceHop = createButton("Forçar Hop Agora", 120)
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Esperando..."
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 160)
statusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 14

local function GetServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceID)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local response
