--[[
    SoundSystem.lua
    Handles all audio in NeuroBloom
    
    Features:
    - Ambient soundscapes
    - Plant interaction sounds
    - Ritual audio
    - Dynamic music system
]]

-- Only request services that are actually used to keep memory lean
local SoundService = game:GetService("SoundService")

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

-- Utility to safely stop and clean up a sound instance
local function stopAndDestroy(sound)
    if not sound then
        return
    end

    sound:Stop()
    sound:Destroy()
end

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
        stopAndDestroy(activeSounds.biome.ambient)
        stopAndDestroy(activeSounds.biome.music)
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
        stopAndDestroy(activeSounds.ritual)
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
-- Initializes the sound system and prepares required state
function SoundSystem.Initialize()
    print("Initializing sound system...")
end

-- Switches the ambient soundscape to match the requested biome
function SoundSystem.SetBiome(biomeName)
    playBiomeSounds(biomeName)
end

-- Plays a plant-specific sound for the given interaction type
function SoundSystem.PlayPlantSound(plantType, soundType)
    playPlantSound(plantType, soundType)
end

-- Triggers ritual audio feedback for the provided ritual and stage
function SoundSystem.PlayRitualSound(ritualType, soundType)
    playRitualSound(ritualType, soundType)
end

-- Stops any looping ritual audio and cleans up resources
function SoundSystem.StopRitualSounds()
    if activeSounds.ritual then
        stopAndDestroy(activeSounds.ritual)
        activeSounds.ritual = nil
    end
end

-- Adjusts music volume for the currently active biome soundtrack
function SoundSystem.SetMusicVolume(volume)
    if activeSounds.biome and activeSounds.biome.music then
        activeSounds.biome.music.Volume = volume
    end
end

-- Adjusts ambient volume for the currently active biome soundscape
function SoundSystem.SetAmbientVolume(volume)
    if activeSounds.biome and activeSounds.biome.ambient then
        activeSounds.biome.ambient.Volume = volume
    end
end

return SoundSystem
