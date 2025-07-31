local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoHop = true,
    SpeedBoost = true,
    Noclip = true,
    AutoEscape = true,
    AutoBrainrot = true,
    AutoSecrets = true,
    ESP = true,
    BaseProtection = true,
    TrollMode = false,
}

local SaveKey = "StealBrainrotConfig_"..tostring(LocalPlayer.UserId)

local function SaveConfig()
    pcall(function()
        local json = HttpService:JSONEncode(Config)
        if writefile then
            writefile(SaveKey..".json", json)
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(SaveKey..".json") then
            local content = readfile(SaveKey..".json")
            local decoded = HttpService:JSONDecode(content)
            for k,v in pairs(decoded) do
                Config[k] = v
            end
        end
    end)
end

LoadConfig()

local Toggles = {}

function CreateToggle(name, default)
    Toggles[name] = default
    return {
        Get = function() return Toggles[name] end,
        Set = function(val)
            Toggles[name] = val
            Config[name] = val
            SaveConfig()
        end
    }
endlocal RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local toggles = {
    AutoHop = true,
    SpeedBoost = true,
    Noclip = true,
    AutoEscape = true,
}

local speedMultiplier = 1.8
local defaultWalkSpeed = 16
local noclipConnection

local function AutoHop()
    if not toggles.AutoHop then return end
    if Humanoid.FloorMaterial ~= Enum.Material.Air and Humanoid:GetState() == Enum.HumanoidStateType.Running then
        Humanoid.Jump = true
    end
end

local function SpeedBoost()
    if toggles.SpeedBoost then
        Humanoid.WalkSpeed = defaultWalkSpeed * speedMultiplier
    else
        Humanoid.WalkSpeed = defaultWalkSpeed
    end
end

local function SetNoclip(state)
    if state then
        if noclipConnection then return end
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local escapePosition = Vector3.new(0, 50, 0)

local function AutoEscape()
    if not toggles.AutoEscape then return end
    RootPart.CFrame = CFrame.new(escapePosition)
end

RunService.Heartbeat:Connect(function()
    AutoHop()
    SpeedBoost()
    SetNoclip(toggles.Noclip)
end)

return {
    SetToggle = function(name, state)
        if toggles[name] ~= nil then
            toggles[name] = state
        end
    end,
    AutoEscape = AutoEscape,
    }local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local ESPObjects = {}

local function CreateESP(part, color)
    if ESPObjects[part] then return ESPObjects[part] end
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.AlwaysOnTop = true
    adorn.ZIndex = 10
    adorn.Transparency = 0.5
    adorn.Size = part.Size
    adorn.Color3 = color
    adorn.Parent = part
    ESPObjects[part] = adorn
    return adorn
end

local function RemoveESP(part)
    local adorn = ESPObjects[part]
    if adorn then
        adorn:Destroy()
        ESPObjects[part] = nil
    end
end

local function UpdateESP()
    if not ESPEnabled then
        for part, adorn in pairs(ESPObjects) do
            adorn:Destroy()
        end
        ESPObjects = {}
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            CreateESP(player.Character.HumanoidRootPart, Color3.new(1,0,0))
        else
            RemoveESP(player.Character and player.Character:FindFirstChild("HumanoidRootPart"))
        end
    end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Brainrot" and obj:IsA("BasePart") then
            CreateESP(obj, Color3.new(1,1,0))
        elseif obj.Name == "Secret" and obj:IsA("BasePart") then
            CreateESP(obj, Color3.new(0,1,1))
        end
    end
end

RunService.Heartbeat:Connect(UpdateESP)

return {
    SetESP = function(state)
        ESPEnabled = state
        if not state then
            for part, adorn in pairs(ESPObjects) do
                adorn:Destroy()
            end
            ESPObjects = {}
        end
    end
    }local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

local toggles = {
    AutoBrainrot = true,
}

local function getBrainrot()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Brainrot" and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

local function isBrainrotFree(brainrot)
    if not brainrot then return false end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - brainrot.Position).Magnitude
            if dist < 5 then
                return false
            end
        end
    end
    return true
end

local function teleportTo(position)
    RootPart.CFrame = CFrame.new(position + Vector3.new(0,3,0))
end

