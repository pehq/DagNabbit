local Dag = script:FindFirstAncestor("DagNabbit")

local MinesBlueprint = {}

local MinesParts = Dag.Models.Mines

function MinesBlueprint.Floor(pos, size)
	local Part = MinesParts.Floor:Clone()

	Part.Size = Vector3.new(size.X, 4, size.Y)
	Part.CFrame = CFrame.new(pos.X, -Part.Size.Y / 2, pos.Y)
	Part.Name = `{pos.X} {pos.Y}`

	return Part
end

function MinesBlueprint.Wall(pos, size)
	local Part = MinesParts.Wall:Clone()

	Part.Size = Vector3.new(size.X, 2, size.Y)
	Part.CFrame = CFrame.new(pos.X, Part.Size.Y / 2, pos.Y)
	Part.Name = `{pos.X} {pos.Y}`

	return Part
end

return MinesBlueprint