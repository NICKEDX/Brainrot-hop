
-- SCRIPT COMPLETO HACK FURTIVO PARA 'STEAL A BRAINROT' -- TODAS AS FUNÇÕES ATIVADAS POR PADRÃO, SISTEMA DE SALVAMENTO ENTRE SERVIDORES -- INCLUI: AUTOHOP, AUTOGRAB, AUTOESCAPE, SPEED, NOCLIP, INVISIBILIDADE, ESP, ETC -- NÃO INCLUI LOADER, É PARA USO DIRETO

-- [ INÍCIO: VARIÁVEIS E GUI ] local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local Mouse = LocalPlayer:GetMouse() local RunService = game:GetService("RunService") local TeleportService = game:GetService("TeleportService") local HttpService = game:GetService("HttpService") local Workspace = game:GetService("Workspace") local TweenService = game:GetService("TweenService")

-- GUI segura local gui = Instance.new("ScreenGui") gui.Name = "BrainrotStealthGUI" gui.ResetOnSpawn = false gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame") frame.Size = UDim2.new(0, 300, 0, 350) frame.Position = UDim2.new(0.5, -150, 0.5, -175) frame.BackgroundTransparency = 0.2 frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) frame.BorderSizePixel = 0 frame.Active = true frame.Draggable = true frame.Parent = gui

local scrolling = Instance.new("ScrollingFrame") scrolling.Size = UDim2.new(1, 0, 1, 0) scrolling.CanvasSize = UDim2.new(0, 0, 2, 0) scrolling.ScrollBarThickness = 8 scrolling.BackgroundTransparency = 1 scrolling.Parent = frame

