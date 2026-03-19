run_on_thread(getactorthreads()[1], [=[
-- Services
local function GetService(Name)
    return cloneref(game.GetService(game, Name));
end

local PlayerService = GetService("Players");
local Workspace = GetService("Workspace");
local UserInputService = GetService("UserInputService");
local RunService = GetService("RunService");

-- Variables
local Camera = Workspace.CurrentCamera;
local LocalPlayer = PlayerService.LocalPlayer;

local ToggleEnabled = false
local RightClickHeld = false

-- T Key Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        ToggleEnabled = not ToggleEnabled
        print("Aim Assist:", ToggleEnabled and "ON" or "OFF")
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

-- Functions
local Modules = { }; do
    local Required = { };
    local RequestedModules = {
        ["firstPerson"] = {
            ["1"] = "cam",
            ["2"] = "signals",
            ["3"] = "nodes",
            ["4"] = "chars",
            ["5"] = "collisionCheck",
            ["6"] = "firstPersonCam",
            ["7"] = "localChar",
            ["8"] = "breath",
            ["9"] = "charConfig",
            ["10"] = "equipment",
            ["11"] = "players",
            ["12"] = "mouse",
            ["13"] = "networkEvents",
            ["14"] = "gamepad",
            ["15"] = "mathLib",
        },

        ["bullet"] = {
            ["2"] = "charData"
        },
    };

    function Modules:Require(Name)
        local NilInstances = getnilinstances();

        for Index = 1, #NilInstances do
            local Module = NilInstances[Index];
    
            if (Module.Name == Name) then
                return require(Module);
            end
        end
    
        return warn(`Could not require {Name}`);
    end

    function Modules:Get(Module)
        local RequiredModule = Required[Module];

        if (not RequiredModule) then
            RequiredModule = self:Require(Module);
        end

        return RequiredModule;
    end

    function Modules:Initiate()
        for Module, Data in RequestedModules do
            local Initiator = self:Require(Module);

            if (not Initiator) then
                continue;
            end

            Initiator = Initiator.setup;

            for Index, Name in Data do
                Required[Name] = debug.getupvalue(Initiator, Index);
            end
        end
    end
    
    Modules:Initiate();
end

local Targets = { }; do
    local Characters = Modules:Get("chars");

    function Targets:GetTargets()
        local TargetObjects = { };
    
        for PlayerName, Data in Characters do
            local Player = PlayerService:FindFirstChild(PlayerName);

            if (not Player) then
                continue;
            end

            local Character = Data.bodyModel;

            if (not Character) or (Player == LocalPlayer) or (Player.Team == LocalPlayer.Team) then
                continue;
            end

            TargetObjects[Player] = Character;
        end

        local Ragdolls = Workspace:FindFirstChild("Ragdolls")
        if Ragdolls then
            for _, Dummy in ipairs(Ragdolls:GetChildren()) do
                if Dummy:IsA("Model") and Dummy:FindFirstChildOfClass("Humanoid") then
                    local bodyModel = Dummy:FindFirstChild("body") or Dummy
                    TargetObjects[Dummy] = bodyModel;
                end
            end
        end

        return TargetObjects;
    end

    function Targets:GetClosestTarget(Range)
        local Closest, ClosestDistance = nil, Range;

        for Target, Character in self:GetTargets() do
            local Root = Character:FindFirstChild("root") or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso");

            if (not Root) then
                continue;
            end
            
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Root.Position);

            if (not OnScreen) then
                continue;
            end

            local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Camera.ViewportSize / 2).Magnitude;

            if (Distance <= ClosestDistance) then
                Closest = Character;
                ClosestDistance = Distance;
            end
        end

        return Closest;
    end

    function Targets:GetTargetPart(Character)
        local part = Character:FindFirstChild("head")
        if part and part:IsA("BasePart") then
            return part
        end
        return Character:FindFirstChild("HumanoidRootPart")
    end
end

-- Soft Aimbot Settings
local SMOOTHNESS = 0.08

RunService.RenderStepped:Connect(function()
    if not ToggleEnabled or not RightClickHeld then return end
    
    local ClosestTarget = Targets:GetClosestTarget(300)
    
    if ClosestTarget then
        local Part = Targets:GetTargetPart(ClosestTarget)
        if Part then
            local ScreenPos = Camera:WorldToViewportPoint(Part.Position)
            local Center = Camera.ViewportSize / 2
            
            local TargetScreenPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
            local CurrentScreenPos = Vector2.new(Center.X, Center.Y)
            
            local Delta = TargetScreenPos - CurrentScreenPos
            local SmoothDelta = Delta * SMOOTHNESS
            
            local Mouse = LocalPlayer:GetMouse()
            Mouse.X = Mouse.X + SmoothDelta.X
            Mouse.Y = Mouse.Y + SmoothDelta.Y
        end
    end
end)

-- Modules
local Signals = Modules:Get("signals");

-- Hooks
do
    FireEvent = hookfunction(Signals.fire, function(...)
        local Arguments = { ... };

        if (Arguments[2] == "CoreGui") then
            return print("dementia! :steamhappy:");
        end
    
        return FireEvent(table.unpack(Arguments));
    end)

    InvokeEvent = hookfunction(Signals.invoke, function(...)
        local Arguments = { ... };

        if not ToggleEnabled or not RightClickHeld then
            return InvokeEvent(table.unpack(Arguments));
        end

        local ClosestTarget = Targets:GetClosestTarget(300);
        local Origin, LookVector = Arguments[2], Arguments[3];
        
        if (typeof(Origin) == "Vector3" and typeof(LookVector) == "Vector3") and ClosestTarget then
            local HitPart = Targets:GetTargetPart(ClosestTarget)

            if HitPart and HitPart:IsA("BasePart") then
                local StaticData = Arguments[4];

                if StaticData then
                    local EndPosition = HitPart.Position;
                    local NewOrigin = EndPosition + Vector3.new(0, 1.3, 0);

                    Arguments[2] = NewOrigin;
                    Arguments[3] = (EndPosition - NewOrigin).Unit * (StaticData.velocity * 2);
                end
            end
        end
    
        return InvokeEvent(table.unpack(Arguments));
    end)
end

print("Aim Assist loaded!")
print("Press T to toggle")
print("Hold right click to activate")
print("- Soft aim + Silent aim")
print("- No teammates")
]=])
