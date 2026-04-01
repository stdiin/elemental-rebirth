local ContextActionService = game:GetService("ContextActionService")

local Replicator = require(script.Parent.Replicator)
local State = require(script.Parent.State)

local KeyCodes = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five }

local SlotSelection = {}

function SlotSelection.select(slotIndex)
	if not Replicator.spells.equipped[slotIndex] then
		return
	end

	if State.selectedSlot == slotIndex then
		State.selectedSlot = nil
	else
		State.selectedSlot = slotIndex
	end
end

function SlotSelection.startListening()
	for i = 1, 5 do
		ContextActionService:BindAction("Slot" .. i .. "Selection", function(_, inputState)
			if inputState == Enum.UserInputState.Begin then
				SlotSelection.select(i)
			end
		end, false, KeyCodes[i])
	end
end

function SlotSelection.stopListening()
	for i = 1, 5 do
		ContextActionService:UnbindAction("Slot" .. i .. "Selection")
	end
end

return SlotSelection
