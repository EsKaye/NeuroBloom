--[[
    GardenRituals.lua
    Ritual management system for NeuroBloom
    
    Features:
    - Daily rituals
    - Emotional ceremonies
    - Growth celebrations
    - Memory preservation
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constants
local RITUAL_TYPES = {
    DAILY = {
        name = "Daily Reflection",
        duration = 300, -- 5 minutes
        emotions = {"JOY", "PEACE", "HOPE", "GRIEF"},
        rewards = {
            experience = 100,
            memoryPoints = 50
        }
    },
    GROWTH = {
        name = "Growth Celebration",
        duration = 600, -- 10 minutes
        emotions = {"JOY", "HOPE"},
        rewards = {
            experience = 200,
            memoryPoints = 100
        }
    },
    HEALING = {
        name = "Healing Ceremony",
        duration = 900, -- 15 minutes
        emotions = {"PEACE", "GRIEF"},
        rewards = {
            experience = 150,
            memoryPoints = 75
        }
    }
}

local EMOTION_WEIGHTS = {
    JOY = 1.2,
    PEACE = 1.0,
    HOPE = 1.1,
    GRIEF = 0.9
}

-- Private variables
local activeRituals = {}
local ritualHistory = {}

-- Private functions
local function calculateRitualSuccess(emotions, ritualType)
    local totalWeight = 0
    local totalEmotions = 0
    
    for _, emotion in ipairs(RITUAL_TYPES[ritualType].emotions) do
        totalWeight = totalWeight + (emotions[emotion] or 0) * (EMOTION_WEIGHTS[emotion] or 1)
        totalEmotions = totalEmotions + 1
    end
    
    return totalWeight / totalEmotions
end

local function generateRitualMemory(ritualType, emotions, success)
    return {
        type = ritualType,
        emotions = emotions,
        success = success,
        timestamp = os.time(),
        rewards = RITUAL_TYPES[ritualType].rewards
    }
end

local function startRitualTimer(ritualId, duration, callback)
    task.delay(duration, function()
        if activeRituals[ritualId] then
            callback()
        end
    end)
end

-- Public API
local GardenRituals = {}

function GardenRituals.startRitual(ritualType, player)
    if not RITUAL_TYPES[ritualType] then return nil end
    
    local ritualId = player.UserId .. "_" .. os.time()
    local ritual = {
        type = ritualType,
        player = player,
        startTime = os.time(),
        emotions = {},
        progress = 0
    }
    
    activeRituals[ritualId] = ritual
    
    -- Start ritual timer
    startRitualTimer(ritualId, RITUAL_TYPES[ritualType].duration, function()
        GardenRituals.completeRitual(ritualId)
    end)
    
    return ritualId
end

function GardenRituals.updateRitualEmotions(ritualId, emotions)
    local ritual = activeRituals[ritualId]
    if not ritual then return end
    
    ritual.emotions = emotions
    ritual.progress = calculateRitualSuccess(emotions, ritual.type)
end

function GardenRituals.completeRitual(ritualId)
    local ritual = activeRituals[ritualId]
    if not ritual then return end
    
    local success = calculateRitualSuccess(ritual.emotions, ritual.type)
    local memory = generateRitualMemory(ritual.type, ritual.emotions, success)
    
    -- Store in history
    table.insert(ritualHistory, memory)
    
    -- Clean up
    activeRituals[ritualId] = nil
    
    return memory
end

function GardenRituals.getRitualInfo(ritualId)
    return activeRituals[ritualId]
end

function GardenRituals.getRitualHistory(player)
    local playerHistory = {}
    for _, memory in ipairs(ritualHistory) do
        if memory.player == player then
            table.insert(playerHistory, memory)
        end
    end
    return playerHistory
end

function GardenRituals.getAvailableRituals()
    local available = {}
    for ritualType, info in pairs(RITUAL_TYPES) do
        table.insert(available, {
            type = ritualType,
            name = info.name,
            duration = info.duration,
            emotions = info.emotions
        })
    end
    return available
end

return GardenRituals 