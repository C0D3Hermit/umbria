--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║    COMBAT DRONE GUI - AUTO-REAPPLY SYSTEM (ENHANCED)          ║
    ║    Modifications persist even after exiting POV mode!         ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    ADD THIS ENHANCED AUTO-REAPPLY SYSTEM TO THE MAIN SCRIPT
]]

local RunService = game:GetService("RunService")

-- ============================================================================
-- AUTO-REAPPLY SYSTEM (Solves POV mode exit issue)
-- ============================================================================

-- State variables
local AutoReapplyEnabled = true
local LastReapplyTime = 0
local ReapplyThrottle = 0.5  -- Adjust between 0.1 - 5.0 seconds
local LastWeaponReference = nil
local ReapplyCount = 0
local IsReapplying = false

-- Enhanced apply function with caching
local function AutoReapply()
    if not AutoReapplyEnabled or IsReapplying then return end
    
    -- Throttle to prevent spam
    local currentTime = tick()
    if currentTime - LastReapplyTime < ReapplyThrottle then
        return
    end
    
    -- Try to find weapon config
    local success, gc = pcall(function() return getgc(true) end)
    if not success then return end
    
    for _, obj in pairs(gc) do
        if type(obj) == "table" and obj.ReloadTime and obj.AttackConfig then
            -- Detect if weapon config was recreated (new reference)
            if obj ~= LastWeaponReference then
                IsReapplying = true
                LastWeaponReference = obj
                
                -- Apply all modifications
                local applySuccess = ApplyModifications()
                
                if applySuccess then
                    ReapplyCount = ReapplyCount + 1
                    LastReapplyTime = currentTime
                    
                    -- Show notification (optional, can be toggled)
                    if ReapplyCount > 1 then -- Don't notify on first apply
                        ShowNotification(ScreenGui, 
                            string.format("🔄 Auto-reapplied modifications (#%d)", ReapplyCount),
                            Color3.fromRGB(100, 150, 255))
                    end
                    
                    print(string.format("✓ Auto-reapply #%d successful", ReapplyCount))
                end
                
                IsReapplying = false
                break
            end
        end
    end
end

-- Connect to RenderStepped for continuous monitoring
local AutoReapplyConnection = RunService.RenderStepped:Connect(function()
    AutoReapply()
end)

-- ============================================================================
-- GUI ADDITIONS FOR AUTO-REAPPLY CONTROLS
-- ============================================================================

-- Auto-Reapply Toggle Button (in TitleBar)
local AutoReapplyToggle = Instance.new("TextButton")
AutoReapplyToggle.Name = "AutoReapplyToggle"
AutoReapplyToggle.Size = UDim2.new(0, 140, 0, 26)
AutoReapplyToggle.Position = UDim2.new(1, -520, 0.5, -13)
AutoReapplyToggle.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
AutoReapplyToggle.BorderSizePixel = 0
AutoReapplyToggle.Font = Enum.Font.GothamBold
AutoReapplyToggle.Text = "✓ AUTO-REAPPLY: ON"
AutoReapplyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoReapplyToggle.TextSize = 10
AutoReapplyToggle.Parent = TitleBar

local AutoToggleCorner = Instance.new("UICorner")
AutoToggleCorner.CornerRadius = UDim.new(0, 6)
AutoToggleCorner.Parent = AutoReapplyToggle

-- Status Indicator (Bottom Bar)
local StatusIndicator = Instance.new("TextLabel")
StatusIndicator.Size = UDim2.new(0, 180, 0, 32)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusIndicator.BorderSizePixel = 0
StatusIndicator.Font = Enum.Font.Gotham
StatusIndicator.Text = "Reapplies: 0"
StatusIndicator.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusIndicator.TextSize = 10
StatusIndicator.Parent = BottomBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusIndicator

-- Manual Reapply Button (Bottom Bar)
local ManualReapplyBtn = Instance.new("TextButton")
ManualReapplyBtn.Size = UDim2.new(0, 130, 0, 32)
ManualReapplyBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
ManualReapplyBtn.BorderSizePixel = 0
ManualReapplyBtn.Font = Enum.Font.GothamBold
ManualReapplyBtn.Text = "🔄 REAPPLY NOW"
ManualReapplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualReapplyBtn.TextSize = 11
ManualReapplyBtn.Parent = BottomBar

local ManualCorner = Instance.new("UICorner")
ManualCorner.CornerRadius = UDim.new(0, 6)
ManualCorner.Parent = ManualReapplyBtn

-- Throttle Slider (in Advanced Settings)
local ThrottleContainer = Instance.new("Frame")
ThrottleContainer.Size = UDim2.new(1, -20, 0, 70)
ThrottleContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ThrottleContainer.BorderSizePixel = 0
ThrottleContainer.Parent = ContentScroll -- Add to content area

local ThrottleCorner = Instance.new("UICorner")
ThrottleCorner.CornerRadius = UDim.new(0, 6)
ThrottleCorner.Parent = ThrottleContainer

