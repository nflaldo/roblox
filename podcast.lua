-- Script: Dance Party UI - Pop Up Menu
-- Jalankan via Executor (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")
local AnimateScript = character:FindFirstChild("Animate")
if AnimateScript then AnimateScript.Disabled = false end

-- ===== PENGATURAN =====
local Settings = {
    WalkSpeed = 24,
    JumpPower = 60,
    InfiniteJump = true,
    NoClip = false,
    AntiAFK = true,
    BrightVision = true,
    AutoDance = false,
}

-- ===== ANIMASI =====
local emotes = {
    {name = "Dance 1",    icon = "💃", id = "rbxassetid://507771019"},
    {name = "Dance 2",    icon = "🕺", id = "rbxassetid://507776043"},
    {name = "Dance 3",    icon = "🎶", id = "rbxassetid://507776048"},
    {name = "Wave",       icon = "👋", id = "rbxassetid://507770239"},
    {name = "Point",      icon = "☝️", id = "rbxassetid://507770453"},
    {name = "Cheer",      icon = "🎉", id = "rbxassetid://507770677"},
    {name = "Laugh",      icon = "😂", id = "rbxassetid://507770818"},
    {name = "Salute",     icon = "🫡", id = "rbxassetid://3544351430"},
    {name = "Shrug",      icon = "🤷", id = "rbxassetid://3544203072"},
    {name = "Tilt",       icon = "😏", id = "rbxassetid://3544200075"},
    {name = "Facepalm",   icon = "🤦", id = "rbxassetid://3544406036"},
    {name = "Breakdance", icon = "🔥", id = "rbxassetid://3544419558"},
    {name = "Victory",    icon = "🏆", id = "rbxassetid://4849487550"},
    {name = "Confused",   icon = "😵", id = "rbxassetid://4849520943"},
    {name = "Tai Chi",    icon = "🧘", id = "rbxassetid://4849470700"},
    {name = "Air Guitar", icon = "🎸", id = "rbxassetid://4849504141"},
    {name = "Head Spin",  icon = "🌀", id = "rbxassetid://5915812855"},
    {name = "Applaud",    icon = "👏", id = "rbxassetid://5915693785"},
}

-- ===== FUNGSI EMOTE =====
local currentTrack = nil
local isEmoting = false

local function stopEmote()
    if currentTrack then
        currentTrack:Stop(0.2)
        currentTrack = nil
    end
    isEmoting = false
    if AnimateScript then AnimateScript.Disabled = false end
    humanoid.WalkSpeed = Settings.WalkSpeed
    humanoid.JumpPower = Settings.JumpPower
end

local function playEmote(emoteData)
    stopEmote()
    isEmoting = true
    local anim = Instance.new("Animation")
    anim.AnimationId = emoteData.id
    local success, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)
    if not success then
        isEmoting = false
        return
    end
    track.Priority = Enum.AnimationPriority.Action2
    track:Play(0.2)
    currentTrack = track
    track.Stopped:Connect(function()
        isEmoting = false
        currentTrack = nil
    end)
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not isEmoting then conn:Disconnect() return end
        local vel = humanoidRootPart.Velocity
        if Vector3.new(vel.X, 0, vel.Z).Magnitude > 1 then
            stopEmote()
            conn:Disconnect()
        end
    end)
end

