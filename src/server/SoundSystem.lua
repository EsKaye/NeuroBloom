--[[
    SoundSystem.lua
    Handles all audio in NeuroBloom
    
    Features:
    - Ambient soundscapes
    - Plant interaction sounds
    - Ritual audio
    - Dynamic music system
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local SoundSystem = {}

-- Constants
local SOUND_TYPES = {
    AMBIENT = "ambient",
    PLANT = "plant",
    RITUAL = "ritual",
    MUSIC = "music"
}

local BIOME_SOUNDS = {
    LightMeadow = {
        ambient = "rbxassetid://YOUR_SOUND_ID", -- Replace with actual sound ID
        music = "rbxassetid://YOUR_SOUND_ID",
        volume = 0.5,
        pitch = 1
    },
    ShadowGarden = {
        ambient = "rbxassetid://YOUR_SOUND_ID",
        music = "rbxassetid://YOUR_SOUND_ID",
        volume = 0.4,
        pitch = 0.9
    },
    VoidBasin = {
        ambient = "rbxassetid://YOUR_SOUND_ID",
        music = "rbxassetid://YOUR_SOUND_ID",
        volume = 0.3,
        pitch = 0.8
    }
}

local PLANT_SOUNDS = {
    JOY = {
        grow = "rbxassetid://YOUR_SOUND_ID",
        interact = "rbxassetid://YOUR_SOUND_ID",
        emotion = "rbxassetid://YOUR_SOUND_ID"
    },
    GRIEF = {
        grow = "rbxassetid://YOUR_SOUND_ID",
        interact = "rbxassetid://YOUR_SOUND_ID",
        emotion = "rbxassetid://YOUR_SOUND_ID"
    }
    -- Add more plant sounds
}

local RITUAL_SOUNDS = {
    BREATHING = {
        start = "rbxassetid://YOUR_SOUND_ID",
        loop = "rbxassetid://YOUR_SOUND_ID",
        complete = "rbxassetid://YOUR_SOUND_ID"
    },
    WHISPER = {
        start = "rbxassetid://YOUR_SOUND_ID",
        loop = "rbxassetid://YOUR_SOUND_ID",
        complete = "rbxassetid://YOUR_SOUND_ID"
    }
    -- Add more ritual sounds
}

-- Private variables
local activeSounds = {}
local currentBiome = nil
local currentRitual = nil

-- Private functions
local function createSound(soundId, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    
    for property, value in pairs(properties) do
        sound[property] = value
    end
    
    return sound
end

local function playBiomeSounds(biomeName)
    if currentBiome == biomeName then return end
    
    -- Stop current biome sounds
    if activeSounds.biome then
        activeSounds.biome.ambient:Stop()
        activeSounds.biome.music:Stop()
    end
    
    -- Create new biome sounds
    local biomeSounds = BIOME_SOUNDS[biomeName]
    if not biomeSounds then return end
    
    local ambient = createSound(biomeSounds.ambient, {
        Volume = biomeSounds.volume,
        Pitch = biomeSounds.pitch,
        Looped = true
    })
    ambient.Parent = SoundService
    
    local music = createSound(biomeSounds.music, {
        Volume = biomeSounds.volume * 0.5,
        Pitch = biomeSounds.pitch,
        Looped = true
    })
    music.Parent = SoundService
    
    -- Play new sounds
    ambient:Play()
    music:Play()
    
    activeSounds.biome = {
        ambient = ambient,
        music = music
    }
    
    currentBiome = biomeName
end

local function playPlantSound(plantType, soundType)
    local plantSounds = PLANT_SOUNDS[plantType]
    if not plantSounds then return end
    
    local soundId = plantSounds[soundType]
    if not soundId then return end
    
    local sound = createSound(soundId, {
        Volume = 0.5,
        Pitch = 1
    })
    sound.Parent = SoundService
    
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function playRitualSound(ritualType, soundType)
    local ritualSounds = RITUAL_SOUNDS[ritualType]
    if not ritualSounds then return end
    
    local soundId = ritualSounds[soundType]
    if not soundId then return end
    
    -- Stop current ritual sounds
    if activeSounds.ritual then
        activeSounds.ritual:Stop()
        activeSounds.ritual:Destroy()
    end
    
    local sound = createSound(soundId, {
        Volume = 0.6,
        Pitch = 1,
        Looped = (soundType == "loop")
    })
    sound.Parent = SoundService
    
    sound:Play()
    
    if soundType == "loop" then
        activeSounds.ritual = sound
    else
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
end

-- Public API
function SoundSystem.Initialize()
    print("Initializing sound system...")
end

function SoundSystem.SetBiome(biomeName)
    playBiomeSounds(biomeName)
end

function SoundSystem.PlayPlantSound(plantType, soundType)
    playPlantSound(plantType, soundType)
end

function SoundSystem.PlayRitualSound(ritualType, soundType)
    playRitualSound(ritualType, soundType)
end

function SoundSystem.StopRitualSounds()
    if activeSounds.ritual then
        activeSounds.ritual:Stop()
        activeSounds.ritual:Destroy()
        activeSounds.ritual = nil
    end
end

function SoundSystem.SetMusicVolume(volume)
    if activeSounds.biome and activeSounds.biome.music then
        activeSounds.biome.music.Volume = volume
    end
end

function SoundSystem.SetAmbientVolume(volume)
    if activeSounds.biome and activeSounds.biome.ambient then
        activeSounds.biome.ambient.Volume = volume
    end
end

return SoundSystem 