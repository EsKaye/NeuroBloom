--[[
    PlantMutationSystem.lua
    Handles plant mutations and genetic variations in NeuroBloom
    
    Features:
    - Mutation types (color, size, pattern, behavior)
    - Genetic inheritance
    - Mutation triggers
    - Mutation effects
    - Mutation visualization
]]

local PlantMutationSystem = {}

-- Constants
PlantMutationSystem.MUTATION_TYPES = {
    COLOR = "color",
    SIZE = "size",
    PATTERN = "pattern",
    BEHAVIOR = "behavior"
}

PlantMutationSystem.MUTATION_CHANCES = {
    BASE = 0.05, -- 5% base chance
    EMOTIONAL = 0.1, -- 10% emotional influence
    RITUAL = 0.15, -- 15% ritual influence
    CROSS_POLLINATION = 0.2 -- 20% cross-pollination influence
}

PlantMutationSystem.MUTATION_EFFECTS = {
    COLOR = {
        VIBRANT = "vibrant",
        PASTEL = "pastel",
        NEON = "neon",
        METALLIC = "metallic"
    },
    SIZE = {
        GIANT = "giant",
        MINIATURE = "miniature",
        VARIABLE = "variable"
    },
    PATTERN = {
        SPIRAL = "spiral",
        FRACTAL = "fractal",
        WAVE = "wave",
        CRYSTAL = "crystal"
    },
    BEHAVIOR = {
        DANCING = "dancing",
        GLOWING = "glowing",
        FLOATING = "floating",
        PULSING = "pulsing"
    }
}

-- Private variables
local activeMutations = {}
local mutationHistory = {}

-- Private functions
local function calculateMutationChance(plant, emotionalInput)
    local chance = PlantMutationSystem.MUTATION_CHANCES.BASE
    
    -- Emotional influence
    if emotionalInput then
        local emotionalIntensity = math.abs(emotionalInput.joy) + 
                                 math.abs(emotionalInput.peace) + 
                                 math.abs(emotionalInput.hope) + 
                                 math.abs(emotionalInput.grief)
        chance = chance + (emotionalIntensity * PlantMutationSystem.MUTATION_CHANCES.EMOTIONAL)
    end
    
    -- Ritual influence
    if plant.lastRitualTime and (os.time() - plant.lastRitualTime) < 3600 then
        chance = chance + PlantMutationSystem.MUTATION_CHANCES.RITUAL
    end
    
    return math.min(chance, 1.0)
end

local function selectMutationType(plant, emotionalInput)
    local types = {}
    local weights = {}
    
    -- Color mutations
    if emotionalInput.joy > 0.5 then
        table.insert(types, PlantMutationSystem.MUTATION_TYPES.COLOR)
        table.insert(weights, 0.4)
    end
    
    -- Size mutations
    if emotionalInput.hope > 0.5 then
        table.insert(types, PlantMutationSystem.MUTATION_TYPES.SIZE)
        table.insert(weights, 0.3)
    end
    
    -- Pattern mutations
    if emotionalInput.peace > 0.5 then
        table.insert(types, PlantMutationSystem.MUTATION_TYPES.PATTERN)
        table.insert(weights, 0.2)
    end
    
    -- Behavior mutations
    if emotionalInput.grief > 0.5 then
        table.insert(types, PlantMutationSystem.MUTATION_TYPES.BEHAVIOR)
        table.insert(weights, 0.1)
    end
    
    -- If no emotional triggers, use base weights
    if #types == 0 then
        types = {
            PlantMutationSystem.MUTATION_TYPES.COLOR,
            PlantMutationSystem.MUTATION_TYPES.SIZE,
            PlantMutationSystem.MUTATION_TYPES.PATTERN,
            PlantMutationSystem.MUTATION_TYPES.BEHAVIOR
        }
        weights = {0.4, 0.3, 0.2, 0.1}
    end
    
    -- Select mutation type based on weights
    local totalWeight = 0
    for _, weight in ipairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local random = math.random() * totalWeight
    local currentWeight = 0
    
    for i, weight in ipairs(weights) do
        currentWeight = currentWeight + weight
        if random <= currentWeight then
            return types[i]
        end
    end
    
    return types[1]
end

local function generateMutationEffect(mutationType, emotionalInput)
    local effects = PlantMutationSystem.MUTATION_EFFECTS[mutationType]
    local effectKeys = {}
    
    for key, _ in pairs(effects) do
        table.insert(effectKeys, key)
    end
    
    return effects[effectKeys[math.random(1, #effectKeys)]]
end

local function applyMutation(plant, mutationType, effect)
    -- Create mutation record
    local mutation = {
        type = mutationType,
        effect = effect,
        timestamp = os.time(),
        emotionalInput = plant.lastEmotionalInput
    }
    
    -- Apply mutation to plant
    if not plant.mutations then
        plant.mutations = {}
    end
    
    table.insert(plant.mutations, mutation)
    
    -- Update active mutations
    activeMutations[plant.id] = activeMutations[plant.id] or {}
    table.insert(activeMutations[plant.id], mutation)
    
    -- Record in history
    table.insert(mutationHistory, {
        plantId = plant.id,
        mutation = mutation
    })
    
    return mutation
end

-- Public API
function PlantMutationSystem.init()
    activeMutations = {}
    mutationHistory = {}
end

function PlantMutationSystem.checkForMutation(plant, emotionalInput)
    if not plant or not emotionalInput then
        return nil
    end
    
    -- Store emotional input
    plant.lastEmotionalInput = emotionalInput
    
    -- Calculate mutation chance
    local chance = calculateMutationChance(plant, emotionalInput)
    
    -- Check if mutation occurs
    if math.random() < chance then
        local mutationType = selectMutationType(plant, emotionalInput)
        local effect = generateMutationEffect(mutationType, emotionalInput)
        return applyMutation(plant, mutationType, effect)
    end
    
    return nil
end

function PlantMutationSystem.getActiveMutations(plantId)
    return activeMutations[plantId] or {}
end

function PlantMutationSystem.getMutationHistory()
    return mutationHistory
end

function PlantMutationSystem.clearMutations(plantId)
    activeMutations[plantId] = {}
end

return PlantMutationSystem 