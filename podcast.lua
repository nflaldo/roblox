-- Script: Dance Party UI FIXED
-- Jalankan via Executor (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Tunggu karakter siap
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
    NoClip = false,
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
    {name = "Facepalm",   icon = "🤦", id = "rbxassetid://3544406036"},
    {name = "Breakdance", icon = "🔥", id = "rbxassetid://3544419558"},
    {name = "Victory",    icon = "🏆", id = "rbxassetid://4849487550"},
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
    local ok, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)
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

-- ===== BUAT UI =====
-- Hapus UI lama kalau ada
local oldGui = player.PlayerGui:FindFirstChild("DanceUI")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DanceUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- ===== ICON BUTTON =====
local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 60, 0, 60)
iconBtn.Position = UDim2.new(0, 20, 0.5, -30)
iconBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
iconBtn.Text = "🎭"
iconBtn.TextSize = 28
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextColor3 = Color3.fromRGB(255,255,255)
iconBtn.BorderSizePixel = 0
iconBtn.ZIndex = 10
iconBtn.Parent = gui
local ic = Instance.new("UICorner", iconBtn)
ic.CornerRadius = UDim.new(1, 0)
local is = Instance.new("UIStroke", iconBtn)
is.Color = Color3.fromRGB(140, 80, 255)
is.Thickness = 2

-- Drag icon
local dragging, dragStart, startPos = false, nil, nil
iconBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = iconBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        iconBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ===== MAIN PANEL =====
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 480)
panel.Position = UDim2.new(0, 90, 0.5, -240)
panel.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 9
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
local ps = Instance.new("UIStroke", panel)
ps.Color = Color3.fromRGB(140, 80, 255)
ps.Thickness = 2

-- Header panel
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(30, 18, 55)
header.BorderSizePixel = 0
header.ZIndex = 10
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -50, 1, 0)
titleLbl.Position = UDim2.new(0, 14, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "🎭 Dance Party"
titleLbl.TextColor3 = Color3.fromRGB(210, 170, 255)
titleLbl.TextSize = 17
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 11
titleLbl.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 12
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Tab buttons
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 34)
tabBar.Position = UDim2.new(0, 8, 0, 54)
tabBar.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 10
tabBar.Parent = panel
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local function makeTabBtn(text, xPos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.33, -4, 1, -6)
    b.Position = UDim2.new(xPos, 3, 0, 3)
    b.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(170, 140, 220)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 11
    b.Parent = tabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local tabEmoteBtn   = makeTabBtn("💃 Emote", 0)
local tabFiturBtn   = makeTabBtn("⚙️ Fitur", 0.33)
local tabInfoBtn    = makeTabBtn("📋 Info", 0.66)

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 0, 330)
contentArea.Position = UDim2.new(0, 8, 0, 96)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 10
contentArea.Parent = panel

-- ===== TAB EMOTE =====
local emoteScroll = Instance.new("ScrollingFrame")
emoteScroll.Size = UDim2.new(1, 0, 1, 0)
emoteScroll.BackgroundTransparency = 1
emoteScroll.BorderSizePixel = 0
emoteScroll.ScrollBarThickness = 3
emoteScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
emoteScroll.ZIndex = 11
emoteScroll.Parent = contentArea

local grid = Instance.new("UIGridLayout", emoteScroll)
grid.CellSize = UDim2.new(0, 136, 0, 56)
grid.CellPadding = UDim2.new(0, 6, 0, 6)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", emoteScroll).PaddingTop = UDim.new(0, 4)

for i, emote in ipairs(emotes) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(0, 136, 0, 56)
    card.BackgroundColor3 = Color3.fromRGB(26, 20, 45)
    card.BorderSizePixel = 0
    card.Text = ""
    card.ZIndex = 12
    card.Parent = emoteScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local cs = Instance.new("UIStroke", card)
    cs.Color = Color3.fromRGB(70, 45, 120)
    cs.Thickness = 1

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0, 28, 1, 0)
    ico.Position = UDim2.new(0, 8, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Text = emote.icon
    ico.TextSize = 20
    ico.Font = Enum.Font.Gotham
    ico.ZIndex = 13
    ico.Parent = card

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, -42, 1, 0)
    nm.Position = UDim2.new(0, 38, 0, 0)
    nm.BackgroundTransparency = 1
    nm.Text = emote.name
    nm.TextColor3 = Color3.fromRGB(210, 190, 255)
    nm.TextSize = 12
    nm.Font = Enum.Font.GothamBold
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.ZIndex = 13
    nm.Parent = card

    card.MouseButton1Click:Connect(function()
        playEmote(emote)
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 40, 140)}):Play()
        task.wait(0.2)
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 20, 45)}):Play()
    end)
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(42, 30, 70)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(26, 20, 45)}):Play()
    end)
end

emoteScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#emotes / 2) * 62 + 10)

-- ===== TAB FITUR =====
local fiturFrame = Instance.new("Frame")
fiturFrame.Size = UDim2.new(1, 0, 1, 0)
fiturFrame.BackgroundTransparency = 1
fiturFrame.Visible = false
fiturFrame.ZIndex = 11
fiturFrame.Parent = contentArea

local fiturList = Instance.new("UIListLayout", fiturFrame)
fiturList.SortOrder = Enum.SortOrder.LayoutOrder
fiturList.Padding = UDim.new(0, 6)

