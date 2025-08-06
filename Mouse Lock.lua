-- ⚙️ Aimbot Config
local MouseLock = {
    Settings = {
        ShowESP = true,
        Prediction = 0, -- Instant, no lead
        LockRadius = 100, -- pixels from cursor
        ESPColor = Color3.fromHex("#b059eb")
    }
}

-- 🧩 Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 🔁 State
local LockedPlayer = nil
local LockedPart = nil
local currentESP = nil

-- 📐 Clamp movement
local function clampMouseMove(x, y, max)
    return math.clamp(x, -max, max), math.clamp(y, -max, max)
end

-- 🧱 Wallcheck
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

-- ✨ ESP
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

-- 🎯 Smart FindClosestPlayer with head priority
local function FindClosestPlayer()
    local closestPlayer, bestPart, shortest = nil, nil, math.huge
    local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local human = plr.Character:FindFirstChild("Humanoid")
            if not human or human.Health <= 0 then continue end

            local head = plr.Character:FindFirstChild("Head")
            if head and isVisible(head, plr.Character) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < MouseLock.Settings.LockRadius and dist < shortest then
                        closestPlayer = plr
                        bestPart = head
                        shortest = dist
                        continue -- use head if visible
                    end
                end
            end

            -- Fallback to visible parts
            for _, partName in ipairs({"UpperTorso", "LowerTorso", "RightArm", "LeftArm", "RightLeg", "LeftLeg"}) do
                local part = plr.Character:FindFirstChild(partName)
                if part and isVisible(part, plr.Character) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < MouseLock.Settings.LockRadius and dist < shortest then
                            closestPlayer = plr
                            bestPart = part
                            shortest = dist
                        end
                    end
                end
            end
        end
    end

    return closestPlayer, bestPart
end

-- 🧠 Lock + Cursor Tracking
RunService.RenderStepped:Connect(function()
    local holdingLMB = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

    if not holdingLMB then
        LockedPlayer = nil
        LockedPart = nil
        clearESP()
        return
    end

    if not LockedPlayer then
        local target, part = FindClosestPlayer()
        if target and part then
            LockedPlayer = target
            LockedPart = part
            applyESP(target)
        end
    end

    if LockedPlayer and LockedPart and LockedPart:IsDescendantOf(LockedPlayer.Character) then
        local predicted = LockedPart.Position + (LockedPart.Velocity * MouseLock.Settings.Prediction)
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
end)
