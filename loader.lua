local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"))()
end)

if not success or not Fluent then
    warn("Falha ao carregar Fluent")
    return
end

local Window = Fluent:CreateWindow({
    Title = "Teste Menu",
    Size = UDim2.fromOffset(400, 300),
})

local Tab = Window:AddTab({ Title = "Principal" })

Tab:AddToggle("TesteToggle", { Text = "Toggle Teste", Default = false }):OnChanged(function(value)
    print("Toggle mudou para:", value)
end)
