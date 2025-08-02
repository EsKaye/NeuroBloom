--[[
    GrandTheftLuxIntegration.lua
    Integrates NeuroBloom with Grand Theft Lux heist mechanics.

    Features:
    - Tracks active lux heists
    - Resolves heists and awards lux
    - Maintains heist history for analytics
]]

local HttpService = game:GetService("HttpService")

local GrandTheftLuxIntegration = {}

-- Private state
local activeHeists = {}
local heistHistory = {}
local playerLux = {}

-- Public API
function GrandTheftLuxIntegration.init()
    activeHeists = {}
    heistHistory = {}
    playerLux = {}
end

-- Register a player with current lux balance
function GrandTheftLuxIntegration.registerPlayer(playerId, currentLux)
    playerLux[playerId] = currentLux or 0
end

function GrandTheftLuxIntegration.unregisterPlayer(playerId)
    playerLux[playerId] = nil
end

-- Start a new lux heist for a player
function GrandTheftLuxIntegration.startHeist(playerId, targetLux)
    if not playerId then return nil end

    local heist = {
        id = HttpService:GenerateGUID(),
        playerId = playerId,
        targetLux = targetLux or 0,
        startTime = os.time()
    }

    activeHeists[heist.id] = heist
    return heist
end

-- Complete an existing heist and award lux if successful
function GrandTheftLuxIntegration.completeHeist(heistId, success)
    local heist = activeHeists[heistId]
    if not heist then return nil end

    heist.success = success
    heist.endTime = os.time()
    heist.reward = success and heist.targetLux or 0

    playerLux[heist.playerId] = (playerLux[heist.playerId] or 0) + heist.reward

    heistHistory[heist.id] = heist
    activeHeists[heistId] = nil

    return heist
end

-- Retrieve a player's lux balance
function GrandTheftLuxIntegration.getLuxBalance(playerId)
    return playerLux[playerId] or 0
end

function GrandTheftLuxIntegration.getActiveHeists()
    return activeHeists
end

function GrandTheftLuxIntegration.getHeistHistory()
    return heistHistory
end

return GrandTheftLuxIntegration

