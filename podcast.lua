-- Dance Party UI - Simple Toggle Fix
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

local Settings = { WalkSpeed = 24, JumpPower = 60, NoClip = false, AutoDance = false }

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

-- Emote system
local currentTrack, isEmoting = nil, false

local function stopEmote()
    if currentTrack then currentTrack:Stop(0.2) currentTrack = nil end
    isEmoting = false
    if AnimateScript then AnimateScript.Disabled = false end
    humanoid.WalkSpeed = Settings.WalkSpeed
    humanoid.JumpPower = Settings.JumpPower
end

local function playEmote(e)
    stopEmote(); isEmoting = true
    local anim = Instance.new("Animation")
    anim.AnimationId = e.id
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if not ok then isEmoting = false return end
    track.Priority = Enum.AnimationPriority.Action2
    track:Play(0.2); currentTrack = track
    track.Stopped:Connect(function() isEmoting = false currentTrack = nil end)
    local c; c = RunService.Heartbeat:Connect(function()
        if not isEmoting then c:Disconnect() return end
        local v = humanoidRootPart.Velocity
        if Vector3.new(v.X,0,v.Z).Magnitude > 1 then stopEmote() c:Disconnect() end
    end)
    print("🎭 "..e.name)
end

local function playRandom() playEmote(emotes[math.random(1,#emotes)]) end

-- Setup karakter
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
local VU = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
RunService.Stepped:Connect(function()
    if Settings.NoClip then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p ~= humanoidRootPart then p.CanCollide = false end
        end
    end
end)

-- Hapus GUI lama
if player.PlayerGui:FindFirstChild("DanceUI") then
    player.PlayerGui:FindFirstChild("DanceUI"):Destroy()
end

-- Buat GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DanceUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- ICON BUTTON
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
panel.Size = UDim2.new(0, 300, 0, 450)
panel.Position = UDim2.new(0, 82, 0.5, -225)
panel.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 99
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", panel).Color = Color3.fromRGB(140, 80, 255)

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

-- Tombol X close di header
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
contentArea.Size = UDim2.new(1, -14, 0, 305)
contentArea.Position = UDim2.new(0, 7, 0, 86)
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
grid.CellSize = UDim2.new(0, 126, 0, 50)
grid.CellPadding = UDim2.new(0, 5, 0, 5)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", emoteScroll).PaddingTop = UDim.new(0, 4)

for _, emote in ipairs(emotes) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(0, 126, 0, 50)
    card.BackgroundColor3 = Color3.fromRGB(26, 20, 45)
    card.BorderSizePixel = 0
    card.Text = ""
    card.ZIndex = 102
    card.Parent = emoteScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Color3.fromRGB(70, 45, 120)

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
        playEmote(emote)
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80,40,140)}):Play()
        task.wait(0.15)
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26,20,45)}):Play()
    end)
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42,30,70)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26,20,45)}):Play()
    end)
end
emoteScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#emotes/2) * 55 + 10)

-- Fitur frame
local fiturFrame = Instance.new("Frame")
fiturFrame.Size = UDim2.new(1, 0, 1, 0)
fiturFrame.BackgroundTransparency = 1
fiturFrame.Visible = false
fiturFrame.ZIndex = 101
fiturFrame.Parent = contentArea
local fl = Instance.new("UIListLayout", fiturFrame)
fl.Padding = UDim.new(0, 6)

local fiturList = {
    {name = "⚡ Infinite Jump", key = "InfiniteJump", on = true},
    {name = "👻 NoClip",        key = "NoClip",        on = false},
    {name = "💡 Bright Vision", key = "BrightVision",  on = true},
    {name = "🎵 Auto Dance",    key = "AutoDance",      on = false},
    {name = "🏃 Sprint (Shift)",key = "Sprint",         on = true},
}

for _, f in ipairs(fiturList) do
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
    lbl.Text = f.name
    lbl.TextColor3 = Color3.fromRGB(210,190,255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 103
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 38, 0, 20)
    bg.Position = UDim2.new(1, -46, 0.5, -10)
    bg.BackgroundColor3 = f.on and Color3.fromRGB(120,60,220) or Color3.fromRGB(55,45,75)
    bg.BorderSizePixel = 0
    bg.ZIndex = 103
    bg.Parent = row
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = f.on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.ZIndex = 104
    circle.Parent = bg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = {on = f.on}
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
    end)
end

-- Info frame
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
infoLbl.Text = "⌨️ KEYBOARD\n\nE → Dance Random\nF → Stop Dance\nQ → NoClip ON/OFF\nShift → Sprint\nSpasi → Lompat\n\n🎭 16 Animasi Gratis\n100% Tanpa Beli\n\n✅ FITUR\nInfinite Jump | Anti AFK\nBright Vision | Sprint\nAuto Dance | NoClip"
infoLbl.TextColor3 = Color3.fromRGB(190,165,240)
infoLbl.TextSize = 13
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.TextWrapped = true
infoLbl.ZIndex = 102
infoLbl.Parent = infoFrame

-- Bottom bar
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
stopBtn.Text = "⏹ Stop"
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.TextSize = 11
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.ZIndex = 101
stopBtn.Parent = bottomBar
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 8)

randBtn.MouseButton1Click:Connect(function() playRandom() end)
stopBtn.MouseButton1Click:Connect(function() stopEmote() end)

-- Tab switch
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

-- ===== TOGGLE PANEL SIMPLE =====
-- Pakai variabel boolean sederhana
local panelOpen = false

local function togglePanel()
    panelOpen = not panelOpen
    if panelOpen then
        panel.Visible = true
        iconBtn.Text = "✕"
        iconStroke.Color = Color3.fromRGB(255, 80, 80)
    else
        panel.Visible = false
        iconBtn.Text = "🎭"
        iconStroke.Color = Color3.fromRGB(140, 80, 255)
    end
end

-- Icon klik = toggle panel
iconBtn.MouseButton1Click:Connect(function()
    togglePanel()
end)

-- Tombol X di header juga close
closeBtn.MouseButton1Click:Connect(function()
    panelOpen = true
    togglePanel()
end)

-- Keyboard
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

print("✅ Siap! Klik icon 🎭 di kiri tengah layar untuk buka menu!")
