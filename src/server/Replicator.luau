local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicator = {}

export type Replicator<T> = T & {
	destroy: (self: Replicator<T>) -> (),
}

local replicators = {}

local replicate = Instance.new("RemoteEvent")
replicate.Name = "_replicate"
replicate.Parent = ReplicatedStorage

function Replicator.build<T>(player: Player, data: T): Replicator<T>
	local self = {
		destroy = function(t)
			table.clear(t)
			replicators[player] = nil
		end,
	}

	local function createProxy(wrapped, path)
		return setmetatable({}, {
			__index = function(_, i)
				local value = wrapped[i]

				if type(value) == "table" then
					return createProxy(value, path .. "." .. i)
				end

				return value
			end,
			__newindex = function(_, i, v)
				wrapped[i] = v
				replicate:FireClient(player, path .. "." .. i, v)
			end,
		})
	end

	setmetatable(self, {
		__index = function(_, i)
			if type(data[i]) == "table" then
				return createProxy(data[i], i)
			end

			return data[i]
		end,
		__newindex = function(_, i, v)
			data[i] = v
			replicate:FireClient(player, i, v)
		end,
		__iter = function()
			return next, data
		end,
	})

	replicators[player] = self
	replicate:FireClient(player, data)

	return self
end

function Replicator.get(player: Player)
	return replicators[player]
end

return Replicator
