--[[
    MainMenu.lua
    Main menu interface for NeuroBloom
    
    Features:
    - Beautiful main menu
    - Garden entry
    - Memory viewing
    - Settings access
    - Daily rituals
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constants
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 20),
    ACCENT = Color3.fromRGB(100, 200, 100),
    TEXT = Color3.fromRGB(255, 255, 255),
    BUTTON_BG = Color3.fromRGB(40, 40, 40),
    BUTTON_HOVER = Color3.fromRGB(60, 60, 60)
}

local FONTS = {
    TITLE = Enum.Font.GothamBold,
    BODY = Enum.Font.GothamMedium
}

-- Private variables
local mainMenu = nil

-- Private functions
local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = position
    button.BackgroundColor3 = COLORS.BUTTON_BG
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.TextSize = 18
    button.Font = FONTS.BODY
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.BUTTON_HOVER
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.BUTTON_BG
        }):Play()
    end)
    
    -- Click handler
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Public API
local MainMenu = {}

function MainMenu.createMainMenu()
    if mainMenu then return end
    
    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = COLORS.BACKGROUND
    frame.BorderSizePixel = 0
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 400, 0, 100)
    title.Position = UDim2.new(0.5, 0, 0.2, 0)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "NeuroBloom"
    title.TextColor3 = COLORS.TEXT
    title.TextSize = 48
    title.Font = FONTS.TITLE
    title.Parent = frame
    
    -- Create subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 400, 0, 30)
    subtitle.Position = UDim2.new(0.5, 0, 0.3, 0)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Cultivate Your Emotional Garden"
    subtitle.TextColor3 = COLORS.TEXT
    subtitle.TextSize = 18
    subtitle.Font = FONTS.BODY
    subtitle.Parent = frame
    
    -- Create buttons
    local buttons = {
        {
            text = "Enter Garden",
            position = UDim2.new(0.5, 0, 0.5, 0),
            callback = function()
                -- TODO: Implement garden entry
                print("Entering garden...")
            end
        },
        {
            text = "View Memories",
            position = UDim2.new(0.5, 0, 0.6, 0),
            callback = function()
                -- TODO: Implement memory viewing
                print("Viewing memories...")
            end
        },
        {
            text = "Daily Ritual",
            position = UDim2.new(0.5, 0, 0.7, 0),
            callback = function()
                -- TODO: Implement ritual start
                print("Starting ritual...")
            end
        },
        {
            text = "Settings",
            position = UDim2.new(0.5, 0, 0.8, 0),
            callback = function()
                -- TODO: Show settings
                print("Opening settings...")
            end
        }
    }
    
    for _, buttonData in ipairs(buttons) do
        local button = createButton(
            buttonData.text,
            buttonData.position,
            buttonData.callback
        )
        button.Parent = frame
    end
    
    -- Create screen gui
    local gui = Instance.new("ScreenGui")
    gui.Name = "MainMenu"
    gui.ResetOnSpawn = false
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    frame.Parent = gui
    mainMenu = gui
end

function MainMenu.show()
    if mainMenu then
        mainMenu.Enabled = true
    end
end

function MainMenu.hide()
    if mainMenu then
        mainMenu.Enabled = false
    end
end

return MainMenu 