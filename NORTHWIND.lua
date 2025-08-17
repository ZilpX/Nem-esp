-- NORTHWIND FULL MENU: ESP Ore/Animal, Hitbox/Aim Player, Infinite Stamina/Bag/Ammo, Auto Mine Ore
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService('Workspace')
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- CONFIG
local ORE_NAMES = {"Iron Ore", "Copper Ore", "Silver Ore", "Gold Ore", "Coal", "Tin Ore", "Lead Ore", "Platinum Ore"}
local ANIMAL_NAMES = {"Wolf", "Bear", "Moose", "Deer", "Rabbit", "Boar", "Fox", "Caribou"}
local ESP_COLOR_ORE = Color3.fromRGB(0,220,255)
local ESP_COLOR_ANIMAL = Color3.fromRGB(255,80,80)
local ESP_COLOR_PLAYER = Color3.fromRGB(255,255,100)
local HITBOX_SIZE = 8
local HITBOX_HEAD_SIZE = 12

-- MENU DRAG
local gui = Instance.new("ScreenGui")
gui.Name = "NW_FullMenu"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 280, 0, 540)
menuFrame.Position = UDim2.new(0.5, -140, 0.5, -270)
menuFrame.BackgroundColor3 = Color3.fromRGB(35,35,48)
menuFrame.Active = true
menuFrame.Visible = true
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 14)

local dragging, dragStart, startPos
menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
menuFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local menuBtn = Instance.new("TextButton", gui)
menuBtn.Size = UDim2.new(0,50,0,50)
menuBtn.Position = UDim2.new(0,30,0.5,-25)
menuBtn.BackgroundColor3 = Color3.fromRGB(80,120,220)
menuBtn.Text = "≡"
menuBtn.TextSize = 32
menuBtn.TextColor3 = Color3.new(1,1,1)
menuBtn.Font = Enum.Font.GothamBlack
menuBtn.ZIndex = 10
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(1,0)
menuBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

local title = Instance.new("TextLabel", menuFrame)
title.Size = UDim2.new(1, -10, 0, 38)
title.Position = UDim2.fromOffset(8, 6)
title.BackgroundTransparency = 1
title.Text = "Northwind FULL MENU: ESP + Hitbox/Aim Player + Auto Ore"
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

local note = Instance.new("TextLabel", menuFrame)
note.Size = UDim2.new(1, -16, 0, 38)
note.Position = UDim2.fromOffset(8, 52)
note.BackgroundTransparency = 1
note.Text = "ESP quặng/động vật, Hitbox/Aim chỉ người chơi, auto đào quặng, vô hạn stamina/bag/ammo."
note.Font = Enum.Font.Gotham
note.TextSize = 13
note.TextColor3 = Color3.fromRGB(220,220,220)
note.TextXAlignment = Enum.TextXAlignment.Left

-- ESP Ore/Animal
local function createESP(obj, label, color)
    if not obj:FindFirstChild("ESP_GUI") and obj:FindFirstChildWhichIsA("BasePart") then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_GUI"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 120, 0, 18)
        bb.Adornee = obj:FindFirstChildWhichIsA("BasePart")
        bb.Parent = obj
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0.5
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
    end
end

for _,obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and table.find(ORE_NAMES, obj.Name) then
        createESP(obj, "[ORE] "..obj.Name, ESP_COLOR_ORE)
    elseif obj:IsA("Model") and table.find(ANIMAL_NAMES, obj.Name) then
        createESP(obj, "[ANIMAL] "..obj.Name, ESP_COLOR_ANIMAL)
    end
end
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") and table.find(ORE_NAMES, obj.Name) then
        createESP(obj, "[ORE] "..obj.Name, ESP_COLOR_ORE)
    elseif obj:IsA("Model") and table.find(ANIMAL_NAMES, obj.Name) then
        createESP(obj, "[ANIMAL] "..obj.Name, ESP_COLOR_ANIMAL)
    end
end)

-- ESP + HITBOX/AIM NGƯỜI CHƠI
local hitboxEnabled = false
local aimEnabled = false
local playerHitboxOriginal = {}

