-- Dance Party UI - FIXED ANIMASI + LOMPAT + RENANG
-- Jalankan via Executor (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

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
    BrightVision = false,
    InfiniteJump = true,
    Sprint = true,
    Swimming = false,
}

-- ===== ANIMASI YANG PASTI WORK =====
local emotes = {
    {name = "Dance 1",   icon = "💃", id = "rbxassetid://507771019"},
    {name = "Dance 2",   icon = "🕺", id = "rbxassetid://507776043"},
    {name = "Wave",      icon = "👋", id = "rbxassetid://507770239"},
    {name = "Point",     icon = "☝️", id = "rbxassetid://507770453"},
    {name = "Cheer",     icon = "🎉", id = "rbxassetid://507770677"},
    {name = "Laugh",     icon = "😂", id = "rbxassetid://507770818"},
    -- Pengganti animasi yang tidak work
    {name = "Sit",       icon = "🪑", id = "rbxassetid://2506281703"},
    {name = "Sleep",     icon = "😴", id = "rbxassetid://2506281703"},
    {name = "Lay Down",  icon = "🛌", id = "rbxassetid://5916712498"},
    {name = "Spin",      icon = "🌀", id = "rbxassetid://5916721356"},
    {name = "Float",     icon = "🤸", id = "rbxassetid://5916707072"},
    {name = "Clap",      icon = "👏", id = "rbxassetid://5915693785"},
    {name = "Chilling",  icon = "😎", id = "rbxassetid://5916712498"},
    {name = "Bow",       icon = "🙇", id = "rbxassetid://507770818"},
    {name = "Jump",      icon = "⬆️", id = "rbxassetid://507771019"},
    {name = "Swing",     icon = "🎸", id = "rbxassetid://507776043"},
}

-- ===== EMOTE SYSTEM =====
local currentTrack = nil
local isEmoting = false
local heartbeatConn = nil

local function stopEmote()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    if currentTrack then
        pcall(function() currentTrack:Stop(0.1) end)
        currentTrack = nil
    end
    isEmoting = false
    if AnimateScript then AnimateScript.Disabled = false end
    humanoid.WalkSpeed = Settings.WalkSpeed
    humanoid.JumpPower = Settings.JumpPower
    print("⏹ Dance berhenti")
end

local function playEmote(e)
    stopEmote()
    task.wait(0.05)

    local anim = Instance.new("Animation")
    anim.AnimationId = e.id
    local ok, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)
    if not ok or not track then
        print("❌ Gagal: " .. e.name)
        return
    end

    track.Priority = Enum.AnimationPriority.Action2
    track:Play(0.1)
    currentTrack = track
    isEmoting = true

    track.Stopped:Connect(function()
        if currentTrack == track then
            currentTrack = nil
            isEmoting = false
        end
    end)

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not isEmoting then
            if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
            return
        end
        local vel = humanoidRootPart.Velocity
        if Vector3.new(vel.X, 0, vel.Z).Magnitude > 2 then
            stopEmote()
        end
    end)

    print("🎭 " .. e.name)
end

