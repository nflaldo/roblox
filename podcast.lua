-- Script: Avatar Enhancement + Emote Menarik
-- Jalankan via Executor (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ===== PENGATURAN =====
local Settings = {
    WalkSpeed = 24,
    JumpPower = 60,
    InfiniteJump = true,
    NoClip = false,
    AntiAFK = true,
    BrightVision = true,
}

-- ===== DAFTAR EMOTE MENARIK =====
local emotes = {
    -- Dance
    "dance",
    "dance2", 
    "dance3",
    -- Ekspresi
    "wave",
    "cheer",
    "laugh",
    "shrug",
    "idk",
    -- Keren
    "salute",
    "point",
    -- Tambahan Roblox Default
    "tilt",
    "smile",
    "shocked",
    "scared",
    "agree",
    "disagree",
    "eyeroll",
    "victory",
    "clap",
    "stampede",
}

-- ===== FUNGSI EMOTE RANDOM =====
local lastEmote = ""
local function playRandomEmote()
    local randomEmote
    repeat
        randomEmote = emotes[math.random(1, #emotes)]
    until randomEmote ~= lastEmote -- tidak repeat emote yang sama
    lastEmote = randomEmote
    humanoid:PlayEmote(randomEmote)
    print("🎭 Emote: " .. randomEmote)
end

-- ===== FUNGSI EMOTE SPESIFIK =====
local emoteIndex = 1
local function playNextEmote()
    humanoid:PlayEmote(emotes[emoteIndex])
    print("🎭 Emote ke-" .. emoteIndex .. ": " .. emotes[emoteIndex])
    emoteIndex = emoteIndex % #emotes + 1
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
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    print("✅ Infinite Jump aktif!")
end

-- ===== 3. INPUT KEYBOARD =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- E = Emote RANDOM
    if input.KeyCode == Enum.KeyCode.E then
        playRandomEmote()
    end

    -- R = Emote URUT (next)
    if input.KeyCode == Enum.KeyCode.R then
        playNextEmote()
    end

    -- Q = Toggle NoClip
    if input.KeyCode == Enum.KeyCode.Q then
        Settings.NoClip = not Settings.NoClip
        print("🔁 NoClip: " .. (Settings.NoClip and "ON" or "OFF"))
    end

    -- Shift = Sprint
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
print("📌 E     = Emote Random")
print("📌 R     = Emote Urut")
print("📌 Q     = Toggle NoClip")
print("📌 Shift = Sprint")
print("=================================")
