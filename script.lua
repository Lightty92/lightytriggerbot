-- Settings
local Hotkey = "t"

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local Enabled = false
local RightClickHeld = false

-- Hotkey Toggle
Mouse.KeyDown:Connect(function(key)
    if key:lower() == Hotkey:lower() then
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

-- Get Character Model
local function getCharacterModel(target)
    if not target then return nil end
    local model = target.Parent
    for i = 1, 10 do
        if model and model:FindFirstChildOfClass("Humanoid") then
            return model
        end
        if model then
            model = model.Parent
        end
    end
    return nil
end

-- Check if Enemy
local function isEnemy(model)
    if not model then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        local target = Mouse.Target
        if target then
            local model = getCharacterModel(target)
            if model and isEnemy(model) then
                mouse1click()
            end
        end
    end
end)

print("Autotrigger loaded! Press T to toggle, hold right click to shoot.")
