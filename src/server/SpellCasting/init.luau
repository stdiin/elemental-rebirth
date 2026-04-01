local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpellTypes = require(ReplicatedStorage.Modules.SpellTypes)
local Progression = require(script.Parent.Progression)
local Replicator = require(script.Parent.Replicator)
local Spells = require(ReplicatedStorage.Modules.Spells)
local SpellCasting = {}

local chargingData = {}
local cooldownData = {}

function SpellCasting.startCasting(player, slot)
	local character = player.Character
	if not character or character.Humanoid.Health <= 0 then
		return
	end

	local replicator = Replicator.get(player)
	local spellId = replicator.spells.equipped[slot]

	if not spellId then
		return false
	end

	local spell = Spells[spellId]
	local spellType = SpellTypes[spell.Type]
	local anchor = spellType and spellType.Anchor or spell.Anchor

	if anchor then
		character.HumanoidRootPart.Anchored = true
	end

	if replicator.mana < spell.ManaReq then
		return false
	end

	cooldownData[player] = cooldownData[player] or {}
	local cooldown = cooldownData[player][slot]
	if cooldown then
		local elapsed = os.clock() - cooldown.timestamp
		if elapsed < cooldown.duration then
			return false
		end
	end

	chargingData[player] = {slot = slot, chargeStart = os.clock()}

	return true
end

function SpellCasting.stopCasting(player, ...)
	local character = player.Character
	if not character or character.Humanoid.Health <= 0 then
		return
	end

	character.HumanoidRootPart.Anchored = false

	local chargeData = chargingData[player]

	if not chargeData then
		return
	end

	local slot = chargeData.slot
	local chargeStart = chargeData.chargeStart

	local chargeDuration = os.clock() - chargeStart

	chargingData[player] = nil

	SpellCasting.cast(player, slot, chargeDuration, ...)
end

function SpellCasting.cast(player, slot, chargeDuration, ...)
	local replicator = Replicator.get(player)
	local spellId = replicator.spells.equipped[slot]
	local spell = Spells[spellId]

	replicator.mana -= spell.ManaReq

	local handler = script.Elements:FindFirstChild(spell.Element)

	if handler then
		handler = require(handler)
		local fn = handler[spellId]
		
		if type(fn) == "function" then
			fn(player, chargeDuration, ...)

			cooldownData[player] = cooldownData[player] or {}
			cooldownData[player][slot] = {
				timestamp = os.clock(),
				duration = spell.Cooldown,
			}

			Progression.addExp(player, spell.ExpGain)
		end
	end
end

-- while true do
-- 	task.wait(60)

-- 	for _, player in Players:GetPlayers() do
-- 		local entry = slotCooldowns[player]
-- 		if #entry == 0 then
-- 			slotCooldowns[player] = nil
-- 		end
-- 	end
-- end

return SpellCasting
