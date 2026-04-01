local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage:WaitForChild("Packages").Janitor)

local Movement = {}
local Dash = require(script.Dash)
local DoubleJump = require(script.DoubleJump)
local Sprint = require(script.Sprint)
local Tilt = require(script.Tilt)

local player = Players.LocalPlayer

function Movement.init()
	local character = player.CharacterAdded:Wait()
    local humanoid = character.Humanoid

	local janitor = Janitor.new()

	janitor:Add(function()
		Sprint.stop()
		DoubleJump.stop()
	end)

	humanoid.Died:Once(function()
		janitor:Cleanup()
	end)

	character.Destroying:Once(function()
		janitor:Cleanup()
	end)

	Sprint.init(humanoid)
	DoubleJump.init(humanoid)
    Tilt.init(character)
    Dash.init(character)
end

return Movement