local function interactWithBrainrot(brainrot)
    local prompt = nil
    for _, child in pairs(brainrot:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            prompt = child
            break
        end
    end
    if prompt then
        prompt:InputHoldBegin()
        wait(0.1)
        prompt:InputHoldEnd()
    end
end

RunService.Heartbeat:Connect(function()
    if toggles.AutoBrainrot then
        local brainrot = getBrainrot()
        if brainrot and isBrainrotFree(brainrot) then
            teleportTo(brainrot.Position)
            interactWithBrainrot(brainrot)
        end
    end
end)

return {
    SetToggle = function(state)
        toggles.AutoBrainrot = state
    end,
    }local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local LocalPlayer=game:GetService("Players").LocalPlayer
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart=Character:WaitForChild("HumanoidRootPart")
local toggles={BaseProtection=true}
local baseOpen=false
local basePart=nil
local baseButton=nil
for _,obj in pairs(Workspace:GetChildren())do
    if obj.Name=="BaseDoor"or obj.Name=="Base"then
        basePart=obj
        for _,child in pairs(obj:GetChildren())do
            if child.Name=="Button"or child:IsA("ClickDetector")or child:IsA("ProximityPrompt")then
                baseButton=child
                break
            end
        end
        break
    end
end
local function checkBaseState()
    if not basePart then return false end
    if basePart:FindFirstChild("Open") and basePart.Open:IsA("BoolValue")then
        return basePart.Open.Value
    end
    return false
end
local function onBaseOpened()
    if not toggles.BaseProtection then return end
    baseOpen=true
end
local function onBaseClosed()
    baseOpen=false
end
RunService.Heartbeat:Connect(function()
    local state=checkBaseState()
    if state~=baseOpen then
        if state then onBaseOpened() else onBaseClosed() end
    end
end)
return{
    SetToggle=function(state) toggles.BaseProtection=state end,
    IsBaseOpen=function() return baseOpen end,
    }local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="StealBrainrotGUI"
ScreenGui.Parent=game.CoreGui
local Frame=Instance.new("Frame",ScreenGui)
Frame.Size=UDim2.new(0,300,0,400)
Frame.Position=UDim2.new(0,50,0,50)
Frame.BackgroundColor3=Color3.fromRGB(30,30,30)
Frame.Active=true
Frame.Draggable=true
local UIListLayout=Instance.new("UIListLayout",Frame)
UIListLayout.SortOrder=Enum.SortOrder.LayoutOrder
UIListLayout.Padding=UDim.new(0,5)
local Config={}
local function CreateToggle(name,default,callback)
    local toggleFrame=Instance.new("Frame",Frame)
    toggleFrame.Size=UDim2.new(1,-10,0,30)
    toggleFrame.BackgroundTransparency=1
    local label=Instance.new("TextLabel",toggleFrame)
    label.Text=name
    label.Size=UDim2.new(0.7,0,1,0)
    label.BackgroundTransparency=1
    label.TextColor3=Color3.new(1,1,1)
    label.TextXAlignment=Enum.TextXAlignment.Left
    local toggleButton=Instance.new("TextButton",toggleFrame)
    toggleButton.Size=UDim2.new(0.3,0,1,0)
    toggleButton.Position=UDim2.new(0.7,0,0,0)
    toggleButton.Text=default and"ON"or"OFF"
    toggleButton.BackgroundColor3=default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    toggleButton.TextColor3=Color3.new(1,1,1)
    toggleButton.MouseButton1Click:Connect(function()
        local newState=toggleButton.Text=="OFF"
        toggleButton.Text=newState and"ON"or"OFF"
        toggleButton.BackgroundColor3=newState and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        if callback then callback(newState)end
    end)
    return toggleButton
end
local Toggles={}
Toggles.AutoHop=CreateToggle("Auto Hop",true,function(state)Config.AutoHop=state end)
Toggles.SpeedBoost=CreateToggle("Speed Boost",true,function(state)Config.SpeedBoost=state end)
Toggles.Noclip=CreateToggle("Noclip",true,function(state)Config.Noclip=state end)
Toggles.AutoBrainrot=CreateToggle("Auto Brainrot",true,function(state)Config.AutoBrainrot=state end)
Toggles.ESP=CreateToggle("ESP",true,function(state)Config.ESP=state end)
Toggles.BaseProtection=CreateToggle("Base Protection",true,function(state)Config.BaseProtection=state end)
return{
    GetConfig=function()return Config end,
    SetToggleState=function(name,state)
        if Toggles[name]then
            Toggles[name].Text=state and"ON"or"OFF"
            Toggles[name].BackgroundColor3=state and Color3.fromRGB(0,170,0)or Color3.fromRGB(170,0,0)
            Config[name]=state
        end
    end,
    Gui=ScreenGui,
    }
