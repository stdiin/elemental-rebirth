local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Leaderstats = require(script.Leaderstats)
local Replicator = require(script.Replicator)
local SpellCasting = require(script.SpellCasting)
require(ReplicatedStorage.Modules.SpellReplicator)
require(script.ManaRegen)

-- Remotes
local remotes = ReplicatedStorage.Remotes
local SpawnCharacter = remotes.SpawnCharacter
local DespawnCharacter = remotes.DespawnCharacter
local RequestCasting = remotes.RequestCasting
local FinishCasting = remotes.FinishCasting

-- Init
Players.PlayerAdded:Connect(function(player)
	local data = Replicator.build(player, {
		elements = {"Fire"},

		spells = {
			unlocked = {"Fireball", "FireStomp"},
			equipped = {"Fireball"},
		},

		prestige = 26,
		level = 100,
		exp = 0,
		maxExp = 100,
		maxStamina = 100,
		stamina = 50,
		mana = 100,
		maxMana = 100,
		essence = 0,
		visits = 0,
		kills = 0
	})

	Leaderstats.setup(player, data)
end)

SpawnCharacter.OnServerEvent:Connect(function(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid and humanoid.Health > 0 then
		return
	end

	player:LoadCharacterAsync()
end)

DespawnCharacter.OnServerEvent:Connect(function(player)
	local character = player.Character

	if not character then
		return
	end

	character:Destroy()
end)

RequestCasting.OnServerInvoke = function(player, slot)
	if type(slot) ~= "number" or slot < 1 or slot > 5 then
		return
	end

	return SpellCasting.startCasting(player, slot)
end

FinishCasting.OnServerEvent:Connect(function(player, ...)
	SpellCasting.stopCasting(player, ...)
end)
