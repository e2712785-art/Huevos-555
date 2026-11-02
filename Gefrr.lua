--// MHUB - Mobile Edition (Fly Táctil, Auto Shoot, Hitbox ESP, Anim)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Función segura para la GUI en Delta
local function getGuiParent()
    local ok, result = pcall(function() return gethui() end)
    if ok and result then return result end
    local ok2, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and coreGui then return coreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local guiParent = getGuiParent()

--// Limpiar si ya existe
for _, child in ipairs(guiParent:GetChildren()) do
    if child.Name == "MHUB_Mobile" then child:Destroy() end
end

--// ==========================================
--// INTERFAZ GRÁFICA (UI)
--// ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MHUB_Mobile"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 320)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Botón Flotante para Abrir/Cerrar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(1, -70, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
toggleBtn.Text = "MHUB"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Barra Superior
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MHUB | Mobile Duelos"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -32, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Contenedor Scrolleable
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -55)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 2, 0) -- Espacio extra para scrollear
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll

-- Arrastrar ventana
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Botón Abrir/Cerrar
local function toggleUI()
    mainFrame.Visible = not mainFrame.Visible
end
toggleBtn.MouseButton1Click:Connect(toggleUI)
closeBtn.MouseButton1Click:Connect(toggleUI)

-- Función para crear botones
local function createBtn(txt, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

--// ==========================================
--// 1. FLY TÁCTIL (Para celular)
--// ==========================================
local flyEnabled = false
local flySpeed = 60
local flyConnection
local bodyVel

-- Joystick visual para móvil
local joyFrame = Instance.new("Frame")
joyFrame.Size = UDim2.new(0, 120, 0, 120)
joyFrame.Position = UDim2.new(0, 20, 0.5, -60)
joyFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
joyFrame.BackgroundTransparency = 0.5
joyFrame.Visible = false
joyFrame.Parent = screenGui
Instance.new("UICorner", joyFrame).CornerRadius = UDim.new(1, 0)

local joyKnob = Instance.new("Frame")
joyKnob.Size = UDim2.new(0, 50, 0, 50)
joyKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
joyKnob.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
joyKnob.Parent = joyFrame
Instance.new("UICorner", joyKnob).CornerRadius = UDim.new(1, 0)

local joyInput = {W=false, A=false, S=false, D=false, Up=false, Down=false}
local isDraggingJoy = false

joyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then isDraggingJoy = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then 
        isDraggingJoy = false 
        joyKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
        joyInput = {W=false, A=false, S=false, D=false, Up=false, Down=false}
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingJoy and input.UserInputType == Enum.UserInputType.Touch then
        local center = joyFrame.AbsolutePosition + (joyFrame.AbsoluteSize / 2)
        local delta = input.Position - center
        local dist = math.min(delta.Magnitude, 45)
        local dir = delta.Unit
        joyKnob.Position = UDim2.new(0.5, -25 + (dir.X * dist), 0.5, -25 + (dir.Y * dist))
        
        joyInput.W = dir.Y < -0.3
        joyInput.S = dir.Y > 0.3
        joyInput.A = dir.X < -0.3
        joyInput.D = dir.X > 0.3
    end
end)

local function toggleFly()
    flyEnabled = not flyEnabled
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if flyEnabled and hrp and hum then
        joyFrame.Visible = true
        hum.PlatformStand = true
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = hrp
        
        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local move = Vector3.new()
            if joyInput.W then move = move + cam.CFrame.LookVector end
            if joyInput.S then move = move - cam.CFrame.LookVector end
            if joyInput.A then move = move - cam.CFrame.RightVector end
            if joyInput.D then move = move + cam.CFrame.RightVector end
            
            -- Botones de subir/bajar en la UI
            if joyInput.Up then move = move + Vector3.new(0, 1, 0) end
            if joyInput.Down then move = move - Vector3.new(0, 1, 0) end
            
            if move.Magnitude > 0 then
                bodyVel.Velocity = move.Unit * flySpeed
            else
                bodyVel.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        joyFrame.Visible = false
        if flyConnection then flyConnection:Disconnect() end
        if bodyVel then bodyVel:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

