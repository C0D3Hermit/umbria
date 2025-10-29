-- Enhanced Save/Load System for Umbria Gui
-- This is an addon module that adds a comprehensive preset management system

--[[
    ENHANCED SAVE SYSTEM FEATURES:
    1. Save configurations as named presets
    2. Load presets from library
    3. Export presets as shareable codes
    4. Import presets from codes
    5. Delete unwanted presets
    6. Preset metadata (name, description, author, date)
    7. Auto-save last configuration
    8. Copy to clipboard functionality
    9. Preset preview before loading
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Preset Manager Module
local PresetManager = {}
PresetManager.SavedPresets = {}
PresetManager.CurrentPreset = nil

-- Create Save/Load Window
function PresetManager:CreateSaveLoadWindow(ScreenGui)
    local SaveLoadFrame = Instance.new("Frame")
    SaveLoadFrame.Name = "SaveLoadFrame"
    SaveLoadFrame.Size = UDim2.new(0, 600, 0, 500)
    SaveLoadFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    SaveLoadFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    SaveLoadFrame.BorderSizePixel = 0
    SaveLoadFrame.Visible = false
    SaveLoadFrame.ZIndex = 300
    SaveLoadFrame.Parent = ScreenGui
    
    local SaveLoadCorner = Instance.new("UICorner")
    SaveLoadCorner.CornerRadius = UDim.new(0, 12)
    SaveLoadCorner.Parent = SaveLoadFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = SaveLoadFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleCover = Instance.new("Frame")
    TitleCover.Size = UDim2.new(1, 0, 0, 12)
    TitleCover.Position = UDim2.new(0, 0, 1, -12)
    TitleCover.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TitleCover.BorderSizePixel = 0
    TitleCover.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "💾 PRESET MANAGER"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 28)
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Tab Buttons
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -20, 0, 35)
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = SaveLoadFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.Parent = TabContainer
    
    -- Save Tab Button
    local SaveTab = Instance.new("TextButton")
    SaveTab.Name = "SaveTab"
    SaveTab.Size = UDim2.new(0, 140, 1, 0)
    SaveTab.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
    SaveTab.BorderSizePixel = 0
    SaveTab.Font = Enum.Font.GothamBold
    SaveTab.Text = "💾 SAVE"
    SaveTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveTab.TextSize = 12
    SaveTab.Parent = TabContainer
    
    local SaveTabCorner = Instance.new("UICorner")
    SaveTabCorner.CornerRadius = UDim.new(0, 6)
    SaveTabCorner.Parent = SaveTab
    
    -- Load Tab Button
    local LoadTab = Instance.new("TextButton")
    LoadTab.Name = "LoadTab"
    LoadTab.Size = UDim2.new(0, 140, 1, 0)
    LoadTab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    LoadTab.BorderSizePixel = 0
    LoadTab.Font = Enum.Font.GothamBold
    LoadTab.Text = "📂 LOAD"
    LoadTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    LoadTab.TextSize = 12
    LoadTab.Parent = TabContainer
    
    local LoadTabCorner = Instance.new("UICorner")
    LoadTabCorner.CornerRadius = UDim.new(0, 6)
    LoadTabCorner.Parent = LoadTab
    
    -- Import Tab Button
    local ImportTab = Instance.new("TextButton")
    ImportTab.Name = "ImportTab"
    ImportTab.Size = UDim2.new(0, 140, 1, 0)
    ImportTab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ImportTab.BorderSizePixel = 0
    ImportTab.Font = Enum.Font.GothamBold
    ImportTab.Text = "📥 IMPORT"
    ImportTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    ImportTab.TextSize = 12
    ImportTab.Parent = TabContainer
    
    local ImportTabCorner = Instance.new("UICorner")
    ImportTabCorner.CornerRadius = UDim.new(0, 6)
    ImportTabCorner.Parent = ImportTab
    
    -- Export Tab Button
    local ExportTab = Instance.new("TextButton")
    ExportTab.Name = "ExportTab"
    ExportTab.Size = UDim2.new(0, 140, 1, 0)
    ExportTab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ExportTab.BorderSizePixel = 0
    ExportTab.Font = Enum.Font.GothamBold
    ExportTab.Text = "📤 EXPORT"
    ExportTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    ExportTab.TextSize = 12
    ExportTab.Parent = TabContainer
    
    local ExportTabCorner = Instance.new("UICorner")
    ExportTabCorner.CornerRadius = UDim.new(0, 6)
    ExportTabCorner.Parent = ExportTab
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -20, 1, -150)
    ContentContainer.Position = UDim2.new(0, 10, 0, 100)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = SaveLoadFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer
    
    -- SAVE TAB CONTENT
    local SaveContent = Instance.new("Frame")
    SaveContent.Name = "SaveContent"
    SaveContent.Size = UDim2.new(1, 0, 1, 0)
    SaveContent.BackgroundTransparency = 1
    SaveContent.Visible = true
    SaveContent.Parent = ContentContainer
    
    -- Preset Name Input
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -20, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 15)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = "Preset Name:"
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = SaveContent
    
    local NameInput = Instance.new("TextBox")
    NameInput.Name = "NameInput"
    NameInput.Size = UDim2.new(1, -20, 0, 35)
    NameInput.Position = UDim2.new(0, 10, 0, 40)
    NameInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    NameInput.BorderSizePixel = 0
    NameInput.Font = Enum.Font.Gotham
    NameInput.PlaceholderText = "Enter preset name..."
    NameInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    NameInput.Text = ""
    NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameInput.TextSize = 13
    NameInput.ClearTextOnFocus = false
    NameInput.Parent = SaveContent
    
    local NameCorner = Instance.new("UICorner")
    NameCorner.CornerRadius = UDim.new(0, 6)
    NameCorner.Parent = NameInput
    
    -- Description Input
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -20, 0, 20)
    DescLabel.Position = UDim2.new(0, 10, 0, 85)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Font = Enum.Font.GothamBold
    DescLabel.Text = "Description (Optional):"
    DescLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DescLabel.TextSize = 12
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = SaveContent
    
    local DescInput = Instance.new("TextBox")
    DescInput.Name = "DescInput"
    DescInput.Size = UDim2.new(1, -20, 0, 80)
    DescInput.Position = UDim2.new(0, 10, 0, 110)
    DescInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    DescInput.BorderSizePixel = 0
    DescInput.Font = Enum.Font.Gotham
    DescInput.PlaceholderText = "Enter description..."
    DescInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    DescInput.Text = ""
    DescInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    DescInput.TextSize = 12
    DescInput.TextWrapped = true
    DescInput.TextXAlignment = Enum.TextXAlignment.Left
    DescInput.TextYAlignment = Enum.TextYAlignment.Top
    DescInput.MultiLine = true
    DescInput.ClearTextOnFocus = false
    DescInput.Parent = SaveContent
    
    local DescCorner = Instance.new("UICorner")
    DescCorner.CornerRadius = UDim.new(0, 6)
    DescCorner.Parent = DescInput
    
    -- Author Input
    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Size = UDim2.new(1, -20, 0, 20)
    AuthorLabel.Position = UDim2.new(0, 10, 0, 200)
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Font = Enum.Font.GothamBold
    AuthorLabel.Text = "Author:"
    AuthorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AuthorLabel.TextSize = 12
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
    AuthorLabel.Parent = SaveContent
    
    local AuthorInput = Instance.new("TextBox")
    AuthorInput.Name = "AuthorInput"
    AuthorInput.Size = UDim2.new(1, -20, 0, 35)
    AuthorInput.Position = UDim2.new(0, 10, 0, 225)
    AuthorInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    AuthorInput.BorderSizePixel = 0
    AuthorInput.Font = Enum.Font.Gotham
    AuthorInput.Text = LocalPlayer.Name
    AuthorInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    AuthorInput.TextSize = 13
    AuthorInput.ClearTextOnFocus = false
    AuthorInput.Parent = SaveContent
    
    local AuthorCorner = Instance.new("UICorner")
    AuthorCorner.CornerRadius = UDim.new(0, 6)
    AuthorCorner.Parent = AuthorInput
    
    -- Save Button
    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Size = UDim2.new(0, 200, 0, 40)
    SaveButton.Position = UDim2.new(0.5, -100, 1, -55)
    SaveButton.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
    SaveButton.BorderSizePixel = 0
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.Text = "💾 SAVE PRESET"
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextSize = 13
    SaveButton.Parent = SaveContent
    
    local SaveBtnCorner = Instance.new("UICorner")
    SaveBtnCorner.CornerRadius = UDim.new(0, 6)
    SaveBtnCorner.Parent = SaveButton
    
    -- LOAD TAB CONTENT
    local LoadContent = Instance.new("Frame")
    LoadContent.Name = "LoadContent"
    LoadContent.Size = UDim2.new(1, 0, 1, 0)
    LoadContent.BackgroundTransparency = 1
    LoadContent.Visible = false
    LoadContent.Parent = ContentContainer
    
    local PresetList = Instance.new("ScrollingFrame")
    PresetList.Name = "PresetList"
    PresetList.Size = UDim2.new(1, -20, 1, -20)
    PresetList.Position = UDim2.new(0, 10, 0, 10)
    PresetList.BackgroundTransparency = 1
    PresetList.BorderSizePixel = 0
    PresetList.ScrollBarThickness = 6
    PresetList.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
    PresetList.Parent = LoadContent
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = PresetList
    
    -- IMPORT TAB CONTENT
    local ImportContent = Instance.new("Frame")
    ImportContent.Name = "ImportContent"
    ImportContent.Size = UDim2.new(1, 0, 1, 0)
    ImportContent.BackgroundTransparency = 1
    ImportContent.Visible = false
    ImportContent.Parent = ContentContainer
    
    local ImportLabel = Instance.new("TextLabel")
    ImportLabel.Size = UDim2.new(1, -20, 0, 60)
    ImportLabel.Position = UDim2.new(0, 10, 0, 15)
    ImportLabel.BackgroundTransparency = 1
    ImportLabel.Font = Enum.Font.Gotham
    ImportLabel.Text = "Paste a preset code below to import a configuration.\nYou can get codes from other players or by exporting your own presets."
    ImportLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    ImportLabel.TextSize = 11
    ImportLabel.TextWrapped = true
    ImportLabel.TextXAlignment = Enum.TextXAlignment.Left
    ImportLabel.TextYAlignment = Enum.TextYAlignment.Top
    ImportLabel.Parent = ImportContent
    
    local ImportBox = Instance.new("TextBox")
    ImportBox.Name = "ImportBox"
    ImportBox.Size = UDim2.new(1, -20, 1, -135)
    ImportBox.Position = UDim2.new(0, 10, 0, 80)
    ImportBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ImportBox.BorderSizePixel = 0
    ImportBox.Font = Enum.Font.Code
    ImportBox.PlaceholderText = "Paste preset code here..."
    ImportBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    ImportBox.Text = ""
    ImportBox.TextColor3 = Color3.fromRGB(150, 255, 150)
    ImportBox.TextSize = 11
    ImportBox.TextXAlignment = Enum.TextXAlignment.Left
    ImportBox.TextYAlignment = Enum.TextYAlignment.Top
    ImportBox.MultiLine = true
    ImportBox.ClearTextOnFocus = false
    ImportBox.Parent = ImportContent
    
    local ImportBoxCorner = Instance.new("UICorner")
    ImportBoxCorner.CornerRadius = UDim.new(0, 6)
    ImportBoxCorner.Parent = ImportBox
    
    local ImportButton = Instance.new("TextButton")
    ImportButton.Name = "ImportButton"
    ImportButton.Size = UDim2.new(0, 200, 0, 40)
    ImportButton.Position = UDim2.new(0.5, -100, 1, -50)
    ImportButton.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
    ImportButton.BorderSizePixel = 0
    ImportButton.Font = Enum.Font.GothamBold
    ImportButton.Text = "📥 IMPORT PRESET"
    ImportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ImportButton.TextSize = 13
    ImportButton.Parent = ImportContent
    
    local ImportBtnCorner = Instance.new("UICorner")
    ImportBtnCorner.CornerRadius = UDim.new(0, 6)
    ImportBtnCorner.Parent = ImportButton
    
    -- EXPORT TAB CONTENT
    local ExportContent = Instance.new("Frame")
    ExportContent.Name = "ExportContent"
    ExportContent.Size = UDim2.new(1, 0, 1, 0)
    ExportContent.BackgroundTransparency = 1
    ExportContent.Visible = false
    ExportContent.Parent = ContentContainer
    
    local ExportLabel = Instance.new("TextLabel")
    ExportLabel.Size = UDim2.new(1, -20, 0, 60)
    ExportLabel.Position = UDim2.new(0, 10, 0, 15)
    ExportLabel.BackgroundTransparency = 1
    ExportLabel.Font = Enum.Font.Gotham
    ExportLabel.Text = "Copy this code to share your current configuration.\nOthers can import it using the Import tab."
    ExportLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    ExportLabel.TextSize = 11
    ExportLabel.TextWrapped = true
    ExportLabel.TextXAlignment = Enum.TextXAlignment.Left
    ExportLabel.TextYAlignment = Enum.TextYAlignment.Top
    ExportLabel.Parent = ExportContent
    
    local ExportBox = Instance.new("TextBox")
    ExportBox.Name = "ExportBox"
    ExportBox.Size = UDim2.new(1, -20, 1, -135)
    ExportBox.Position = UDim2.new(0, 10, 0, 80)
    ExportBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ExportBox.BorderSizePixel = 0
    ExportBox.Font = Enum.Font.Code
    ExportBox.Text = ""
    ExportBox.TextColor3 = Color3.fromRGB(255, 200, 100)
    ExportBox.TextSize = 11
    ExportBox.TextXAlignment = Enum.TextXAlignment.Left
    ExportBox.TextYAlignment = Enum.TextYAlignment.Top
    ExportBox.TextEditable = false
    ExportBox.MultiLine = true
    ExportBox.ClearTextOnFocus = false
    ExportBox.Parent = ExportContent
    
    local ExportBoxCorner = Instance.new("UICorner")
    ExportBoxCorner.CornerRadius = UDim.new(0, 6)
    ExportBoxCorner.Parent = ExportBox
    
    local CopyButton = Instance.new("TextButton")
    CopyButton.Name = "CopyButton"
    CopyButton.Size = UDim2.new(0, 200, 0, 40)
    CopyButton.Position = UDim2.new(0.5, -100, 1, -50)
    CopyButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    CopyButton.BorderSizePixel = 0
    CopyButton.Font = Enum.Font.GothamBold
    CopyButton.Text = "📋 COPY TO CLIPBOARD"
    CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyButton.TextSize = 12
    CopyButton.Parent = ExportContent
    
    local CopyBtnCorner = Instance.new("UICorner")
    CopyBtnCorner.CornerRadius = UDim.new(0, 6)
    CopyBtnCorner.Parent = CopyButton
    
    return SaveLoadFrame, {
        SaveContent = SaveContent,
        LoadContent = LoadContent,
        ImportContent = ImportContent,
        ExportContent = ExportContent,
        SaveTab = SaveTab,
        LoadTab = LoadTab,
        ImportTab = ImportTab,
        ExportTab = ExportTab,
        NameInput = NameInput,
        DescInput = DescInput,
        AuthorInput = AuthorInput,
        SaveButton = SaveButton,
        PresetList = PresetList,
        ImportBox = ImportBox,
        ImportButton = ImportButton,
        ExportBox = ExportBox,
        CopyButton = CopyButton,
        CloseBtn = CloseBtn
    }
