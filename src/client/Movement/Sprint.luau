local ContextActionService = game:GetService("ContextActionService")
local Sprint = {}

local SPEED_INCREMENT = 15

function Sprint.init(humanoid: Humanoid)
    local BASE_WALK_SPEED = humanoid.WalkSpeed

	local sprinting = false

	ContextActionService:BindAction("Sprint", function(_, state)
		if state == Enum.UserInputState.Begin then
			sprinting = not sprinting

            if sprinting then
                humanoid.WalkSpeed = BASE_WALK_SPEED + SPEED_INCREMENT
            else
                humanoid.WalkSpeed = BASE_WALK_SPEED
            end
		end
	end, true, Enum.KeyCode.LeftControl)
end

function Sprint.stop()
    ContextActionService:UnbindAction("Sprint")
end

return Sprint
