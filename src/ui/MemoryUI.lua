--[[
    MemoryUI.lua
    Provides a beautiful interface for viewing and interacting with memories.
    Features:
    - Memory visualization with textures
    - Memory filtering
    - Memory sharing
    - Memory effects
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local MemoryUI = {}

-- Constants
MemoryUI.COLORS = {
    -- Main colors
    BACKGROUND = Color3.fromRGB(15, 15, 20),
    ACCENT = Color3.fromRGB(120, 200, 120),
    TEXT = Color3.fromRGB(240, 240, 245),
    HOVER = Color3.fromRGB(140, 220, 140),
    
    -- Category colors
    PERSONAL = Color3.fromRGB(100, 180, 255),
    SHARED = Color3.fromRGB(255, 180, 100),
    RITUAL = Color3.fromRGB(180, 100, 255),
    PLANT = Color3.fromRGB(100, 255, 180),
    
    -- Emotion colors
    JOY = Color3.fromRGB(255, 220, 100),
    PEACE = Color3.fromRGB(100, 220, 255),
    HOPE = Color3.fromRGB(180, 255, 100),
    GRIEF = Color3.fromRGB(255, 100, 180)
}

MemoryUI.FONTS = {
    TITLE = Enum.Font.GothamBold,
    SUBTITLE = Enum.Font.GothamSemibold,
    BODY = Enum.Font.Gotham
}

MemoryUI.TEXTURES = {
    BACKGROUND = "rbxassetid://9124908409", -- Subtle gradient texture
    CARD = "rbxassetid://9124908409", -- Card background texture
    BUTTON = "rbxassetid://9124908409", -- Button background texture
    GLOW = "rbxassetid://9124908409" -- Glow effect texture
}

-- Private variables
local memoryFrame = nil
local memoryList = nil
local selectedMemory = nil
local currentFilter = "All"

-- Private functions
local function createGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function createGlow(parent, color, size)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, size, 1, size)
    glow.Position = UDim2.new(0, -size/2, 0, -size/2)
    glow.BackgroundTransparency = 1
    glow.Image = MemoryUI.TEXTURES.GLOW
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.8
    glow.Parent = parent
    return glow
end

local function createMemoryCard(memory)
    local card = Instance.new("Frame")
    card.Name = "MemoryCard_" .. memory.id
    card.Size = UDim2.new(1, -20, 0, 100)
    card.Position = UDim2.new(0, 10, 0, 0)
    card.BackgroundColor3 = MemoryUI.COLORS.BACKGROUND
    card.BorderSizePixel = 0
    
    -- Add background texture
    local background = Instance.new("ImageLabel")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundTransparency = 1
    background.Image = MemoryUI.TEXTURES.CARD
    background.ImageColor3 = MemoryUI.COLORS.BACKGROUND
    background.ImageTransparency = 0.9
    background.Parent = card
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card
    
    -- Add glow effect
    local glowColor = MemoryUI.COLORS[memory.category:upper()] or MemoryUI.COLORS.ACCENT
    createGlow(card, glowColor, 10)
    
    -- Add memory title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = memory.title
    title.TextColor3 = MemoryUI.COLORS.TEXT
    title.TextSize = 18
    title.Font = MemoryUI.FONTS.TITLE
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card
    
    -- Add memory date
    local date = Instance.new("TextLabel")
    date.Name = "Date"
    date.Size = UDim2.new(1, -20, 0, 20)
    date.Position = UDim2.new(0, 10, 0, 40)
    date.BackgroundTransparency = 1
    date.Text = os.date("%Y-%m-%d %H:%M", memory.timestamp)
    date.TextColor3 = MemoryUI.COLORS.TEXT
    date.TextSize = 14
    date.Font = MemoryUI.FONTS.BODY
    date.TextXAlignment = Enum.TextXAlignment.Left
    date.Parent = card
    
    -- Add memory category
    local category = Instance.new("TextLabel")
    category.Name = "Category"
    category.Size = UDim2.new(0, 100, 0, 20)
    category.Position = UDim2.new(0, 10, 0, 70)
    category.BackgroundColor3 = MemoryUI.COLORS[memory.category:upper()] or MemoryUI.COLORS.ACCENT
    category.Text = memory.category
    category.TextColor3 = MemoryUI.COLORS.TEXT
    category.TextSize = 12
    category.Font = MemoryUI.FONTS.BODY
    
    -- Add corner radius to category
    local categoryCorner = Instance.new("UICorner")
    categoryCorner.CornerRadius = UDim.new(0, 4)
    categoryCorner.Parent = category
    
    -- Add gradient to category
    createGradient(category, category.BackgroundColor3, category.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2), 45)
    
    category.Parent = card
    
    -- Add hover effect
    local originalColor = card.BackgroundColor3
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.3), {
            BackgroundColor3 = MemoryUI.COLORS.HOVER
        }):Play()
        TweenService:Create(background, TweenInfo.new(0.3), {
            ImageTransparency = 0.8
        }):Play()
    end)
    
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.3), {
            BackgroundColor3 = originalColor
        }):Play()
        TweenService:Create(background, TweenInfo.new(0.3), {
            ImageTransparency = 0.9
        }):Play()
    end)
    
    -- Add click handler
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            MemoryUI.showMemoryDetails(memory)
        end
    end)
    
    return card
