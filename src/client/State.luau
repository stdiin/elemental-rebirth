local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Packages").Signal)

local data = {}
local signals = {}

local State = {}

function State.changed(state: string): typeof(Signal.new())
	signals[state] = signals[state] or Signal.new()
	return signals[state]
end

setmetatable(State, {
    __index = data,
	__newindex = function(_, i, v)
		data[i] = v
        signals[i] = signals[i] or Signal.new()
        signals[i]:Fire(v)
	end,
})

return State
