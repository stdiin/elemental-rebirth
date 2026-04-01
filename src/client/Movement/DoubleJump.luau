local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local DoubleJump = {}

local INTERVAL = 0.5
local janitor = Janitor.new()

function DoubleJump.init(humanoid: Humanoid)
	local lastJump = os.clock()
	local hasDoubleJump = true

	janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Space then
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				if os.clock() - lastJump < INTERVAL and hasDoubleJump then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					hasDoubleJump = false
				end
			end
		end
	end))

	janitor:Add(humanoid.StateChanged:Connect(function(state)
		if state == Enum.HumanoidStateType.Landed then
			hasDoubleJump = true
		elseif state == Enum.HumanoidStateType.Jumping then
			lastJump = os.clock()
		end
	end))
end

function DoubleJump.stop()
	janitor:Cleanup()
end

return DoubleJump
