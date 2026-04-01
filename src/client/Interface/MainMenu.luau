local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Settings = require(ReplicatedFirst.Client.Settings)
local version = Settings.Version

local MenuCamera = workspace.MenuCamera
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local MenuMusic = SoundService.MenuMusic
local HoverSFX = SoundService.UIHover
local SelectSFX = SoundService.UISelect

local MAX_TILT = 10
local SENSITIVITY = 0.75
local MAX_Y_LIMIT = 100
local MAX_X_LIMIT = 100

local BASE_FOV = 70
local MAX_FOV_CHANGE = 10
local FOV_LERP_SPEED = 0.1

local HOVER_SCALE_INCREMENT = 0.1

local hoverTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quint)

return function(gui, onDisable)
	local janitor = Janitor.new()

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	gui.Enabled = true
	camera.CameraType = Enum.CameraType.Scriptable

	MenuMusic:Play()

	local accumulatedX = 0
	local accumulatedY = 0
	local lastMousePos = UserInputService:GetMouseLocation()

	local currentFOV = BASE_FOV
	local targetFOV = BASE_FOV

	janitor:Add(RunService.RenderStepped:Connect(function()
		local loudness = MenuMusic.PlaybackLoudness
		local normalizedLoudness = loudness / 1000
		targetFOV = BASE_FOV + (normalizedLoudness * MAX_FOV_CHANGE)
		currentFOV = currentFOV + (targetFOV - currentFOV) * FOV_LERP_SPEED
		camera.FieldOfView = currentFOV

		local currentMousePos = UserInputService:GetMouseLocation()
		local delta = currentMousePos - lastMousePos

		local xDelta = (delta.X / mouse.ViewSizeX) * SENSITIVITY
		local yDelta = (delta.Y / mouse.ViewSizeY) * SENSITIVITY

		accumulatedY =
			math.clamp(accumulatedY - xDelta * math.rad(MAX_TILT), math.rad(-MAX_Y_LIMIT), math.rad(MAX_Y_LIMIT))
		accumulatedX =
			math.clamp(accumulatedX - yDelta * math.rad(MAX_TILT), math.rad(-MAX_X_LIMIT), math.rad(MAX_X_LIMIT))

		local targetCFrame = MenuCamera.CFrame * CFrame.Angles(accumulatedX, accumulatedY, 0)
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.1)

		lastMousePos = currentMousePos
	end))

	local PlayButton = gui.Buttons.PlayButton :: TextButton

	janitor:Add(PlayButton.Activated:Once(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)

		task.defer(function()
			repeat
				local success = pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", true)
				task.wait()
			until success
		end)

		camera.FieldOfView = BASE_FOV
		camera.CameraType = Enum.CameraType.Custom

		MenuMusic:Stop()

		local transitionScreen = Instance.new("ScreenGui")
		transitionScreen.ResetOnSpawn = false
		transitionScreen.DisplayOrder = 1
		local transitionFrame = Instance.new("Frame")
		transitionFrame.BackgroundColor3 = Color3.new(0, 0, 0)
		transitionFrame.Size = UDim2.fromScale(2, 2)
		transitionFrame.Rotation = -45
		transitionFrame.Position = UDim2.fromScale(-2, -2)
		transitionFrame.Parent = transitionScreen
		transitionScreen.Parent = player.PlayerGui

		local transitionTween =
			TweenService:Create(transitionFrame, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(2, 2),
			})

		local timeOffset = transitionTween.TweenInfo.Time / 10

		task.delay(timeOffset, function()
			gui.Enabled = false
			task.wait(timeOffset)
			onDisable()
			janitor:Cleanup()
		end)

		transitionTween.Completed:Once(function()
			transitionScreen:Destroy()
		end)

		transitionTween:Play()
	end))

	for _, button: GuiButton in gui.Buttons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local scale = button.UIScale
		scale.Scale = 1

		janitor:Add(button.MouseEnter:Connect(function()
			HoverSFX:Play()
			TweenService:Create(scale, hoverTweenInfo, {
				Scale = 1 + HOVER_SCALE_INCREMENT,
			}):Play()

			button.MouseLeave:Once(function()
				TweenService:Create(scale, hoverTweenInfo, {
					Scale = 1,
				}):Play()
			end)
		end))

		button.Activated:Connect(function()
			SelectSFX:Play()
		end)
	end

	local VersionLabel = gui.Version
	VersionLabel.Text = version
end
