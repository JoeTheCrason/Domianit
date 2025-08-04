-- Place this LocalScript in StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Ensure the PlayerStats folder exists in ReplicatedStorage
local playerStatsFolder = ReplicatedStorage:FindFirstChild("PlayerStats")
if not playerStatsFolder then
    playerStatsFolder = Instance.new("Folder")
    playerStatsFolder.Name = "PlayerStats"
    playerStatsFolder.Parent = ReplicatedStorage
end

-- Function to set all "Intelligence" values to 100
local function setAllIntelligenceTo100()
    for _, playerFolder in pairs(playerStatsFolder:GetChildren()) do
        local intelligence = playerFolder:FindFirstChild("Intelligence")
        if intelligence and intelligence:IsA("NumberValue") then
            intelligence.Value = 100
        end
    end
end

-- Set the values initially
setAllIntelligenceTo100()

-- Listen for new players being added
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Wait for the player's data to be replicated
        setAllIntelligenceTo100()
    end)
end)
