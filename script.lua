-- Settings
local Hotkey = "t"
local HotkeyToggle = true

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
local Smoothness = 0.02

-- Hotkey Toggle
Mouse.KeyDown:Connect(function(key)
    key = key:lower()
    if key == Hotkey:lower() then
        Enabled = not Enabled
        print("Triggerbot:", Enabled and "ON" or "OFF")
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
    
    local player = Players:GetPlayerFromCharacter(model)
    if player and player.Team == LocalPlayer.Team then return false end
    
    local parent = model.Parent
    if parent and parent.Name == "Ragdolls" then return true end
    
    return false
end

-- Smooth Click
local function smoothClick()
    local delay = math.random(15, 45) / 1000
    task.delay(delay, function()
        mouse1click()
    end)
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not Enabled or not RightClickHeld then return end
    
    local target = Mouse.Target
    if not target then return end
    
    local model = getCharacterModel(target)
    if not model then return end
    
    if isEnemy(model) then
        smoothClick()
    end
end)

print("Triggerbot loaded! Press T to toggle, hold right click to shoot.")
