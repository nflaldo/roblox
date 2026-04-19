-- Script: FIXED - Walk, Jump & Emote
-- Jalankan via Executor (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local AnimateScript = nil

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")

-- ===== PERBAIKAN ANIMASI BERJALAN =====
-- Aktifkan kembali script Animate bawaan Roblox
AnimateScript = character:FindFirstChild("Animate")
if AnimateScript then
    AnimateScript.Disabled = false
end

-- ===== PENGATURAN =====
local Settings = {
    WalkSpeed = 24,
    JumpPower = 60,
    InfiniteJump = true,
    NoClip = false,
    AntiAFK = true,
    BrightVision = true,
}

-- ===== ANIMASI GRATIS 100% =====
local emotes = {
    {name = "Dance 1",      id = "rbxassetid://507771019"},
    {name = "Dance 2",      id = "rbxassetid://507776043"},
    {name = "Dance 3",      id = "rbxassetid://507776048"},
    {name = "Wave",         id = "rbxassetid://507770239"},
    {name = "Point",        id = "rbxassetid://507770453"},
    {name = "Cheer",        id = "rbxassetid://507770677"},
    {name = "Laugh",        id = "rbxassetid://507770818"},
    {name = "Salute",       id = "rbxassetid://3544351430"},
    {name = "Shrug",        id = "rbxassetid://3544203072"},
    {name = "Tilt",         id = "rbxassetid://3544200075"},
    {name = "Facepalm",     id = "rbxassetid://3544406036"},
    {name = "Breakdance",   id = "rbxassetid://3544419558"},
    {name = "Victory",      id = "rbxassetid://4849487550"},
    {name = "Confused",     id = "rbxassetid://4849520943"},
    {name = "Tai Chi",      id = "rbxassetid://4849470700"},
    {name = "Air Guitar",   id = "rbxassetid://4849504141"},
    {name = "Head Spin",    id = "rbxassetid://5915812855"},
    {name = "Applaud",      id = "rbxassetid://5915693785"},
}

-- ===== FUNGSI PLAY EMOTE =====
local currentTrack = nil
local lastIndex = 0
local isEmoting = false

local function stopEmote()
    if currentTrack then
        currentTrack:Stop(0.2)
        currentTrack = nil
    end
    isEmoting = false

    -- Pulihkan animasi jalan & lompat
    if AnimateScript then
        AnimateScript.Disabled = false
    end
    humanoid.WalkSpeed = Settings.WalkSpeed
    humanoid.JumpPower = Settings.JumpPower
    print("⏹ Emote berhenti - bisa jalan & lompat lagi!")
end

local function playEmote(emoteData)
    -- Stop emote sebelumnya
    stopEmote()
    isEmoting = true

    local anim = Instance.new("Animation")
    anim.AnimationId = emoteData.id

    local success, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)

    if not success then
        print("❌ Gagal load: " .. emoteData.name)
        isEmoting = false
        return
    end

    -- Pakai Movement priority agar tidak konflik dengan walk/jump
    track.Priority = Enum.AnimationPriority.Action2
    track:Play(0.2)
    currentTrack = track

    -- Auto stop emote saat karakter bergerak
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not isEmoting then
            connection:Disconnect()
            return
        end
        local velocity = humanoidRootPart.Velocity
        local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        if speed > 1 then
            stopEmote()
            connection:Disconnect()
        end
    end)

    -- Auto stop saat animasi selesai
    track.Stopped:Connect(function()
        if isEmoting then
            isEmoting = false
            currentTrack = nil
        end
    end)

    print("🎭 Emote: " .. emoteData.name)
end

local function playRandomEmote()
    local index
    repeat
        index = math.random(1, #emotes)
    until index ~= lastIndex
    lastIndex = index
    playEmote(emotes[index])
end

local emoteIndex = 1
local function playNextEmote()
    playEmote(emotes[emoteIndex])
    print("📋 " .. emoteIndex .. "/" .. #emotes .. " - " .. emotes[emoteIndex].name)
    emoteIndex = emoteIndex % #emotes + 1
end

local function playPrevEmote()
    emoteIndex = emoteIndex - 2
    if emoteIndex < 1 then emoteIndex = #emotes end
    playEmote(emotes[emoteIndex])
    print("📋 " .. emoteIndex .. "/" .. #emotes .. " - " .. emotes[emoteIndex].name)
    emoteIndex = emoteIndex % #emotes + 1
end

-- ===== AUTO DANCE =====
local autoDance = false

local function toggleAutoDance()
    autoDance = not autoDance
    if autoDance then
        print("🎵 Auto Dance ON!")
        task.spawn(function()
            while autoDance do
                if not isEmoting then
                    playRandomEmote()
                end
                task.wait(6)
            end
        end)
    else
        stopEmote()
        print("⏹ Auto Dance OFF")
    end
end

-- ===== 1. WALK & JUMP =====
humanoid.WalkSpeed = Settings.WalkSpeed
humanoid.JumpPower = Settings.JumpPower
humanoid.PlatformStand = false
humanoid.Sit = false

humanoidRootPart.Anchored = false
for _, part in pairs(character:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = false
    end
end
print("✅ Walk & Jump aktif!")

-- ===== 2. INFINITE JUMP =====
if Settings.InfiniteJump then
    UserInputService.JumpRequest:Connect(function()
        if isEmoting then stopEmote() end
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    print("✅ Infinite Jump aktif!")
end

-- ===== 3. INPUT KEYBOARD =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.E then
        playRandomEmote()
    end

    if input.KeyCode == Enum.KeyCode.R then
        playNextEmote()
    end

    if input.KeyCode == Enum.KeyCode.T then
        playPrevEmote()
    end

    if input.KeyCode == Enum.KeyCode.F then
        stopEmote()
    end

    if input.KeyCode == Enum.KeyCode.G then
        toggleAutoDance()
    end

    if input.KeyCode == Enum.KeyCode.Q then
        Settings.NoClip = not Settings.NoClip
        print("🔁 NoClip: " .. (Settings.NoClip and "ON" or "OFF"))
    end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        humanoid.WalkSpeed = 50
        print("🏃 Sprint ON")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        humanoid.WalkSpeed = Settings.WalkSpeed
        print("🚶 Sprint OFF")
    end
end)

-- ===== 4. NOCLIP =====
RunService.Stepped:Connect(function()
    if Settings.NoClip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= humanoidRootPart then
                part.CanCollide = false
            end
        end
    end
end)

-- ===== 5. ANTI AFK =====
if Settings.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        print("✅ Anti-AFK triggered!")
    end)
    print("✅ Anti-AFK aktif!")
end

-- ===== 6. BRIGHT VISION =====
if Settings.BrightVision then
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 5
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    print("✅ Bright Vision aktif!")
end

print("=================================")
print("✅ Semua fitur aktif!")
print("📌 E     = Dance Random")
print("📌 R     = Dance Selanjutnya")
print("📌 T     = Dance Sebelumnya")
print("📌 F     = Stop Dance")
print("📌 G     = Auto Dance ON/OFF")
print("📌 Q     = NoClip ON/OFF")
print("📌 Shift = Sprint")
print("=================================")
