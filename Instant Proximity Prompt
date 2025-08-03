local Players = game:GetService("Players")

-- Function to check if the prompt is the excluded one
local function isExcludedPrompt(prompt)
	if prompt.Name ~= "ArrestPrompt" then return false end
	
	local root = prompt:FindFirstAncestorOfClass("Model")
	if root and Players:GetPlayerFromCharacter(root) then
		local hrp = root:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:FindFirstChild("ArrestPrompt") == prompt then
			return true
		end
	end
	return false
end

-- Connect to all current prompts
for _, prom in next, workspace:GetDescendants() do
	if prom:IsA("ProximityPrompt") and not isExcludedPrompt(prom) then
		prom.PromptButtonHoldBegan:Connect(function()
			if prom.HoldDuration <= 0 then return end
			fireproximityprompt(prom, 0)
		end)
	end
end

-- Handle newly added prompts
workspace.DescendantAdded:Connect(function(class)
	if class:IsA("ProximityPrompt") and not isExcludedPrompt(class) then
		class.PromptButtonHoldBegan:Connect(function()
			if class.HoldDuration <= 0 then return end
			fireproximityprompt(class, 0)
		end)
	end
end)
