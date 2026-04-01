local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(caster)
    local character = caster.Character
    local hrp = character.HumanoidRootPart :: Part
    
    local ring = ReplicatedStorage.Assets.FireRing:Clone() :: Part
    ring.Position = hrp.Position
    ring.Parent = workspace

    ring.Wave:Emit(500)

    Debris:AddItem(ring, 5)
end
