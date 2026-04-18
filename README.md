--// =========================================
--// 🎮 TELEPORT PANEL FINAL (UI + FUNCIONES)
--// =========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--// CONFIG
local CONFIG = {
    Zombies = {Altura = 5, Distancia = 15, Separacion = 4},
    Materiales = {Altura = 3, Distancia = 8, Separacion = 2},
    Intervalo = 0.5
}

--// MATERIALES
local MaterialesLista = {
    "Bandage","BrokenLantern","ButcherKnife","CrackedBell","CrushedCan",
    "Gear","Lamp","M1Grand","MetalBarrel","MetalGear","Nail","Nut",
    "OldCan","Painting","RockingChair","Teapot","Toaster","VintageTV",
    "Wheel","WheelBarrow","WoodChair","WoodStool"
}

--// CONTAR ZOMBIES
local function ContarZombies()
    local carpeta = workspace:FindFirstChild("interactables")
    local lista = carpeta and carpeta:GetDescendants() or workspace:GetDescendants()
    
    local count = 0
    for _, v in ipairs(lista) do
        if v:IsA("Model") and v.PrimaryPart then
            if v.Name:lower():find("zombie") then
                count += 1
            end
        end
    end
    return count
end

--// OBTENER MODELOS
local function GetModels(filtro)
    local carpeta = workspace:FindFirstChild("interactables")
    local lista = carpeta and carpeta:GetDescendants() or workspace:GetDescendants()
    
    local t = {}
    for _, v in ipairs(lista) do
        if v:IsA("Model") and v.PrimaryPart then
            if filtro(v) then
                table.insert(t, v)
            end
        end
    end
    return t
end

--// TELEPORT
local function Teleport(models, cfg)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    
    for i, obj in ipairs(models) do
        local base = hrp.Position + hrp.CFrame.LookVector * cfg.Distancia
        
        local offset = Vector3.new(
            math.cos(i) * cfg.Separacion,
            0,
            math.sin(i) * cfg.Separacion
        )
        
        local pos = base + offset
        
        local ray = workspace:Raycast(pos, Vector3.new(0,-1000,0))
        local y = ray and ray.Position.Y + cfg.Altura or pos.Y
        
        obj:SetPrimaryPartCFrame(CFrame.new(pos.X, y, pos.Z))
    end
end

--// FUNCIONES
local function TPZombies()
    Teleport(GetModels(function(v)
        return v.Name:lower():find("zombie")
    end), CONFIG.Zombies)
end

local function TPMaterials()
    Teleport(GetModels(function(v)
        local name = v.Name
        for _, mat in ipairs(MaterialesLista) do
            if name == mat or name:lower() == mat:lower() then
                return true
            end
        end
        return false
    end), CONFIG.Materiales)
end

--// =========================================
--// 🎨 UI BONITA
--// =========================================

local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local Panel = Instance.new("Frame", gui)
Panel.Size = UDim2.new(0, 300, 0, 260)
Panel.Position = UDim2.new(0.5, -150, 0.5, -130)
Panel.BackgroundColor3 = Color3.fromRGB(20,20,25)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", Panel)
stroke.Color = Color3.fromRGB(0,255,150)
stroke.Thickness = 2

local grad = Instance.new("UIGradient", Panel)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35,35,45))
}

-- TITULO
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "ID_062009"
Title.TextColor3 = Color3.fromRGB(0,255,150)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBlack

local Sub = Instance.new("TextLabel", Panel)
Sub.Size = UDim2.new(1,0,0,20)
Sub.Position = UDim2.new(0,0,0,45)
Sub.BackgroundTransparency = 1
Sub.Text = "Teleport Panel"
Sub.TextColor3 = Color3.fromRGB(200,200,200)
Sub.TextSize = 14
Sub.Font = Enum.Font.Gotham

-- INFO
local Info = Instance.new("TextLabel", Panel)
Info.Size = UDim2.new(1,-20,0,120)
Info.Position = UDim2.new(0,10,0,75)
Info.BackgroundTransparency = 1
Info.Text = "Z → Zombies\nX → Materiales\nV → Mostrar/Ocultar"
Info.TextColor3 = Color3.new(1,1,1)
Info.TextSize = 14
Info.Font = Enum.Font.GothamSemibold
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top

-- CONTADOR
local ContadorLabel = Instance.new("TextLabel", Panel)
ContadorLabel.Size = UDim2.new(1,-20,0,25)
ContadorLabel.Position = UDim2.new(0,10,1,-55)
ContadorLabel.BackgroundTransparency = 1
ContadorLabel.Text = "🧟 Zombies: 0"
ContadorLabel.Font = Enum.Font.GothamBold
ContadorLabel.TextSize = 14
ContadorLabel.TextColor3 = Color3.new(1,1,1)
ContadorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- CREDITOS
local Credits = Instance.new("TextLabel", Panel)
Credits.Size = UDim2.new(1,-20,0,35)
Credits.Position = UDim2.new(0,10,1,-30)
Credits.BackgroundTransparency = 1
Credits.Text = "User_Roblox: Dilin123D\nIG: id_061817"
Credits.TextColor3 = Color3.fromRGB(150,150,150)
Credits.TextSize = 11
Credits.Font = Enum.Font.Gotham
Credits.TextXAlignment = Enum.TextXAlignment.Left
Credits.TextYAlignment = Enum.TextYAlignment.Top

--// CONTADOR LOOP
task.spawn(function()
    while true do
        task.wait(CONFIG.Intervalo)
        ContadorLabel.Text = "🧟 Zombies: " .. ContarZombies()
    end
end)

--// HOTKEYS
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        TPZombies()
    elseif input.KeyCode == Enum.KeyCode.X then
        TPMaterials()
    elseif input.KeyCode == Enum.KeyCode.V then
        Panel.Visible = not Panel.Visible
    end
end)
