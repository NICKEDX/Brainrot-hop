local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local configs = {}

local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "BrainrotGUI"
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0, 50, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 10, 0)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder

function createToggle(name, default, callback)
    local toggle = Instance.new("TextButton", scroll)
    toggle.Size = UDim2.new(1, -10, 0, 30)
    toggle.BackgroundColor3 = default and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
    toggle.Text = "[OFF] " .. name
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14

    local state = default
    if default then
        toggle.Text = "[ON] " .. name
        toggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "[ON] " .. name or "[OFF] " .. name
        toggle.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
        callback(state)
        configs[name] = state
    end)

    configs[name] = default
end

function noclipFunc(state)
    rs:UnbindFromRenderStep("noclip")
    if state then
        rs:BindToRenderStep("noclip", Enum.RenderPriority.Character.Value, function()
            for _, part in pairs(lp.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end)
    end
end

function speedFunc(state)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and 60 or 16
    end
end

function invisFunc(state)
    for _, p in pairs(lp.Character:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = state and 1 or 0
        end
    end
end

function autoHop(state)
    if not state then return end
    spawn(function()
        while configs["Auto-Hop Inteligente"] do
            task.wait(3)
            if workspace:FindFirstChild("Secret") == nil then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId)
            end
        end
    end)
end

function autoSteal(state)
    if not state then return end
    spawn(function()
        while configs["Auto-Roubo"] do
            task.wait(0.5)
            local brain = workspace:FindFirstChild("Brainrot")
            if brain and brain:IsA("Tool") then
                hrp.CFrame = brain.Handle.CFrame + Vector3.new(0, 5, 0)
                firetouchinterest(brain.Handle, lp.Character:FindFirstChild("HumanoidRootPart"), 0)
            end
        end
    end)
end

function fakeDrop()
    local clone = Instance.new("Part", workspace)
    clone.Size = Vector3.new(2, 2, 2)
    clone.Color = Color3.fromRGB(200, 0, 200)
    clone.Position = hrp.Position + Vector3.new(0, 3, 0)
    clone.Anchored = true
    clone.Name = "FakeBrainrot"
    game:GetService("Debris"):AddItem(clone, 10)
end

createToggle("Noclip", false, noclipFunc)
createToggle("Speed Boost", true, speedFunc)
createToggle("Invisibilidade", false, invisFunc)
createToggle("Auto-Hop Inteligente", true, autoHop)
createToggle("Auto-Roubo", true, autoSteal)
createToggle("ESP Players/Secrets", true, function(state) end)
createToggle("Teleportar para Secrets", false, function(state) end)
createToggle("Modo Troll (Drop Fake)", false, function(state) if state then fakeDrop() end end)

pcall(function()
    local HttpService = game:GetService("HttpService")
    if writefile and isfile then
        if isfile("brainconfig.json") then
            local data = HttpService:JSONDecode(readfile("brainconfig.json"))
            for name, val in pairs(data) do
                configs[name] = val
            end
        end
        writefile("brainconfig.json", HttpService:JSONEncode(configs))
    end
end)
