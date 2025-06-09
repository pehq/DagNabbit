local Dag = script:FindFirstAncestor("DagNabbit")
local SegmentModel = Dag.Models["3FloorLadderSegment"]

local Segment = {}

function Segment.Generate(Pos:Vector2, Scale:Vector2)
	local Model = SegmentModel:Clone()
	Model.PrimaryPart = Model.Nodes.FloorMiddle
	Model:PivotTo(CFrame.new(Pos.X, 0, Pos.Y))
	Model.Name = `Ladder @ {Pos.X} {Pos.Y}`
	
	return Model
end

return Segment.Generate