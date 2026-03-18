-- Debug: Full color detection
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 500, 0, 400)
label.Position = UDim2.new(0.5, -250, 0.5, -200)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.3
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.Code
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Text = "Aim at any character..."
label.Parent = gui

RunService.RenderStepped:Connect(function()
    local target = Mouse.Target
    if target then
        local model = target.Parent
        for i = 1, 10 do
            if model and model:FindFirstChild("Humanoid") then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local player = Players:GetPlayerFromCharacter(model)
                
                local txt = "=== CHARACTER ===\n"
                txt = txt .. "Name: " .. model.Name .. "\n"
                txt = txt .. "Is Player: " .. tostring(player ~= nil) .. "\n"
                txt = txt .. "Health: " .. humanoid.Health .. "\n\n"
                
                local bodyColors = model:FindFirstChildOfClass("BodyColors")
                if bodyColors then
                    txt = txt .. "--- BodyColors ---\n"
                    txt = txt .. "HeadColor: " .. tostring(bodyColors.HeadColor) .. "\n"
                    txt = txt .. "TorsoColor: " .. tostring(bodyColors.TorsoColor) .. "\n"
                    txt = txt .. "LeftArmColor: " .. tostring(bodyColors.LeftArmColor) .. "\n"
                    txt = txt .. "RightArmColor: " .. tostring(bodyColors.RightArmColor) .. "\n"
                    txt = txt .. "LeftLegColor: " .. tostring(bodyColors.LeftLegColor) .. "\n"
                    txt = txt .. "RightLegColor: " .. tostring(bodyColors.RightLegColor) .. "\n"
                else
                    txt = txt .. "No BodyColors\n"
                end
                
                local torso = model:FindFirstChild("Torso")
                local upperTorso = model:FindFirstChild("UpperTorso")
                if torso then
                    txt = txt .. "\n--- Torso ---\n"
                    txt = txt .. "BrickColor: " .. tostring(torso.BrickColor) .. "\n"
                    txt = txt .. "Color (RGB): " .. tostring(torso.Color) .. "\n"
                elseif upperTorso then
                    txt = txt .. "\n--- UpperTorso ---\n"
                    txt = txt .. "BrickColor: " .. tostring(upperTorso.BrickColor) .. "\n"
                    txt = txt .. "Color (RGB): " .. tostring(upperTorso.Color) .. "\n"
                end
                
                if player then
                    txt = txt .. "\n--- Player Info ---\n"
                    txt = txt .. "Team: " .. tostring(player.Team) .. "\n"
                    txt = txt .. "TeamColor: " .. tostring(player.TeamColor) .. "\n"
                end
                
                label.Text = txt
                return
            end
            if model then model = model.Parent end
        end
        label.Text = "No Humanoid found"
    else
        label.Text = "No target"
    end
end)
