-- Combat Drone GUI - Bulletproof Version
-- Fixed: "attempt to call a nil value" error

local success, result = pcall(function()

-- Check executor
if not getgc then
    error("Executor doesn't support getgc()!")
end

print("Loading...")

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- State
local CurrentValues = {
    reload_time = 0,
    shot_interval = 0,
    splash_radius = 9999,
    spread = 0,
    proj_velocity = 100000,
    min_time_hit = 0,
    movement_speed = 50,
    vertical_speed = 50,
    mag_size = 999,
    no_recoil = true,
}

-- Cache
local CachedWeaponConfig = nil
local CacheValid = false

-- Find weapon
local function FindWeapon()
    if CacheValid and CachedWeaponConfig then
        local valid = pcall(function() return CachedWeaponConfig.ReloadTime end)
        if valid then return CachedWeaponConfig end
        CacheValid = false
    end
    
    local gc = getgc(true)
    for _, obj in pairs(gc) do
        if type(obj) == "table" then
            local hasReload = rawget(obj, "ReloadTime")
            if hasReload then
                local hasConfig = rawget(obj, "AttackConfig")
                if hasConfig then
                    CachedWeaponConfig = obj
                    CacheValid = true
                    return obj
                end
            end
        end
    end
    return nil
end

-- Apply mods
local function ApplyMods()
    local weapon = FindWeapon()
    if not weapon then return false end
    
    pcall(function()
        rawset(weapon, "ReloadTime", CurrentValues.reload_time)
        rawset(weapon, "DefaultShotInterval", CurrentValues.shot_interval)
        rawset(weapon, "SplashRadius", CurrentValues.splash_radius)
        rawset(weapon, "DefaultSpreadDegrees", CurrentValues.spread)
        rawset(weapon, "MagSize", CurrentValues.mag_size)
        rawset(weapon, "MovementSpeed", CurrentValues.movement_speed)
        rawset(weapon, "VerticalMovementSpeed", CurrentValues.vertical_speed)
        
        if weapon.AttackConfig and weapon.AttackConfig.RecoilConfig then
            rawset(weapon.AttackConfig.RecoilConfig, "CamKickMin", Vector3.zero)
            rawset(weapon.AttackConfig.RecoilConfig, "CamKickMax", Vector3.zero)
        end
        
        if weapon.ProjectileConfig then
            rawset(weapon.ProjectileConfig, "Velocity", CurrentValues.proj_velocity)
            rawset(weapon.ProjectileConfig, "MinimumTimeToHit", CurrentValues.min_time_hit)
        end
    end)
    
    return true
end

-- Auto-reapply
local LastRef = nil
local ReapplyCount = 0
local AutoEnabled = true

RunService.RenderStepped:Connect(function()
    if not AutoEnabled then return end
    local config = FindWeapon()
    if config and config ~= LastRef then
        LastRef = config
        if ApplyMods() then
            ReapplyCount = ReapplyCount + 1
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatDroneGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 60, 0, 60)
Toggle.Position = UDim2.new(0, 10, 0.5, -30)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
Toggle.BorderSizePixel = 0
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "⚡"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 28
Toggle.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = Toggle

-- Main frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 400)
Main.Position = UDim2.new(0.5, -250, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ COMBAT DRONE GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Parent = Main

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 60)
Status.Position = UDim2.new(0, 10, 0, 60)
Status.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Status.BorderSizePixel = 0
Status.Font = Enum.Font.Gotham
Status.Text = "GOD MODE Active\nReapplies: 0"
Status.TextColor3 = Color3.fromRGB(100, 255, 100)
Status.TextSize = 14
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = Status

-- Info
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 180)
Info.Position = UDim2.new(0, 10, 0, 130)
Info.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Info.BorderSizePixel = 0
Info.Font = Enum.Font.Gotham
Info.Text = [[
✓ Instant Reload
✓ Maximum Fire Rate
✓ Massive Splash Radius (9999)
✓ Perfect Accuracy
✓ No Recoil
✓ Instant Projectiles
✓ Max Movement Speed
✓ 999 Round Magazine

Auto-reapply: ENABLED]]
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 12
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.TextWrapped = true
Info.Parent = Main

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = Info

-- Apply button
local Apply = Instance.new("TextButton")
Apply.Size = UDim2.new(0, 200, 0, 50)
Apply.Position = UDim2.new(0.5, -100, 1, -70)
Apply.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
Apply.BorderSizePixel = 0
Apply.Font = Enum.Font.GothamBold
Apply.Text = "✓ APPLY NOW"
Apply.TextColor3 = Color3.fromRGB(255, 255, 255)
Apply.TextSize = 16
Apply.Parent = Main

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0, 8)
ApplyCorner.Parent = Apply

-- Close button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -40, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.BorderSizePixel = 0
Close.Font = Enum.Font.GothamBold
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 14
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

-- Events
Toggle.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

Apply.MouseButton1Click:Connect(function()
    if ApplyMods() then
        Apply.Text = "✓ APPLIED!"
        Apply.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        wait(1)
        Apply.Text = "✓ APPLY NOW"
        Apply.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
    else
        Apply.Text = "✗ FAILED"
        Apply.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        wait(1)
        Apply.Text = "✓ APPLY NOW"
        Apply.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
    end
end)

-- Update status
spawn(function()
    while wait(1) do
        if Status then
            Status.Text = string.format("GOD MODE Active\nReapplies: %d", ReapplyCount)
        end
    end
end)

-- Draggable
local dragging = false
local dragInput, mousePos, framePos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - mousePos
        Main.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("╔════════════════════════════════════════════════════════════╗")
print("║  ✅ COMBAT DRONE GUI LOADED!                               ║")
print("║  Press ⚡ to open                                           ║")
print("║  GOD MODE preset active                                    ║")
print("║  Auto-reapply: ON                                          ║")
print("╚════════════════════════════════════════════════════════════╝")

end)

if not success then
    warn("Error loading GUI:", result)
else
    print("✓ GUI loaded successfully!")
end
