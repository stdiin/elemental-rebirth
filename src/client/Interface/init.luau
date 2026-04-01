local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

local Interface = {}

function Interface.handle(guiObj, onDisable, ...)
	local handler = script:FindFirstChild(guiObj.Name)
	if not handler then
		warn("No handler found for ", guiObj.Name)
		return
	end

    guiObj.Parent = PlayerGui
    require(handler)(guiObj, onDisable, ...)
end

return Interface
