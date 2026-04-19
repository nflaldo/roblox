-- Script: Avatar Enhancement - Jalan, Lompat & Fitur Tambahan
-- Jalankan via Executor (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- ===== PENGATURAN =====
local Settings = {
    WalkSpeed = 24,        -- Kecepatan jalan (default 16)
    JumpPower = 60,        -- Kekuatan lompat (default 50)
    InfiniteJump = true,   -- Lompat terus tanpa batas
    NoClip = false,        -- Tembus dinding (toggle Q)
    AntiAFK = true,        -- Tidak auto-kick AFK
    BrightVision = true,   -- Pencahayaan lebih terang
    FPS = 60,              -- Target FPS
}

-- ===== 1. WALK & JUMP =====
humanoid.WalkSpeed = Settings.WalkSpeed
humanoid.JumpPower = Settings.JumpPower
humanoid.PlatformStand = false
humanoid.Sit = false

-- Unfreeze karakter
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
        if character and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    print("✅ Infinite Jump aktif!")
end

-- ===== 3. NOCLIP (Toggle pakai Q) =====
local noClipEnabled = Settings.NoClip
RunService.Stepped:Connect(function()
    if noClipEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= humanoidRootPart then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Toggle NoClip dengan tombol Q
    if input.KeyCode == Enum.KeyCode.Q then
        noClipEnabled = not noClipEnabled
        print("🔁 NoClip: " .. (noClipEnabled and "ON" or "OFF"))
    end

    -- Speed Boost sementara dengan Shift (sprint)
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

-- ===== 4. ANTI AFK =====
if Settings.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        print("✅ Anti-AFK triggered!")
    end)
    print("✅ Anti-AFK aktif!")
end

-- ===== 5. BRIGHT VISION =====
if Settings.BrightVision then
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = 5
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    print("✅ Bright Vision aktif!")
end

-- ===== 6. FPS UNLOCKER =====
settings().Rendering.FrameRateManager = Enum.FrameRateManagerMode.Disabled
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
print("✅ FPS Unlocker aktif!")

print("=================================")
print("✅ Semua fitur berhasil diaktifkan!")
print("📌 Q = Toggle NoClip")
print("📌 Shift = Sprint")
print("=================================")
