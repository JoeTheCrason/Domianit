-- External Shift Sprint Script with Constant Speed Override
local uis = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local sprinting = false

-- Sprint loop (runs in background)
task.spawn(function()
    while true do
        if sprinting and humanoid then
            humanoid.WalkSpeed = 24
        end
        task.wait(0.1) -- adjust as needed for responsiveness
    end
end)

-- Detect key press
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        sprinting = true
    end
end)

-- Detect key release
uis.InputEnded:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        sprinting = false
        if humanoid then
            humanoid.WalkSpeed = 16 -- restore default
        end
    end
end)
