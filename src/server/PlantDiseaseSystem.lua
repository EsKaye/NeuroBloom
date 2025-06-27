--[[
    PlantDiseaseSystem.lua
    Handles plant health and diseases in NeuroBloom
    
    Features:
    - Disease types and effects
    - Health monitoring
    - Treatment mechanics
    - Disease spread
    - Recovery system
]]

local PlantDiseaseSystem = {}

-- Constants
PlantDiseaseSystem.DISEASE_TYPES = {
    FUNGAL = "fungal",
    VIRAL = "viral",
    NUTRITIONAL = "nutritional",
    ENVIRONMENTAL = "environmental"
}

PlantDiseaseSystem.DISEASE_EFFECTS = {
    FUNGAL = {
        name = "Root Rot",
        symptoms = {"discoloration", "wilting", "stunted growth"},
        spreadRate = 0.2,
        damageRate = 0.1,
        treatment = {"fungicide", "improved drainage", "sunlight"}
    },
    VIRAL = {
        name = "Leaf Mosaic",
        symptoms = {"mottled leaves", "deformed growth", "reduced yield"},
        spreadRate = 0.3,
        damageRate = 0.15,
        treatment = {"isolation", "pruning", "antiviral treatment"}
    },
    NUTRITIONAL = {
        name = "Nutrient Deficiency",
        symptoms = {"yellowing", "weak growth", "leaf drop"},
        spreadRate = 0.1,
        damageRate = 0.05,
        treatment = {"fertilizer", "soil amendment", "balanced diet"}
    },
    ENVIRONMENTAL = {
        name = "Stress Response",
        symptoms = {"leaf curl", "color change", "growth pause"},
        spreadRate = 0.05,
        damageRate = 0.02,
        treatment = {"optimal conditions", "stress reduction", "time"}
    }
}

PlantDiseaseSystem.HEALTH_STATES = {
    HEALTHY = "healthy",
    WEAKENED = "weakened",
    INFECTED = "infected",
    CRITICAL = "critical"
}

-- Private variables
local plantHealth = {}
local activeDiseases = {}
local diseaseHistory = {}

-- Private functions
local function calculateHealthState(plant)
    local health = plantHealth[plant.id]
    if not health then return PlantDiseaseSystem.HEALTH_STATES.HEALTHY end
    
    if health.value >= 0.8 then
        return PlantDiseaseSystem.HEALTH_STATES.HEALTHY
    elseif health.value >= 0.5 then
        return PlantDiseaseSystem.HEALTH_STATES.WEAKENED
    elseif health.value >= 0.2 then
        return PlantDiseaseSystem.HEALTH_STATES.INFECTED
    else
        return PlantDiseaseSystem.HEALTH_STATES.CRITICAL
    end
end

local function applyDiseaseEffects(plant, disease)
    local effects = PlantDiseaseSystem.DISEASE_EFFECTS[disease.type]
    if not effects then return end
    
    -- Apply visual effects
    if plant.model and plant.model.PrimaryPart then
        -- Discoloration
        if table.find(effects.symptoms, "discoloration") then
            local originalColor = plant.model.PrimaryPart.Color
            plant.model.PrimaryPart.Color = Color3.new(
                originalColor.R * 0.8,
                originalColor.G * 0.8,
                originalColor.B * 0.8
            )
        end
        
        -- Wilting
        if table.find(effects.symptoms, "wilting") then
            plant.model.PrimaryPart.Orientation = Vector3.new(
                math.random(-10, 10),
                math.random(-10, 10),
                math.random(-10, 10)
            )
        end
    end
    
    -- Apply growth effects
    if table.find(effects.symptoms, "stunted growth") then
        plant.growthRate = plant.growthRate * 0.5
    end
end

local function spreadDisease(plant, disease)
    local effects = PlantDiseaseSystem.DISEASE_EFFECTS[disease.type]
    if not effects then return end
    
    -- Check nearby plants
    local nearbyPlants = workspace:FindPartsInRegion3(
        Region3.new(
            plant.model.PrimaryPart.Position - Vector3.new(5, 5, 5),
            plant.model.PrimaryPart.Position + Vector3.new(5, 5, 5)
        ),
        nil,
        10
    )
    
    for _, part in ipairs(nearbyPlants) do
        local nearbyPlant = part.Parent
        if nearbyPlant and nearbyPlant:FindFirstChild("PlantId") then
            local plantId = nearbyPlant.PlantId.Value
            if not activeDiseases[plantId] and math.random() < effects.spreadRate then
                infectPlant(plantId, disease.type)
            end
        end
    end
end

local function updateDiseaseProgress(plant, disease)
    local effects = PlantDiseaseSystem.DISEASE_EFFECTS[disease.type]
    if not effects then return end
    
    -- Update disease severity
    disease.severity = disease.severity + (effects.damageRate * (1 - (plant.resistance or 0)))
    
    -- Update plant health
    local health = plantHealth[plant.id]
    if health then
        health.value = math.max(0, health.value - (effects.damageRate * disease.severity))
        health.state = calculateHealthState(plant)
    end
    
    -- Apply effects
    applyDiseaseEffects(plant, disease)
    
    -- Attempt spread
    if math.random() < effects.spreadRate then
        spreadDisease(plant, disease)
    end
end

-- Public API
function PlantDiseaseSystem.init()
    plantHealth = {}
    activeDiseases = {}
    diseaseHistory = {}
end

function PlantDiseaseSystem.infectPlant(plantId, diseaseType)
    if not plantId or not diseaseType then return nil end
    
    -- Check if plant is already infected
    if activeDiseases[plantId] then
        return nil
    end
    
    -- Create disease record
    local disease = {
        type = diseaseType,
        severity = 0.1,
        startTime = os.time(),
        lastUpdate = os.time()
    }
    
    -- Initialize plant health if needed
    if not plantHealth[plantId] then
        plantHealth[plantId] = {
            value = 1.0,
            state = PlantDiseaseSystem.HEALTH_STATES.HEALTHY,
            history = {}
        }
    end
    
    -- Record disease
    activeDiseases[plantId] = disease
    table.insert(diseaseHistory, {
        plantId = plantId,
        disease = disease
    })
    
    return disease
end

function PlantDiseaseSystem.treatDisease(plantId, treatment)
    local disease = activeDiseases[plantId]
    if not disease then return false end
    
    local effects = PlantDiseaseSystem.DISEASE_EFFECTS[disease.type]
    if not effects then return false end
    
    -- Check if treatment is effective
    if table.find(effects.treatment, treatment) then
        -- Apply treatment
        disease.severity = math.max(0, disease.severity - 0.2)
        
        -- Update health
        local health = plantHealth[plantId]
        if health then
            health.value = math.min(1.0, health.value + 0.1)
            health.state = calculateHealthState(plant)
        end
        
        -- Check for recovery
        if disease.severity <= 0 then
            activeDiseases[plantId] = nil
            return true
        end
    end
    
    return false
end

function PlantDiseaseSystem.updatePlantHealth(plantId, deltaTime)
    local disease = activeDiseases[plantId]
    if not disease then return end
    
    -- Update disease progress
    updateDiseaseProgress(plant, disease)
    
    -- Record health history
    local health = plantHealth[plantId]
    if health then
        table.insert(health.history, {
            value = health.value,
            state = health.state,
            timestamp = os.time()
        })
    end
end

function PlantDiseaseSystem.getPlantHealth(plantId)
    return plantHealth[plantId]
end

function PlantDiseaseSystem.getActiveDiseases()
    return activeDiseases
end

function PlantDiseaseSystem.getDiseaseHistory()
    return diseaseHistory
end

return PlantDiseaseSystem 