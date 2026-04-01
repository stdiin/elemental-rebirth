local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Dash = {}

local MAX_FORCE = 1e5
local POWER = 75
local COOLDOWN = 2

function Dash.init(character: Model)
    local hrp = character.HumanoidRootPart
    local humanoid = character.Humanoid :: Humanoid

    local lastDash = os.clock()

	ContextActionService:BindAction("Dash", function(_, state)
		if state == Enum.UserInputState.Begin and os.clock() - lastDash > COOLDOWN then
            local lv = Instance.new("LinearVelocity")
            lv.Visible = true
            lv.MaxForce = MAX_FORCE
            lv.Attachment0 = hrp.RootAttachment
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
            lv.PrimaryTangentAxis = vector.create(1, 0, 0)
            lv.SecondaryTangentAxis = vector.create(0, 0, 1)
            lv.Parent = hrp

            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude == 0 then
                moveDir = -hrp.CFrame.LookVector
            end

            local vx = moveDir.X
            local vy = moveDir.Z

            lv.PlaneVelocity = Vector2.new(vx, vy) * POWER

            Debris:AddItem(lv, 0.3)
            lastDash = os.clock()
		end
	end, true, Enum.KeyCode.Q)
end

function Dash.stop() 
    ContextActionService:UnbindAction("Dash")
end

return Dash