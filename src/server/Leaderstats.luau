local Leaderstats = {}

local function toRoman(num)
	local romanMap = {
		{ 1000, "M" },
		{ 900, "CM" },
		{ 500, "D" },
		{ 400, "CD" },
		{ 100, "C" },
		{ 90, "XC" },
		{ 50, "L" },
		{ 40, "XL" },
		{ 10, "X" },
		{ 9, "IX" },
		{ 5, "V" },
		{ 4, "IV" },
		{ 1, "I" },
	}

	local result = ""

	for _, pair in romanMap do
		local value, symbol = pair[1], pair[2]
		while num >= value do
			result ..= symbol
			num -= value
		end
	end

	return result
end

function Leaderstats.setup(player, data)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"

    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Value = data.level
    level.Parent = leaderstats

    local prestige = Instance.new("StringValue")
    prestige.Name = "Prestige"
    prestige.Value = toRoman(data.prestige)
    prestige.Parent = leaderstats

    local kills = Instance.new("IntValue")
    kills.Name = "Kills"
    kills.Value = data.kills
    kills.Parent = leaderstats

    leaderstats.Parent = player
end

return Leaderstats