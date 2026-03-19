run_on_thread(getactorthreads()[1], [=[
-- Services
local function GetService(Name)
    return cloneref(game.GetService(game, Name));
end

local PlayerService = GetService("Players");
local Workspace = GetService("Workspace");
local UserInputService = GetService("UserInputService");

-- Variables
local Camera = Workspace.CurrentCamera;
local LocalPlayer = PlayerService.LocalPlayer;

local SilentAimEnabled = false

-- T Key Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        SilentAimEnabled = not SilentAimEnabled
        print("Silent Aim:", SilentAimEnabled and "ON" or "OFF")
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

            if (not Character) or (Player == LocalPlayer) then
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

    function Targets:GetRandomPart(Character)
        local parts = {}
        
        local bodyParts = {"head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
        
        for _, partName in ipairs(bodyParts) do
            local part = Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                table.insert(parts, part)
            end
        end
        
        if #parts == 0 then
            return Character:FindFirstChild("head") or Character:FindFirstChild("HumanoidRootPart")
        end
        
        local roll = math.random(100)
        
        if roll <= 10 then
            local head = Character:FindFirstChild("head")
            if head then
                return head
            end
        end
        
        local otherParts = {}
        for _, part in ipairs(parts) do
            if part.Name ~= "head" then
                table.insert(otherParts, part)
            end
        end
        
        if #otherParts > 0 then
            return otherParts[math.random(#otherParts)]
        end
        
        return parts[math.random(#parts)]
    end
end

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

        if not SilentAimEnabled then
            return InvokeEvent(table.unpack(Arguments));
        end

        local ClosestTarget = Targets:GetClosestTarget(300);
        local Origin, LookVector = Arguments[2], Arguments[3];
        
        if (typeof(Origin) == "Vector3" and typeof(LookVector) == "Vector3") and ClosestTarget then
            local HitPart = Targets:GetRandomPart(ClosestTarget)

            if HitPart and HitPart:IsA("BasePart") then
                local StaticData = Arguments[4];

                if StaticData then
                    local EndPosition = HitPart.Position;
                    local NewOrigin = EndPosition + Vector3.new(0, 1.3, 0);
                    local velocityMult = 0.99 + (math.random() * 0.02)

                    Arguments[2] = NewOrigin;
                    Arguments[3] = (EndPosition - NewOrigin).Unit * (StaticData.velocity * velocityMult);
                end
            end
        end
    
        return InvokeEvent(table.unpack(Arguments));
    end)
end

print("Silent Aim loaded! Press T to toggle.")
]=])