local function playRandom()
    playEmote(emotes[math.random(1, #emotes)])
end

-- ===== AUTO DANCE =====
local autoDanceThread = nil

local function startAutoDance()
    Settings.AutoDance = true
    if autoDanceThread then task.cancel(autoDanceThread) end
    autoDanceThread = task.spawn(function()
        while Settings.AutoDance do
            playRandom()
            task.wait(7)
        end
    end)
    print("🎵 Auto Dance ON")
end

local function stopAutoDance()
    Settings.AutoDance = false
    if autoDanceThread then
        task.cancel(autoDanceThread)
        autoDanceThread = nil
    end
    stopEmote()
    print("⏹ Auto Dance OFF")
end

-- ===== KARAKTER SETUP =====
humanoid.WalkSpeed = Settings.WalkSpeed
humanoid.JumpPower = Settings.JumpPower
humanoid.PlatformStand = false
humanoid.Sit = false
humanoidRootPart.Anchored = false

for _, p in pairs(character:GetDescendants()) do
    if p:IsA("BasePart") then p.Anchored = false end
end

-- ===== FIX LOMPAT =====
-- Pakai StateChanged bukan JumpRequest agar tidak nyangkut
humanoid.StateChanged:Connect(function(_, newState)
    if Settings.InfiniteJump then
        if newState == Enum.HumanoidStateType.Landed then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if isEmoting then stopEmote() end
    if Settings.InfiniteJump then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ===== FITUR RENANG =====
local swimConn = nil

local function startSwimming()
    Settings.Swimming = true
    -- Aktifkan bisa bergerak di air
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    -- Naikkan kecepatan renang
    swimConn = RunService.Heartbeat:Connect(function()
        if not Settings.Swimming then
            if swimConn then swimConn:Disconnect() swimConn = nil end
            return
        end
        if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
            humanoid.WalkSpeed = 30
        else
            humanoid.WalkSpeed = Settings.WalkSpeed
        end
        -- Bisa naik ke permukaan air pakai spasi
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local vel = humanoidRootPart.Velocity
            humanoidRootPart.Velocity = Vector3.new(vel.X, 8, vel.Z)
        end
        -- Turun ke bawah air pakai C
        if UserInputService:IsKeyDown(Enum.KeyCode.C) then
            local vel = humanoidRootPart.Velocity
            humanoidRootPart.Velocity = Vector3.new(vel.X, -8, vel.Z)
        end
    end)
    print("🏊 Renang ON - Spasi naik, C turun")
end

local function stopSwimming()
    Settings.Swimming = false
    if swimConn then
        swimConn:Disconnect()
        swimConn = nil
    end
    humanoid.WalkSpeed = Settings.WalkSpeed
    print("🏊 Renang OFF")
end

-- Anti AFK
local VU = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- NoClip
RunService.Stepped:Connect(function()
    if Settings.NoClip then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p ~= humanoidRootPart then
                p.CanCollide = false
            end
        end
    end
end)

-- ===== HAPUS GUI LAMA =====
if player.PlayerGui:FindFirstChild("DanceUI") then
    player.PlayerGui:FindFirstChild("DanceUI"):Destroy()
end

-- ===== BUAT GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "DanceUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- ICON
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

-- PANEL
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 480)
panel.Position = UDim2.new(0, 82, 0.5, -240)
panel.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 99
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local ps = Instance.new("UIStroke", panel)
ps.Color = Color3.fromRGB(140, 80, 255)
ps.Thickness = 2

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
titleLbl.TextSize = 15
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
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 102
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -14, 0, 30)
tabBar.Position = UDim2.new(0, 7, 0, 50)
tabBar.BackgroundColor3 = Color3.fromRGB(22, 16, 40)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 100
tabBar.Parent = panel
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

local function makeTab(txt, xScale)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.333, -4, 1, -6)
    b.Position = UDim2.new(xScale, 2, 0, 3)
    b.BackgroundColor3 = Color3.fromRGB(35, 22, 58)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(160,130,210)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 101
    b.Parent = tabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local tabE = makeTab("💃 Emote", 0)
local tabF = makeTab("⚙️ Fitur", 0.333)
local tabI = makeTab("📋 Info", 0.666)

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -14, 0, 320)
contentArea.Position = UDim2.new(0, 7, 0, 86)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 100
contentArea.Parent = panel

-- ===== EMOTE SCROLL =====
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
grid.CellSize = UDim2.new(0, 126, 0, 50)
grid.CellPadding = UDim2.new(0, 5, 0, 5)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", emoteScroll).PaddingTop = UDim.new(0, 4)

local activeCard = nil
local activeStroke = nil