local function playRandomEmote()
    playEmote(emotes[math.random(1, #emotes)])
end

-- ===== WALK JUMP SETUP =====
humanoid.WalkSpeed = Settings.WalkSpeed
humanoid.JumpPower = Settings.JumpPower
humanoid.PlatformStand = false
humanoid.Sit = false
humanoidRootPart.Anchored = false
for _, p in pairs(character:GetDescendants()) do
    if p:IsA("BasePart") then p.Anchored = false end
end

if Settings.InfiniteJump then
    UserInputService.JumpRequest:Connect(function()
        if isEmoting then stopEmote() end
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

if Settings.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

if Settings.BrightVision then
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 5
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end

-- ===== NOCLIP =====
RunService.Stepped:Connect(function()
    if Settings.NoClip then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p ~= humanoidRootPart then
                p.CanCollide = false
            end
        end
    end
end)

-- ===== UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DancePartyUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Tombol buka (pojok kanan bawah)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 55, 0, 55)
toggleBtn.Position = UDim2.new(1, -70, 1, -70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "🎭"
toggleBtn.TextSize = 26
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(120, 80, 255)
toggleStroke.Thickness = 2

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 500)
mainFrame.Position = UDim2.new(1, -360, 1, -580)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(120, 80, 255)
mainStroke.Thickness = 2

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎭 Dance Party"
title.TextColor3 = Color3.fromRGB(220, 180, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 36)
tabFrame.Position = UDim2.new(0, 10, 0, 58)
tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
tabFrame.BorderSizePixel = 0
tabFrame.Parent = mainFrame
Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 10)

local tabLayout = Instance.new("UIListLayout", tabFrame)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)

local function makeTab(text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -4, 1, -8)
    btn.Position = UDim2.new(0, 0, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    btn.TextColor3 = Color3.fromRGB(180, 150, 255)
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = tabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local tabEmote = makeTab("💃 Emote", 1)
local tabFeature = makeTab("⚙️ Fitur", 2)
local tabInfo = makeTab("📋 Info", 3)

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 0, 360)
contentFrame.Position = UDim2.new(0, 10, 0, 102)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- ===== TAB EMOTE =====
local emoteTab = Instance.new("ScrollingFrame")
emoteTab.Size = UDim2.new(1, 0, 1, 0)
emoteTab.BackgroundTransparency = 1
emoteTab.BorderSizePixel = 0
emoteTab.ScrollBarThickness = 4
emoteTab.ScrollBarImageColor3 = Color3.fromRGB(120, 80, 255)
emoteTab.Parent = contentFrame

local emoteGrid = Instance.new("UIGridLayout", emoteTab)
emoteGrid.CellSize = UDim2.new(0, 140, 0, 60)
emoteGrid.CellPadding = UDim2.new(0, 8, 0, 8)
emoteGrid.SortOrder = Enum.SortOrder.LayoutOrder
emoteGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local emoteFramePad = Instance.new("UIPadding", emoteTab)
emoteFramePad.PaddingTop = UDim.new(0, 6)

for i, emote in ipairs(emotes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(28, 22, 45)
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = emoteTab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(80, 50, 150)
    stroke.Thickness = 1

    local btnIcon = Instance.new("TextLabel")
    btnIcon.Size = UDim2.new(0, 30, 1, 0)
    btnIcon.Position = UDim2.new(0, 8, 0, 0)
    btnIcon.BackgroundTransparency = 1
    btnIcon.Text = emote.icon
    btnIcon.TextSize = 22
    btnIcon.Font = Enum.Font.Gotham
    btnIcon.Parent = btn

    local btnName = Instance.new("TextLabel")
    btnName.Size = UDim2.new(1, -45, 1, 0)
    btnName.Position = UDim2.new(0, 42, 0, 0)
    btnName.BackgroundTransparency = 1
    btnName.Text = emote.name
    btnName.TextColor3 = Color3.fromRGB(220, 200, 255)
    btnName.TextSize = 13
    btnName.Font = Enum.Font.GothamBold
    btnName.TextXAlignment = Enum.TextXAlignment.Left
    btnName.Parent = btn

    btn.MouseButton1Click:Connect(function()
        playEmote(emote)
        stroke.Color = Color3.fromRGB(160, 100, 255)
        task.wait(0.3)
        stroke.Color = Color3.fromRGB(80, 50, 150)
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(28, 22, 45)
        }):Play()
    end)
end

emoteTab.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#emotes / 2) * 68 + 20)

-- Random dance button
local randomBtn = Instance.new("TextButton")
randomBtn.Size = UDim2.new(1, -20, 0, 40)
randomBtn.Position = UDim2.new(0, 10, 1, -48)
randomBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
randomBtn.Text = "🎲 Random Dance!"
randomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
randomBtn.TextSize = 15
randomBtn.Font = Enum.Font.GothamBold
randomBtn.BorderSizePixel = 0
randomBtn.Parent = mainFrame
Instance.new("UICorner", randomBtn).CornerRadius = UDim.new(0, 10)

randomBtn.MouseButton1Click:Connect(function()
    playRandomEmote()
    TweenService:Create(randomBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(160, 100, 255)
    }):Play()
    task.wait(0.2)
    TweenService:Create(randomBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(120, 60, 220)
    }):Play()
end)

-- ===== TAB FITUR =====
local featureTab = Instance.new("Frame")
featureTab.Size = UDim2.new(1, 0, 1, 0)
featureTab.BackgroundTransparency = 1
featureTab.Visible = false
featureTab.Parent = contentFrame

local featureLayout = Instance.new("UIListLayout", featureTab)
featureLayout.SortOrder = Enum.SortOrder.LayoutOrder
featureLayout.Padding = UDim.new(0, 8)

