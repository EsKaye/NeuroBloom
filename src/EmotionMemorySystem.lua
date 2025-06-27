--[[
    EmotionMemorySystem.lua
    Manages player emotional states and memory persistence in NeuroBloom
    
    Features:
    - Emotional state tracking
    - Memory fragment system
    - DataStore integration
    - Garden state synchronization
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local EmotionMemorySystem = {}

-- Constants
local DATASTORE_KEY = "NeuroBloom_PlayerData"
local MAX_MEMORIES = 100
local EMOTION_COOLDOWN = 60 -- seconds

-- Private variables
local playerData = {}
local emotionCooldowns = {}

-- Private functions
local function createDefaultPlayerData()
    return {
        memories = {},
        emotions = {},
        gardenState = {
            plants = {},
            biomes = {},
            lastVisit = os.time()
        },
        rituals = {
            completed = {},
            streak = 0
        }
    }
end

local function savePlayerData(player)
    local success, err = pcall(function()
        local dataStore = DataStoreService:GetDataStore(DATASTORE_KEY)
        dataStore:SetAsync(player.UserId, playerData[player.UserId])
    end)
    
    if not success then
        warn("Failed to save player data:", err)
    end
end

local function loadPlayerData(player)
    local success, data = pcall(function()
        local dataStore = DataStoreService:GetDataStore(DATASTORE_KEY)
        return dataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        playerData[player.UserId] = data
    else
        playerData[player.UserId] = createDefaultPlayerData()
    end
end

local function canRecordEmotion(player)
    local lastEmotion = emotionCooldowns[player.UserId]
    if not lastEmotion then return true end
    
    return (os.time() - lastEmotion) >= EMOTION_COOLDOWN
end

-- Public API
function EmotionMemorySystem.Initialize()
    Players.PlayerAdded:Connect(function(player)
        loadPlayerData(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        savePlayerData(player)
        playerData[player.UserId] = nil
        emotionCooldowns[player.UserId] = nil
    end)
    
    -- Auto-save every 5 minutes
    while true do
        wait(300)
        for _, player in ipairs(Players:GetPlayers()) do
            savePlayerData(player)
        end
    end
end

function EmotionMemorySystem.RecordEmotion(player, emotion, intensity)
    if not canRecordEmotion(player) then
        return false, "Emotion cooldown active"
    end
    
    local data = playerData[player.UserId]
    if not data then return false, "Player data not found" end
    
    table.insert(data.emotions, {
        type = emotion,
        intensity = intensity,
        timestamp = os.time()
    })
    
    emotionCooldowns[player.UserId] = os.time()
    return true
end

function EmotionMemorySystem.AddMemory(player, memory)
    local data = playerData[player.UserId]
    if not data then return false, "Player data not found" end
    
    if #data.memories >= MAX_MEMORIES then
        table.remove(data.memories, 1)
    end
    
    table.insert(data.memories, {
        content = memory,
        timestamp = os.time()
    })
    
    return true
end

function EmotionMemorySystem.GetPlayerData(player)
    return playerData[player.UserId]
end

function EmotionMemorySystem.UpdateGardenState(player, state)
    local data = playerData[player.UserId]
    if not data then return false, "Player data not found" end
    
    data.gardenState = state
    return true
end

function EmotionMemorySystem.CompleteRitual(player, ritualId)
    local data = playerData[player.UserId]
    if not data then return false, "Player data not found" end
    
    table.insert(data.rituals.completed, {
        id = ritualId,
        timestamp = os.time()
    })
    
    data.rituals.streak = data.rituals.streak + 1
    return true
end

return EmotionMemorySystem 