-- Settings
local Hotkey = "t"

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Enabled = false
local RightClickHeld = false
local LastShot = 0
local MinDistance = 3

-- Hotkey Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        Enabled = not Enabled
        print("Autotrigger:", Enabled and "ON" or "OFF")
    end
end)

-- Right Click Detection
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false
    end
end)

-- Get Ping-based Delay
local function getDelay()
    local ping = LocalPlayer:GetNetworkPing()
    ping = math.clamp(ping * 1000, 30, 150)
    return ping / 1000
end

-- Wall Check (Anti-Wallbang)
local function isTargetVisible(targetPosition)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (targetPosition - origin).Unit * 1500)
    local hit, pos = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, false, true)
    
    if hit then
        local distToHit = (pos - origin).Magnitude
        local distToTarget = (targetPosition - origin).Magnitude
        
        if distToHit < distToTarget - 1 then
            return false
        end
    end
    
    return true
end

-- Check if Centered on Screen
local function isCentered(screenPos)
    local center = Camera.ViewportSize / 2
    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    return distance < 30
end

-- Check if Within Distance
local function isWithinDistance(targetPosition)
    local origin = Camera.CFrame.Position
    local distance = (targetPosition - origin).Magnitude
    return distance < MinDistance
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        local currentTime = tick()
        local Delay = getDelay()
        if currentTime - LastShot < Delay then return end
        
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        if LocalPlayer.Character then
            params.FilterDescendantsInstances = {LocalPlayer.Character}
        end
        
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
        
        if result then
            local targetPart = result.Instance
            local targetPos = result.Position
            
            local screenPos = Camera:WorldToViewportPoint(targetPos)
            
            for i = 1, 10 do
                if targetPart and targetPart:FindFirstChildOfClass("Humanoid") then
                    if isTargetVisible(targetPos) and isCentered(screenPos) and not isWithinDistance(targetPos) then
                        mouse1click()
                        LastShot = currentTime
                    end
                    break
                end
                if targetPart then
                    targetPart = targetPart.Parent
                end
            end
        end
    end
end)

print("Autotrigger loaded! Press T to toggle, hold right click to shoot.")
