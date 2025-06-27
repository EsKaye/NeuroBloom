--[[
    init.client.lua
    Main client initialization script for NeuroBloom
    
    Features:
    - UI management
    - Event handling
    - Player state
    - Visual effects
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load UI modules
local MainMenu = require(script.Parent.Parent.ui.MainMenu)
local RitualUI = require(script.Parent.Parent.ui.RitualUI)
local SettingsUI = require(script.Parent.Parent.ui.SettingsUI)
local MemoryUI = require(script.Parent.Parent.ui.MemoryUI)

-- Get remote events
local Events = ReplicatedStorage:WaitForChild("Events")
local remoteEvents = {
    StartRitual = Events:WaitForChild("StartRitual"),
    UpdateEmotions = Events:WaitForChild("UpdateEmotions"),
    CompleteRitual = Events:WaitForChild("CompleteRitual"),
    CreatePlant = Events:WaitForChild("CreatePlant"),
    GrowPlant = Events:WaitForChild("GrowPlant"),
    AttemptPollination = Events:WaitForChild("AttemptPollination"),
    TreatDisease = Events:WaitForChild("TreatDisease")
}

-- Player state
local playerState = {
    emotions = {
        joy = 0,
        peace = 0,
        hope = 0,
        grief = 0
    },
    activeRitual = nil,
    selectedPlants = {},
    lastUpdate = os.time()
}

-- UI state
local uiState = {
    mainMenu = nil,
    ritualUI = nil,
    settingsUI = nil,
    memoryUI = nil
}

-- Initialize UI
local function initUI()
    -- Create main menu
    uiState.mainMenu = MainMenu.create()
    uiState.mainMenu.Visible = true
    
    -- Create ritual UI
    uiState.ritualUI = RitualUI.create()
    uiState.ritualUI.Visible = false
    
    -- Create settings UI
    uiState.settingsUI = SettingsUI.create()
    uiState.settingsUI.Visible = false
    
    -- Create memory UI
    uiState.memoryUI = MemoryUI.create()
    uiState.memoryUI.Visible = false
end

-- Event handlers
local function onStartRitual(ritualType)
    if playerState.activeRitual then return end
    
    remoteEvents.StartRitual:FireServer(ritualType)
    playerState.activeRitual = ritualType
    
    -- Show ritual UI
    uiState.ritualUI.Visible = true
    RitualUI.startRitual(ritualType)
end

local function onUpdateEmotions(emotions)
    playerState.emotions = emotions
    playerState.lastUpdate = os.time()
    
    -- Update UI
    if uiState.ritualUI.Visible then
        RitualUI.updateEmotions(emotions)
    end
    
    -- Send to server
    remoteEvents.UpdateEmotions:FireServer(emotions)
end

local function onCompleteRitual()
    if not playerState.activeRitual then return end
    
    remoteEvents.CompleteRitual:FireServer(playerState.activeRitual)
    playerState.activeRitual = nil
    
    -- Hide ritual UI
    uiState.ritualUI.Visible = false
end

local function onCreatePlant(plantType)
    remoteEvents.CreatePlant:FireServer(plantType)
end

local function onGrowPlant(plantId)
    remoteEvents.GrowPlant:FireServer(plantId)
end

local function onAttemptPollination(plant1Id, plant2Id, pollinationType)
    remoteEvents.AttemptPollination:FireServer(plant1Id, plant2Id, pollinationType)
end

local function onTreatDisease(plantId, treatment)
    remoteEvents.TreatDisease:FireServer(plantId, treatment)
end

-- UI event connections
MainMenu.onRitualStart = onStartRitual
MainMenu.onPlantCreate = onCreatePlant
MainMenu.onSettingsOpen = function()
    uiState.settingsUI.Visible = true
end
MainMenu.onMemoryOpen = function()
    uiState.memoryUI.Visible = true
end

RitualUI.onComplete = onCompleteRitual
RitualUI.onEmotionUpdate = onUpdateEmotions

SettingsUI.onClose = function()
    uiState.settingsUI.Visible = false
end

MemoryUI.onClose = function()
    uiState.memoryUI.Visible = false
end

-- Character events
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Reset player state
    playerState.activeRitual = nil
    playerState.selectedPlants = {}
    
    -- Update UI
    if uiState.ritualUI.Visible then
        uiState.ritualUI.Visible = false
    end
end)

-- Initialize
local function init()
    initUI()
    print("NeuroBloom client initialized")
end

init() 