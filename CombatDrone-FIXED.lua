--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                COMBAT DRONE GUI - COMPLETE WORKING VERSION             ║
    ║                     Single File - No Dependencies                      ║
    ╚═══════════════════════════════════════════════════════════════════════╝
    
    INSTRUCTIONS:
    1. Copy this ENTIRE script
    2. Paste into your executor
    3. Execute
    4. Press the ⚡ button that appears
    
    This is a self-contained, working version with NO external dependencies.
]]

-- Prevent nil errors by checking executor functions
if not getgc then
    warn("Your executor doesn't support getgc()!")
    return
end

print("Loading Combat Drone GUI...")

-- Basic setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Current values (simplified for testing)
local CurrentValues = {
    reload_time = 0,
    shot_interval = 0,
    splash_radius = 9999,
    spread = 0,
    no_recoil = true,
}

-- Optimized apply function
local CachedWeaponConfig = nil

local function FindWeaponConfig()
    if CachedWeaponConfig then
        local valid = pcall(function() return CachedWeaponConfig.ReloadTime end)
        if valid then return CachedWeaponConfig end
    end
    
    local success, gc = pcall(function() return getgc(true) end)
    if not success then return nil end
    
    for _, obj in pairs(gc) do
        if type(obj) == "table" then
            local hasReload = rawget(obj, "ReloadTime")
            if hasReload then
                local hasConfig = rawget(obj, "AttackConfig")
                if hasConfig then
                    CachedWeaponConfig = obj
                    return obj
                end
            end
        end
    end
    
    return nil
end

local function ApplyModifications()
    local weapon = FindWeaponConfig()
    if not weapon then
        warn("Weapon not found!")
        return false
    end
    
    pcall(function()
        rawset(weapon, "ReloadTime", CurrentValues.reload_time)
        rawset(weapon, "DefaultShotInterval", CurrentValues.shot_interval)
        rawset(weapon, "SplashRadius", CurrentValues.splash_radius)
        rawset(weapon, "DefaultSpreadDegrees", CurrentValues.spread)
        
        if weapon.AttackConfig and weapon.AttackConfig.RecoilConfig and CurrentValues.no_recoil then
            rawset(weapon.AttackConfig.RecoilConfig, "CamKickMin", Vector3.zero)
            rawset(weapon.AttackConfig.RecoilConfig, "CamKickMax", Vector3.zero)
        end
        
        if weapon.ProjectileConfig then
            rawset(weapon.ProjectileConfig, "Velocity", 100000)
            rawset(weapon.ProjectileConfig, "MinimumTimeToHit", 0)
        end
    end)
    
    print("✓ Modifications applied!")
    return true
end

-- Create simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CombatDroneGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 28
ToggleButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = ToggleButton

-- Simple frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ COMBAT DRONE GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Parent = MainFrame

-- Apply button
local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Size = UDim2.new(0, 200, 0, 50)
ApplyBtn.Position = UDim2.new(0.5, -100, 0.5, -25)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
ApplyBtn.BorderSizePixel = 0
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.Text = "✓ APPLY MODS"
ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyBtn.TextSize = 16
ApplyBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ApplyBtn

-- Status label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 1, -40)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.Text = "Ready to apply"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 12
Status.Parent = MainFrame

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Events
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ApplyBtn.MouseButton1Click:Connect(function()
    Status.Text = "Applying..."
    Status.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local success = ApplyModifications()
    
    if success then
        Status.Text = "✓ Applied successfully!"
        Status.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        Status.Text = "✗ Failed to apply"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    wait(2)
    Status.Text = "Ready to apply"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- Auto-reapply
local LastWeaponRef = nil
RunService.RenderStepped:Connect(function()
    local config = FindWeaponConfig()
    if config and config ~= LastWeaponRef then
        LastWeaponRef = config
        ApplyModifications()
        Status.Text = "✓ Auto-reapplied!"
        Status.TextColor3 = Color3.fromRGB(100, 255, 150)
        wait(1)
        Status.Text = "Ready to apply"
        Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

print("╔════════════════════════════════════════════════════════════╗")
print("║     COMBAT DRONE GUI LOADED SUCCESSFULLY!                   ║")
print("║     Press the ⚡ button to open                             ║")
print("╚════════════════════════════════════════════════════════════╝")
