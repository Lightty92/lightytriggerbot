-- Settings
local Hotkey = "t"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Enabled = false
local RightClickHeld = false

Mouse.KeyDown:Connect(function(key)
    if key:lower() == Hotkey:lower() then
        Enabled = not Enabled
        print("Autotrigger:", Enabled and "ON" or "OFF")
    end
end)

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

local function getCharacterModel(target)
    if not target then return nil end
    local model = target.Parent
    for i = 1, 10 do
        if model and model:FindFirstChild("Humanoid") then
            return model
        end
        if model then
            model = model.Parent
        end
    end
    return nil
end

local function canShoot(model)
    if not model then return false end
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        if player.Team == LocalPlayer.Team then return false end
    end
    
    return true
end

RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        local target = Mouse.Target
        local model = getCharacterModel(target)
        
        if canShoot(model) then
            mouse1click()
        end
    end
end)

print("Script loaded! Press T to toggle, hold right click to shoot.")
