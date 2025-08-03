local Players = game:GetService("Players")

-- Accurate check for excluded ArrestPrompt
local function isExcludedPrompt(prompt)
	if prompt.Name ~= "ArrestPrompt" then return false end

	local hrp = prompt.Parent
	if not hrp or hrp.Name ~= "HumanoidRootPart" then return false end

	local character = hrp.Parent
	if not character or not character:IsA("Model") then return false end

	local player = Players:GetPlayerFromCharacter(character)
	if player then
		-- Confirm this is the player's actual ArrestPrompt
		return character:FindFirstChild("HumanoidRootPart") == hrp and hrp:FindFirstChild("ArrestPrompt") == prompt
	end

	return false
end

-- Hook into existing ProximityPrompts
for _, prompt in ipairs(workspace:GetDescendants()) do
	if prompt:IsA("ProximityPrompt") and not isExcludedPrompt(prompt) then
		prompt.PromptButtonHoldBegan:Connect(function()
			if prompt.HoldDuration <= 0 then return end
			fireproximityprompt(prompt, 0)
		end)
	end
end

-- Listen for new ProximityPrompts
workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("ProximityPrompt") and not isExcludedPrompt(descendant) then
		descendant.PromptButtonHoldBegan:Connect(function()
			if descendant.HoldDuration <= 0 then return end
			fireproximityprompt(descendant, 0)
		end)
	end
end)
