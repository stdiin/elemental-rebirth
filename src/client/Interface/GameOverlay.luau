local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Elements = require(ReplicatedStorage.Modules.Elements)
local Icon = require(ReplicatedStorage.Packages.Icon)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Replicator = require(ReplicatedFirst.Client.Replicator)
local SlotSelection = require(ReplicatedFirst.Client.SlotSelection)
local Spells = require(ReplicatedStorage.Modules.Spells)
local State = require(ReplicatedFirst.Client.State)

local function toRoman(num)
	local romanMap = {
		{ 1000, "M" },
		{ 900, "CM" },
		{ 500, "D" },
		{ 400, "CD" },
		{ 100, "C" },
		{ 90, "XC" },
		{ 50, "L" },
		{ 40, "XL" },
		{ 10, "X" },
		{ 9, "IX" },
		{ 5, "V" },
		{ 4, "IV" },
		{ 1, "I" },
	}

	local result = ""

	for _, pair in romanMap do
		local value, symbol = pair[1], pair[2]
		while num >= value do
			result ..= symbol
			num -= value
		end
	end

	return result
end

local barTweenInfo = TweenInfo.new(0.25)

return function(gui, onDisable)
	local janitor = Janitor.new()
	gui.Enabled = true

	Icon.new()
		:setImage(136039649721373)
		:setLabel("Menu")
		:call(function(self)
			self:bindEvent("deselected", function()
				gui.Enabled = false
				onDisable()
				janitor:Cleanup()
				self:destroy()
			end)
		end)
		:oneClick()

	--STATS / CURRENCIES

	local prestige = Replicator.prestige
	local level = Replicator.level

	local ProgressDisplay = gui.Stats["01_Progress"]

	ProgressDisplay.Level.Text = "Lv. " .. level
	ProgressDisplay.Prestige.Text = toRoman(prestige)

	janitor:Add(
		Replicator.changed("level"):Connect(function(new)
			ProgressDisplay.Level.Text = "Lv. " .. new
		end),
		"Disconnect"
	)

	janitor:Add(
		Replicator.changed("prestige"):Connect(function(new)
			ProgressDisplay.Prestige.Text = toRoman(new)
		end),
		"Disconnect"
	)

	for _, display in gui.Currencies:GetChildren() do
		local currencyName = display:GetAttribute("currency")
		if currencyName then
			local currency = Replicator[currencyName]
			if currency then
				display.Amount.Text = currency
				janitor:Add(
					Replicator.changed(currencyName):Connect(function(new)
						display.Amount.Text = new
					end),
					"Disconnect"
				)
			end
		end
	end

	for _, display in gui.Stats:GetChildren() do
		local statName = display:GetAttribute("stat")
		local maxStatName = display:GetAttribute("maxStat")

		if statName and maxStatName then
			local stat = Replicator[statName]
			local maxStat = Replicator[maxStatName]

			if stat and maxStat then
				display.Amount.Text = stat .. " / " .. maxStat
				display.Bar.Size = UDim2.fromScale(stat / maxStat, 1)

				janitor:Add(
					Replicator.changed(statName):Connect(function(new)
						local max = Replicator[maxStatName]

						display.Amount.Text = new .. " / " .. max
						TweenService:Create(display.Bar, barTweenInfo, { Size = UDim2.fromScale(new / max, 1) }):Play()
					end),
					"Disconnect"
				)
			end
		end
	end

	--SLOTS

	local Slots = gui.Slots :: Frame
	local selectedSlot

	local function renderSlots(equipped)
		for slotIndex = 1, 5 do
			local slot = Slots["Slot" .. slotIndex]
			local spellId = equipped[slotIndex]

			if spellId then
				local spell = Spells[spellId]
				local element = Elements[spell.Element]

				slot.UIStroke.Color = element.Color
				slot.UIStroke.Transparency = 0.5

				slot.Text = spellId:gsub("(%u)", " %1"):gsub("^%s+", "")

				slot.AutoButtonColor = true

				if UserInputService.KeyboardEnabled then
					slot.Keybind.Visible = true
				end
			else
				slot.UIStroke.Transparency = 1
				slot.Text = ""
				slot.AutoButtonColor = false
				slot.Keybind.Visible = false
			end
		end
	end

	local function selectSlot(slot)
		slot.UIStroke.Thickness = 3
		slot.UIStroke.Transparency = 0
	end

	local function deselectSlot(slot)
		slot.UIStroke.Thickness = 1
		slot.UIStroke.Transparency = 0.5
	end

	local function updateSelection(newSlotIndex)
		if selectedSlot then
			deselectSlot(selectedSlot)
		end

		if newSlotIndex then
			selectedSlot = Slots["Slot" .. newSlotIndex]
			selectSlot(selectedSlot)
		else
			selectedSlot = nil
		end
	end

	local function updateCooldown(cooldownData)
		local slot = Slots["Slot"..cooldownData.slotIndex]
		local cooldown = cooldownData.cooldown

		local cooldownLabel = Instance.new("TextLabel")
		cooldownLabel.TextColor3 = Color3.new(1, 1, 1)
		cooldownLabel.TextSize = 15
		cooldownLabel.BackgroundColor3 = Color3.new()
		cooldownLabel.BackgroundTransparency = 0.5
		cooldownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		cooldownLabel.Position = UDim2.fromScale(0.5, 0.5)
		cooldownLabel.Size = UDim2.fromScale(2, 2)
		cooldownLabel.Parent = slot

		local startTime = os.clock()

		local connection
		connection = RunService.Heartbeat:Connect(function()
			local elapsed = os.clock() - startTime
			local remaining = cooldown - elapsed

			if remaining <= 0 then
				connection:Disconnect()
				cooldownLabel:Destroy()
			else
				cooldownLabel.Text = string.format("%.1f", remaining)
			end
		end)

		janitor:Add(cooldownLabel)
		janitor:Add(connection)
	end

	janitor:Add(
		Replicator.changed("spells"):Connect(function(spells)
			renderSlots(spells.equipped)
		end),
		"Disconnect"
	)

	janitor:Add(State.changed("selectedSlot"):Connect(updateSelection), "Disconnect")
	janitor:Add(State.changed("onCooldown"):Connect(updateCooldown), "Disconnect")

	for _, slot in Slots:GetChildren() do
		if slot:IsA("GuiButton") then
			local slotIndex = tonumber(string.match(slot.Name, "%d"))

			janitor:Add(slot.Activated:Connect(function()
				SlotSelection.select(slotIndex)
			end))
		end
	end

	renderSlots(Replicator.spells.equipped)
end
