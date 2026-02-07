local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "FTF Ghost v34 - by souteX",
   LoadingTitle = "Iniciando Script...",
   LoadingSubtitle = "by SouteX",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

_G.WalkSpeed = 16
_G.InfJump = false
_G.CompESP = false
_G.PlayerESP = false
_G.PodESP = false
_G.ExitESP = false
_G.FreeCamActive = false

local Light = game:GetService("Lighting")
local localPlayer = game.Players.LocalPlayer
local AzulPC = Color3.fromRGB(0, 85, 255)
local CorSobrevivente = Color3.fromRGB(0, 255, 255)
local CorBesta = Color3.fromRGB(255, 0, 0)
local CorPod = Color3.fromRGB(255, 170, 0)
local CorSaidaMarrrom = Color3.fromRGB(101, 67, 33)

local cache = { Comps = {}, Pods = {}, Exits = {} }

local function RefreshMapCache()
    table.clear(cache.Comps)
    table.clear(cache.Pods)
    table.clear(cache.Exits)
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v.Name == "ComputerTable" then table.insert(cache.Comps, v)
        elseif (v.Name == "FreezePod" or v.Name == "CryoPod") and v:IsA("Model") then table.insert(cache.Pods, v)
        elseif (v.Name == "ExitDoor" or v.Name == "ExitGate") and v:IsA("Model") then table.insert(cache.Exits, v)
        end
    end
end

local function SimpleClear(tag)
    task.spawn(function()
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Highlight") and v.Name == tag then v:Destroy() end
        end
    end)
end

RefreshMapCache()
localPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    RefreshMapCache()
end)

local function UpdateESP()
    if _G.CompESP then
        for _, v in pairs(cache.Comps) do
            if v and v.Parent then
                local hl = v:FindFirstChild("CompHighlight") or Instance.new("Highlight", v)
                hl.Name = "CompHighlight"
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.8
                if hl.FillColor ~= Color3.fromRGB(0, 255, 0) then
                    local screen = v:FindFirstChild("Screen", true)
                    if screen then
                        local target = Color3.new(0.156863, 0.498039, 0.278431)
                        if (math.abs(screen.Color.r - target.r) < 0.01) then hl.FillColor = Color3.fromRGB(0, 255, 0)
                        elseif v:FindFirstChild("Smoke", true) then hl.FillColor = Color3.fromRGB(255, 0, 0)
                        else hl.FillColor = AzulPC end
                    end
                end
            end
        end
    end

    if _G.PlayerESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local hl = p.Character:FindFirstChild("PlayerHighlight") or Instance.new("Highlight", p.Character)
                    hl.Name = "PlayerHighlight"
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0.8
                    local isBeast = p.Character:FindFirstChild("Hammer") or p.Backpack:FindFirstChild("Hammer")
                    hl.FillColor = isBeast and CorBesta or CorSobrevivente
                end
            end
        end
    end

    if _G.PodESP then
        for _, v in pairs(cache.Pods) do
            if v and v.Parent then
                local hl = v:FindFirstChild("PodHighlight") or Instance.new("Highlight", v)
                hl.Name = "PodHighlight"
                hl.FillColor = CorPod
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0.8
            end
        end
    end

    if _G.ExitESP then
        for _, v in pairs(cache.Exits) do
            if v and v.Parent then
                local hl = v:FindFirstChild("ExitHighlight") or Instance.new("Highlight", v)
                hl.Name = "ExitHighlight"
                hl.FillColor = CorSaidaMarrrom
                hl.FillTransparency = 0.4
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0 
            end
        end
    end
end


local TabVisual = Window:CreateTab("Visuais", 4483345998)
local TabMove = Window:CreateTab("Movimentação", 6035067836)

TabVisual:CreateToggle({ Name = "ESP Computadores", CurrentValue = false, Callback = function(v) _G.CompESP = v if not v then SimpleClear("CompHighlight") end end })
TabVisual:CreateToggle({ Name = "ESP Jogadores", CurrentValue = false, Callback = function(v) _G.PlayerESP = v if not v then SimpleClear("PlayerHighlight") end end })
TabVisual:CreateToggle({ Name = "ESP Tubos", CurrentValue = false, Callback = function(v) _G.PodESP = v if not v then SimpleClear("PodHighlight") end end })
TabVisual:CreateToggle({ Name = "ESP Saídas", CurrentValue = false, Callback = function(v) _G.ExitESP = v if not v then SimpleClear("ExitHighlight") end end })

-- Velocidade alterada de Slider para Input (caixinha)
TabMove:CreateInput({
   Name = "Velocidade",
   PlaceholderText = "Padrão: 16",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local num = tonumber(Text)
       if num then
           _G.WalkSpeed = num
       end
   end,
})

TabMove:CreateToggle({ Name = "Pulo Infinito", CurrentValue = false, Callback = function(v) _G.InfJump = v end })

TabMove:CreateButton({
   Name = "FreeCam",
   Callback = function()
       _G.FreeCamActive = true
       Rayfield:Notify({
          Title = "Câmera Liberada",
          Content = "A trava de primeira pessoa do Beast foi removida!",
          Duration = 3,
          Image = 4483345998,
       })
   end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local p = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if p then p:ChangeState("Jumping") end
    end
end)

task.spawn(function()
    while true do
        if _G.FreeCamActive then
            local char = localPlayer.Character
            local isBeast = char and (char:FindFirstChild("Hammer") or localPlayer.Backpack:FindFirstChild("Hammer"))
            
            if isBeast then
                localPlayer.CameraMaxZoomDistance = 100
                localPlayer.CameraMode = Enum.CameraMode.Classic
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    local scanCount = 0
    while true do
        UpdateESP()
        scanCount = scanCount + 1
        if scanCount >= 20 then RefreshMapCache(); scanCount = 0 end
        task.wait(0.5)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local char = localPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = _G.WalkSpeed
    end
end)
