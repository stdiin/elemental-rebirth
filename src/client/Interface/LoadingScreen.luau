local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local transitionTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local LOADING_DURATION = if RunService:IsStudio() then 2 else 5

return function(gui, onDisable, waitFor)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	task.defer(function()
		repeat
			local success = pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", false)
			task.wait()
		until success
	end)

	gui.Enabled = true

	local LoadingLabel = gui.LoadingLabel
	local Vignette = gui.Vignette

	local dotAnim = task.spawn(function()
		while true do
			task.wait()
			LoadingLabel.Text = "Loading"
			for _ = 1, 3 do
				LoadingLabel.Text ..= "."
				task.wait(0.25)
			end
		end
	end)

	task.spawn(function()
		local start = os.clock()
		waitFor()
		local yieldedFor = os.clock() - start

		task.wait(LOADING_DURATION - yieldedFor)

		task.cancel(dotAnim)
		LoadingLabel.Text = "Loaded"

		task.wait(1)

		TweenService:Create(LoadingLabel, transitionTweenInfo, {
			TextTransparency = 1,
		}):Play()

		local transition = TweenService:Create(Vignette, transitionTweenInfo, {
			BackgroundTransparency = 1,
			ImageTransparency = 1,
		})

		transition.Completed:Once(function()
			gui:Destroy()
		end)

		transition:Play()
		onDisable()
	end)
end
