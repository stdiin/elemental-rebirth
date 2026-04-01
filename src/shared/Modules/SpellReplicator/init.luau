local RunService = game:GetService("RunService")
local SpellReplicator = {}

if RunService:IsServer() then
	local replicate = Instance.new("UnreliableRemoteEvent")
	replicate.Name = "_replicate"
    replicate.Parent = script

	function SpellReplicator.replicate(spell, ...)
		local handler = script.Spells:FindFirstChild(spell)
		if handler then
			replicate:FireAllClients(spell, ...)
		end
	end
else
    local replicate = script:FindFirstChild("_replicate") :: UnreliableRemoteEvent

    replicate.OnClientEvent:Connect(function(spell, ...)
        require(script.Spells[spell] :: ModuleScript)(...)
    end)
end

return SpellReplicator
