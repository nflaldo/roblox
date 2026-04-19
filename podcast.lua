-- Script: Dance Party UI - FIXED POPUP
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

local Settings = {
    WalkSpeed = 24,
    JumpPower = 60,
    NoClip = false,
    AutoDance = false,
}

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
    {name = "Facepalm",   icon = "🤦", id = "rbxassetid://3544406036"},
    {name = "Breakdance", icon = "🔥", id = "rbxassetid://3544419558"},
    {name = "Victory",    icon = "🏆", id = "rbxassetid://4849487550"},
    {name = "Tai Chi",    icon = "🧘", id = "rbxassetid://4849470700"},
    {name = "Air Guitar", icon = "🎸", id = "rbxassetid://4849504141"},
    {name = "Head Spin",  icon = "🌀", id = "rbxassetid://5915812855"},
    {name = "Applaud",    icon = "👏", id = "rbxassetid://5915693785"},
}

-- ===== EMOTE SYSTEM =====
local currentTrack = nil
local isEmoting = false

local function stopEmote()
    if currentTrack then currentTrack:Stop(0.2) currentTrack = nil end
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
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if not ok then isEmoting = false return end
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
            stopEmote() conn:Disconnect()
        end
    end)
    print("🎭 " .. emoteData.name)
end

local function playRandom()
    playEmote(emotes[math.random(1, #emotes)])
end

-- ===== WALK JUMP =====
humanoid.WalkSpeed = Settings.WalkSpeed
humanoid.JumpPower = Settings.JumpPower
humanoid.PlatformStand = false
humanoid.Sit = false
humanoidRootPart.Anchored = false
for _, p in pairs(character:GetDescendants()) do
    if p:IsA("BasePart") then p.Anchored = false end
end

UserInputService.JumpRequest:Connect(function()
    if isEmoting then stopEmote() end
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

RunService.Stepped:Connect(function()
    if Settings.NoClip then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p ~= humanoidRootPart then
                p.CanCollide = false
            end
        end
    end
end)

-- ===== HAPUS UI LAMA =====
local oldGui = player.PlayerGui:FindFirstChild("DanceUI")
if oldGui then oldGui:Destroy() end

-- ===== BUAT GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "DanceUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- ===== ICON =====
local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 55, 0, 55)
iconBtn.Position = UDim2.new(0, 16, 0.5, -27)
iconBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
iconBtn.Text = "🎭"
iconBtn.TextSize = 26
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextColor3 = Color3.fromRGB(255,255,255)
iconBtn.BorderSizePixel = 0
iconBtn.ZIndex = 100
iconBtn.Parent = gui
Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(1, 0)
local iconStroke = Instance.new("UIStroke", iconBtn)
iconStroke.Color = Color3.fromRGB(140, 80, 255)
iconStroke.Thickness = 2

-- ===== PANEL =====
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 310, 0, 460)
panel.Position = UDim2.new(0, 80, 0.5, -230)
panel.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 99
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(140, 80, 255)
panelStroke.Thickness = 2

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(28, 16, 52)
header.BorderSizePixel = 0
header.ZIndex = 100
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -50, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "🎭 Dance Party"
titleLbl.TextColor3 = Color3.fromRGB(210, 170, 255)
titleLbl.TextSize = 16
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 101
titleLbl.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 102
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -14, 0, 32)
tabBar.Position = UDim2.new(0, 7, 0, 50)
tabBar.BackgroundColor3 = Color3.fromRGB(22, 16, 40)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 100
tabBar.Parent = panel
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

local function makeTabBtn(txt, xScale)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.333, -4, 1, -6)
    b.Position = UDim2.new(xScale, 2, 0, 3)
    b.BackgroundColor3 = Color3.fromRGB(35, 22, 58)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(160, 130, 210)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 101
    b.Parent = tabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local tabE = makeTabBtn("💃 Emote", 0)
local tabF = makeTabBtn("⚙️ Fitur", 0.333)
local tabI = makeTabBtn("📋 Info", 0.666)

-- Content
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -14, 0, 310)
contentArea.Position = UDim2.new(0, 7, 0, 88)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 100
contentArea.Parent = panel

-- Emote scroll
local emoteScroll = Instance.new("ScrollingFrame")
emoteScroll.Size = UDim2.new(1, 0, 1, 0)
emoteScroll.BackgroundTransparency = 1
emoteScroll.BorderSizePixel = 0
emoteScroll.ScrollBarThickness = 3
emoteScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
emoteScroll.ZIndex = 101
emoteScroll.Visible = true
emoteScroll.Parent = contentArea

