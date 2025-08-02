--[[
    GardenExpansionSystem.lua
    Provides logic for expanding a player's personal garden space.

    Features:
    - Expansion tracking
    - Simple integration with GardenScene
]]

local HttpService = game:GetService("HttpService")
local GardenScene = require(script.Parent.GardenScene)

local GardenExpansionSystem = {}

-- Types of expansion available
GardenExpansionSystem.EXPANSION_TYPES = {
    EXTRA_PLOT = "extra_plot",
    SERENITY_POOL = "serenity_pool",
    SKY_PLATFORM = "sky_platform"
}

-- Private state
local playerExpansions = {}

-- Apply visual effects for an expansion
local function applyExpansionVisual(expansionType)
    if expansionType == GardenExpansionSystem.EXPANSION_TYPES.EXTRA_PLOT then
        GardenScene.updateBiomeEffects("LIGHT_MEADOW", 1.2)
    elseif expansionType == GardenExpansionSystem.EXPANSION_TYPES.SERENITY_POOL then
        GardenScene.updateBiomeEffects("VOID_BASIN", 1.5)
    elseif expansionType == GardenExpansionSystem.EXPANSION_TYPES.SKY_PLATFORM then
        GardenScene.updateBiomeEffects("SHADOW_GARDEN", 1.3)
    end
end

-- Public API
function GardenExpansionSystem.init()
    playerExpansions = {}
end

function GardenExpansionSystem.applyExpansion(playerId, expansionType)
    if not playerId or not expansionType then return end

    playerExpansions[playerId] = playerExpansions[playerId] or {}

    table.insert(playerExpansions[playerId], {
        id = HttpService:GenerateGUID(),
        type = expansionType,
        timestamp = os.time()
    })

    applyExpansionVisual(expansionType)
end

function GardenExpansionSystem.getExpansions(playerId)
    return playerExpansions[playerId] or {}
end

return GardenExpansionSystem
