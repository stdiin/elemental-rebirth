local ReplicatedStorage = game:GetService("ReplicatedStorage")

local replicate = ReplicatedStorage:WaitForChild("_replicate") :: RemoteEvent
local Signal = require(ReplicatedStorage:WaitForChild("Packages").Signal)

local data = {}
local signals = {}

local Replicator = setmetatable({
	loaded = Signal.new(),
}, {
	__index = function(_, i)
		return data[i]
	end,
})

replicate.OnClientEvent:Connect(function(k: { [string]: any } | string, v: any?)
	if type(k) == "table" then
		data = k
		Replicator.loaded:Fire()
	else
		local path = string.split(k, ".")
        local root = path[1]

		if #path > 1 then
			local pointer = data

			for i = 1, #path - 1 do
                local key = tonumber(path[i]) or path[i]
				pointer = pointer[key]
			end

            local finalKey = tonumber(path[#path]) or path[#path]
            pointer[finalKey] = v
        else
            data[k] = v
		end

		if signals[root] then
			signals[root]:Fire(data[root])
		end
	end
end)

function Replicator.changed(key: string): typeof(Signal.new())
	signals[key] = signals[key] or Signal.new()
	return signals[key]
end

return Replicator