local function applyPlayerHitbox(p, enable)
    if not p.Character then return end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local head = p.Character:FindFirstChild("Head")
    if hrp then
        if enable then
            if not playerHitboxOriginal[p] then
                playerHitboxOriginal[p] = {size = hrp.Size, massless = hrp.Massless, collide = hrp.CanCollide}
            end
            hrp.Size = Vector3.new(HITBOX_SIZE,HITBOX_SIZE,HITBOX_SIZE)
            hrp.Massless = true
            hrp.CanCollide = false
        elseif playerHitboxOriginal[p] then
            hrp.Size = playerHitboxOriginal[p].size
            hrp.Massless = playerHitboxOriginal[p].massless
            hrp.CanCollide = playerHitboxOriginal[p].collide
            playerHitboxOriginal[p] = nil
        end
    end
    if head then
        if enable then
            if not playerHitboxOriginal[p.."Head"] then
                playerHitboxOriginal[p.."Head"] = {size = head.Size, massless = head.Massless, collide = head.CanCollide}
            end
            head.Size = Vector3.new(HITBOX_HEAD_SIZE,HITBOX_HEAD_SIZE,HITBOX_HEAD_SIZE)
            head.Massless = true
            head.CanCollide = false
        elseif playerHitboxOriginal[p.."Head"] then
            head.Size = playerHitboxOriginal[p.."Head"].size
            head.Massless = playerHitboxOriginal[p.."Head"].massless
            head.CanCollide = playerHitboxOriginal[p.."Head"].collide
            playerHitboxOriginal[p.."Head"] = nil
        end
    end
end

local function updateAllPlayerHitbox(enable)
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            applyPlayerHitbox(p, enable)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if hitboxEnabled then
            applyPlayerHitbox(p, true)
        end
    end)
end)
for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then
        if hitboxEnabled then applyPlayerHitbox(p, true) end
    end
end

-- MENU NÚT HITBOX/AIM NGƯỜI CHƠI
local hitboxBtn = Instance.new("TextButton", menuFrame)
hitboxBtn.Size = UDim2.new(1,-16,0,30)
hitboxBtn.Position = UDim2.fromOffset(8,100)
hitboxBtn.Text = "Hitbox Player: OFF"
hitboxBtn.Font = Enum.Font.GothamBold
hitboxBtn.TextSize = 14
hitboxBtn.BackgroundColor3 = Color3.fromRGB(70,100,140)
hitboxBtn.TextColor3 = Color3.new(1,1,1)
hitboxBtn.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    hitboxBtn.Text = hitboxEnabled and "Hitbox Player: ON" or "Hitbox Player: OFF"
    updateAllPlayerHitbox(hitboxEnabled)
end)

aimBtn = Instance.new("TextButton", menuFrame)
aimBtn.Size = UDim2.new(1,-16,0,30)
aimBtn.Position = UDim2.fromOffset(8,140)
aimBtn.Text = "Aim Player: OFF"
aimBtn.Font = Enum.Font.GothamBold
aimBtn.TextSize = 14
aimBtn.BackgroundColor3 = Color3.fromRGB(180,90,60)
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimBtn.Text = aimEnabled and "Aim Player: ON" or "Aim Player: OFF"
end)

-- AIM ĐẾN NGƯỜI CHƠI GẦN NHẤT
task.spawn(function()
    while true do
        if aimEnabled then
            local nearest, dist = nil, math.huge
            local myPos = Camera.CFrame.Position
            for _,p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local d = (p.Character.Head.Position - myPos).Magnitude
                    if d < dist then
                        nearest = p.Character.Head
                        dist = d
                    end
                end
            end
            if nearest then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearest.Position)
            end
        end
        task.wait(0.1)
    end
end)

-- AUTO MINE ORE
local oreScroll = Instance.new("ScrollingFrame", menuFrame)
oreScroll.Size = UDim2.new(1,-16,0,140)
oreScroll.Position = UDim2.fromOffset(8,190)
oreScroll.BackgroundTransparency = 0.12
oreScroll.BackgroundColor3 = Color3.fromRGB(40,45,70)
oreScroll.BorderSizePixel = 0
oreScroll.CanvasSize = UDim2.new(0,0,0,0)
oreScroll.ScrollBarThickness = 6

