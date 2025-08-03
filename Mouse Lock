-- ⚙️ Aimbot Config
local MouseLock = {
    Settings = {
        ShowESP = true,
        AimPart = "Head",
        Prediction = 0,
        LockRadius = 100, -- pixels from cursor
        ESPColor = Color3.fromHex("#b059eb")
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- State
local LockedPlayer = nil
local currentESP = nil

-- 📐 Clamp
local function clampMouseMove(x, y, max)
    return math.clamp(x, -max, max), math.clamp(y, -max, max)
end

-- 🌑 Wallcheck
local function isVisible(part, char)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, dir, rayParams)
    return result and result.Instance and char:IsAncestorOf(result.Instance)
end

-- 🎯 Find Closest Player to Cursor
local function FindClosestPlayer()
    local closest, shortest = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(MouseLock.Settings.AimPart)
            local human = plr.Character:FindFirstChild("Humanoid")

            if part and human and human.Health > 0 and isVisible(part, plr.Character) then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortest and dist < MouseLock.Settings.LockRadius then
                        shortest = dist
                        closest = plr
                    end
                end
            end
        end
    end

    return closest
end

-- ✨ ESP Functions
local function applyESP(player)
    if not MouseLock.Settings.ShowESP then return end
    if currentESP then currentESP:Destroy() end

    local h = Instance.new("Highlight")
    h.Adornee = player.Character
    h.FillColor = MouseLock.Settings.ESPColor
    h.FillTransparency = 1
    h.OutlineColor = MouseLock.Settings.ESPColor
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = player.Character
    currentESP = h
end

local function clearESP()
    if currentESP then currentESP:Destroy() end
    currentESP = nil
end

-- 🧠 Auto Lock + Aim
RunService.RenderStepped:Connect(function()
    local holdingLMB = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

    if not holdingLMB then
        LockedPlayer = nil
        clearESP()
        return
    end

    if not LockedPlayer then
        LockedPlayer = FindClosestPlayer()
        if LockedPlayer then
            applyESP(LockedPlayer)
        end
    end

    if LockedPlayer and LockedPlayer.Character then
        local part = LockedPlayer.Character:FindFirstChild(MouseLock.Settings.AimPart)
        if part then
            local predicted = part.Position + (part.Velocity * MouseLock.Settings.Prediction)
            local screenPos, onScreen = Camera:WorldToScreenPoint(predicted)
            if not onScreen then return end

            local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
            local dx = screenPos.X - mousePos.X
            local dy = screenPos.Y - mousePos.Y

            local moveX, moveY = clampMouseMove(dx, dy, 100)
            pcall(function()
                mousemoverel(moveX, moveY)
            end)
        end
    end
end)
