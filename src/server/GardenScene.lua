--[[
    GardenScene.lua
    Garden environment setup for NeuroBloom
    
    Features:
    - Dynamic terrain generation
    - Biome placement
    - Lighting setup
    - Ambient effects
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Constants
local BIOME_SIZE = 100
local BIOME_HEIGHT = 20

local BIOME_TYPES = {
    LIGHT_MEADOW = {
        color = Color3.fromRGB(144, 238, 144),
        material = Enum.Material.Grass,
        particles = {
            color = Color3.fromRGB(255, 255, 255),
            size = 0.1,
            rate = 10
        }
    },
    SHADOW_GARDEN = {
        color = Color3.fromRGB(106, 90, 205),
        material = Enum.Material.Slate,
        particles = {
            color = Color3.fromRGB(147, 112, 219),
            size = 0.2,
            rate = 15
        }
    },
    VOID_BASIN = {
        color = Color3.fromRGB(25, 25, 112),
        material = Enum.Material.Marble,
        particles = {
            color = Color3.fromRGB(0, 0, 139),
            size = 0.3,
            rate = 20
        }
    }
}

-- Private functions
local function createBiome(biomeType, position)
    local biome = Instance.new("Part")
    biome.Size = Vector3.new(BIOME_SIZE, BIOME_HEIGHT, BIOME_SIZE)
    biome.Position = position
    biome.Anchored = true
    biome.Material = BIOME_TYPES[biomeType].material
    biome.Color = BIOME_TYPES[biomeType].color
    
    -- Add particle emitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(BIOME_TYPES[biomeType].particles.color)
    emitter.Size = NumberSequence.new(BIOME_TYPES[biomeType].particles.size)
    emitter.Rate = BIOME_TYPES[biomeType].particles.rate
    emitter.Lifetime = NumberRange.new(2, 4)
    emitter.Speed = NumberRange.new(1, 3)
    emitter.SpreadAngle = Vector2.new(0, 180)
    emitter.Parent = biome
    
    return biome
end

local function setupLighting()
    -- Ambient
    Lighting.Ambient = Color3.fromRGB(50, 50, 50)
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
    
    -- Bloom
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.5
    bloom.Size = 24
    bloom.Threshold = 2
    bloom.Parent = Lighting
    
    -- Atmosphere
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.3
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(199, 199, 199)
    atmosphere.Decay = Color3.fromRGB(106, 112, 125)
    atmosphere.Glare = 0.3
    atmosphere.Haze = 2
    atmosphere.Parent = Lighting
    
    -- Sky
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://1234567890" -- TODO: Replace with actual skybox ID
    sky.SkyboxDn = "rbxassetid://1234567891"
    sky.SkyboxFt = "rbxassetid://1234567892"
    sky.SkyboxLf = "rbxassetid://1234567893"
    sky.SkyboxRt = "rbxassetid://1234567894"
    sky.SkyboxUp = "rbxassetid://1234567895"
    sky.Parent = Lighting
end

local function createBoundaries()
    -- Create invisible walls
    local function createWall(position, size)
        local wall = Instance.new("Part")
        wall.Size = size
        wall.Position = position
        wall.Anchored = true
        wall.CanCollide = true
        wall.Transparency = 1
        wall.Parent = workspace
        return wall
    end
    
    local gardenSize = BIOME_SIZE * 3
    local wallHeight = 50
    
    -- North wall
    createWall(
        Vector3.new(0, wallHeight/2, -gardenSize/2),
        Vector3.new(gardenSize, wallHeight, 1)
    )
    
    -- South wall
    createWall(
        Vector3.new(0, wallHeight/2, gardenSize/2),
        Vector3.new(gardenSize, wallHeight, 1)
    )
    
    -- East wall
    createWall(
        Vector3.new(gardenSize/2, wallHeight/2, 0),
        Vector3.new(1, wallHeight, gardenSize)
    )
    
    -- West wall
    createWall(
        Vector3.new(-gardenSize/2, wallHeight/2, 0),
        Vector3.new(1, wallHeight, gardenSize)
    )
end

-- Public API
local GardenScene = {}

function GardenScene.createGardenEnvironment()
    -- Create biomes
    local lightMeadow = createBiome("LIGHT_MEADOW", Vector3.new(-BIOME_SIZE, 0, 0))
    lightMeadow.Parent = workspace
    
    local shadowGarden = createBiome("SHADOW_GARDEN", Vector3.new(0, 0, 0))
    shadowGarden.Parent = workspace
    
    local voidBasin = createBiome("VOID_BASIN", Vector3.new(BIOME_SIZE, 0, 0))
    voidBasin.Parent = workspace
    
    -- Setup lighting
    setupLighting()
    
    -- Create boundaries
    createBoundaries()
    
    -- Create spawn point
    local spawnPoint = Instance.new("SpawnLocation")
    spawnPoint.Size = Vector3.new(6, 1, 6)
    spawnPoint.Position = Vector3.new(0, 1, 0)
    spawnPoint.Anchored = true
    spawnPoint.CanCollide = true
    spawnPoint.Parent = workspace
end

function GardenScene.updateBiomeEffects(biomeType, intensity)
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Material == BIOME_TYPES[biomeType].material then
            local emitter = part:FindFirstChild("ParticleEmitter")
            if emitter then
                emitter.Rate = BIOME_TYPES[biomeType].particles.rate * intensity
            end
        end
    end
end

return GardenScene 