local ThrottleLabel = Instance.new("TextLabel")
ThrottleLabel.Size = UDim2.new(1, -20, 0, 20)
ThrottleLabel.Position = UDim2.new(0, 10, 0, 8)
ThrottleLabel.BackgroundTransparency = 1
ThrottleLabel.Font = Enum.Font.GothamBold
ThrottleLabel.Text = "Auto-Reapply Interval: 0.5s"
ThrottleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ThrottleLabel.TextSize = 12
ThrottleLabel.TextXAlignment = Enum.TextXAlignment.Left
ThrottleLabel.Parent = ThrottleContainer

local ThrottleSlider = Instance.new("Frame")
ThrottleSlider.Size = UDim2.new(1, -90, 0, 6)
ThrottleSlider.Position = UDim2.new(0, 10, 0, 40)
ThrottleSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ThrottleSlider.BorderSizePixel = 0
ThrottleSlider.Parent = ThrottleContainer

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 3)
SliderCorner.Parent = ThrottleSlider

local ThrottleFill = Instance.new("Frame")
ThrottleFill.Size = UDim2.new(0.1, 0, 1, 0)
ThrottleFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
ThrottleFill.BorderSizePixel = 0
ThrottleFill.Parent = ThrottleSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 3)
FillCorner.Parent = ThrottleFill

local ThrottleValue = Instance.new("TextLabel")
ThrottleValue.Size = UDim2.new(0, 70, 0, 18)
ThrottleValue.Position = UDim2.new(1, -70, 0, 35)
ThrottleValue.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ThrottleValue.BorderSizePixel = 0
ThrottleValue.Font = Enum.Font.GothamBold
ThrottleValue.Text = "0.5s"
ThrottleValue.TextColor3 = Color3.fromRGB(255, 255, 255)
ThrottleValue.TextSize = 11
ThrottleValue.Parent = ThrottleContainer

local ValueCorner = Instance.new("UICorner")
ValueCorner.CornerRadius = UDim.new(0, 4)
ValueCorner.Parent = ThrottleValue

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

-- Toggle auto-reapply
AutoReapplyToggle.MouseButton1Click:Connect(function()
    AutoReapplyEnabled = not AutoReapplyEnabled
    
    if AutoReapplyEnabled then
        AutoReapplyToggle.Text = "✓ AUTO-REAPPLY: ON"
        AutoReapplyToggle.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
        ShowNotification(ScreenGui, "✓ Auto-reapply enabled", Color3.fromRGB(40, 200, 80))
    else
        AutoReapplyToggle.Text = "✗ AUTO-REAPPLY: OFF"
        AutoReapplyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ShowNotification(ScreenGui, "✗ Auto-reapply disabled", Color3.fromRGB(200, 50, 50))
    end
end)

-- Manual reapply button
ManualReapplyBtn.MouseButton1Click:Connect(function()
    LastWeaponReference = nil -- Force reapply
    LastReapplyTime = 0
    AutoReapply()
    ShowNotification(ScreenGui, "🔄 Manually reapplied modifications", Color3.fromRGB(100, 150, 255))
end)

-- Update status indicator
spawn(function()
    while true do
        wait(0.5)
        if AutoReapplyEnabled then
            StatusIndicator.Text = string.format("🔄 Reapplies: %d | Active", ReapplyCount)
            StatusIndicator.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            StatusIndicator.Text = string.format("⏸️ Reapplies: %d | Paused", ReapplyCount)
            StatusIndicator.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
    end
end)

-- Throttle slider interaction
local draggingThrottle = false
ThrottleSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingThrottle = true
    end
end)

ThrottleSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingThrottle = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingThrottle and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position.X
        local sliderPos = ThrottleSlider.AbsolutePosition.X
        local sliderSize = ThrottleSlider.AbsoluteSize.X
        local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        
        -- Map to 0.1s - 5.0s range
        local value = 0.1 + (4.9 * relativePos)
        value = math.floor(value * 10 + 0.5) / 10
        
        ReapplyThrottle = value
        ThrottleValue.Text = string.format("%.1fs", value)
        ThrottleLabel.Text = string.format("Auto-Reapply Interval: %.1fs", value)
        ThrottleFill.Size = UDim2.new(relativePos, 0, 1, 0)
    end
end)

-- ============================================================================
-- CLEANUP
-- ============================================================================

-- Disconnect when GUI is destroyed
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if AutoReapplyConnection then
            AutoReapplyConnection:Disconnect()
        end
    end
end)

-- ============================================================================
-- INFO DISPLAY
-- ============================================================================

print("╔═══════════════════════════════════════════════════════════╗")
print("║    AUTO-REAPPLY SYSTEM LOADED                              ║")
print("╠═══════════════════════════════════════════════════════════╣")
print("║  ✓ Modifications will persist after exiting POV mode      ║")
print("║  ✓ Auto-reapply runs every 0.5s (adjustable)              ║")
print("║  ✓ Toggle with button in title bar                        ║")
print("║  ✓ Manual reapply button available                        ║")
print("╚═══════════════════════════════════════════════════════════╝")
