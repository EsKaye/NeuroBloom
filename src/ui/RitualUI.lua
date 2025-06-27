--[[
    RitualUI.lua
    Ritual interface for NeuroBloom
    
    Features:
    - Beautiful ritual animations
    - Progress tracking
    - Emotional input
    - Visual feedback
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constants
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 20),
    ACCENT = Color3.fromRGB(100, 200, 100),
    TEXT = Color3.fromRGB(255, 255, 255),
    PROGRESS_BG = Color3.fromRGB(40, 40, 40),
    PROGRESS_FILL = Color3.fromRGB(100, 200, 100)
}

local FONTS = {
    TITLE = Enum.Font.GothamBold,
    BODY = Enum.Font.GothamMedium
}

-- Private variables
local ritualUI = nil
local currentRitual = nil

-- Private functions
local function createRitualFrame(ritualType)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 500)
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
    title.Text = ritualType .. " Ritual"
    title.TextColor3 = COLORS.TEXT
    title.TextSize = 24
    title.Font = FONTS.TITLE
    title.Parent = frame
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, -40, 0, 20)
    progressBar.Position = UDim2.new(0, 20, 0, 70)
    progressBar.BackgroundColor3 = COLORS.PROGRESS_BG
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = COLORS.PROGRESS_FILL
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    -- Instructions
    local instructions = Instance.new("TextLabel")
    instructions.Size = UDim2.new(1, -40, 0, 100)
    instructions.Position = UDim2.new(0, 20, 0, 100)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Follow the rhythm of your breath..."
    instructions.TextColor3 = COLORS.TEXT
    instructions.TextSize = 16
    instructions.Font = FONTS.BODY
    instructions.TextWrapped = true
    instructions.Parent = frame
    
    -- Emotion input
    local emotions = {
        "Joy",
        "Peace",
        "Hope",
        "Grief",
        "Fear",
        "Anger"
    }
    
    local emotionButtons = {}
    for i, emotion in ipairs(emotions) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 100, 0, 40)
        button.Position = UDim2.new(0, 20 + (i-1) * 110, 0, 220)
        button.BackgroundColor3 = COLORS.PROGRESS_BG
        button.BorderSizePixel = 0
        button.Text = emotion
        button.TextColor3 = COLORS.TEXT
        button.TextSize = 16
        button.Font = FONTS.BODY
        button.Parent = frame
        
        -- Add corner radius
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = COLORS.ACCENT
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = COLORS.PROGRESS_BG
            }):Play()
        end)
        
        emotionButtons[emotion] = button
    end
    
    -- Complete button
    local completeButton = Instance.new("TextButton")
    completeButton.Size = UDim2.new(0, 200, 0, 50)
    completeButton.Position = UDim2.new(0.5, 0, 1, -70)
    completeButton.AnchorPoint = Vector2.new(0.5, 0)
    completeButton.BackgroundColor3 = COLORS.ACCENT
    completeButton.BorderSizePixel = 0
    completeButton.Text = "Complete Ritual"
    completeButton.TextColor3 = COLORS.TEXT
    completeButton.TextSize = 18
    completeButton.Font = FONTS.BODY
    completeButton.Parent = frame
    
    -- Add corner radius
    local completeCorner = Instance.new("UICorner")
    completeCorner.CornerRadius = UDim.new(0, 4)
    completeCorner.Parent = completeButton
    
    return frame
end

-- Public API
local RitualUI = {}

function RitualUI.createRitualUI()
    if ritualUI then return end
    
    -- Create screen gui
    local gui = Instance.new("ScreenGui")
    gui.Name = "RitualUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    ritualUI = gui
end

function RitualUI.startRitual(ritualType)
    if not ritualUI then return end
    
    -- Create ritual frame
    local frame = createRitualFrame(ritualType)
    frame.Parent = ritualUI
    
    -- Show UI
    ritualUI.Enabled = true
    currentRitual = ritualType
end

function RitualUI.updateProgress(progress)
    if not ritualUI or not currentRitual then return end
    
    -- Update progress bar
    local progressBar = ritualUI:FindFirstChild("ProgressBar")
    if progressBar then
        local fill = progressBar:FindFirstChild("ProgressFill")
        if fill then
            TweenService:Create(fill, TweenInfo.new(0.3), {
                Size = UDim2.new(progress, 0, 1, 0)
            }):Play()
        end
    end
end

function RitualUI.completeRitual()
    if not ritualUI or not currentRitual then return end
    
    -- Hide UI
    ritualUI.Enabled = false
    currentRitual = nil
    
    -- Clear ritual frame
    for _, child in ipairs(ritualUI:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

return RitualUI 