end

local function createMemoryDetails(memory)
    local details = Instance.new("Frame")
    details.Name = "MemoryDetails"
    details.Size = UDim2.new(0, 400, 0, 500)
    details.Position = UDim2.new(0.5, -200, 0.5, -250)
    details.BackgroundColor3 = MemoryUI.COLORS.BACKGROUND
    details.BorderSizePixel = 0
    
    -- Add background texture
    local background = Instance.new("ImageLabel")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundTransparency = 1
    background.Image = MemoryUI.TEXTURES.BACKGROUND
    background.ImageColor3 = MemoryUI.COLORS.BACKGROUND
    background.ImageTransparency = 0.9
    background.Parent = details
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = details
    
    -- Add glow effect
    local glowColor = MemoryUI.COLORS[memory.category:upper()] or MemoryUI.COLORS.ACCENT
    createGlow(details, glowColor, 20)
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = memory.title
    title.TextColor3 = MemoryUI.COLORS.TEXT
    title.TextSize = 24
    title.Font = MemoryUI.FONTS.TITLE
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = details
    
    -- Add date
    local date = Instance.new("TextLabel")
    date.Name = "Date"
    date.Size = UDim2.new(1, -40, 0, 20)
    date.Position = UDim2.new(0, 20, 0, 70)
    date.BackgroundTransparency = 1
    date.Text = os.date("%Y-%m-%d %H:%M", memory.timestamp)
    date.TextColor3 = MemoryUI.COLORS.TEXT
    date.TextSize = 16
    date.Font = MemoryUI.FONTS.BODY
    date.TextXAlignment = Enum.TextXAlignment.Left
    date.Parent = details
    
    -- Add description
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -40, 0, 100)
    description.Position = UDim2.new(0, 20, 0, 100)
    description.BackgroundTransparency = 1
    description.Text = memory.description
    description.TextColor3 = MemoryUI.COLORS.TEXT
    description.TextSize = 16
    description.Font = MemoryUI.FONTS.BODY
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextWrapped = true
    description.Parent = details
    
    -- Add emotions
    local emotions = Instance.new("Frame")
    emotions.Name = "Emotions"
    emotions.Size = UDim2.new(1, -40, 0, 100)
    emotions.Position = UDim2.new(0, 20, 0, 210)
    emotions.BackgroundTransparency = 1
    emotions.Parent = details
    
    local yOffset = 0
    for emotion, value in pairs(memory.emotions) do
        local emotionBar = Instance.new("Frame")
        emotionBar.Name = emotion
        emotionBar.Size = UDim2.new(1, 0, 0, 20)
        emotionBar.Position = UDim2.new(0, 0, 0, yOffset)
        emotionBar.BackgroundColor3 = MemoryUI.COLORS[emotion] or MemoryUI.COLORS.ACCENT
        emotionBar.BorderSizePixel = 0
        emotionBar.Parent = emotions
        
        -- Add corner radius
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 4)
        barCorner.Parent = emotionBar
        
        -- Add gradient
        createGradient(emotionBar, emotionBar.BackgroundColor3, emotionBar.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2), 45)
        
        -- Add emotion label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 100, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = emotion
        label.TextColor3 = MemoryUI.COLORS.TEXT
        label.TextSize = 14
        label.Font = MemoryUI.FONTS.BODY
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = emotionBar
        
        -- Add value label
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(0, 50, 1, 0)
        valueLabel.Position = UDim2.new(1, -60, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = string.format("%.0f%%", value * 100)
        valueLabel.TextColor3 = MemoryUI.COLORS.TEXT
        valueLabel.TextSize = 14
        valueLabel.Font = MemoryUI.FONTS.BODY
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = emotionBar
        
        -- Set bar width based on value
        emotionBar.Size = UDim2.new(value, 0, 0, 20)
        
        yOffset = yOffset + 30
    end
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 40)
    closeButton.Position = UDim2.new(0.5, -50, 1, -60)
    closeButton.BackgroundColor3 = MemoryUI.COLORS.ACCENT
    closeButton.Text = "Close"
    closeButton.TextColor3 = MemoryUI.COLORS.TEXT
    closeButton.TextSize = 16
    closeButton.Font = MemoryUI.FONTS.SUBTITLE
    closeButton.Parent = details
    
    -- Add corner radius to close button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = closeButton
    
    -- Add gradient to close button
    createGradient(closeButton, closeButton.BackgroundColor3, closeButton.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2), 45)
    
    -- Add hover effect
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.3), {
            BackgroundColor3 = MemoryUI.COLORS.HOVER
        }):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.3), {
            BackgroundColor3 = MemoryUI.COLORS.ACCENT
        }):Play()
    end)
    
    -- Add click handler
    closeButton.MouseButton1Click:Connect(function()
        details:Destroy()
        selectedMemory = nil
    end)
    
    return details
