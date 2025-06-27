--[[
    SettingsUI.lua
    Settings interface for NeuroBloom
    
    Features:
    - Audio settings
    - Visual settings
    - Accessibility options
    - Save/Load preferences
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constants
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 20),
    ACCENT = Color3.fromRGB(100, 200, 100),
    TEXT = Color3.fromRGB(255, 255, 255),
    SLIDER_BG = Color3.fromRGB(40, 40, 40),
    SLIDER_FILL = Color3.fromRGB(100, 200, 100)
}

local FONTS = {
    TITLE = Enum.Font.GothamBold,
    BODY = Enum.Font.GothamMedium
}

-- Private variables
local settingsUI = nil
local currentSettings = {
    masterVolume = 1,
    musicVolume = 0.8,
    sfxVolume = 0.8,
    ambientVolume = 0.8,
    bloomEnabled = true,
    particleEffects = true,
    colorBlindMode = false,
    highContrast = false
}

-- Private functions
local function createSlider(name, value, position)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -40, 0, 40)
    container.Position = position
    container.BackgroundTransparency = 1
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT
    label.TextSize = 16
    label.Font = FONTS.BODY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Slider background
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.6, 0, 0, 4)
    slider.Position = UDim2.new(0.35, 0, 0.5, 0)
    slider.AnchorPoint = Vector2.new(0, 0.5)
    slider.BackgroundColor3 = COLORS.SLIDER_BG
    slider.BorderSizePixel = 0
    slider.Parent = container
    
    -- Slider fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(value, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.SLIDER_FILL
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    -- Slider handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(value, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = COLORS.ACCENT
    handle.BorderSizePixel = 0
    handle.Parent = slider
    
    -- Add corner radius to handle
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = handle
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.1, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.95, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(value * 100)) .. "%"
    valueLabel.TextColor3 = COLORS.TEXT
    valueLabel.TextSize = 16
    valueLabel.Font = FONTS.BODY
    valueLabel.Parent = container
    
    return container, slider, handle, valueLabel
end

local function createToggle(name, value, position)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -40, 0, 40)
    container.Position = position
    container.BackgroundTransparency = 1
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT
    label.TextSize = 16
    label.Font = FONTS.BODY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Toggle background
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(0.9, 0, 0.5, 0)
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.BackgroundColor3 = value and COLORS.SLIDER_FILL or COLORS.SLIDER_BG
    toggle.BorderSizePixel = 0
    toggle.Parent = container
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggle
    
    -- Toggle handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(value and 1 or 0, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(value and 1 or 0, 0.5)
    handle.BackgroundColor3 = COLORS.ACCENT
    handle.BorderSizePixel = 0
    handle.Parent = toggle
    
    -- Add corner radius
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    return container, toggle, handle
end

local function createSettingsFrame()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 600)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = COLORS.BACKGROUND
    frame.BorderSizePixel = 0
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Settings"
    title.TextColor3 = COLORS.TEXT
    title.TextSize = 24
    title.Font = FONTS.TITLE
    title.Parent = frame
    
    -- Audio settings
    local audioTitle = Instance.new("TextLabel")
    audioTitle.Size = UDim2.new(1, -40, 0, 30)
    audioTitle.Position = UDim2.new(0, 20, 0, 60)
    audioTitle.BackgroundTransparency = 1
    audioTitle.Text = "Audio"
    audioTitle.TextColor3 = COLORS.TEXT
    audioTitle.TextSize = 18
    audioTitle.Font = FONTS.BODY
    audioTitle.Parent = frame
    
    -- Create audio sliders
    local masterSlider, masterSliderBg, masterHandle, masterValue = createSlider(
        "Master Volume",
        currentSettings.masterVolume,
        UDim2.new(0, 20, 0, 100)
    )
    masterSlider.Parent = frame
    
    local musicSlider, musicSliderBg, musicHandle, musicValue = createSlider(
        "Music Volume",
        currentSettings.musicVolume,
        UDim2.new(0, 20, 0, 150)
    )
    musicSlider.Parent = frame
    
    local sfxSlider, sfxSliderBg, sfxHandle, sfxValue = createSlider(
        "SFX Volume",
        currentSettings.sfxVolume,
        UDim2.new(0, 20, 0, 200)
    )
    sfxSlider.Parent = frame
    
    local ambientSlider, ambientSliderBg, ambientHandle, ambientValue = createSlider(
        "Ambient Volume",
        currentSettings.ambientVolume,
        UDim2.new(0, 20, 0, 250)
    )
    ambientSlider.Parent = frame
    
    -- Visual settings
    local visualTitle = Instance.new("TextLabel")
    visualTitle.Size = UDim2.new(1, -40, 0, 30)
    visualTitle.Position = UDim2.new(0, 20, 0, 310)
    visualTitle.BackgroundTransparency = 1
    visualTitle.Text = "Visual"
    visualTitle.TextColor3 = COLORS.TEXT
    visualTitle.TextSize = 18
    visualTitle.Font = FONTS.BODY
    visualTitle.Parent = frame
    
    -- Create visual toggles
    local bloomToggle, bloomToggleBg, bloomHandle = createToggle(
        "Bloom Effects",
        currentSettings.bloomEnabled,
        UDim2.new(0, 20, 0, 350)
    )
    bloomToggle.Parent = frame
    
    local particleToggle, particleToggleBg, particleHandle = createToggle(
        "Particle Effects",
        currentSettings.particleEffects,
        UDim2.new(0, 20, 0, 400)
    )
    particleToggle.Parent = frame
    
    -- Accessibility settings
    local accessibilityTitle = Instance.new("TextLabel")
    accessibilityTitle.Size = UDim2.new(1, -40, 0, 30)
    accessibilityTitle.Position = UDim2.new(0, 20, 0, 460)
    accessibilityTitle.BackgroundTransparency = 1
    accessibilityTitle.Text = "Accessibility"
    accessibilityTitle.TextColor3 = COLORS.TEXT
    accessibilityTitle.TextSize = 18
    accessibilityTitle.Font = FONTS.BODY
    accessibilityTitle.Parent = frame
    
    -- Create accessibility toggles
    local colorBlindToggle, colorBlindToggleBg, colorBlindHandle = createToggle(
        "Color Blind Mode",
        currentSettings.colorBlindMode,
        UDim2.new(0, 20, 0, 500)
    )
    colorBlindToggle.Parent = frame
    
    local contrastToggle, contrastToggleBg, contrastHandle = createToggle(
        "High Contrast",
        currentSettings.highContrast,
        UDim2.new(0, 20, 0, 550)
    )
    contrastToggle.Parent = frame
    
    return frame
end

-- Public API
local SettingsUI = {}

function SettingsUI.createSettingsUI()
    if settingsUI then return end
    
    -- Create screen gui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SettingsUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    settingsUI = gui
end

function SettingsUI.showSettings()
    if not settingsUI then return end
    
    -- Create settings frame
    local frame = createSettingsFrame()
    frame.Parent = settingsUI
    
    -- Show UI
    settingsUI.Enabled = true
end

function SettingsUI.hideSettings()
    if not settingsUI then return end
    
    -- Hide UI
    settingsUI.Enabled = false
    
    -- Clear settings frame
    for _, child in ipairs(settingsUI:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

function SettingsUI.getSettings()
    return currentSettings
end

return SettingsUI 