local fiturData = {
    {name = "⚡ Infinite Jump", state = true,  key = "InfiniteJump"},
    {name = "👻 NoClip",        state = false, key = "NoClip"},
    {name = "💡 Bright Vision", state = true,  key = "BrightVision"},
    {name = "🎵 Auto Dance",    state = false, key = "AutoDance"},
    {name = "🏃 Sprint (Shift)",state = true,  key = "Sprint"},
}

local toggleRefs = {}

for _, f in ipairs(fiturData) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(24, 18, 42)
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = fiturFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = f.name
    lbl.TextColor3 = Color3.fromRGB(210, 190, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 42, 0, 22)
    bg.Position = UDim2.new(1, -54, 0.5, -11)
    bg.BackgroundColor3 = f.state and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(55, 45, 75)
    bg.BorderSizePixel = 0
    bg.ZIndex = 13
    bg.Parent = row
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = f.state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.ZIndex = 14
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = {on = f.state}
    toggleRefs[f.key] = state

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 15
    clickBtn.Parent = row

    clickBtn.MouseButton1Click:Connect(function()
        state.on = not state.on
        local on = state.on
        TweenService:Create(bg, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(55, 45, 75)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()

        if f.key == "NoClip" then
            Settings.NoClip = on
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
        elseif f.key == "InfiniteJump" then
            -- sudah terhubung di atas
        end
        print((on and "✅ ON: " or "❌ OFF: ") .. f.name)
    end)
end

-- ===== TAB INFO =====
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, 0, 1, 0)
infoFrame.BackgroundTransparency = 1
infoFrame.Visible = false
infoFrame.ZIndex = 11
infoFrame.Parent = contentArea

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -10, 1, 0)
infoLbl.Position = UDim2.new(0, 8, 0, 4)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "⌨️ KEYBOARD\n\nE  →  Dance Random\nF  →  Stop Dance\nQ  →  NoClip ON/OFF\nShift  →  Sprint\nSpasi  →  Lompat\n\n🎭 ANIMASI\n16 Animasi Gratis\n100% Tanpa Beli\n\n✅ FITUR\nInfinite Jump\nAnti AFK\nBright Vision\nSprint\nAuto Dance\nNoClip"
infoLbl.TextColor3 = Color3.fromRGB(190, 165, 240)
infoLbl.TextSize = 13
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.TextWrapped = true
infoLbl.ZIndex = 12
infoLbl.Parent = infoFrame

-- ===== TOMBOL RANDOM & STOP =====
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, -16, 0, 40)
bottomBar.Position = UDim2.new(0, 8, 1, -48)
bottomBar.BackgroundTransparency = 1
bottomBar.ZIndex = 10
bottomBar.Parent = panel

local randBtn = Instance.new("TextButton")
randBtn.Size = UDim2.new(0.6, -4, 1, 0)
randBtn.Position = UDim2.new(0, 0, 0, 0)
randBtn.BackgroundColor3 = Color3.fromRGB(110, 55, 210)
randBtn.Text = "🎲 Random"
randBtn.TextColor3 = Color3.fromRGB(255,255,255)
randBtn.TextSize = 13
randBtn.Font = Enum.Font.GothamBold
randBtn.BorderSizePixel = 0
randBtn.ZIndex = 11
randBtn.Parent = bottomBar
Instance.new("UICorner", randBtn).CornerRadius = UDim.new(0, 10)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.4, -4, 1, 0)
stopBtn.Position = UDim2.new(0.6, 4, 0, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 70)
stopBtn.Text = "⏹ Stop"
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.TextSize = 13
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.ZIndex = 11
stopBtn.Parent = bottomBar
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 10)

randBtn.MouseButton1Click:Connect(function() playRandom() end)
stopBtn.MouseButton1Click:Connect(function() stopEmote() end)

-- ===== TAB SWITCH =====
local tabs = {
    {btn = tabEmoteBtn, content = emoteScroll},
    {btn = tabFiturBtn, content = fiturFrame},
    {btn = tabInfoBtn,  content = infoFrame},
}

local function switchTab(sel)
    for _, t in ipairs(tabs) do
        local active = t.btn == sel.btn
        t.content.Visible = active
        TweenService:Create(t.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = active and Color3.fromRGB(110, 55, 210) or Color3.fromRGB(35, 25, 55),
            TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,140,220),
        }):Play()
    end
end

for _, t in ipairs(tabs) do
    t.btn.MouseButton1Click:Connect(function() switchTab(t) end)
end
switchTab(tabs[1])

-- ===== TOGGLE PANEL =====
local panelOpen = false

local function openPanel()
    panelOpen = true
    panel.Visible = true
    panel.Size = UDim2.new(0, 0, 0, 0)
    panel.Position = UDim2.new(iconBtn.Position.X.Scale, iconBtn.Position.X.Offset + 65, iconBtn.Position.Y.Scale, iconBtn.Position.Y.Offset)
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 480),
        Position = UDim2.new(0, iconBtn.Position.X.Offset + 70, 0.5, -240),
    }):Play()
end

local function closePanel()
    panelOpen = false
    TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
    }):Play()
    task.wait(0.2)
    panel.Visible = false
end

local clickTime = 0
iconBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - clickTime < 0.3 then return end
    clickTime = now
    if not dragging then
        if panelOpen then closePanel() else openPanel() end
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
    if input.KeyCode == Enum.KeyCode.LeftShift then humanoid.WalkSpeed = Settings.WalkSpeed end
end)

print("✅ Dance Party UI siap! Klik icon 🎭 di layar!")