end

-- Public API
function MemoryUI.create()
    -- Create main frame
    memoryFrame = Instance.new("Frame")
    memoryFrame.Name = "MemoryUI"
    memoryFrame.Size = UDim2.new(0, 800, 0, 600)
    memoryFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    memoryFrame.BackgroundColor3 = MemoryUI.COLORS.BACKGROUND
    memoryFrame.BorderSizePixel = 0
    memoryFrame.Visible = false
    
    -- Add background texture
    local background = Instance.new("ImageLabel")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundTransparency = 1
    background.Image = MemoryUI.TEXTURES.BACKGROUND
    background.ImageColor3 = MemoryUI.COLORS.BACKGROUND
    background.ImageTransparency = 0.9
    background.Parent = memoryFrame
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = memoryFrame
    
    -- Add glow effect
    createGlow(memoryFrame, MemoryUI.COLORS.ACCENT, 30)
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Memories"
    title.TextColor3 = MemoryUI.COLORS.TEXT
    title.TextSize = 32
    title.Font = MemoryUI.FONTS.TITLE
    title.Parent = memoryFrame
    
    -- Add filter buttons
    local filters = {"All", "Personal", "Shared", "Ritual", "Plant"}
    local xOffset = 20
    for _, filter in ipairs(filters) do
        local button = Instance.new("TextButton")
        button.Name = filter .. "Filter"
        button.Size = UDim2.new(0, 100, 0, 30)
        button.Position = UDim2.new(0, xOffset, 0, 80)
        button.BackgroundColor3 = MemoryUI.COLORS[filter:upper()] or MemoryUI.COLORS.ACCENT
        button.Text = filter
        button.TextColor3 = MemoryUI.COLORS.TEXT
        button.TextSize = 14
        button.Font = MemoryUI.FONTS.BODY
        button.Parent = memoryFrame
        
        -- Add corner radius
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        -- Add gradient
        createGradient(button, button.BackgroundColor3, button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2), 45)
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = MemoryUI.COLORS.HOVER
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = MemoryUI.COLORS[filter:upper()] or MemoryUI.COLORS.ACCENT
            }):Play()
        end)
        
        -- Add click handler
        button.MouseButton1Click:Connect(function()
            currentFilter = filter
            MemoryUI.refreshMemories()
        end)
        
        xOffset = xOffset + 120
    end
    
    -- Create memory list
    memoryList = Instance.new("ScrollingFrame")
    memoryList.Name = "MemoryList"
    memoryList.Size = UDim2.new(1, -40, 1, -140)
    memoryList.Position = UDim2.new(0, 20, 0, 120)
    memoryList.BackgroundTransparency = 1
    memoryList.BorderSizePixel = 0
    memoryList.ScrollBarThickness = 6
    memoryList.ScrollingDirection = Enum.ScrollingDirection.Y
    memoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
    memoryList.Parent = memoryFrame
    
    -- Add UIListLayout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = memoryList
    
    memoryFrame.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

function MemoryUI.show()
    if not memoryFrame then
        MemoryUI.create()
    end
    memoryFrame.Visible = true
    MemoryUI.refreshMemories()
end

function MemoryUI.hide()
    if memoryFrame then
        memoryFrame.Visible = false
    end
end

function MemoryUI.refreshMemories()
    if not memoryList then return end
    
    -- Clear existing memories
    for _, child in ipairs(memoryList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Get memories from MemorySystem
    local memories = ReplicatedStorage.Events.GetMemories:InvokeServer()
    
    -- Filter memories
    local filteredMemories = {}
    for _, memory in ipairs(memories) do
        if currentFilter == "All" or memory.category == currentFilter then
            table.insert(filteredMemories, memory)
        end
    end
    
    -- Sort memories by timestamp (newest first)
    table.sort(filteredMemories, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    -- Create memory cards
    local yOffset = 0
    for _, memory in ipairs(filteredMemories) do
        local card = createMemoryCard(memory)
        card.Position = UDim2.new(0, 0, 0, yOffset)
        card.Parent = memoryList
        yOffset = yOffset + 110
    end
    
    -- Update canvas size
    memoryList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

function MemoryUI.showMemoryDetails(memory)
    if selectedMemory then
        selectedMemory:Destroy()
    end
    
    selectedMemory = createMemoryDetails(memory)
    selectedMemory.Parent = memoryFrame
end

return MemoryUI 