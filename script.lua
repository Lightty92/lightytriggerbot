-- Debug: Show all players and their teams
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
print("=== MY INFO ===")
print("My Name:", LocalPlayer.Name)
print("My Team:", LocalPlayer.Team)
print("My TeamColor:", LocalPlayer.TeamColor)
print("==============")

task.wait(1)

for i, player in pairs(Players:GetPlayers()) do
    print("---")
    print("Player:", player.Name)
    print("Team:", player.Team)
    print("TeamColor:", player.TeamColor)
end