local features = {
    {name = "⚡ Infinite Jump",  key = "InfiniteJump"},
    {name = "👟 Sprint (Shift)", key = "Sprint"},
    {name = "👻 NoClip (Q)",     key = "NoClip"},
    {name = "💡 Bright Vision",  key = "BrightVision"},
    {name = "🤖 Anti AFK",       key = "AntiAFK"},
    {name = "🎵 Auto Dance",     key = "AutoDance"},
}

local featureStates = {
    InfiniteJump = true,
    Sprint = true,
    NoClip = false,
    BrightVision = true,
    AntiAFK = true,
    AutoDance = false,
}

local function makeToggle(feat)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(28, 22, 45)
    row.BorderSizePixel = 0
    row.LayoutOrder = 1
    row.Parent = featureTab
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = feat.name
    label.TextColor3 = Color3.fromRGB(220, 200, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(1, -58, 0.5, -12)
    toggleBg.BackgroundColor3 = featureStates[feat.key] and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(60, 60, 80)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = featureStates[feat.key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        featureStates[feat.key] = not featureStates[feat.key]
        local on = featureStates[feat.key]

        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(60, 60, 80)
        }):Play()
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()

        -- Apply fitur
        if feat.key == "NoClip" then
            Settings.NoClip = on
        elseif feat.key == "BrightVision" then
            local Lighting = game:GetService("Lighting")
            if on then
                Lighting.Brightness = 5
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            else
                Lighting.Brightness = 1
                Lighting.GlobalShadows = true
            end
        elseif feat.key == "AutoDance" then
            Settings.AutoDance = on
            if on then
                task.spawn(function()
                    while Settings.AutoDance do
                        if not isEmoting then playRandomEmote() end
                        task.wait(6)
                    end
                end)
            else
                stopEmote()
            end
        elseif feat.key == "InfiniteJump" then
            Settings.InfiniteJump = on
        end

        print((on and "✅ ON: " or "❌ OFF: ") .. feat.name)
    end)
end

for _, f in ipairs(features) do
    makeToggle(f)
end

-- ===== TAB INFO =====
local infoTab = Instance.new("Frame")
infoTab.Size = UDim2.new(1, 0, 1, 0)
infoTab.BackgroundTransparency = 1
infoTab.Visible = false
infoTab.Parent = contentFrame

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -10, 1, 0)
infoText.Position = UDim2.new(0, 5, 0, 0)
infoText.BackgroundTransparency = 1
infoText.Text = "📌 KONTROL KEYBOARD\n\nE  →  Dance Random\nR  →  Dance Selanjutnya\nT  →  Dance Sebelumnya\nF  →  Stop Dance\nG  →  Auto Dance ON/OFF\nQ  →  NoClip ON/OFF\nShift  →  Sprint\nSpasi  →  Lompat\n\n🎭 TOTAL ANIMASI\n18 Animasi Gratis\n\n✅ FITUR AKTIF\nInfinite Jump\nAnti AFK\nBright Vision\nSprint\nAuto Dance"
infoText.TextColor3 = Color3.fromRGB(200, 180, 255)
infoText.TextSize = 13
infoText.Font = Enum.Font.Gotham
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextWrapped = true
infoText.Parent = infoTab

-- ===== TAB SWITCHING =====
local tabs = {
    {btn = tabEmote,   content = emoteTab},
    {btn = tabFeature, content = featureTab},
    {btn = tabInfo,    content = infoTab},
}

local function switchTab(selected)
    for _, t in ipairs(tabs) do
        local isSelected = t.btn == selected.btn
        t.content.Visible = isSelected
        TweenService:Create(t.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isSelected and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(40, 30, 60),
            TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 150, 255),
        }):Play()
    end
end

for _, t in ipairs(tabs) do
    t.btn.MouseButton1Click:Connect(function() switchTab(t) end)
end
switchTab(tabs[1])

-- ===== TOGGLE UI =====
local uiOpen = false
toggleBtn.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    if uiOpen then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(1, -20, 1, -70)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 340, 0, 500),
            Position = UDim2.new(1, -360, 1, -580),
        }):Play()
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(1, -20, 1, -70),
        }):Play()
        task.wait(0.2)
        mainFrame.Visible = false
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    uiOpen = false
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(1, -20, 1, -70),
    }):Play()
    task.wait(0.2)
    mainFrame.Visible = false
end)

-- ===== KEYBOARD SHORTCUT =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then playRandomEmote() end
    if input.KeyCode == Enum.KeyCode.F then stopEmote() end
    if input.KeyCode == Enum.KeyCode.Q then
        Settings.NoClip = not Settings.NoClip
        featureStates.NoClip = Settings.NoClip
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        humanoid.WalkSpeed = 50
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

print("✅ Dance Party UI Loaded! Klik 🎭 untuk buka menu!")
