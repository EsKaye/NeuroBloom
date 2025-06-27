--[[
    init.server.lua
    Main server initialization script for NeuroBloom
    
    Features:
    - Module loading
    - Service setup
    - Environment configuration
    - Event handling
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load modules
local PlantVisuals = require(script.Parent.PlantVisuals)
local SoundSystem = require(script.Parent.SoundSystem)
local GardenRituals = require(script.Parent.GardenRituals)
local GardenScene = require(script.Parent.GardenScene)
local PlantMutationSystem = require(script.Parent.PlantMutationSystem)
local CrossPollinationSystem = require(script.Parent.CrossPollinationSystem)
local PlantDiseaseSystem = require(script.Parent.PlantDiseaseSystem)

-- Create Events folder
local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

-- Create remote events
local function createRemoteEvent(name)
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = Events
    return event
end

local remoteEvents = {
    StartRitual = createRemoteEvent("StartRitual"),
    UpdateEmotions = createRemoteEvent("UpdateEmotions"),
    CompleteRitual = createRemoteEvent("CompleteRitual"),
    CreatePlant = createRemoteEvent("CreatePlant"),
    GrowPlant = createRemoteEvent("GrowPlant"),
    AttemptPollination = createRemoteEvent("AttemptPollination"),
    TreatDisease = createRemoteEvent("TreatDisease")
}

-- Initialize systems
local function initSystems()
    PlantVisuals.init()
    SoundSystem.init()
    GardenRituals.init()
    GardenScene.init()
    PlantMutationSystem.init()
    CrossPollinationSystem.init()
    PlantDiseaseSystem.init()
end

-- Player data management
local playerData = {}

local function initPlayerData(player)
    playerData[player.UserId] = {
        emotions = {
            joy = 0,
            peace = 0,
            hope = 0,
            grief = 0
        },
        rituals = {},
        plants = {},
        lastUpdate = os.time()
    }
end

-- Event handlers
remoteEvents.StartRitual.OnServerEvent:Connect(function(player, ritualType)
    local data = playerData[player.UserId]
    if not data then return end
    
    local ritual = GardenRituals.startRitual(ritualType, data.emotions)
    if ritual then
        data.rituals[ritual.id] = ritual
    end
end)

remoteEvents.UpdateEmotions.OnServerEvent:Connect(function(player, emotions)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.emotions = emotions
    data.lastUpdate = os.time()
    
    -- Update plants
    for _, plant in pairs(data.plants) do
        -- Check for mutations
        PlantMutationSystem.checkForMutation(plant, emotions)
        
        -- Update plant health
        PlantDiseaseSystem.updatePlantHealth(plant.id, os.time() - data.lastUpdate)
    end
end)

remoteEvents.CompleteRitual.OnServerEvent:Connect(function(player, ritualId)
    local data = playerData[player.UserId]
    if not data or not data.rituals[ritualId] then return end
    
    local ritual = data.rituals[ritualId]
    local success = GardenRituals.completeRitual(ritualId, data.emotions)
    
    if success then
        data.rituals[ritualId] = nil
    end
end)

remoteEvents.CreatePlant.OnServerEvent:Connect(function(player, plantType)
    local data = playerData[player.UserId]
    if not data then return end
    
    local plant = PlantVisuals.createPlant(plantType, data.emotions)
    if plant then
        data.plants[plant.id] = plant
    end
end)

remoteEvents.GrowPlant.OnServerEvent:Connect(function(player, plantId)
    local data = playerData[player.UserId]
    if not data or not data.plants[plantId] then return end
    
    local plant = data.plants[plantId]
    PlantVisuals.growPlant(plant, data.emotions)
end)

remoteEvents.AttemptPollination.OnServerEvent:Connect(function(player, plant1Id, plant2Id, pollinationType)
    local data = playerData[player.UserId]
    if not data or not data.plants[plant1Id] or not data.plants[plant2Id] then return end
    
    local result = CrossPollinationSystem.attemptPollination(
        data.plants[plant1Id],
        data.plants[plant2Id],
        pollinationType
    )
    
    if result and result.success then
        data.plants[result.hybrid.id] = result.hybrid
    end
end)

remoteEvents.TreatDisease.OnServerEvent:Connect(function(player, plantId, treatment)
    local data = playerData[player.UserId]
    if not data or not data.plants[plantId] then return end
    
    PlantDiseaseSystem.treatDisease(plantId, treatment)
end)

-- Player events
game.Players.PlayerAdded:Connect(function(player)
    initPlayerData(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
    playerData[player.UserId] = nil
end)

-- Initialize
local function init()
    initSystems()
    print("NeuroBloom server initialized")
end

init() 