local function autoMine(oreModel)
    local part = oreModel:FindFirstChildWhichIsA("BasePart")
    if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,2,0)
        wait(0.2)
        for _,v in ipairs(part:GetChildren()) do
            if v:IsA('TouchTransmitter') then
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 1)
            end
        end
    end
end

local function makeOreBtn(oreName)
    local btn = Instance.new("TextButton", oreScroll)
    btn.Size = UDim2.new(1,-8,0,28)
    btn.Position = UDim2.fromOffset(4, (#oreScroll:GetChildren()-1)*32)
    btn.Text = "Tele & Auto Mine: "..oreName
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = ESP_COLOR_ORE
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    btn.MouseButton1Click:Connect(function()
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == oreName and obj:FindFirstChildWhichIsA("BasePart") then
                autoMine(obj)
                break
            end
        end
    end)
end
for _,name in ipairs(ORE_NAMES) do makeOreBtn(name) end
oreScroll.CanvasSize = UDim2.new(0,0,0,#ORE_NAMES*32)

-- VÔ HẠN STAMINA
local staminaBtn = Instance.new("TextButton", menuFrame)
staminaBtn.Size = UDim2.new(1,-16,0,30)
staminaBtn.Position = UDim2.fromOffset(8,340)
staminaBtn.Text = "Vô hạn Stamina"
staminaBtn.Font = Enum.Font.GothamBold
staminaBtn.TextSize = 14
staminaBtn.BackgroundColor3 = Color3.fromRGB(45,120,80)
staminaBtn.TextColor3 = Color3.new(1,1,1)
local function infiniteStamina()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Stamina") then
        char.Stamina.Value = char.Stamina.MaxValue or 999999
        char.Stamina.Changed:Connect(function()
            char.Stamina.Value = char.Stamina.MaxValue or 999999
        end)
    end
end
staminaBtn.MouseButton1Click:Connect(function()
    infiniteStamina()
end)
LocalPlayer.CharacterAdded:Connect(function() infiniteStamina() end)
if LocalPlayer.Character then infiniteStamina() end

-- VÔ HẠN TÚI ĐỒ
local bagBtn = Instance.new("TextButton", menuFrame)
bagBtn.Size = UDim2.new(1,-16,0,30)
bagBtn.Position = UDim2.fromOffset(8,380)
bagBtn.Text = "Vô hạn Túi Đồ"
bagBtn.Font = Enum.Font.GothamBold
bagBtn.TextSize = 14
bagBtn.BackgroundColor3 = Color3.fromRGB(120,45,80)
bagBtn.TextColor3 = Color3.new(1,1,1)
local function infiniteBag()
    pcall(function()
        if LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild("MaxWeight") then
            LocalPlayer.Inventory.MaxWeight.Value = math.huge
        end
    end)
end
bagBtn.MouseButton1Click:Connect(function()
    infiniteBag()
end)

-- VÔ HẠN ĐẠN / KHÔNG CẦN NẠP ĐẠN
local ammoBtn = Instance.new("TextButton", menuFrame)
ammoBtn.Size = UDim2.new(1,-16,0,30)
ammoBtn.Position = UDim2.fromOffset(8,420)
ammoBtn.Text = "Vô hạn đạn/Không reload"
ammoBtn.Font = Enum.Font.GothamBold
ammoBtn.TextSize = 14
ammoBtn.BackgroundColor3 = Color3.fromRGB(120,120,50)
ammoBtn.TextColor3 = Color3.new(1,1,1)
local function infiniteAmmo()
    for i, v in next, getgc(true) do
        if type(v) == "table" then
            if rawget(v, "CurrentAmmo") then
                v.CurrentAmmo = math.huge
            end
            if rawget(v, "Reload") and typeof(v.Reload) == "function" then
                hookfunction(v.Reload, function(...) end)
            end
        end
    end
    for _,tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:FindFirstChild("Ammo") then
            tool.Ammo.Value = 999999
        end
    end
end
ammoBtn.MouseButton1Click:Connect(function()
    infiniteAmmo()
end)

print("Northwind FULL MENU: ESP Ore/Animal, Hitbox/Aim Player, Infinite Stamina/Bag/Ammo, Auto Mine Ore loaded!")
