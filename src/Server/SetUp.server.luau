local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DagNabbit = ReplicatedStorage.DagNabbit

local DagMod = require(ReplicatedStorage.DagNabbit)
local Mat = require(DagNabbit.Matrix)
local RectList = require(DagNabbit.RectList)

local MatWalk = require(DagNabbit.Matrix.RandomWalk)

local LADDER_RADIUS = 24/2
local FLOORS = 20
local LastFloorLadderPos = {}
for i = 1, FLOORS do
    local floorMatrix = Mat.new(Vector2.new(100,100))
    floorMatrix:SetAll(false)

    MatWalk.Run(floorMatrix, 300, math.random(5, 15))
    
    floorMatrix = floorMatrix:Cull()

    floorMatrix:SetByChar(false, "#")
    floorMatrix:SetByChar(true, "_")
    floorMatrix:SetEndingConnectors("H")
    
    local floorRect = RectList.fromMatrix(floorMatrix)
    floorRect:Rescale(Vector2.new(4,4))
    
    for i, v in pairs(floorRect.List) do
        if v.Value ~= "H" then
            continue
        end

        local mid = v:GetMidpoint()
        local diff = Rect.new(mid - Vector2.one * 14, mid + Vector2.one * 14)
        floorRect:Difference(diff, {"H"})
    end
    
    if #LastFloorLadderPos ~= 0 then
        for i, v:Vector2 in pairs(LastFloorLadderPos) do
            local diffRect = Rect.new(v - Vector2.new(LADDER_RADIUS, LADDER_RADIUS), v + Vector2.new(LADDER_RADIUS, LADDER_RADIUS))
            floorRect:Difference(diffRect)
        end
    end
    table.clear(LastFloorLadderPos)
    for i, v in pairs(floorRect.List) do
        if v.Value ~= "H" then
            continue
        end

        local MidPoint = v:GetMidpoint()
        table.insert(LastFloorLadderPos, MidPoint)
    end

    
    local GeneratedModel = floorRect:GenerateList()
    
    local RefPart = Instance.new("Part")
    RefPart.Anchored = true
    RefPart.CFrame = CFrame.identity
    RefPart.Name = "RefPart"
    RefPart.Parent = GeneratedModel

    local ModelSize = GeneratedModel:GetExtentsSize()
    GeneratedModel:PivotTo(CFrame.new(0 + ModelSize.X / 2,i * -50, 0 + ModelSize.Z / 2))
    GeneratedModel.Parent = workspace

    task.wait(1/2)
end
