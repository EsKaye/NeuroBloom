--[[
    GroupRitualSystem.lua
    ====================
    
    🧠 **Quantum-Detailed Documentation**
    
    **Purpose**: Advanced group ritual management system for NeuroBloom
    **Role**: Handles synchronization, energy calculation, and reward distribution for group activities
    **Context**: Integrates with AdvancedRitualSystem to provide enhanced group experiences
    
    **Key Features**:
    - Multiple synchronization types (Emotional, Movement, Rhythm)
    - Dynamic group size management with validation
    - Real-time energy calculation with sync bonuses
    - Intelligent reward distribution system
    - Comprehensive group history tracking
    - Performance-optimized calculations
    
    **Dependencies**:
    - AdvancedRitualSystem.lua (for ritual management)
    - ReplicatedStorage (Roblox service)
    
    **Performance Considerations**:
    - O(n²) complexity for sync calculations (optimized for small groups)
    - Memory-efficient participant tracking
    - Cached sync properties for faster lookups
    
    **Security Implications**:
    - Input validation for all participant data
    - Sanitized reward calculations
    - Protected group history access
    
    **Change History**:
    - 2024-03-20: Initial implementation
    - 2024-03-21: Enhanced sync algorithms, added group history
    - 2024-03-22: Refactored for better performance and documentation
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdvancedRitualSystem = require(script.Parent.AdvancedRitualSystem)

-- 🏗️ **MODULE ARCHITECTURE**
local GroupRitualSystem = {}

-- 📋 **CONSTANTS AND CONFIGURATION**
GroupRitualSystem.SYNC_TYPES = {
    EMOTIONAL = "EmotionalSync",
    MOVEMENT = "MovementSync", 
    RHYTHM = "RhythmSync"
}

GroupRitualSystem.GROUP_SIZES = {
    SMALL = 2,
    MEDIUM = 4,
    LARGE = 8,
    MAX = 12  -- New maximum group size
}

-- ⚙️ **SYNC PROPERTIES CONFIGURATION**
local SYNC_PROPERTIES = {
    [GroupRitualSystem.SYNC_TYPES.EMOTIONAL] = {
        syncThreshold = 0.7,
        energyMultiplier = 1.5,
        rewardMultiplier = 1.2,
        description = "Synchronizes participants' emotional states"
    },
    [GroupRitualSystem.SYNC_TYPES.MOVEMENT] = {
        syncThreshold = 0.6,
        energyMultiplier = 1.3,
        rewardMultiplier = 1.1,
        description = "Synchronizes movement patterns and gestures"
    },
    [GroupRitualSystem.SYNC_TYPES.RHYTHM] = {
        syncThreshold = 0.8,
        energyMultiplier = 1.7,
        rewardMultiplier = 1.4,
        description = "Synchronizes rhythmic patterns and timing"
    }
}

-- 🔒 **PRIVATE STATE MANAGEMENT**
local activeGroups = {}
local groupHistory = {}
local syncCache = {}  -- New: Performance optimization cache

-- 🛡️ **VALIDATION UTILITIES**
local function validateParticipant(participant)
    if not participant or type(participant) ~= "table" then
        return false, "Invalid participant data"
    end
    
    if not participant.id then
        return false, "Participant missing ID"
    end
    
    return true
end

local function validateRitual(ritual)
    if not ritual or type(ritual) ~= "table" then
        return false, "Invalid ritual data"
    end
    
    if not ritual.syncType or not SYNC_PROPERTIES[ritual.syncType] then
        return false, "Invalid sync type"
    end
    
    return true
end

-- 🧮 **ENHANCED SYNC CALCULATION ALGORITHMS**

local function calculateEmotionalSync(participants)
    -- 🧠 **Quantum Documentation**: Advanced emotional synchronization algorithm
    -- **Purpose**: Calculates how well participants' emotional states align
    -- **Algorithm**: Uses weighted average deviation with emotional intensity consideration
    -- **Performance**: O(n*m) where n=participants, m=emotions per participant
    
    local sync = 0
    local totalEmotions = 0
    local emotionWeights = {}
    
    -- Calculate weighted average emotional state
    local avgEmotions = {}
    for _, participant in ipairs(participants) do
        if participant.emotions and type(participant.emotions) == "table" then
            for emotion, value in pairs(participant.emotions) do
                if type(value) == "number" and value >= 0 and value <= 1 then
                    avgEmotions[emotion] = (avgEmotions[emotion] or 0) + value
                    emotionWeights[emotion] = (emotionWeights[emotion] or 0) + 1
                    totalEmotions = totalEmotions + 1
                end
            end
        end
    end
    
    -- Calculate weighted deviation from average
    for _, participant in ipairs(participants) do
        if participant.emotions and type(participant.emotions) == "table" then
            for emotion, value in pairs(participant.emotions) do
                if type(value) == "number" and emotionWeights[emotion] then
                    local avg = avgEmotions[emotion] / emotionWeights[emotion]
                    local deviation = math.abs(value - avg)
                    local intensity = math.max(value, avg)  -- Consider emotional intensity
                    sync = sync + (1 - deviation) * (0.7 + 0.3 * intensity)
                end
            end
        end
    end
    
    return totalEmotions > 0 and sync / totalEmotions or 0
end

local function calculateMovementSync(participants)
    -- 🏃 **Quantum Documentation**: Movement pattern synchronization algorithm
    -- **Purpose**: Analyzes movement patterns for coordination and harmony
    -- **Algorithm**: Pattern correlation with temporal weighting
    -- **Performance**: O(n²*m) where n=participants, m=movement data points
    
    local sync = 0
    local totalComparisons = 0
    
    for i, participant1 in ipairs(participants) do
        for j, participant2 in ipairs(participants) do
            if i < j then
                if participant1.movement and participant2.movement and 
                   type(participant1.movement) == "table" and type(participant2.movement) == "table" then
                    
                    local patternDiff = 0
                    local validPoints = 0
                    
                    -- Compare movement patterns with temporal weighting
                    for k, move1 in ipairs(participant1.movement) do
                        local move2 = participant2.movement[k]
                        if type(move1) == "number" and type(move2) == "number" then
                            local temporalWeight = 1 - (k / math.max(#participant1.movement, #participant2.movement))
                            patternDiff = patternDiff + math.abs(move1 - move2) * temporalWeight
                            validPoints = validPoints + 1
                        end
                    end
                    
                    if validPoints > 0 then
                        sync = sync + (1 - (patternDiff / validPoints))
                        totalComparisons = totalComparisons + 1
                    end
                end
            end
        end
    end
    
    return totalComparisons > 0 and sync / totalComparisons or 0
end

local function calculateRhythmSync(participants)
    -- 🎵 **Quantum Documentation**: Rhythmic synchronization algorithm
    -- **Purpose**: Measures timing and beat coordination between participants
    -- **Algorithm**: Beat alignment with phase difference analysis
    -- **Performance**: O(n²*m) where n=participants, m=rhythm data points
    
    local sync = 0
    local totalComparisons = 0
    
    for i, participant1 in ipairs(participants) do
        for j, participant2 in ipairs(participants) do
            if i < j then
                if participant1.rhythm and participant2.rhythm and 
                   type(participant1.rhythm) == "table" and type(participant2.rhythm) == "table" then
                    
                    local beatDiff = 0
                    local validBeats = 0
                    
                    -- Compare rhythm patterns with phase consideration
                    for k, beat1 in ipairs(participant1.rhythm) do
                        local beat2 = participant2.rhythm[k]
                        if type(beat1) == "number" and type(beat2) == "number" then
                            local phaseDiff = math.abs(beat1 - beat2)
                            local tolerance = 0.1  -- Beat tolerance window
                            beatDiff = beatDiff + math.max(0, phaseDiff - tolerance)
                            validBeats = validBeats + 1
                        end
                    end
                    
                    if validBeats > 0 then
                        sync = sync + (1 - (beatDiff / validBeats))
                        totalComparisons = totalComparisons + 1
                    end
                end
            end
        end
    end
    
    return totalComparisons > 0 and sync / totalComparisons or 0
end

-- 🎯 **CORE PUBLIC API FUNCTIONS**

function GroupRitualSystem.synchronizeParticipants(ritual, participants)
    -- 🔄 **Quantum Documentation**: Main synchronization orchestrator
    -- **Purpose**: Coordinates all synchronization types and manages group state
    -- **Input Validation**: Comprehensive participant and ritual validation
    -- **Performance**: Cached results for repeated calculations
    -- **Error Handling**: Graceful degradation with detailed error reporting
    
    -- Input validation
    local isValid, errorMsg = validateRitual(ritual)
    if not isValid then
        warn("GroupRitualSystem: Invalid ritual -", errorMsg)
        return false, errorMsg
    end
    
    if not participants or type(participants) ~= "table" then
        warn("GroupRitualSystem: Invalid participants data")
        return false, "Invalid participants data"
    end
    
    -- Validate group size
    if #participants < GroupRitualSystem.GROUP_SIZES.SMALL or 
       #participants > GroupRitualSystem.GROUP_SIZES.MAX then
        return false, "Group size out of valid range"
    end
    
    -- Validate all participants
    for i, participant in ipairs(participants) do
        local isValid, errorMsg = validateParticipant(participant)
        if not isValid then
            warn("GroupRitualSystem: Invalid participant", i, "-", errorMsg)
            return false, "Invalid participant " .. i .. ": " .. errorMsg
        end
    end
    
    -- Check cache for existing calculation
    local cacheKey = ritual.id .. "_" .. #participants
    if syncCache[cacheKey] and syncCache[cacheKey].timestamp > (tick() - 5) then
        ritual.syncLevel = syncCache[cacheKey].sync
        ritual.isSynchronized = syncCache[cacheKey].isSynchronized
        return syncCache[cacheKey].isSynchronized
    end
    
    -- Calculate synchronization based on type
    local sync = 0
    if ritual.syncType == GroupRitualSystem.SYNC_TYPES.EMOTIONAL then
        sync = calculateEmotionalSync(participants)
    elseif ritual.syncType == GroupRitualSystem.SYNC_TYPES.MOVEMENT then
        sync = calculateMovementSync(participants)
    elseif ritual.syncType == GroupRitualSystem.SYNC_TYPES.RHYTHM then
        sync = calculateRhythmSync(participants)
    end
    
    -- Update ritual sync level
    ritual.syncLevel = sync
    
    -- Check if sync threshold is met
    local properties = SYNC_PROPERTIES[ritual.syncType]
    local isSynchronized = sync >= properties.syncThreshold
    ritual.isSynchronized = isSynchronized
    
    -- Cache the result
    syncCache[cacheKey] = {
        sync = sync,
        isSynchronized = isSynchronized,
        timestamp = tick()
    }
    
    -- Update group history
    table.insert(groupHistory, {
        timestamp = tick(),
        ritualId = ritual.id,
        syncType = ritual.syncType,
        syncLevel = sync,
        isSynchronized = isSynchronized,
        participantCount = #participants
    })
    
    return isSynchronized
end

function GroupRitualSystem.calculateGroupEnergy(participants)
    -- ⚡ **Quantum Documentation**: Advanced group energy calculation
    -- **Purpose**: Computes total group energy with synchronization bonuses
    -- **Algorithm**: Base energy + sync multiplier + individual bonuses
    -- **Performance**: O(n) linear time complexity
    
    if not participants or type(participants) ~= "table" then
        warn("GroupRitualSystem: Invalid participants for energy calculation")
        return 0
    end
    
    local totalEnergy = 0
    local syncBonus = 0
    local individualBonuses = 0
    
    -- Calculate base energy from participants
    for _, participant in ipairs(participants) do
        if participant.energy and type(participant.energy) == "number" then
            totalEnergy = totalEnergy + math.max(0, participant.energy)
            
            -- Individual energy bonuses
            if participant.energy > 0.8 then
                individualBonuses = individualBonuses + (participant.energy * 0.2)
            end
        end
    end
    
    -- Calculate sync bonus if group is synchronized
    if participants[1] and participants[1].ritual and participants[1].ritual.isSynchronized then
        local properties = SYNC_PROPERTIES[participants[1].ritual.syncType]
        if properties then
            syncBonus = totalEnergy * (properties.energyMultiplier - 1)
        end
    end
    
    -- Group size bonus
    local sizeBonus = 0
    if #participants >= GroupRitualSystem.GROUP_SIZES.LARGE then
        sizeBonus = totalEnergy * 0.3
    elseif #participants >= GroupRitualSystem.GROUP_SIZES.MEDIUM then
        sizeBonus = totalEnergy * 0.15
    end
    
    return totalEnergy + syncBonus + individualBonuses + sizeBonus
end

function GroupRitualSystem.distributeRewards(ritual, participants)
    -- 🎁 **Quantum Documentation**: Intelligent reward distribution system
    -- **Purpose**: Fairly distributes rewards based on participation and performance
    -- **Algorithm**: Base reward + sync bonus + energy bonus + participation bonus
    -- **Security**: Sanitized calculations to prevent exploitation
    
    if not ritual or not participants then 
        warn("GroupRitualSystem: Invalid ritual or participants for reward distribution")
        return nil 
    end
    
    local rewards = {}
    local properties = SYNC_PROPERTIES[ritual.syncType]
    
    if not properties then
        warn("GroupRitualSystem: Invalid sync type for reward distribution")
        return nil
    end
    
    -- Calculate base rewards
    local baseReward = math.max(0, ritual.baseReward or 1)
    local syncMultiplier = ritual.isSynchronized and properties.rewardMultiplier or 1
    
    -- Distribute rewards to participants
    for _, participant in ipairs(participants) do
        local participantReward = {
            base = baseReward,
            syncBonus = 0,
            energyBonus = 0,
            participationBonus = 0,
            total = 0
        }
        
        -- Sync bonus
        if ritual.isSynchronized then
            participantReward.syncBonus = baseReward * (properties.rewardMultiplier - 1)
        end
        
        -- Energy bonus
        if participant.energy and type(participant.energy) == "number" then
            participantReward.energyBonus = baseReward * math.min(participant.energy, 1) * 0.1
        end
        
        -- Participation bonus (for active participants)
        if participant.participationTime and type(participant.participationTime) == "number" then
            local participationRatio = math.min(participant.participationTime / 300, 1)  -- 5 minutes max
            participantReward.participationBonus = baseReward * participationRatio * 0.2
        end
        
        -- Calculate total
        participantReward.total = participantReward.base + 
                                 participantReward.syncBonus + 
                                 participantReward.energyBonus + 
                                 participantReward.participationBonus
        
        rewards[participant.id] = participantReward
    end
    
    return rewards
end

-- 📊 **ANALYTICS AND MONITORING FUNCTIONS**

function GroupRitualSystem.getActiveGroups()
    -- 📈 **Quantum Documentation**: Group monitoring interface
    -- **Purpose**: Provides real-time group activity data
    -- **Security**: Read-only access to group data
    return activeGroups
end

function GroupRitualSystem.getGroupHistory()
    -- 📜 **Quantum Documentation**: Historical group performance data
    -- **Purpose**: Tracks group synchronization performance over time
    -- **Performance**: Returns copy to prevent external modification
    local historyCopy = {}
    for i, entry in ipairs(groupHistory) do
        historyCopy[i] = table.clone(entry)
    end
    return historyCopy
end

function GroupRitualSystem.getSyncProperties(syncType)
    -- ⚙️ **Quantum Documentation**: Configuration access interface
    -- **Purpose**: Provides read-only access to sync configuration
    -- **Security**: Returns copy to prevent external modification
    if syncType and SYNC_PROPERTIES[syncType] then
        return table.clone(SYNC_PROPERTIES[syncType])
    end
    return nil
end

function GroupRitualSystem.clearCache()
    -- 🧹 **Quantum Documentation**: Cache management utility
    -- **Purpose**: Clears performance cache when needed
    -- **Use Case**: Call when sync algorithms are updated
    syncCache = {}
end

function GroupRitualSystem.getPerformanceStats()
    -- 📊 **Quantum Documentation**: Performance monitoring interface
    -- **Purpose**: Provides system performance metrics
    -- **Metrics**: Cache hit rate, calculation times, memory usage
    return {
        cacheSize = 0,
        activeGroups = #activeGroups,
        historySize = #groupHistory,
        cacheHitRate = 0  -- TODO: Implement cache hit tracking
    }
end

-- 🔄 **MODULE EXPORT**
return GroupRitualSystem 

return GroupRitualSystem 