local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local LoadingScreen = ReplicatedFirst.LoadingScreen

-- Modules
local Interface = require(script.Interface)
local Movement = require(script.Movement)
local SlotSelection = require(script.SlotSelection)
local SpellCasting = require(script.SpellCasting)

-- Init
Interface.handle(LoadingScreen, function()
	local MainMenu = ReplicatedStorage.UI.MainMenu
	local GameOverlay = ReplicatedStorage.UI.GameOverlay
	local remotes = ReplicatedStorage.Remotes

	local SpawnCharacter = remotes.SpawnCharacter
	local DespawnCharacter = remotes.DespawnCharacter

	local function toMainMenu()
		Interface.handle(MainMenu, function()
			SpawnCharacter:FireServer()
			Movement.init()

			if UserInputService.KeyboardEnabled then
				SlotSelection.startListening()
			end

			SpellCasting.startListening()

			Interface.handle(GameOverlay, function()
				DespawnCharacter:FireServer()
				SlotSelection.stopListening()
				SpellCasting.stopListening()
				toMainMenu()
			end)
		end)
	end

	toMainMenu()
end, function()
	local Replicator = require(script.Replicator)
	Replicator.loaded:Wait()

	local anims = {}

	local SpellTypes = require(ReplicatedStorage.Modules.SpellTypes)
	for _, v in SpellTypes do
		local animation = Instance.new("Animation")
		animation.AnimationId = v.Animation
		table.insert(anims, animation)
	end

	ContentProvider:PreloadAsync(anims, function()
		for _, animation in anims do
			animation:Destroy()
		end
	end)

	require(ReplicatedStorage.Modules.SpellReplicator)
end)

player.CharacterAdded:Connect(function(character)
	local Janitor = require(ReplicatedStorage.Packages.Janitor)
	local janitor = Janitor.new()

	local humanoid = character.Humanoid

	janitor:Add(humanoid.Died:Once(function()
		task.delay(5, function()
			ReplicatedStorage.Remotes.SpawnCharacter:FireServer()
			Movement.init()
		end)
	end))

	janitor:LinkToInstance(character)
end)
