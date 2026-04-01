local Replicator = require(script.Parent.Replicator)
local Progression = {}

local BASE_EXP = 100
local BASE_MANA = 100
local MANA_PER_LEVEL = 10

local function calculateMaxExp(level)
	return math.floor(BASE_EXP * level^1.5)
end

local function calculateMaxMana(level)
	return BASE_MANA + (level * MANA_PER_LEVEL)
end

function Progression.addExp(player, amount)
	local replicator = Replicator.get(player)

	replicator.exp += amount

	Progression.updateStats(player)
end

function Progression.updateStats(player)
	local replicator = Replicator.get(player)

	if replicator.exp >= replicator.maxExp then
		replicator.level += 1
		player.leaderstats.Level.Value = replicator.level

		replicator.exp = 0
		replicator.maxExp = calculateMaxExp(replicator.level)
		replicator.maxMana = calculateMaxMana(replicator.level)
	end
end

return Progression