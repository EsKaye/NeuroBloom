--[[
    PlantVisuals.lua
    Plant visualization system for NeuroBloom
    
    Features:
    - Dynamic plant model generation
    - Growth animations
    - Emotional effects
    - Bioluminescence
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local PLANT_TYPES = {
    JOY = {
        modelId = "rbxassetid://1234567890", -- TODO: Replace with actual model ID
        colors = {
            primary = Color3.fromRGB(255, 223, 0),
            secondary = Color3.fromRGB(255, 182, 0)
        },
        particleColor = Color3.fromRGB(255, 223, 0)
    },
    GRIEF = {
        modelId = "rbxassetid://1234567891", -- TODO: Replace with actual model ID
        colors = {
            primary = Color3.fromRGB(147, 112, 219),
            secondary = Color3.fromRGB(106, 90, 205)
        },
        particleColor = Color3.fromRGB(147, 112, 219)
    },
    HOPE = {
        modelId = "rbxassetid://1234567892", -- TODO: Replace with actual model ID
        colors = {
            primary = Color3.fromRGB(135, 206, 235),
            secondary = Color3.fromRGB(0, 191, 255)
        },
        particleColor = Color3.fromRGB(135, 206, 235)
    },
    PEACE = {
        modelId = "rbxassetid://1234567893", -- TODO: Replace with actual model ID
        colors = {
            primary = Color3.fromRGB(144, 238, 144),
            secondary = Color3.fromRGB(50, 205, 50)
        },
        particleColor = Color3.fromRGB(144, 238, 144)
    }
}

local GROWTH_STAGES = {
    SEED = {
        scale = Vector3.new(0.1, 0.1, 0.1),
        duration = 2
    },
    SPROUT = {
        scale = Vector3.new(0.3, 0.3, 0.3),
        duration = 3
    },
    BUD = {
        scale = Vector3.new(0.6, 0.6, 0.6),
        duration = 4
    },
    BLOOM = {
        scale = Vector3.new(0.8, 0.8, 0.8),
        duration = 5
    },
    MATURE = {
        scale = Vector3.new(1, 1, 1),
        duration = 6
    }
}

-- Private variables
local plants = {}

-- Private functions
local function createParticleEmitter(part)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(PLANT_TYPES.JOY.particleColor)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Lifetime = NumberRange.new(1, 2)
    emitter.Rate = 10
    emitter.Speed = NumberRange.new(1, 2)
    emitter.SpreadAngle = Vector2.new(0, 180)
    emitter.Parent = part
    return emitter
end

local function createPlantModel(plantType, position)
    local model = Instance.new("Model")
    model.Name = plantType .. "Plant"
    
    -- Create base part
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(1, 1, 1)
    base.Position = position
    base.Anchored = true
    base.CanCollide = false
    base.Transparency = 1
    base.Parent = model
    
    -- Create stem
    local stem = Instance.new("Part")
    stem.Name = "Stem"
    stem.Size = Vector3.new(0.2, 2, 0.2)
    stem.Position = position + Vector3.new(0, 1, 0)
    stem.Anchored = true
    stem.CanCollide = false
    stem.Material = Enum.Material.Neon
    stem.Color = PLANT_TYPES[plantType].colors.primary
    stem.Parent = model
    
    -- Create leaves
    for i = 1, 3 do
        local leaf = Instance.new("Part")
        leaf.Name = "Leaf" .. i
        leaf.Size = Vector3.new(0.1, 0.5, 0.5)
        leaf.Position = position + Vector3.new(0, 1 + (i * 0.5), 0)
        leaf.Anchored = true
        leaf.CanCollide = false
        leaf.Material = Enum.Material.Neon
        leaf.Color = PLANT_TYPES[plantType].colors.secondary
        leaf.Parent = model
        
        -- Add particle emitter
        createParticleEmitter(leaf)
    end
    
    -- Create flower
    local flower = Instance.new("Part")
    flower.Name = "Flower"
    flower.Size = Vector3.new(0.8, 0.8, 0.8)
    flower.Position = position + Vector3.new(0, 2.5, 0)
    flower.Anchored = true
    flower.CanCollide = false
    flower.Material = Enum.Material.Neon
    flower.Color = PLANT_TYPES[plantType].colors.primary
    flower.Parent = model
    
    -- Add particle emitter
    createParticleEmitter(flower)
    
    return model
end

local function animateGrowth(plant, stage)
    local targetScale = GROWTH_STAGES[stage].scale
    local duration = GROWTH_STAGES[stage].duration
    
    for _, part in ipairs(plant:GetDescendants()) do
        if part:IsA("BasePart") then
            TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = part.Size * targetScale
            }):Play()
        end
    end
end

local function updateEmotionalState(plant, emotion)
    local plantType = plant.Name:gsub("Plant", "")
    local colors = PLANT_TYPES[plantType].colors
    
    for _, part in ipairs(plant:GetDescendants()) do
        if part:IsA("BasePart") then
            local emitter = part:FindFirstChild("ParticleEmitter")
            if emitter then
                emitter.Color = ColorSequence.new(colors.primary)
                emitter.Rate = emotion * 20
            end
        end
    end
end

-- Public API
local PlantVisuals = {}

function PlantVisuals.createPlant(plantType, position)
    local plant = createPlantModel(plantType, position)
    plant.Parent = workspace
    
    -- Initialize growth
    animateGrowth(plant, "SEED")
    
    -- Store plant reference
    plants[plant] = {
        type = plantType,
        stage = "SEED",
        emotion = 0
    }
    
    return plant
end

function PlantVisuals.growPlant(plant)
    local plantData = plants[plant]
    if not plantData then return end
    
    local stages = {"SPROUT", "BUD", "BLOOM", "MATURE"}
    local currentIndex = table.find(stages, plantData.stage) or 0
    local nextStage = stages[currentIndex + 1]
    
    if nextStage then
        plantData.stage = nextStage
        animateGrowth(plant, nextStage)
    end
end

function PlantVisuals.updateEmotion(plant, emotion)
    local plantData = plants[plant]
    if not plantData then return end
    
    plantData.emotion = emotion
    updateEmotionalState(plant, emotion)
end

function PlantVisuals.getPlantInfo(plant)
    return plants[plant]
end

return PlantVisuals 