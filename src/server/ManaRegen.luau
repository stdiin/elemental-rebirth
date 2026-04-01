local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Replicator = require(script.Parent.Replicator)

local manaAccumulator = {}

RunService.Heartbeat:Connect(function(dt)
    for _, player in Players:GetPlayers() do
        local replicator = Replicator.get(player)

        local regenRate = math.max(2, replicator.maxMana / 100)
        
		manaAccumulator[player] = (manaAccumulator[player] or 0) + regenRate * dt

		if manaAccumulator[player] >= 1 then
			local toAdd = math.floor(manaAccumulator[player])
			replicator.mana = math.min(replicator.mana + toAdd, replicator.maxMana)
			manaAccumulator[player] -= toAdd
		end
    end
end)

return nil