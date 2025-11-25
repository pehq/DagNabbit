--TODO: Maybe tag the parts??
local Dag = script:FindFirstAncestor("DagNabbit")
local CharSet = require(Dag.Data.CharSet)

local ClassicPartsGround = Dag.Models.ClassicPartsGround

local Blueprint = {}

function Blueprint.Ground(Pos:Vector2, Scale:Vector2)
	local Part = ClassicPartsGround.Ground:Clone()

	Part.Size = Vector3.new(Scale.X, 1, Scale.Y)
	Part.CFrame = CFrame.new(Pos.X, -Part.Size.Y / 2, Pos.Y)
	Part.Name = `{Pos.X} {Pos.Y}`

	return Part
end

function Blueprint.Plate(Pos, Scale)
	local Part = ClassicPartsGround.Plate:Clone()
	
	Part.Size = Vector3.new(Scale.X, 0.2, Scale.Y)
	Part.CFrame = CFrame.new(Pos.X, Part.Size.Y /2, Pos.Y)
	Part.Name = `{Pos.X} {Pos.Y}`
	
	return Part
end

function Blueprint.Symmetric(Pos, Scale)
	local Part = ClassicPartsGround.Symmetric:Clone()
	
	Part.Size = Vector3.new(Scale.X, 1, Scale.Y)
	Part.CFrame = CFrame.new(Pos.X, Part.Size.Y /2, Pos.Y)
	Part.Name = `{Pos.X} {Pos.Y}`
	
	return Part
end

function Blueprint.Brick(Pos, Scale)
	local Part = ClassicPartsGround.Brick:Clone()

	Part.Size = Vector3.new(Scale.X, 1.2, Scale.Y)
	Part.CFrame = CFrame.new(Pos.X, Part.Size.Y / 2, Pos.Y)
	Part.Name = `{Pos.X} {Pos.Y}`

	return Part
end

local GenFuncs = {
	Ground = Blueprint.Ground,
	Plate = Blueprint.Plate,
	Symmetric = Blueprint.Symmetric,
	Brick = Blueprint.Brick,
}


return Blueprint
