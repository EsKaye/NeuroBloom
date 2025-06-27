--[[
    CrossPollinationSystem.lua
    Handles plant breeding and genetic combinations in NeuroBloom
    
    Features:
    - Cross-pollination mechanics
    - Genetic inheritance
    - Hybrid plant creation
    - Pollination effects
    - Breeding restrictions
]]

local CrossPollinationSystem = {}

-- Constants
CrossPollinationSystem.POLLINATION_TYPES = {
    NATURAL = "natural",
    ASSISTED = "assisted",
    RITUAL = "ritual"
}

CrossPollinationSystem.POLLINATION_CHANCES = {
    NATURAL = 0.1, -- 10% chance
    ASSISTED = 0.3, -- 30% chance
    RITUAL = 0.5 -- 50% chance
}

CrossPollinationSystem.GENETIC_TRAITS = {
    COLOR = "color",
    SIZE = "size",
    PATTERN = "pattern",
    BEHAVIOR = "behavior",
    RESISTANCE = "resistance",
    GROWTH = "growth"
}

-- Private variables
local activePollinations = {}
local pollinationHistory = {}
local geneticPool = {}

-- Private functions
local function calculateGeneticCompatibility(plant1, plant2)
    local compatibility = 0
    
    -- Check plant types
    if plant1.type == plant2.type then
        compatibility = compatibility + 0.5
    end
    
    -- Check emotional states
    if plant1.emotions and plant2.emotions then
        local emotionalCompatibility = 0
        for emotion, value1 in pairs(plant1.emotions) do
            local value2 = plant2.emotions[emotion] or 0
            emotionalCompatibility = emotionalCompatibility + (1 - math.abs(value1 - value2))
        end
        compatibility = compatibility + (emotionalCompatibility * 0.3)
    end
    
    -- Check mutations
    if plant1.mutations and plant2.mutations then
        local mutationCompatibility = 0
        for _, mut1 in ipairs(plant1.mutations) do
            for _, mut2 in ipairs(plant2.mutations) do
                if mut1.type == mut2.type then
                    mutationCompatibility = mutationCompatibility + 0.2
                end
            end
        end
        compatibility = compatibility + (mutationCompatibility * 0.2)
    end
    
    return math.min(compatibility, 1.0)
end

local function selectGeneticTraits(plant1, plant2)
    local traits = {}
    
    -- Inherit traits from both parents
    for _, traitType in pairs(CrossPollinationSystem.GENETIC_TRAITS) do
        local trait = {
            type = traitType,
            value = nil,
            source = nil
        }
        
        -- Randomly select parent for each trait
        local parent = math.random() < 0.5 and plant1 or plant2
        if parent[traitType] then
            trait.value = parent[traitType]
            trait.source = parent.id
        end
        
        table.insert(traits, trait)
    end
    
    return traits
end

local function createHybridPlant(plant1, plant2, traits)
    local hybrid = {
        id = game:GetService("HttpService"):GenerateGUID(),
        type = "hybrid",
        parents = {plant1.id, plant2.id},
        traits = traits,
        creationTime = os.time(),
        emotions = {
            joy = (plant1.emotions.joy + plant2.emotions.joy) / 2,
            peace = (plant1.emotions.peace + plant2.emotions.peace) / 2,
            hope = (plant1.emotions.hope + plant2.emotions.hope) / 2,
            grief = (plant1.emotions.grief + plant2.emotions.grief) / 2
        }
    }
    
    -- Add to genetic pool
    geneticPool[hybrid.id] = hybrid
    
    return hybrid
end

local function applyPollinationEffects(plant1, plant2, pollinationType)
    local effects = {
        particles = {},
        sounds = {},
        animations = {}
    }
    
    -- Create pollination particles
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Color = ColorSequence.new(plant1.color, plant2.color)
    particleEmitter.Size = NumberSequence.new(0.1, 0.3)
    particleEmitter.Transparency = NumberSequence.new(0, 1)
    particleEmitter.Rate = 20
    particleEmitter.Speed = NumberRange.new(1, 3)
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    
    table.insert(effects.particles, particleEmitter)
    
    -- Add pollination sound
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. (pollinationType == CrossPollinationSystem.POLLINATION_TYPES.RITUAL and "ritual_pollination" or "natural_pollination")
    sound.Volume = 0.5
    
    table.insert(effects.sounds, sound)
    
    return effects
end

-- Public API
function CrossPollinationSystem.init()
    activePollinations = {}
    pollinationHistory = {}
    geneticPool = {}
end

function CrossPollinationSystem.attemptPollination(plant1, plant2, pollinationType)
    if not plant1 or not plant2 or plant1.id == plant2.id then
        return nil
    end
    
    -- Check if plants are already pollinating
    if activePollinations[plant1.id] or activePollinations[plant2.id] then
        return nil
    end
    
    -- Calculate compatibility
    local compatibility = calculateGeneticCompatibility(plant1, plant2)
    
    -- Calculate success chance
    local baseChance = CrossPollinationSystem.POLLINATION_CHANCES[pollinationType] or CrossPollinationSystem.POLLINATION_CHANCES.NATURAL
    local successChance = baseChance * compatibility
    
    -- Attempt pollination
    if math.random() < successChance then
        -- Select genetic traits
        local traits = selectGeneticTraits(plant1, plant2)
        
        -- Create hybrid plant
        local hybrid = createHybridPlant(plant1, plant2, traits)
        
        -- Apply pollination effects
        local effects = applyPollinationEffects(plant1, plant2, pollinationType)
        
        -- Record pollination
        local pollination = {
            id = game:GetService("HttpService"):GenerateGUID(),
            plant1Id = plant1.id,
            plant2Id = plant2.id,
            hybridId = hybrid.id,
            type = pollinationType,
            compatibility = compatibility,
            timestamp = os.time(),
            effects = effects
        }
        
        -- Update active pollinations
        activePollinations[plant1.id] = pollination
        activePollinations[plant2.id] = pollination
        
        -- Add to history
        table.insert(pollinationHistory, pollination)
        
        return {
            success = true,
            hybrid = hybrid,
            pollination = pollination
        }
    end
    
    return {
        success = false,
        reason = "Pollination failed"
    }
end

function CrossPollinationSystem.getActivePollinations()
    return activePollinations
end

function CrossPollinationSystem.getPollinationHistory()
    return pollinationHistory
end

function CrossPollinationSystem.getGeneticPool()
    return geneticPool
end

function CrossPollinationSystem.clearPollination(plantId)
    activePollinations[plantId] = nil
end

return CrossPollinationSystem 