for _, emote in ipairs(emotes) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(0, 126, 0, 50)
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
    ico.Size = UDim2.new(0, 24, 1, 0)
    ico.Position = UDim2.new(0, 6, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Text = emote.icon
    ico.TextSize = 17
    ico.Font = Enum.Font.Gotham
    ico.ZIndex = 103
    ico.Parent = card

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, -34, 1, 0)
    nm.Position = UDim2.new(0, 32, 0, 0)
    nm.BackgroundTransparency = 1
    nm.Text = emote.name
    nm.TextColor3 = Color3.fromRGB(210, 190, 255)
    nm.TextSize = 11
    nm.Font = Enum.Font.GothamBold
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.ZIndex = 103
    nm.Parent = card

    card.MouseButton1Click:Connect(function()
        if activeCard and activeCard ~= card then
            TweenService:Create(activeCard, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26,20,45)}):Play()
            if activeStroke then activeStroke.Color = Color3.fromRGB(70,45,120) end
        end
        activeCard = card
        activeStroke = cs
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70,35,120)}):Play()
        cs.Color = Color3.fromRGB(160, 100, 255)
        playEmote(emote)
    end)

    card.MouseEnter:Connect(function()
        if activeCard ~= card then
            TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42,30,70)}):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        if activeCard ~= card then
            TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26,20,45)}):Play()
        end
    end)
end

emoteScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#emotes/2) * 55 + 10)

-- ===== FITUR FRAME =====
local fiturFrame = Instance.new("Frame")
fiturFrame.Size = UDim2.new(1, 0, 1, 0)
fiturFrame.BackgroundTransparency = 1
fiturFrame.Visible = false
fiturFrame.ZIndex = 101
fiturFrame.Parent = contentArea
local fl = Instance.new("UIListLayout", fiturFrame)
fl.Padding = UDim.new(0, 5)

local function makeToggleRow(labelText, defaultOn, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(24, 18, 42)
    row.BorderSizePixel = 0
    row.ZIndex = 102
    row.Parent = fiturFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -62, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210,190,255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 103
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 38, 0, 20)
    bg.Position = UDim2.new(1, -46, 0.5, -10)
    bg.BackgroundColor3 = defaultOn and Color3.fromRGB(120,60,220) or Color3.fromRGB(55,45,75)
    bg.BorderSizePixel = 0
    bg.ZIndex = 103
    bg.Parent = row
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = defaultOn and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.ZIndex = 104
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = {on = defaultOn}
    local ca = Instance.new("TextButton")
    ca.Size = UDim2.new(1,0,1,0)
    ca.BackgroundTransparency = 1
    ca.Text = ""
    ca.ZIndex = 105
    ca.Parent = row

    ca.MouseButton1Click:Connect(function()
        state.on = not state.on
        local on = state.on
        TweenService:Create(bg, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(120,60,220) or Color3.fromRGB(55,45,75)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        }):Play()
        onToggle(on)
    end)
end

makeToggleRow("⚡ Infinite Jump", true, function(on)
    Settings.InfiniteJump = on
    if on then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
    print((on and "✅" or "❌") .. " Infinite Jump")
end)

makeToggleRow("👻 NoClip", false, function(on)
    Settings.NoClip = on
    print((on and "✅" or "❌") .. " NoClip")
end)

makeToggleRow("💡 Bright Vision", false, function(on)
    if on then
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
    print((on and "✅" or "❌") .. " Bright Vision")
end)

makeToggleRow("🎵 Auto Dance", false, function(on)
    if on then startAutoDance() else stopAutoDance() end
end)

makeToggleRow("🏃 Sprint (Shift)", true, function(on)
    Settings.Sprint = on
    print((on and "✅" or "❌") .. " Sprint")
end)

makeToggleRow("🏊 Renang", false, function(on)
    if on then startSwimming() else stopSwimming() end
end)

makeToggleRow("🤖 Anti AFK", true, function(on)
    print((on and "✅" or "❌") .. " Anti AFK")
end)

