local RunService = game:GetService("RunService")

local Tilt = {}

local MAX_TILT = 4

function Tilt.init(character: Model)
    local humanoid = character.Humanoid :: Humanoid
    local hrp = character.HumanoidRootPart :: Part
    local rootJoint = hrp.RootJoint :: Motor6D

    local BASE_C0 = rootJoint.C0

    RunService:BindToRenderStep("CharacterTilt", Enum.RenderPriority.Character.Value, function()
		local localMoveDir = hrp.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
		local tiltX = math.clamp(localMoveDir.X * math.rad(MAX_TILT), math.rad(-MAX_TILT), math.rad(MAX_TILT))
		local tiltY = math.clamp(localMoveDir.Z * math.rad(MAX_TILT), math.rad(-MAX_TILT), math.rad(MAX_TILT))
        
        rootJoint.C0 = rootJoint.C0:Lerp(BASE_C0 * CFrame.Angles(-tiltY, -tiltX, 0), 0.1)
	end)
end

function Tilt.stop() 
    RunService:UnbindFromRenderStep("CharacterTilt")
end

return Tilt
