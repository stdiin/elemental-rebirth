local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Replicator = require(script.Parent.Replicator)
local SpellTypes = require(ReplicatedStorage.Modules.SpellTypes)
local Spells = require(ReplicatedStorage.Modules.Spells)
local State = require(script.Parent.State)

local remotes = ReplicatedStorage.Remotes
local RequestCasting = remotes.RequestCasting
local FinishCasting = remotes.FinishCasting

local SpellCasting = {}

local castingConnection
local slotChangedConnection
local timeout
local animationTrack
local alignOrientation

local cooldowns = {}

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude

local function mouseRaycast()
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	params.FilterDescendantsInstances = { player.Character }
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 500, params)

	return raycastResult and raycastResult.Position or ray.Origin + ray.Direction * 500
end

function SpellCasting.startListening()
	ContextActionService:BindAction("SpellCasting", function(_, inputState)
		local selectedSlot = State.selectedSlot

		if not selectedSlot or cooldowns[selectedSlot] then
			return
		end

		if inputState == Enum.UserInputState.Begin then
			SpellCasting.startCasting(selectedSlot)

			slotChangedConnection = State.changed("selectedSlot"):Once(function()
				SpellCasting.stopCasting(selectedSlot)
			end)

			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				task.wait()
			end

			SpellCasting.stopCasting(selectedSlot)
		end
	end, false, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
end

function SpellCasting.stopListening()
	ContextActionService:UnbindAction("SpellCasting")
end

function SpellCasting.startCasting(selectedSlot)
	if cooldowns[selectedSlot] then
		return
	end

	local spellId = Replicator.spells.equipped[selectedSlot]
	local spell = Spells[spellId]

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local allowed = RequestCasting:InvokeServer(selectedSlot)
	if not allowed then
		return
	end

	local hrp = character.HumanoidRootPart :: Part
	local animator = humanoid.Animator :: Animator

	local spellType = SpellTypes[spell.Type]

	local animationId = spellType and spellType.Animation or spell.Animation

	if animationId then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId

		animationTrack = animator:LoadAnimation(animation)
		animationTrack.Priority = Enum.AnimationPriority.Action

		animationTrack:Play(0.1)
	end

	local anchor = spellType and spellType.Anchor or spell.Anchor

	if anchor then
		hrp.Anchored = true
	end

	timeout = task.delay(spell.MaxChargeDuration, function()
		SpellCasting.stopCasting(selectedSlot)
	end)

	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.RigidityEnabled = true
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = hrp.RootAttachment
	alignOrientation.Parent = hrp

	castingConnection = RunService.Heartbeat:Connect(function()
		if humanoid.Health <= 0 then
			SpellCasting.stopCasting(selectedSlot)
		end

		local mousePos = mouseRaycast()
		local hrpPos = hrp.Position

		local x = mousePos.X
		local y = hrpPos.Y
		local z = mousePos.Z

		local target = vector.create(x, y, z)

		alignOrientation.CFrame = CFrame.lookAt(hrpPos, target)
	end)
end

function SpellCasting.stopCasting(selectedSlot)
	player.Character.HumanoidRootPart.Anchored = false

	if animationTrack then
		animationTrack:Stop(0.2)
		animationTrack = nil
	end

	if alignOrientation then
		alignOrientation:Destroy()
		alignOrientation = nil
	end

	if castingConnection then
		castingConnection:Disconnect()
		castingConnection = nil
	end

	if slotChangedConnection then
		slotChangedConnection:Disconnect()
		slotChangedConnection = nil
	end

	if timeout and coroutine.running() ~= timeout then
		task.cancel(timeout)
		timeout = nil
	end

	SpellCasting.cast(selectedSlot)
end

function SpellCasting.cast(selectedSlot)
	FinishCasting:FireServer(mouseRaycast())

	local spellId = Replicator.spells.equipped[selectedSlot]
	local spell = Spells[spellId]
	local cooldown = spell.Cooldown

	cooldowns[selectedSlot] = cooldown
	State.onCooldown = { slotIndex = selectedSlot, cooldown = cooldown }

	task.delay(cooldown, function()
		cooldowns[selectedSlot] = nil
	end)
end

return SpellCasting