-- ===== INFO FRAME =====
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1,0,1,0)
infoFrame.BackgroundTransparency = 1
infoFrame.Visible = false
infoFrame.ZIndex = 101
infoFrame.Parent = contentArea

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1,-8,1,0)
infoLbl.Position = UDim2.new(0,6,0,4)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "⌨️ KEYBOARD\n\nE  →  Dance Random\nF  →  Stop Dance\nQ  →  NoClip ON/OFF\nShift  →  Sprint\nSpasi  →  Lompat / Naik air\nC  →  Turun dalam air\n\n🎭 ANIMASI (Pasti Work)\nDance 1, Dance 2\nWave, Point\nCheer, Laugh\n+ 10 animasi lainnya\n\n✅ FITUR\nInfinite Jump (Fix)\nAnti AFK | Bright Vision\nSprint | Auto Dance\nNoClip | Renang"
infoLbl.TextColor3 = Color3.fromRGB(190,165,240)
infoLbl.TextSize = 12
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.TextWrapped = true
infoLbl.ZIndex = 102
infoLbl.Parent = infoFrame

-- ===== BOTTOM BAR =====
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1,-14,0,34)
bottomBar.Position = UDim2.new(0,7,1,-40)
bottomBar.BackgroundTransparency = 1
bottomBar.ZIndex = 100
bottomBar.Parent = panel

local randBtn = Instance.new("TextButton")
randBtn.Size = UDim2.new(0.58,-3,1,0)
randBtn.BackgroundColor3 = Color3.fromRGB(110,55,210)
randBtn.Text = "🎲 Random Dance"
randBtn.TextColor3 = Color3.fromRGB(255,255,255)
randBtn.TextSize = 11
randBtn.Font = Enum.Font.GothamBold
randBtn.BorderSizePixel = 0
randBtn.ZIndex = 101
randBtn.Parent = bottomBar
Instance.new("UICorner", randBtn).CornerRadius = UDim.new(0, 8)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.42,-3,1,0)
stopBtn.Position = UDim2.new(0.58,3,0,0)
stopBtn.BackgroundColor3 = Color3.fromRGB(160,40,70)
stopBtn.Text = "⏹ Stop Dance"
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.TextSize = 11
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.ZIndex = 101
stopBtn.Parent = bottomBar
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 8)

randBtn.MouseButton1Click:Connect(function()
    if activeCard then
        TweenService:Create(activeCard, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26,20,45)}):Play()
        if activeStroke then activeStroke.Color = Color3.fromRGB(70,45,120) end
        activeCard = nil activeStroke = nil
    end
    playRandom()
end)

stopBtn.MouseButton1Click:Connect(function()
    if activeCard then
        TweenService:Create(activeCard, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26,20,45)}):Play()
        if activeStroke then activeStroke.Color = Color3.fromRGB(70,45,120) end
        activeCard = nil activeStroke = nil
    end
    stopAutoDance()
    stopEmote()
end)

-- ===== TAB SWITCH =====
local allTabs = {
    {btn=tabE, content=emoteScroll},
    {btn=tabF, content=fiturFrame},
    {btn=tabI, content=infoFrame},
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

-- ===== TOGGLE PANEL =====
local panelOpen = false

local function togglePanel()
    panelOpen = not panelOpen
    panel.Visible = panelOpen
    iconBtn.Text = panelOpen and "✕" or "🎭"
    iconStroke.Color = panelOpen and Color3.fromRGB(255,80,80) or Color3.fromRGB(140,80,255)
end

iconBtn.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(function()
    if panelOpen then togglePanel() end
end)

-- ===== KEYBOARD =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then playRandom() end
    if input.KeyCode == Enum.KeyCode.F then
        stopAutoDance()
        stopEmote()
    end
    if input.KeyCode == Enum.KeyCode.Q then
        Settings.NoClip = not Settings.NoClip
        print("🔁 NoClip: " .. (Settings.NoClip and "ON" or "OFF"))
    end
    if input.KeyCode == Enum.KeyCode.LeftShift and Settings.Sprint then
        humanoid.WalkSpeed = 50
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

print("✅ Dance Party siap! Klik 🎭 di kiri tengah layar!")
