--// =========================================
--// 🎮 TELEPORT PANEL (PC + MOVIL COMPLETO)
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
        if v:IsA("Model") and v.PrimaryPart and v.Name:lower():find("zombie") then
            count += 1
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
        if v:IsA("Model") and v.PrimaryPart and filtro(v) then
            table.insert(t, v)
        end
    end
    return t
end

--// TELEPORT
local function Teleport(models, cfg)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

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
        for _, mat in ipairs(MaterialesLista) do
            if v.Name:lower() == mat:lower() then
                return true
            end
        end
        return false
    end), CONFIG.Materiales)
end

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportPanel"
gui.Parent = LP:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local Panel = Instance.new("Frame", gui)
Panel.Size = UDim2.new(0, 300, 0, 320)
Panel.Position = UDim2.new(0.5, -150, 0.5, -160)
Panel.BackgroundColor3 = Color3.fromRGB(25,25,30)
Panel.Active = true
Panel.Draggable = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,12)

-- TITULO
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "ID_062009"
Title.TextColor3 = Color3.fromRGB(0,255,150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20

-- CONTROLES
local Controls = Instance.new("TextLabel", Panel)
Controls.Size = UDim2.new(1,-20,0,80)
Controls.Position = UDim2.new(0,10,0,50)
Controls.BackgroundTransparency = 1
Controls.Text =
    "🎮 Controles:\n" ..
    "Z → Teleport Zombies\n" ..
    "X → Teleport Materiales\n" ..
    "V → Mostrar / Ocultar"
Controls.TextColor3 = Color3.fromRGB(200,200,200)
Controls.Font = Enum.Font.Gotham
Controls.TextSize = 13
Controls.TextXAlignment = Enum.TextXAlignment.Left
Controls.TextYAlignment = Enum.TextYAlignment.Top

-- BOTONES (MOVIL)
local function CrearBoton(txt, y, func)
    local b = Instance.new("TextButton", Panel)
    b.Size = UDim2.new(1,-20,0,40)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40,40,45)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b)

    b.MouseButton1Click:Connect(func)
end

CrearBoton("🧟 Teleport Zombies (Z)", 130, TPZombies)
CrearBoton("📦 Teleport Materiales (X)", 180, TPMaterials)

-- BOTON MOSTRAR/OCULTAR (MOVIL)
local ToggleBtn = Instance.new("TextButton", gui)
ToggleBtn.Size = UDim2.new(0,140,0,40)
ToggleBtn.Position = UDim2.new(0,20,1,-60)
ToggleBtn.Text = "Mostrar / Ocultar (V)"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,255,150)
ToggleBtn.TextColor3 = Color3.new(0,0,0)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14

ToggleBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
end)

-- CONTADOR
local contador = Instance.new("TextLabel", Panel)
contador.Size = UDim2.new(1,-20,0,30)
contador.Position = UDim2.new(0,10,1,-40)
contador.BackgroundTransparency = 1
contador.TextColor3 = Color3.new(1,1,1)
contador.Font = Enum.Font.GothamBold
contador.TextSize = 14

-- LOOP CONTADOR
task.spawn(function()
    while true do
        task.wait(CONFIG.Intervalo)
        contador.Text = "🧟 Zombies: "..ContarZombies()
    end
end)

-- HOTKEYS PC
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.Z then
        TPZombies()
    elseif input.KeyCode == Enum.KeyCode.X then
        TPMaterials()
    elseif input.KeyCode == Enum.KeyCode.V then
        Panel.Visible = not Panel.Visible
    end
end)