createBtn("Fly Táctil [OFF]", function(btn)
    toggleFly()
    btn.Text = "Fly Táctil [" .. (flyEnabled and "ON" or "OFF") .. "]"
    btn.BackgroundColor3 = flyEnabled and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(40, 40, 55)
end)

-- Botones de subir/bajar para el Fly
local upBtn = createBtn("⬆️ Subir (Fly)", function() joyInput.Up = not joyInput.Up end)
upBtn.Size = UDim2.new(0.48, -5, 0, 35)
upBtn.Position = UDim2.new(0, 0, 0, 250)
local downBtn = createBtn("⬇️ Bajar (Fly)", function() joyInput.Down = not joyInput.Down end)
downBtn.Size = UDim2.new(0.48, -5, 0, 35)
downBtn.Position = UDim2.new(0.52, 0, 0, 250)

--// ==========================================
--// 2. HITBOX ESP (Agrandar y ver jugadores)
--// ==========================================
local espEnabled = false
local espObjects = {}

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if espEnabled and hrp then
                -- Hacer la hitbox más grande
                if not espObjects[p] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "MHUB_Hitbox"
                    box.Size = Vector3.new(6, 7, 6) -- Tamaño agrandado
                    box.Adornee = hrp
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.5
                    box.Color3 = Color3.fromRGB(255, 0, 255)
                    box.Parent = hrp
                    espObjects[p] = box
                end
            else
                if espObjects[p] then
                    espObjects[p]:Destroy()
                    espObjects[p] = nil
                end
            end
        end
    end
end

createBtn("Hitbox ESP [OFF]", function(btn)
    espEnabled = not espEnabled
    updateESP()
    btn.Text = "Hitbox ESP [" .. (espEnabled and "ON" or "OFF") .. "]"
    btn.BackgroundColor3 = espEnabled and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(40, 40, 55)
end)

-- Actualizar ESP cuando alguien entra
Players.PlayerAdded:Connect(function() task.wait(1) updateESP() end)

--// ==========================================
--// 3. AUTO SHOOT (Disparo automático)
--// ==========================================
local autoShootEnabled = false
local shootConnection

local function getClosestPlayer()
    local closest = nil
    local dist = math.huge
    local cam = Workspace.CurrentCamera
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local mag = (hrp.Position - cam.CFrame.Position).Magnitude
                if mag < dist then
                    dist = mag
                    closest = p
                end
            end
        end
    end
    return closest
end

createBtn("Auto Shoot [OFF]", function(btn)
    autoShootEnabled = not autoShootEnabled
    btn.Text = "Auto Shoot [" .. (autoShootEnabled and "ON" or "OFF") .. "]"
    btn.BackgroundColor3 = autoShootEnabled and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(40, 40, 55)
    
    if autoShootEnabled then
        shootConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestPlayer()
            if target and target.Character then
                local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    -- Hace que la cámara apunte al enemigo
                    Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, targetHrp.Position)
                    -- Simula el clic del mouse para disparar
                    pcall(function()
                        local mouse = LocalPlayer:GetMouse()
                        mouse.TargetFilter = target.Character
                        -- Esto varía según el juego, pero es un intento universal
                        mouse.Button1Down:Fire()
                    end)
                end
            end
        end)
    else
        if shootConnection then shootConnection:Disconnect() end
    end
end)

--// ==========================================
--// 4. CAMBIAR ANIMACIÓN
--// ==========================================
local animIdInput = Instance.new("TextBox")
animIdInput.Size = UDim2.new(1, -10, 0, 35)
animIdInput.PlaceholderText = "ID de Animación (ej: rbxassetid://123456)"
animIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
animIdInput.TextColor3 = Color3.new(1, 1, 1)
animIdInput.Font = Enum.Font.Gotham
animIdInput.TextSize = 12
animIdInput.Parent = scroll
Instance.new("UICorner", animIdInput).CornerRadius = UDim.new(0, 6)

createBtn("Cambiar Animación", function()
    local id = animIdInput.Text
    if id == "" then return end
    if not string.find(id, "rbxassetid://") then
        id = "rbxassetid://" .. id
    end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if animator then
        -- Detener animaciones actuales
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        -- Cargar y reproducir la nueva
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        local track = animator:LoadAnimation(anim)
        track:Play()
    end
end)

print("MHUB Mobile cargado correctamente.")