local function newButton(name, callback) local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, -10, 0, 30) btn.Position = UDim2.new(0, 5, 0, #scrolling:GetChildren() * 35) btn.Text = name btn.TextColor3 = Color3.new(1, 1, 1) btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) btn.BorderSizePixel = 0 btn.Font = Enum.Font.SourceSansBold btn.TextSize = 18 btn.MouseButton1Click:Connect(callback) btn.Parent = scrolling end

-- [ SALVAMENTO DE CONFIGURAÇÃO ENTRE SERVIDORES ] getgenv().AutoHop = true getgenv().AutoGrab = true getgenv().AutoEscape = true getgenv().SpeedHack = true getgenv().Noclip = true getgenv().Invisible = true getgenv().ESP = true getgenv().SavePaths = true

queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/seuscript/brainrot.lua"))()]])

-- [ FUNÇÕES DE HACK ]

-- Noclip RunService.Stepped:Connect(function() if getgenv().Noclip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide == true then v.CanCollide = false end end end end)

-- Speed boost local speed = 50 RunService.RenderStepped:Connect(function() if getgenv().SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = speed end end)

-- Invisibilidade local function invis() if getgenv().Invisible and LocalPlayer.Character then for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 1 if part:FindFirstChild("face") then part.face.Transparency = 1 end end end end end invis()

-- ESP local function createESP(target, color) if target:FindFirstChild("ESP") then return end local box = Instance.new("BoxHandleAdornment") box.Name = "ESP" box.Size = target.Size + Vector3.new(0.1, 0.1, 0.1) box.Adornee = target box.Color3 = color box.AlwaysOnTop = true box.ZIndex = 10 box.Transparency = 0.4 box.Parent = target end

RunService.RenderStepped:Connect(function() if getgenv().ESP then for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Part") and v.Name == "SecretBrainrot" then createESP(v, Color3.new(0, 1, 0)) elseif v:IsA("Model") and Players:GetPlayerFromCharacter(v) and v ~= LocalPlayer.Character then if v:FindFirstChild("HumanoidRootPart") then createESP(v.HumanoidRootPart, Color3.new(1, 0, 0)) end end end end end)

-- AutoHop local function hopServers() local servers = {} local req = syn and syn.request or http_request or request local success, result = pcall(function() return req({ Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" }) end) if success then local data = HttpService:JSONDecode(result.Body) for _, v in pairs(data.data) do if v.playing < v.maxPlayers then table.insert(servers, v.id) end end if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)]) end end end

-- AutoGrab + AutoEscape RunService.Heartbeat:Connect(function() if getgenv().AutoGrab then for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Part") and obj.Name == "SecretBrainrot" then LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame wait(0.5) if getgenv().AutoEscape then for _, v in pairs(Workspace:GetChildren()) do if v:IsA("Part") and v.Name == "Escape" then LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame wait(0.5) end end end if getgenv().AutoHop then hopServers() end end end end end)

-- [ FIM DO SCRIPT COMPLETO HACK FURTIVO ]


local frame = Instance.new("Frame") frame.Size = UDim2.new(0, 300, 0, 350) frame.Position = UDim2.new(0.5, -150, 0.5, -175) frame.BackgroundTransparency = 0.2 frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) frame.BorderSizePixel = 0 frame.Active = true frame.Draggable = true frame.Parent = gui

local scrolling = Instance.new("ScrollingFrame") scrolling.Size = UDim2.new(1, 0, 1, 0) scrolling.CanvasSize = UDim2.new(0, 0, 2, 0) scrolling.ScrollBarThickness = 8 scrolling.BackgroundTransparency = 1 scrolling.Parent = frame

local function newButton(name, callback) local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, -10, 0, 30) btn.Position = UDim2.new(0, 5, 0, #scrolling:GetChildren() * 35) btn.Text = name btn.TextColor3 = Color3.new(1, 1, 1) btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) btn.BorderSizePixel = 0 btn.Font = Enum.Font.SourceSansBold btn.TextSize = 18 btn.MouseButton1Click:Connect(callback) btn.Parent = scrolling end

-- [ SALVAMENTO DE CONFIGURAÇÃO ENTRE SERVIDORES ] getgenv().AutoHop = true getgenv().AutoGrab = true getgenv().AutoEscape = true getgenv().SpeedHack = true getgenv().Noclip = true getgenv().Invisible = true getgenv().ESP = true getgenv().SavePaths = true

queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/seuscript/brainrot.lua"))()]])

-- [ FUNÇÕES DE HACK ]

-- Noclip RunService.Stepped:Connect(function() if getgenv().Noclip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide == true then v.CanCollide = false end end end end)

-- Speed boost local speed = 50 RunService.RenderStepped:Connect(function() if getgenv().SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = speed end end)

-- Invisibilidade local function invis() if getgenv().Invisible and LocalPlayer.Character then for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 1 if part:FindFirstChild("face") then part.face.Transparency = 1 end end end end end invis()

-- ESP local function createESP(target, color) if target:FindFirstChild("ESP") then return end local box = Instance.new("BoxHandleAdornment") box.Name = "ESP" box.Size = target.Size + Vector3.new(0.1, 0.1, 0.1) box.Adornee = target box.Color3 = color box.AlwaysOnTop = true box.ZIndex = 10 box.Transparency = 0.4 box.Parent = target end

RunService.RenderStepped:Connect(function() if getgenv().ESP then for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Part") and v.Name == "SecretBrainrot" then createESP(v, Color3.new(0, 1, 0)) elseif v:IsA("Model") and Players:GetPlayerFromCharacter(v) and v ~= LocalPlayer.Character then if v:FindFirstChild("HumanoidRootPart") then createESP(v.HumanoidRootPart, Color3.new(1, 0, 0)) end end end end end)

-- AutoHop local function hopServers() local servers = {} local req = syn and syn.request or http_request or request local success, result = pcall(function() return req({ Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" }) end) if success then local data = HttpService:JSONDecode(result.Body) for _, v in pairs(data.data) do if v.playing < v.maxPlayers then table.insert(servers, v.id) end end if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)]) end end end

-- AutoGrab + AutoEscape RunService.Heartbeat:Connect(function() if getgenv().AutoGrab then for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Part") and obj.Name == "SecretBrainrot" then LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame wait(0.5) if getgenv().AutoEscape then for _, v in pairs(Workspace:GetChildren()) do if v:IsA("Part") and v.Name == "Escape" then LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame wait(0.5) end end end if getgenv().AutoHop then hopServers() end end end end end)

-- [ FIM DO SCRIPT COMPLETO HACK FURTIVO ]

