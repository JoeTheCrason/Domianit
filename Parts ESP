local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local ESPs = {}
local lootFolder = workspace:WaitForChild("SpawnsLoot")

-- Utility: Get the visible part in a SpawnForLoot model
local function getVisiblePart(model)
	local partNames = {"Gear", "Blade", "Spring"}
	for _, name in ipairs(partNames) do
		local part = model:FindFirstChild(name)
		if part and part:IsA("BasePart") and part.Transparency == 0 then
			return part
		end
	end
	return nil
end

-- Function to create ESP for a part
local function createESP(model, part)
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Name = "ESP"
	BillboardGui.Parent = part
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Size = UDim2.new(0, 100, 0, 40)
	BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
	BillboardGui.Adornee = part

	-- Label
	local NameTag = Instance.new("TextLabel")
	NameTag.Name = "NameTag"
	NameTag.Parent = BillboardGui
	NameTag.BackgroundTransparency = 1
	NameTag.Size = UDim2.new(1, 0, 0.5, 0)
	NameTag.Text = part.Name
	NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameTag.TextStrokeTransparency = 0.5
	NameTag.TextScaled = true

	-- Distance Label
	local DistanceTag = Instance.new("TextLabel")
	DistanceTag.Name = "DistanceTag"
	DistanceTag.Parent = BillboardGui
	DistanceTag.BackgroundTransparency = 1
	DistanceTag.Position = UDim2.new(0, 0, 0.5, 0)
	DistanceTag.Size = UDim2.new(1, 0, 0.5, 0)
	DistanceTag.TextColor3 = Color3.fromRGB(0, 255, 0)
	DistanceTag.TextStrokeTransparency = 0.5
	DistanceTag.TextScaled = true

	-- Track this ESP by model
	ESPs[model] = {
		gui = BillboardGui,
		part = part,
		model = model
	}
end

-- Function to remove ESP
local function removeESP(model)
	if ESPs[model] then
		local gui = ESPs[model].gui
		if gui and gui.Parent then
			gui:Destroy()
		end
		ESPs[model] = nil
	end
end

-- Constantly update ESP
RunService.RenderStepped:Connect(function()
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	local root = player.Character.HumanoidRootPart

	for _, model in ipairs(lootFolder:GetChildren()) do
		if model:IsA("Model") and model.Name == "SpawnForLoot" then
			local visiblePart = getVisiblePart(model)

			if visiblePart then
				-- ESP exists, but part changed
				if ESPs[model] then
					if ESPs[model].part ~= visiblePart then
						removeESP(model)
						createESP(model, visiblePart)
					end
				else
					-- No ESP yet
					createESP(model, visiblePart)
				end

				-- Update distance text
				local distance = (root.Position - visiblePart.Position).Magnitude
				local gui = ESPs[model].gui
				if gui and gui:FindFirstChild("DistanceTag") then
					gui.DistanceTag.Text = "(" .. math.floor(distance) .. "m)"
				end
			else
				-- No visible part — remove ESP if exists
				removeESP(model)
			end
		end
	end
end)

-- Optional: ESP cleanup function
local function disableESP()
	for _, data in pairs(ESPs) do
		if data.gui then
			data.gui:Destroy()
		end
	end
	ESPs = {}
end
