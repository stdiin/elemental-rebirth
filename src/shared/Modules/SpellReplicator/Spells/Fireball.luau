local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Projectile = require(ReplicatedStorage.Modules.Projectile)
local Spells = require(ReplicatedStorage.Modules.Spells)

return function(caster, origin, target, speed)
	local maxDistance = Spells["Fireball"].MaxDistance

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { caster.Character }

	local dir = (target - origin).Unit

	local fireball = ReplicatedStorage.Assets.Fireball:Clone() :: Part
	fireball.CFrame = CFrame.lookAt(origin, origin + dir)
	fireball.Parent = workspace

	fireball.Spawn:Play()

	Projectile.new({
		origin = origin,
		direction = dir,
		speed = speed,
		maxDistance = maxDistance,
		filter = { caster.Character },
	})
		:onUpdate(function(position)
			fireball.Position = position
		end)
		:onImpact(function(position)
			local impact = fireball.Impact
			impact.Position = position
			impact.Parent = workspace

			impact.Explosion:Play()

			for _, particle in impact:GetChildren() do
				if particle:IsA("ParticleEmitter") then
					particle:Emit(particle.Rate)
				end
			end

			Debris:AddItem(impact, 5)
			fireball:Destroy()
		end)
		:run()
end
