local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Stats = require(ReplicatedStorage.Modules.Lib.Stats)

local CommandService = {}

local statCommand = Instance.new("TextChatCommand")
statCommand.PrimaryAlias = "/set"
statCommand.SecondaryAlias = "/get"
statCommand.Parent = TextChatService

statCommand.Triggered:Connect(function(textSource, message)
	if textSource.UserId ~= game.CreatorId then
		return
	end

	local args = string.split(message, " ")

	if args[1] == "/set" then
		local stat = args[2]
		local value = args[3]

		if not stat or not value then
			warn(`Invalid arguments: stat = {stat}, value = {value}`)
			return
		end

		local target = args[4]

		local player

		if not target then
			player = Players:GetPlayerByUserId(game.CreatorId)
		else
			player = Players:FindFirstChild(target)
			if not player then
				warn(`Player "{target}" not found`)
				return
			end
		end

		Stats.set(player, stat, tonumber(value))
	elseif args[1] == "/get" then
		local stat = args[2]

		if not stat then
			warn("/get command for all stats is not supported")
			return
		end

		local target = args[3]

		local player

		if not target then
			player = Players:GetPlayerByUserId(game.CreatorId)
		else
			player = Players:FindFirstChild(target)
			if not player then
				warn(`Player "{target}" not found`)
				return
			end
		end

		local value = Stats.get(player, stat)

		print(`{stat}: {value}`)
	end
end)

return CommandService
