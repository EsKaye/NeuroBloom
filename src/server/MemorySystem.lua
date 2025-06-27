--[[
    MemorySystem.lua
    Handles memory management, including categories, effects, and persistence.
    Features:
    - Multiple memory categories
    - Memory effects
    - Memory persistence
    - Memory sharing
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local MemorySystem = {}

-- Constants
MemorySystem.CATEGORIES = {
    PERSONAL = "PersonalMemory",
    SHARED = "SharedMemory",
    RITUAL = "RitualMemory",
    PLANT = "PlantMemory"
}

MemorySystem.EFFECT_TYPES = {
    VISUAL = "VisualEffect",
    AUDIO = "AudioEffect",
    EMOTIONAL = "EmotionalEffect",
    ENVIRONMENTAL = "EnvironmentalEffect"
}

MemorySystem.STORAGE_TYPES = {
    LOCAL = "LocalStorage",
    CLOUD = "CloudStorage",
    HYBRID = "HybridStorage"
}

-- Private variables
local activeMemories = {}
local memoryHistory = {}
local memoryStore = DataStoreService:GetDataStore("NeuroBloomMemories")

-- Private functions
local function createMemoryEffect(memory, effectType)
    local effect = {
        type = effectType,
        intensity = 0,
        duration = 0,
        timestamp = os.time()
    }
    
    -- Set effect properties based on type
    if effectType == MemorySystem.EFFECT_TYPES.VISUAL then
        effect.color = Color3.new(math.random(), math.random(), math.random())
        effect.particles = true
        effect.intensity = 0.7
        effect.duration = 10
    elseif effectType == MemorySystem.EFFECT_TYPES.AUDIO then
        effect.soundId = "rbxassetid://" .. tostring(math.random(1000000, 9999999))
        effect.volume = 0.5
        effect.intensity = 0.6
        effect.duration = 8
    elseif effectType == MemorySystem.EFFECT_TYPES.EMOTIONAL then
        effect.emotions = {
            JOY = math.random(),
            PEACE = math.random(),
            HOPE = math.random(),
            GRIEF = math.random()
        }
        effect.intensity = 0.8
        effect.duration = 15
    elseif effectType == MemorySystem.EFFECT_TYPES.ENVIRONMENTAL then
        effect.weather = "Clear"
        effect.lighting = "Normal"
        effect.intensity = 0.5
        effect.duration = 20
    end
    
    return effect
end

local function calculateMemoryIntensity(memory)
    local intensity = 0
    
    -- Base intensity from emotions
    if memory.emotions then
        for _, value in pairs(memory.emotions) do
            intensity = intensity + value
        end
        intensity = intensity / 4 -- Average of emotions
    end
    
    -- Modify based on age
    local age = os.time() - memory.timestamp
    local ageModifier = math.exp(-age / (30 * 24 * 60 * 60)) -- Decay over 30 days
    intensity = intensity * ageModifier
    
    -- Modify based on category
    if memory.category == MemorySystem.CATEGORIES.SHARED then
        intensity = intensity * 1.2
    elseif memory.category == MemorySystem.CATEGORIES.RITUAL then
        intensity = intensity * 1.5
    end
    
    return math.clamp(intensity, 0, 1)
end

local function blendEffects(effects)
    local blended = {
        color = Color3.new(0, 0, 0),
        volume = 0,
        emotions = {
            JOY = 0,
            PEACE = 0,
            HOPE = 0,
            GRIEF = 0
        },
        intensity = 0
    }
    
    local totalWeight = 0
    
    for _, effect in ipairs(effects) do
        local weight = effect.intensity
        
        if effect.type == MemorySystem.EFFECT_TYPES.VISUAL then
            blended.color = blended.color:Lerp(effect.color, weight)
        elseif effect.type == MemorySystem.EFFECT_TYPES.AUDIO then
            blended.volume = blended.volume + (effect.volume * weight)
        elseif effect.type == MemorySystem.EFFECT_TYPES.EMOTIONAL then
            for emotion, value in pairs(effect.emotions) do
                blended.emotions[emotion] = blended.emotions[emotion] + (value * weight)
            end
        end
        
        blended.intensity = blended.intensity + (effect.intensity * weight)
        totalWeight = totalWeight + weight
    end
    
    -- Normalize
    if totalWeight > 0 then
        blended.volume = blended.volume / totalWeight
        for emotion, value in pairs(blended.emotions) do
            blended.emotions[emotion] = value / totalWeight
        end
        blended.intensity = blended.intensity / totalWeight
    end
    
    return blended
end

-- Public API
function MemorySystem.createMemory(data)
    if not data then return nil end
    
    local memory = {
        id = HttpService:GenerateGUID(),
        category = data.category or MemorySystem.CATEGORIES.PERSONAL,
        title = data.title or "Untitled Memory",
        description = data.description or "",
        emotions = data.emotions or {},
        effects = {},
        timestamp = os.time(),
        owner = data.owner,
        shared = data.shared or false,
        intensity = 0
    }
    
    -- Add effects if specified
    if data.effectTypes then
        for _, effectType in ipairs(data.effectTypes) do
            table.insert(memory.effects, createMemoryEffect(memory, effectType))
        end
    end
    
    -- Calculate initial intensity
    memory.intensity = calculateMemoryIntensity(memory)
    
    -- Store memory
    activeMemories[memory.id] = memory
    memoryHistory[memory.id] = memory
    
    return memory
end

function MemorySystem.applyEffect(memory, effectType)
    if not memory or not effectType then return nil end
    
    local effect = createMemoryEffect(memory, effectType)
    table.insert(memory.effects, effect)
    
    -- Update memory intensity
    memory.intensity = calculateMemoryIntensity(memory)
    
    return effect
end

function MemorySystem.calculateIntensity(memory, effectType)
    if not memory then return 0 end
    
    local intensity = memory.intensity
    
    -- Modify based on effect type
    if effectType then
        local effectIntensity = 0
        for _, effect in ipairs(memory.effects) do
            if effect.type == effectType then
                effectIntensity = effectIntensity + effect.intensity
            end
        end
        intensity = intensity * (1 + effectIntensity)
    end
    
    return math.clamp(intensity, 0, 1)
end

function MemorySystem.blendEffects(effects)
    if not effects then return nil end
    return blendEffects(effects)
end

function MemorySystem.saveMemory(memory, storageType)
    if not memory then return false end
    
    if storageType == MemorySystem.STORAGE_TYPES.LOCAL then
        -- Save to local storage
        local success, err = pcall(function()
            memoryStore:SetAsync(memory.id, memory)
        end)
        return success
    elseif storageType == MemorySystem.STORAGE_TYPES.CLOUD then
        -- Save to cloud storage
        local success, err = pcall(function()
            memoryStore:SetAsync("cloud_" .. memory.id, memory)
        end)
        return success
    elseif storageType == MemorySystem.STORAGE_TYPES.HYBRID then
        -- Save to both local and cloud
        local localSuccess = MemorySystem.saveMemory(memory, MemorySystem.STORAGE_TYPES.LOCAL)
        local cloudSuccess = MemorySystem.saveMemory(memory, MemorySystem.STORAGE_TYPES.CLOUD)
        return localSuccess and cloudSuccess
    end
    
    return false
end

function MemorySystem.loadMemory(memoryId, storageType)
    if not memoryId then return nil end
    
    local memory = nil
    
    if storageType == MemorySystem.STORAGE_TYPES.LOCAL then
        -- Load from local storage
        local success, result = pcall(function()
            return memoryStore:GetAsync(memoryId)
        end)
        if success then memory = result end
    elseif storageType == MemorySystem.STORAGE_TYPES.CLOUD then
        -- Load from cloud storage
        local success, result = pcall(function()
            return memoryStore:GetAsync("cloud_" .. memoryId)
        end)
        if success then memory = result end
    elseif storageType == MemorySystem.STORAGE_TYPES.HYBRID then
        -- Try local first, then cloud
        memory = MemorySystem.loadMemory(memoryId, MemorySystem.STORAGE_TYPES.LOCAL)
        if not memory then
            memory = MemorySystem.loadMemory(memoryId, MemorySystem.STORAGE_TYPES.CLOUD)
        end
    end
    
    if memory then
        -- Update memory in active memories
        activeMemories[memory.id] = memory
        memoryHistory[memory.id] = memory
    end
    
    return memory
end

function MemorySystem.syncMemories()
    local success = true
    
    -- Sync all active memories
    for _, memory in pairs(activeMemories) do
        if not MemorySystem.saveMemory(memory, MemorySystem.STORAGE_TYPES.HYBRID) then
            success = false
        end
    end
    
    return success
end

function MemorySystem.getActiveMemories()
    return activeMemories
end

function MemorySystem.getMemoryHistory()
    return memoryHistory
end

return MemorySystem 