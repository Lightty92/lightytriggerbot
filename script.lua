-- Settings
local Hotkey = "t"
local HotkeyToggle = true
local HoldClick = false -- true = hold mouse1, false = single click

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Enabled = false
local RightClickHeld = false
local CurrentlyPressed = false

-- Try to climb from any part (hat, arm, etc.) to the character model
local function GetCharacterFromTarget(part)
    local current = part
    while current and current ~= workspace do
        if current:FindFirstChildOfClass("Humanoid") then
            return current
        end
        current = current.Parent
    end
    return nil
end

-- Check if the character has the specific avatar colors (red torso, yellow head, dark limbs)
local function IsTargetAvatar(character)
    -- R6 sample parts; use UpperTorso/LowerTorso for R15 if needed
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
    local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")

    if not (head and torso and leftArm and rightArm and leftLeg and rightLeg) then
        return false
    end

    -- Adjust these BrickColors if your enemy avatar uses slightly different ones
    local redTorso = BrickColor.new("Really red")
    local yellowHead = BrickColor.new("New Yeller")
    local darkLimb = BrickColor.new("Really black")

    local torsoOk = torso.BrickColor == redTorso
    local headOk = head.BrickColor == yellowHead
    local limbsOk =
        leftArm.BrickColor == darkLimb and
        rightArm.BrickColor == darkLimb and
        leftLeg.BrickColor == darkLimb and
        rightLeg.BrickColor == darkLimb

    return torsoOk and headOk and limbsOk
end

-- Decide if this character is a valid enemy with that avatar
local function IsEnemyCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    local plr = Players:GetPlayerFromCharacter(character)
    if not plr or plr == LocalPlayer then
        return false
    end

    -- Optional: ignore same-team players if the game uses teams
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return false
    end

    -- Only accept if the avatar matches the target colors
    return IsTargetAvatar(character)
end

Mouse.KeyDown:Connect(function(key)
    key = key:lower()
    if key == Hotkey:lower() then
        if HotkeyToggle then
            Enabled = not Enabled
            print("Autotrigger:", Enabled and "ON" or "OFF")
        else
            Enabled = true
        end
    end
end)

Mouse.KeyUp:Connect(function(key)
    key = key:lower()
    if not HotkeyToggle and key == Hotkey:lower() then
        Enabled = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false
        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        local targetPart = Mouse.Target
        if targetPart then
            local character = GetCharacterFromTarget(targetPart)
            if character and IsEnemyCharacter(character) then
                if HoldClick then
                    if not CurrentlyPressed then
                        CurrentlyPressed = true
                        mouse1press()
                    end
                else
                    mouse1click()
                end
            else
                if HoldClick and CurrentlyPressed then
                    CurrentlyPressed = false
                    mouse1release()
                end
            end
        else
            if HoldClick and CurrentlyPressed then
                CurrentlyPressed = false
                mouse1release()
            end
        end
    else
        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end
end)