end

-- Save preset function
function PresetManager:SavePreset(name, description, author, values)
    local preset = {
        name = name,
        description = description or "",
        author = author or "Unknown",
        date = os.date("%Y-%m-%d %H:%M:%S"),
        values = values,
        version = "2.0"
    }
    
    table.insert(self.SavedPresets, preset)
    return preset
end

-- Generate export code
function PresetManager:GenerateExportCode(values, name, description, author)
    local preset = {
        n = name or "Unnamed",
        d = description or "",
        a = author or LocalPlayer.Name,
        t = os.time(),
        v = values
    }
    
    local json = HttpService:JSONEncode(preset)
    local base64 = self:Base64Encode(json)
    return "CDPRESET_" .. base64
end

-- Parse import code
function PresetManager:ParseImportCode(code)
    if not code:sub(1, 9) == "CDPRESET_" then
        return nil, "Invalid preset code format"
    end
    
    local base64 = code:sub(10)
    local json = self:Base64Decode(base64)
    
    local success, preset = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if not success then
        return nil, "Failed to decode preset"
    end
    
    return {
        name = preset.n,
        description = preset.d,
        author = preset.a,
        date = os.date("%Y-%m-%d %H:%M:%S", preset.t),
        values = preset.v,
        version = "2.0"
    }
