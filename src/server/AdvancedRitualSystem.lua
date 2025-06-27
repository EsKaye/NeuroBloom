--[[
    AdvancedRitualSystem.lua
    Handles advanced rituals, including healing, growth, and transformation rituals.
    Features:
    - Multiple ritual types
    - Ritual components (gestures, chants, offerings, symbols)
    - Outcome calculations
    - Ritual history tracking
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlantVisuals = require(script.Parent.PlantVisuals)
local PlantMutationSystem = require(script.Parent.PlantMutationSystem)
local PlantDiseaseSystem = require(script.Parent.PlantDiseaseSystem)

local AdvancedRitualSystem = {}

-- Constants
AdvancedRitualSystem.RITUAL_TYPES = {
    HEALING = "HealingRitual",
    GROWTH = "GrowthRitual",
    TRANSFORMATION = "TransformationRitual"
}

AdvancedRitualSystem.RITUAL_COMPONENTS = {
    GESTURES = "Gestures",
    CHANTS = "Chants",
    OFFERINGS = "Offerings",
    SYMBOLS = "Symbols"
}

-- Ritual properties
local RITUAL_PROPERTIES = {
    [AdvancedRitualSystem.RITUAL_TYPES.HEALING] = {
        duration = 300, -- 5 minutes
        requiredComponents = {
            AdvancedRitualSystem.RITUAL_COMPONENTS.GESTURES,
            AdvancedRitualSystem.RITUAL_COMPONENTS.CHANTS
        },
        successThreshold = 0.7
    },
    [AdvancedRitualSystem.RITUAL_TYPES.GROWTH] = {
        duration = 600, -- 10 minutes
        requiredComponents = {
            AdvancedRitualSystem.RITUAL_COMPONENTS.GESTURES,
            AdvancedRitualSystem.RITUAL_COMPONENTS.OFFERINGS
        },
        successThreshold = 0.6
    },
    [AdvancedRitualSystem.RITUAL_TYPES.TRANSFORMATION] = {
        duration = 900, -- 15 minutes
        requiredComponents = {
            AdvancedRitualSystem.RITUAL_COMPONENTS.GESTURES,
            AdvancedRitualSystem.RITUAL_COMPONENTS.CHANTS,
            AdvancedRitualSystem.RITUAL_COMPONENTS.OFFERINGS,
            AdvancedRitualSystem.RITUAL_COMPONENTS.SYMBOLS
        },
        successThreshold = 0.8
    }
}

-- Private variables
local activeRituals = {}
local ritualHistory = {}

-- Private functions
local function validateComponents(ritualType, components)
    local required = RITUAL_PROPERTIES[ritualType].requiredComponents
    if not required then return false end
    
    for _, reqComponent in ipairs(required) do
        local found = false
        for _, component in ipairs(components) do
            if component == reqComponent then
                found = true
                break
            end
        end
        if not found then return false end
    end
    
    return true
end

local function calculateComponentSuccess(component, participant)
    local baseSuccess = 0.5
    
    -- Modify based on participant's emotional state
    if participant.emotions then
        local emotionalModifier = 0
        for _, value in pairs(participant.emotions) do
            emotionalModifier = emotionalModifier + value
        end
        baseSuccess = baseSuccess + (emotionalModifier * 0.1)
    end
    
    -- Add random variation
    baseSuccess = baseSuccess + (math.random() * 0.2 - 0.1)
    
    return math.clamp(baseSuccess, 0, 1)
end

local function applyRitualEffects(ritual, success)
    local properties = RITUAL_PROPERTIES[ritual.type]
    if not properties then return end
    
    if ritual.type == AdvancedRitualSystem.RITUAL_TYPES.HEALING then
        -- Apply healing effects
        for _, plant in pairs(ritual.targets) do
            if plant.health and plant.health < 1 then
                plant.health = math.min(1, plant.health + (success * 0.3))
            end
        end
    elseif ritual.type == AdvancedRitualSystem.RITUAL_TYPES.GROWTH then
        -- Apply growth effects
        for _, plant in pairs(ritual.targets) do
            if plant.growthStage then
                plant.growthStage = math.min(plant.maxGrowthStage or 5, 
                    plant.growthStage + (success * 0.5))
            end
        end
    elseif ritual.type == AdvancedRitualSystem.RITUAL_TYPES.TRANSFORMATION then
        -- Apply transformation effects
        for _, plant in pairs(ritual.targets) do
            if success > 0.8 then
                PlantMutationSystem.createMutation(plant, 
                    PlantMutationSystem.MUTATION_TYPES.EFFECT,
                    PlantMutationSystem.MUTATION_TRIGGERS.RITUAL)
            end
        end
    end
end

-- Public API
function AdvancedRitualSystem.createRitual(type, components, targets)
    if not type or not components or not targets then return nil end
    
    -- Validate ritual type and components
    if not RITUAL_PROPERTIES[type] or not validateComponents(type, components) then
        return nil
    end
    
    local ritual = {
        id = game:GetService("HttpService"):GenerateGUID(),
        type = type,
        components = components,
        targets = targets,
        startTime = os.time(),
        endTime = os.time() + RITUAL_PROPERTIES[type].duration,
        participants = {},
        progress = 0,
        success = 0
    }
    
    -- Store ritual
    activeRituals[ritual.id] = ritual
    
    return ritual
end

function AdvancedRitualSystem.performRitual(ritual, participant)
    if not ritual or not participant then return false end
    
    -- Check if ritual is still active
    if os.time() > ritual.endTime then
        return false
    end
    
    -- Add participant if not already present
    local isNewParticipant = true
    for _, p in ipairs(ritual.participants) do
        if p.id == participant.id then
            isNewParticipant = false
            break
        end
    end
    
    if isNewParticipant then
        table.insert(ritual.participants, participant)
    end
    
    -- Calculate component success
    local totalSuccess = 0
    for _, component in ipairs(ritual.components) do
        totalSuccess = totalSuccess + calculateComponentSuccess(component, participant)
    end
    
    -- Update ritual progress
    ritual.progress = math.min(1, ritual.progress + (totalSuccess / #ritual.components))
    ritual.success = (ritual.success * #ritual.participants + totalSuccess) / (#ritual.participants + 1)
    
    -- Check if ritual is complete
    if ritual.progress >= 1 then
        -- Apply ritual effects
        applyRitualEffects(ritual, ritual.success)
        
        -- Store in history
        ritualHistory[ritual.id] = ritual
        
        -- Remove from active rituals
        activeRituals[ritual.id] = nil
        
        return true
    end
    
    return false
end

function AdvancedRitualSystem.calculateOutcome(ritual)
    if not ritual then return nil end
    
    local properties = RITUAL_PROPERTIES[ritual.type]
    if not properties then return nil end
    
    local outcome = {
        success = ritual.success >= properties.successThreshold,
        effectiveness = ritual.success,
        rewards = {}
    }
    
    -- Calculate rewards based on success
    if outcome.success then
        if ritual.type == AdvancedRitualSystem.RITUAL_TYPES.HEALING then
            outcome.rewards.healthBonus = ritual.success * 0.3
        elseif ritual.type == AdvancedRitualSystem.RITUAL_TYPES.GROWTH then
            outcome.rewards.growthBonus = ritual.success * 0.5
        elseif ritual.type == AdvancedRitualSystem.RITUAL_TYPES.TRANSFORMATION then
            outcome.rewards.mutationChance = ritual.success * 0.8
        end
    end
    
    return outcome
end

function AdvancedRitualSystem.getActiveRituals()
    return activeRituals
end

function AdvancedRitualSystem.getRitualHistory()
    return ritualHistory
end

return AdvancedRitualSystem 