local grid = Instance.new("UIGridLayout", emoteScroll)
grid.CellSize = UDim2.new(0, 130, 0, 52)
grid.CellPadding = UDim2.new(0, 6, 0, 6)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", emoteScroll).PaddingTop = UDim.new(0, 4)

for _, emote in ipairs(emotes) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(0, 130, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(26, 20, 45)
    card.BorderSizePixel = 0
    card.Text = ""
    card.ZIndex = 102
    card.Parent = emoteScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local cs = Instance.new("UIStroke", card)
    cs.Color = Color3.fromRGB(70, 45, 120)
    cs.Thickness = 1

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0, 26, 1, 0)
    ico.Position = UDim2.new(0, 7, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Text = emote.icon
    ico.TextSize = 18
    ico.Font = Enum.Font.Gotham
    ico.ZIndex = 103
    ico.Parent = card

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, -38, 1, 0)
    nm.Position = UDim2.new(0, 36, 0, 0)
    nm.BackgroundTransparency = 1
    nm.Text = emote.name
    nm.TextColor3 = Color3.fromRGB(210, 190, 255)
    nm.TextSize = 11
    nm.Font = Enum.Font.GothamBold
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.ZIndex = 103
    nm.Parent = card

    card.MouseButton1Click:Connect(function()
        playEmote(emote)
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 40, 140)}):Play()
        task.wait(0.15)
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 20, 45)}):Play()
    end)
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 30, 70)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 20, 45)}):Play()
    end)
end

emoteScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#emotes / 2) * 58 + 10)

-- Fitur frame
local fiturFrame = Instance.new("Frame")
fiturFrame.Size = UDim2.new(1, 0, 1, 0)
fiturFrame.BackgroundTransparency = 1
fiturFrame.Visible = false
fiturFrame.ZIndex = 101
fiturFrame.Parent = contentArea
Instance.new("UIListLayout", fiturFrame).Padding = UDim.new(0, 6)

local fiturList = {
    {name = "⚡ Infinite Jump", key = "InfiniteJump", on = true},
    {name = "👻 NoClip",        key = "NoClip",        on = false},
    {name = "💡 Bright Vision", key = "BrightVision",  on = true},
    {name = "🎵 Auto Dance",    key = "AutoDance",      on = false},
    {name = "🏃 Sprint",        key = "Sprint",         on = true},
}

for _, f in ipairs(fiturList) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(24, 18, 42)
    row.BorderSizePixel = 0
    row.ZIndex = 102
    row.Parent = fiturFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = f.name
    lbl.TextColor3 = Color3.fromRGB(210, 190, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 103
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -50, 0.5, -10)
    bg.BackgroundColor3 = f.on and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(55, 45, 75)
    bg.BorderSizePixel = 0
    bg.ZIndex = 103
    bg.Parent = row
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = f.on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.ZIndex = 104
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = {on = f.on}
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 105
    clickArea.Parent = row

    clickArea.MouseButton1Click:Connect(function()
        state.on = not state.on
        local on = state.on
        TweenService:Create(bg, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(120,60,220) or Color3.fromRGB(55,45,75)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        }):Play()

        if f.key == "NoClip" then Settings.NoClip = on
        elseif f.key == "BrightVision" then
            local L = game:GetService("Lighting")
            if on then L.Brightness=5 L.ClockTime=14 L.FogEnd=100000 L.GlobalShadows=false
            else L.Brightness=1 L.GlobalShadows=true end
        elseif f.key == "AutoDance" then
            Settings.AutoDance = on
            if on then
                task.spawn(function()
                    while Settings.AutoDance do
                        if not isEmoting then playRandom() end
                        task.wait(6)
                    end
                end)
            else stopEmote() end
        end
        print((on and "✅ " or "❌ ") .. f.name)
    end)
end

-- Info frame
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, 0, 1, 0)
infoFrame.BackgroundTransparency = 1
infoFrame.Visible = false
infoFrame.ZIndex = 101
infoFrame.Parent = contentArea

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -8, 1, 0)
infoLbl.Position = UDim2.new(0, 6, 0, 4)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "⌨️ KEYBOARD\n\nE → Dance Random\nF → Stop Dance\nQ → NoClip ON/OFF\nShift → Sprint\nSpasi → Lompat\n\n🎭 16 Animasi Gratis\n100% Tanpa Beli\n\n✅ FITUR\nInfinite Jump\nAnti AFK\nBright Vision\nSprint\nAuto Dance\nNoClip"
infoLbl.TextColor3 = Color3.fromRGB(190, 165, 240)
infoLbl.TextSize = 13
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.TextWrapped = true
infoLbl.ZIndex = 102
infoLbl.Parent = infoFrame