end

-- Base64 encoding
function PresetManager:Base64Encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Base64 decoding
function PresetManager:Base64Decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Create preset list item
function PresetManager:CreatePresetListItem(preset, parent, onLoad, onDelete)
    local Item = Instance.new("Frame")
    Item.Size = UDim2.new(1, 0, 0, 90)
    Item.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Item.BorderSizePixel = 0
    Item.Parent = parent
    
    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 6)
    ItemCorner.Parent = Item
    
    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -150, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 8)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = preset.name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = Item
    
    -- Author & Date
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -150, 0, 15)
    InfoLabel.Position = UDim2.new(0, 10, 0, 28)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "by " .. preset.author .. " • " .. preset.date
    InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    InfoLabel.TextSize = 9
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.Parent = Item
    
    -- Description
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -150, 0, 35)
    DescLabel.Position = UDim2.new(0, 10, 0, 45)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.Text = preset.description
    DescLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    DescLabel.TextSize = 10
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextYAlignment = Enum.TextYAlignment.Top
    DescLabel.TextWrapped = true
    DescLabel.Parent = Item
    
    -- Load Button
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0, 70, 0, 30)
    LoadBtn.Position = UDim2.new(1, -135, 0.5, -15)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
    LoadBtn.BorderSizePixel = 0
    LoadBtn.Font = Enum.Font.GothamBold
    LoadBtn.Text = "LOAD"
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.TextSize = 11
    LoadBtn.Parent = Item
    
    local LoadCorner = Instance.new("UICorner")
    LoadCorner.CornerRadius = UDim.new(0, 5)
    LoadCorner.Parent = LoadBtn
    
    LoadBtn.MouseButton1Click:Connect(function()
        if onLoad then onLoad(preset) end
    end)
    
    -- Delete Button
    local DeleteBtn = Instance.new("TextButton")
    DeleteBtn.Size = UDim2.new(0, 55, 0, 30)
    DeleteBtn.Position = UDim2.new(1, -60, 0.5, -15)
    DeleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    DeleteBtn.BorderSizePixel = 0
    DeleteBtn.Font = Enum.Font.GothamBold
    DeleteBtn.Text = "✕"
    DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeleteBtn.TextSize = 14
    DeleteBtn.Parent = Item
    
    local DeleteCorner = Instance.new("UICorner")
    DeleteCorner.CornerRadius = UDim.new(0, 5)
    DeleteCorner.Parent = DeleteBtn
    
    DeleteBtn.MouseButton1Click:Connect(function()
        if onDelete then onDelete(preset) end
        Item:Destroy()
    end)
    
    return Item
end

return PresetManager
