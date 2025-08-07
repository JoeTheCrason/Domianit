local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerFolder = ReplicatedStorage:WaitForChild("PlayerStats"):WaitForChild(player.Name)
local solitaryTime = playerFolder:WaitForChild("SolitaryTime")

while true do
	solitaryTime.Value = 0
	wait(1)
end
