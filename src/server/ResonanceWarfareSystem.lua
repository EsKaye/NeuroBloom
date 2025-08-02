--[[
    ResonanceWarfareSystem.lua
    Handles resonance-based combat mechanics between players.

    Features:
    - Resonance charge calculation
    - Simple battle resolution
    - Battle history tracking
]]

local HttpService = game:GetService("HttpService")

local ResonanceWarfareSystem = {}

-- Constants
ResonanceWarfareSystem.RESONANCE_TYPES = {
    HARMONIC = "harmonic",
    DISSONANT = "dissonant"
}

-- Private state
local activeBattles = {}
local battleHistory = {}
local playerStats = {}

-- Calculate resonance strength from emotional table
local function calculateResonance(emotions)
    local strength = 0
    for _, value in pairs(emotions or {}) do
        if type(value) == "number" then
            strength += value
        end
    end
    return math.clamp(strength / 4, 0, 1)
end

-- Finalize a battle and store results
local function resolveBattle(battle)
    local p1 = calculateResonance(battle.player1.emotions)
    local p2 = calculateResonance(battle.player2.emotions)

    local p1Stat = playerStats[battle.player1.id] or {}
    local p2Stat = playerStats[battle.player2.id] or {}

    -- Basic attack/defense modifiers
    p1 *= p1Stat.attack or 1
    p2 *= p2Stat.defense or 1

    battle.winner = p1 >= p2 and battle.player1.id or battle.player2.id
    battle.endTime = os.time()

    battleHistory[battle.id] = battle
    activeBattles[battle.id] = nil
end

-- Public API
function ResonanceWarfareSystem.init()
    activeBattles = {}
    battleHistory = {}
    playerStats = {}
end

function ResonanceWarfareSystem.registerPlayer(playerId, stats)
    playerStats[playerId] = stats or {attack = 1, defense = 1}
end

function ResonanceWarfareSystem.startBattle(player1, player2)
    if not player1 or not player2 then return nil end

    local battle = {
        id = HttpService:GenerateGUID(),
        player1 = player1,
        player2 = player2,
        startTime = os.time()
    }

    activeBattles[battle.id] = battle
    resolveBattle(battle)

    return battle
end

function ResonanceWarfareSystem.getActiveBattles()
    return activeBattles
end

function ResonanceWarfareSystem.getBattleHistory()
    return battleHistory
end

return ResonanceWarfareSystem
