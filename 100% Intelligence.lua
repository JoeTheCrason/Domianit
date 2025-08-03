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
