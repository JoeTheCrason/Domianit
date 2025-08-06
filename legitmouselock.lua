local MouseLock = {
	Settings = {
		BaseHoverRadius = 80, -- Dynamic hover radius (for near and far players)
		Prediction = 0.1, -- Predict movement
		DragSmoothing = 0.12, -- Smooth aim drag
		MaxMouseMovePerFrame = 20,
		SwipeInterval = 0.35,
		ShowESP = true,
		ESPColor = Color3.fromHex("#b059eb"),
		TargetParts = { "Head", "UpperTorso", "LowerTorso", "RightArm", "LeftArm", "RightLeg", "LeftLeg" }
	}
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local LockedPlayer = nil
local LockedPart = nil
local ESP = nil
local swipeIndex = 1
local lastSwipe = tick()
local function isVisible(part, character)
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, direction, rayParams)
	return result and character:IsAncestorOf(result.Instance)
end

local function clampMouseMove(x, y, max)
	return math.clamp(x, -max, max), math.clamp(y, -max, max)
end

local function applyESP(player)
	if MouseLock.Settings.ShowESP and not ESP then
		local h = Instance.new("Highlight")
		h.Adornee = player.Character
		h.FillColor = MouseLock.Settings.ESPColor
		h.FillTransparency = 1
		h.OutlineColor = MouseLock.Settings.ESPColor
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = player.Character
		ESP = h
	end
end

local function clearESP()
	if ESP then ESP:Destroy() end
	ESP = nil
end
local function getHoveredTarget()
	local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local bestTarget, bestPart, shortestDist = nil, nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				for _, partName in ipairs(MouseLock.Settings.TargetParts) do
					local part = player.Character:FindFirstChild(partName)
					if part and isVisible(part, player.Character) then
						local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
						if onScreen then
							local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

							-- Adjust for target distance
							local worldDist = (Camera.CFrame.Position - part.Position).Magnitude
							local dynamicHover = MouseLock.Settings.BaseHoverRadius * (1 + (worldDist / 200))

							if dist < dynamicHover and dist < shortestDist then
								bestTarget = player
								bestPart = part
								shortestDist = dist
							end
						end
					end
				end
			end
		end
	end

	return bestTarget, bestPart
end
RunService.RenderStepped:Connect(function(deltaTime)
	local holdingLMB = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	local holdingRMB = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

	if not holdingLMB or holdingRMB then
		LockedPlayer = nil
		LockedPart = nil
		swipeIndex = 1
		clearESP()
		return
	end

	if not LockedPlayer then
		local target, part = getHoveredTarget()
		if target and part then
			LockedPlayer = target
			LockedPart = part
			applyESP(target)
		else
			return
		end
	end

	if not LockedPlayer or not LockedPart or not LockedPart:IsDescendantOf(LockedPlayer.Character) then
		LockedPlayer = nil
		LockedPart = nil
		clearESP()
		return
	end

	-- Predictive position
	local predicted = LockedPart.Position + (LockedPart.Velocity * MouseLock.Settings.Prediction)
	local screenPos, onScreen = Camera:WorldToScreenPoint(predicted)
	if not onScreen then return end

	local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local dx = (screenPos.X - mousePos.X)
	local dy = (screenPos.Y - mousePos.Y)

	-- Apply frame-time-adjusted smoothing
	local smoothedX = dx * MouseLock.Settings.DragSmoothing
	local smoothedY = dy * MouseLock.Settings.DragSmoothing
	local moveX, moveY = clampMouseMove(smoothedX, smoothedY, MouseLock.Settings.MaxMouseMovePerFrame)

	pcall(function()
		mousemoverel(moveX, moveY)
	end)
end)
