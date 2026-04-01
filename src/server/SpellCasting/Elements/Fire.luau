local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Projectile = require(ReplicatedStorage.Modules.Projectile)
local Replicator = require(ServerScriptService.Server.Replicator)
local SpellReplicator = require(ReplicatedStorage.Modules.SpellReplicator)
local Spells = require(ReplicatedStorage.Modules.Spells)

local Fire = {}

function Fire.Fireball(caster, chargeDuration, target)
	print(`FIREBALL REQUESTED:\nCaster: {caster}\nCharge Duration: {chargeDuration}\nTarget: {target}`)

	local chargePercent = math.clamp(chargeDuration / Spells["Fireball"].MaxChargeDuration, 0, 1)

	local character = caster.Character
	local hrp = character.HumanoidRootPart

	local origin = hrp.Position + hrp.CFrame.LookVector * 3
	local dir = (target - origin).Unit
	local speed = 75 + (chargePercent * 50)
	local maxDistance = Spells["Fireball"].MaxDistance

	Projectile.new({
		origin = origin,
		direction = dir,
		speed = speed,
		maxDistance = maxDistance,
		filter = { character },
	})
		:onImpact(function(position)
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			overlapParams.FilterDescendantsInstances = { character }

			local parts = workspace:GetPartBoundsInRadius(position, 20, overlapParams)
			local damaged = {}

			for _, part in parts do
				local model = part:FindFirstAncestorWhichIsA("Model")

				if not model then
					continue
				end

				if damaged[model] then
					continue
				else
					damaged[model] = true
				end

				local humanoid = model:FindFirstChild("Humanoid")

				if humanoid then
					humanoid:TakeDamage(Spells["Fireball"].Damage)
					damaged[humanoid] = true

					if Players:GetPlayerFromCharacter(model) and humanoid.Health <= 0 then
						local replicator = Replicator.get(caster)
						replicator.kills += 1
						caster.leaderstats.Kills.Value += 1
					end
				end
			end
		end)
		:run()

	SpellReplicator.replicate("Fireball", caster, origin, target, speed, maxDistance)
end

function Fire.FireStomp(caster, chargeDuration)
	print(`FIRE STOMP REQUESTED:\nCaster: {caster}\nCharge Duration: {chargeDuration}`)

	SpellReplicator.replicate("FireStomp", caster)
end

return Fire