-- Bottom bar
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, -14, 0, 36)
bottomBar.Position = UDim2.new(0, 7, 1, -42)
bottomBar.BackgroundTransparency = 1
bottomBar.ZIndex = 100
bottomBar.Parent = panel

local randBtn = Instance.new("TextButton")
randBtn.Size = UDim2.new(0.58, -3, 1, 0)
randBtn.Position = UDim2.new(0, 0, 0, 0)
randBtn.BackgroundColor3 = Color3.fromRGB(110, 55, 210)
randBtn.Text = "🎲 Random Dance"
randBtn.TextColor3 = Color3.fromRGB(255,255,255)
randBtn.TextSize = 12
randBtn.Font = Enum.Font.GothamBold
randBtn.BorderSizePixel = 0
randBtn.ZIndex = 101
randBtn.Parent = bottomBar
Instance.new("UICorner", randBtn).CornerRadius = UDim.new(0, 8)

local stopBtn2 = Instance.new("TextButton")
stopBtn2.Size = UDim2.new(0.42, -3, 1, 0)
stopBtn2.Position = UDim2.new(0.58, 3, 0, 0)
stopBtn2.BackgroundColor3 = Color3.fromRGB(160, 40, 70)
stopBtn2.Text = "⏹ Stop"
stopBtn2.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn2.TextSize = 12
stopBtn2.Font = Enum.Font.GothamBold
stopBtn2.BorderSizePixel = 0
stopBtn2.ZIndex = 101
stopBtn2.Parent = bottomBar
Instance.new("UICorner", stopBtn2).CornerRadius = UDim.new(0, 8)

randBtn.MouseButton1Click:Connect(function() playRandom() end)
stopBtn2.MouseButton1Click:Connect(function() stopEmote() end)

-- ===== TAB SWITCH =====
local allTabs = {
    {btn = tabE, content = emoteScroll},
    {btn = tabF, content = fiturFrame},
    {btn = tabI, content = infoFrame},
}

local function switchTab(sel)
    for _, t in ipairs(allTabs) do
        local active = t.btn == sel.btn
        t.content.Visible = active
        TweenService:Create(t.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = active and Color3.fromRGB(110,55,210) or Color3.fromRGB(35,22,58),
            TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,130,210),
        }):Play()
    end
end

for _, t in ipairs(allTabs) do
    t.btn.MouseButton1Click:Connect(function() switchTab(t) end)
end
switchTab(allTabs[1])

-- ===== TOGGLE PANEL - FIXED =====
local panelOpen = false

local function openPanel()
    panelOpen = true
    panel.Visible = true
    panel.GroupTransparency = 1
    TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        GroupTransparency = 0
    }):Play()
end

local function closePanel()
    panelOpen = false
    TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        GroupTransparency = 1
    }):Play()
    task.delay(0.2, function() panel.Visible = false end)
end

-- FIXED: Pakai MouseButton1Up bukan Click agar tidak bentrok dengan drag
local isDragging = false
local dragStartPos = nil
local dragStartTime = nil

iconBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        dragStartPos = input.Position
        dragStartTime = tick()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) and dragStartPos then
        local delta = (input.Position - dragStartPos).Magnitude
        if delta > 5 then
            isDragging = true
            local pos = iconBtn.Position
            iconBtn.Position = UDim2.new(
                pos.X.Scale, pos.X.Offset + (input.Position.X - dragStartPos.X),
                pos.Y.Scale, pos.Y.Offset + (input.Position.Y - dragStartPos.Y)
            )
            dragStartPos = input.Position
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        if not isDragging then
            -- Ini klik biasa, toggle panel
            if panelOpen then
                closePanel()
            else
                openPanel()
            end
        end
        isDragging = false
        dragStartPos = nil
    end
end)

closeBtn.MouseButton1Click:Connect(function() closePanel() end)

-- ===== KEYBOARD =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then playRandom() end
    if input.KeyCode == Enum.KeyCode.F then stopEmote() end
    if input.KeyCode == Enum.KeyCode.Q then Settings.NoClip = not Settings.NoClip end
    if input.KeyCode == Enum.KeyCode.LeftShift then humanoid.WalkSpeed = 50 end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

print("✅ Dance Party siap! Klik icon 🎭 di layar kiri tengah!")
