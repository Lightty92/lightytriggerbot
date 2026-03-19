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

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        if LocalPlayer.Character then
            params.FilterDescendantsInstances = {LocalPlayer.Character}
        end
        
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        
        if result then
            local model = result.Instance
            for i = 1, 10 do
                if model and model:FindFirstChildOfClass("Humanoid") then
                    mouse1click()
                    break
                end
                if model then
                    model = model.Parent
                end
            end
        end
    end
end)

print("Autotrigger loaded! Press T to toggle, hold right click to shoot.")
